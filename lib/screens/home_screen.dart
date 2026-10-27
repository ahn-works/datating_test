import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'local_friends_screen.dart';
import 'driver_profile_modal.dart';
import 'party_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // Now in Android 에디토리얼 큐레이션 배너 (30대 취향·아지트 중심)
  final List<Map<String, String>> _banners = [
    {
      'tag': '☕ 이번 주말 아지트',
      'title': '성수동 에스프레소 바 & 북토크',
      'sub': '퇴근길 가볍게 들르는 연남·성수 동네 친구',
      'bgColor': '0xFFFF6B4A',
    },
    {
      'tag': '🏃‍♂️ 라이프 메이트',
      'title': '달빛 한강 러닝 5K 크루',
      'sub': '초보도 부담 없이! 페이스 630 함께 달려요',
      'bgColor': '0xFF0F172A',
    },
    {
      'tag': '🛡️ 100% 여성 안심',
      'title': '동네 취향 기반 안심 소모임',
      'sub': '호스트 승인제와 1/N 투명 정산 시스템',
      'bgColor': '0xFFE11D48',
    },
  ];

  // 추천 동네 메이트 데이터 (Now in Android Card Anatomy 규격)
  final List<Map<String, dynamic>> _recommendedMembers = [
    {
      'name': '민우',
      'location': '서울 마포구 연남동',
      'tag': '☕ 카페투어 · 책',
      'mannerTemp': '41.5°C',
      'img': 'https://picsum.photos/300/400?random=101',
    },
    {
      'name': '서연',
      'location': '서울 성동구 성수동',
      'tag': '🎨 전시회 · LP바',
      'mannerTemp': '39.8°C',
      'img': 'https://picsum.photos/300/400?random=102',
    },
    {
      'name': '준호',
      'location': '서울 송파구 잠실동',
      'tag': '🏃‍♂️ 러닝 · 테니스',
      'mannerTemp': '42.0°C',
      'img': 'https://picsum.photos/300/400?random=103',
    },
    {
      'name': '지은',
      'location': '서울 용산구 한남동',
      'tag': '🍷 와인 · 드라이브',
      'mannerTemp': '38.5°C',
      'img': 'https://picsum.photos/300/400?random=104',
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        _currentPage = (_currentPage + 1) % _banners.length;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F7), // OOMU 오트밀 로즈 크림
      appBar: AppBar(
        title: const Text(
          '우무 (OOMU)',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF0F172A), size: 26),
            tooltip: '알림',
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
        children: [
          // 1. Now in Android 슬림 큐레이션 배너
          SizedBox(
            height: 130,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _banners.length,
              itemBuilder: (ctx, i) {
                final b = _banners[i];
                final bgColor = Color(int.parse(b['bgColor']!));
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: bgColor.withOpacity(0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          b['tag']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        b['title']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        b['sub']!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // 슬림 필 도트 인디케이터 (Shadcn-Mobile & Now in Android 규격)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_banners.length, (i) {
              final isCurrent = _currentPage == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isCurrent ? 22 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isCurrent ? const Color(0xFFFF6B4A) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // 2. 추천 동네 메이트 섹션 (Card Anatomy & Image State Handling)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '동네 메이트 추천',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '취향이 비슷하고 매너온도가 높은 이웃',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalFriendsScreen()));
                },
                child: const Row(
                  children: [
                    Text('전체보기', style: TextStyle(color: Color(0xFFFF6B4A), fontWeight: FontWeight.w700, fontSize: 13)),
                    Icon(Icons.chevron_right_rounded, color: Color(0xFFFF6B4A), size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 230,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _recommendedMembers.length,
              itemBuilder: (ctx, i) {
                final m = _recommendedMembers[i];
                return _memberCard(
                  context: ctx,
                  name: m['name'] as String,
                  location: m['location'] as String,
                  tag: m['tag'] as String,
                  mannerTemp: m['mannerTemp'] as String,
                  imgUrl: m['img'] as String,
                );
              },
            ),
          ),
          const SizedBox(height: 28),

          // 3. 주요 기능 바로가기 (48dp Touch Target & Button Anatomy)
          const Text(
            '주요 모임 서비스',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 14),

          _featureCard(
            icon: Icons.groups_rounded,
            title: '동네 모임 & 번개 찾기',
            sub: '주말 서핑, 에스프레소 바, 반포 러닝 크루',
            accentColor: const Color(0xFFFF6B4A),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PartyScreen()));
            },
          ),
          const SizedBox(height: 12),

          _featureCard(
            icon: Icons.forum_rounded,
            title: '우리 동네 찐친 아지트',
            sub: '카공, 산책, 밥친구 등 부담 없는 동네 일상 친구',
            accentColor: const Color(0xFF0F172A),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalFriendsScreen()));
            },
          ),
        ],
      ),
    );
  }

  // Now in Android 카드 아나토미 및 이미지 상태 처리 (Shimmer/Fallback Container)
  Widget _memberCard({
    required BuildContext context,
    required String name,
    required String location,
    required String tag,
    required String mannerTemp,
    required String imgUrl,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showDriverProfileModal(context);
      },
      child: Container(
        width: 154,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEFF1F5), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 이미지 상태 처리: errorBuilder 및 로딩 배경
              Image.network(
                imgUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFF1F5F9),
                  child: const Center(
                    child: Icon(Icons.person_rounded, size: 40, color: Color(0xFF94A3B8)),
                  ),
                ),
              ),

              // 하단 텍스트 가독성을 위한 그라데이션
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.85),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.3, 0.6, 1.0],
                  ),
                ),
              ),

              // 상단 매너온도 뱃지
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    mannerTemp,
                    style: const TextStyle(
                      color: Color(0xFFFF9E80),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              // 하단 인적 정보 (Now in Android 정보 위계)
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: Colors.white70, size: 11),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tag,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFFFE0D0),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Now in Android 표준 버튼/카드 패딩 (최소 48dp 터치 타깃 준수)
  Widget _featureCard({
    required IconData icon,
    required String title,
    required String sub,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEFF1F5), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        sub,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
