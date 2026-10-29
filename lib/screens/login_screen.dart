import 'dart:async';
import 'profile_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'soso_car_home_screen.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Color brandCoral = const Color(0xFFF25767);
  final Color textPrimary = const Color(0xFF111111);
  final Color textSecondary = const Color(0xFF767676);
  final Color surfaceColor = const Color(0xFFF7F7FA);

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkKakaoOAuthRedirect();
  }

  void _checkKakaoOAuthRedirect() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final uri = Uri.base;
        if (uri.queryParameters.containsKey('code')) {
          final code = uri.queryParameters['code']!;
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
            SnackBar(content: Text('카카오 인증 실패: $e')),
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
            Text(message),
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

    Future<void> _navigateHome() async {
    _hideLoading();
    if (!mounted) return;

    try {
      final user = authService.currentUser;
      if (user != null && !authService.isAdmin) {
        final isComplete = await authService.isUserProfileComplete(user.uid);
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

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OOMUHomeScreen()),
      );
    }
  }

  // 1. 카카오 로그인 (공식 OAuth 화면 열기 + 내 실제 카카오 계정 연동)
  void _handleKakaoLogin() {
    final emailController = TextEditingController();
    final nickController = TextEditingController();
    bool isDirectMode = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44, height: 4,
                    decoration: BoxDecoration(color: const Color(0xFFE5E5EA), borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAE100),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chat_bubble_rounded, size: 20, color: Color(0xFF391B1B)),
                    ),
                    const SizedBox(width: 12),
                    const Text('카카오 계정으로 시작하기', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF111111))),
                  ],
                ),
                const SizedBox(height: 8),
                Text('공식 카카오 계정으로 안전하게 인증하고 동네 모임을 시작하세요.', style: TextStyle(fontSize: 13, color: textSecondary)),
                const SizedBox(height: 24),

                // [옵션 1] 공식 카카오 OAuth 간편 로그인 버튼
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFAE100),
                      foregroundColor: const Color(0xFF391B1B),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text('🚀 공식 카카오 로그인 화면 열기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final kakaoUri = Uri.parse(authService.kakaoOAuthUrl);
                      try {
                        await launchUrl(kakaoUri, webOnlyWindowName: '_self');
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('카카오 로그인 창 열기 실패: $e')),
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16),
                Center(
                  child: Text('또는', style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 16),

                // [옵션 2] 내 실제 카카오 계정/이메일로 직접 연결 폼
                if (!isDirectMode)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textPrimary,
                        side: const BorderSide(color: Color(0xFFE5E5EB)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.badge_outlined, size: 18),
                      label: const Text('✉️ 내 카카오 이메일/닉네임으로 직접 연동', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      onPressed: () {
                        setModalState(() => isDirectMode = true);
                      },
                    ),
                  )
                else ...[
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: '실제 카카오 계정 이메일 (예: user@kakao.com)',
                      filled: true,
                      fillColor: surfaceColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nickController,
                    decoration: InputDecoration(
                      hintText: '내 닉네임 (예: 홍길동)',
                      filled: true,
                      fillColor: surfaceColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF391B1B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final email = emailController.text.trim();
                        final nick = nickController.text.trim();
                        if (email.isEmpty || !email.contains('@')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('올바른 카카오 이메일을 입력해주세요.')),
                          );
                          return;
                        }
                        Navigator.pop(ctx);
                        _showLoading('💬 내 카카오 계정 연동 중...');
                        try {
                          await authService.signInWithRealKakaoAccount(
                            kakaoEmail: email,
                            kakaoNickname: nick.isNotEmpty ? nick : email.split('@').first,
                          );
                          if (mounted) {
                            _hideLoading();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('🎉 내 카카오 계정으로 성공적으로 연동되었습니다!')),
                            );
                            _navigateHome();
                          }
                        } catch (e) {
                          _hideLoading();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('연동 실패: $e')),
                            );
                          }
                        }
                      },
                      child: const Text('내 카카오 계정으로 연동 및 시작', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 2. 구글 로그인
  Future<void> _handleGoogleLogin() async {
    _showLoading('🌐 Google 계정으로 로그인 중...');
    try {
      final credential = await authService.signInWithGoogle();
      if (credential != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Google 계정으로 로그인되었습니다!')),
        );
        _navigateHome();
      }
    } catch (e) {
      _hideLoading();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google 로그인 실패: $e')),
        );
      }
    }
  }

  // 3. 관리자 직접 빠른 접속
  Future<void> _handleAdminDirectLogin() async {
    _showLoading('👑 총괄 관리자 계정(ansimhyang60@naver.com) 인증 중...');
    try {
      await authService.signInAsAdmin();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('👑 총괄 관리자 권한으로 로그인되었습니다!'),
            backgroundColor: Color(0xFF1E1E24),
          ),
        );
        _navigateHome();
      }
    } catch (e) {
      _hideLoading();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('관리자 로그인 실패: $e')),
        );
      }
    }
  }

  // 4. 게스트 둘러보기
  Future<void> _handleGuestLogin() async {
    _showLoading('동네 모임 둘러보기 입장 중...');
    try {
      await authService.signInAsGuest();
      _navigateHome();
    } catch (_) {
      _navigateHome();
    }
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

  // 6. 휴대폰 번호 SMS 인증 바텀시트
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 휴대폰 번호 인증이 완료되었습니다! 환영합니다.'),
              backgroundColor: Color(0xFFF25767),
            ),
          );
          _navigateHome();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 상단 우측 둘러보기
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _isLoading ? null : _handleGuestLogin,
                  child: Text(
                    '둘러보기 ›',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // 중앙 브랜드 소개 영역 (당근마켓 스타일)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 앱 로고 아이콘
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [brandCoral, const Color(0xFFFF7E8B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: brandCoral.withOpacity(0.32),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.favorite_rounded,
                            color: brandCoral,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 앱 이름
                  Text(
                    'OOMU',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // 우리 동네 무드
                  Text(
                    '우리 동네 무드',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: brandCoral,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 모임 소개 문구
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '어색한 1:1 만남 대신 재밌는 모임에서 시작해\n자연스러운 동네 친구이자 연인을 만들어 보세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.5,
                        color: textSecondary,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              // 하단 로그인 및 가입 액션 버튼군
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. 휴대폰 번호로 시작하기 (실제 SMS OTP 전송)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _showPhoneAuthModal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandCoral,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.smartphone_rounded, size: 20, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            '휴대폰 번호로 시작하기',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. 카카오로 시작하기
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
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_rounded, size: 18, color: Color(0xFF191919)),
                          SizedBox(width: 8),
                          Text(
                            '카카오계정으로 시작하기',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. Google 계정으로 시작하기
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _handleGoogleLogin,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: textPrimary,
                        side: const BorderSide(color: Color(0xFFE5E5EA), width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('G', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF4285F4))),
                          SizedBox(width: 8),
                          Text(
                            'Google 계정으로 시작하기',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 3. 이메일로 가입 / 시작하기
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _showEmailAuthModal(isSignUp: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandCoral,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mail_outline_rounded, size: 19, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            '이메일로 직접 시작하기',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 4. 하단 텍스트 링크 (이미 계정이 있나요? 로그인)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '이미 계정이 있나요?',
                        style: TextStyle(fontSize: 13.5, color: textSecondary),
                      ),
                      TextButton(
                        onPressed: _isLoading ? null : () => _showEmailAuthModal(isSignUp: false),
                        child: Text(
                          '로그인',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: brandCoral,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ),
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

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialIsSignUp;
  }

  void _fillAdminAccount() {
    setState(() {
      _isSignUp = false;
      _emailController.text = 'ansimhyang60@naver.com';
      _passwordController.text = 'test_simhyang99';
      _errorMessage = '';
    });
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = '이메일과 비밀번호를 모두 입력해주세요.');
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
      widget.onSuccess();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandCoral = Color(0xFFF25767);
    const Color textPrimary = Color(0xFF111111);
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: '닉네임 (활동명)',
                  filled: true,
                  fillColor: surfaceColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
            ],

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: '이메일 주소',
                filled: true,
                fillColor: surfaceColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '비밀번호',
                filled: true,
                fillColor: surfaceColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),

            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        _isSignUp ? '가입 완료하고 시작하기' : '로그인하기',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
    if (rawPhone.isEmpty || rawPhone.replaceAll(RegExp(r'[^0-9]'), '').length < 9) {
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
                    color: brandCoral.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smartphone_rounded, size: 22, color: brandCoral),
                ),
                const SizedBox(width: 12),
                const Text(
                  '휴대폰 번호로 인증',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Color(0xFF111111)),
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: (_isLoading || (_isCodeSent && _timerSeconds > 150)) ? null : _sendCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isCodeSent ? const Color(0xFF111111) : brandCoral,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      _isCodeSent
                          ? (_timerSeconds > 150 ? '${_timerSeconds - 150}초 후 재발송' : '재발송')
                          : '인증요청',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(
                          '인증 확인 및 시작하기',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
