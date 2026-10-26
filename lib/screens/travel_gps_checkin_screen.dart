import 'package:flutter/material.dart';
import '../services/kakao_map_service.dart';
import '../widgets/kakao_map_view.dart';
import 'travel_room_screen.dart';

class TravelGpsCheckinScreen extends StatefulWidget {
  const TravelGpsCheckinScreen({super.key});

  @override
  State<TravelGpsCheckinScreen> createState() => _TravelGpsCheckinScreenState();
}

class _TravelGpsCheckinScreenState extends State<TravelGpsCheckinScreen> {
  static const double mokpoLat = 34.7912;
  static const double mokpoLng = 126.3868;
  static const String placeName = '목포역 광장 시계탑 앞';

  @override
  Widget build(BuildContext context) {
    const coralAccent = Color(0xFFFF5E36);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '목포역 광장 카카오 GPS 체크인',
          style: TextStyle(color: Color(0xFF111111), fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111111)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF0F0F3), height: 1),
        ),
      ),
      body: Stack(
        children: [
          // 1. 카카오 공식 지도 뷰
          Positioned.fill(
            child: KakaoMapView(
              lat: mokpoLat,
              lng: mokpoLng,
              locationName: placeName,
            ),
          ),

          // 2. 우측 하단 카카오 길찾기 FAB
          Positioned(
            right: 20,
            bottom: 230,
            child: FloatingActionButton.extended(
              backgroundColor: const Color(0xFFFEE500),
              foregroundColor: const Color(0xFF191919),
              elevation: 4,
              onPressed: () => KakaoMapService.launchDirections(placeName, lat: mokpoLat, lng: mokpoLng),
              icon: const Icon(Icons.directions_rounded, size: 20),
              label: const Text('카카오 길찾기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),

          // 3. 하단 GPS 안심 인증 카드 & 환불 확정
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                              SizedBox(width: 6),
                              Text(
                                '카카오 위치 인증 완료 (오차 10m 이내)',
                                style: TextStyle(
                                  color: Color(0xFF047857),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, color: coralAccent, size: 22),
                        SizedBox(width: 6),
                        Text(
                          '현재 위치: 목포역 광장 (체크인 정상)',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '모임 장소 도착이 확인되었습니다. 보증금이 안심 환불 처리됩니다.',
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const TravelRoomScreen()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: coralAccent,
                        minimumSize: const Size(double.infinity, 54),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        '보증금 환불 받고 단톡방 입장',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
