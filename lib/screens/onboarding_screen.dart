import 'package:flutter/material.dart';
import 'voice_ping_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('프로필 설정 (1/3)', style: TextStyle(color: Colors.black, fontSize: 16)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('나를 잘 표현하는\n취향 태그를 골라주세요.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.4)),
            const SizedBox(height: 12),
            const Text('최대 5개까지 선택할 수 있어요.', style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 32),
            Wrap(
              spacing: 10,
              runSpacing: 12,
              children: [
                _buildSelectableTag('☕ 카페 투어', isSelected: true),
                _buildSelectableTag('🎬 영화/넷플릭스', isSelected: false),
                _buildSelectableTag('💪 헬스/운동', isSelected: false),
                _buildSelectableTag('🍷 와인/칵테일', isSelected: true),
                _buildSelectableTag('✈️ 여행', isSelected: false),
                _buildSelectableTag('📚 독서', isSelected: false),
                _buildSelectableTag('🐶 반려동물', isSelected: true),
                _buildSelectableTag('🎮 게임', isSelected: false),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const VoicePingScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A65),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('다음 단계로', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableTag(String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFF8A65) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? const Color(0xFFFF8A65) : Colors.transparent),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
