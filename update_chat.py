import io

chat_code = '''import 'package:flutter/material.dart';
import 'soso_car_chat_screen.dart';
import 'soso_car_home_screen.dart';
import 'soso_car_host_screen.dart';
import 'oomu_my_trips_screen.dart';
import 'my_page_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color textPrimary = const Color(0xFF111111);
    final Color textSecondary = const Color(0xFF767676);
    
    final List<Map<String, dynamic>> _chatRooms = [
      {
        'title': '주말 엽떡+마라탕 조지실 분 🔥',
        'lastMessage': '홍대입구역 9번 출구 앞에서 봬요!',
        'time': '오후 2:30',
        'unread': 3,
        'members': 4,
        'imageUrl': 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=200&q=80',
        'isGroup': true,
      },
      {
        'title': '볼링 에버리지 100 쪼렙팟 🎳',
        'lastMessage': '저 볼링화 240이요~',
        'time': '오전 11:15',
        'unread': 0,
        'members': 6,
        'imageUrl': 'https://images.unsplash.com/photo-1523301343968-6a6ebf63c672?w=200&q=80',
        'isGroup': true,
      },
      {
        'title': '매운맛킬러 (호스트)',
        'lastMessage': '혹시 마라탕 알러지 있으신가요?',
        'time': '어제',
        'unread': 1,
        'members': 2,
        'imageUrl': 'https://i.pravatar.cc/150?img=47',
        'isGroup': false,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('채팅', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 24)),
        actions: [
          IconButton(icon: Icon(Icons.search, color: textPrimary), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 12),
        itemCount: _chatRooms.length,
        itemBuilder: (context, index) {
          final room = _chatRooms[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OOMUChatScreen(
                    title: room['title'],
                    memberCount: room['members'],
                  ),
                ),
              );
            },
            highlightColor: const Color(0xFFF5F5F7),
            splashColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          shape: room['isGroup'] ? BoxShape.rectangle : BoxShape.circle,
                          borderRadius: room['isGroup'] ? BorderRadius.circular(20) : null,
                          image: DecorationImage(image: NetworkImage(room['imageUrl']), fit: BoxFit.cover),
                          border: Border.all(color: const Color(0xFFEBEBEF)),
                        ),
                      ),
                    ],
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
                                room['title'],
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: textPrimary),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (room['isGroup']) ...[
                              const SizedBox(width: 6),
                              Text('${room['members']}', style: TextStyle(color: textSecondary, fontSize: 14)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          room['lastMessage'],
                          style: TextStyle(color: textSecondary, fontSize: 14, fontWeight: room['unread'] > 0 ? FontWeight.w600 : FontWeight.w400),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(room['time'], style: const TextStyle(color: Color(0xFFAEAEC2), fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      if (room['unread'] > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFF3B30), borderRadius: BorderRadius.circular(10)),
                          child: Text('${room['unread']}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      if (room['unread'] == 0) const SizedBox(height: 22),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF111111),
      unselectedItemColor: const Color(0xFFC7C7CC),
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      elevation: 20,
      backgroundColor: Colors.white,
      onTap: (index) {
        if (index == 0) { Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => const OOMUHomeScreen(), transitionDuration: Duration.zero)); }
        else if (index == 1) { Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => const OOMUHostScreen(), transitionDuration: Duration.zero)); }
        else if (index == 2) { }
        else if (index == 3) { Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => const OOMUMyTripsScreen(), transitionDuration: Duration.zero)); }
        else if (index == 4) { Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => const MyPageScreen(), transitionDuration: Duration.zero)); }
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined, size: 26), activeIcon: Icon(Icons.explore, size: 26), label: '탐색'),
        const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 26), activeIcon: Icon(Icons.add_circle, size: 26), label: '모집하기'),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.chat_bubble_outline, size: 24),
              Positioned(right: -6, top: -6, child: Container(padding: const EdgeInsets.all(5), decoration: const BoxDecoration(color: Color(0xFFFF3B30), shape: BoxShape.circle), child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
            ],
          ),
          activeIcon: const Icon(Icons.chat_bubble, size: 24),
          label: '채팅',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.directions_car_outlined, size: 26), activeIcon: Icon(Icons.directions_car, size: 26), label: '내 모임'),
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 26), activeIcon: Icon(Icons.person, size: 26), label: '마이'),
      ],
    );
  }
}
'''
with io.open('lib/screens/chat_screen.dart', 'w', encoding='utf-8') as f:
    f.write(chat_code)

print("chat_screen.dart updated")
