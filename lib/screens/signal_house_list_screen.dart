import 'package:flutter/material.dart';

class SignalHouseListScreen extends StatelessWidget {
  const SignalHouseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHouseCard('시그널 하우스 4기 모집 중', '현재 남 3 / 여 4 지원완료', '이번 주 목요일 입주 시작', true),
        const SizedBox(height: 16),
        _buildHouseCard('시그널 하우스 3기 진행 중', '입주 완료 (익명 미션 진행 중)', '하트 트래블 준비 중', false),
        const SizedBox(height: 16),
        _buildHouseCard('시그널 하우스 2기 종료', '매칭 성공 3쌍 탄생!', '종료됨', false),
      ],
    );
  }

  Widget _buildHouseCard(String title, String subtitle, String status, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isActive ? const LinearGradient(colors: [Color(0xFFFF8A65), Color(0xFFFFAB91)]) : null,
        color: isActive ? null : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isActive ? [BoxShadow(color: const Color(0x40FF8A65), blurRadius: 10, offset: const Offset(0, 4))] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: isActive ? Colors.white24 : Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
            child: Text(status, style: TextStyle(color: isActive ? Colors.white : Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isActive ? Colors.white : Colors.black87)),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: isActive ? Colors.white70 : Colors.black54)),
          const SizedBox(height: 24),
          if (isActive)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, 
                foregroundColor: const Color(0xFFFF8A65), 
                minimumSize: const Size(double.infinity, 48), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              child: const Text('입주 신청하기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            )
        ],
      ),
    );
  }
}
