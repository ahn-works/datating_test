import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final Color textPrimary = const Color(0xFF111111);
  final Color textSecondary = const Color(0xFF767676);
  final Color surfaceColor = const Color(0xFFF5F5F7);
  final Color accentColor = const Color(0xFF007AFF);
  final Color destructiveColor = const Color(0xFFFF3B30);
  
  int _selectedCategoryIndex = 0;
  final List<Map<String, dynamic>> _categories = [
    {'icon': '🔥', 'name': '전체'},
    {'icon': '🎤', 'name': '코노/노래'},
    {'icon': '🍻', 'name': '술/맛집'},
    {'icon': '☕', 'name': '카페/수다'},
    {'icon': '✈️', 'name': '여행/드라이브'},
    {'icon': '🎳', 'name': '액티비티'},
  ];

  @override
  void initState() {
    super.initState();
    _seedDatabase();
  }

  Future<void> _seedDatabase() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('meetups').limit(1).get();
      if (snapshot.docs.isEmpty) {
        final dummyMeetups = [
          {
            'title': '불금엔 역시 코노! 스트레스 풀 분 🎤',
            'category': '코노/노래',
            'location': '합정역 수코인노래방',
            'date': '오늘 저녁 8시',
            'host': '고음불가',
            'manner': 38.5,
            'price': 'N빵',
            'members': '2/4',
            'isFemaleOnly': true,
            'transport': '각자 이동',
            'imageUrl': 'https://images.unsplash.com/photo-1516280440502-8618eb3090ef?w=800&q=80',
            'createdAt': FieldValue.serverTimestamp()
          },
          {
            'title': '주말 엽떡+마라탕 조지실 분',
            'category': '술/맛집',
            'location': '홍대입구역 9번 출구',
            'date': '이번주 토요일 18:00',
            'host': '매운맛킬러',
            'manner': 41.2,
            'price': 'N빵',
            'members': '2/4',
            'isFemaleOnly': true,
            'transport': '각자 이동',
            'imageUrl': 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&q=80',
            'createdAt': FieldValue.serverTimestamp()
          },
          {
            'title': '파주 대형 북카페로 드라이브 가요',
            'category': '여행/드라이브',
            'location': '파주 지혜의 숲',
            'date': '일요일 14:00',
            'host': '달리는 민우',
            'manner': 42.8,
            'price': 'N빵',
            'members': '1/3',
            'isFemaleOnly': false,
            'transport': '호스트 차로 같이 이동',
            'imageUrl': 'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=800&q=80',
            'createdAt': FieldValue.serverTimestamp()
          }
        ];
        for (var m in dummyMeetups) {
          await FirebaseFirestore.instance.collection('meetups').add(m);
        }
      }
    } catch (e) {
      debugPrint("Seed error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Dummy Map Background (Lighter and more transparent)
          Positioned.fill(
            child: Container(
              color: Colors.white,
              child: Opacity(
                opacity: 0.4,
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
          ),
          
          // Bottom Sheet with Meetups (Main Feed)
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 40, offset: const Offset(0, -10))
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFEBEBEF), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('우리 동네\n취향 모임', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textPrimary, height: 1.2)),
                        Text('12개 진행 중', style: TextStyle(fontSize: 14, color: accentColor, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('meetups').orderBy('createdAt', descending: true).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Colors.black));
                        }
                        if (snapshot.hasError) {
                          // Fallback to dummy data
                          final dummyDocs = [
                            {
                              'title': '불금엔 역시 코노! 스트레스 풀 분 🎤',
                              'category': '코노/노래',
                              'location': '합정역 수코인노래방',
                              'date': '오늘 저녁 8시',
                              'host': '고음불가',
                              'manner': 38.5,
                              'price': 'N빵',
                              'members': '2/4',
                              'isFemaleOnly': true,
                              'transport': '각자 이동',
                              'imageUrl': 'https://images.unsplash.com/photo-1516280440502-8618eb3090ef?w=800&q=80',
                            },
                            {
                              'title': '주말 엽떡+마라탕 조지실 분',
                              'category': '술/맛집',
                              'location': '홍대입구역 9번 출구',
                              'date': '이번주 토요일 18:00',
                              'host': '매운맛킬러',
                              'manner': 41.2,
                              'price': 'N빵',
                              'members': '2/4',
                              'isFemaleOnly': true,
                              'transport': '각자 이동',
                              'imageUrl': 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&q=80',
                            }
                          ];
                          
                          final filteredDummy = dummyDocs.where((doc) {
                            if (_selectedCategoryIndex == 0) return true;
                            return doc['category'] == _categories[_selectedCategoryIndex]['name'];
                          }).toList();
                          
                          if (filteredDummy.isEmpty) {
                            return const Center(child: Text("선택한 카테고리의 모임이 없습니다.", style: TextStyle(color: Colors.grey)));
                          }
                          
                          return ListView.builder(
                            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 4),
                            itemCount: filteredDummy.length,
                            itemBuilder: (context, index) {
                              return _buildMeetupCard(filteredDummy[index]);
                            },
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("아직 등록된 모임이 없습니다.", style: TextStyle(color: Colors.grey)));
                        }
                        
                        final docs = snapshot.data!.docs;
                        final filteredDocs = docs.where((doc) {
                          if (_selectedCategoryIndex == 0) return true;
                          var data = doc.data() as Map<String, dynamic>;
                          return data['category'] == _categories[_selectedCategoryIndex]['name'];
                        }).toList();

                        if (filteredDocs.isEmpty) {
                          return const Center(child: Text("선택한 카테고리의 모임이 없습니다.", style: TextStyle(color: Colors.grey)));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 4),
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, index) {
                            var data = filteredDocs[index].data() as Map<String, dynamic>;
                            return _buildMeetupCard(data);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Custom AppBar (Glassmorphism Sticky Header)
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text('마포구 서교동', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: textPrimary)),
                          const SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down, size: 24, color: textPrimary),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen())),
                        child: Container(
                          width: 40, height: 40,
                          decoration: const BoxDecoration(color: Color(0xFFF5F5F7), shape: BoxShape.circle),
                          child: Icon(Icons.tune, color: textPrimary, size: 20),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Categories Tab
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        bool isSelected = _selectedCategoryIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategoryIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? textPrimary : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? textPrimary : const Color(0xFFEBEBEF)),
                              boxShadow: isSelected ? [BoxShadow(color: textPrimary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_categories[index]['icon'], style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Text(
                                  _categories[index]['name'],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : textSecondary,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    fontSize: 14,
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))]
            ),
            child: Text(label, style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          CustomPaint(size: const Size(12, 8), painter: _TrianglePainter(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildMeetupCard(Map<String, dynamic> meetup) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OOMUDetailScreen(meetup: meetup))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFEBEBEF)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))]
        ),
        child: Column(
          children: [
            Container(
              height: 180, // Taller image for magazine feel
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                image: DecorationImage(image: NetworkImage(meetup['imageUrl']), fit: BoxFit.cover),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      gradient: LinearGradient(colors: [Colors.black.withOpacity(0.5), Colors.transparent], begin: Alignment.topCenter, end: Alignment.center),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(8)),
                          child: Text(meetup['category'], style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        if (meetup['isFemaleOnly'])
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: destructiveColor, borderRadius: BorderRadius.circular(8)),
                            child: const Text('여성 전용', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meetup['title'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: textSecondary),
                      const SizedBox(width: 4),
                      Text(meetup['location'], style: TextStyle(fontSize: 13, color: textSecondary)),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 16, color: textSecondary),
                      const SizedBox(width: 4),
                      Text(meetup['date'], style: TextStyle(fontSize: 13, color: textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(height: 1, color: surfaceColor),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(radius: 12, backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=11')),
                          const SizedBox(width: 8),
                          Text(meetup['host'], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
                          const SizedBox(width: 4),
                          Icon(Icons.local_fire_department, size: 14, color: destructiveColor),
                          Text('${meetup['manner']}°C', style: TextStyle(fontSize: 12, color: textSecondary)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(8)),
                        child: Text('${meetup['members']} 참여', style: TextStyle(fontSize: 12, color: textPrimary, fontWeight: FontWeight.bold)),
                      )
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
      selectedItemColor: textPrimary,
      unselectedItemColor: const Color(0xFFC7C7CC),
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      elevation: 20,
      backgroundColor: Colors.white,
      onTap: (index) {
        if (index == 0) { }
        else if (index == 1) { Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => const OOMUHostScreen(), transitionDuration: Duration.zero)); }
        else if (index == 2) { Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => const ChatScreen(), transitionDuration: Duration.zero)); }
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

class _GridPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFF0F0F0)..strokeWidth = 1;
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
