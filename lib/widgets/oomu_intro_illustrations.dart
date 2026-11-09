import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_image.dart';

/// OOMU 앱 스플래시 및 인트로 온보딩 전용 실제 모임 UI 쇼케이스 위젯
/// PPT 스타일의 평면 도형/스틱맨 일러스트나 겹치는 말풍선 배지를 완전히 배제하고,
/// 실제 앱에서 동작하는 모임 카드(실사 커버 사진, 실제 호스트 프로필, 참여 인원, 공연·전시 그리드, 모임 채팅방)를
/// 부드러운 전환 애니메이션과 LayoutBuilder + FittedBox 반응형 스케일링으로 렌더링합니다.

/// 1. OOMU 시그니처 로고 마크 (소프트 라운드 스퀘어 + 코랄/틸 오버랩 서클 + 화이트 하트)
class OomuLogoMark extends StatelessWidget {
  final double size;
  final bool showShadow;
  final bool glowShadow;

  const OomuLogoMark({
    super.key,
    this.size = 96.0,
    this.showShadow = false,
    this.glowShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * (27.0 / 96.0)),
        boxShadow: glowShadow
            ? [
                BoxShadow(
                  color: const Color(0xFFFF5C39).withValues(alpha: 0.36),
                  blurRadius: 42,
                  offset: const Offset(0, 14),
                ),
              ]
            : (showShadow
                ? [
                    BoxShadow(
                      color: const Color(0xFF4A3014).withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null),
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _OomuLogoMarkPainter(),
      ),
    );
  }
}

class _OomuLogoMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 96.0;
    canvas.save();
    canvas.scale(scale);

    final bgRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 96, 96),
      const Radius.circular(27),
    );

    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF6EC), Color(0xFFFFE8D5)],
      ).createShader(const Rect.fromLTWH(0, 0, 96, 96));
    canvas.drawRRect(bgRect, bgPaint);

    // 1. 코랄 서클 (cx=38, cy=48, r=20, #FF5C39)
    canvas.drawCircle(
      const Offset(38, 48),
      20,
      Paint()..color = const Color(0xFFFF5C39),
    );

    // 2. 틸 서클 (cx=58, cy=48, r=20, #2FA98C)
    canvas.drawCircle(
      const Offset(58, 48),
      20,
      Paint()..color = const Color(0xFF2FA98C),
    );

    // 3. 교차 영역 (#1D7A66, opacity 0.72)
    canvas.save();
    canvas.clipPath(
      Path()
        ..addOval(Rect.fromCircle(center: const Offset(38, 48), radius: 20)),
    );
    canvas.drawCircle(
      const Offset(58, 48),
      20,
      Paint()..color = const Color(0xFF1D7A66).withValues(alpha: 0.72),
    );
    canvas.restore();

    // 4. 중앙 화이트 하트
    final heartPath = _buildHeartPath(48, 54, 1.0);
    canvas.drawPath(heartPath, Paint()..color = Colors.white);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Path _buildHeartPath(double cx, double bottomY, double scale) {
  final path = Path();
  path.moveTo(cx, bottomY);
  path.cubicTo(
    cx - 1.5 * scale,
    bottomY - 1.2 * scale,
    cx - 7.0 * scale,
    bottomY - 5.2 * scale,
    cx - 7.0 * scale,
    bottomY - 9.0 * scale,
  );
  path.cubicTo(
    cx - 7.0 * scale,
    bottomY - 11.4 * scale,
    cx - 5.2 * scale,
    bottomY - 13.0 * scale,
    cx - 3.0 * scale,
    bottomY - 13.0 * scale,
  );
  path.cubicTo(
    cx - 1.5 * scale,
    bottomY - 13.0 * scale,
    cx - 0.5 * scale,
    bottomY - 12.1 * scale,
    cx,
    bottomY - 11.0 * scale,
  );
  path.cubicTo(
    cx + 0.5 * scale,
    bottomY - 12.1 * scale,
    cx + 1.5 * scale,
    bottomY - 13.0 * scale,
    cx + 3.0 * scale,
    bottomY - 13.0 * scale,
  );
  path.cubicTo(
    cx + 5.2 * scale,
    bottomY - 13.0 * scale,
    cx + 7.0 * scale,
    bottomY - 11.4 * scale,
    cx + 7.0 * scale,
    bottomY - 9.0 * scale,
  );
  path.cubicTo(
    cx + 7.0 * scale,
    bottomY - 5.2 * scale,
    cx + 1.5 * scale,
    bottomY - 1.2 * scale,
    cx,
    bottomY,
  );
  path.close();
  return path;
}

/// 2. 스플래시 화면 하단 실시간 동네 모임 라이브 카드 티커
/// 실제 앱 모임 사진(cover_running_hangang.jpg, cover_wine.jpg, cover_salt_bread.jpg)과
/// 실제 호스트 아바타를 사용해 현재 동네에서 열리는 모임을 보여줍니다.
class OomuSplashLiveMeetupPreview extends StatefulWidget {
  const OomuSplashLiveMeetupPreview({super.key});

  @override
  State<OomuSplashLiveMeetupPreview> createState() =>
      _OomuSplashLiveMeetupPreviewState();
}

class _OomuSplashLiveMeetupPreviewState
    extends State<OomuSplashLiveMeetupPreview> {
  Timer? _tickerTimer;
  int _activeIdx = 0;

  static const List<Map<String, String>> _liveMeetups = [
    {
      'badge': '🏃 러닝 크루',
      'title': '주말 아침 망원 한강공원 5km 러닝 크루',
      'sub': '망원러너_지안 · 토요일 오전 9:00 · 4/6명 참여',
      'cover': 'assets/images/cover_running_hangang.jpg',
      'avatar': 'assets/images/지안.png',
    },
    {
      'badge': '🍷 와인·다이닝',
      'title': '성수 소소스팟 비스트로 내추럴 와인 모임',
      'sub': '성수와인_초연 · 금요일 저녁 7:30 · 6/8명 참여',
      'cover': 'assets/images/cover_wine.jpg',
      'avatar': 'assets/images/초연.png',
    },
    {
      'badge': '🎭 공연·전시',
      'title': '성수 디올 & 미디어아트 전시 동행 모임',
      'sub': '전시메이트_시연 · 일요일 오후 2:00 · 5/6명 참여',
      'cover': 'assets/images/cover_cafe.jpg',
      'avatar': 'assets/images/시연.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tickerTimer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
      if (mounted) {
        setState(() {
          _activeIdx = (_activeIdx + 1) % _liveMeetups.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _liveMeetups[_activeIdx];
    final next = _liveMeetups[(_activeIdx + 1) % _liveMeetups.length];

    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 라이브 상태 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF5C39),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                '지금 우리 동네 실시간 모임',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE6D8C7),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 메인 라이브 실제 모임 카드 (실사 썸네일 + 호스트 아바타)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            transitionBuilder: (child, anim) {
              return FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.12),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: anim,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              );
            },
            child: _buildSplashRealMeetupCard(
              key: ValueKey<int>(_activeIdx),
              item: current,
              isPrimary: true,
            ),
          ),
          const SizedBox(height: 8),

          // 서브 대기 모임 카드
          Opacity(
            opacity: 0.78,
            child: _buildSplashRealMeetupCard(
              key: ValueKey<String>('sub_${next['title']}'),
              item: next,
              isPrimary: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplashRealMeetupCard({
    required Key key,
    required Map<String, String> item,
    required bool isPrimary,
  }) {
    return Container(
      key: key,
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isPrimary ? 10 : 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2D231B).withValues(alpha: isPrimary ? 0.96 : 0.78),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrimary
              ? const Color(0xFFFF7A55).withValues(alpha: 0.42)
              : Colors.white.withValues(alpha: 0.12),
        ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Image(
              image: appImg(item['cover']!),
              width: isPrimary ? 48 : 40,
              height: isPrimary ? 48 : 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6.5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5C39),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item['badge']!,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item['sub']!,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD5C5B3),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['title']!,
                  style: TextStyle(
                    fontSize: isPrimary ? 12.5 : 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFFFF9F2),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ClipOval(
            child: Image(
              image: appImg(item['avatar']!),
              width: 24,
              height: 24,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

/// 3. 온보딩 슬라이드 1: 실제 동네 모임 피드 (한강 러닝 · 와인 · 오늘 번개 실사 카드)
class OomuSlide1Map extends StatefulWidget {
  final double width;
  final double height;

  const OomuSlide1Map({
    super.key,
    this.width = 336,
    this.height = 310,
  });

  @override
  State<OomuSlide1Map> createState() => _OomuSlide1MapState();
}

class _OomuSlide1MapState extends State<OomuSlide1Map> {
  Timer? _cardTimer;
  int _activeIndex = 0;

  static const List<String> _categories = [
    '🔥 전체',
    '🏃 러닝·운동',
    '🍷 와인·다이닝',
    '⚡ 오늘 번개',
  ];

  static const List<Map<String, dynamic>> _featuredMeetups = [
    {
      'chipIndex': 1,
      'badge': '라이프 메이트',
      'distance': '📍 도보 8분 · 망원한강공원',
      'title': '주말 아침 망원 한강공원 가벼운 5km 러닝 크루 🏃',
      'schedule': '이번 주 토요일 오전 9:00 · 망원나들목 집결',
      'cover': 'assets/images/cover_running_hangang.jpg',
      'hostName': '망원러너_지안',
      'hostAvatar': 'assets/images/지안.png',
      'temp': '46.5°C',
      'members': '4/6명 참여',
      'memberAvatars': [
        'assets/images/지안.png',
        'assets/images/시연.png',
        'assets/images/정재.png',
      ],
    },
    {
      'chipIndex': 2,
      'badge': '와인·다이닝',
      'distance': '📍 도보 5분 · 성수 연무장길',
      'title': '성수 소소스팟 비스트로 내추럴 와인 & 대화 모임 🍷',
      'schedule': '이번 주 금요일 저녁 7:30 · 성수동 비스트로',
      'cover': 'assets/images/cover_wine.jpg',
      'hostName': '성수와인_초연',
      'hostAvatar': 'assets/images/초연.png',
      'temp': '48.2°C',
      'members': '6/8명 참여',
      'memberAvatars': [
        'assets/images/초연.png',
        'assets/images/민지.png',
        'assets/images/주아.png',
      ],
    },
    {
      'chipIndex': 3,
      'badge': '⚡ 오늘 번개',
      'distance': '📍 도보 6분 · 서울숲 카페거리',
      'title': '서울숲 잔디마당 플랫화이트 & 주말 산책 번개 ☕',
      'schedule': '오늘 오후 2:00 · 서울숲역 3번 출구 앞',
      'cover': 'assets/images/cover_cafe.jpg',
      'hostName': '숲길산책_시연',
      'hostAvatar': 'assets/images/시연.png',
      'temp': '43.8°C',
      'members': '5/6명 참여',
      'memberAvatars': [
        'assets/images/시연.png',
        'assets/images/정재.png',
        'assets/images/민지.png',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _cardTimer = Timer.periodic(const Duration(milliseconds: 2400), (_) {
      if (mounted) {
        setState(() {
          _activeIndex = (_activeIndex + 1) % _featuredMeetups.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _cardTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = _featuredMeetups[_activeIndex];
    final activeChip = item['chipIndex'] as int;
    final avatars = (item['memberAvatars'] as List).cast<String>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: Container(
            width: 328,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9F2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEADBC8), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A3014).withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1) 실제 앱 동네 헤더 바
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFEFE3D0)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: Color(0xFFFF5C39),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '성수동 · 망원동',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2B2118),
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 15,
                            color: Color(0xFF7D6F5E),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F5EF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        '✓ 동네인증 완료',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F8A70),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 2) 카테고리 필터 칩 바
                Row(
                  children: List.generate(_categories.length, (i) {
                    final isSelected = i == activeChip || (i == 0 && activeChip == 0);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.only(
                          right: i < _categories.length - 1 ? 6 : 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFF5C39)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFF5C39)
                              : const Color(0xFFEFE3D0),
                        ),
                      ),
                      child: Text(
                        _categories[i],
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF7D6F5E),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),

                // 3) 실제 앱 대표 모임 카드 (실사 사진 + 호스트 프로필 + 참여 현황)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 380),
                  transitionBuilder: (child, anim) {
                    return FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: anim,
                          curve: Curves.easeOutCubic,
                        )),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    key: ValueKey<int>(_activeIndex),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF0E6D4)),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF4A3014).withValues(alpha: 0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 실사 커버 사진 영역
                        SizedBox(
                          height: 118,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image(
                                image: appImg(item['cover'] as String),
                                fit: BoxFit.cover,
                              ),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.22),
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.45),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 9,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.white.withValues(alpha: 0.95),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    item['badge'] as String,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2B2118),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 9,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.black.withValues(alpha: 0.58),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    item['distance'] as String,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 카드 본문
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2B2118),
                                  height: 1.25,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 11.5,
                                    color: Color(0xFFFF5C39),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item['schedule'] as String,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF7D6F5E),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.only(top: 8),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Color(0xFFF5EDDD)),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _buildRealAvatarStack(avatars),
                                    const SizedBox(width: 7),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              item['hostName'] as String,
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF2B2118),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFEDE7),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              item['temp'] as String,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFFE8542F),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 9, vertical: 4.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF5C39),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        item['members'] as String,
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // 4) 하단 서브 번개 모임 행 (실제 앱 리스트 아이템)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF0E6D4)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Image(
                          image: appImg('assets/images/cover_salt_bread.jpg'),
                          width: 38,
                          height: 38,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '성수 겉바속촉 수제 소금빵 오픈런 번개 🥐',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2B2118),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              '⚡ 오늘 오후 1시 · 성수동 카페거리 · 3/4명',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7D6F5E),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFECE5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          '마감임박',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFF5C39),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRealAvatarStack(List<String> paths) {
    return SizedBox(
      width: 52,
      height: 24,
      child: Stack(
        children: List.generate(paths.length, (i) {
          return Positioned(
            left: i * 14.0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: ClipOval(
                child: Image(
                  image: appImg(paths[i]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 4. 온보딩 슬라이드 2: 공연·전시 & 동네 핫플 발견 2x2 실제 피드 그리드
class OomuSlide2Friends extends StatefulWidget {
  final double width;
  final double height;

  const OomuSlide2Friends({
    super.key,
    this.width = 336,
    this.height = 310,
  });

  @override
  State<OomuSlide2Friends> createState() => _OomuSlide2FriendsState();
}

class _OomuSlide2FriendsState extends State<OomuSlide2Friends> {
  Timer? _filterTimer;
  int _selectedFilter = 0;

  static const List<String> _filters = [
    '전체 46',
    '📍 우리동네 8',
    '공연·전시 19',
    'SNS 맛집 12',
    '러닝·액티비티 7',
  ];

  @override
  void initState() {
    super.initState();
    _filterTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (mounted) {
        setState(() {
          _selectedFilter = (_selectedFilter + 1) % _filters.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _filterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: Container(
            width: 328,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9F2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEADBC8), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A3014).withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 섹션 헤더
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '공연·전시와 동네 핫플 발견',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2B2118),
                      ),
                    ),
                    Text(
                      '전체보기 >',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF5C39),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 실시간 필터 칩 바
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Row(
                    children: List.generate(_filters.length, (i) {
                      final isDark = i == _selectedFilter;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        margin: const EdgeInsets.only(right: 5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4.5),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF2B2118) : Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF2B2118)
                                : const Color(0xFFEFE3D0),
                          ),
                        ),
                        child: Text(
                          _filters[i],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color:
                                isDark ? Colors.white : const Color(0xFF7D6F5E),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 10),

                // 2x2 실제 모임 카드 그리드 (실사 이미지 & 호스트 아바타)
                Row(
                  children: [
                    Expanded(
                      child: _buildRealDiscoveryCard(
                        coverPath: 'assets/images/cover_cafe.jpg',
                        badge: '공연·전시',
                        badgeColor: const Color(0xFF2FA98C),
                        title: '성수 디올 & 미디어아트 전시 동행 🎨',
                        placeAndMembers: '📍 성수동 · 4/6명',
                        hostAvatar: 'assets/images/시연.png',
                        hostName: '시연',
                        isHighlighted:
                            _selectedFilter == 0 || _selectedFilter == 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildRealDiscoveryCard(
                        coverPath: 'assets/images/cover_salt_bread.jpg',
                        badge: 'SNS 맛집',
                        badgeColor: const Color(0xFFFF5C39),
                        title: '성수 비건 베이커리 & 소금빵 투어 🥐',
                        placeAndMembers: '📍 서울숲 · 3/4명',
                        hostAvatar: 'assets/images/민지.png',
                        hostName: '민지',
                        isHighlighted:
                            _selectedFilter == 1 || _selectedFilter == 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildRealDiscoveryCard(
                        coverPath: 'assets/images/cover_food.jpg',
                        badge: '뮤지컬·콘서트',
                        badgeColor: const Color(0xFF2FA98C),
                        title: '샤롯데씨어터 뮤지컬 관람 & 뒷풀이 🎭',
                        placeAndMembers: '📍 잠실역 · 5/6명',
                        hostAvatar: 'assets/images/주아.png',
                        hostName: '주아',
                        isHighlighted: _selectedFilter == 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildRealDiscoveryCard(
                        coverPath: 'assets/images/cover_running.jpg',
                        badge: '러닝 크루',
                        badgeColor: const Color(0xFFFF5C39),
                        title: '반포 한강 야경 시티런 5km 모임 🏃',
                        placeAndMembers: '📍 반포한강 · 6/8명',
                        hostAvatar: 'assets/images/정재.png',
                        hostName: '정재',
                        isHighlighted: _selectedFilter == 4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRealDiscoveryCard({
    required String coverPath,
    required String badge,
    required Color badgeColor,
    required String title,
    required String placeAndMembers,
    required String hostAvatar,
    required String hostName,
    required bool isHighlighted,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlighted
              ? badgeColor.withValues(alpha: 0.65)
              : const Color(0xFFEFE3D0),
          width: isHighlighted ? 1.4 : 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 68,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image(
                  image: appImg(coverPath),
                  fit: BoxFit.cover,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6.5, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2B2118),
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    ClipOval(
                      child: Image(
                        image: appImg(hostAvatar),
                        width: 15,
                        height: 15,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        placeAndMembers,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7D6F5E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
}

/// 5. 온보딩 슬라이드 3: 실제 모임 채팅방 (#chatroom 디자인 1:1 재현 + 실사 사진 공유)
class OomuSlide3Meetup extends StatefulWidget {
  final double width;
  final double height;

  const OomuSlide3Meetup({
    super.key,
    this.width = 336,
    this.height = 310,
  });

  @override
  State<OomuSlide3Meetup> createState() => _OomuSlide3MeetupState();
}

class _OomuSlide3MeetupState extends State<OomuSlide3Meetup> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: Container(
            width: 328,
            decoration: BoxDecoration(
              color: const Color(0xFFFBF6EC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEADBC8), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A3014).withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1) 채팅방 상단 헤더 (.cr-header)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF9F2),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFF1E7D6)),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 15,
                        color: Color(0xFF2B2118),
                      ),
                      const SizedBox(width: 8),
                      ClipOval(
                        child: Image(
                          image: appImg('assets/images/초연.png'),
                          width: 34,
                          height: 34,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '성수 소소스팟 비스트로 와인 모임',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2B2118),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2FA98C),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '멤버 8명 · 방금 활동',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2FA98C),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.more_horiz_rounded,
                        size: 18,
                        color: Color(0xFF7D6F5E),
                      ),
                    ],
                  ),
                ),

                // 2) 코랄 일정 배너 (.cr-banner)
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF7A55), Color(0xFFFF5C39)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5C39).withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.wine_bar_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '이번 주 와인 모임',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '금요일 저녁 7시 · 성수동 비스트로',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFFF3E5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          '모임 정보',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3) 실제 대화 메시지 리스트 (.cr-messages)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildRealChatMsgLeft(
                        avatarPath: 'assets/images/초연.png',
                        sender: '초연',
                        text: '이번 주 금요일 저녁 7시에 성수동 비스트로에서 모임 진행해요 🍷',
                        photoAttachment: 'assets/images/cover_wine.jpg',
                        photoCaption: '이번 주 갈집 비스트로 내부',
                      ),
                      const SizedBox(height: 7),
                      _buildRealChatMsgLeft(
                        avatarPath: 'assets/images/민지.png',
                        sender: '민지',
                        text: '분위기 너무 좋네요! 와인 모임 처음인데 기대돼요 🙌',
                      ),
                      const SizedBox(height: 7),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 11, vertical: 7.5),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF5C39),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(14),
                              topRight: Radius.circular(4),
                              bottomLeft: Radius.circular(14),
                              bottomRight: Radius.circular(14),
                            ),
                          ),
                          child: const Text(
                            '저도 참여 완료했어요! 금요일에 봬요 😊',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 4) 채팅 입력 바 (.cr-input)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF9F2),
                    border: Border(
                      top: BorderSide(color: Color(0xFFF1E7D6)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3E9D8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          size: 16,
                          color: Color(0xFF7D6F5E),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F0E4),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            '메시지 보내기…',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFA99A87),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF5C39),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRealChatMsgLeft({
    required String avatarPath,
    required String sender,
    required String text,
    String? photoAttachment,
    String? photoCaption,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: Image(
            image: appImg(avatarPath),
            width: 26,
            height: 26,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sender,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7D6F5E),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  border: Border.all(color: const Color(0xFFF0E6D4)),
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2B2118),
                    height: 1.35,
                  ),
                ),
              ),
              if (photoAttachment != null) ...[
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 170,
                    height: 54,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image(
                          image: appImg(photoAttachment),
                          fit: BoxFit.cover,
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.65),
                              ],
                            ),
                          ),
                        ),
                        if (photoCaption != null)
                          Positioned(
                            left: 8,
                            bottom: 5,
                            child: Text(
                              photoCaption,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
