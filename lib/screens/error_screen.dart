import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  
  const ErrorScreen({
    super.key, 
    this.title = '네트워크 연결 오류', 
    this.message = '인터넷 연결이 불안정합니다.\nWi-Fi 또는 데이터 연결 상태를 확인해주세요.'
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(color: Color(0xFFFFF0EC), shape: BoxShape.circle),
                child: const Icon(Icons.wifi_off, size: 80, color: Color(0xFFFF8A65)),
              ),
              const SizedBox(height: 32),
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5)),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87, 
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                ),
                child: const Text('다시 시도', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
