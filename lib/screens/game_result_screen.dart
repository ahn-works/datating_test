import 'package:flutter/material.dart';

class GameResultScreen extends StatelessWidget {
  const GameResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            const Text('성향 일치율 85%!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFF8A65))),
            const SizedBox(height: 12),
            const Text('두 분은 가치관이 아주 잘 맞네요.\n지금 바로 매칭을 신청해볼까요?', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5)),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A65), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('매칭 신청하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
