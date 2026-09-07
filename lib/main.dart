import 'package:flutter/material.dart';
import 'core/app_router.dart';

// 앱 구동 시 가장 먼저 실행되는 곳으로, UI가 아닌 "상태 모니터링"을 담당합니다.

void main() {
  runApp(const Spot10AppRoot());
}

class Spot10AppRoot extends StatelessWidget {
  const Spot10AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    // 여기서는 AuthController의 상태를 감시(Listen)하고 있다가,
    // 유저가 로그인 상태면 initialRoute를 '/main'으로,
    // 비로그인 상태면 '/login'으로 알아서 길을 열어주는 뼈대 역할을 합니다.
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spot10 Core',
      // 라우터 연결 (화면 이동 권한 위임)
      onGenerateRoute: AppRouter.generateRoute,
      // 앱이 켜질 때 상태에 따라 첫 진입점을 결정
      initialRoute: '/', // 스플래시 화면에서 로그인 상태 체크 후 자동 이동함
    );
  }
}
