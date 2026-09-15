import 'package:flutter/material.dart';
import 'soso_car_host_screen.dart';
import 'soso_car_chat_screen.dart';

class SosoCarDetailScreen extends StatelessWidget {
  const SosoCarDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F7),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              TextButton(
                onPressed: () {},
                child: const Text('내 여행 관리', style: TextStyle(color: Color(0xFF2E4F28), fontWeight: FontWeight.bold)),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network('https://picsum.photos/600/400?random=20', fit: BoxFit.cover),
                  Container(color: Colors.black.withOpacity(0.3)),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFB53D25), borderRadius: BorderRadius.circular(12)),
                          child: const Text('🔥 마감임박 1자리!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        const Text('토요일 당일', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('강화도 동막해변 일몰 보고 대하구이 먹...', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.3)),
                    const SizedBox(height: 24),
                    
                    // 예상 비용 패널
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('예상 1인당 비용', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              SizedBox(height: 4),
                              Text('유류비+톨비 1/N 정산', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                          Text('약 12,000원', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFFC04020))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 운전자 프로필 및 매너 평가
                    const Text('운전자 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(radius: 24, backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=11')),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('달리는 민우', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      const Icon(Icons.thermostat, color: Colors.orange, size: 14),
                                      Text('매너온도 42.5°C', style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500)),
                                    ]),
                                  ],
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFC04020)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                                child: const Text('매너 평가 보기', style: TextStyle(color: Color(0xFFC04020), fontSize: 12, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildCarInfo(Icons.directions_car, '현대 싼타페'),
                              _buildCarInfo(Icons.smoke_free, '비흡연 차량'),
                              _buildCarInfo(Icons.luggage, '짐 공간 넉넉'),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 여행 경로
                    const Text('경로 및 일정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                      child: Column(
                        children: [
                          _buildTimelineItem(time: '15:00', location: '마포구청역 2번 출구 (출발)', isLast: false, color: const Color(0xFFC04020)),
                          _buildTimelineItem(time: '16:30', location: '동막해변 (경유지/일몰)', isLast: false, color: Colors.grey.shade400),
                          _buildTimelineItem(time: '18:00', location: '강화도 대하구이 (최종 목적지)', isLast: true, color: const Color(0xFF2E4F28)),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 120), // 하단 버튼 여백
                  ],
                ),
              )
            ]),
          )
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SosoCarChatScreen())),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E4F28), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('동행 채팅방 입장', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC04020), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('참여 신청하기', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
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
}
