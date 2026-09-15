import 'package:flutter/material.dart';
import 'soso_car_detail_screen.dart';

class SosoCarHomeScreen extends StatefulWidget {
  const SosoCarHomeScreen({super.key});

  @override
  State<SosoCarHomeScreen> createState() => _SosoCarHomeScreenState();
}

class _SosoCarHomeScreenState extends State<SosoCarHomeScreen> {
  final Color oliveGreen = const Color(0xFF556B2F);
  final Color terracotta = const Color(0xFFE2725B);
  
  int _selectedFilter = 0;
  final List<String> _filters = ['전체', '당일치기', '1박 2일', '반려동물 동반', '여성 전용'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: const Text('동네 카풀 SosoCar', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.search, color: Colors.black87), onPressed: (){})],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 프로모션 배너 (감성 터치)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [oliveGreen, Color(0xFF3A4D1C)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: oliveGreen.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)), child: const Text('이번 주말 추천', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                        const SizedBox(height: 12),
                        const Text('마포구 이웃들과 떠나는\n가을 단풍 드라이브 🍁', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.4)),
                      ],
                    ),
                  ),
                  const Icon(Icons.map, color: Colors.white54, size: 48),
                ],
              ),
            ),

            // 2. 필터 영역 (스티키 느낌)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: List.generate(_filters.length, (index) {
                    final isSelected = _selectedFilter == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_filters[index], style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        selected: isSelected,
                        onSelected: (s) => setState(() => _selectedFilter = index),
                        selectedColor: oliveGreen,
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? oliveGreen : Colors.grey.shade200)),
                      ),
                    );
                  }),
                ),
              ),
            ),
            
            // 3. 실시간 급상승 핫플 드라이브 (가로 스크롤)
            const Padding(padding: EdgeInsets.fromLTRB(16, 24, 16, 12), child: Text('🔥 우리 동네 급상승 핫플', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildHotPlaceCard('양평 두물머리', '물안개 피는 아침', 'https://picsum.photos/300/200?random=11'),
                  _buildHotPlaceCard('파주 마장호수', '출렁다리 스릴', 'https://picsum.photos/300/200?random=12'),
                  _buildHotPlaceCard('인천 영종도', '바다 뷰 카페 투어', 'https://picsum.photos/300/200?random=13'),
                ],
              ),
            ),
            
            // 4. 안심 드라이버 추천 (가로 스크롤)
            const Padding(padding: EdgeInsets.fromLTRB(16, 32, 16, 12), child: Text('🛡️ 이번 주말, 믿고 타는 안심 드라이버', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildDriverCard('달리는 민우', '42.5°C', '아이오닉5', 1),
                  _buildDriverCard('베스트드라이버', '45.0°C', '쏘렌토', 2),
                  _buildDriverCard('조용한 힐링', '39.8°C', 'K5', 3),
                  _buildDriverCard('수다쟁이', '41.2°C', '아반떼', 4),
                ],
              ),
            ),

            // 5. 메인 모임 피드 (세로 리스트)
            const Padding(padding: EdgeInsets.fromLTRB(16, 32, 16, 12), child: Text('🚗 지금 모집 중인 동네 카풀', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildTripCard(context, title: '이번 주말 강화도 일몰 보고 조개구이 팟', destTags: ['#일몰 명소', '#바다뷰 카페'], driverName: '달리는 민우', mannerTemp: 42.5, seats: '2/4석', time: '이번 주 토요일 오후 3시', price: '약 12,000원'),
                  const SizedBox(height: 16),
                  _buildTripCard(context, title: '분당 율동공원 반려견 산책 힐링 드라이브', destTags: ['#힐링 숲', '#반려동물'], driverName: '댕댕이엄마', mannerTemp: 38.0, seats: '1/3석', time: '내일 오전 10시', price: '약 5,000원'),
                  const SizedBox(height: 16),
                  _buildTripCard(context, title: '가평 풀빌라 1박 2일 카풀 구해요 (여성만)', destTags: ['#1박2일', '#여성전용', '#호캉스'], driverName: '여행조아', mannerTemp: 44.1, seats: '1/4석', time: '이번 주 금요일 오후 6시', price: '약 15,000원'),
                  const SizedBox(height: 16),
                  _buildTripCard(context, title: '퇴근길 한강공원 피크닉 & 치맥 팟', destTags: ['#당일치기', '#퇴근길', '#한강'], driverName: '직장인A', mannerTemp: 36.5, seats: '3/4석', time: '오늘 저녁 7시', price: '약 3,000원'),
                ],
              ),
            ),
            const SizedBox(height: 100), // FAB 하단 여백
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: terracotta,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('빠른 모임 생성', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHotPlaceCard(String title, String sub, String imgUrl) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(0.8)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverCard(String name, String temp, String car, int id) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=')),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(temp, style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, {required String title, required List<String> destTags, required String driverName, required double mannerTemp, required String seats, required String time, required String price}) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SosoCarDetailScreen())),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: terracotta.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text('잔여 좌석 ', style: TextStyle(color: terracotta, fontWeight: FontWeight.bold, fontSize: 12))),
                Row(children: [const Icon(Icons.thermostat, color: Colors.orange, size: 14), Text('°C', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange))])
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.3)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: destTags.map((tag) => Text(tag, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))).toList(),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, thickness: 1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 14, backgroundColor: oliveGreen.withOpacity(0.2), child: Icon(Icons.person, color: oliveGreen, size: 16)),
                    const SizedBox(width: 8),
                    Text(driverName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
                Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
