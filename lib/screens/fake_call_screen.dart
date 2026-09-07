import 'package:flutter/material.dart';

class FakeCallScreen extends StatelessWidget {
  const FakeCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // 어두운 통화 화면 배경
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Column(
              children: [
                SizedBox(height: 40),
                Text('엄마', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w400)),
                SizedBox(height: 12),
                Text('휴대전화', style: TextStyle(color: Colors.white54, fontSize: 18)),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCallButton(Icons.alarm, '나중에 알림'),
                _buildCallButton(Icons.message, '메시지'),
              ],
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionCircle(Icons.call_end, Colors.red, '거절', context),
                _buildActionCircle(Icons.call, Colors.green, '응답', context),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Widget _buildActionCircle(IconData icon, Color color, String label, BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context), // 누르면 이전 화면으로 복귀
          child: Container(
            width: 75, height: 75,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }
}
