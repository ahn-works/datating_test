import io

with io.open('lib/screens/soso_car_chat_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add import
if 'url_launcher.dart' not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:url_launcher/url_launcher.dart';")

old_map = """          // 다음 지도 (Kakao Map) 썸네일 예시
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: NetworkImage('https://tile.openstreetmap.org/16/55865/25398.png'), // Placeholder for map
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withOpacity(0.3),
              ),
              child: const Center(
                child: Text('📍 카카오맵에서 위치 보기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),"""

new_map = """          // 다음 지도 (Kakao Map) 썸네일 예시
          GestureDetector(
            onTap: () async {
              final Uri url = Uri.parse('https://map.kakao.com/link/map/홍대입구역 9번출구,37.5568,126.9242');
              if (!await launchUrl(url)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('지도를 열 수 없습니다.')));
              }
            },
            child: Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: NetworkImage('https://tile.openstreetmap.org/16/55865/25398.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black.withOpacity(0.3),
                ),
                child: const Center(
                  child: Text('📍 카카오맵에서 위치 보기 (클릭)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),"""

content = content.replace(old_map, new_map)

with io.open('lib/screens/soso_car_chat_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
