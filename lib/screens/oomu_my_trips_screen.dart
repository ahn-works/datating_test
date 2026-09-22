import 'package:flutter/material.dart';
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
  final Color accentColor = const Color(0xFF007AFF);
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
          indicatorColor: textPrimary,
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
        'imageUrl': 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&q=80'
      }
    ] : [
      {
        'title': '파주 대형 북카페로 드라이브 가요',
        'category': '여행/드라이브',
        'location': '파주 지혜의 숲',
        'date': '내일 14:00',
        'status': '참여 확정',
        'members': '3/3',
        'imageUrl': 'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=800&q=80'
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
                  image: DecorationImage(image: NetworkImage(meetup['imageUrl']!), fit: BoxFit.cover),
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
    return BottomNavigationBar(
      currentIndex: 3,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: textPrimary,
      unselectedItemColor: const Color(0xFFC7C7CC),
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      elevation: 20,
      backgroundColor: Colors.white,
      onTap: (index) {
        if (index == 0) { Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => const OOMUHomeScreen(), transitionDuration: Duration.zero)); }
        else if (index == 1) { Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => const OOMUHostScreen(), transitionDuration: Duration.zero)); }
        else if (index == 2) { Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => const ChatScreen(), transitionDuration: Duration.zero)); }
        else if (index == 3) { }
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
