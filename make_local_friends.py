import io

code = '''import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'soso_car_home_screen.dart';
import 'soso_car_host_screen.dart';
import 'oomu_my_trips_screen.dart';
import 'my_page_screen.dart';

class LocalFriendsScreen extends StatefulWidget {
  const LocalFriendsScreen({super.key});

  @override
  State<LocalFriendsScreen> createState() => _LocalFriendsScreenState();
}

class _LocalFriendsScreenState extends State<LocalFriendsScreen> {
  final Color primaryColor = const Color(0xFFF19E39);
  int _selectedFilterIndex = 0;
  
  final List<String> _filters = ['전체', '동네 산책', '밥친구', '카공', '러닝', '급벙'];

  final List<Map<String, dynamic>> _meetups = [
    {
      'type': '동네 산책',
      'title': '경의선 숲길 가볍게 산책해요 🚶‍♀️',
      'time': '오늘 저녁 8시',
      'location': '홍대입구역 3번 출구',
      'hostName': '연남동 댕댕이',
      'hostTemp': 38.5,
      'currentMembers': 2,
      'maxMembers': 4,
      'color': const Color(0xFFF19E39),
    },
    {
      'type': '밥친구',
      'title': '퇴근하고 연남동에서 마라탕 드실 분!',
      'time': '오늘 오후 7시 30분',
      'location': '연남파출소 앞',
      'hostName': '마라사랑',
      'hostTemp': 41.2,
      'currentMembers': 1,
      'maxMembers': 2,
      'color': const Color(0xFFE76F51),
    },
    {
      'type': '카공',
      'title': '주말 오후 조용히 각자 할 일 해요 💻',
      'time': '토요일 오후 2시',
      'location': '스타벅스 연희DT점',
      'hostName': '취준생파이팅',
      'hostTemp': 36.5,
      'currentMembers': 1,
      'maxMembers': 4,
      'color': const Color(0xFF2A9D8F),
    },
    {
      'type': '러닝',
      'title': '연트럴파크 5km 러닝 🏃‍♂️🏃‍♀️',
      'time': '내일 아침 7시',
      'location': '가좌역 1번 출구',
      'hostName': '런린이',
      'hostTemp': 45.0,
      'currentMembers': 3,
      'maxMembers': 6,
      'color': const Color(0xFF264653),
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('동네 친구 만들기', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black87), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(_filters.length, (index) {
                  bool isSelected = _selectedFilterIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilterIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade300),
                      ),
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _meetups.length,
              itemBuilder: (context, index) {
                final meetup = _meetups[index];
                if (_selectedFilterIndex != 0 && meetup['type'] != _filters[_selectedFilterIndex]) {
                  return const SizedBox.shrink();
                }
                return _buildMeetupCard(meetup);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: primaryColor,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text('모임 열기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMeetupCard(Map<String, dynamic> meetup) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (meetup['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  meetup['type'],
                  style: TextStyle(color: meetup['color'], fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const Icon(Icons.more_vert, size: 18, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Text(meetup['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(meetup['time'], style: const TextStyle(fontSize: 12, color: Colors.black87)),
              const SizedBox(width: 12),
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(meetup['location'], style: const TextStyle(fontSize: 12, color: Colors.black87)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(Icons.person, size: 14, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Text(meetup['hostName'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text('${meetup['hostTemp']}°C 🌡️', style: const TextStyle(fontSize: 11, color: Color(0xFFC04020), fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  Text('참여 ${meetup['currentMembers']}/${meetup['maxMembers']}명', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('참여하기', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
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

with io.open('lib/screens/local_friends_screen.dart', 'w', encoding='utf-8') as f:
    f.write(code)
