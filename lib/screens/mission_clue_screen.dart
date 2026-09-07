import 'package:flutter/material.dart';

class MissionClueScreen extends StatelessWidget {
  const MissionClueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(title: const Text('오늘의 단서', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('누군가 당신에게 단서를 남겼습니다 💌', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
              child: const Column(
                children: [
                  Icon(Icons.search, size: 48, color: Color(0xFFFF8A65)),
                  SizedBox(height: 16),
                  Text('"주말에는 주로 한강에서 러닝을 해요"', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black87), textAlign: TextAlign.center),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A65), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('확인', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))
          ],
        ),
      ),
    );
  }
}
