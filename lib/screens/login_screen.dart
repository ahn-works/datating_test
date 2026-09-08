
import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(child: Padding(padding: const EdgeInsets.all(32), child: Column(children: [
      const Spacer(),
      Container(width: 72, height: 72, decoration: BoxDecoration(color: const Color(0xFFFF3B30), borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.travel_explore, color: Colors.white, size: 40)),
      const SizedBox(height: 24),
      const Text('Travel Buddy', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('동네 친구와 함께하는 실제 여행', style: TextStyle(color: Colors.grey)),
      const Spacer(),
      _btn(context, '카카오톡으로 시작', const Color(0xFFFEE500), Colors.black, Icons.chat_bubble),
      const SizedBox(height: 12),
      _btn(context, '네이버로 시작', const Color(0xFF03C75A), Colors.white, Icons.account_circle),
      const SizedBox(height: 12),
      _btn(context, '후다오로 시작', Colors.black, Colors.white, Icons.apple),
      const SizedBox(height: 32),
      const Text('가입 시 이용약관 및 개인정보보호정첸에 동의하는 것으로 간주합니다.', style: TextStyle(color: Colors.grey, fontSize: 11), textAlign: TextAlign.center),
    ]))),
  );
  Widget _btn(BuildContext ctx, String label, Color bg, Color fg, IconData icon) => ElevatedButton.icon(
    onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const OnboardingScreen())),
    icon: Icon(icon, color: fg, size: 20),
    label: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.bold)),
    style: ElevatedButton.styleFrom(backgroundColor: bg, minimumSize: const Size(double.infinity, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
  );
}
