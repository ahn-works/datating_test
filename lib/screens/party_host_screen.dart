import 'package:flutter/material.dart';

class PartyHostScreen extends StatelessWidget {
  const PartyHostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Spot Party 주최하기', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('어떤 모임을 만들어볼까요?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            _buildInputField('모임 이름', '예: 성수동 하이볼 & 타코 팟!'),
            const SizedBox(height: 24),
            _buildInputField('장소 (또는 지역)', '예: 성수역 3번 출구 근처'),
            const SizedBox(height: 24),
            const Text('모집 인원 (본인 포함)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildChoiceChip('2명 (1:1)'),
                const SizedBox(width: 8),
                _buildChoiceChip('4명 (2:2)', isSelected: true),
                const SizedBox(width: 8),
                _buildChoiceChip('6명 (3:3)'),
              ],
            ),
            const SizedBox(height: 24),
            _buildInputField('모임 상세 설명', '어떤 분위기의 모임인지 설명해주세요.', maxLines: 4),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A65),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('모임 개설하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceChip(String label, {bool isSelected = false}) {
    return FilterChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
      selected: isSelected,
      onSelected: (bool value) {},
      backgroundColor: const Color(0xFFF5F5F5),
      selectedColor: const Color(0xFFFF8A65),
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
    );
  }
}
