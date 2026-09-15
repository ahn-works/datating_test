import 'package:flutter/material.dart';
import 'soso_car_detail_screen.dart';
import 'soso_car_host_screen.dart';

class SosoCarHomeScreen extends StatefulWidget {
  const SosoCarHomeScreen({super.key});

  @override
  State<SosoCarHomeScreen> createState() => _SosoCarHomeScreenState();
}

class _SosoCarHomeScreenState extends State<SosoCarHomeScreen> {
  final Color oliveGreen = const Color(0xFFE2F0D9); // 배경 연한 그린
  final Color darkGreen = const Color(0xFF2E4F28);
  final Color terracotta = const Color(0xFFC04020);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.directions_car, color: Color(0xFF2E4F28)),
            const SizedBox(width: 8),
            const Text('소소카', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 20)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.yellow.withOpacity(0.3), borderRadius: BorderRadius.circular(4)), // 형광펜 하이라이트 느낌
              child: const Row(
                children: [
                  Text('마포구 연남동', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
                  Icon(Icons.keyboard_arrow_down, color: Colors.black87, size: 16),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black87), onPressed: (){}),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(radius: 16, backgroundColor: darkGreen, child: const Icon(Icons.directions_car, color: Colors.white, size: 16)),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 메인 배너
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF3E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFA5D6A7), borderRadius: BorderRadius.circular(12)),
                          child: const Text('🏠 마포 이웃 전용 소모임', style: TextStyle(color: Color(0xFF1B5E20), fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        const Text('연남동 이웃과 떠나는\n소소한 주말 로드트립', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, height: 1.3)),
                        const SizedBox(height: 8),
                        const Text('가까운 3~4명과 유류비 나누며 가볍게 훌쩍\n다녀와요.', style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4)),
                      ],
                    ),
                  ),
                  const Icon(Icons.wb_sunny, color: Color(0xFFC85A32), size: 48),
                ],
              ),
            ),

            // 2. 검색바 (하이라이트된 부분)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black87),
                    const SizedBox(width: 12),
                    Expanded(child: Text('어디로 떠날까요? (강화도, 헤이리, 바다)', style: TextStyle(color: Colors.grey.shade600, fontSize: 14))),
                    const Icon(Icons.tune, color: Colors.black87),
                  ],
                ),
              ),
            ),
            
            // 3. 필터 칩
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  _buildChip('전체', true),
                  _buildChip('당일치기 ☕', false),
                  _buildChip('노을 드라이브 🌅', false),
                  _buildChip('주말 🚗', false),
                ],
              ),
            ),

            // 4. 모임 리스트 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('이번 주말 출발 모집 🔴', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  Text('출발 임박순', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                ],
              ),
            ),

            // 5. 모임 카드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildImageTripCard(context),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SosoCarHostScreen())),
        backgroundColor: const Color(0xFFC04020),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('빠른 모임 생성', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2E4F28) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? const Color(0xFF2E4F28) : Colors.grey.shade300),
      ),
      child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
    );
  }

  Widget _buildImageTripCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SosoCarDetailScreen())),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 이미지 영역
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network('https://picsum.photos/600/300?random=20', height: 180, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 12, left: 12,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFB53D25), borderRadius: BorderRadius.circular(12)),
                        child: const Text('🔥 마감임박 1자리!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: const Text('토요일 당일', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 12, right: 12,
                  child: CircleAvatar(backgroundColor: Colors.white.withOpacity(0.8), radius: 16, child: const Icon(Icons.favorite_border, color: Colors.black54, size: 18)),
                ),
                Positioned(
                  bottom: 12, left: 12, right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(children: [Icon(Icons.location_on, color: Colors.white, size: 14), SizedBox(width: 4), Text('강화도 동막해변', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
                      const Text('편도 약 1시간 20분', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              ],
            ),
            // 하단 텍스트 영역
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('강화도 동막해변 일몰 보고 대하구이 먹...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildTag('#노을맛집'), _buildTag('#수다환영'), _buildTag('#플리공유'),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}
