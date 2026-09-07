import 'package:flutter/material.dart';

class TravelRoomScreen extends StatefulWidget {
  const TravelRoomScreen({super.key});
  @override
  State<TravelRoomScreen> createState() => _TravelRoomScreenState();
}

class _TravelRoomScreenState extends State<TravelRoomScreen> {
  int _step = 0;
  final List<String> _steps = ['투표', '단톡방', '미션', '최종선택'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('[목포] 당일치기 모임', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(_steps.length, (i) {
            final active = i == _step, passed = i < _step;
            return GestureDetector(onTap: () => setState(() => _step = i), child: Column(children: [
              Icon(passed ? Icons.check_circle : Icons.circle, color: active || passed ? const Color(0xFFFF3B30) : Colors.grey.shade300, size: 20),
              const SizedBox(height: 4),
              Text(_steps[i], style: TextStyle(fontSize: 12, fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? Colors.black : Colors.grey)),
            ]));
          })),
        ),
        Expanded(child: _step == 0 ? _voting() : _step == 2 ? _mission() : _step == 3 ? _finalChoice() : const Center(child: Text('단톡방은 하단 버튼을 눌러 입장하세요.', style: TextStyle(color: Colors.grey)))),
        SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: const Text('대화방 입장하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ))),
      ]),
    );
  }

  Widget _voting() => ListView(padding: const EdgeInsets.all(24), children: [
    const Text('함께 갈 목포 맛집을 투표해주세요!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.5)),
    const SizedBox(height: 24),
    _voteCard('A: 낙지탕탕이', 0.65, '5명'),
    const SizedBox(height: 16),
    _voteCard('B: 게살비빔밥 노포', 0.25, '2명'),
  ]);

  Widget _voteCard(String t, double p, String v) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.restaurant, color: Color(0xFFFF3B30)), const SizedBox(width: 8), Expanded(child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)))]),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: LinearProgressIndicator(value: p, backgroundColor: Colors.grey.shade200, color: const Color(0xFFFF3B30), minHeight: 10, borderRadius: BorderRadius.circular(5))), const SizedBox(width: 12), Text((p*100).toInt().toString() + '% (' + v + ')', style: const TextStyle(fontWeight: FontWeight.bold))]),
    ]),
  );

  Widget _mission() => ListView(padding: const EdgeInsets.all(24), children: [
    const Text('현장 미션 스탬프 투어!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    const SizedBox(height: 24),
    Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)), child: Column(children: [
      const Text('팀원 전체 인증샷 찍기!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.5), textAlign: TextAlign.center),
      const SizedBox(height: 8),
      const Text('성공 보상: 매너 온도 +1.5도', style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.camera_alt, color: Colors.white), label: const Text('인증샷 업로드', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
    ])),
  ]);

  Widget _finalChoice() => ListView(padding: const EdgeInsets.all(24), children: [
    const Center(child: Text('최종 하트시그널 마감 [ 14:59 ]', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF3B30)))),
    const SizedBox(height: 16),
    const Text('오늘 여행에서 가장 설렉던 이성을 1명만 선택해 주세요.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, height: 1.5)),
    const SizedBox(height: 32),
    _choiceCard('지은', '26세', false),
    const SizedBox(height: 12),
    _choiceCard('민서', '27세', true),
  ]);

  Widget _choiceCard(String n, String info, bool sel) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(border: Border.all(color: sel ? const Color(0xFFFF3B30) : Colors.grey.shade300, width: sel ? 2 : 1), borderRadius: BorderRadius.circular(12), color: sel ? const Color(0xFFFFF5F5) : Colors.white),
    child: Row(children: [
      CircleAvatar(backgroundColor: Colors.grey.shade300, radius: 24, child: const Icon(Icons.person, color: Colors.white)),
      const SizedBox(width: 16),
      Expanded(child: Text(n + ' (' + info + ')', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
      Icon(sel ? Icons.favorite : Icons.favorite_border, color: sel ? const Color(0xFFFF3B30) : Colors.grey),
    ]),
  );
}
