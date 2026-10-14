import 'package:flutter/material.dart';
import '../utils/app_image.dart';
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
  final Color accentColor = const Color(0xFFF19E39);
  final Color destructiveColor = const Color(0xFFFF3B30);
  
  String _currentLocation = '마포구 서교동';
  final List<String> _neighborhoods = const [
    '마포구 서교동', '마포구 연남동', '마포구 망원동', '마포구 합정동',
    '성동구 성수동', '용산구 한남동', '강남구 신사동', '중구 을지로',
  ];

  void _showLocationPickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFEBEBEF), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('우리 동네 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: _neighborhoods.map((n) {
                  final selected = n == _currentLocation;
                  return ListTile(
                    leading: Icon(Icons.location_on, color: selected ? accentColor : textSecondary),
                    title: Text(n, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.w500, color: selected ? accentColor : textPrimary)),
                    trailing: selected ? Icon(Icons.check_circle, color: accentColor) : null,
                    onTap: () {
                      setState(() => _currentLocation = n);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('📍 $n(으)로 동네를 변경했어요')));
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

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
            'imageUrl': 'assets/images/cover_wine.jpg',
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
            'imageUrl': 'assets/images/cover_food.jpg',
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
            'imageUrl': 'assets/images/cover_cafe.jpg',
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

  Widget _buildVibeCard(String emoji, String title, String subtitle, Color bgColor) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title 모임을 찾아볼게요!')));
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111111))),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF767676), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _showLocationPickerBottomSheet,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_currentLocation, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: textPrimary)),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 24, color: textPrimary),
            ],
          ),
        ),
                actions: [
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('🔔 FCM 알림: [방장] 참여 승인이 완료되었습니다!'),
                backgroundColor: Color(0xFFF19E39),
                duration: Duration(seconds: 3),
              ));
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              width: 40, height: 40,
              decoration: const BoxDecoration(color: Color(0xFFF5F5F7), shape: BoxShape.circle),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.notifications_outlined, color: Color(0xFF111111), size: 22),
                  Positioned(
                    top: 10, right: 10,
                    child: CircleAvatar(radius: 3.5, backgroundColor: Colors.redAccent),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen())),
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              width: 40, height: 40,
              decoration: const BoxDecoration(color: Color(0xFFF5F5F7), shape: BoxShape.circle),
              child: Icon(Icons.tune, color: textPrimary, size: 20),
            ),
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 1. Categories Tab (Horizontal Scroll)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 24, left: 24),
              child: SizedBox(
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
                          color: isSelected ? accentColor : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? accentColor : const Color(0xFFEBEBEF)),
                          boxShadow: isSelected ? [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
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
            ),
          ),
          
          // 2. 지금 내 상황 (My Current Situation)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('지금 내 상황', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary)),
                      Text('전체 보기', style: TextStyle(fontSize: 14, color: textSecondary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildVibeCard('⚡', '놀줄아는', '핫플·페스티벌', const Color(0xFFFFF4E6)),
                      const SizedBox(width: 12),
                      _buildVibeCard('☕', '소소하게', '카페·산책', const Color(0xFFF3F4F6)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildVibeCard('🍔', '메이트', '맛집·배달', const Color(0xFFFCE8E6)),
                      const SizedBox(width: 12),
                      _buildVibeCard('💖', '소개팅', '취향 기반', const Color(0xFFFCE4EC)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // 3. 우리 동네 취향 모임 Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('우리 동네\n취향 모임', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary, height: 1.2)),
                  Text('12개 진행 중', style: TextStyle(fontSize: 14, color: accentColor, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          
                    // 4. StreamBuilder (List of Meetups) - with Fallback
          SliverToBoxAdapter(
            child: _getMeetupStream() == null
              ? _buildDummyMeetups()
              : StreamBuilder<QuerySnapshot>(
                  stream: _getMeetupStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: Colors.black)));
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildDummyMeetups(); // 데이터가 없거나 에러나면 더미 보여주기
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var doc = snapshot.data!.docs[index];
                        var data = doc.data() as Map<String, dynamic>;
                        data['id'] = doc.id;
                        return _buildMeetupCard(data);
                      },
                    );
                  },
                ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
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
                image: DecorationImage(image: appImg(meetup['imageUrl'] ?? 'assets/images/cover_food.jpg'), fit: BoxFit.cover),
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
                          child: Text(meetup['category'] ?? '모임', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        if (meetup['isFemaleOnly'] == true)
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
                  Text(meetup['title'] ?? '취향 모임', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: textSecondary),
                      const SizedBox(width: 4),
                      Text(meetup['location'] ?? '위치 협의', style: TextStyle(fontSize: 13, color: textSecondary)),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 16, color: textSecondary),
                      const SizedBox(width: 4),
                      Text(meetup['date'] ?? '일정 협의', style: TextStyle(fontSize: 13, color: textSecondary)),
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
                          CircleAvatar(
                            radius: 12, 
                            backgroundImage: appImg(
                              meetup['hostAvatar'] ?? 
                              (meetup['isFemaleOnly'] == true 
                                ? 'assets/images/kr_female_1.jpg'
                                : 'assets/images/kr_male_1.jpg')
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(meetup['host'] ?? '호스트', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
                          const SizedBox(width: 4),
                          Icon(Icons.local_fire_department, size: 14, color: destructiveColor),
                          Text('${meetup['manner'] ?? 36.5}°C', style: TextStyle(fontSize: 12, color: textSecondary)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(8)),
                        child: Text('${meetup['members'] ?? '1/4'} 참여', style: TextStyle(fontSize: 12, color: textPrimary, fontWeight: FontWeight.bold)),
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

  Widget _buildDummyMeetups() {
    final List<Map<String, dynamic>> dummyData = [
      {
        'id': 'dummy_meetup_01',
        'title': '주말 엽떡+마라탕 조지실 분 🔥',
        'category': '술/맛집',
        'location': '마포구 홍대입구역 9번 출구',
        'date': '이번주 토요일 18:00',
        'imageUrl': 'assets/images/cover_food.jpg',
        'isFemaleOnly': true,
        'host': '매운맛킬러',
        'hostAvatar': 'assets/images/kr_female_1.jpg',
        'manner': 41.2,
        'members': '2/4',
        'price': 'N빵',
        'transport': '각자 이동',
        'schedule': '1차 엽떡+마라탕 먹방 ➔ 2차 인생네컷 & 보드게임 카페',
        'tags': ['소셜다이닝', '매운맛', '홍대맛집', '동네찐친'],
        'photos': [
          'assets/images/cover_food.jpg',
          'assets/images/cover_food.jpg',
          'assets/images/cover_cafe.jpg',
        ],
      },
      {
        'id': 'dummy_meetup_02',
        'title': '성수동 감성 카페 & 디저트 투어 ☕',
        'category': '카페/수다',
        'location': '성동구 성수동 카페거리',
        'date': '이번주 일요일 오후 2:00',
        'imageUrl': 'assets/images/cover_cafe.jpg',
        'isFemaleOnly': false,
        'host': '성수동힙스터',
        'hostAvatar': 'assets/images/kr_female_2.jpg',
        'manner': 38.5,
        'members': '2/4',
        'price': '각자 결제',
        'transport': '성수역 3번출구 집결',
        'schedule': '힙한 신상 에스프레소 바 ➔ 베이커리 팝업 스토어 탐방',
        'tags': ['소소하게', '성수카페', '디저트', '주말여유'],
        'photos': [
          'assets/images/cover_cafe.jpg',
          'assets/images/cover_cafe.jpg',
        ],
      },
      {
        'id': 'dummy_meetup_03',
        'title': '연남동 내추럴 와인바 소셜 다이닝 🍷',
        'category': '술/맛집',
        'location': '마포구 연남동 미로길',
        'date': '금요일 저녁 7:30',
        'imageUrl': 'assets/images/cover_wine.jpg',
        'isFemaleOnly': false,
        'host': '와인앤모어',
        'hostAvatar': 'assets/images/kr_male_1.jpg',
        'manner': 42.0,
        'members': '3/4',
        'price': '1/N 분담',
        'transport': '홍대입구역 3번출구 도보',
        'schedule': '내추럴 와인 2병 페어링 & 소소한 금요일 밤 이야기',
        'tags': ['놀줄아는', '와인바', '연남동', '소셜다이닝'],
        'photos': [
          'assets/images/cover_wine.jpg',
          'assets/images/cover_food.jpg',
        ],
      },
      {
        'id': 'dummy_meetup_04',
        'title': '망원 한강공원 야경 러닝 5km 🏃‍♀️',
        'category': '액티비티',
        'location': '마포구 망원 한강공원 입구',
        'date': '목요일 저녁 8:00',
        'imageUrl': 'assets/images/cover_running.jpg',
        'isFemaleOnly': false,
        'host': '러닝크루장',
        'hostAvatar': 'assets/images/kr_male_3.jpg',
        'manner': 39.8,
        'members': '4/6',
        'price': '무료',
        'transport': '망원역 집결',
        'schedule': '스트레칭 10분 ➔ 6분 페이스 5km 러닝 ➔ 이온음료 쿨다운',
        'tags': ['메이트', '러닝', '한강야경', '오운완'],
        'photos': [
          'assets/images/cover_running.jpg',
          'assets/images/cover_running.jpg',
        ],
      },
    ];
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dummyData.length,
      itemBuilder: (context, index) {
        return _buildMeetupCard(dummyData[index]);
      },
    );
  }

  Stream<QuerySnapshot>? _getMeetupStream() {
    try {
      return FirebaseFirestore.instance.collection('meetups').orderBy('createdAt', descending: true).limit(20).snapshots();
    } catch (e) {
      return null;
    }
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
      backgroundColor: const Color(0xFFF7F8FA),
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
