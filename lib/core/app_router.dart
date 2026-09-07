import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/game_screen.dart';
import '../main.dart'; // MainNavigation 이 있는 곳

// 모든 프론트엔드 UI 화면들을 연결하는 라우터 (백엔드 로직 제외)
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case '/main':
        return MaterialPageRoute(builder: (_) => const MainNavigation());
      case '/game':
        return MaterialPageRoute(builder: (_) => const GameScreen());
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('경로 오류'))));
    }
  }
}
