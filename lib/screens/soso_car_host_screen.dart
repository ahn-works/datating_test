import 'package:flutter/material.dart';

class SosoCarHostScreen extends StatelessWidget {
  const SosoCarHostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('여행 모임 등록', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('어디로 떠나시나요?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: '목적지를 입력해주세요',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            
            const Text('집결 장소 및 시간', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: '예: 마포구청역 2번 출구',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),

            const Text('내 차 정보 및 성향', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                _buildTagChip('조용한 힐링'), _buildTagChip('수다 환영'), _buildTagChip('플리 공유'), _buildTagChip('비흡연 차량'), _buildTagChip('반려동물 가능')
              ],
            ),
            const SizedBox(height: 32),

            const Text('비용 정산 방식', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFF2E4F28)), borderRadius: BorderRadius.circular(12), color: const Color(0xFFE2F0D9).withOpacity(0.3)),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF2E4F28)),
                  SizedBox(width: 12),
                  Text('유류비 + 톨비 1/N 정산', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC04020), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('모집 시작하기', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}
