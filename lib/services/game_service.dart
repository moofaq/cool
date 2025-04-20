import 'dart:async';
import 'dart:convert';
import 'package:voice_chat_app/app/config.dart';
import 'package:voice_chat_app/core/utils/logger.dart';
import 'package:voice_chat_app/features/games/data/models/game_model.dart';
import 'package:voice_chat_app/services/api_service.dart';
import 'package:voice_chat_app/services/websocket_service.dart';
import 'package:flutter/services.dart';

class GameService {
  final ApiService _apiService;
  final WebSocketService _webSocketService;
  
  // سجل الألعاب
  List<GameModel> _availableGames = [];
  String? _currentGameId;
  String? _currentRoomId;
  bool _isPlaying = false;
  
  // للاستماع لأحداث اللعبة
  final _gameEventsController = StreamController<GameEvent>.broadcast();
  Stream<GameEvent> get gameEvents => _gameEventsController.stream;
  
  // الحالة
  List<GameModel> get availableGames => _availableGames;
  bool get isPlaying => _isPlaying;
  String? get currentGameId => _currentGameId;
  String? get currentRoomId => _currentRoomId;
  
  GameService(this._apiService, this._webSocketService) {
    // الاستماع لأحداث WebSocket المتعلقة بالألعاب
    _webSocketService.events.listen(_handleWebSocketEvent);
  }
  
  // جلب قائمة الألعاب المتاحة
  Future<List<GameModel>> fetchAvailableGames() async {
    try {
      final response = await _apiService.get('/games');
      
      if (response.statusCode == 200) {
        final List<dynamic> gamesJson = response.data['data'];
        _availableGames = gamesJson
            .map((json) => GameModel.fromJson(json))
            .where((game) => game.isActive)
            .toList();
        
        return _availableGames;
      } else {
        throw Exception('فشل في جلب الألعاب: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.log('خطأ في جلب الألعاب: $e', LogLevel.error);
      rethrow;
    }
  }
  
  // الحصول على معلومات لعبة معينة
  Future<GameModel> getGameDetails(String gameId) async {
    try {
      final response = await _apiService.get('/games/$gameId');
      
      if (response.statusCode == 200) {
        return GameModel.fromJson(response.data['data']);
      } else {
        throw Exception('فشل في جلب تفاصيل اللعبة: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.log('خطأ في جلب تفاصيل اللعبة: $e', LogLevel.error);
      rethrow;
    }
  }
  
  // إنشاء غرفة لعبة جديدة
  Future<String> createGameRoom(String gameId, String roomName) async {
    try {
      final response = await _apiService.post('/rooms', data: {
        'name': roomName,
        'type': 'game',
        'game_id': gameId,
      });
      
      if (response.statusCode == 201) {
        final roomId = response.data['data']['id'];
        return roomId;
      } else {
        throw Exception('فشل في إنشاء غرفة لعبة: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.log('خطأ في إنشاء غرفة لعبة: $e', LogLevel.error);
      rethrow;
    }
  }
  
  // بدء لعبة في غرفة
  Future<bool> startGame(String roomId, String gameId) async {
    if (_isPlaying) {
      await endGame();
    }
    
    try {
      // إرسال طلب لبدء اللعبة
      final response = await _apiService.post('/games/start', data: {
        'room_id': roomId,
        'game_id': gameId,
      });
      
      if (response.statusCode == 200) {
        _currentGameId = gameId;
        _currentRoomId = roomId;
        _isPlaying = true;
        
        // إرسال حدث بدء اللعبة
        _emitGameEvent(GameEventType.gameStarted, {
          'roomId': roomId,
          'gameId': gameId,
          'config': response.data['data']['config'],
        });
        
        // إرسال حدث انضمام للعبة إلى WebSocket
        _webSocketService.send('game_join', {
          'room_id': roomId,
          'game_id': gameId,
        });
        
        AppLogger.log('تم بدء اللعبة $gameId في الغرفة $roomId', LogLevel.info);
        return true;
      } else {
        throw Exception('فشل في بدء اللعبة: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.log('خطأ في بدء اللعبة: $e', LogLevel.error);
      _emitGameEvent(GameEventType.error, {'error': e.toString()});
      return false;
    }
  }
  
  // إنهاء اللعبة الحالية
  Future<bool> endGame() async {