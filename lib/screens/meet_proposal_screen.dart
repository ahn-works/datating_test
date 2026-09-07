import 'package:flutter/material.dart';
import 'middle_spot_map_screen.dart';

class MeetProposalScreen extends StatelessWidget {
  const MeetProposalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, // 반투명 배경 효과 (모달 느낌)
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite, color: Color(0xFFFF8A65), size: 60),
              const SizedBox(height: 24),
              const Text('오프라인 만남 제안하기', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('10분 대화가 즐거우셨나요?\n상대방에게 오프라인 만남을 제안해보세요.\n상대방이 수락하면 중간지점을 탐색합니다.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, height: 1.5)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MiddleSpotMapScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A65), 
                  minimumSize: const Size(double.infinity, 50), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                ),
                child: const Text('용기 내서 제안하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('조금 더 대화할래요', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
