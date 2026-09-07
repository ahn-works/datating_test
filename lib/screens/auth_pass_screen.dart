import 'package:flutter/material.dart';
import 'profile_setup_screen.dart';

class AuthPassScreen extends StatelessWidget {
  const AuthPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.verified_user, size: 60, color: Color(0xFFFF8A65)),
            const SizedBox(height: 24),
            const Text('안전한 만남을 위해\n본인인증을 진행해주세요.', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.4)),
            const SizedBox(height: 16),
            const Text('스팟10은 100% 신원 인증된 유저만\n활동할 수 있는 클린 플랫폼입니다.', style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline, color: Colors.grey, size: 20),
                  SizedBox(width: 12),
                  Expanded(child: Text('인증 정보는 안전하게 암호화되어 보관되며, 프로필에 실명이 노출되지 않습니다.', style: TextStyle(color: Colors.grey, fontSize: 12))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileSetupScreen())),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A65),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('PASS 본인인증하기', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
