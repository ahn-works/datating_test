import 'package:flutter/material.dart';
import '../services/kakao_map_service.dart';
import '../widgets/kakao_map_view.dart';

class MiddleSpotMapScreen extends StatelessWidget {
  final double lat;
  final double lng;
  final String spotName;
  final String description;

  const MiddleSpotMapScreen({
    super.key,
    this.lat = 36.6347,
    this.lng = 127.4326,
    this.spotName = '청주역 (충북선)',
    this.description = '두 사람의 출발지 중간 지점으로 최적화되었습니다',
  });

  @override
  Widget build(BuildContext context) {
    const coralAccent = Color(0xFFFF5E36);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '중간 지점 카카오 지도 찾기',
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
      body: Column(
        children: [
          // 1. 카카오 공식 지도 뷰
          Expanded(
            child: Stack(
              children: [
                KakaoMapView(
                  lat: lat,
                  lng: lng,
                  locationName: spotName, hideActions: true,
            ),
                // 상단 안내 뱃지
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.hub_rounded, color: coralAccent, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '카카오맵 기반 정밀 중간 지점 탐색 완료',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. 하단 정보 카드 & 카카오 액션
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFECE5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.location_on, color: coralAccent, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                spotName,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                description,
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => KakaoMapService.launchMap(spotName, lat: lat, lng: lng),
                          icon: const Icon(Icons.map_rounded, size: 18),
                          label: const Text('카카오맵 열기', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1E293B),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => KakaoMapService.launchDirections(spotName, lat: lat, lng: lng),
                          icon: const Icon(Icons.directions_rounded, size: 18, color: Color(0xFF191919)),
                          label: const Text('카카오 길찾기', style: TextStyle(color: Color(0xFF191919), fontWeight: FontWeight.w800, fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFEE500),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: coralAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        '이 지점으로 모임 장소 확정',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
