import 'package:flutter/material.dart';

class ProfileDetailScreen extends StatelessWidget {
  final String name;
  const ProfileDetailScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('프로필 상세', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 프로필 사진 (크게)
            Container(
              height: 320,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Center(
                child: Text('블러 처리된 프로필 이미지 (크게)', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$name, 24', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('📍 서울 강남구 · 36.5° 매너', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  
                  const SizedBox(height: 32),
                  const Text('자기소개', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text(
                    '퇴근하고 분위기 좋은 카페에서 커피 마시는 걸 좋아해요!\n주말에는 주로 전시회를 보러 다닙니다.\n비슷한 취향이시라면 편하게 대화 나눠요 😊',
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),
                  
                  const SizedBox(height: 32),
                  const Text('나의 취향 및 관심사', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8, runSpacing: 12,
                    children: [
                      _buildTag('🎨 전시회 관람'), _buildTag('☕ 산미 없는 커피'),
                      _buildTag('🐶 강아지 집사'), _buildTag('🎬 넷플릭스 정주행'),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  // 큰 보이스핑 버튼
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0EC),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_fill, color: Color(0xFFFF8A65), size: 36),
                        SizedBox(width: 12),
                        Text('Voice Ping 들어보기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              // TODO: 대화 신청 로직
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8A65),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('⏱️ 10분 익명 대화 신청하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }
}
