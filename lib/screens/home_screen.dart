import 'package:flutter/material.dart';
import 'dart:async';
import 'profile_detail_screen.dart';

class HomeScreen extends StatefulWidget { const HomeScreen({super.key}); @override State<HomeScreen> createState() => _HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> {
  final PageController _pc = PageController();
  int _p = 0;
  Timer? _t;
  final _banners = [
    {'title': '오늘의 여행 친구를 찾아보세요', 'sub': '동네 친구들과 지역 여행을 함께!'},
    {'title': '새로운 동네 커플의 탄생', 'sub': '나와 잘 맞는 동네 인연을 만나보세요'},
    {'title': '심쿵 하트 시그널', 'sub': '마음에 드는 이성에게 마음을 표현하세요'}
  ];

  @override void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() { _p = (_p + 1) % _banners.length; });
      _pc.animateToPage(_p, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
    });
  }
  @override void dispose() { _t?.cancel(); _pc.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('위피 버디', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)), backgroundColor: Colors.white, elevation: 0, actions: [IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black), onPressed: () {})]),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SizedBox(
            height: 120,
            child: PageView.builder(
              controller: _pc,
              onPageChanged: (i) => setState(() => _p = i),
              itemCount: _banners.length,
              itemBuilder: (ctx, i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFFFF3B30), borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_banners[i]['title']!, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_banners[i]['sub']!, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_banners.length, (i) => AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4), width: _p == i ? 20 : 8, height: 8, decoration: BoxDecoration(color: _p == i ? const Color(0xFFFF3B30) : Colors.grey.shade300, borderRadius: BorderRadius.circular(4)))),
          ),
          const SizedBox(height: 24),
          const Text('추천 사용자', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(height: 240, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: 5, itemBuilder: (ctx, i) => _userCard(ctx, '위피멤버 ', '서울 강남구', 'https://picsum.photos/200/300?random='))),
          const SizedBox(height: 32),
          const Text('주요 기능', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _featureCard(Icons.travel_explore, '여행 모집', '지역 기반 여행 모임 만들기', const Color(0xFFFF3B30)), const SizedBox(height: 12),
          _featureCard(Icons.people, '동네 커플', '남성/여성 성비 확인 후 참여', Colors.blue), const SizedBox(height: 12),
          _featureCard(Icons.task_alt, '미션 & 하트시그널', '현장 인증 미션 및 최종 선택', Colors.orange)
        ]
      )
    );
  }

  Widget _userCard(BuildContext ctx, String name, String sub, String img) => GestureDetector(onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => ProfileDetailScreen(name: name, age: '24', region: '서울', imageUrl: '', intro: '안녕하세요!', mannerTemp: 36.5))), child: Container(width: 160, margin: const EdgeInsets.only(right: 16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover)), child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(0.8)], begin: Alignment.topCenter, end: Alignment.bottomCenter)), padding: const EdgeInsets.all(16), child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(height: 4), Row(children: [const Icon(Icons.location_on, color: Colors.white70, size: 12), const SizedBox(width: 4), Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500))])]))));

  Widget _featureCard(IconData icon, String title, String sub, Color color) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]), child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(sub, style: TextStyle(color: Colors.grey.shade600, fontSize: 14))])), const Icon(Icons.chevron_right, color: Colors.grey)]));
}
