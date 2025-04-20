class AppConfig {
  // عناوين URL للواجهات الخلفية
  static const String apiBaseUrl = 'https://api.example.com/api';
  static const String webSocketUrl = 'wss://socket.example.com';
  static const String mediaServerUrl = 'wss://media.example.com';

  // إعدادات HTTP
  static const int connectTimeout = 15000; // بالميلي ثانية
  static const int receiveTimeout = 15000; // بالميلي ثانية

  // إعدادات WebSocket
  static const int webSocketReconnectDelay = 3000; // بالميلي ثانية
  static const int webSocketHeartbeatInterval = 30000; // بالميلي ثانية

  // إعدادات التخزين
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';

  // البيئة
  static const String environment =
      'development'; // development, staging, production

  // مفاتيح API للخدمات الخارجية (إن وجدت)
  static const String firebaseApiKey = 'YOUR_FIREBASE_API_KEY';

  // إعدادات الألعاب
  static const bool enableGames = true;

  // هل التطبيق في وضع التصحيح؟
  static const bool debugMode = true;
}
