import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:voice_chat_app/app/config.dart';
import 'package:voice_chat_app/core/utils/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// تعريف أنواع الأحداث
enum WebSocketEventType {
  message,
  join,
  leave,
  typing,
  gift,
  roomUpdate,
  error,
}

// كلاس لتمثيل الأحداث
class WebSocketEvent {
  final WebSocketEventType type;
  final Map<String, dynamic> data;

  WebSocketEvent(this.type, this.data);

  factory WebSocketEvent.fromJson(Map<String, dynamic> json) {
    return WebSocketEvent(_stringToEventType(json['type']), json['data']);
  }

  static WebSocketEventType _stringToEventType(String type) {
    switch (type) {
      case 'message':
        return WebSocketEventType.message;
      case 'join':
        return WebSocketEventType.join;
      case 'leave':
        return WebSocketEventType.leave;
      case 'typing':
        return WebSocketEventType.typing;
      case 'gift':
        return WebSocketEventType.gift;
      case 'room_update':
        return WebSocketEventType.roomUpdate;
      default:
        return WebSocketEventType.error;
    }
  }
}

class WebSocketService {
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  final _storage = const FlutterSecureStorage();

  // بث الأحداث لمن يستمع إليها
  final StreamController<WebSocketEvent> _eventsController =
      StreamController<WebSocketEvent>.broadcast();
  Stream<WebSocketEvent> get events => _eventsController.stream;

  // الحالة
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // الاتصال بالخادم
  Future<void> connect() async {
    if (_isConnected) return;

    try {
      // جلب الرمز المميز للمصادقة
      final token = await _storage.read(key: AppConfig.authTokenKey);

      if (token == null) {
        AppLogger.log(
          'لا يمكن الاتصال بـ WebSocket: لم يتم العثور على رمز المصادقة',
          LogLevel.error,
        );
        return;
      }

      // الاتصال بالخادم مع إرسال الرمز المميز
      final uri = Uri.parse('${AppConfig.webSocketUrl}?token=$token');
      _channel = WebSocketChannel.connect(uri);

      // الاستماع للأحداث
      _channel!.stream.listen(_onMessage, onError: _onError, onDone: _onDone);

      // بدء نبض القلب للحفاظ على الاتصال
      _startHeartbeat();

      _isConnected = true;
      AppLogger.log('تم الاتصال بـ WebSocket', LogLevel.info);
    } catch (e) {
      AppLogger.log('خطأ في الاتصال بـ WebSocket: $e', LogLevel.error);
      _scheduleReconnect();
    }
  }

  // إغلاق الاتصال
  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
      _channel = null;
    }

    _stopHeartbeat();
    _stopReconnect();
    _isConnected = false;
    AppLogger.log('تم قطع الاتصال بـ WebSocket', LogLevel.info);
  }

  // إرسال رسالة
  void send(String type, Map<String, dynamic> data) {
    if (!_isConnected) {
      AppLogger.log(
        'محاولة إرسال رسالة ولكن WebSocket غير متصل',
        LogLevel.warning,
      );
      connect(); // محاولة إعادة الاتصال
      return;
    }

    final message = jsonEncode({
      'type': type,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    _channel!.sink.add(message);
  }

  // إرسال رسالة نصية إلى غرفة محددة
  void sendMessage(String roomId, String content) {
    send('message', {
      'room_id': roomId,
      'content': content,
      'message_type': 'text',
    });
  }

  // الانضمام إلى غرفة
  void joinRoom(String roomId) {
    send('join', {'room_id': roomId});
  }

  // مغادرة غرفة
  void leaveRoom(String roomId) {
    send('leave', {'room_id': roomId});
  }

  // إرسال حالة الكتابة
  void sendTyping(String roomId, bool isTyping) {
    send('typing', {'room_id': roomId, 'is_typing': isTyping});
  }

  // إرسال هدية
  void sendGift(String roomId, String userId, String giftId) {
    send('gift', {'room_id': roomId, 'user_id': userId, 'gift_id': giftId});
  }

  // التعامل مع الرسائل الواردة
  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final event = WebSocketEvent.fromJson(data);

      // إرسال الحدث إلى المستمعين
      _eventsController.add(event);
    } catch (e) {
      AppLogger.log('خطأ في تحليل رسالة WebSocket: $e', LogLevel.error);
    }
  }

  // التعامل مع الأخطاء
  void _onError(error) {
    AppLogger.log('خطأ في WebSocket: $error', LogLevel.error);
    _scheduleReconnect();
  }

  // التعامل مع إغلاق الاتصال
  void _onDone() {
    _isConnected = false;
    AppLogger.log('تم إغلاق اتصال WebSocket', LogLevel.info);
    _scheduleReconnect();
  }

  // جدولة إعادة الاتصال
  void _scheduleReconnect() {
    _stopReconnect(); // إيقاف أي محاولات سابقة لإعادة الاتصال

    _reconnectTimer = Timer(
      Duration(milliseconds: AppConfig.webSocketReconnectDelay),
      connect,
    );
  }

  // إيقاف محاولات إعادة الاتصال
  void _stopReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  // بدء نبض القلب للحفاظ على الاتصال
  void _startHeartbeat() {
    _stopHeartbeat(); // إيقاف أي نبض قلب سابق

    _heartbeatTimer = Timer.periodic(
      Duration(milliseconds: AppConfig.webSocketHeartbeatInterval),
      (_) {
        if (_isConnected) {
          send('heartbeat', {
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        }
      },
    );
  }

  // إيقاف نبض القلب
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  // التنظيف عند التخلص من الخدمة
  void dispose() {
    disconnect();
    _eventsController.close();
  }
}
