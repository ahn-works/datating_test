import 'package:flutter/material.dart';

class QrCheckinScreen extends StatelessWidget {
  const QrCheckinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // 카메라 뷰 느낌의 어두운 배경
      appBar: AppBar(
        title: const Text('오프라인 QR 체크인', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('서로의 QR 코드를 스캔하여\n만남을 인증하고 보증금을 환불받으세요!', 
            textAlign: TextAlign.center, 
            style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)
          ),
          const SizedBox(height: 48),
          // 가짜 QR 스캐너 프레임
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFF8A65), width: 4),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner, size: 120, color: Colors.white24),
                  // 스캔 애니메이션 선 느낌
                  Positioned(
                    top: 50,
                    child: Container(width: 200, height: 2, color: const Color(0xFFFF8A65)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
          // 내 QR 코드 보여주기 버튼
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.qr_code, color: Colors.black87),
            label: const Text('내 QR 코드 보여주기', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
          const SizedBox(height: 32),
          // 테이블 컬러 시그널
          const Text('우리의 테이블 컬러 시그널', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          const Text('🟣 보라색', style: TextStyle(color: Color(0xFFD288FF), fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
