import 'package:flutter/material.dart';
import 'game_screen.dart';

class BalanceGameLobbyScreen extends StatelessWidget {
  const BalanceGameLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFF8A65), Color(0xFFFFAB91)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(Icons.gamepad, size: 80, color: Colors.white),
              const SizedBox(height: 24),
              const Text('가치관 밸런스 게임', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('상대방과 나의 성향이 얼마나 잘 맞을까요?\n게임을 통해 확인해보세요!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const GameScreen())),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFFF8A65), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('게임 시작하기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
