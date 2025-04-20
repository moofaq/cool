import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voice_chat_app/features/chat/presentation/screens/rooms_list_screen.dart';
import 'package:voice_chat_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:voice_chat_app/features/games/presentation/screens/games_list_screen.dart';
import 'package:voice_chat_app/features/gifts/presentation/screens/gifts_screen.dart';

class VoiceChatApp extends StatelessWidget {
  const VoiceChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'تطبيق الدردشة الصوتية',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo',
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }

  // تكوين التوجيه باستخدام GoRouter
  final GoRouter _router = GoRouter(
    initialLocation: '/rooms',
    routes: [
      GoRoute(
        path: '/rooms',
        builder: (context, state) => const RoomsListScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/games',
        builder: (context, state) => const GamesListScreen(),
      ),
      GoRoute(path: '/gifts', builder: (context, state) => const GiftsScreen()),
    ],
  );
}
