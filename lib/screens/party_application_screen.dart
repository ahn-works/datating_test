import 'package:flutter/material.dart';
import 'travel_payment_screen.dart';

class PartyApplicationScreen extends StatefulWidget { const PartyApplicationScreen({super.key}); @override State<PartyApplicationScreen> createState() => _PartyApplicationScreenState(); }
class _PartyApplicationScreenState extends State<PartyApplicationScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0; final int _totalQuestions = 10;
  final Map<int, String> _answers = {};

  final List<Map<String, dynamic>> _q = [
    {'type': 'choice', 'q': '1. 남녀 사이에 순수한 친구가 존재할 수 있나요?', 'opt': ['네, 당연히 가능하죠!', '아니요, 절대 불가능해요']},
    {'type': 'choice', 'q': '2. 이른바 깻잎 논쟁! 내 애인이 내 절친의 깻잎을 떼어준다면?', 'opt': ['매너니까 전혀 상관없다', '절대 용납 못한다']},
    {'type': 'choice', 'q': '3. 연인 혹은 썸남썸녀와의 이상적인 연락 빈도는?', 'opt': ['틈나는 대로 계속 연락하는 편', '각자의 시간은 존중하는 편']},
    {'type': 'choice', 'q': '4. 선호하는 여행 스타일은 어느 쪽인가요?', 'opt': ['발길 닿는 대로! 즉흥(P) 여행', '시간표까지 완벽하게! 계획(J) 여행']},
    {'type': 'choice', 'q': '5. 여행 중 의견 충돌이나 갈등이 생겼을 때 나는?', 'opt': ['그 자리에서 대화로 바로 푼다', '감정을 식힐 혼자만의 시간이 필요하다']},
    {'type': 'choice', 'q': '6. 모임에서의 술자리 선호도는?', 'opt': ['술은 빠질 수 없죠! 즐기는 편', '술 없이도 분위기만 잘 맞춰요', '아예 마시지 않습니다']},
    {'type': 'choice', 'q': '7. 소비를 할 때 나의 가치관에 더 가까운 것은?', 'opt': ['비싸도 퀄리티지! 가심비 럭셔리', '합리적인 게 최고! 가성비 실속형']},
    {'type': 'choice', 'q': '8. 새로운 사람을 만났을 때 나의 낯가림 정도는?', 'opt': ['먼저 다가가는 인싸 스타일', '친해지기까지 시간이 꽤 필요한 편']},
    {'type': 'text', 'q': '9. 사람을 만날 때 가장 중요하게 생각하는 가치관이나 성격은 무엇인가요?'},
    {'type': 'text', 'q': '10. 마지막으로, 이번 모임에서 가장 기대하는 점을 자유롭게 적어주세요!'},
  ];

  void _next() {
    if (_currentIndex < _totalQuestions - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.fastOutSlowIn);
      setState(() => _currentIndex++);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TravelPaymentScreen()));
    }
  }

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black), title: ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: (_currentIndex + 1) / _totalQuestions, backgroundColor: Colors.grey.shade100, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF3B30)), minHeight: 6))),
    body: SafeArea(
      child: PageView.builder(
        controller: _pageController, physics: const NeverScrollableScrollPhysics(), itemCount: _totalQuestions,
        itemBuilder: (ctx, i) {
          final q = _q[i];
          return Padding(padding: const EdgeInsets.all(32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 20),
            Text(q['q'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.4, letterSpacing: -0.5)),
            const SizedBox(height: 40),
            if (q['type'] == 'choice') ...[
              ...(q['opt'] as List<String>).map((opt) {
                bool sel = _answers[i] == opt;
                return Padding(padding: const EdgeInsets.only(bottom: 16), child: InkWell(onTap: () { setState(() => _answers[i] = opt); Future.delayed(const Duration(milliseconds: 250), _next); }, borderRadius: BorderRadius.circular(20), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24), width: double.infinity, decoration: BoxDecoration(color: sel ? const Color(0xFFFF3B30).withOpacity(0.05) : Colors.white, border: Border.all(color: sel ? const Color(0xFFFF3B30) : Colors.grey.shade200, width: 2), borderRadius: BorderRadius.circular(20), boxShadow: sel ? [BoxShadow(color: const Color(0xFFFF3B30).withOpacity(0.1), blurRadius: 10, offset: const Offset(0,4))] : []), child: Text(opt, style: TextStyle(fontSize: 17, fontWeight: sel ? FontWeight.bold : FontWeight.w600, color: sel ? const Color(0xFFFF3B30) : Colors.black87)))));
              }).toList()
            ] else ...[
              Expanded(child: TextField(autofocus: true, maxLines: null, onChanged: (v) => setState(() => _answers[i] = v), style: const TextStyle(fontSize: 18, height: 1.5), decoration: InputDecoration(hintText: '자유롭게 작성해주세요...', hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 18), filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(24)))),
              const SizedBox(height: 24),
              AnimatedOpacity(
                opacity: (_answers[i] ?? '').trim().isNotEmpty ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(onPressed: (_answers[i] ?? '').trim().isNotEmpty ? _next : null, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30), disabledBackgroundColor: const Color(0xFFFF3B30), minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0), child: Text(i == _totalQuestions - 1 ? '제출 및 결제하기' : '다음', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
              ),
              const SizedBox(height: 16),
            ]
          ]));
        },
      ),
    ),
  );
}
