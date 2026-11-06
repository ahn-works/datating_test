import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/global_data.dart';
import '../utils/web_redirect_helper.dart';
import '../widgets/bouncy_tap.dart';
import '../widgets/oomu_intro_illustrations.dart';
import 'profile_setup_screen.dart';
import 'soso_car_home_screen.dart';

/// OOMU 앱 인트로 온보딩 및 소셜 로그인 화면
/// 'assets/images/OOMU 앱 UI 디자인.html'의 3단계 흐름(스플래시 -> 인트로 온보딩 -> 로그인)을
/// 1:1 완벽 구현하며, 카카오·네이버·구글·휴대폰·둘러보기(게스트) 및 테스트 계정 전환을 완벽 지원합니다.
class LoginScreen extends StatefulWidget {
  final int initialStage; // 0: 스플래시, 1: 온보딩, 2: 로그인

  const LoginScreen({
    super.key,
    this.initialStage = 0,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  // OOMU 단일 디자인 테마 컬러
  static const Color colorBg = Color(0xFFFBEFE0);
  static const Color colorAppBg = Color(0xFFFFF9F2);
  static const Color colorText = Color(0xFF2B2118);
  static const Color colorTextMuted = Color(0xFF7D6F5E);
  static const Color colorPrimary = Color(0xFFFF5C39);
  static const Color colorKakao = Color(0xFFFEE500);
  static const Color colorNaver = Color(0xFF03C75A);
  static const Color colorGoogleBorder = Color(0xFFE8E0D4);

  late int _currentStage; // 0: 스플래시, 1: 인트로, 2: 로그인
  Timer? _splashTimer;

  // 온보딩 슬라이드 제어
  final PageController _pageController = PageController();
  int _currentSlide = 0;

  bool _isLoading = false;
  bool _hasProcessedOAuthCode = false;

  // 스플래시 점 3개 애니메이션 컨트롤러
  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    _currentStage = widget.initialStage;

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // 0단계 스플래시일 경우 2.2초 후 자동으로 온보딩(1단계) 전환
    if (_currentStage == 0) {
      _splashTimer = Timer(const Duration(milliseconds: 2200), () {
        if (mounted && _currentStage == 0) {
          setState(() => _currentStage = 1);
        }
      });
    }

    _checkOAuthRedirect();
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _dotsController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // OAuth 리다이렉트 콜백 감지 (카카오/네이버)
  void _checkOAuthRedirect() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_hasProcessedOAuthCode) return;
      try {
        final uri = Uri.base;
        String? code = uri.queryParameters['code'];
        String? state = uri.queryParameters['state'];
        String? error = uri.queryParameters['error'];
        String? errorDesc = uri.queryParameters['error_description'];

        if ((code == null || code.isEmpty) && uri.fragment.isNotEmpty) {
          final fragmentStr = uri.fragment;
          final qIndex = fragmentStr.indexOf('?');
          if (qIndex != -1) {
            final queryPart = fragmentStr.substring(qIndex + 1);
            final params = Uri.splitQueryString(queryPart);
            code ??= params['code'];
            state ??= params['state'];
            error ??= params['error'];
            errorDesc ??= params['error_description'];
          }
        }

        if (error != null && error.isNotEmpty) {
          _hasProcessedOAuthCode = true;
          if (mounted) {
            setState(() => _currentStage = 2);
            _hideLoading();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('간편인증 알림 [$error]: ${errorDesc ?? "인증이 취소되었거나 거절되었습니다."}'),
                backgroundColor: const Color(0xFFD9384A),
                duration: const Duration(seconds: 4),
              ),
            );
          }
          return;
        }

        if (code != null && code.isNotEmpty) {
          _hasProcessedOAuthCode = true;
          setState(() => _currentStage = 2);

          if (state != null && state.startsWith('naver')) {
            _showLoading('💬 네이버 공식 인증 정보 확인 중...');
            await authService.handleNaverOAuthCode(code, state);
            if (mounted) {
              _hideLoading();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎉 네이버 계정 인증 완료! 환영합니다.'),
                  backgroundColor: colorNaver,
                ),
              );
              _navigateHome();
            }
          } else {
            _showLoading('💬 카카오 공식 인증 정보 확인 중...');
            await authService.handleKakaoOAuthCode(code);
            if (mounted) {
              _hideLoading();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎉 카카오 계정 인증 완료! 환영합니다.'),
                  backgroundColor: colorKakao,
                ),
              );
              _navigateHome();
            }
          }
        }
      } catch (e) {
        if (mounted) {
          _hideLoading();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('간편 인증 처리 실패: $e'),
              backgroundColor: const Color(0xFFD9384A),
            ),
          );
        }
      }
    });
  }

  void _showLoading(String message) {
    setState(() => _isLoading = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: colorPrimary,
      ),
    );
  }

  void _hideLoading() {
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _navigateHome({bool skipProfileCheck = false}) async {
    _hideLoading();
    if (!mounted) return;

    if (!skipProfileCheck) {
      try {
        final activeUid = globalData.currentUserId.value.isNotEmpty
            ? globalData.currentUserId.value
            : authService.currentUser?.uid;
        if (activeUid != null && activeUid.isNotEmpty && !authService.isAdmin) {
          final isComplete = await authService.isUserProfileComplete(activeUid);
          if (!isComplete && mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
            );
            return;
          }
        }
      } catch (e) {
        debugPrint('[LoginScreen] Check profile fallback: $e');
      }
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OOMUHomeScreen()),
      );
    }
  }

  // 1. 카카오 로그인
  Future<void> _handleKakaoLogin() async {
    if (_isLoading) return;
    _showLoading('카카오 로그인 페이지로 이동 중…');
    try {
      final opened = await redirectToExternalUrl(authService.kakaoOAuthUrl);
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카카오 로그인 페이지를 열지 못했어요. 다시 시도해 주세요.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('카카오 연결 실패: $e')));
      }
    } finally {
      if (mounted) _hideLoading();
    }
  }

  // 2. 구글 로그인
  Future<void> _handleGoogleLogin() async {
    if (_isLoading) return;
    _showLoading('Google 계정 확인 중…');
    try {
      final credential = await authService.signInWithGoogle();
      if (!mounted) return;
      if (credential != null) await _navigateHome();
    } on FirebaseAuthException catch (e) {
      if (mounted && e.code != 'popup-closed-by-user' && e.code != 'cancelled-popup-request') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google 로그인을 완료하지 못했어요. 다시 시도해 주세요.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('연결 상태를 확인하고 다시 시도해 주세요.')),
        );
      }
    } finally {
      if (mounted) _hideLoading();
    }
  }

  // 3. 네이버 공식 로그인 연동
  void _handleNaverLogin() async {
    final currentUrl = Uri.base.toString().split('?').first.split('#').first;
    final redirectUri = Uri.encodeComponent(currentUrl);
    final state = 'naver_${DateTime.now().millisecondsSinceEpoch}';
    const clientId = '8GUg95zrKv0Cw6g4aTmi';
    final naverAuthUrl =
        'https://nid.naver.com/oauth2.0/authorize?response_type=code&client_id=$clientId&redirect_uri=$redirectUri&state=$state';

    _showLoading('💬 네이버 공식 로그인 페이지로 이동 중...');
    await redirectToExternalUrl(naverAuthUrl);
  }

  // 4. 일단 둘러볼래요 (게스트 둘러보기 -> 바로 동네 모임 앱 진입)
  Future<void> _handleGuestLogin() async {
    _showLoading('동네 모임 둘러보기 입장 중...');
    try {
      await authService.signInAsGuest();
      _navigateHome(skipProfileCheck: true);
    } catch (_) {
      _navigateHome(skipProfileCheck: true);
    }
  }

  // 스테이지 수동 전환
  void _goToStage(int stage) {
    _splashTimer?.cancel();
    setState(() => _currentStage = stage);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 540;

    // 모바일 폰 뷰포트 내부 위젯
    Widget screenContent;
    switch (_currentStage) {
      case 0:
        screenContent = _buildSplashScreen();
        break;
      case 1:
        screenContent = _buildOnboardingScreen();
        break;
      case 2:
      default:
        screenContent = _buildLoginScreen();
        break;
    }

    if (!isDesktop) {
      return Scaffold(
        backgroundColor: colorAppBg,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: KeyedSubtree(
              key: ValueKey<int>(_currentStage),
              child: screenContent,
            ),
          ),
        ),
      );
    }

    // 데스크톱 뷰: 브라우저 중앙에 예쁜 폰 프레임 및 하단 스테이지 전환 칩 배치
    return Scaffold(
      backgroundColor: colorBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 데스크톱 헤더
              const Text(
                'OOMU · APP UI DESIGN',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                  color: colorPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '우리 동네 모임, OOMU',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: colorText,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '앱 로고 · 인트로 온보딩 · SNS 로그인 화면 디자인',
                style: TextStyle(fontSize: 14.5, color: colorTextMuted),
              ),
              const SizedBox(height: 28),

              // 폰 프레임 (390 x 812 기준)
              Container(
                width: 390,
                height: 812,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(52),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3A332C), Color(0xFF17130F)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A3014).withValues(alpha: 0.28),
                      blurRadius: 90,
                      offset: const Offset(0, 40),
                    ),
                    BoxShadow(
                      color: const Color(0xFF4A3014).withValues(alpha: 0.18),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(42),
                  child: Container(
                    color: colorAppBg,
                    child: Stack(
                      children: [
                        // 다이나믹 아일랜드
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: const EdgeInsets.only(top: 14),
                            width: 108,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B0908),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        // 상태바 텍스트
                        Positioned(
                          top: 18,
                          left: 28,
                          child: Text(
                            TimeOfDay.now().format(context),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colorText,
                            ),
                          ),
                        ),
                        // 실제 화면 전환 뷰
                        Positioned.fill(
                          top: 48,
                          bottom: 16,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 320),
                            child: KeyedSubtree(
                              key: ValueKey<int>(_currentStage),
                              child: screenContent,
                            ),
                          ),
                        ),
                        // 하단 홈 인디케이터 바
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            width: 134,
                            height: 5,
                            decoration: BoxDecoration(
                              color: colorText.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 하단 화면 전환 칩 [ 스플래시 | 인트로 | 로그인 ]
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStageChip(0, '스플래시'),
                  const SizedBox(width: 8),
                  _buildStageChip(1, '인트로'),
                  const SizedBox(width: 8),
                  _buildStageChip(2, '로그인'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageChip(int stage, String label) {
    final isSelected = _currentStage == stage;
    return InkWell(
      onTap: () => _goToStage(stage),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colorText : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? colorText : const Color(0xFFD2B482).withValues(alpha: 0.45),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? const Color(0xFFFFF6E9) : colorTextMuted,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. 스플래시 화면 (Screen 1)
  // ==========================================
  Widget _buildSplashScreen() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _goToStage(1),
      child: Container(
        color: colorAppBg,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const OomuLogoMark(size: 132, showShadow: true),
              const SizedBox(height: 24),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'OO',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: colorPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    TextSpan(
                      text: 'MU',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: colorText,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '우리 동네 모임',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorTextMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 38),

              // 애니메이션 점 3개
              AnimatedBuilder(
                animation: _dotsController,
                builder: (context, child) {
                  final val = _dotsController.value;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPulseDot((val * 3) % 1.0),
                      const SizedBox(width: 8),
                      _buildPulseDot(((val * 3) + 0.33) % 1.0),
                      const SizedBox(width: 8),
                      _buildPulseDot(((val * 3) + 0.66) % 1.0),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPulseDot(double phase) {
    final opacity = (0.25 + 0.75 * (1.0 - (phase - 0.5).abs() * 2)).clamp(0.25, 1.0);
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: colorText.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  // ==========================================
  // 2. 인트로 온보딩 화면 (Screen 2: 3개 슬라이드 캐러셀)
  // ==========================================
  Widget _buildOnboardingScreen() {
    return Container(
      color: colorAppBg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // 상단 바: 로고 마크 + 건너뛰기 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const OomuLogoMark(size: 38),
              TextButton(
                onPressed: () => _goToStage(2),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                child: const Text(
                  '건너뛰기',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorTextMuted,
                  ),
                ),
              ),
            ],
          ),

          // 3개 슬라이드 PageView
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (idx) => setState(() => _currentSlide = idx),
              children: [
                // 슬라이드 1: 동네 숨은 장소 발견
                _buildSlideItem(
                  illustration: const OomuSlide1Map(width: 290, height: 215),
                  titlePrefix: '동네의 ',
                  highlight: '숨은 장소',
                  titleSuffix: '를 발견',
                  description: '우리 동네 카페부터 공원까지\n가볼 곳을 지도에서 한눈에 알려줘요',
                ),
                // 슬라이드 2: 취향이 맞는 이웃과 연결
                _buildSlideItem(
                  illustration: const OomuSlide2Friends(width: 290, height: 215),
                  titlePrefix: '',
                  highlight: '취향이 맞는',
                  titleSuffix: ' 이웃과 연결',
                  description: '관심사가 비슷한 이웃을 추천해 주고\n자연스럽게 대화를 시작할 수 있어요',
                ),
                // 슬라이드 3: 함께하는 모임 만들기
                _buildSlideItem(
                  illustration: const OomuSlide3Meetup(width: 290, height: 215),
                  titlePrefix: '함께하는 ',
                  highlight: '모임',
                  titleSuffix: '을 만들어요',
                  description: '동네 산책, 카페 투어, 독서 모임까지\n원하는 모임을 직접 만들고 참여해요',
                ),
              ],
            ),
          ),

          // 하단 도트 인디케이터 (active: width 26, inactive: width 8)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final isActive = _currentSlide == i;
              return InkWell(
                onTap: () {
                  _pageController.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 26 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? colorPrimary : const Color(0xFFE4D5C2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // 하단 다음 / 시작하기 CTA 버튼
          BouncyTap(
            onTap: () {
              if (_currentSlide < 2) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                );
              } else {
                _goToStage(2);
              }
            },
            child: Container(
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                color: colorPrimary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorPrimary.withValues(alpha: 0.32),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _currentSlide == 2 ? '시작하기' : '다음',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSlideItem({
    required Widget illustration,
    required String titlePrefix,
    required String highlight,
    required String titleSuffix,
    required String description,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: Center(child: illustration)),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: colorText,
              letterSpacing: -0.3,
              height: 1.3,
            ),
            children: [
              if (titlePrefix.isNotEmpty) TextSpan(text: titlePrefix),
              TextSpan(
                text: highlight,
                style: const TextStyle(color: colorPrimary),
              ),
              if (titleSuffix.isNotEmpty) TextSpan(text: titleSuffix),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15.5,
            color: colorTextMuted,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  // ==========================================
  // 3. 로그인 및 둘러보기 화면 (Screen 3)
  // ==========================================
  Widget _buildLoginScreen() {
    return Container(
      color: colorAppBg,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 히어로 영역
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    const OomuLogoMark(size: 88, showShadow: true),
                    const SizedBox(height: 14),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'OO',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: colorPrimary,
                            ),
                          ),
                          TextSpan(
                            text: 'MU',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: colorText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '우리 동네에서\n새로운 이웃을 만나요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.5,
                        fontWeight: FontWeight.w800,
                        color: colorText,
                        height: 1.35,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '3초 만에 간편하게 로그인하고 동네 모임을 시작하세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.5,
                        color: colorTextMuted,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // 액션 버튼 리스트
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. 카카오톡으로 시작하기
                    BouncyTap(
                      onTap: _handleKakaoLogin,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colorKakao,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(20, 20),
                              painter: _KakaoSymbolPainter(),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              '카카오톡으로 시작하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF191919),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 2. 네이버로 시작하기
                    BouncyTap(
                      onTap: _handleNaverLogin,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colorNaver,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: colorNaver.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'N',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              '네이버로 시작하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 3. Google로 시작하기
                    BouncyTap(
                      onTap: _handleGoogleLogin,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colorGoogleBorder),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4A3014).withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(18, 18),
                              painter: _GoogleLogoPainter(),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Google로 시작하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3C3C3C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 4. 휴대폰 번호로 시작하기
                    BouncyTap(
                      onTap: _showPhoneAuthModal,
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFECE5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFD4C7)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.smartphone_rounded, size: 19, color: colorPrimary),
                            SizedBox(width: 8),
                            Text(
                              '휴대폰 번호로 시작하기',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: colorPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 구분선 "또는"
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          Expanded(child: Container(height: 1, color: const Color(0xFFEFE4D4))),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              '또는',
                              style: TextStyle(fontSize: 13, color: Color(0xFF8A7B68)),
                            ),
                          ),
                          Expanded(child: Container(height: 1, color: const Color(0xFFEFE4D4))),
                        ],
                      ),
                    ),

                    // 5. 일단 둘러볼래요 (게스트 둘러보기)
                    BouncyTap(
                      onTap: _handleGuestLogin,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEADBC8), width: 1.5),
                        ),
                        child: const Center(
                          child: Text(
                            '일단 둘러볼래요',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: colorTextMuted,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 서브 옵션: 이메일 로그인 / 테스트 계정 선택
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: _showEmailAuthModal,
                          child: const Text(
                            '이메일 로그인',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorTextMuted,
                            ),
                          ),
                        ),
                        Container(width: 1, height: 12, color: const Color(0xFFE0D5C5)),
                        TextButton(
                          onPressed: _showTestUserModal,
                          child: const Text(
                            '🧪 테스트 계정',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colorPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 이용약관 및 개인정보처리방침 안내
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
                      child: Text(
                        '가입하면 OOMU 이용약관과 개인정보 처리방침에 동의하게 됩니다',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: const Color(0xFF8A7B68).withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 모달 시트들 (이메일 로그인 / 테스트 계정 / 휴대폰 SMS)
  // ==========================================

  // 이메일 로그인 모달 바텀시트
  void _showEmailAuthModal() {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    bool isLogin = true;
    String errorMsg = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5EA),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isLogin ? '이메일로 로그인' : '이메일로 회원가입',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF191F28),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        isLogin = !isLogin;
                        errorMsg = '';
                      });
                    },
                    child: Text(
                      isLogin ? '회원가입 하기' : '로그인 하기',
                      style: const TextStyle(color: colorPrimary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: '이메일 주소 입력',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5E8EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: colorPrimary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '비밀번호 입력 (6자리 이상)',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5E8EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: colorPrimary, width: 1.5),
                  ),
                ),
              ),
              if (errorMsg.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(errorMsg, style: const TextStyle(fontSize: 12, color: Color(0xFFD9384A))),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final email = emailCtrl.text.trim();
                    final pass = passCtrl.text;
                    if (email.isEmpty || pass.isEmpty) {
                      setModalState(() => errorMsg = '이메일과 비밀번호를 모두 입력해 주세요.');
                      return;
                    }
                    Navigator.pop(ctx);
                    _showLoading(isLogin ? '로그인 확인 중…' : '계정 생성 중…');
                    try {
                      if (isLogin) {
                        await authService.signInWithEmail(email, pass);
                      } else {
                        await authService.signUpWithEmail(email: email, password: pass);
                      }
                      if (mounted) {
                        _hideLoading();
                        _navigateHome();
                      }
                    } catch (e) {
                      if (mounted) {
                        _hideLoading();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('인증 실패: $e')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    isLogin ? '로그인' : '회원가입',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 체험용 테스트 계정 바텀시트
  void _showTestUserModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '체험용 테스트 계정 선택',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191F28),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close, size: 20, color: Color(0xFF767676)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                '원하는 프로필을 선택하면 해당 동네와 계정으로 1초 만에 전환됩니다.',
                style: TextStyle(fontSize: 13, color: Color(0xFF767676)),
              ),
              const SizedBox(height: 16),
              _buildTestUserTile(
                ctx,
                uid: 'LZs5U32GQJMkK77hkmaJupgKzwE2',
                name: '우리동네_초연',
                desc: '29세 · 여성 · 전남 여수시 화장동 (test11@naver.com)',
                badge: '여수 로컬',
                avatar: 'assets/images/초연.png',
              ),
              const SizedBox(height: 8),
              _buildTestUserTile(
                ctx,
                uid: 'test_user_01',
                name: '망원치즈_민지',
                desc: '25세 · 여성 · 서울 마포구 망원동',
                badge: '디저트·카페',
                avatar: 'assets/images/민지.png',
              ),
              const SizedBox(height: 8),
              _buildTestUserTile(
                ctx,
                uid: 'test_user_02',
                name: '연남러너_지훈',
                desc: '28세 · 남성 · 서울 마포구 연남동',
                badge: '한강러닝·운동',
                avatar: 'assets/images/지훈.png',
              ),
              const SizedBox(height: 8),
              _buildTestUserTile(
                ctx,
                uid: 'test_user_03',
                name: '성수와인_지연',
                desc: '31세 · 여성 · 서울 성동구 성수동',
                badge: '와인·전시회',
                avatar: 'assets/images/지연.png',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestUserTile(
    BuildContext ctx, {
    required String uid,
    required String name,
    required String desc,
    required String badge,
    required String avatar,
  }) {
    return InkWell(
      onTap: () async {
        Navigator.pop(ctx);
        _showLoading('$name 계정으로 입장 중...');
        try {
          await authService.syncUserSessionProfile(uid);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎉 $name($desc) 계정으로 전환되었습니다.'),
                duration: const Duration(seconds: 2),
                backgroundColor: colorPrimary,
              ),
            );
            await _navigateHome(skipProfileCheck: true);
          }
        } catch (_) {
          if (mounted) _hideLoading();
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E8EB)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(avatar),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191F28),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorPrimary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF767676)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFB0B8C1)),
          ],
        ),
      ),
    );
  }

  // 휴대폰 번호 SMS 인증 모달
  void _showPhoneAuthModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _PhoneAuthSheet(
        onSuccess: () {
          Navigator.pop(ctx);
          _navigateHome();
        },
      ),
    );
  }
}

/// 휴대폰 번호 인증 시트 (SOLAPI SMS 연동 지원)
class _PhoneAuthSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  const _PhoneAuthSheet({required this.onSuccess});

  @override
  State<_PhoneAuthSheet> createState() => _PhoneAuthSheetState();
}

class _PhoneAuthSheetState extends State<_PhoneAuthSheet> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _isCodeSent = false;
  bool _isLoading = false;
  String _verificationId = '';
  String _errorMessage = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color brandCoral = Color(0xFFFF5C39);
    const Color surfaceColor = Color(0xFFF7F7FA);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: brandCoral.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smartphone_rounded, size: 22, color: brandCoral),
                ),
                const SizedBox(width: 12),
                const Text(
                  '휴대폰 번호로 인증',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191F28),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '입력하신 휴대폰 번호로 SMS 인증번호 6자리가 발송됩니다.',
              style: TextStyle(fontSize: 13, color: Color(0xFF767676)),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '휴대폰 번호 (예: 01012345678)',
                      filled: true,
                      fillColor: surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          final phone = _phoneController.text.trim();
                          if (phone.length < 10) {
                            setState(() => _errorMessage = '올바른 휴대폰 번호를 입력해 주세요.');
                            return;
                          }
                          setState(() {
                            _isLoading = true;
                            _errorMessage = '';
                          });
                          await authService.sendPhoneSmsCode(
                            rawPhone: phone,
                            onCodeSent: (vId) {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                  _verificationId = vId;
                                  _isCodeSent = true;
                                });
                              }
                            },
                            onError: (err) {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                  _errorMessage = err;
                                });
                              }
                            },
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandCoral,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: Text(_isCodeSent ? '재발송' : '인증요청', style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
            if (_isCodeSent) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '인증번호 6자리 입력',
                  filled: true,
                  fillColor: surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          final code = _codeController.text.trim();
                          final phone = _phoneController.text.trim();
                          if (code.length != 6) {
                            setState(() => _errorMessage = '인증번호 6자리를 정확히 입력해 주세요.');
                            return;
                          }
                          setState(() {
                            _isLoading = true;
                            _errorMessage = '';
                          });
                          try {
                            await authService.verifyPhoneSmsCodeAndSignIn(
                              verificationId: _verificationId,
                              smsCode: code,
                              rawPhone: phone,
                            );
                            if (mounted) {
                              setState(() => _isLoading = false);
                              widget.onSuccess();
                            }
                          } catch (e) {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                                _errorMessage = e.toString().replaceAll('Exception: ', '');
                              });
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandCoral,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('인증 완료', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_errorMessage, style: const TextStyle(fontSize: 12, color: Color(0xFFD9384A))),
            ],
          ],
        ),
      ),
    );
  }
}

/// 카카오 말풍선 심볼 벡터 페인터
class _KakaoSymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF191919)
      ..style = PaintingStyle.fill;
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    final path = Path()
      ..addOval(const Rect.fromLTWH(0, 2, 24, 18));
    final tail = Path()
      ..moveTo(6, 17)
      ..lineTo(2, 22)
      ..lineTo(10, 19)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(tail, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Google 다색 'G' 로고 벡터 페인터
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    // Blue
    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    final blue = Path()
      ..moveTo(23.49, 12.27)
      ..cubicTo(23.49, 11.48, 23.42, 10.73, 23.3, 10.0)
      ..lineTo(12, 10.0)
      ..lineTo(12, 14.51)
      ..lineTo(18.47, 14.51)
      ..cubicTo(18.19, 15.99, 17.34, 17.25, 16.07, 18.15)
      ..lineTo(19.95, 21.17)
      ..cubicTo(22.21, 19.08, 23.49, 16.0, 23.49, 12.27)
      ..close();
    canvas.drawPath(blue, bluePaint);

    // Green
    final greenPaint = Paint()..color = const Color(0xFF34A853);
    final green = Path()
      ..moveTo(12, 24.0)
      ..cubicTo(15.24, 24.0, 17.95, 22.92, 19.95, 21.09)
      ..lineTo(16.07, 18.07)
      ..cubicTo(14.99, 18.79, 13.61, 19.23, 12, 19.23)
      ..cubicTo(8.87, 19.23, 6.22, 17.12, 5.27, 14.27)
      ..lineTo(1.29, 17.36)
      ..cubicTo(3.28, 21.31, 7.33, 24.0, 12, 24.0)
      ..close();
    canvas.drawPath(green, greenPaint);

    // Yellow
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final yellow = Path()
      ..moveTo(5.27, 14.27)
      ..cubicTo(5.02, 13.52, 4.88, 12.72, 4.88, 11.9)
      ..cubicTo(4.88, 11.08, 5.02, 10.28, 5.27, 9.53)
      ..lineTo(1.29, 6.44)
      ..cubicTo(0.47, 8.08, 0, 9.93, 0, 11.9)
      ..cubicTo(0, 13.87, 0.47, 15.72, 1.29, 17.36)
      ..lineTo(5.27, 14.27)
      ..close();
    canvas.drawPath(yellow, yellowPaint);

    // Red
    final redPaint = Paint()..color = const Color(0xFFEA4335);
    final red = Path()
      ..moveTo(12, 4.75)
      ..cubicTo(13.76, 4.75, 15.34, 5.36, 16.58, 6.55)
      ..lineTo(20.02, 3.11)
      ..cubicTo(17.95, 1.19, 15.24, 0, 12, 0)
      ..cubicTo(7.33, 0, 3.28, 2.69, 1.29, 6.64)
      ..lineTo(5.27, 9.73)
      ..cubicTo(6.22, 6.88, 8.87, 4.75, 12, 4.75)
      ..close();
    canvas.drawPath(red, redPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
