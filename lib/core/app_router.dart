import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/game_screen.dart';
import '../screens/party_host_screen.dart';
import '../screens/qr_checkin_screen.dart';
import '../screens/review_screen.dart';
import '../main.dart'; // MainNavigation 이 있는 곳

// 모든 프론트엔드 UI 화면들을 연결하는 라우터
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
      case '/party_host':
        return MaterialPageRoute(builder: (_) => const PartyHostScreen());
      case '/qr_checkin':
        return MaterialPageRoute(builder: (_) => const QrCheckinScreen());
      case '/review':
        return MaterialPageRoute(builder: (_) => const ReviewScreen());
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('경로 오류'))));
    }
  }
}
