import 'package:flutter/material.dart';
import '../services/kakao_map_service.dart';

Widget buildKakaoMapWidget({
  required double lat,
  required double lng,
  required String locationName,
  required double height,
  required double width,
  bool hideActions = false,
  List<Map<String, dynamic>>? markers,
  String? selectedMarkerId,
  int zoomLevel = 3,
  void Function(String markerId, bool shouldOpenDetail)? onMarkerTap,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: const Color(0xFFFFFBE6),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFFEE500), width: 1.5),
    ),
    child: Center(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE500),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '카카오 지도',
                style: TextStyle(
                  color: Color(0xFF191919),
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                locationName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: Color(0xFF191919),
                ),
              ),
            ),
            if (markers != null && markers.isNotEmpty && onMarkerTap != null) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: markers.take(5).map((m) {
                  final id = (m['id'] ?? '').toString();
                  final title = (m['title'] ?? '모임').toString();
                  final isSel = id == selectedMarkerId;
                  return ActionChip(
                    backgroundColor:
                        isSel ? const Color(0xFF191F28) : Colors.white,
                    label: Text(
                      title.length > 12 ? '${title.substring(0, 11)}..' : title,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSel ? Colors.white : const Color(0xFF191F28),
                      ),
                    ),
                    onPressed: () => onMarkerTap(id, isSel),
                  );
                }).toList(),
              ),
            ],
            if (!hideActions) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE500),
                        foregroundColor: const Color(0xFF191919),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () =>
                          KakaoMapService.launchMap(locationName, lat: lat, lng: lng),
                      icon: const Icon(Icons.map_rounded, size: 16),
                      label: const Text(
                        '카카오맵 보기',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF191919),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => KakaoMapService.launchDirections(
                          locationName,
                          lat: lat,
                          lng: lng),
                      icon: const Icon(
                        Icons.directions_rounded,
                        size: 16,
                        color: Color(0xFFFEE500),
                      ),
                      label: const Text(
                        '길찾기',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
