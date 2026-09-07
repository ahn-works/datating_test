import 'package:flutter/material.dart';
import 'profile_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Spot10', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF8A65))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Color(0xFFFF8A65)), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // 유저 카드를 누르면 프로필 상세로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileDetailScreen(name: 'Ji-won')),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          child: const Center(child: Text('블러 처리된 프로필 이미지', style: TextStyle(color: Colors.white))),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Ji-won, 24', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              const Text('📍 서울 강남구 · 36.5°', style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8, runSpacing: 8,
                                children: [
                                  _buildTag('🎨 Creative'), _buildTag('☕ Coffee Lover'), _buildTag('✈️ Traveler'),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0EC),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.play_circle_fill, color: Color(0xFFFF8A65), size: 32),
                                    SizedBox(width: 8),
                                    Text('Voice Ping', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  // 대화 신청 버튼 눌러도 프로필 상세와 동일하게 동작하도록 (테스트용)
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ProfileDetailScreen(name: 'Ji-won')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF8A65),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: const Text('⏱️ 10분 익명 대화 시작', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
