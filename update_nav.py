import io
import re

for filepath in ['lib/screens/soso_car_home_screen.dart', 'lib/screens/oomu_my_trips_screen.dart']:
    with io.open(filepath, 'r', encoding='utf-8') as f:
        text = f.read()

    # ensure my_page_screen.dart is imported
    if "import 'my_page_screen.dart';" not in text:
        text = text.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'my_page_screen.dart';")

    # replace the bottom navigation bar items array
    if filepath == 'lib/screens/soso_car_home_screen.dart':
        current_idx = 0
    else:
        current_idx = 3
        
    start_idx = text.find('Widget _buildBottomNav() {')
    if start_idx != -1:
        text = text[:start_idx] + f'''Widget _buildBottomNav() {{
    return BottomNavigationBar(
      currentIndex: {current_idx},
      type: BottomNavigationBarType.fixed,
      selectedItemColor: darkGreen,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      onTap: (index) {{
        if (index == 0) {{
          Navigator.popUntil(context, (route) => route.isFirst);
        }} else if (index == 1) {{
          Navigator.push(context, MaterialPageRoute(builder: (context) => const OOMUHostScreen()));
        }} else if (index == 2) {{
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
        }} else if (index == 3) {{
          Navigator.push(context, MaterialPageRoute(builder: (context) => const OOMUMyTripsScreen()));
        }} else if (index == 4) {{
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPageScreen()));
        }}
      }},
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
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: '마이'),
      ],
    );
  }}
}}
'''
    with io.open(filepath, 'w', encoding='utf-8') as f:
        f.write(text)
