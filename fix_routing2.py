import io
with io.open('lib/screens/oomu_my_trips_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Make sure imports are there
if "import 'soso_car_host_screen.dart';" not in text:
    text = text.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'soso_car_host_screen.dart';\nimport 'chat_screen.dart';\nimport 'soso_car_chat_screen.dart';")

# Replace _buildBottomNav completely
start_idx = text.find('Widget _buildBottomNav() {')
if start_idx != -1:
    text = text[:start_idx] + '''Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 3,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: darkGreen,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      onTap: (index) {
        if (index == 0) {
          // 탐색 (메인 화면으로 이동)
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (index == 1) {
          // 모집하기
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SosoCarHostScreen()));
        } else if (index == 2) {
          // 채팅
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
        } else if (index == 3) {
          // 내 여행 (현재 화면)
        }
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: '탐색'),
        const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: '모집하기'),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.chat_bubble_outline),
              Positioned(
                right: -4, top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Color(0xFFB53D25), shape: BoxShape.circle),
                  child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
          label: '채팅',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.directions_car_outlined), activeIcon: Icon(Icons.directions_car), label: '내 여행'),
      ],
    );
  }
}
'''
    with io.open('lib/screens/oomu_my_trips_screen.dart', 'w', encoding='utf-8') as f:
        f.write(text)
