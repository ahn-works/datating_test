import io

with io.open('lib/screens/soso_car_home_screen.dart', 'r', encoding='utf-8') as f:
    code = f.read()

if "import 'package:kpostal/kpostal.dart';" not in code:
    code = code.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:kpostal/kpostal.dart';")

if "String _currentLocation =" not in code:
    code = code.replace("class _SosoCarHomeScreenState extends State<SosoCarHomeScreen> {", "class _SosoCarHomeScreenState extends State<SosoCarHomeScreen> {\n  String _currentLocation = '마포구 연남동';")

old_title = '''      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('마포구 연남동', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
            SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: Colors.black87, size: 14),
          ],
        ),
      ),'''

new_title = '''      title: GestureDetector(
        onTap: () async {
          try {
            Kpostal? result = await Navigator.push(context, MaterialPageRoute(builder: (_) => KpostalView()));
            if (result != null) {
              setState(() {
                String addr = result.address;
                if (addr.length > 15) addr = addr.substring(0, 15) + '...';
                _currentLocation = addr;
              });
            }
          } catch (e) {
            print("Kpostal error: \\\");
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_currentLocation, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, color: Colors.black87, size: 14),
            ],
          ),
        ),
      ),'''

code = code.replace(old_title, new_title)

with io.open('lib/screens/soso_car_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(code)