import 'package:flutter/material.dart';
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

  void _navigateHome() {
    _hideLoading();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OOMUHomeScreen()),
    );
  }

  // 1. 카카오 로그인
  Future<void> _handleKakaoLogin() async {
    _showLoading('💬 카카오 계정으로 동적 로그인 중...');
    try {
      await authService.signInWithKakao(
        kakaoNickname: '카카오이웃',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 카카오 계정으로 성공적으로 시작했습니다!')),
        );
        _navigateHome();
      }
    } catch (e) {
      _hideLoading();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카카오 로그인 실패: $e')),
        );
      }
    }
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
                  // 1. 카카오로 시작하기 (실제 작동하는 동적 로그인)
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
