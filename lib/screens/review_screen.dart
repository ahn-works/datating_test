import 'package:flutter/material.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('만남 매너 평가', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // 뒤로가기 버튼 숨김 (필수 평가)
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('오늘 Ji-won님과의\n만남은 어떠셨나요?', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.4)),
            const SizedBox(height: 8),
            const Text('솔직한 피드백은 상대방의 매너 온도에 반영됩니다.', style: TextStyle(color: Colors.grey, fontSize: 15)),
            const SizedBox(height: 40),
            
            const Text('✨ 어떤 점이 좋았나요?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10, runSpacing: 12,
              children: [
                _buildReviewChip('친절하고 매너가 좋아요', isSelected: true),
                _buildReviewChip('대화가 잘 통해요', isSelected: true),
                _buildReviewChip('사진과 느낌이 비슷해요', isSelected: false),
                _buildReviewChip('시간 약속을 잘 지켜요', isSelected: false),
                _buildReviewChip('리드를 잘 해줘요', isSelected: false),
              ],
            ),
            
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text('혹시 불편하셨나요? (비매너 신고)', style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A65),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('평가 완료하고 홈으로 가기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewChip(String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFF0EC) : Colors.white,
        border: Border.all(color: isSelected ? const Color(0xFFFF8A65) : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFFFF8A65) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
