import 'package:flutter/material.dart';
import 'profile_detail_screen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white, appBar: AppBar(title: const Text('위피 버디', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)), backgroundColor: Colors.white, elevation: 0, actions: [ IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black), onPressed: () {}) ]),
    body: ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFFFF3B30), borderRadius: BorderRadius.circular(20)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('오늘의 동네 친구를 찾아보세요!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), SizedBox(height: 8), Text('나와 가까운 친구들과 모임까지 한 번에!', style: TextStyle(color: Colors.white70, fontSize: 14))]))),
        const SizedBox(height: 32),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('오늘의 추천 친구', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        const SizedBox(height: 16),
        SizedBox(height: 220, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [ _userCard(context, '지은', '광주 · 24세', 'https://picsum.photos/200/300?random=1'), _userCard(context, '수현', '광주 · 27세', 'https://picsum.photos/200/300?random=2'), _userCard(context, '민호', '목포 · 26세', 'https://picsum.photos/200/300?random=3') ])),
        const SizedBox(height: 32),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('서비스 둘러보기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        const SizedBox(height: 16),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(children: [ _featureCard(Icons.travel_explore, '여행 모집', '지역기반 여행 모임 만들기', const Color(0xFFFF3B30)), const SizedBox(height: 12), _featureCard(Icons.people, '동네 커플', '남성/여성 성비 확인 후 참여', Colors.blue), const SizedBox(height: 12), _featureCard(Icons.task_alt, '미션 & 하트시그널', '현장 인증 미션과 최종 선택', Colors.orange) ])),
      ],
    ),
  );
  Widget _userCard(BuildContext ctx, String name, String sub, String img) => GestureDetector(onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => ProfileDetailScreen(name: name, age: '24', region: '광주', imageUrl: '', intro: '반가워요!', mannerTemp: 36.5))), child: Container(width: 140, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover)), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(0.8)], begin: Alignment.topCenter, end: Alignment.bottomCenter)), child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 12))]))));
  Widget _featureCard(IconData icon, String title, String sub, Color color) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]), child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text(sub, style: TextStyle(fontSize: 13, color: Colors.grey.shade600))])), Icon(Icons.chevron_right, color: Colors.grey.shade400)]));
}
