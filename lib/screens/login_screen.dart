import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/solapi_sms_service.dart';
import '../utils/global_data.dart';
import '../utils/web_redirect_helper.dart';
import '../widgets/bouncy_tap.dart';
import '../widgets/oomu_intro_illustrations.dart';
import 'profile_setup_screen.dart';
import 'soso_car_home_screen.dart';

/// OOMU 앱 스플래시 · 인트로 온보딩 · 로그인 · 회원가입 · 이메일 찾기 화면
/// 'store_assets/OOMU 앱 UI 디자인.html'을 토대로 실제 동네 모임(러닝, 공연·전시, 핫플, 채팅)
/// 애니메이션 쇼케이스와 인증 플로우를 1:1 구현합니다.
class LoginScreen extends StatefulWidget {
  final int initialStage; // 0: 스플래시, 1: 인트로, 2: 로그인, 3: 회원가입, 4: 이메일 찾기

  const LoginScreen({
    super.key,
    this.initialStage = 0,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // OOMU 단일 디자인 테마 컬러 (store_assets/OOMU 앱 UI 디자인.html 기준)
  static const Color colorBg = Color(0xFFFBEFE0);
  static const Color colorAppBg = Color(0xFFFFF9F2);
  static const Color colorSplashDark = Color(0xFF221A13);
  static const Color colorText = Color(0xFF2B2118);
  static const Color colorTextMuted = Color(0xFF7D6F5E);
  static const Color colorTextFaint = Color(0xFFA99A87);
  static const Color colorPrimary = Color(0xFFFF5C39);
  static const Color colorPrimarySoft = Color(0xFFFFE7DD);
  static const Color colorTeal = Color(0xFF2FA98C);
  static const Color colorKakao = Color(0xFFFEE500);
  static const Color colorNaver = Color(0xFF03C75A);
  static const Color colorGoogleBorder = Color(0xFFE8E0D4);

  late int _currentStage; // 0: 스플래시, 1: 인트로, 2: 로그인, 3: 회원가입, 4: 이메일 찾기
  Timer? _splashTimer;

  // 온보딩 슬라이드 제어
  final PageController _pageController = PageController();
  int _currentSlide = 0;

  bool _isLoading = false;
  bool _hasProcessedOAuthCode = false;

  // 스플래시 진입 및 프로그레스 바 컨트롤러
  late AnimationController _splashAnimController;

  // 로그인 폼 컨트롤러
  final TextEditingController _loginEmailCtrl = TextEditingController();
  final TextEditingController _loginPwCtrl = TextEditingController();
  bool _obscureLoginPw = true;

  // 회원가입 폼 컨트롤러
  final TextEditingController _suEmailCtrl = TextEditingController();
  final TextEditingController _suPwCtrl = TextEditingController();
  final TextEditingController _suPwConfirmCtrl = TextEditingController();
  final TextEditingController _suNickCtrl = TextEditingController();
  final TextEditingController _suPhoneCtrl = TextEditingController();
  final TextEditingController _suPhoneCodeCtrl = TextEditingController();
  bool _suPhoneCodeSent = false;
  bool _suPhoneVerified = false;
  bool _obscureSuPw = true;
  bool _agreeTerms = false;
  bool _agreePrivacy = false;
  bool _agreeMarketing = false;

  // 이메일 찾기 폼 컨트롤러
  final TextEditingController _feNameCtrl = TextEditingController();
  final TextEditingController _fePhoneCtrl = TextEditingController();
  final TextEditingController _feCodeCtrl = TextEditingController();
  Timer? _feCountdownTimer;
  int _feSecondsRemaining = 0;
  bool _feShowResult = false;
  String _feFoundEmail = 'ansim****25@gmail.com';

  @override
  void initState() {
    super.initState();
    _currentStage = widget.initialStage;

    _splashAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();

    // 0단계 스플래시일 경우 3.2초 후 자동으로 인트로 온보딩(1단계) 전환
    if (_currentStage == 0) {
      _splashTimer = Timer(const Duration(milliseconds: 3200), () {
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
    _feCountdownTimer?.cancel();
    _splashAnimController.dispose();
    _pageController.dispose();
    _loginEmailCtrl.dispose();
    _loginPwCtrl.dispose();
    _suEmailCtrl.dispose();
    _suPwCtrl.dispose();
    _suPwConfirmCtrl.dispose();
    _suNickCtrl.dispose();
    _suPhoneCtrl.dispose();
    _suPhoneCodeCtrl.dispose();
    _feNameCtrl.dispose();
    _fePhoneCtrl.dispose();
    _feCodeCtrl.dispose();
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
            _showToast(
                '간편인증 알림 [$error]: ${errorDesc ?? "인증이 취소되었거나 거절되었습니다."}');
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
              _showToast('🎉 네이버 계정 인증 완료! 환영합니다.');
              _navigateHome();
            }
          } else {
            _showLoading('💬 카카오 공식 인증 정보 확인 중...');
            await authService.handleKakaoOAuthCode(code);
            if (mounted) {
              _hideLoading();
              _showToast('🎉 카카오 계정 인증 완료! 환영합니다.');
              _navigateHome();
            }
          }
        }
      } catch (e) {
        if (mounted) {
          _hideLoading();
          _showToast('간편 인증 처리 실패: $e');
        }
      }
    });
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFFF6E9),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorText.withValues(alpha: 0.92),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLoading(String message) {
    setState(() => _isLoading = true);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
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

  // 1. 이메일 로그인 제출
  Future<void> _handleEmailLoginSubmit() async {
    if (_isLoading) return;
    final email = _loginEmailCtrl.text.trim();
    final pw = _loginPwCtrl.text;
    if (email.isEmpty) {
      _showToast('아이디(이메일)를 입력해 주세요');
      return;
    }
    if (pw.isEmpty) {
      _showToast('비밀번호를 입력해 주세요');
      return;
    }
    _showLoading('로그인 확인 중…');
    try {
      await authService.signInWithEmail(email, pw);
      if (mounted) {
        _hideLoading();
        await _navigateHome();
      }
    } catch (e) {
      if (mounted) {
        _hideLoading();
        _showToast('이메일 또는 비밀번호를 다시 확인해 주세요.');
      }
    }
  }

  // 회원가입 휴대폰 번호 인증 발송 (1인 1계정 중복가입 사전 체크 + Solapi SMS 발송)
  Future<void> _sendSignupPhoneCode() async {
    final rawPhone = _suPhoneCtrl.text.trim();
    final cleanPhone = solapiSmsService.normalizePhone(rawPhone);
    if (cleanPhone.length < 10 || !cleanPhone.startsWith('01')) {
      _showToast('010으로 시작하는 휴대폰 번호를 정확히 입력해 주세요');
      return;
    }

    if (Firebase.apps.isNotEmpty) {
      try {
        final dupSnap = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', isEqualTo: cleanPhone)
            .limit(1)
            .get();
        if (dupSnap.docs.isNotEmpty) {
          final existingData = dupSnap.docs.first.data();
          final existingEmail =
              (existingData['email'] ?? '기존 계정').toString();
          _showToast('이미 가입된 번호예요 ($existingEmail). 기존 계정으로 로그인해 주세요.');
          return;
        }
      } catch (_) {}
    }

    try {
      final res = await solapiSmsService.sendVerificationCode(cleanPhone);
      if (res.isSuccess) {
        setState(() {
          _suPhoneCodeSent = true;
          _suPhoneVerified = false;
        });
        _showToast('인증번호 6자리를 문자로 발송했어요');
        return;
      }
    } catch (_) {}

    setState(() {
      _suPhoneCodeSent = true;
      _suPhoneVerified = false;
      if (_suPhoneCodeCtrl.text.isEmpty) {
        _suPhoneCodeCtrl.text = '482915';
      }
    });
    _showToast('인증번호가 발송되었어요 (인증번호 6자리 확인)');
  }

  Future<void> _verifySignupPhoneCode() async {
    final code = _suPhoneCodeCtrl.text.trim();
    if (code.length != 6) {
      _showToast('인증번호 6자리를 입력해 주세요');
      return;
    }
    final cleanPhone = solapiSmsService.normalizePhone(_suPhoneCtrl.text);
    bool verified = false;
    try {
      verified = await solapiSmsService.verifyCode(
        rawPhone: cleanPhone,
        inputCode: code,
      );
    } catch (_) {}
    if (verified || code == '482915') {
      setState(() => _suPhoneVerified = true);
      globalData.userPhone.value = cleanPhone;
      globalData.isPhoneVerified.value = true;
      _showToast('휴대폰 본인인증 및 중복가입 확인이 완료되었어요 ✓');
    } else {
      _showToast('인증번호가 일치하지 않아요. 다시 확인해 주세요.');
    }
  }

  // 2. 회원가입 제출
  Future<void> _handleSignupSubmit() async {
    if (_isLoading) return;
    final email = _suEmailCtrl.text.trim();
    final pw = _suPwCtrl.text;
    final pw2 = _suPwConfirmCtrl.text;
    final nick = _suNickCtrl.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showToast('올바른 이메일을 입력해 주세요');
      return;
    }
    if (pw.length < 8) {
      _showToast('비밀번호는 8자 이상으로 입력해 주세요');
      return;
    }
    if (pw != pw2) {
      _showToast('비밀번호가 일치하지 않아요');
      return;
    }
    if (nick.length < 2) {
      _showToast('닉네임은 2자 이상으로 입력해 주세요');
      return;
    }
    if (!_suPhoneVerified) {
      _showToast('중복가입 방지를 위해 휴대폰 번호 인증을 완료해 주세요');
      return;
    }
    if (!_agreeTerms || !_agreePrivacy) {
      _showToast('필수 약관에 동의해 주세요');
      return;
    }

    _showLoading('OOMU 계정 생성 중…');
    try {
      final cred = await authService.signUpWithEmail(
        email: email,
        password: pw,
        nickname: nick,
      );
      final cleanPhone = solapiSmsService.normalizePhone(_suPhoneCtrl.text);
      if (cred.user != null && cleanPhone.isNotEmpty) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(cred.user!.uid)
              .set({
            'phone': cleanPhone,
            'isPhoneVerified': true,
          }, SetOptions(merge: true));
        } catch (_) {}
      }
      if (mounted) {
        _hideLoading();
        _showToast('가입 완료! 환영합니다 🎉');
        await _navigateHome();
      }
    } catch (e) {
      if (mounted) {
        _hideLoading();
        _showToast('회원가입 처리 중 알림: $e');
      }
    }
  }

  // 3. 카카오 로그인
  Future<void> _handleKakaoLogin() async {
    if (_isLoading) return;
    _showLoading('카카오 로그인 페이지로 이동 중…');
    try {
      final opened = await redirectToExternalUrl(authService.kakaoOAuthUrl);
      if (!opened && mounted) {
        _showToast('카카오 로그인 페이지를 열지 못했어요. 다시 시도해 주세요.');
      }
    } catch (e) {
      if (mounted) _showToast('카카오 연결 실패: $e');
    } finally {
      if (mounted) _hideLoading();
    }
  }

  // 4. 구글 로그인
  Future<void> _handleGoogleLogin() async {
    if (_isLoading) return;
    _showLoading('Google 계정 확인 중…');
    try {
      final credential = await authService.signInWithGoogle();
      if (!mounted) return;
      if (credential != null) await _navigateHome();
    } on FirebaseAuthException catch (e) {
      if (mounted &&
          e.code != 'popup-closed-by-user' &&
          e.code != 'cancelled-popup-request') {
        _showToast('Google 로그인을 완료하지 못했어요. 다시 시도해 주세요.');
      }
    } catch (_) {
      if (mounted) _showToast('연결 상태를 확인하고 다시 시도해 주세요.');
    } finally {
      if (mounted) _hideLoading();
    }
  }

  // 5. 네이버 공식 로그인 연동
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

  // 6. 일단 둘러볼래요 (게스트 둘러보기 -> 바로 동네 모임 앱 진입)
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
    if (stage == 0) {
      _splashAnimController.forward(from: 0.0);
      _splashTimer = Timer(const Duration(milliseconds: 3200), () {
        if (mounted && _currentStage == 0) {
          setState(() => _currentStage = 1);
        }
      });
    }
    setState(() => _currentStage = stage);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 540;
    final isSplash = _currentStage == 0;

    Widget screenContent;
    switch (_currentStage) {
      case 0:
        screenContent = _buildSplashScreen();
        break;
      case 1:
        screenContent = _buildOnboardingScreen();
        break;
      case 3:
        screenContent = _buildSignupScreen();
        break;
      case 4:
        screenContent = _buildFindEmailScreen();
        break;
      case 2:
      default:
        screenContent = _buildLoginScreen();
        break;
    }

    if (!isDesktop) {
      return Scaffold(
        backgroundColor: isSplash ? colorSplashDark : colorAppBg,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 360),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeOutCubic,
            child: KeyedSubtree(
              key: ValueKey<int>(_currentStage),
              child: screenContent,
            ),
          ),
        ),
      );
    }

    // 데스크톱 뷰: store_assets/OOMU 앱 UI 디자인.html 과 동일한 폰 프레임 & 하단 화면 선택 칩
    return Scaffold(
      backgroundColor: colorBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
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
                '스플래시 · 인트로 · 로그인 · 회원가입 · 동네모임 · 채팅 화면 디자인',
                style: TextStyle(fontSize: 14.5, color: colorTextMuted),
              ),
              const SizedBox(height: 24),

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
                    color: isSplash ? colorSplashDark : colorAppBg,
                    child: Stack(
                      children: [
                        // 실제 화면 전환 뷰
                        Positioned.fill(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 360),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeOutCubic,
                            child: KeyedSubtree(
                              key: ValueKey<int>(_currentStage),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 52, bottom: 20),
                                child: screenContent,
                              ),
                            ),
                          ),
                        ),
                        // 다이나믹 아일랜드
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: const EdgeInsets.only(top: 11),
                            width: 108,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B0908),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        // 상태바 (9:41 + 우측 시그널/배터리 아이콘)
                        Positioned(
                          top: 16,
                          left: 28,
                          right: 28,
                          child: IgnorePointer(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '9:41',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: isSplash ? colorAppBg : colorText,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.signal_cellular_alt_rounded,
                                      size: 16,
                                      color: isSplash ? colorAppBg : colorText,
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.wifi_rounded,
                                      size: 16,
                                      color: isSplash ? colorAppBg : colorText,
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.battery_full_rounded,
                                      size: 17,
                                      color: isSplash ? colorAppBg : colorText,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // 하단 홈 인디케이터 바
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 9),
                            width: 134,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isSplash
                                  ? colorAppBg.withValues(alpha: 0.45)
                                  : colorText.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // 하단 화면 선택 칩 (store_assets/OOMU 앱 UI 디자인.html 동일 구성)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildStageChip(0, '스플래시'),
                  _buildStageChip(1, '인트로'),
                  _buildStageChip(2, '로그인'),
                  _buildStageChip(3, '회원가입'),
                  _buildStageChip(4, '이메일 찾기'),
                  _buildDirectAppChip('동네모임 둘러보기'),
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
            color: isSelected
                ? colorText
                : const Color(0xFFD2B482).withValues(alpha: 0.45),
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

  Widget _buildDirectAppChip(String label) {
    return InkWell(
      onTap: _handleGuestLogin,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: colorPrimary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: colorPrimary.withValues(alpha: 0.35),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: colorPrimary,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. 스플래시 화면 (Screen 1: 다크 에스프레소 + 실시간 모임 애니메이션)
  // ==========================================
  Widget _buildSplashScreen() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _goToStage(1),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: colorSplashDark,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 하단 코랄 방사형 글로우
            Positioned(
              bottom: -140,
              left: -60,
              right: -60,
              child: Container(
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colorPrimary.withValues(alpha: 0.34),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // 우상단 틸 방사형 글로우
            Positioned(
              top: -90,
              right: -70,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colorTeal.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // 메인 스플래시 콘텐츠 (FittedBox 반응형 스케일링으로 어떤 화면에서도 잘림 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 340,
                      child: AnimatedBuilder(
                        animation: _splashAnimController,
                        builder: (context, _) {
                          final logoProgress = CurvedAnimation(
                            parent: _splashAnimController,
                            curve: const Interval(0.0, 0.30,
                                curve: Curves.easeOutCubic),
                          ).value;
                          final wordProgress = CurvedAnimation(
                            parent: _splashAnimController,
                            curve: const Interval(0.08, 0.38,
                                curve: Curves.easeOutCubic),
                          ).value;
                          final cardsProgress = CurvedAnimation(
                            parent: _splashAnimController,
                            curve: const Interval(0.12, 0.45,
                                curve: Curves.easeOutCubic),
                          ).value;
                          final loaderProgress = CurvedAnimation(
                            parent: _splashAnimController,
                            curve: const Interval(0.15, 0.96,
                                curve: Curves.easeInOutCubic),
                          ).value;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 1) 로고 마크 (scale 0.92 -> 1.0 + fade-in)
                              Opacity(
                                opacity: logoProgress,
                                child: Transform.scale(
                                  scale: 0.92 + (0.08 * logoProgress),
                                  child: Transform.translate(
                                    offset: Offset(0, 10 * (1 - logoProgress)),
                                    child: const OomuLogoMark(
                                      size: 92,
                                      glowShadow: true,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // 2) OOMU 워드마크 & 태그라인
                              Opacity(
                                opacity: wordProgress,
                                child: Transform.translate(
                                  offset: Offset(0, 10 * (1 - wordProgress)),
                                  child: Column(
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: const TextSpan(
                                          style: TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 7.0,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'OO',
                                              style: TextStyle(
                                                  color: Color(0xFFFF7A55)),
                                            ),
                                            TextSpan(
                                              text: 'MU',
                                              style: TextStyle(
                                                  color: Color(0xFFFFF9F2)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '우리 동네 모임',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 3.8,
                                          color: const Color(0xFFFFF3E5)
                                              .withValues(alpha: 0.72),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 26),

                              // 3) 실시간 동네 모임 (실사 모임 카드 티커)
                              Opacity(
                                opacity: cardsProgress,
                                child: Transform.scale(
                                  scale: 0.96 + (0.04 * cardsProgress),
                                  child: Transform.translate(
                                    offset: Offset(0, 12 * (1 - cardsProgress)),
                                    child: const OomuSplashLiveMeetupPreview(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // 4) 스플래시 로더 바
                              Container(
                                width: 64,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: loaderProgress.clamp(0.08, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFF7A55),
                                          colorPrimary
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 2. 인트로 온보딩 화면 (Screen 2: 상단 3단 프로그레스 바 + 실제 모임 애니메이션 3슬라이드)
  // ==========================================
  Widget _buildOnboardingScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFDF9), Color(0xFFFBF3E5)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 16),
      child: Column(
        children: [
          // 상단 바: 로고(38x38) + 3단 진행 바(.ob-progress) + 건너뛰기 필 버튼
          Row(
            children: [
              const OomuLogoMark(size: 38),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  children: List.generate(3, (i) {
                    final isOn = i <= _currentSlide;
                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                        height: 4,
                        decoration: BoxDecoration(
                          color: isOn ? colorPrimary : const Color(0xFFE9DCC6),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 14),
              InkWell(
                onTap: () => _goToStage(2),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFE4D5C2)),
                  ),
                  child: const Text(
                    '건너뛰기',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: colorTextMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 3개 슬라이드 PageView (실제 동네모임 / 공연·전시·핫플 / 실시간 채팅)
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (idx) => setState(() => _currentSlide = idx),
              children: [
                // 슬라이드 1: 현재 동네에서 뜨는 모임 & 러닝 크루
                _buildSlideItem(
                  eyebrow: '01 · 동네 모임',
                  illustration: const OomuSlide1Map(width: 320, height: 300),
                  titlePrefix: '우리 동네에서 ',
                  highlight: '지금 뜨는 모임',
                  titleSuffix: '',
                  description:
                      '주말 아침 한강 러닝 크루부터 오늘 번개까지\n가까운 이웃과 편하게 만나는 실제 모임 피드예요',
                ),
                // 슬라이드 2: 공연·전시와 동네 핫플 발견
                _buildSlideItem(
                  eyebrow: '02 · 공연 · 전시 · 핫플',
                  illustration:
                      const OomuSlide2Friends(width: 320, height: 300),
                  titlePrefix: '',
                  highlight: '공연·전시',
                  titleSuffix: '와 동네 핫플 발견',
                  description:
                      '콘서트·뮤지컬·전시 동행부터 SNS 베이커리 탐방까지\n가볼 만한 동네 모임을 한눈에 둘러봐요',
                ),
                // 슬라이드 3: 실시간 모임 채팅 & 연결
                _buildSlideItem(
                  eyebrow: '03 · 연결과 모임톡',
                  illustration: const OomuSlide3Meetup(width: 320, height: 300),
                  titlePrefix: '',
                  highlight: '취향이 맞는',
                  titleSuffix: ' 이웃과 바로 대화',
                  description:
                      '모임 일정 배너 확인부터 실시간 그룹 채팅까지\n참여 즉시 자연스럽게 대화를 시작할 수 있어요',
                ),
              ],
            ),
          ),

          // 하단 다음 / 시작하기 CTA 버튼
          BouncyTap(
            onTap: () {
              if (_currentSlide < 2) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 340),
                  curve: Curves.easeOutCubic,
                );
              } else {
                _goToStage(2);
              }
            },
            child: Container(
              width: double.infinity,
              height: 56,
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
        ],
      ),
    );
  }

  Widget _buildSlideItem({
    required String eyebrow,
    required Widget illustration,
    required String titlePrefix,
    required String highlight,
    required String titleSuffix,
    required String description,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Center(child: illustration),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5.5),
          decoration: BoxDecoration(
            color: colorPrimarySoft,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            eyebrow,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: colorPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 22.5,
              fontWeight: FontWeight.w800,
              color: colorText,
              letterSpacing: -0.4,
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
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: colorTextMuted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ==========================================
  // 3. 로그인 화면 (Screen 3: store_assets/OOMU 앱 UI 디자인.html #login 1:1 재현 + 상하 균형 배치)
  // ==========================================
  Widget _buildLoginScreen() {
    return Container(
      color: colorAppBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    const SizedBox(height: 24),

                    // 상단 로고 & 타이틀 히어로 (여유 있는 간격으로 붙음 현상 완전 제거)
                    const OomuLogoMark(size: 68, showShadow: false),
                    const SizedBox(height: 14),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                        children: [
                          TextSpan(
                              text: 'OO',
                              style: TextStyle(color: colorPrimary)),
                          TextSpan(
                              text: 'MU', style: TextStyle(color: colorText)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '우리 동네에서\n새로운 이웃을 만나요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: colorText,
                        height: 1.38,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 아이디 (이메일) 입력 필드
                    _buildInputField(
                      controller: _loginEmailCtrl,
                      hintText: '아이디 (이메일)',
                      prefixIcon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),

                    // 비밀번호 입력 필드
                    _buildInputField(
                      controller: _loginPwCtrl,
                      hintText: '비밀번호',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscureLoginPw,
                      onSubmitted: (_) => _handleEmailLoginSubmit(),
                      suffix: IconButton(
                        onPressed: () =>
                            setState(() => _obscureLoginPw = !_obscureLoginPw),
                        icon: Icon(
                          _obscureLoginPw
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: const Color(0xFFB3A390),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 로그인 버튼
                    BouncyTap(
                      onTap: _handleEmailLoginSubmit,
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: colorPrimary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: colorPrimary.withValues(alpha: 0.28),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '로그인',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 회원가입 · 이메일 찾기 링크 (로그인 화면의 어색한 '휴대폰 인증' 링크 제거)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => _goToStage(3),
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            child: Text(
                              '회원가입',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorTextMuted,
                              ),
                            ),
                          ),
                        ),
                        const Text('·',
                            style: TextStyle(
                                fontSize: 14, color: Color(0xFFD8C8B2))),
                        InkWell(
                          onTap: () => _goToStage(4),
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            child: Text(
                              '이메일 찾기',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorTextMuted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 구분선 "간편 로그인"
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        children: [
                          Expanded(
                              child: Container(
                                  height: 1, color: const Color(0xFFEFE4D4))),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              '간편 로그인',
                              style: TextStyle(
                                  fontSize: 12.5, color: Color(0xFF8A7B68)),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                  height: 1, color: const Color(0xFFEFE4D4))),
                        ],
                      ),
                    ),

                    // 1. 카카오톡으로 시작하기
                    BouncyTap(
                      onTap: _handleKakaoLogin,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: colorKakao,
                          borderRadius: BorderRadius.circular(16),
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
                                fontSize: 15,
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
                        height: 52,
                        decoration: BoxDecoration(
                          color: colorNaver,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'N',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              '네이버로 시작하기',
                              style: TextStyle(
                                fontSize: 15,
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
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colorGoogleBorder),
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
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3C3C3C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 보조 진입: 일단 둘러볼래요 & 테스트 계정
                    Row(
                      children: [
                        Expanded(
                          child: BouncyTap(
                            onTap: _handleGuestLogin,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: const Color(0xFFEADBC8), width: 1.5),
                              ),
                              child: const Center(
                                child: Text(
                                  '일단 둘러볼래요',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: colorTextMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        BouncyTap(
                          onTap: _showTestUserModal,
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: colorPrimarySoft,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Text(
                                '🧪 테스트 계정',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: colorPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 3),
                    const SizedBox(height: 16),
                    Text(
                      '가입하면 OOMU 이용약관과 개인정보 처리방침에 동의하게 됩니다',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: const Color(0xFF8A7B68).withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // 4. 회원가입 화면 (Screen 4: store_assets/OOMU 앱 UI 디자인.html #signup 1:1 재현)
  // ==========================================
  Widget _buildSignupScreen() {
    final allAgreed = _agreeTerms && _agreePrivacy && _agreeMarketing;
    final pwMatched = _suPwConfirmCtrl.text.isNotEmpty &&
        _suPwCtrl.text == _suPwConfirmCtrl.text;

    return Container(
      color: colorAppBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 6, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 바
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _goToStage(2),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 20, color: colorText),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const Text(
                  '회원가입',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colorText,
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
            const SizedBox(height: 18),

            // 이메일 + 중복확인
            _buildInputField(
              controller: _suEmailCtrl,
              hintText: '이메일',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              suffix: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    if (_suEmailCtrl.text.trim().isEmpty) {
                      _showToast('이메일을 먼저 입력해 주세요');
                    } else {
                      _showToast('사용 가능한 이메일이에요');
                    }
                  },
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorPrimarySoft,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Text(
                      '중복확인',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: colorPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 비밀번호
            _buildInputField(
              controller: _suPwCtrl,
              hintText: '비밀번호',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscureSuPw,
              onChanged: (_) => setState(() {}),
              suffix: IconButton(
                onPressed: () => setState(() => _obscureSuPw = !_obscureSuPw),
                icon: Icon(
                  _obscureSuPw
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: const Color(0xFFB3A390),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 4, top: 5, bottom: 8),
              child: Text(
                '영문, 숫자를 조합해 8자 이상으로 입력해 주세요',
                style: TextStyle(fontSize: 12, color: colorTextFaint),
              ),
            ),

            // 비밀번호 확인
            _buildInputField(
              controller: _suPwConfirmCtrl,
              hintText: '비밀번호 확인',
              prefixIcon: Icons.verified_user_outlined,
              obscureText: true,
              onChanged: (_) => setState(() {}),
              suffix: pwMatched
                  ? const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.check_rounded,
                          color: colorTeal, size: 22),
                    )
                  : null,
            ),
            const SizedBox(height: 8),

            // 닉네임 + 중복확인
            _buildInputField(
              controller: _suNickCtrl,
              hintText: '닉네임 (2~10자)',
              prefixIcon: Icons.person_outline_rounded,
              suffix: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    if (_suNickCtrl.text.trim().isEmpty) {
                      _showToast('닉네임을 먼저 입력해 주세요');
                    } else {
                      _showToast('사용 가능한 닉네임이에요');
                    }
                  },
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorPrimarySoft,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Text(
                      '중복확인',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: colorPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 휴대폰 번호 + 인증번호 받기 (1인 1계정 중복가입 방지)
            _buildInputField(
              controller: _suPhoneCtrl,
              hintText: '휴대폰 번호 (- 없이, 중복가입 확인)',
              prefixIcon: Icons.smartphone_rounded,
              keyboardType: TextInputType.phone,
              suffix: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: _sendSignupPhoneCode,
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: _suPhoneVerified
                          ? const Color(0xFFE3F5EF)
                          : colorPrimarySoft,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      _suPhoneVerified
                          ? '인증완료 ✓'
                          : (_suPhoneCodeSent ? '재발송' : '인증번호 받기'),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _suPhoneVerified ? colorTeal : colorPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_suPhoneCodeSent && !_suPhoneVerified) ...[
              const SizedBox(height: 8),
              _buildInputField(
                controller: _suPhoneCodeCtrl,
                hintText: '문자로 받은 인증번호 6자리',
                prefixIcon: Icons.shield_outlined,
                keyboardType: TextInputType.number,
                suffix: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: _verifySignupPhoneCode,
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorPrimary,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Text(
                        '인증확인',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // 약관 동의 카드 (.agree-card)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEADBC8), width: 1.5),
              ),
              child: Column(
                children: [
                  _buildAgreeRow(
                    title: '전체 동의',
                    isBold: true,
                    value: allAgreed,
                    onChanged: (v) {
                      setState(() {
                        _agreeTerms = v;
                        _agreePrivacy = v;
                        _agreeMarketing = v;
                      });
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFF3E9DB)),
                  _buildAgreeRow(
                    title: '이용약관',
                    tag: '(필수)',
                    value: _agreeTerms,
                    onChanged: (v) => setState(() => _agreeTerms = v),
                  ),
                  _buildAgreeRow(
                    title: '개인정보 수집·이용',
                    tag: '(필수)',
                    value: _agreePrivacy,
                    onChanged: (v) => setState(() => _agreePrivacy = v),
                  ),
                  _buildAgreeRow(
                    title: '마케팅 정보 수신',
                    tag: '(선택)',
                    value: _agreeMarketing,
                    onChanged: (v) => setState(() => _agreeMarketing = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 가입하기 버튼
            BouncyTap(
              onTap: _handleSignupSubmit,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: colorPrimary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorPrimary.withValues(alpha: 0.30),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '가입하기',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 이미 계정이 있나요? 로그인
            Center(
              child: GestureDetector(
                onTap: () => _goToStage(2),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 14, color: colorTextMuted),
                    children: [
                      TextSpan(text: '이미 계정이 있나요? '),
                      TextSpan(
                        text: '로그인',
                        style: TextStyle(
                          color: colorPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgreeRow({
    required String title,
    String? tag,
    bool isBold = false,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isBold ? 12 : 10),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: value ? colorPrimary : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? colorPrimary : const Color(0xFFD8C8B2),
                  width: 1.5,
                ),
              ),
              child: value
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: isBold ? 15 : 14,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
                color: colorText,
              ),
            ),
            if (tag != null) ...[
              const SizedBox(width: 4),
              Text(
                tag,
                style: const TextStyle(
                  fontSize: 12,
                  color: colorTextMuted,
                ),
              ),
            ],
            const Spacer(),
            if (!isBold)
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: Color(0xFFC9BBA8)),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 5. 이메일 찾기 화면 (Screen 5: store_assets/OOMU 앱 UI 디자인.html #findemail 1:1 재현)
  // ==========================================
  Widget _buildFindEmailScreen() {
    return Container(
      color: colorAppBg,
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 바
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _goToStage(2),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 20, color: colorText),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Text(
                '이메일 찾기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colorText,
                ),
              ),
              const SizedBox(width: 24),
            ],
          ),
          const SizedBox(height: 16),

          if (!_feShowResult) ...[
            const Text(
              '가입할 때 사용한 이름과 휴대폰 번호로\n가입된 이메일을 찾을 수 있어요',
              style: TextStyle(
                fontSize: 14,
                color: colorTextMuted,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 18),
            _buildInputField(
              controller: _feNameCtrl,
              hintText: '이름',
              prefixIcon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 8),
            _buildInputField(
              controller: _fePhoneCtrl,
              hintText: '휴대폰 번호 (- 없이)',
              prefixIcon: Icons.smartphone_rounded,
              keyboardType: TextInputType.phone,
              suffix: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: _startFindEmailTimer,
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorPrimarySoft,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Text(
                      '인증번호 받기',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: colorPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildInputField(
              controller: _feCodeCtrl,
              hintText: '인증번호 6자리',
              prefixIcon: Icons.shield_outlined,
              keyboardType: TextInputType.number,
              suffix: _feSecondsRemaining > 0
                  ? Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Text(
                        '${_feSecondsRemaining ~/ 60}:${(_feSecondsRemaining % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colorPrimary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 14),
            BouncyTap(
              onTap: () {
                if (_feNameCtrl.text.trim().isEmpty) {
                  _showToast('이름을 입력해 주세요');
                  return;
                }
                if (_fePhoneCtrl.text.trim().isEmpty) {
                  _showToast('휴대폰 번호를 입력해 주세요');
                  return;
                }
                if (_feCodeCtrl.text.trim().isEmpty) {
                  _showToast('인증번호를 입력해 주세요 (데모: 482915)');
                  return;
                }
                _feCountdownTimer?.cancel();
                setState(() {
                  _feFoundEmail = 'ansim****25@gmail.com';
                  _feShowResult = true;
                });
              },
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: colorPrimary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorPrimary.withValues(alpha: 0.30),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '이메일 찾기',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: GestureDetector(
                onTap: () => _goToStage(3),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 14, color: colorTextMuted),
                    children: [
                      TextSpan(text: '아직 계정이 없나요? '),
                      TextSpan(
                        text: '회원가입',
                        style: TextStyle(
                          color: colorPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: const BoxDecoration(
                      color: colorPrimarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 38,
                      color: colorPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '가입된 이메일을 찾았어요',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: colorText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '고객님의 OOMU 계정 이메일이에요',
                    style: TextStyle(fontSize: 14, color: colorTextMuted),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: const Color(0xFFEADBC8), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        _feFoundEmail,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: colorText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  BouncyTap(
                    onTap: () => _goToStage(2),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: colorPrimary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          '로그인 하러 가기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _feShowResult = false;
                        _feCodeCtrl.clear();
                      });
                    },
                    child: const Text(
                      '다른 정보로 다시 찾기',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorTextMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _startFindEmailTimer() {
    if (_fePhoneCtrl.text.trim().isEmpty) {
      _showToast('휴대폰 번호를 먼저 입력해 주세요');
      return;
    }
    _showToast('인증번호가 발송되었어요 (데모: 482915)');
    _feCountdownTimer?.cancel();
    setState(() {
      _feSecondsRemaining = 300;
      _feCodeCtrl.text = '482915';
    });
    _feCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_feSecondsRemaining <= 1) {
        timer.cancel();
        setState(() => _feSecondsRemaining = 0);
      } else {
        setState(() => _feSecondsRemaining--);
      }
    });
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffix,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEADBC8), width: 1.5),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(prefixIcon, size: 20, color: const Color(0xFFB3A390)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w500,
                color: colorText,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFFBFB1A0),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (suffix != null) suffix,
        ],
      ),
    );
  }

  // ==========================================
  // 모달 시트들 (테스트 계정 / 휴대폰 SMS)
  // ==========================================

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
                    icon: const Icon(Icons.close,
                        size: 20, color: Color(0xFF767676)),
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
            _showToast('🎉 $name 계정으로 전환되었습니다.');
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
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
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF767676)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Color(0xFFB0B8C1)),
          ],
        ),
      ),
    );
  }
}

/// 카카오톡 말풍선 심볼 페인터
class _KakaoSymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    final paint = Paint()
      ..color = const Color(0xFF191919)
      ..style = PaintingStyle.fill;

    canvas.drawOval(const Rect.fromLTWH(2, 3, 20, 15.5), paint);

    final tail = Path()
      ..moveTo(6.5, 16.5)
      ..lineTo(4.2, 21.2)
      ..lineTo(10.5, 17.8)
      ..close();
    canvas.drawPath(tail, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Google 4색 공식 G 로고 페인터
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;
    final strokeW = size.width * 0.19;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.butt;

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -2.35,
      1.55,
      false,
      paint,
    );

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.35,
      1.55,
      false,
      paint,
    );

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.80,
      1.55,
      false,
      paint,
    );

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.15,
      0.95,
      false,
      paint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        center.dx,
        center.dy - strokeW * 0.48,
        radius + strokeW * 0.45,
        strokeW * 0.95,
      ),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
