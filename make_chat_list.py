import io

code = '''import 'package:flutter/material.dart';
import 'soso_car_chat_screen.dart';
import 'soso_car_home_screen.dart';
import 'soso_car_host_screen.dart';
import 'oomu_my_trips_screen.dart';
import 'my_page_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('동행 채팅', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFBF9F6),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _chatItem(
            context,
            '달리는 민우',
            '강화도 당일치기 드라이브 팟',
            '내일 아침 9시 반 맞으시죠?',
            '오후 2:30',
            2,
            const Color(0xFF14422D),
          ),
          const SizedBox(height: 12),
          _chatItem(
            context,
            '책읽는 지은',
            '파주 출판도시 북카페 카풀',
            '네, 출발할 때 연락드릴게요~',
            '어제',
            0,
            const Color(0xFFBCEECF),
            avatarIconColor: const Color(0xFF14422D),
          ),
          const SizedBox(height: 12),
          _chatItem(
            context,
            '마라사랑',
            '연남동 마라탕 밥친구',
            '사진을 보냈습니다.',
            '어제',
            0,
            const Color(0xFFE76F51),
            avatarIconColor: Colors.white,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _chatItem(BuildContext context, String name, String groupTitle, String msg, String time, int unreadCount, Color avatarColor, {Color? avatarIconColor}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const OOMUChatScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: avatarColor.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: avatarColor.withOpacity(0.5), width: 1),
              ),
              child: Icon(Icons.directions_car, color: avatarIconColor ?? avatarColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          groupTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('$name: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
                      Expanded(
                        child: Text(
                          msg,
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFA33D23),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF14422D),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      onTap: (index) {
        if (index == 0) {
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const OOMUHostScreen()));
        } else if (index == 2) {
          // Current Screen
        } else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const OOMUMyTripsScreen()));
        } else if (index == 4) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPageScreen()));
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
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: '마이'),
      ],
    );
  }
}
'''

with io.open('lib/screens/chat_screen.dart', 'w', encoding='utf-8') as f:
    f.write(code)
