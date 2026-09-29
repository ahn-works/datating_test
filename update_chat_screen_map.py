import io

with io.open('lib/screens/soso_car_chat_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add import for map popup and latlong2
if 'interactive_map_popup.dart' not in content:
    content = content.replace("import 'package:url_launcher/url_launcher.dart';", "import 'package:url_launcher/url_launcher.dart';\nimport 'package:latlong2/latlong.dart';\nimport '../widgets/interactive_map_popup.dart';")

old_tap = """            onTap: () async {
              final Uri url = Uri.parse('https://map.kakao.com/link/map/홍대입구역 9번출구,37.5568,126.9242');
              if (!await launchUrl(url)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('지도를 열 수 없습니다.')));
              }
            },"""

new_tap = """            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => const InteractiveMapPopup(
                  initialCenter: LatLng(37.5568, 126.9242),
                  locationName: '홍대입구역 9번 출구',
                  kakaoLink: 'https://map.kakao.com/link/map/홍대입구역 9번출구,37.5568,126.9242',
                ),
              );
            },"""

content = content.replace(old_tap, new_tap)

with io.open('lib/screens/soso_car_chat_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
