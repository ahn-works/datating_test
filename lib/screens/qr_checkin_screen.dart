import 'package:flutter/material.dart';
import 'review_screen.dart';
import 'fake_call_screen.dart';
import 'second_spot_screen.dart';

class QrCheckinScreen extends StatelessWidget {
  const QrCheckinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // 카메라 느낌의 어두운 배경
      appBar: AppBar(
        title: const Text('오프라인 QR 체크인', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
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
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ReviewScreen()));
              },
              icon: const Icon(Icons.qr_code, color: Colors.black87),
              label: const Text('체크인 완료 및 리뷰하기', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            const Spacer(),
            const Divider(color: Colors.white24),
            const SizedBox(height: 12),
            const Text('현장 만남 보조 도구', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const FakeCallScreen()));
                    },
                    icon: const Icon(Icons.call_end, color: Colors.red),
                    label: const Text('비상 탈출', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SecondSpotScreen()));
                    },
                    icon: const Icon(Icons.map, color: Colors.white),
                    label: const Text('2차 스팟', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), backgroundColor: const Color(0xFFFF8A65), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
