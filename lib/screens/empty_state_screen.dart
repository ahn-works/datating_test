import 'package:flutter/material.dart';

class EmptyStateScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  
  const EmptyStateScreen({super.key, this.title = '주변에 유저가 없어요', this.subtitle = '필터를 조정해서 더 넓은 지역을 탐색해보세요.'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: const Color(0xFFF9F9F9), shape: BoxShape.circle),
                child: const Icon(Icons.search_off, size: 80, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5)),
              const SizedBox(height: 40),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF8A65),
                  side: const BorderSide(color: Color(0xFFFF8A65)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('필터 재설정하기', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
