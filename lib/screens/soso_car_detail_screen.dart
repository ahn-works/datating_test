import 'package:flutter/material.dart';

class SosoCarDetailScreen extends StatelessWidget {
  const SosoCarDetailScreen({super.key});

  final Color oliveGreen = const Color(0xFF556B2F);
  final Color terracotta = const Color(0xFFE2725B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('여행 모임 상세', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          // 내 여행 관리 (My Trip Management)
          TextButton(
            onPressed: () {},
            child: Text('내 여행 관리', style: TextStyle(color: oliveGreen, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 헤더 (타이틀 및 비용)
            const Text('이번 주말 강화도 일몰 보고 조개구이 팟', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: oliveGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('예상 1인당 비용 (1/N 정산)', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('약 12,000원', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: oliveGreen)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. 여행 경로 및 일정 타임라인
            const Text('경로 및 일정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Column(
                children: [
                  _buildTimelineItem(time: '15:00', location: '마포구청역 2번 출구 (출발)', isLast: false, color: terracotta),
                  _buildTimelineItem(time: '16:30', location: '동막해변 (경유지/일몰)', isLast: false, color: Colors.grey.shade400),
                  _buildTimelineItem(time: '18:00', location: '강화도 조개구이 타운 (최종 목적지)', isLast: true, color: oliveGreen),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. 운전자 프로필 & 매너 평가
            const Text('운전자 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(radius: 24, backgroundColor: oliveGreen.withOpacity(0.2), child: Icon(Icons.person, color: oliveGreen, size: 28)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('달리는 민우', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Row(children: [
                              const Icon(Icons.thermostat, color: Colors.orange, size: 14),
                              const SizedBox(width: 4),
                              Text('매너온도 42.5°C', style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500)),
                            ]),
                          ],
                        ),
                      ),
                      // 운전자 매너 평가 버튼
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(side: BorderSide(color: terracotta), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        child: Text('매너 평가 보기', style: TextStyle(color: terracotta, fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
                  // 차량 정보
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCarInfo(Icons.directions_car, '현대 아이오닉5'),
                      _buildCarInfo(Icons.smoke_free, '비흡연 차량'),
                      _buildCarInfo(Icons.luggage, '짐 공간 넉넉'),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. 동행 참가자 목록
            const Text('참가자 (2/4석)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildParticipant(name: '민우 (호스트)', isHost: true),
                const SizedBox(width: 12),
                _buildParticipant(name: '지우', isHost: false),
                const SizedBox(width: 12),
                _buildEmptySeat(),
                const SizedBox(width: 12),
                _buildEmptySeat(),
              ],
            ),
            const SizedBox(height: 100), // FAB 공간 확보
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: terracotta,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
          ),
          child: const Text('참여 신청하기', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({required String time, required String location, required bool isLast, required Color color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            if (!isLast) Container(width: 2, height: 40, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(time, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(location, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        )
      ],
    );
  }

  Widget _buildCarInfo(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey.shade700),
        const SizedBox(height: 8),
        Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
      ],
    );
  }

  Widget _buildParticipant({required String name, required bool isHost}) {
    return Column(
      children: [
        CircleAvatar(radius: 24, backgroundColor: isHost ? oliveGreen.withOpacity(0.2) : Colors.grey.shade200, child: Icon(Icons.person, color: isHost ? oliveGreen : Colors.grey)),
        const SizedBox(height: 8),
        Text(name, style: TextStyle(fontSize: 12, fontWeight: isHost ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildEmptySeat() {
    return Column(
      children: [
        CircleAvatar(radius: 24, backgroundColor: Colors.grey.shade100, child: const Icon(Icons.add, color: Colors.grey)),
        const SizedBox(height: 8),
        const Text('빈 자리', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
