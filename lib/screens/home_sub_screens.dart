import 'package:flutter/material.dart';
import 'profile_detail_screen.dart';

class LocalCoupleScreen extends StatelessWidget {
  const LocalCoupleScreen({super.key});
  
  @override Widget build(BuildContext context) => DefaultTabController(
    length: 3,
    child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('동네 인연 찾기', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: const TabBar(
          labelColor: Color(0xFFFF3B30),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFFFF3B30),
          indicatorWeight: 3,
          tabs: [
            Tab(text: '동네 친구'),
            Tab(text: '동네 소개팅'),
            Tab(text: '오늘의 번개'),
          ]
        )
      ),
      body: const TabBarView(
        physics: NeverScrollableScrollPhysics(), // swipe cards could conflict with tab view
        children: [
          _LocalFriendsTab(),
          _BlindDateTab(),
          _LightningMeetingTab(),
        ]
      )
    )
  );
}

// 1. 동네 친구 탭 (기존 GridView 방식 + 성별 표시)
class _LocalFriendsTab extends StatelessWidget {
  const _LocalFriendsTab();
  @override Widget build(BuildContext context) => GridView.builder(
    padding: const EdgeInsets.all(16), 
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 16, mainAxisSpacing: 16), 
    itemCount: 10, 
    itemBuilder: (ctx, i) => GestureDetector(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => ProfileDetailScreen(name: '위피친구 ', age: '25', region: '서울 강남구', imageUrl: 'https://picsum.photos/300/400?random=', intro: '친해져요!', mannerTemp: 36.5))), 
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0,5))]), 
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20), 
          child: Stack(
            fit: StackFit.expand, 
            children: [
              Image.network('https://picsum.photos/300/400?random=', fit: BoxFit.cover), 
              Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(0.8)], begin: Alignment.center, end: Alignment.bottomCenter))), 
              Positioned(
                top: 12, left: 12, 
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFF3B30), borderRadius: BorderRadius.circular(12)), child: const Text('1km 이내', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))
              ), 
              Positioned(
                bottom: 16, left: 16, right: 16, 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Row(children: [Text('위피친구 ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(width: 4), Icon(i%2==0 ? Icons.female : Icons.male, color: i%2==0 ? Colors.pinkAccent : Colors.blueAccent, size: 16)]), 
                    const SizedBox(height: 4), 
                    const Text('가볍게 커피 한잔 해요 ☕', style: TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)
                  ]
                )
              )
            ]
          )
        )
      )
    )
  ); 
}

// 2. 동네 소개팅 탭 (카드 스와이프 UI 느낌)
class _BlindDateTab extends StatelessWidget {
  const _BlindDateTab();
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        const Text('나와 딱 맞는 동네 인연을 만나보세요', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))]
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network('https://picsum.photos/500/700?random=199', fit: BoxFit.cover),
                  Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(0.9)], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
                  Positioned(
                    top: 20, left: 20,
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)), child: const Text('오늘의 추천', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
                  ),
                  Positioned(
                    bottom: 30, left: 20, right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('지연, 26', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                            const SizedBox(width: 8),
                            const Icon(Icons.verified, color: Colors.blue, size: 24)
                          ]
                        ),
                        const SizedBox(height: 8),
                        const Row(children: [Icon(Icons.location_on, color: Colors.white70, size: 16), SizedBox(width: 4), Text('서울 강남구 · 1.2km', style: TextStyle(color: Colors.white70, fontSize: 16))]),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: ['#맛집탐방', '#넷플릭스', '#댕댕이'].map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)), child: Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))).toList()
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _actionBtn(Icons.close, Colors.grey, Colors.white),
                            _actionBtn(Icons.favorite, const Color(0xFFFF3B30), Colors.white, size: 64),
                            _actionBtn(Icons.star, Colors.blueAccent, Colors.white),
                          ]
                        )
                      ]
                    )
                  )
                ]
              )
            )
          )
        )
      ]
    )
  );

  Widget _actionBtn(IconData icon, Color bg, Color iconColor, {double size = 56}) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: bg, boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))]),
    child: Icon(icon, color: iconColor, size: size * 0.5)
  );
}

// 3. 오늘의 번개 탭 (실시간 모임 피드)
class _LightningMeetingTab extends StatelessWidget {
  const _LightningMeetingTab();
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF1F3F5),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: (){}, 
      backgroundColor: const Color(0xFFFF3B30),
      icon: const Icon(Icons.flash_on, color: Colors.white),
      label: const Text('번개 열기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
    ),
    body: ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_,__) => const SizedBox(height: 12),
      itemBuilder: (_, i) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://picsum.photos/100?random=')), 
                const SizedBox(width: 12), 
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Text('동네주민 ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(4)), child: const Text('번개모집', style: TextStyle(color: Color(0xFFFF3B30), fontSize: 10, fontWeight: FontWeight.bold)))]), 
                  Text('방금 전 · 500m 이내', style: TextStyle(color: Colors.grey.shade500, fontSize: 12))
                ])), 
              ]
            ), 
            const SizedBox(height: 16), 
            Text(i == 0 ? '퇴근하고 맥주 한잔 하실 분 계신가요? 🍻' : '코인노래방 갈 사람 구해요!! (1/2)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), 
            const SizedBox(height: 8), 
            Row(children: [const Icon(Icons.location_on, color: Colors.grey, size: 14), const SizedBox(width: 4), Text(i == 0 ? '강남역 11번 출구 근처' : '신논현역 코노', style: const TextStyle(color: Colors.grey, fontSize: 13))]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF8F9FA), foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('참여하기'))
            )
          ]
        )
      )
    )
  );
}

class CommunityScreen extends StatelessWidget { const CommunityScreen({super.key}); @override Widget build(BuildContext context) => Scaffold(backgroundColor: const Color(0xFFF1F3F5), appBar: AppBar(title: const Text('동네 커뮤니티', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)), body: ListView.separated(padding: const EdgeInsets.symmetric(vertical: 16), itemCount: 5, separatorBuilder: (_,__) => const SizedBox(height: 12), itemBuilder: (_, i) => Container(color: Colors.white, padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://picsum.photos/100?random=')), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('주민 ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), Text('분 전 · 근처', style: TextStyle(color: Colors.grey.shade500, fontSize: 12))])), const Icon(Icons.more_vert, color: Colors.grey)]), const SizedBox(height: 16), const Text('이 동네에 맛집이 정말 많네요! 다들 어디를 제일 좋아하시나요?', style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)), const SizedBox(height: 16), ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network('https://picsum.photos/600/300?random=', width: double.infinity, height: 200, fit: BoxFit.cover)), const SizedBox(height: 16), Row(children: [const Icon(Icons.favorite_border, color: Colors.grey, size: 22), const SizedBox(width: 6), Text('', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)), const SizedBox(width: 20), const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 20), const SizedBox(width: 6), Text('', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))])])))); }