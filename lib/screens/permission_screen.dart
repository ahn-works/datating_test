import 'package:flutter/material.dart';
import '../main.dart'; 

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text('스팟10 이용을 위해\n앱 권한을 허용해주세요.', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.4)),
              const SizedBox(height: 12),
              const Text('더 나은 매칭과 원활한 서비스 이용을 위해\n아래 권한들이 필요합니다.', style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5)),
              const SizedBox(height: 48),
              _buildPermissionItem(Icons.location_on, '위치 (필수)', '내 주변 유저를 찾고 중간지점 카페를 추천받기 위해 필요합니다.'),
              const SizedBox(height: 32),
              _buildPermissionItem(Icons.mic, '마이크 (선택)', '나만의 Voice Ping을 녹음하고 매력을 어필하기 위해 필요합니다.'),
              const SizedBox(height: 32),
              _buildPermissionItem(Icons.notifications_active, '알림 (선택)', '새로운 매칭 시그널과 메시지 도착 알림을 받기 위해 필요합니다.'),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainNavigation()), (route) => false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A65), 
                  minimumSize: const Size(double.infinity, 56), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                ),
                child: const Text('확인하고 시작하기', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12), 
          decoration: const BoxDecoration(color: Color(0xFFF9F9F9), shape: BoxShape.circle), 
          child: Icon(icon, color: const Color(0xFFFF8A65), size: 28)
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(color: Colors.black87, height: 1.4)),
            ],
          ),
        )
      ],
    );
  }
}
