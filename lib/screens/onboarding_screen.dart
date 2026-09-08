
import 'package:flutter/material.dart';
import 'auth_pass_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override State<OnboardingScreen> createState() => _OnboardingScreenState();
}
class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _page = 0;
  final _pages = [
    ['동네 친구와 여행을', '같은 동네에 사는 사람들과
1박 2일 여행 모임을 만들어보세요', Icons.travel_explore],
    ['안전한 만남', '실명 본인인증으로
안전하게 만나보세요', Icons.verified_user],
    ['여행 후 하트 시그널', '여행이 끝나면 많은 이성에게
하트를 전해보세요', Icons.favorite],
  ];
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(child: Column(children: [
      Expanded(child: PageView.builder(controller: _pc, onPageChanged: (i) => setState(() => _page = i), itemCount: _pages.length, itemBuilder: (_, i) => Padding(padding: const EdgeInsets.all(40), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 120, height: 120, decoration: BoxDecoration(color: const Color(0xFFFF3B30).withOpacity(0.1), shape: BoxShape.circle), child: Icon(_pages[i][2] as IconData, size: 60, color: const Color(0xFFFF3B30))),
        const SizedBox(height: 32),
        Text(_pages[i][0] as String, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Text(_pages[i][1] as String, style: const TextStyle(color: Colors.grey, height: 1.6), textAlign: TextAlign.center),
      ])))),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_pages.length, (i) => Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: _page == i ? 20 : 8, height: 8, decoration: BoxDecoration(color: _page == i ? const Color(0xFFFF3B30) : Colors.grey.shade300, borderRadius: BorderRadius.circular(4))))),
      const SizedBox(height: 24),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), child: ElevatedButton(
        onPressed: () { if (_page < _pages.length - 1) { _pc.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease); } else { Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthPassScreen())); } },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.black, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: Text(_page < _pages.length - 1 ? '다음' : '시작하기', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      )),
    ])),
  );
}
