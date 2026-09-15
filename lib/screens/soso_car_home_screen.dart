import 'package:flutter/material.dart';
import 'soso_car_detail_screen.dart';
import 'soso_car_host_screen.dart';
import 'soso_car_chat_screen.dart';

class SosoCarHomeScreen extends StatefulWidget {
  const SosoCarHomeScreen({super.key});

  @override
  State<SosoCarHomeScreen> createState() => _SosoCarHomeScreenState();
}

class _SosoCarHomeScreenState extends State<SosoCarHomeScreen> {
  final Color darkGreen = const Color(0xFF1B4D3E); // 소소카 딥그린
  final Color badgeGreen = const Color(0xFFA5D6A7); // 인증이웃 뱃지 그린
  final Color terracotta = const Color(0xFFC04020);
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F7), // 스크린샷의 따뜻한 배경색
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainBanner(),
            _buildSearchBar(context),
            _buildFilterChips(),
            _buildListHeader(),
            _buildTripCard(
              context: context,
              image: 'https://picsum.photos/600/300?random=30',
              badge: '🔥 마감임박 1자리!',
              timeBadge: '토요일 당일',
              location: '강화도 동막해변',
              distance: '편도 약 1시간 20분',
              title: '강화도 동막해변 일몰 보고 대하구이 먹...',
              tags: ['#노을맛집', '#수다환영', '#플리공유'],
              scheduleTime: '이번 주 토요일 14:00 출발 - 21:00 연남 도착 예정',
              scheduleLoc: '집결지: 홍대입구역 3번 출구 앞',
              driverName: '달리는 민우',
              driverCar: '볼보 XC40 - 비흡연 - 클래식음악',
              driverTemp: 38.5,
              reservedSeats: 3,
              totalSeats: 4,
              price: '18,000',
            ),
            _buildTripCard(
              context: context,
              image: 'https://picsum.photos/600/300?random=31',
              badge: '일요일 낮',
              timeBadge: '조용한 힐링',
              location: '파주 헤이리 예술마을',
              distance: '편도 약 45분',
              title: '파주 헤이리마을 대형 북카페 책 읽고 ...',
              tags: ['#조용한힐링', '#커피한잔', '#자유시간'],
              scheduleTime: '이번 주 일요일 10:30 출발 - 17:30 복귀',
              scheduleLoc: '집결지: 연남파출소 앞 미팅',
              driverName: '책읽는 지훈',
              driverCar: '쏘렌토 하이브리드 - 안전운전 5년차',
              driverTemp: 41.2,
              reservedSeats: 2,
              totalSeats: 4,
              price: '12,000',
            ),
            _buildTripCard(
              context: context,
              image: 'https://picsum.photos/600/300?random=32',
              badge: '토요일 아침',
              timeBadge: '연핫도그 투어 🌭',
              location: '양평 두물머리',
              distance: '편도 약 55분',
              title: '양평 두물머리 연핫도그 & 물안개 아...',
              tags: ['#물안개산책', '#소규모3인', '#쾌적드라이브'],
              scheduleTime: '이번 주 토요일 07:00 출발 - 12:30 복귀 (오전순삭)',
              scheduleLoc: '집결지: 가좌역 1번 출구',
              driverName: '얼리버드 진호',
              driverCar: '아이오닉 5 전기차 - 무사고',
              driverTemp: 39.1,
              reservedSeats: 2,
              totalSeats: 3,
              price: '15,000',
            ),
            _buildSafetyBanner(),
            const SizedBox(height: 80), // 하단 FAB 공간
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SosoCarHostScreen())),
        backgroundColor: const Color(0xFFB53D25),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('번개 드라이브 열기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (i) => setState(() => _bottomNavIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: darkGreen,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
            label: '동행채팅',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.directions_car_outlined), activeIcon: Icon(Icons.directions_car), label: '내여행'),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF9F9F7),
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.directions_car, color: darkGreen),
          const SizedBox(width: 8),
          const Text('소소카', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 20)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                Text('마포구 연남동', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, color: Colors.black87, size: 16),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black87), onPressed: (){}),
            Positioned(top: 12, right: 12, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)))
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(radius: 16, backgroundColor: darkGreen, child: const Icon(Icons.emoji_people, color: Colors.white, size: 18)),
        )
      ],
    );
  }

  Widget _buildMainBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF1F6EC), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: badgeGreen, borderRadius: BorderRadius.circular(12)),
                  child: Text('🏠 마포 이웃 전용 소모임', style: TextStyle(color: darkGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                const Text('연남동 이웃과 떠나는\n소소한 주말 로드트립', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, height: 1.3)),
                const SizedBox(height: 8),
                const Text('가까운 3~4명과 유류비 나누며 가볍게 훌\n쩍 다녀와요.', style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
          const Icon(Icons.wb_sunny, color: Color(0xFFC85A32), size: 48),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('위치 검색 모달 오픈!')));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.black54),
              const SizedBox(width: 12),
              Expanded(child: Text('어디로 떠날까요? (강화도, 헤이리, 바다)', style: TextStyle(color: Colors.grey.shade500, fontSize: 14))),
              const Icon(Icons.tune, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          _buildChip('전체', true),
          _buildChip('당일치기 ☕', false),
          _buildChip('노을 드라이브 🌅', false),
          _buildChip('주말 🚗', false),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? darkGreen : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? darkGreen : Colors.grey.shade300),
      ),
      child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 13)),
    );
  }

  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('이번 주말 출발 모집 ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFC04020), shape: BoxShape.circle)),
            ],
          ),
          Text('출발 임박순', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildTripCard({
    required BuildContext context,
    required String image, required String badge, required String timeBadge, required String location, required String distance,
    required String title, required List<String> tags,
    required String scheduleTime, required String scheduleLoc,
    required String driverName, required String driverCar, required double driverTemp,
    required int reservedSeats, required int totalSeats, required String price,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SosoCarDetailScreen())),
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            // 이미지 영역
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(image, height: 160, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 12, left: 12,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: badge.contains('마감') ? const Color(0xFFB53D25) : (badge.contains('일요일') ? const Color(0xFF90CAF9) : Colors.white), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            if (badge.contains('마감')) const Icon(Icons.local_fire_department, color: Colors.white, size: 12),
                            if (badge.contains('마감')) const SizedBox(width: 4),
                            Text(badge, style: TextStyle(color: badge.contains('마감') ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 11)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Text(timeBadge, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 12, right: 12,
                  child: CircleAvatar(backgroundColor: Colors.white, radius: 14, child: const Icon(Icons.favorite_border, color: Colors.black87, size: 16)),
                ),
                Positioned(
                  bottom: 12, left: 12, right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [const Icon(Icons.location_on, color: Color(0xFFC04020), size: 14), const SizedBox(width: 4), Text(location, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, shadows: [Shadow(color: Colors.black87, blurRadius: 4)]))]),
                      Text(distance, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, shadows: [Shadow(color: Colors.black87, blurRadius: 4)])),
                    ],
                  ),
                )
              ],
            ),
            // 하단 정보 영역
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Row(children: tags.map((t) => Container(margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)), child: Text(t, style: TextStyle(color: Colors.grey.shade700, fontSize: 11, fontWeight: FontWeight.bold)))).toList()),
                  
                  const SizedBox(height: 16),
                  // 일정 박스
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.black54), const SizedBox(width: 8),
                          Expanded(child: Text(scheduleTime, style: const TextStyle(fontSize: 12, color: Colors.black87)))
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.near_me, size: 14, color: Color(0xFFC04020)), const SizedBox(width: 8),
                          Expanded(child: Text(scheduleLoc, style: const TextStyle(fontSize: 12, color: Colors.black87)))
                        ]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  // 운전자 정보
                  Row(
                    children: [
                      const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=11')),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(driverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(width: 6),
                                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: badgeGreen, borderRadius: BorderRadius.circular(10)), child: Text('인증이웃', style: TextStyle(color: darkGreen, fontSize: 10, fontWeight: FontWeight.bold))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(driverCar, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\°C 🟡', style: const TextStyle(color: Color(0xFFC04020), fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Container(
                            width: 60, height: 4,
                            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(2)),
                            child: Row(children: [Container(width: (driverTemp/100)*60, height: 4, decoration: BoxDecoration(color: const Color(0xFFC04020), borderRadius: BorderRadius.circular(2)))]),
                          )
                        ],
                      )
                    ],
                  ),

                  const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
                  
                  // 탑승 인원 및 정산
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('탑승 인원 (\/\ 예약됨)', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                          const SizedBox(height: 6),
                          Row(
                            children: List.generate(totalSeats, (index) {
                              bool isReserved = index < reservedSeats;
                              return Container(
                                margin: const EdgeInsets.only(right: 4),
                                width: 24, height: 24,
                                decoration: BoxDecoration(color: isReserved ? darkGreen : Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
                                child: Icon(isReserved ? Icons.person : Icons.add, color: isReserved ? Colors.white : Colors.grey, size: 14),
                              );
                            }),
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('예상 1인 합산금', style: TextStyle(fontSize: 11, color: Colors.black54)),
                          const SizedBox(height: 4),
                          Text('', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: (){},
                        style: ElevatedButton.styleFrom(backgroundColor: darkGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                        child: const Text('동행 신청', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF9F9F7), borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: badgeGreen, shape: BoxShape.circle), child: Icon(Icons.shield_outlined, color: darkGreen, size: 20)),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('소소카 안전 동행 약속', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 6),
                Text('동네 이웃 인증, 운전면허 및 자동차보험 검증이 완료된 차주만 모집글을 등록할 수 있습니다.', style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
