import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pc = PageController();
  int _p = 0;

  final List<List<dynamic>> _data = [
    ['취향 맞는 우리끼리', '매너온도와 취향 데이터를 기반으로\n나와 가장 잘 맞는 동행을 찾아요', Icons.favorite],
    ['무드있는 드라이브', '주말 드라이브, 맛집 투어 등\n자연스러운 만남(자만추)을 추구합니다', Icons.directions_car],
    ['우무(OOMU) 시작하기', '유류비와 톨게이트 비용은\n탑승자들과 1/N로 깔끔하게 정산해요', Icons.account_balance_wallet],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pc,
                onPageChanged: (i) => setState(() => _p = i),
                itemCount: _data.length,
                itemBuilder: (_, i) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_data[i][2] as IconData, size: 100, color: const Color(0xFFFF7A59)),
                    const SizedBox(height: 48),
                    Text(_data[i][0] as String, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text(_data[i][1] as String, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5)),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _data.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _p == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(color: _p == i ? const Color(0xFFFF7A59) : Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A59),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('우무 시작하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
