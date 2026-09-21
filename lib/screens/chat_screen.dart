import 'package:flutter/material.dart';
import 'soso_car_chat_screen.dart';
import 'soso_car_home_screen.dart';
import 'soso_car_host_screen.dart';
import 'oomu_my_trips_screen.dart';
import 'my_page_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF1A1A1A);
    
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
        title: const Text('우무 채팅', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black87), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black87), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: room['isGroup'] ? BoxShape.rectangle : BoxShape.circle,
                          borderRadius: room['isGroup'] ? BorderRadius.circular(20) : null,
                          image: DecorationImage(
                            image: NetworkImage(room['imageUrl']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (room['isGroup'])
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Icon(Icons.group, size: 12, color: primaryColor),
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
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (room['isGroup']) ...[
                              const SizedBox(width: 6),
                              Text(
                                '${room['members']}',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          room['lastMessage'],
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(room['time'], style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                      const SizedBox(height: 8),
                      if (room['unread'] > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF3B30),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${room['unread']}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
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
    final Color primaryColor = const Color(0xFF1A1A1A);
    return BottomNavigationBar(
      currentIndex: 2,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      onTap: (index) {
        if (index == 0) { Navigator.push(context, MaterialPageRoute(builder: (context) => const OOMUHomeScreen())); }
        else if (index == 1) { Navigator.push(context, MaterialPageRoute(builder: (context) => const OOMUHostScreen())); }
        else if (index == 2) { }
        else if (index == 3) { Navigator.push(context, MaterialPageRoute(builder: (context) => const OOMUMyTripsScreen())); }
        else if (index == 4) { Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPageScreen())); }
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: '탐색'),
        const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: '모집하기'),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.chat_bubble_outline),
              Positioned(right: -4, top: -4, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Color(0xFFFF3B30), shape: BoxShape.circle), child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
            ],
          ),
          label: '채팅',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.directions_car_outlined), activeIcon: Icon(Icons.directions_car), label: '내 모임'),
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: '마이'),
      ],
    );
  }
}
