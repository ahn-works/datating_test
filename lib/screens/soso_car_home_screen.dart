import 'package:flutter/material.dart';
import 'oomu_my_trips_screen.dart';
import 'package:kpostal/kpostal.dart';
import 'soso_car_host_screen.dart';
import 'soso_car_detail_screen.dart';

class OOMUHomeScreen extends StatefulWidget {
  const OOMUHomeScreen({super.key});

  @override
  State<OOMUHomeScreen> createState() => _OOMUHomeScreenState();
}

class _OOMUHomeScreenState extends State<OOMUHomeScreen> {
  final Color darkGreen = const Color(0xFF1B4D3E);
  final Color badgeGreen = const Color(0xFFA5D6A7);
  final Color terracotta = const Color(0xFFC04020);
  
  String _currentLocation = '마포구 연남동';

  final List<Map<String, dynamic>> _trips = [
    {
      'title': '강릉 경포대 당일치기 드라이브 팟',
      'location': '강원 강릉시',
      'distance': '210km',
      'tags': ['#당일치기', '#드라이브', '#맛집탐방', '#바다뷰'],
      'driverName': '차주 민우',
      'driverCar': '기아 EV6 Long Range',
      'scheduleTime': '10월 28일 (토) 오전 09:30',
      'scheduleLoc': '마포구청역 1번출구 지상 버스베이',
      'reserved': 2,
      'total': 4,
      'price': '9,000',
      'image': 'https://picsum.photos/600/300?random=1',
      'badge': '여유자리'
    },
    {
      'title': '양평 두물머리 가을 출사 가실분',
      'location': '경기 양평군',
      'distance': '45km',
      'tags': ['#사진촬영', '#카페투어', '#가을단풍'],
      'driverName': '사진러 지훈',
      'driverCar': '현대 싼타페 하이브리드',
      'scheduleTime': '10월 29일 (일) 오전 10:00',
      'scheduleLoc': '홍대입구역 3번출구 픽업존',
      'reserved': 3,
      'total': 5,
      'price': '4,500',
      'image': 'https://picsum.photos/600/300?random=2',
      'badge': '마감임박'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            _buildTripList(),
            _buildSafetyBanner(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTrip = await Navigator.push(context, MaterialPageRoute(builder: (context) => const OOMUHostScreen()));
          if (newTrip != null && newTrip is Map<String, dynamic>) {
            setState(() {
              newTrip['distance'] = '측정불가';
              newTrip['reserved'] = 1;
              newTrip['total'] = 4;
              newTrip['driverCar'] = '내 차 정보 없음';
              newTrip['scheduleTime'] = newTrip['time'] ?? '시간 미정';
              newTrip['scheduleLoc'] = '집결 장소 미정';
              _trips.insert(0, newTrip);
            });
          }
        },
        backgroundColor: darkGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: GestureDetector(
        onTap: () async {
          try {
            Kpostal? result = await Navigator.push(context, MaterialPageRoute(builder: (_) => KpostalView()));
            if (result != null) {
              setState(() {
                _currentLocation = result.address;
              });
            }
          } catch (e) {
            print("Kpostal error: \$e");
          }
        },
        child: Row(
          children: [
            Text(_currentLocation, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
          ],
        ),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.search, color: Colors.black87), onPressed: (){}),
        IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black87), onPressed: (){}),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('우리 동네 이웃과 함께하는\n새로운 만남은 어때요?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.4, letterSpacing: -0.5)),
          const SizedBox(height: 24),
          const Text('🚙 우무 드라이브 메이트', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('당일치기', true),
                const SizedBox(width: 8),
                _buildFilterChip('자연풍경', false),
                const SizedBox(width: 8),
                _buildFilterChip('드라이브', false),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('👫 동네 친구 만들기', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('동네 산책', false),
                const SizedBox(width: 8),
                _buildFilterChip('밥친구', false),
                const SizedBox(width: 8),
                _buildFilterChip('카공', false),
                const SizedBox(width: 8),
                _buildFilterChip('러닝', false),
                const SizedBox(width: 8),
                _buildFilterChip('급벙', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? darkGreen : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? darkGreen : Colors.grey.shade300),
      ),
      child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildTripList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _trips.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const OOMUDetailScreen()));
          },
          child: _buildTripCard(_trips[index], index == 0 ? 21 : 18),
        );
      },
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip, int temp) {
    int reserved = trip['reserved'];
    int total = trip['total'];
    String price = trip['price'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.black.withOpacity(0.04))
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Stack(
              children: [
                Image.network(trip['image'], height: 180, width: double.infinity, fit: BoxFit.cover),
                Positioned(
                  top: 12, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: badgeGreen, borderRadius: BorderRadius.circular(20)),
                    child: Text(trip['badge'], style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                Positioned(
                  bottom: 12, right: 12,
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(trip['location'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, shadows: [Shadow(color: Colors.black87, blurRadius: 4)])),
                      const SizedBox(width: 8),
                      Text(trip['distance'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, shadows: [Shadow(color: Colors.black87, blurRadius: 4)])),
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  Row(children: (trip['tags'] as List).map<Widget>((t) => Container(margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)), child: Text(t, style: TextStyle(color: Colors.grey.shade700, fontSize: 11, fontWeight: FontWeight.bold)))).toList()),
                  
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.black54), const SizedBox(width: 8),
                          Expanded(child: Text(trip['scheduleTime'], style: const TextStyle(fontSize: 12, color: Colors.black87)))
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.near_me, size: 14, color: Color(0xFFC04020)), const SizedBox(width: 8),
                          Expanded(child: Text(trip['scheduleLoc'], style: const TextStyle(fontSize: 12, color: Colors.black87)))
                        ]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
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
                                Text(trip['driverName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(width: 6),
                                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: badgeGreen, borderRadius: BorderRadius.circular(10)), child: Text('인증이웃', style: TextStyle(color: darkGreen, fontSize: 10, fontWeight: FontWeight.bold))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(trip['driverCar'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(temp.toString() + '°C 🌡️', style: const TextStyle(color: Color(0xFFC04020), fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Container(
                            width: 60, height: 4,
                            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(2)),
                            child: Row(children: [Container(width: (temp/100)*60, height: 4, decoration: BoxDecoration(color: const Color(0xFFC04020), borderRadius: BorderRadius.circular(2)))]),
                          )
                        ],
                      )
                    ],
                  ),

                  const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('탑승 인원 (' + reserved.toString() + '/' + total.toString() + '명 예약)', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                          const SizedBox(height: 6),
                          Row(
                            children: List.generate(total, (index) {
                              bool isReserved = index < reserved;
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
                      const SizedBox(),
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
                Text('우무(OOMU) 안전 운행 약속', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 6),
                Text('동네 이웃 인증, 운전면허 & 자동차보험 검증이 완료된 차주만 모집글을 등록할 수 있습니다.', style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: darkGreen,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: '탐색'),
        const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: '만들기'),
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
        const         BottomNavigationBarItem(
          icon: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const OOMUMyTripsScreen()));
            },
            child: const Icon(Icons.directions_car_outlined)
          ),
          activeIcon: const Icon(Icons.directions_car),
          label: '내 여행',
        ), label: '내 차'),
      ],
    );
  }
}
