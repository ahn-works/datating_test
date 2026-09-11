import 'package:flutter/material.dart';
import 'signal_house_list_screen.dart';

class SignalHouseIntroScreen extends StatelessWidget {
  const SignalHouseIntroScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    body: Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)], begin: Alignment.topCenter, end: Alignment.bottomCenter)
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFFF3B30).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.favorite, color: Color(0xFFFF3B30), size: 48)),
              const SizedBox(height: 32),
              const Text('시그널 하우스', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1)),
              const SizedBox(height: 16),
              const Text('당신의 마음이 향하는 곳은 어디인가요?\n\n시그널 하우스에서는 매일 밤 10시,\n단 한 사람에게 익명으로 마음을 전할 수 있습니다.\n\n여행 중 숨겨진 단서를 찾고, 미션을 수행하며\n진짜 인연을 찾아보세요.', style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.6, fontWeight: FontWeight.w500)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
                child: const Row(children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber), SizedBox(width: 12),
                  Expanded(child: Text('안내: 한 번 입장하면 모임이 끝날 때까지 퇴장할 수 없습니다.', style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4)))
                ]),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignalHouseListScreen())),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30), minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                child: const Text('수락하고 입장하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))
              ),
              const SizedBox(height: 16),
              TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 60)), child: const Text('다음에 할게요', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 16)))
            ]
          )
        )
      )
    )
  );
}
