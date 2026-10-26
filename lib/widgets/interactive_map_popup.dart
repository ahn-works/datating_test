import '../services/kakao_map_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class InteractiveMapPopup extends StatefulWidget {
  final LatLng initialCenter;
  final String locationName;
  final String kakaoLink;

  const InteractiveMapPopup({
    super.key,
    required this.initialCenter,
    required this.locationName,
    required this.kakaoLink,
  });

  @override
  State<InteractiveMapPopup> createState() => _InteractiveMapPopupState();
}

class _InteractiveMapPopupState extends State<InteractiveMapPopup> {
  String _distanceText = '거리 계산 중...';

  @override
  void initState() {
    super.initState();
    _calcDistance();
  }

  Future<void> _calcDistance() async {
    final text = await KakaoMapService.getDistanceTextFromCurrent(
      widget.initialCenter.latitude,
      widget.initialCenter.longitude,
    );
    if (mounted) {
      setState(() => _distanceText = text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.72,
        child: Stack(
          children: [
            // Map
            FlutterMap(
              options: MapOptions(
                initialCenter: widget.initialCenter,
                initialZoom: 16.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.initialCenter,
                      width: 52,
                      height: 52,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF191919),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '약속장소',
                              style: TextStyle(color: Color(0xFFFEE500), fontSize: 9.5, fontWeight: FontWeight.w900),
                            ),
                          ),
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFFF25767),
                            size: 32,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Header (Back button & Title & Distance)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.locationName,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE500),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '카카오맵 연동',
                                  style: TextStyle(color: Color(0xFF191919), fontSize: 9.5, fontWeight: FontWeight.w900),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _distanceText,
                                style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Kakao Map & Directions Launch Buttons
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => KakaoMapService.launchMap(
                        widget.locationName,
                        lat: widget.initialCenter.latitude,
                        lng: widget.initialCenter.longitude,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE500), // Kakao Yellow
                        foregroundColor: const Color(0xFF191919), // Kakao Black
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.map_rounded, size: 18),
                      label: const Text('카카오맵 보기', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => KakaoMapService.launchDirections(
                        widget.locationName,
                        lat: widget.initialCenter.latitude,
                        lng: widget.initialCenter.longitude,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF191919), // Midnight Black
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.directions_rounded, size: 18, color: Color(0xFFFEE500)),
                      label: const Text('카카오 길찾기', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
