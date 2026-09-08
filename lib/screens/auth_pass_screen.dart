
import 'package:flutter/material.dart';
import 'profile_setup_screen.dart';

class AuthPassScreen extends StatelessWidget {
  const AuthPassScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(title: const Text('본인 인증', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
    body: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('안전한 서비스를 위해
본인 인증이 필요합니다', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.4)),
      const SizedBox(height: 8),
      const Text('인증 정보는 서버에 저장되지 않으며,
만 14세 이상만 가입할 수 있습니다.', style: TextStyle(color: Colors.grey, height: 1.5)),
      const SizedBox(height: 40),
      _authItem('휴대폰 인증', '본인 휴대폰 번호로 인증', Icons.phone_android),
      const SizedBox(height: 16),
      _authItem('카카오 인증', '카카오톡 계정으로 인증', Icons.chat),
      const SizedBox(height: 16),
      _authItem('네이버 인증', '네이버 계정으로 인증', Icons.person),
      const Spacer(),
      ElevatedButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSetupScreen())),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: const Text('휴대폰으로 인증하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    ])),
  );
  static Widget _authItem(String t, String s, IconData icon) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
    child: Row(children: [Icon(icon, color: const Color(0xFFFF3B30)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.bold)), Text(s, style: const TextStyle(color: Colors.grey, fontSize: 13))]))]),
  );
}
