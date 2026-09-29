import io
import re

with io.open('lib/screens/soso_car_host_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add imports
if 'interactive_map_popup.dart' not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:latlong2/latlong.dart';\nimport '../widgets/interactive_map_popup.dart';")

# Find the build method invocation
target_line = "_buildTextField('모임 장소', _locationController, '예) 마포구 연남동 (또는 구체적인 카페명)'),"

replacement = """            _buildLocationField(context),"""
content = content.replace(target_line, replacement)

# Add the new method
new_method = """  Widget _buildLocationField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('모임 장소', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textSecondary)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => const InteractiveMapPopup(
                  initialCenter: LatLng(37.5665, 126.9780), // 서울 중심 또는 지정 위치
                  locationName: '모임 장소 설정',
                  kakaoLink: 'https://map.kakao.com/', // 임시
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: textSecondary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _locationController.text.isEmpty ? '지도에서 모임 장소 선택' : _locationController.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: _locationController.text.isEmpty ? textSecondary : textPrimary,
                    ),
                  ),
                  const Spacer(),
                  // 우측 작은 썸네일 (당근마켓 스타일)
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        image: NetworkImage('https://tile.openstreetmap.org/16/55865/25398.png'),
                        fit: BoxFit.cover,
                      )
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

  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {"""

content = content.replace("  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {", new_method)

with io.open('lib/screens/soso_car_host_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
