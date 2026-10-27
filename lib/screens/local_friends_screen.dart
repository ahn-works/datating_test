import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_image.dart';
import 'chat_screen.dart';
import 'soso_car_home_screen.dart';
import 'soso_car_host_screen.dart';
import 'oomu_my_trips_screen.dart';
import 'my_page_screen.dart';
import 'party_detail_screen.dart';
import 'party_host_screen.dart';
import 'empty_state_screen.dart';

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
      'image': 'assets/images/cover_running.jpg',
      'likes': 12,
      'comments': 5,
      'hasPoll': true,
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
      'image': 'assets/images/cover_food.jpg',
      'likes': 8,
      'comments': 2,
      'hasPoll': false,
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
      'image': 'assets/images/cover_cafe.jpg',
      'likes': 24,
      'comments': 11,
      'hasPoll': true,
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
      'image': 'assets/images/cover_running.jpg',
      'likes': 19,
      'comments': 4,
      'hasPoll': false,
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
                      HapticFeedback.selectionClick();
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
            child: Builder(
              builder: (context) {
                final displayed = _selectedFilterIndex == 0
                    ? _meetups
                    : _meetups.where((m) => m['type'] == _filters[_selectedFilterIndex]).toList();

                if (displayed.isEmpty) {
                  return EmptyStateScreen(
                    icon: Icons.person_search_rounded,
                    title: '해당 조건의 동네 친구 모임이 없어요',
                    message: '첫 번째로 모임을 열고\n가까운 동네 이웃과 소소한 일상을 함께해보세요!',
                    actionLabel: '새 모임 직접 열기',
                    onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PartyHostScreen())),
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: displayed.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildRichMeetupCard(displayed[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PartyHostScreen()));
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 22),
        label: const Text('모임 열기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildRichMeetupCard(Map<String, dynamic> meetup) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
          // Header: Host info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundImage: AssetImage('assets/images/kr_female_2.jpg'),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(meetup['hostName'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        Text('${meetup['hostTemp']}°C 🌡️', style: const TextStyle(fontSize: 11, color: Color(0xFFC04020), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const Icon(Icons.more_vert, size: 20, color: Colors.grey),
              ],
            ),
          ),
          // Image with Title and Badge
          Stack(
            children: [
              appNetImage(
                meetup['image'],
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: meetup['color'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    meetup['type'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Text(
                  meetup['title'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black87, blurRadius: 4)]),
                ),
              ),
            ],
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (meetup['hasPoll']) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.how_to_vote, size: 16, color: Color(0xFFF19E39)),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('현재 만남 장소 (스팟) 투표 진행 중!', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFF19E39), borderRadius: BorderRadius.circular(12)),
                          child: const Text('투표하기', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(meetup['time'], style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(meetup['location'], style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                // Footer: Social actions and Join
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.favorite_border, size: 18, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${meetup['likes']}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        const SizedBox(width: 12),
                        const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${meetup['comments']}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                    Row(
                      children: [
                        Text('참여 ${meetup['currentMembers']}/${meetup['maxMembers']}명', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        const SizedBox(width: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PartyDetailScreen(
                                  partyData: {
                                    'title': meetup['title'],
                                    'category': meetup['type'],
                                    'loc': meetup['location'],
                                    'date': meetup['time'],
                                    'author': meetup['hostName'],
                                    'authorInfo': '${meetup['hostTemp']}°C · 동네 이웃',
                                    'img': meetup['image'],
                                  },
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('참여하기', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    const coralAccent = Color(0xFFF25767);
    return BottomNavigationBar(
      currentIndex: 1,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: coralAccent,
      unselectedItemColor: const Color(0xFF767676),
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      elevation: 20,
      backgroundColor: Colors.white,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OOMUHomeScreen(initialTab: 0)));
        } else if (index == 1) {
          // current tab
        } else if (index == 2) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OOMUHomeScreen(initialTab: 2)));
        } else if (index == 3) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
        } else if (index == 4) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyPageScreen()));
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined, size: 24),
          activeIcon: Icon(Icons.home, size: 24),
          label: '동네모임',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_outlined, size: 24),
          activeIcon: Icon(Icons.group, size: 24),
          label: '커뮤니티',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border, size: 24),
          activeIcon: Icon(Icons.favorite, size: 24),
          label: '소개팅',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline, size: 23),
          activeIcon: Icon(Icons.chat_bubble, size: 23),
          label: '채팅',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline, size: 24),
          activeIcon: Icon(Icons.person, size: 24),
          label: 'MY',
        ),
      ],
    );
  }
}
