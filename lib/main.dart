import 'package:flutter/material.dart';
import 'package:voice_chat_app/app/app.dart';
import 'package:voice_chat_app/core/utils/logger.dart';
import 'package:voice_chat_app/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'core/auth/auth_provider.dart';
import 'features/chat/domain/providers/chat_provider.dart';

// Service locator
final GetIt serviceLocator = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تسجيل الخدمات
  setupServices();

  // تهيئة الـ Logger
  setupLogger();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const VoiceChatApp(),
    ),
  );
}

void setupServices() {
  // تسجيل ApiService كخدمة singleton
  serviceLocator.registerLazySingleton<ApiService>(() => ApiService());

  // يمكن تسجيل المزيد من الخدمات هنا
}

void setupLogger() {
  AppLogger.init();
  AppLogger.log('تم بدء التطبيق', LogLevel.info);
}
