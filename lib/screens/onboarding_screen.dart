import 'package:flutter/material.dart';
import 'login_screen.dart';

/// OOMU 인트로 온보딩 화면
/// 신규 'assets/images/OOMU 앱 UI 디자인.html' 규격의 온보딩 경험(initialStage: 1)을 제공합니다.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreen(initialStage: 1);
  }
}
