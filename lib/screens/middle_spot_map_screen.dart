import 'package:flutter/material.dart';

class MiddleSpotMapScreen extends StatelessWidget {
  const MiddleSpotMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('중간지점 스팟 추천', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // 지도 영역 (Placeholder)
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: const Color(0xFFE2E8F0), // 지도 배경색 느낌
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 64, color: Colors.white),
                        SizedBox(height: 8),
                        Text('Google Maps (현재 위치 및 마커 로딩 중...)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                // 가상의 내 위치 마커
                Positioned(
                  left: 60, bottom: 80,
                  child: _buildMarker('나 (강남구)', Colors.blueAccent),
                ),
                // 가상의 상대방 위치 마커
                Positioned(
                  right: 60, top: 60,
                  child: _buildMarker('상대방 (성동구)', Colors.teal),
                ),
                // 제안된 중간지점 마커
                Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 25,
                  top: MediaQuery.of(context).size.height / 3 - 25,
                  child: const Column(
                    children: [
                      Icon(Icons.location_on, size: 50, color: Color(0xFFFF8A65)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 스팟 정보 및 보증금 결제 영역
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -5))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0EC),
                          borderRadius: BorderRadius.circular(16)
                        ),
                        child: const Icon(Icons.local_cafe, color: Color(0xFFFF8A65), size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('오우드(OUDE) 성수점', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('나에게서 3.2km · 상대에게서 1.5km', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // 보증금 안내 박스
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('노쇼 방지 보증금', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            Text('10,000원', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF8A65))),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 14, color: Colors.grey),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text('현장 카페에서 서로의 QR을 체크인하면 100% 환불됩니다.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const Spacer(),
                  
                  // 결제 버튼
                  ElevatedButton(
                    onPressed: () {
                      // TODO: 카카오페이/토스 등 결제 모듈 연동
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8A65),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('10,000원 결제하고 만남 확정하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarker(String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        Icon(Icons.arrow_drop_down, color: color, size: 24),
      ],
    );
  }
}
