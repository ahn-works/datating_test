import 'package:flutter/material.dart';

class NeighborhoodCrewScreen extends StatelessWidget {
  const NeighborhoodCrewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F3F5),
        appBar: AppBar(
          title: const Text('Regular Crew', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
            IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ],
          bottom: const TabBar(
            labelColor: Color(0xFF2E7D32),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF2E7D32),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: '함께한 크루 3'),
              Tab(text: '찜한 드라이버 4'),
              Tab(text: '나의 뱃지함 5'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _CrewTab(),
            _DriverTab(),
            _BadgeTab(),
          ]
        ),
      ),
    );
  }
}

class _CrewTab extends StatelessWidget {
  const _CrewTab();
  @override Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [Icon(Icons.favorite_border, color: Color(0xFF2E7D32), size: 16), SizedBox(width: 8), Text('MEMORABLE COMPANION', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 12))]),
            const SizedBox(height: 12),
            Text('지난 주말 강화도 동행이 벌써\n그립다면?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.4)),
            const SizedBox(height: 8),
            Text('취향이 잘 맞았던 이웃들과 번거로운 신청·승인\n절차 없이 다음 일정을 원클릭으로 가볍게\n시작해보세요. 🌿', style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.5)),
          ]
        )
      ),
      const SizedBox(height: 32),
      const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [Icon(Icons.people_alt, color: Colors.black87), SizedBox(width: 8), Text('검증된 우리 동네 단골 크루', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
        Text('총 3개 그룹', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))
      ]),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)), child: const Text('만족도 100%', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold))),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)), child: const Text('환상의 케미 🧡', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold))),
              const Spacer(),
              const Icon(Icons.more_horiz, color: Colors.grey)
            ]),
            const SizedBox(height: 12),
            const Text('강화도 동막해변 1기 크루 🌅', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('최근 동행: 2024. 10. 26 (토)', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)), const Text('4명 완주', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13))]),
            const SizedBox(height: 16),
            GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 2.5, mainAxisSpacing: 12, crossAxisSpacing: 12, children: [
              _memberItem('https://picsum.photos/100?random=1', '호스트 민우', '안전매너 100점 🛡️'),
              _memberItem('https://picsum.photos/100?random=2', '지우', '감성 선곡 DJ 🎵'),
              _memberItem('https://picsum.photos/100?random=3', '서연', '간식 요정 🥐'),
              _memberItem('https://picsum.photos/100?random=4', '나', '시간약속 완료 ⏰'),
            ]),
            const SizedBox(height: 20),
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(16)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.format_quote, color: Colors.grey, size: 20), const SizedBox(width: 8), Expanded(child: Text('"갑자기 비바람 칠 때 다 함께 온실 북카페로 피신했던 전설의 강화 드라이브! 다음엔 일몰 맛집으로 가요 ☕"', style: TextStyle(color: Colors.grey.shade800, fontSize: 13, height: 1.5)))])),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: (){}, icon: const Icon(Icons.send, color: Colors.white, size: 18), label: const Text('이 멤버로 다음 여행 또 가기 (초대 전송)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14422D), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ElevatedButton.icon(onPressed: (){}, icon: const Icon(Icons.chat_bubble_outline, color: Colors.black87, size: 16), label: const Text('크루 전용 채팅방', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300))))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(onPressed: (){}, icon: const Icon(Icons.photo_library_outlined, color: Colors.black87, size: 16), label: const Text('동행 앨범 (14)', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300))))),
            ])
          ]
        )
      )
    ]
  );
  
  Widget _memberItem(String img, String name, String sub) => Row(children: [CircleAvatar(backgroundImage: NetworkImage(img), radius: 18), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)]))]);
}

class _DriverTab extends StatelessWidget { const _DriverTab(); @override Widget build(BuildContext context) => const Center(child: Text('찜한 안심 드라이버 목록')); }
class _BadgeTab extends StatelessWidget { const _BadgeTab(); @override Widget build(BuildContext context) => const Center(child: Text('소소한 동행 뱃지 컬렉션')); }
