
import 'package:flutter/material.dart';
import '../utils/app_image.dart';
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
    final Color accentColor = const Color(0xFFF19E39);
    final Color backgroundColor = const Color(0xFFF7F8FA);
    
    final List<Map<String, dynamic>> _chatRooms = [
      {
        'title': '주말 엽떡+마라탕 조지실 분 🔥',
        'lastMessage': '홍대입구역 9번 출구 앞에서 봬요!',
        'time': '오후 2:30',
        'unread': 3,
        'members': 4,
        'imageUrl': 'assets/images/cover_food.jpg',
        'isGroup': true,
      },
      {
        'title': '볼링 에버리지 100 쪼렙팟 🎳',
        'lastMessage': '저 볼링화 240이요~',
        'time': '오전 11:15',
        'unread': 0,
        'members': 6,
        'imageUrl': 'assets/images/cover_wine.jpg',
        'isGroup': true,
      },
      {
        'title': '매운맛킬러 (호스트)',
        'lastMessage': '혹시 마라탕 알러지 있으신가요?',
        'time': '어제',
        'unread': 1,
        'members': 2,
        'imageUrl': 'assets/images/kr_female_1.jpg',
        'isGroup': false,
      },
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text('채팅', style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(icon: Icon(Icons.search, color: textPrimary, size: 28), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _chatRooms.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final room = _chatRooms[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => OOMUChatScreen(title: room['title'], memberCount: room['members'])));
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  // Profile Image
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: appImg(room['imageUrl']),
                        backgroundColor: const Color(0xFFEBEBEF),
                      ),
                      if (room['isGroup'] == false)
                        Positioned(
                          right: 0, bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const CircleAvatar(radius: 8, backgroundColor: Colors.green),
                          ),
                        )
                    ],
                  ),
                  const SizedBox(width: 16),
                  
                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                room['title'],
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (room['isGroup'])
                              Padding(
                                padding: const EdgeInsets.only(left: 6.0),
                                child: Text('${room['members']}', style: TextStyle(color: textSecondary, fontSize: 14)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          room['lastMessage'],
                          style: TextStyle(fontSize: 14, color: textSecondary, fontWeight: FontWeight.w500),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Time & Unread Badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(room['time'], style: TextStyle(fontSize: 12, color: room['unread'] > 0 ? accentColor : const Color(0xFFC7C7CC), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (room['unread'] > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(12)),
                          child: Text('${room['unread']}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      else
                        const SizedBox(height: 22),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: BottomNavigationBar(
            currentIndex: 2,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: accentColor,
            unselectedItemColor: const Color(0xFFC7C7CC),
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 0,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OOMUHomeScreen()));
              } else if (index == 1) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OOMUHostScreen()));
              } else if (index == 3) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OOMUMyTripsScreen()));
              } else if (index == 4) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyPageScreen()));
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.explore), label: '탐색'),
              BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: '모집하기'),
              BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: '채팅'),
              BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: '내 모임'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이'),
            ],
          ),
        ),
      ),
    );
  }
}
