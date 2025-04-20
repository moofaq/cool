import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:voice_chat_app/app/config.dart';
import 'package:voice_chat_app/core/utils/logger.dart';

class VoiceService {
  // متغيرات WebRTC
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  // حالة الخدمة
  bool _isInitialized = false;
  bool _isMicrophoneEnabled = false;
  bool _isConnected = false;
  String? _currentRoomId;

  // حالة الخدمة
  bool get isInitialized => _isInitialized;
  bool get isMicrophoneEnabled => _isMicrophoneEnabled;
  bool get isConnected => _isConnected;
  String? get currentRoomId => _currentRoomId;

  // للإعلام عن تغييرات الحالة
  final _stateController = StreamController<VoiceStateEvent>.broadcast();
  Stream<VoiceStateEvent> get stateStream => _stateController.stream;

  // تهيئة الخدمة
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // تهيئة الاتصال المحلي
      _localStream = await _createLocalStream();

      // تهيئة إعدادات الاتصال
      _peerConnection = await _createPeerConnection();

      // إضافة المسار المحلي
      if (_localStream != null) {
        for (var track in _localStream!.getTracks()) {
          await _peerConnection?.addTrack(track, _localStream!);
        }
      }

      _isInitialized = true;
      _emitStateChange(VoiceStateEventType.initialized);
      AppLogger.log('تمت تهيئة خدمة الصوت بنجاح', LogLevel.info);
    } catch (e) {
      AppLogger.log('فشل في تهيئة خدمة الصوت: $e', LogLevel.error);
      _emitStateChange(VoiceStateEventType.error, {'error': e.toString()});
    }
  }

  // إنشاء مسار الصوت المحلي
  Future<MediaStream> _createLocalStream() async {
    final mediaConstraints = <String, dynamic>{'audio': true, 'video': false};

    try {
      final stream = await navigator.mediaDevices.getUserMedia(
        mediaConstraints,
      );

      // قم بإيقاف الميكروفون بشكل افتراضي
      stream.getAudioTracks().forEach((track) {
        track.enabled = false;
      });

      return stream;
    } catch (e) {
      AppLogger.log('فشل في الوصول إلى الميكروفون: $e', LogLevel.error);
      rethrow;
    }
  }

  // إنشاء اتصال WebRTC
  Future<RTCPeerConnection> _createPeerConnection() async {
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ],
    };

    final constraints = {
      'mandatory': {},
      'optional': [
        {'DtlsSrtpKeyAgreement': true},
      ],
    };

    try {
      final pc = await createPeerConnection(config, constraints);

      // إعداد مستمعي الأحداث
      pc.onIceCandidate = (candidate) {
        // هنا سيتم إرسال مرشحي ICE إلى الخادم
        // ستحتاج إلى تنفيذ هذا حسب واجهة برمجة التطبيقات الخاصة بك
      };

      pc.onIceConnectionState = (state) {
        AppLogger.log('حالة اتصال ICE: $state', LogLevel.debug);

        if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
          _isConnected = true;
          _emitStateChange(VoiceStateEventType.connected);
        } else if (state ==
                RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
            state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
          _isConnected = false;
          _emitStateChange(VoiceStateEventType.disconnected);
        }
      };

      pc.onAddStream = (stream) {
        // إضافة مسار صوتي جديد عند استلامه
        _emitStateChange(VoiceStateEventType.streamAdded, {'stream': stream});
      };

      return pc;
    } catch (e) {
      AppLogger.log('فشل في إنشاء اتصال WebRTC: $e', LogLevel.error);
      rethrow;
    }
  }

  // الانضمام إلى غرفة صوتية
  Future<bool> joinRoom(String roomId) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // هنا ستحتاج إلى تنفيذ المنطق للاتصال بخادم MediaSoup
      // وإنشاء اتصال WebRTC لهذه الغرفة المحددة

      _currentRoomId = roomId;
      _emitStateChange(VoiceStateEventType.roomJoined, {'roomId': roomId});

      AppLogger.log('تم الانضمام إلى الغرفة الصوتية: $roomId', LogLevel.info);
      return true;
    } catch (e) {
      AppLogger.log('فشل في الانضمام إلى الغرفة الصوتية: $e', LogLevel.error);
      _emitStateChange(VoiceStateEventType.error, {'error': e.toString()});
      return false;
    }
  }

  // مغادرة الغرفة الصوتية
  Future<void> leaveRoom() async {
    if (_currentRoomId == null) return;

    try {
      // إجراءات قطع الاتصال بالغرفة

      final roomId = _currentRoomId;
      _currentRoomId = null;
      _isConnected = false;

      _emitStateChange(VoiceStateEventType.roomLeft, {'roomId': roomId});
      AppLogger.log('تمت مغادرة الغرفة الصوتية: $roomId', LogLevel.info);
    } catch (e) {
      AppLogger.log('خطأ أثناء مغادرة الغرفة الصوتية: $e', LogLevel.error);
      _emitStateChange(VoiceStateEventType.error, {'error': e.toString()});
    }
  }

  // تشغيل/إيقاف الميكروفون
  Future<bool> toggleMicrophone() async {
    if (!_isInitialized || _localStream == null) {
      return false;
    }

    try {
      final tracks = _localStream!.getAudioTracks();

      if (tracks.isNotEmpty) {
        final track = tracks[0];
        track.enabled = !track.enabled;
        _isMicrophoneEnabled = track.enabled;

        _emitStateChange(
          _isMicrophoneEnabled
              ? VoiceStateEventType.microphoneEnabled
              : VoiceStateEventType.microphoneDisabled,
        );

        AppLogger.log(
          _isMicrophoneEnabled ? 'تم تشغيل الميكروفون' : 'تم إيقاف الميكروفون',
          LogLevel.info,
        );

        return true;
      }

      return false;
    } catch (e) {
      AppLogger.log('خطأ في تبديل حالة الميكروفون: $e', LogLevel.error);
      return false;
    }
  }

  // إرسال تغيير الحالة
  void _emitStateChange(
    VoiceStateEventType type, [
    Map<String, dynamic>? data,
  ]) {
    _stateController.add(VoiceStateEvent(type, data ?? {}));
  }

  // التنظيف عند التخلص من الخدمة
  Future<void> dispose() async {
    try {
      await leaveRoom();

      // إيقاف المسارات الصوتية المحلية
      _localStream?.getTracks().forEach((track) {
        track.stop();
      });

      // إغلاق اتصال WebRTC
      await _peerConnection?.close();
      _peerConnection = null;

      // إغلاق ناقل الأحداث
      await _stateController.close();

      _isInitialized = false;
      AppLogger.log('تم التخلص من خدمة الصوت', LogLevel.info);
    } catch (e) {
      AppLogger.log('خطأ أثناء التخلص من خدمة الصوت: $e', LogLevel.error);
    }
  }
}

// تعريف أنواع أحداث الصوت
enum VoiceStateEventType {
  initialized,
  error,
  connected,
  disconnected,
  roomJoined,
  roomLeft,
  microphoneEnabled,
  microphoneDisabled,
  streamAdded,
}

// فئة أحداث حالة الصوت
class VoiceStateEvent {
  final VoiceStateEventType type;
  final Map<String, dynamic> data;

  VoiceStateEvent(this.type, this.data);
}
