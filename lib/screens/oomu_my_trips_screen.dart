import 'package:flutter/material.dart';
import 'soso_car_host_screen.dart';
import 'chat_screen.dart';
import 'soso_car_chat_screen.dart';
import 'soso_car_chat_screen.dart';
import 'oomu_review_screen.dart';

class OOMUMyTripsScreen extends StatefulWidget {
  const OOMUMyTripsScreen({super.key});

  @override
  State<OOMUMyTripsScreen> createState() => _OOMUMyTripsScreenState();
}

class _OOMUMyTripsScreenState extends State<OOMUMyTripsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color darkGreen = const Color(0xFF1B4D3E);
  final Color background = const Color(0xFFF7F7F7);
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 140,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: [
              const Icon(Icons.directions_car, color: Colors.black87),
              const SizedBox(width: 4),
              const Text('소소카', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black87, fontSize: 16)),
            ],
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('마포구 연남동', style: TextStyle(fontSize: 13, color: Colors.black87)),
              const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54)
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 20),
            child: CircleAvatar(radius: 14, backgroundColor: Color(0xFF1B4D3E), child: Icon(Icons.person, size: 16, color: Colors.white)),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('내 여행', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                      child: Text('총 5회 동행', style: TextStyle(fontSize: 12, color: darkGreen, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                      child: const Icon(Icons.tune, size: 18, color: Colors.black87),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                      child: const Icon(Icons.settings_outlined, size: 18, color: Colors.black87),
                    )
                  ],
                )
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.black87,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
              tabs: [
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('참여 예정'), const SizedBox(width: 4), Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: darkGreen, shape: BoxShape.circle), child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 10)))] )),
                const Tab(text: '지난 여행  3'),
                const Tab(text: '내가 모집한  1'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUpcomingTab(),
                const Center(child: Text('지난 여행 내역')),
                const Center(child: Text('내가 모집한 여행 내역')),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildUpcomingTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFC04020), shape: BoxShape.circle)),
            const SizedBox(width: 8),
            const Text('다가오는 여행', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(12)),
              child: const Text('D-2 출발 임박', style: TextStyle(color: Color(0xFFC04020), fontSize: 12, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network('https://images.unsplash.com/photo-1542458428-4c9103be5296?auto=format&fit=crop&q=80&w=800', height: 160, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 12, left: 12,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: darkGreen.withOpacity(0.8), borderRadius: BorderRadius.circular(12)),
                          child: const Text('동승자 · 조수석', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
                          child: const Text('모임 예정', style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  const Positioned(
                    bottom: 16, left: 16,
                    child: Text('가평 자라섬 꽃 페스티벌 & 잣닭갈비...', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))])),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.calendar_today, size: 20, color: Colors.black54),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('11월 4일 (토) 09:00 출발', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            SizedBox(height: 4),
                            Text('당일 복귀 · 예상 왕복 4시간 30분', style: TextStyle(fontSize: 13, color: Colors.black54)),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.near_me, size: 20, color: Color(0xFFC04020)),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('합정역 8번 출구 앞 (KB국민은행)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              SizedBox(height: 4),
                              Text('마포구 집결 포인트', style: TextStyle(fontSize: 13, color: Colors.black54)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                          child: const Text('지도보기 >', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage('https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&q=80&w=200'),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('친절한 민호님', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                              child: const Text('드라이버', style: TextStyle(fontSize: 10, color: Colors.black54)),
                            )
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('볼보 XC40 · 14가 78**', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                    const Spacer(),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.thermostat, size: 14, color: Color(0xFFC04020)),
                            Text('39.2°C', style: TextStyle(color: Color(0xFFC04020), fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        SizedBox(height: 2),
                        Text('매너온도 따뜻함', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                color: Colors.grey.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.people_alt, size: 18, color: Colors.black54),
                    const SizedBox(width: 8),
                    const Text('탑승 인원 (4/4명 마감)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Row(
                      children: List.generate(4, (index) => Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Container(width: 10, height: 10, decoration: BoxDecoration(color: darkGreen, shape: BoxShape.circle)),
                      )),
                    ),
                    const SizedBox(width: 8),
                    Text('만석', style: TextStyle(fontSize: 13, color: darkGreen, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const OOMUChatScreen()));
                            },
                            icon: const Icon(Icons.chat, color: Colors.white, size: 18),
                            label: const Text('동행 단체 채팅방', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkGreen,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                          child: IconButton(icon: const Icon(Icons.share, color: Colors.black87), onPressed: (){}),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel_outlined, size: 16, color: Colors.black54),
                        SizedBox(width: 6),
                        Text('참여 취소 요청', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        SizedBox(width: 16),
                        Text('|', style: TextStyle(color: Colors.black26)),
                        SizedBox(width: 16),
                        Text('출발 24시간 전까지 페널티 없이 취소 가능', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildPastTripsSection(),
        const SizedBox(height: 32),
        _buildTrustBanner(),
      ],
    );
  }

  Widget _buildPastTripsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.history, color: Colors.black87, size: 20),
            SizedBox(width: 8),
            Text('함께한 지난 여행', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Spacer(),
            Text('최근 순', style: TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(12)),
                    child: const Text('평가 대기', style: TextStyle(color: Color(0xFFC04020), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const Text('10월 28일 (토) 종료', style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
              const SizedBox(height: 12),
              const Text('강화도 동막해변 일몰 보고 대하구이...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Row(
                children: [
                  SizedBox(
                    width: 60,
                    height: 24,
                    child: Stack(
                      children: [
                        Positioned(left: 0, child: CircleAvatar(radius: 12, backgroundImage: NetworkImage('https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&q=80&w=100'))),
                        Positioned(left: 16, child: CircleAvatar(radius: 12, backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100'))),
                        Positioned(left: 32, child: CircleAvatar(radius: 12, backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=100'))),
                      ],
                    ),
                  ),
                  Text('달리는 민우, 서...', style: TextStyle(fontSize: 13, color: Colors.black87)),
                  Spacer(),
                  Icon(Icons.check_circle, color: Color(0xFF1B4D3E), size: 16),
                  SizedBox(width: 4),
                  Text('즐거운 동행 완료', style: TextStyle(fontSize: 13, color: Color(0xFF1B4D3E), fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.volunteer_activism, color: Color(0xFFC04020), size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text('민우 드라이버님과의 여행은 어떠셨나요?\n따뜻한 피드백으로 동네 이웃 매너 온도를 올려주세요!', style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4)),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const OOMUReviewScreen(isDriveMode: true)));
                        },
                        icon: const Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.white),
                        label: const Text('운전자 매너 평가하기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC04020),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                    child: const Text('여정 완료', style: TextStyle(color: Color(0xFF1B4D3E), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const Text('10월 14일 (토) 완료', style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network('https://images.unsplash.com/photo-1544928147-79a2dbc1f389?auto=format&fit=crop&q=80&w=200', width: 64, height: 64, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('파주 헤이리마을 대형 북...', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('운전자: 책읽는 지은님 (40.1°C)', style: TextStyle(fontSize: 13, color: Colors.black87)),
                        SizedBox(height: 4),
                        Text('3명 동행 완료', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.format_quote, color: Color(0xFF1B4D3E), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('"차량도 너무 쾌적하고 지은님이 운전도 부드럽게 해주셔서 편안한 주말 보냈어요. 추천..."', style: TextStyle(fontSize: 12, color: Colors.black54, fontStyle: FontStyle.italic)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.photo_library_outlined, size: 16, color: Color(0xFF1B4D3E)),
                      SizedBox(width: 6),
                      Text('공유 앨범 보기 (14장)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      children: [
                        Text('여정 상세 보기 ', style: TextStyle(fontSize: 12, color: Colors.black87)),
                        Icon(Icons.receipt_long, size: 14, color: Colors.black54),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildTrustBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
            child: const Icon(Icons.verified_user_outlined, color: Color(0xFF1B4D3E), size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('동네 이웃 안심 약속', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 6),
                Text('소소카는 상호 존중 매너와 운전자 신원 인증을 통해 믿을 수 있는 로컬 동행 문화를 만들어갑니다.', style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 3,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: darkGreen,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      onTap: (index) {
        if (index == 0) {
          // 탐색 (메인 화면으로 이동)
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (index == 1) {
          // 모집하기
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SosoCarHostScreen()));
        } else if (index == 2) {
          // 채팅
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
        } else if (index == 3) {
          // 내 여행 (현재 화면)
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
      ],
    );
  }
}
