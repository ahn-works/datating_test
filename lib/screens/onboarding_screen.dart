import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget { const OnboardingScreen({super.key}); @override State<OnboardingScreen> createState() => _OnboardingScreenState(); }
class _OnboardingScreenState extends State<OnboardingScreen> {
  int _p = 0; 
  final PageController _pc = PageController();
  Timer? _timer;
  final _data = [['동네 친구', '내 주변에 있는\n새로운 인연을 찾아봐요', Icons.people], ['동행 여행', '함께 갈 여행 친구를\n구하고 떠나세요', Icons.travel_explore], ['하트 시그널', '마음에 드는 이성에게\n하트 시그널을 표현하세요', Icons.favorite]];
  
  @override void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_p < _data.length - 1) {
        _p++;
      } else {
        _p = 0;
      }
      _pc.animateToPage(_p, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override void dispose() {
    _timer?.cancel();
    _pc.dispose();
    super.dispose();
  }

  @override Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.white, body: SafeArea(child: Column(children: [Expanded(child: PageView.builder(controller: _pc, onPageChanged: (i) => setState(() => _p = i), itemCount: _data.length, itemBuilder: (_, i) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(_data[i][2] as IconData, size: 100, color: const Color(0xFFFF3B30)), const SizedBox(height: 48), Text(_data[i][0] as String, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 16), Text(_data[i][1] as String, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5))]))), Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_data.length, (i) => AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4), width: _p == i ? 24 : 8, height: 8, decoration: BoxDecoration(color: _p == i ? const Color(0xFFFF3B30) : Colors.grey.shade300, borderRadius: BorderRadius.circular(4))))), const SizedBox(height: 48), Padding(padding: const EdgeInsets.all(24), child: ElevatedButton(onPressed: () { _timer?.cancel(); Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('위피 시작하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))))])));
}
