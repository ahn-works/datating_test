import 'package:flutter/material.dart';
import 'login_screen.dart';

/// OOMU 스플래시 화면
/// 신규 'assets/images/OOMU 앱 UI 디자인.html' 규격의 스플래시 인트로(initialStage: 0)를 제공합니다.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreen(initialStage: 0);
  }
}
