import 'package:flutter/material.dart';
import 'soso_car_host_screen.dart';
import 'chat_screen.dart';
import 'oomu_my_trips_screen.dart';
import 'my_page_screen.dart';
import 'soso_car_detail_screen.dart';
import 'filter_screen.dart';

class OOMUHomeScreen extends StatefulWidget {
  const OOMUHomeScreen({super.key});

  @override
  State<OOMUHomeScreen> createState() => _OOMUHomeScreenState();
}

class _OOMUHomeScreenState extends State<OOMUHomeScreen> {
  final Color primaryColor = const Color(0xFF1A1A1A);
  final Color badgeGrey = const Color(0xFFF0F0F0);
  
  int _selectedCategoryIndex = 0;
  final List<Map<String, dynamic>> _categories = [
    {'icon': '🔥', 'name': '전체'},
    {'icon': '🎤', 'name': '코노/노래'},
    {'icon': '🍻', 'name': '술/맛집'},
    {'icon': '☕', 'name': '카페/수다'},
    {'icon': '✈️', 'name': '여행/드라이브'},
    {'icon': '🎳', 'name': '액티비티'},
  ];

  final List<Map<String, dynamic>> _meetups = [
    {
      'title': '불금엔 역시 코노! 스트레스 풀 분 🎤',
      'category': '코노/노래',
      'location': '합정역 수코인노래방',
      'date': '오늘 저녁 8시',
      'host': '고음불가',
      'manner': 38.5,
      'price': 'N빵',
      'members': '2/4명',
      'isFemaleOnly': true,
      'transport': '각자 이동',
      'imageUrl': 'https://images.unsplash.com/photo-1516280440502-8618eb3090ef?w=500&q=80'
    },
    {
      'title': '주말 엽떡+마라탕 조지실 분',
      'category': '술/맛집',
      'location': '홍대입구역 9번 출구',
      'date': '이번주 토요일 18:00',
      'host': '매운맛킬러',
      'manner': 41.2,
      'price': 'N빵',
      'members': '2/4명',
      'isFemaleOnly': true,
      'transport': '각자 이동',
      'imageUrl': 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=500&q=80'
    },
    {
      'title': '파주 대형 북카페로 드라이브 가요',
      'category': '여행/드라이브',
      'location': '파주 지혜의 숲',
      'date': '일요일 14:00',
      'host': '달리는 민우',
      'manner': 42.8,
      'price': 'N빵',
      'members': '1/3명',
      'isFemaleOnly': false,
      'transport': '호스트 차로 같이 이동',
      'imageUrl': 'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=500&q=80'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dummy Map Background
          Positioned.fill(
            child: Container(
              color: const Color(0xFFF5F5F7),
              child: CustomPaint(
                painter: _GridPainter(),
                child: Stack(
                  children: [
                    _buildMapMarker(context, 150, 100, '코노 팟'),
                    _buildMapMarker(context, 250, 200, '마라탕 팟'),
                    _buildMapMarker(context, 100, 350, '북카페 드라이브'),
                  ],
                ),
              ),
            ),
          ),
          
          // Custom AppBar
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.white.withOpacity(0.8), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, color: primaryColor, size: 18),
                            const SizedBox(width: 8),
                            const Text('마포구 서교동', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const Icon(Icons.keyboard_arrow_down, size: 18),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen())),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
                          child: Icon(Icons.tune, color: primaryColor),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Categories Tab
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        bool isSelected = _selectedCategoryIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategoryIndex = index),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: isSelected ? null : Border.all(color: Colors.grey.shade200),
                              boxShadow: isSelected ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : [],
                            ),
                            child: Row(
                              children: [
                                Text(_categories[index]['icon'], style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Text(
                                  _categories[index]['name'],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Sheet with Meetups
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.50,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 30, offset: Offset(0, -5))],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('우리 동네 취향 모임', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                        Text('12개 진행 중', style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                      itemCount: _meetups.length,
                      itemBuilder: (context, index) {
                        // Filter logic mock
                        if (_selectedCategoryIndex != 0 && _meetups[index]['category'] != _categories[_selectedCategoryIndex]['name']) {
                          return const SizedBox.shrink();
                        }
                        return _buildMeetupCard(_meetups[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildMapMarker(BuildContext context, double top, double left, String label) {
    return Positioned(
      top: top, left: left,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]),
            child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          CustomPaint(size: const Size(10, 10), painter: _TrianglePainter(color: primaryColor)),
          const SizedBox(height: 4),
          Container(width: 12, height: 4, decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(50))),
        ],
      ),
    );
  }

  Widget _buildMeetupCard(Map<String, dynamic> meetup) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OOMUDetailScreen())),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Column(
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                image: DecorationImage(image: NetworkImage(meetup['imageUrl']), fit: BoxFit.cover),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  gradient: LinearGradient(colors: [Colors.black.withOpacity(0.6), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Text(meetup['category'], style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                    if (meetup['isFemaleOnly'])
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFFF3B30), borderRadius: BorderRadius.circular(12)),
                        child: const Text('여성 전용', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meetup['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(meetup['location'], style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(meetup['date'], style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(meetup['transport'] == '각자 이동' ? Icons.directions_walk : Icons.directions_car, size: 14, color: primaryColor),
                      const SizedBox(width: 4),
                      Text(meetup['transport'], style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(radius: 12, backgroundColor: badgeGrey, child: Icon(Icons.person, size: 14, color: primaryColor)),
                          const SizedBox(width: 8),
                          Text('${meetup['host']} (${meetup['manner']}°C)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      ),
                      Text('${meetup['members']} 참여', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                    ],
                  )
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
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      onTap: (index) {
        if (index == 0) { }
        else if (index == 1) { Navigator.push(context, MaterialPageRoute(builder: (context) => const OOMUHostScreen())); }
        else if (index == 2) { Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen())); }
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

class _GridPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 40) canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    for (double i = 0; i < size.height; i += 40) canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path()..moveTo(0, 0)..lineTo(size.width, 0)..lineTo(size.width / 2, size.height)..close();
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
