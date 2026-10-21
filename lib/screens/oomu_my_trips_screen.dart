import 'package:flutter/material.dart';
import '../utils/app_image.dart';
import 'soso_car_home_screen.dart';
import 'soso_car_host_screen.dart';
import 'chat_screen.dart';
import 'my_page_screen.dart';
import 'soso_car_detail_screen.dart';

class OOMUMyTripsScreen extends StatefulWidget {
  const OOMUMyTripsScreen({super.key});

  @override
  State<OOMUMyTripsScreen> createState() => _OOMUMyTripsScreenState();
}

class _OOMUMyTripsScreenState extends State<OOMUMyTripsScreen> with SingleTickerProviderStateMixin {
  final Color textPrimary = const Color(0xFF111111);
  final Color textSecondary = const Color(0xFF767676);
  final Color surfaceColor = const Color(0xFFF5F5F7);
  final Color accentColor = const Color(0xFFF19E39);
  final Color destructiveColor = const Color(0xFFFF3B30);

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('내 모임', style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: textPrimary,
          unselectedLabelColor: textSecondary,
          indicatorColor: accentColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          tabs: const [
            Tab(text: '참여 예정'),
            Tab(text: '내가 연 모임'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyMeetupList(isHosting: false),
          _buildMyMeetupList(isHosting: true),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildMyMeetupList({required bool isHosting}) {
    // Dummy Data specifically for "My Meetups"
    final meetups = isHosting ? [
      {
        'title': '주말 엽떡+마라탕 조지실 분',
        'category': '술/맛집',
        'location': '홍대입구역 9번 출구',
        'date': '이번주 토요일 18:00',
        'status': '모집 중',
        'members': '2/4',
        'imageUrl': 'assets/images/cover_food.jpg'
      }
    ] : [
      {
        'title': '성수동 대형 에스프레소 바 & 감성 북카페 나들이 ☕📚',
        'category': '카페/수다',
        'location': '성동구 성수동 카페거리',
        'date': '내일 14:00',
        'status': '참여 확정',
        'members': '3/4',
        'imageUrl': 'assets/images/cover_cafe.jpg'
      }
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: meetups.length,
      itemBuilder: (context, index) {
        final meetup = meetups[index];
        return GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OOMUDetailScreen(meetup: meetup))), child: Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEBEBEF)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  image: DecorationImage(image: appImg(meetup['imageUrl']), fit: BoxFit.cover),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    gradient: LinearGradient(colors: [Colors.black.withOpacity(0.5), Colors.transparent], begin: Alignment.topCenter, end: Alignment.center),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(8)),
                        child: Text(meetup['category']!, style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(meetup['title']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: isHosting ? surfaceColor : const Color(0xFFE5F0FF), borderRadius: BorderRadius.circular(8)),
                          child: Text(meetup['status']!, style: TextStyle(fontSize: 12, color: isHosting ? textPrimary : accentColor, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: textSecondary),
                        const SizedBox(width: 4),
                        Text(meetup['location']!, style: TextStyle(fontSize: 13, color: textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 16, color: textSecondary),
                            const SizedBox(width: 4),
                            Text(meetup['date']!, style: TextStyle(fontSize: 13, color: textSecondary)),
                          ],
                        ),
                        Text('${meetup['members']!} 참여중', style: TextStyle(fontSize: 13, color: textSecondary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
      },
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    const coralAccent = Color(0xFFF25767);
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: coralAccent,
      unselectedItemColor: const Color(0xFF767676),
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      elevation: 20,
      backgroundColor: Colors.white,
      onTap: (index) {
        if (index <= 2) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OOMUHomeScreen(initialTab: index)));
        } else if (index == 3) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
        } else if (index == 4) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyPageScreen()));
        }
      },
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined, size: 24),
          activeIcon: Icon(Icons.home, size: 24, color: Color(0xFFF25767)),
          label: '동네모임',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.group_outlined, size: 24),
          activeIcon: Icon(Icons.group, size: 24),
          label: '커뮤니티',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border, size: 24),
          activeIcon: Icon(Icons.favorite, size: 24),
          label: '소개팅',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline, size: 23),
          activeIcon: Icon(Icons.chat_bubble, size: 23),
          label: '채팅',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline, size: 24),
          activeIcon: Icon(Icons.person, size: 24),
          label: 'MY',
        ),
      ],
    );
  }
}
