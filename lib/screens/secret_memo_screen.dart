import 'package:flutter/material.dart';

class SecretMemoScreen extends StatelessWidget {
  const SecretMemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, color: Colors.white54, size: 48),
            const SizedBox(height: 24),
            const Text('데일리 비밀 메모', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('오늘의 대화 중 가장 인상 깊었던 사람에게\n익명으로 짧은 메모를 남겨주세요.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, height: 1.5)),
            const SizedBox(height: 40),
            TextField(maxLines: 5, decoration: InputDecoration(hintText: '메모를 작성해주세요...', hintStyle: const TextStyle(color: Colors.white38), filled: true, fillColor: Colors.white12, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A65), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('메모 남기기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))
          ],
        ),
      ),
    );
  }
}
