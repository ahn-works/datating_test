import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// OOMU 앱 스플래시 및 인트로 온보딩 전용 실시간 모임 쇼케이스 & 일러스트 위젯
/// 'store_assets/OOMU 앱 UI 디자인.html'을 기반으로 실제 동네 모임(러닝 크루, 공연·전시, 핫플, 실시간 채팅)
/// UI와 부드러운 물리 애니메이션(Emil Kowalski 모션 원칙: scale 0.92->1.0, easeOutCubic, GPU Transform)을 결합합니다.

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
                  blurRadius: 48,
                  offset: const Offset(0, 18),
                ),
              ]
            : (showShadow
                ? [
                    BoxShadow(
                      color: const Color(0xFF4A3014).withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
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
      Path()..addOval(Rect.fromCircle(center: const Offset(38, 48), radius: 20)),
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

/// 2. 스플래시 화면 하단 실시간 동네 모임 라이브 프리뷰 티커
/// 스플래시 진입 시 현재 동네에서 뜨는 러닝·공연·전시·와인 모임 카드를 부드러운 애니메이션으로 보여줍니다.
class OomuSplashLiveMeetupPreview extends StatefulWidget {
  const OomuSplashLiveMeetupPreview({super.key});

  @override
  State<OomuSplashLiveMeetupPreview> createState() =>
      _OomuSplashLiveMeetupPreviewState();
}

class _OomuSplashLiveMeetupPreviewState
    extends State<OomuSplashLiveMeetupPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _floatCtrl,
        builder: (context, _) {
          final t = Curves.easeInOutSine.transform(_floatCtrl.value);
          final dy1 = -4.0 + (8.0 * t);
          final dy2 = 4.0 - (8.0 * t);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 실시간 카테고리 필 바
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  _buildSplashPill('🔥 지금 뜨는 모임', isHighlight: true),
                  _buildSplashPill('🏃 한강 러닝'),
                  _buildSplashPill('🎭 공연·전시 46'),
                  _buildSplashPill('🍷 와인·다이닝'),
                ],
              ),
              const SizedBox(height: 14),

              // 라이브 미니 모임 카드 1: 러닝 크루
              Transform.translate(
                offset: Offset(0, dy1),
                child: Container(
                  width: 310,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E241B).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFF7A55).withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 미니 한강 선셋 썸네일
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: CustomPaint(
                            painter: _HanRiverRunSunrisePainter(phase: t),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF5C39),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    '라이프 메이트',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Expanded(
                                  child: Text(
                                    '망원러너_지안 · 46.5°C',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFD5C5B3),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '주말 아침 망원 한강공원 5km 러닝 크루 🏃',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFFFF9F2),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 라이브 미니 모임 카드 2: 공연·전시 & 동네 핫플
              Transform.translate(
                offset: Offset(0, dy2),
                child: Container(
                  width: 294,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E241B).withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFF2FA98C).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2FA98C), Color(0xFF1D7A66)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text('🎭', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '공연·전시 동행 & 성수 베이커리 탐방 🥐',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFFFF9F2),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              '📍 우리동네 8건 · 콘서트 6 · 뮤지컬 7 진행 중',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8FD4CB),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSplashPill(String label, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: isHighlight
            ? const Color(0xFFFF5C39).withValues(alpha: 0.24)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isHighlight
              ? const Color(0xFFFF7A55).withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isHighlight
              ? const Color(0xFFFFB299)
              : const Color(0xFFE6D8C7),
        ),
      ),
    );
  }
}

/// 3. 온보딩 슬라이드 1: 실제 동네모임 피드 & 한강 러닝 크루 라이브 쇼케이스
class OomuSlide1Map extends StatefulWidget {
  final double width;
  final double height;

  const OomuSlide1Map({
    super.key,
    this.width = 320,
    this.height = 310,
  });

  @override
  State<OomuSlide1Map> createState() => _OomuSlide1MapState();
}

class _OomuSlide1MapState extends State<OomuSlide1Map>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  Timer? _chipTimer;
  int _activeCategoryIdx = 0;

  static const List<String> _categories = [
    '🔥 전체',
    '⚡ 오늘 번개',
    '🏃 라이프 메이트',
    '🍷 와인 모임',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _chipTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (mounted) {
        setState(() {
          _activeCategoryIdx = (_activeCategoryIdx + 1) % _categories.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _chipTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = Curves.easeInOutSine.transform(_ctrl.value);
          final floatY = -5.0 + (10.0 * t);
          final floatOpposite = 5.0 - (10.0 * t);

          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // 은은한 방사형 배경 글로우
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF5C39).withValues(alpha: 0.14),
                        const Color(0xFF2FA98C).withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // 메인 실제 모임 UI 쇼케이스 카드
                Transform.translate(
                  offset: Offset(0, floatY * 0.45),
                  child: Transform.rotate(
                    angle: -0.024, // -1.4deg 감성 틸트
                    child: Container(
                      width: 292,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFF0E6D4)),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF4A3014).withValues(alpha: 0.18),
                            blurRadius: 36,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 미니 동네 헤더 + 실시간 카테고리 칩 바
                          Container(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                            color: const Color(0xFFFFFDF9),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      size: 14,
                                      color: Color(0xFFFF5C39),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      '우리 동네에서 지금 뜨는 모임',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF2B2118),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFEDE7),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: const Text(
                                        'LIVE',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFFFF5C39),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 7),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const NeverScrollableScrollPhysics(),
                                  child: Row(
                                    children:
                                        List.generate(_categories.length, (i) {
                                      final isOn = i == _activeCategoryIdx;
                                      return AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 260),
                                        margin: const EdgeInsets.only(right: 5),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3.5),
                                        decoration: BoxDecoration(
                                          color: isOn
                                              ? const Color(0xFFFF5C39)
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          border: Border.all(
                                            color: isOn
                                                ? const Color(0xFFFF5C39)
                                                : const Color(0xFFEFE3D0),
                                          ),
                                        ),
                                        child: Text(
                                          _categories[i],
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: isOn
                                                ? Colors.white
                                                : const Color(0xFF7D6F5E),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 한강공원 아침 러닝 일러스트 배너 (store_assets/OOMU 앱 UI 디자인.html 동일)
                          SizedBox(
                            height: 112,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CustomPaint(
                                  painter: _HanRiverRunSunrisePainter(phase: t),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.94),
                                      borderRadius: BorderRadius.circular(999),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.12),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      '라이프 메이트',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF2B2118),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 모임 본문 정보
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '망원 한강공원 아침 5km 러닝 크루 🏃',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2B2118),
                                    height: 1.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 11.5,
                                      color: Color(0xFFFF5C39),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '이번 주 토요일 오전 9시 · 망원한강공원 입구',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF7D6F5E),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 9),
                                Container(
                                  padding: const EdgeInsets.only(top: 8),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: Color(0xFFF5EDDD)),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildAvatarStack(),
                                      const SizedBox(width: 6),
                                      const Text(
                                        '망원러너_지안',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF2B2118),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFEDE7),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: const Text(
                                          '46.5°C',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFFE8542F),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF5C39),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: const Text(
                                          '참여하기',
                                          style: TextStyle(
                                            fontSize: 11,
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
                ),

                // 우상단 플로팅 배지 (일러스트 배너 상단 영역에 배치하여 텍스트 가림 방지)
                Positioned(
                  top: 72,
                  right: 2,
                  child: Transform.translate(
                    offset: Offset(0, floatOpposite * 0.7),
                    child: _buildFloatingMockChip('🏃 러닝 크루 · 3명 참여'),
                  ),
                ),

                // 좌중단 플로팅 배지 (일러스트 배너 하단 영역에 배치하여 호스트명 가림 방지)
                Positioned(
                  top: 146,
                  left: 2,
                  child: Transform.translate(
                    offset: Offset(0, floatY * 0.7),
                    child: _buildFloatingMockChip('📍 도보 8분 · 동네 인증'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarStack() {
    final colors = [
      const Color(0xFF2FA98C),
      const Color(0xFFFF8A5C),
      const Color(0xFFFFC24B),
    ];
    final labels = ['지', '민', '현'];
    return SizedBox(
      width: 52,
      height: 22,
      child: Stack(
        children: List.generate(3, (i) {
          return Positioned(
            left: i * 14.0,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: colors[i],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: Text(
                  labels[i],
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 4. 온보딩 슬라이드 2: 공연·전시 & 동네 핫플 발견 라이브 쇼케이스
class OomuSlide2Friends extends StatefulWidget {
  final double width;
  final double height;

  const OomuSlide2Friends({
    super.key,
    this.width = 320,
    this.height = 310,
  });

  @override
  State<OomuSlide2Friends> createState() => _OomuSlide2FriendsState();
}

class _OomuSlide2FriendsState extends State<OomuSlide2Friends>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  Timer? _filterTimer;
  int _selectedFilter = 0;

  static const List<String> _filters = [
    '전체 46',
    '📍 우리동네 8',
    '콘서트 6',
    '뮤지컬 7',
    '전시·페스티벌 12',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _filterTimer = Timer.periodic(const Duration(milliseconds: 1300), (_) {
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
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = Curves.easeInOutSine.transform(_ctrl.value);
          final floatY = -5.0 + (10.0 * t);

          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // 배경 서클 글로우
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF2FA98C).withValues(alpha: 0.14),
                        const Color(0xFFFFC24B).withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // 공연·전시 & 동네 발견 UI 카드
                Transform.translate(
                  offset: Offset(0, floatY * 0.4),
                  child: Transform.rotate(
                    angle: 0.02, // +1.1deg 틸트
                    child: Container(
                      width: 294,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFF0E6D4)),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF4A3014).withValues(alpha: 0.18),
                            blurRadius: 36,
                            offset: const Offset(0, 18),
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
                                '공연·전시와 동네 발견',
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

                          // 필터 칩 (전체 46 | 📍 우리동네 8 | 콘서트 6 | 뮤지컬 7)
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
                                      horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF2B2118)
                                        : Colors.white,
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
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF7D6F5E),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 2열 실제 발견 카드 그리드 (공연·전시 + SNS 맛집/러닝)
                          Row(
                            children: [
                              // 카드 1: 공연·전시 / 뮤지컬 동행
                              Expanded(
                                child: _buildDiscoveryMiniCard(
                                  badge: '공연·전시',
                                  badgeColor: const Color(0xFF2FA98C),
                                  title: '성수 미디어아트 전시 동행 🎨',
                                  time: '🕒 토요일 오후 3시',
                                  place: '📍 성수 문화공간',
                                  customArt: CustomPaint(
                                    painter: _ExhibitionArtPainter(phase: t),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 카드 2: SNS 맛집 베이커리 탐방 (HTML 시안 1:1)
                              Expanded(
                                child: _buildDiscoveryMiniCard(
                                  badge: 'SNS 맛집',
                                  badgeColor: const Color(0xFFFF5C39),
                                  title: '성수 비건 베이커리 탐방 🥐',
                                  time: '🕒 토요일 오후 2시',
                                  place: '📍 성수동 카페거리',
                                  customArt: CustomPaint(
                                    painter: _BakeryArtPainter(phase: t),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // 하단 미니 지도 핀 배너
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBF6EC),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFF0E5D4)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFECE5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.map_rounded,
                                    size: 14,
                                    color: Color(0xFFFF5C39),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    '지도에서 내 주변 1km 공연·핫플 모임 한눈에 보기',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2B2118),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 좌상단 플로팅 배지 (카드 상단 경계 바깥쪽에 배치)
                Positioned(
                  top: -12,
                  left: 4,
                  child: Transform.translate(
                    offset: Offset(floatY * 0.5, -floatY * 0.4),
                    child: _buildFloatingMockChip('🎭 콘서트·뮤지컬·전시 46건'),
                  ),
                ),

                // 우하단 플로팅 배지 (카드 하단 경계 바깥쪽에 배치)
                Positioned(
                  bottom: -12,
                  right: 4,
                  child: Transform.translate(
                    offset: Offset(-floatY * 0.5, floatY * 0.4),
                    child: _buildFloatingMockChip('🥐 동네 핫플·맛집 투어'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiscoveryMiniCard({
    required String badge,
    required Color badgeColor,
    required String title,
    required String time,
    required String place,
    required Widget customArt,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEFE3D0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 76,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                customArt,
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 9.5,
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
            padding: const EdgeInsets.all(8.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2B2118),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFA99A87),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  place,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFA99A87),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 5. 온보딩 슬라이드 3: 실제 모임 채팅방 & 일정 배너 라이브 쇼케이스
class OomuSlide3Meetup extends StatefulWidget {
  final double width;
  final double height;

  const OomuSlide3Meetup({
    super.key,
    this.width = 320,
    this.height = 310,
  });

  @override
  State<OomuSlide3Meetup> createState() => _OomuSlide3MeetupState();
}

class _OomuSlide3MeetupState extends State<OomuSlide3Meetup>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = Curves.easeInOutSine.transform(_ctrl.value);
          final floatY = -5.0 + (10.0 * t);

          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // 배경 서클 글로우
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFC24B).withValues(alpha: 0.16),
                        const Color(0xFFFF5C39).withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // 실제 모임 채팅방 쇼케이스 카드
                Transform.translate(
                  offset: Offset(0, floatY * 0.4),
                  child: Transform.rotate(
                    angle: -0.018,
                    child: Container(
                      width: 292,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF6EC),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFF0E6D4)),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF4A3014).withValues(alpha: 0.18),
                            blurRadius: 36,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 채팅방 상단 헤더
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            color: Colors.white,
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFE3D8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text('🍷',
                                        style: TextStyle(fontSize: 15)),
                                  ),
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '성수 소소스팟 비스트로 와인 모임',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF2B2118),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
                              ],
                            ),
                          ),

                          // 코랄 모임 일정 공지 배너
                          Container(
                            margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 9),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF7A55), Color(0xFFFF5C39)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF5C39)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.wine_bar_rounded,
                                    size: 16, color: Colors.white),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '이번 주 와인 & 다이닝 모임',
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
                                Text(
                                  '모임 정보 >',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 실시간 대화 말풍선 영역
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildChatBubbleLeft(
                                  sender: '초연',
                                  avatarColor: const Color(0xFFFF8A5C),
                                  text: '안녕하세요! 이번 주 와인 모임 반가워요 🙌',
                                ),
                                const SizedBox(height: 6),
                                _buildChatBubbleLeft(
                                  sender: '민지',
                                  avatarColor: const Color(0xFFFFC24B),
                                  text: '와인 모임 처음인데 가볍게 가도 될까요?',
                                ),
                                const SizedBox(height: 6),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 11, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF5C39),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(14),
                                        topRight: Radius.circular(4),
                                        bottomLeft: Radius.circular(14),
                                        bottomRight: Radius.circular(14),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF5C39)
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      '환영해요! 금요일 7시 성수역 3번 출구에서 봐요 🍷',
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
                        ],
                      ),
                    ),
                  ),
                ),

                // 우상단 플로팅 배지 (카드 상단 경계 바깥쪽에 배치)
                Positioned(
                  top: -12,
                  right: 4,
                  child: Transform.translate(
                    offset: Offset(0, -floatY * 0.6),
                    child: _buildFloatingMockChip('💬 실시간 모임 그룹톡'),
                  ),
                ),

                // 좌하단 플로팅 배지 (카드 하단 경계 바깥쪽에 배치)
                Positioned(
                  bottom: -12,
                  left: 4,
                  child: Transform.translate(
                    offset: Offset(0, floatY * 0.6),
                    child: _buildFloatingMockChip('♥ 취향 메이트 연결'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatBubbleLeft({
    required String sender,
    required Color avatarColor,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: avatarColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              sender.substring(0, 1),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(14),
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2B2118),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 공통 플로팅 칩 & 커스텀 페인터
// ==========================================

Widget _buildFloatingMockChip(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: const Color(0xFFF0E6D4)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF4A3014).withValues(alpha: 0.14),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        color: Color(0xFF2B2118),
      ),
    ),
  );
}

/// 한강 노을 & 러닝 크루 라이브 일러스트 페인터 (store_assets/OOMU 앱 UI 디자인.html #hmSky 재현)
class _HanRiverRunSunrisePainter extends CustomPainter {
  final double phase;
  _HanRiverRunSunrisePainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 노을 하늘 그래디언트
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFE9C4), Color(0xFFFFB477), Color(0xFFF0764E)],
        stops: [0.0, 0.55, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, skyPaint);

    // 태양 글로우
    final sunCenter = Offset(
      size.width * 0.80,
      size.height * (0.30 - 0.04 * math.sin(phase * math.pi)),
    );
    canvas.drawCircle(
      sunCenter,
      size.height * 0.22,
      Paint()..color = const Color(0xFFFFDFA3).withValues(alpha: 0.45),
    );
    canvas.drawCircle(
      sunCenter,
      size.height * 0.13,
      Paint()..color = const Color(0xFFFFF3D6),
    );

    // 한강 물결 영역
    final riverTop = size.height * 0.60;
    final riverHeight = size.height * 0.22;
    final riverRect = Rect.fromLTWH(0, riverTop, size.width, riverHeight);
    canvas.drawRect(
      riverRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8FD4CB), Color(0xFF55A8A0)],
        ).createShader(riverRect),
    );

    // 강변 산책로 트랙
    final trackTop = size.height * 0.80;
    canvas.drawRect(
      Rect.fromLTWH(0, trackTop, size.width, size.height - trackTop),
      Paint()..color = const Color(0xFFF2DDBB),
    );

    // 달리는 러너 실루엣 3명 (살짝 앞으로 움직이는 애니메이션)
    final shift = (phase - 0.5) * 8.0;
    _drawRunner(
        canvas, Offset(size.width * 0.32 + shift, size.height * 0.90), 0.85);
    _drawRunner(
        canvas, Offset(size.width * 0.50 + shift, size.height * 0.92), 0.90);
    _drawRunner(
        canvas, Offset(size.width * 0.68 + shift, size.height * 0.93), 0.85);
  }

  void _drawRunner(Canvas canvas, Offset base, double s) {
    final p = Paint()
      ..color = const Color(0xFF4A3014)
      ..strokeWidth = 3.2 * s
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      Offset(base.dx + 4 * s, base.dy - 22 * s),
      3.4 * s,
      Paint()..color = const Color(0xFF4A3014),
    );
    canvas.drawLine(
      Offset(base.dx + 3 * s, base.dy - 17 * s),
      Offset(base.dx - 1 * s, base.dy - 6 * s),
      p,
    );
    canvas.drawLine(
      Offset(base.dx + 3 * s, base.dy - 16 * s),
      Offset(base.dx + 10 * s, base.dy - 11 * s),
      p,
    );
    canvas.drawLine(
      Offset(base.dx - 1 * s, base.dy - 6 * s),
      Offset(base.dx + 7 * s, base.dy),
      p,
    );
    canvas.drawLine(
      Offset(base.dx - 1 * s, base.dy - 6 * s),
      Offset(base.dx - 8 * s, base.dy - 2 * s),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _HanRiverRunSunrisePainter oldDelegate) =>
      oldDelegate.phase != phase;
}

/// 공연·전시 카드 일러스트 페인터
class _ExhibitionArtPainter extends CustomPainter {
  final double phase;
  _ExhibitionArtPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF23332F), Color(0xFF2FA98C), Color(0xFF8FD4CB)],
        ).createShader(rect),
    );

    // 갤러리 아치 프레임
    final archRRect = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: Offset(size.width * 0.52, size.height * 0.58),
        width: size.width * 0.38,
        height: size.height * 0.68,
      ),
      topLeft: const Radius.circular(30),
      topRight: const Radius.circular(30),
    );
    canvas.drawRRect(
      archRRect,
      Paint()..color = const Color(0xFFFFF6E4).withValues(alpha: 0.92),
    );

    // 프레임 안 오브제
    canvas.drawCircle(
      Offset(size.width * 0.52, size.height * (0.48 - 0.04 * phase)),
      9,
      Paint()..color = const Color(0xFFFF5C39),
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.28),
      12,
      Paint()..color = const Color(0xFFFFC24B).withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant _ExhibitionArtPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

/// SNS 맛집 베이커리 카드 일러스트 페인터 (store_assets/OOMU 앱 UI 디자인.html #hdBak 재현)
class _BakeryArtPainter extends CustomPainter {
  final double phase;
  _BakeryArtPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF6E4), Color(0xFFFFE9C6)],
        ).createShader(rect),
    );

    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.22),
      18,
      Paint()..color = const Color(0xFFFFD9A0).withValues(alpha: 0.55),
    );

    // 우드 테이블
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.68, size.width, size.height * 0.32),
      Paint()..color = const Color(0xFFC98F5B),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.64, size.width, size.height * 0.06),
      Paint()..color = const Color(0xFFE8B87F),
    );

    // 크루아상 & 브레드 오브제
    final center = Offset(size.width * 0.46, size.height * 0.52);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 28, height: 18),
      Paint()..color = const Color(0xFFD98E3F),
    );
    canvas.drawCircle(
      Offset(size.width * 0.74, size.height * 0.54),
      11,
      Paint()..color = const Color(0xFFE3A75F),
    );
  }

  @override
  bool shouldRepaint(covariant _BakeryArtPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

/// 정밀 하트 패스 생성 (cx, cy를 하트 최하단 첨점으로 위치)
Path _buildHeartPath(double cx, double cy, double scale) {
  final path = Path();
  final s = scale;
  path.moveTo(cx, cy);
  path.cubicTo(cx - 3.8 * s, cy - 2.4 * s, cx - 6.1 * s, cy - 4.4 * s,
      cx - 6.1 * s, cy - 6.9 * s);
  path.cubicTo(cx - 6.1 * s, cy - 8.9 * s, cx - 4.5 * s, cy - 10.5 * s,
      cx - 2.7 * s, cy - 10.5 * s);
  path.cubicTo(
      cx - 1.6 * s, cy - 10.5 * s, cx - 0.6 * s, cy - 10.0 * s, cx, cy - 9.1 * s);
  path.cubicTo(cx + 0.6 * s, cy - 10.0 * s, cx + 1.6 * s, cy - 10.5 * s,
      cx + 2.7 * s, cy - 10.5 * s);
  path.cubicTo(cx + 4.5 * s, cy - 10.5 * s, cx + 6.1 * s, cy - 8.9 * s,
      cx + 6.1 * s, cy - 6.9 * s);
  path.cubicTo(
      cx + 6.1 * s, cy - 4.4 * s, cx + 3.8 * s, cy - 2.4 * s, cx, cy);
  path.close();
  return path;
}
