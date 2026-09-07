import 'package:flutter/material.dart';

class SecondSpotScreen extends StatelessWidget {
  const SecondSpotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('2차 스팟 추천', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('분위기가 좋다면?\n근처 제휴 스팟으로 이동해보세요!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.4)),
          const SizedBox(height: 8),
          const Text('스팟10 유저 인증 시 전 메뉴 10% 할인 혜택', style: TextStyle(color: Color(0xFFFF8A65), fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildSpotCard('더 글렌도르 펍', '도보 3분 · 칵테일 바', '어두운 조명, 잔잔한 재즈 음악', 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?auto=format&fit=crop&w=400&q=80'),
          const SizedBox(height: 16),
          _buildSpotCard('카페 어니언', '도보 5분 · 베이커리 카페', '넓고 탁 트인 루프탑', 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=400&q=80'),
          const SizedBox(height: 16),
          _buildSpotCard('야키토리 도쿄', '도보 8분 · 이자카야', '프라이빗한 룸 좌석 제공', 'https://images.unsplash.com/photo-1525610553991-2bede1a236e2?auto=format&fit=crop&w=400&q=80'),
        ],
      ),
    );
  }

  Widget _buildSpotCard(String name, String distance, String desc, String imageUrl) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFFF0EC), borderRadius: BorderRadius.circular(8)), child: const Text('-10%', style: TextStyle(color: Color(0xFFFF8A65), fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                ),
                const SizedBox(height: 4),
                Text(distance, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Text(desc, style: const TextStyle(color: Colors.black87)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFFF8A65), side: const BorderSide(color: Color(0xFFFF8A65)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('상대방에게 제안하기', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
