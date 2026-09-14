import 'package:flutter/material.dart';
import 'profile_detail_screen.dart';
import 'natural_meeting_detail_screens.dart';

class LocalCoupleScreen extends StatelessWidget {
  const LocalCoupleScreen({super.key});
  
  @override Widget build(BuildContext context) => DefaultTabController(
    length: 4,
    child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('자연스러운 만남', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: const TabBar(
          isScrollable: true,
          labelColor: Color(0xFFFF3B30),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFFFF3B30),
          indicatorWeight: 3,
          labelPadding: EdgeInsets.symmetric(horizontal: 20),
          tabs: [
            Tab(text: '🐶 산책 메이트'),
            Tab(text: '🍱 밥친구·카공'),
            Tab(text: '🏃‍♂️ 동네 크루'),
            Tab(text: '⚡ 오늘의 번개'),
          ]
        )
      ),
      body: const TabBarView(
        children: [
          _PetWalkingTab(),
          _MealFriendTab(),
          _ActivityCrewTab(),
          _LightningMeetingTab(),
        ]
      )
    )
  );
}

// 1. 산책 메이트 (반려동물 매칭)
class _PetWalkingTab extends StatelessWidget {
  const _PetWalkingTab();
  @override Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: 4,
    separatorBuilder: (_,__) => const SizedBox(height: 12),
    itemBuilder: (_, i) => GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileDetailScreen(name: '보리네', age: '28', region: '서울 송파구', imageUrl: 'https://picsum.photos/120/120?random=', intro: '강아지 산책 같이 해요!', mannerTemp: 37.5))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network('https://picsum.photos/120/120?random=', width: 80, height: 80, fit: BoxFit.cover)),
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)), child: const Text('강아지 산책', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold))), const SizedBox(width: 8), Text('보리네 (km)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))]),
                const SizedBox(height: 8),
                const Text('올림픽공원 같이 산책하실 댕댕이 찾아요! 저희 애는 골든리트리버예요 🦮', style: TextStyle(fontSize: 13, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
              ]
            )),
            const SizedBox(width: 8),
            const Icon(Icons.favorite_border, color: Colors.grey)
          ]
        )
      )
    )
  ); 
}

// 2. 밥친구 / 카공 (일상 공유)
class _MealFriendTab extends StatelessWidget {
  const _MealFriendTab();
  @override Widget build(BuildContext context) => GridView.builder(
    padding: const EdgeInsets.all(16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.8, crossAxisSpacing: 12, mainAxisSpacing: 12),
    itemCount: 6,
    itemBuilder: (ctx, i) => GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MealDetailScreen(title: i%2==0 ? '하남돼지집 3명 모여요' : '스벅 조용히 각자 할일'))),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: Stack(fit: StackFit.expand, children: [Image.network('https://picsum.photos/200/200?random=', fit: BoxFit.cover), Positioned(bottom: 8, left: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)), child: Text(i%2==0 ? '고기팟 🥩' : '카페 카공 ☕', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))))]))),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(i%2==0 ? '하남돼지집 3명 모여요' : '스벅 조용히 각자 할일', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
                  const SizedBox(height: 4),
                  Row(children: [Icon(Icons.person, size: 12, color: Colors.grey.shade500), const SizedBox(width: 4), Text('1/4명 참여중', style: TextStyle(color: Colors.grey.shade500, fontSize: 11))])
                ]
              )
            )
          ]
        )
      )
    )
  );
}

// 3. 동네 크루 (액티비티)
class _ActivityCrewTab extends StatelessWidget {
  const _ActivityCrewTab();
  @override Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: 4,
    separatorBuilder: (_,__) => const SizedBox(height: 12),
    itemBuilder: (_, i) => GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CrewDetailScreen(title: i%2==0 ? '한강 나이트 러닝 크루 🏃‍♂️' : '배드민턴 초보 모임 🏸'))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          children: [
            Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle), child: Icon(i%2==0 ? Icons.directions_run : Icons.sports_tennis, color: Colors.blue, size: 30)),
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(i%2==0 ? '한강 나이트 러닝 크루 🏃‍♂️' : '배드민턴 초보 모임 🏸', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(i%2==0 ? '매주 수요일 저녁 8시 반포대교' : '주말 오전 동네 체육관', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ]
            )),
            ElevatedButton(onPressed: (){ Navigator.push(context, MaterialPageRoute(builder: (_) => CrewDetailScreen(title: i%2==0 ? '한강 나이트 러닝 크루 🏃‍♂️' : '배드민턴 초보 모임 🏸'))); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('가입', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
          ]
        )
      )
    )
  );
}

// 4. 오늘의 번개 탭 (실시간 모임 피드)
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
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LightningDetailScreen(title: i == 0 ? '퇴근하고 맥주 한잔 하실 분 계신가요? 🍻' : '코인노래방 갈 사람 구해요!! (1/2)'))),
        child: Container(
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
                child: ElevatedButton(onPressed: (){ Navigator.push(context, MaterialPageRoute(builder: (_) => LightningDetailScreen(title: i == 0 ? '퇴근하고 맥주 한잔 하실 분 계신가요? 🍻' : '코인노래방 갈 사람 구해요!! (1/2)'))); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF8F9FA), foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('참여하기'))
              )
            ]
          )
        )
      )
    )
  );
}

class CommunityScreen extends StatelessWidget { const CommunityScreen({super.key}); @override Widget build(BuildContext context) => Scaffold(backgroundColor: const Color(0xFFF1F3F5), appBar: AppBar(title: const Text('동네 커뮤니티', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)), body: ListView.separated(padding: const EdgeInsets.symmetric(vertical: 16), itemCount: 5, separatorBuilder: (_,__) => const SizedBox(height: 12), itemBuilder: (_, i) => Container(color: Colors.white, padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://picsum.photos/100?random=')), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('주민 ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), Text('분 전 · 근처', style: TextStyle(color: Colors.grey.shade500, fontSize: 12))])), const Icon(Icons.more_vert, color: Colors.grey)]), const SizedBox(height: 16), const Text('이 동네에 맛집이 정말 많네요! 다들 어디를 제일 좋아하시나요?', style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)), const SizedBox(height: 16), ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network('https://picsum.photos/600/300?random=', width: double.infinity, height: 200, fit: BoxFit.cover)), const SizedBox(height: 16), Row(children: [const Icon(Icons.favorite_border, color: Colors.grey, size: 22), const SizedBox(width: 6), Text('', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)), const SizedBox(width: 20), const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 20), const SizedBox(width: 6), Text('', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))])])))); }