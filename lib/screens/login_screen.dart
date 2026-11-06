import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'profile_setup_screen.dart';
import 'package:flutter/material.dart';
import 'soso_car_home_screen.dart';
import '../services/auth_service.dart';
import '../utils/global_data.dart';
import '../utils/web_redirect_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Color brandCoral = const Color(0xFFF25767);
  final Color textPrimary = const Color(0xFF191F28);
  final Color textSecondary = const Color(0xFF6B7684);

  bool _isLoading = false;
  bool _hasProcessedKakaoCode = false;

  @override
  void initState() {
    super.initState();
    _checkKakaoOAuthRedirect();
  }

  void _checkKakaoOAuthRedirect() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_hasProcessedKakaoCode) return;
      try {
        final uri = Uri.base;
        String? code = uri.queryParameters['code'];
        String? error = uri.queryParameters['error'];
        String? errorDesc = uri.queryParameters['error_description'];

        // 모바일 브라우저 또는 Flutter Web HashUrlStrategy로 인해 # 뒤에 파라미터가 붙는 경우 파싱
        if ((code == null || code.isEmpty) && uri.fragment.isNotEmpty) {
          final fragmentStr = uri.fragment;
          final qIndex = fragmentStr.indexOf('?');
          if (qIndex != -1) {
            final queryPart = fragmentStr.substring(qIndex + 1);
            final params = Uri.splitQueryString(queryPart);
            code ??= params['code'];
            error ??= params['error'];
            errorDesc ??= params['error_description'];
          }
        }

        // 카카오 OAuth 에러 파라미터 응답 시 사용자에게 명확한 원인 안내
        if (error != null && error.isNotEmpty) {
          _hasProcessedKakaoCode = true;
          if (mounted) {
            _hideLoading();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('카카오 인증 알림 [$error]: ${errorDesc ?? "인증이 취소되었거나 거절되었습니다."}'),
                backgroundColor: const Color(0xFFD9384A),
                duration: const Duration(seconds: 4),
              ),
            );
          }
          return;
        }

        if (code != null && code.isNotEmpty) {
          _hasProcessedKakaoCode = true;
          _showLoading('💬 카카오 공식 인증 정보 확인 중...');
          await authService.handleKakaoOAuthCode(code);
          if (mounted) {
            _hideLoading();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 카카오 계정 인증 완료! 환영합니다.'),
                backgroundColor: Color(0xFFFAE100),
              ),
            );
            _navigateHome();
          }
        }
      } catch (e) {
        if (mounted) {
          _hideLoading();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('카카오 인증 실패: $e'),
              backgroundColor: const Color(0xFFD9384A),
              duration: const Duration(seconds: 5),
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
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: brandCoral,
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
        debugPrint('[LoginScreen] Check profile complete fallback: $e');
      }
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OOMUHomeScreen()),
      );
    }
  }

  // 1. 카카오 로그인 (모바일 브라우저 팝업 차단 원천 방지 redirectToExternalUrl 적용)
  Future<void> _handleKakaoLogin() async {
    if (_isLoading) return;
    _showLoading('카카오 로그인 페이지로 이동 중…');
    try {
      final opened = await redirectToExternalUrl(authService.kakaoOAuthUrl);
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('카카오 로그인 페이지를 열지 못했어요. 다시 시도해 주세요.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('카카오 로그인 연결 실패: $e')));
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
      if (mounted &&
          e.code != 'popup-closed-by-user' &&
          e.code != 'cancelled-popup-request') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Google 로그인을 완료하지 못했어요. 다시 시도해 주세요.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('연결 상태를 확인하고 다시 시도해 주세요.')));
      }
    } finally {
      if (mounted) _hideLoading();
    }
  }

  // 3. 게스트 둘러보기 (로그인 없이 바로 앱 체험)
  Future<void> _handleGuestLogin() async {
    _showLoading('동네 모임 둘러보기 입장 중...');
    try {
      await authService.signInAsGuest();
      _navigateHome();
    } catch (_) {
      _navigateHome();
    }
  }

  // 4. 체험용 테스트 계정 바텀시트
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
                '원하는 페르소나를 선택하면 해당 프로필로 1초 만에 전환됩니다.',
                style: TextStyle(fontSize: 13, color: Color(0xFF767676)),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 8),
              _buildTestUserTile(
                ctx,
                uid: 'LZs5U32GQJMkK77hkmaJupgKzwE2',
                name: '우리동네_초연',
                desc: '29세 · 여성 · 전남 여수시 화장동 (test11@naver.com)',
                badge: '여수 로컬',
                avatar: 'assets/images/초연.png',
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
            await _navigateHome(skipProfileCheck: true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎉 $name($desc) 계정으로 전환되었습니다.'),
                duration: const Duration(seconds: 2),
                backgroundColor: brandCoral,
              ),
            );
          }
        } catch (e) {
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
                          color: brandCoral.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: brandCoral,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF767676),
                    ),
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

  // 4. 휴대폰 SMS 인증 바텀시트
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

  // 5. 이메일 로그인 / 회원가입 바텀시트
  void _showEmailAuthModal({bool isSignUp = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _EmailAuthSheet(
        initialIsSignUp: isSignUp,
        onSuccess: () {
          Navigator.pop(ctx);
          _navigateHome();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. 상단 액션 바 (닫기 X & 둘러보기/테스트 계정)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 좌측 닫기 버튼 (누르면 둘러보기로 홈 진입)
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                size: 26, color: Color(0xFF333D4B)),
                            onPressed: _isLoading ? null : _handleGuestLogin,
                            tooltip: '둘러보기로 이동',
                          ),
                          // 우측 체험 계정 & 둘러보기 (대형 글자 시 자동 스케일 다운)
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed:
                                        _isLoading ? null : _showTestUserModal,
                                    child: const Text(
                                      '🧪 테스트 계정',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6B7684),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed:
                                        _isLoading ? null : _handleGuestLogin,
                                    child: const Text(
                                      '둘러보기 ›',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF191F28),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

              // 2. 중앙 브랜드 심볼 & 슬로건 (요기요 스타일의 깔끔한 중앙 정렬)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // OOMU 브랜드 엠블럼
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [brandCoral, const Color(0xFFFF7E8B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: brandCoral.withValues(alpha: 0.28),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.favorite_rounded, color: Colors.white, size: 36),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 메인 브랜드명
                  Text(
                    'OOMU',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 친근하고 감성적인 슬로건
                  const Text(
                    '가보고 싶은 곳에서,\n함께할 동네 이웃을 만나요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF333D4B),
                      height: 1.45,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '야구 직관, 핫플 오픈런, 주말 공연 동행까지',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8B95A1),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 3. 하단 간편가입 / 로그인 버튼군 (요기요 스타일 3단 버튼)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1) 카카오로 계속하기
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleKakaoLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE500),
                        foregroundColor: const Color(0xFF191919),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_rounded,
                                size: 18, color: Color(0xFF191919)),
                            SizedBox(width: 8),
                            Text(
                              '카카오로 계속하기',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF191919),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2) Google로 계속하기
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _handleGoogleLogin,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: textPrimary,
                        side: const BorderSide(
                            color: Color(0xFFE2E8F0), width: 1.2),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'G',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF4285F4),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Google로 계속하기',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF191F28),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 3) 이메일로 계속하기 (요기요 서피스 버튼 스타일)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => _showEmailAuthModal(isSignUp: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2F4F7),
                        foregroundColor: const Color(0xFF333D4B),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mail_outline_rounded,
                                size: 19, color: Color(0xFF333D4B)),
                            SizedBox(width: 8),
                            Text(
                              '이메일로 계속하기',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333D4B),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 4) 직접 회원가입 / 휴대폰 / 비밀번호 찾기 (Kiwiplay 스타일 서브 액션)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _isLoading ? null : _showPhoneAuthModal,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            child: Text(
                              '휴대폰 번호로 시작하기',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF6B7684),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 1,
                          height: 12,
                          color: const Color(0xFFCBD5E1),
                        ),
                        GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () => _showEmailAuthModal(isSignUp: true),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            child: Text(
                              '이메일 가입',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF6B7684),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 1,
                          height: 12,
                          color: const Color(0xFFCBD5E1),
                        ),
                        GestureDetector(
                          onTap: _isLoading ? null : _handleGuestLogin,
                          child: Text(
                            '둘러보기',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: brandCoral,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5) 약관 안내
                  Text(
                    '로그인 시 OOMU 이용약관 및 개인정보처리방침에 동의하게 됩니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF8B95A1),
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: bottomPadding > 0 ? bottomPadding : 12),
                ],
              ),
            ],
          ),
        ),
      )))),
    );
  }
}


class _EmailAuthSheet extends StatefulWidget {
  final bool initialIsSignUp;
  final VoidCallback onSuccess;

  const _EmailAuthSheet({
    required this.initialIsSignUp,
    required this.onSuccess,
  });

  @override
  State<_EmailAuthSheet> createState() => _EmailAuthSheetState();
}

class _EmailAuthSheetState extends State<_EmailAuthSheet> {
  late bool _isSignUp;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialIsSignUp;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = '이메일과 비밀번호를 모두 입력해주세요.');
      return;
    }

    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      setState(() => _errorMessage = '이메일 주소를 확인해 주세요.');
      return;
    }
    if (_isSignUp &&
        (_nameController.text.trim().isEmpty ||
            _nicknameController.text.trim().isEmpty ||
            password.length < 6)) {
      setState(() => _errorMessage = '이름과 닉네임, 6자 이상의 비밀번호를 입력해 주세요.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_isSignUp) {
        await authService.signUpWithEmail(
          email: email,
          password: password,
          name: _nameController.text.trim(),
          nickname: _nicknameController.text.trim(),
        );
      } else {
        await authService.signInWithEmail(email, password);
      }
      if (!mounted) return;
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final code = e is FirebaseAuthException ? e.code : '';
        _errorMessage = switch (code) {
          'email-already-in-use' => '이미 가입된 이메일이에요. 로그인해 주세요.',
          'invalid-credential' ||
          'wrong-password' ||
          'user-not-found' =>
            '이메일과 비밀번호를 다시 확인해 주세요.',
          'too-many-requests' => '요청이 많아요. 잠시 후 다시 시도해 주세요.',
          'network-request-failed' => '연결 상태를 확인하고 다시 시도해 주세요.',
          _ => '로그인을 완료하지 못했어요. 잠시 후 다시 시도해 주세요.',
        };
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandCoral = Color(0xFFF25767);
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

            // 상단 탭 (로그인 / 회원가입)
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isSignUp = false),
                  child: Text(
                    '로그인',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: !_isSignUp ? brandCoral : const Color(0xFF8E8E93),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => setState(() => _isSignUp = true),
                  child: Text(
                    '회원가입',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _isSignUp ? brandCoral : const Color(0xFF8E8E93),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_isSignUp) ...[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '이름 (실명)',
                  filled: true,
                  fillColor: surfaceColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: '닉네임 (활동명)',
                  filled: true,
                  fillColor: surfaceColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
            ],

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: '이메일 주소',
                filled: true,
                fillColor: surfaceColor,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '비밀번호',
                suffixIcon: IconButton(
                    tooltip: _obscurePassword ? '비밀번호 보기' : '비밀번호 숨기기',
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined)),
                filled: true,
                fillColor: surfaceColor,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
              ),
            ),

            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage,
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandCoral,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(
                        _isSignUp ? '계정 만들고 프로필 설정하기' : '로그인하기',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneAuthSheet extends StatefulWidget {
  final VoidCallback onSuccess;

  const _PhoneAuthSheet({required this.onSuccess});

  @override
  State<_PhoneAuthSheet> createState() => _PhoneAuthSheetState();
}

class _PhoneAuthSheetState extends State<_PhoneAuthSheet> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isCodeSent = false;
  bool _isLoading = false;
  String? _verificationId;
  String _errorMessage = '';

  int _timerSeconds = 180;
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timerSeconds = 180);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        if (mounted) setState(() => _timerSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String get _formattedTimer {
    final minutes = (_timerSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_timerSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _sendCode() async {
    final rawPhone = _phoneController.text.trim();
    if (rawPhone.isEmpty ||
        rawPhone.replaceAll(RegExp(r'[^0-9]'), '').length < 9) {
      setState(() => _errorMessage = '올바른 휴대폰 번호(10~11자리)를 입력해 주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    await authService.sendPhoneSmsCode(
      rawPhone: rawPhone,
      onAutoVerified: () {
        if (mounted) {
          setState(() => _isLoading = false);
          widget.onSuccess();
        }
      },
      onCodeSent: (vId) {
        if (mounted) {
          setState(() {
            _verificationId = vId;
            _isCodeSent = true;
            _isLoading = false;
          });
          _startTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📱 SMS 인증번호가 전송되었습니다! 문자를 확인해 주세요.'),
              backgroundColor: Color(0xFFF25767),
            ),
          );
        }
      },
      onError: (msg) {
        if (mounted) {
          setState(() {
            _errorMessage = msg;
            _isLoading = false;
          });
        }
      },
    );
  }

  Future<void> _verifyCode() async {
    final smsCode = _otpController.text.trim();
    if (smsCode.length < 6) {
      setState(() => _errorMessage = '6자리 인증번호를 정확히 입력해 주세요.');
      return;
    }
    if (_verificationId == null) {
      setState(() => _errorMessage = '인증번호를 먼저 발송받아 주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await authService.verifyPhoneSmsCodeAndSignIn(
        verificationId: _verificationId!,
        smsCode: smsCode,
        rawPhone: _phoneController.text.trim(),
      );
      if (mounted) {
        setState(() => _isLoading = false);
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '인증번호가 일치하지 않거나 만료되었습니다. ($e)';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandCoral = Color(0xFFF25767);
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
                  child: const Icon(Icons.smartphone_rounded,
                      size: 22, color: brandCoral),
                ),
                const SizedBox(width: 12),
                const Text(
                  '휴대폰 번호로 인증',
                  style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111111)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '입력하신 휴대폰 번호로 SMS 인증번호 6자리가 발송됩니다.',
              style: TextStyle(fontSize: 13, color: Color(0xFF767676)),
            ),
            const SizedBox(height: 20),

            // 1. 휴대폰 번호 입력칸 + 발송 버튼
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    enabled: !_isCodeSent || _timerSeconds == 0,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '휴대폰 번호 (예: 01012345678)',
                      filled: true,
                      fillColor: surfaceColor,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                        (_isLoading || (_isCodeSent && _timerSeconds > 150))
                            ? null
                            : _sendCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isCodeSent ? const Color(0xFF111111) : brandCoral,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      _isCodeSent
                          ? (_timerSeconds > 150
                              ? '${_timerSeconds - 150}초 후 재발송'
                              : '재발송')
                          : '인증요청',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                  ),
                ),
              ],
            ),

            // 2. 인증번호 6자리 입력칸 (발송 완료시 나타남)
            if (_isCodeSent) ...[
              const SizedBox(height: 14),
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      hintText: '인증번호 6자리 입력',
                      counterText: '',
                      filled: true,
                      fillColor: surfaceColor,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      _formattedTimer,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _timerSeconds > 30 ? brandCoral : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage,
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ],

            const SizedBox(height: 24),

            if (_isCodeSent)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandCoral,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text(
                          '인증 확인 및 시작하기',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
