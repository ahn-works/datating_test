import 'package:flutter/material.dart';
import '../main.dart'; 

class VoicePingScreen extends StatelessWidget {
  const VoicePingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('나의 매력을 보여주는\nVoice Ping 녹음 🎤', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.4)),
            const SizedBox(height: 16),
            const Text('10초 남짓 짧은 목소리로\n나를 표현할 수 있는 인삿말을 남겨보세요.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5)),
            const Spacer(),
            Container(
              height: 120, width: double.infinity,
              decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(20)),
              child: const Center(child: Text('여기에 음성 파형(Visualizer) 애니메이션이 들어갑니다', style: TextStyle(color: Colors.grey))),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(color: Color(0xFFFF8A65), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x40FF8A65), blurRadius: 15, offset: Offset(0, 5))]),
                child: const Icon(Icons.mic, color: Colors.white, size: 40),
              ),
            ),
            const SizedBox(height: 16),
            const Text('버튼을 누르고 말하세요', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainNavigation()), (route) => false),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black87, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('녹음 완료하고 스팟10 시작하기', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainNavigation()), (route) => false),
              child: const Text('나중에 할게요', style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
