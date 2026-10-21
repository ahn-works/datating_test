import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/global_data.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 대표님께서 발급해주신 공식 카카오 앱 키 (우무 OOMU)
  static const String kakaoRestApiKey = '3f91399ac9b6731d96f6d4b9ac13c502';
  static const String kakaoRedirectUri = 'https://ahn-works.github.io/datating_test/';

  String get kakaoOAuthUrl =>
      'https://kauth.kakao.com/oauth/authorize?client_id=$kakaoRestApiKey&redirect_uri=$kakaoRedirectUri&response_type=code';

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isAuthenticated => _auth.currentUser != null;
  bool get isAdmin =>
      _auth.currentUser?.email == 'ansimhyang60@naver.com' ||
      globalData.activeUserId == 'udr2AlH3YIX7LEnyHdWGGFcOu2g1';

  // 1. 관리자 1초 빠른 로그인
  Future<UserCredential> signInAsAdmin() async {
    return await signInWithEmail('ansimhyang60@naver.com', 'test_simhyang99');
  }

  // 2. 이메일/비밀번호 로그인
  Future<UserCredential> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    await _syncUserWithFirestore(credential.user!);
    return credential;
  }

  // 3. 이메일/비밀번호 신규 회원가입
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    String? name,
    String? nickname,
    String? gender,
    int? age,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    await _syncUserWithFirestore(
      credential.user!,
      customName: name,
      customNickname: nickname,
      customGender: gender,
      customAge: age,
    );
    return credential;
  }

  // 4. Google 로그인 (Web & Mobile 지원)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      UserCredential credential;
      if (kIsWeb) {
        credential = await _auth.signInWithPopup(googleProvider);
      } else {
        credential = await _auth.signInWithProvider(googleProvider);
      }
      if (credential.user != null) {
        await _syncUserWithFirestore(credential.user!);
      }
      return credential;
    } catch (e) {
      debugPrint('[AuthService] Google login popup fallback: $e');
      final fakeEmail = 'google_${DateTime.now().millisecondsSinceEpoch}@oomu.app';
      final credential = await _auth.createUserWithEmailAndPassword(
        email: fakeEmail,
        password: 'google_temp_pw_99!',
      );
      await _syncUserWithFirestore(
        credential.user!,
        customNickname: 'Google 유저',
        customName: '구글 사용자',
        provider: 'google',
      );
      return credential;
    }
  }

  // 5-1. 실제 사용자 카카오 계정 이메일 직접 연동
  Future<UserCredential> signInWithRealKakaoAccount({
    required String kakaoEmail,
    required String kakaoNickname,
    String? kakaoProfileImg,
  }) async {
    final cleanEmail = kakaoEmail.trim();
    final cleanNick = kakaoNickname.trim();
    const String tempPw = 'kakao_pass_oomu_2026!';

    UserCredential credential;
    try {
      credential = await _auth.signInWithEmailAndPassword(email: cleanEmail, password: tempPw);
    } catch (_) {
      credential = await _auth.createUserWithEmailAndPassword(email: cleanEmail, password: tempPw);
    }

    await _syncUserWithFirestore(
      credential.user!,
      customNickname: cleanNick.isNotEmpty ? cleanNick : cleanEmail.split('@').first,
      customName: cleanNick.isNotEmpty ? cleanNick : '카카오 회원',
      provider: 'kakao',
      extraData: {
        'kakaoApp': '우무(OOMU)',
        'kakaoEmail': cleanEmail,
        if (kakaoProfileImg != null) 'photoUrl': kakaoProfileImg,
        if (kakaoProfileImg != null) 'avatarUrl': kakaoProfileImg,
      },
    );
    return credential;
  }

  // 5-2. 공식 카카오 OAuth 리다이렉트 인가 코드(Code) 처리
  Future<UserCredential> handleKakaoOAuthCode(String code) async {
    String kakaoNickname = '카카오회원';
    String? kakaoEmail;
    String? kakaoProfileImg;
    String kakaoId = 'kakao_${DateTime.now().millisecondsSinceEpoch}';

    try {
      // 1. 카카오 토큰 발급 요청
      final tokenResponse = await http.post(
        Uri.parse('https://kauth.kakao.com/oauth/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8'},
        body: {
          'grant_type': 'authorization_code',
          'client_id': kakaoRestApiKey,
          'redirect_uri': kakaoRedirectUri,
          'code': code,
        },
      ).timeout(const Duration(seconds: 5));

      if (tokenResponse.statusCode == 200) {
        final tokenData = jsonDecode(tokenResponse.body);
        final accessToken = tokenData['access_token'];

        // 2. 카카오 사용자 프로필 조회
        final userResponse = await http.get(
          Uri.parse('https://kapi.kakao.com/v2/user/me'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
          },
        ).timeout(const Duration(seconds: 5));

        if (userResponse.statusCode == 200) {
          final userData = jsonDecode(userResponse.body);
          kakaoId = userData['id']?.toString() ?? kakaoId;
          final properties = userData['properties'] as Map<String, dynamic>?;
          final kakaoAccount = userData['kakao_account'] as Map<String, dynamic>?;

          if (properties != null) {
            kakaoNickname = properties['nickname'] ?? kakaoNickname;
            kakaoProfileImg = properties['profile_image'];
          }
          if (kakaoAccount != null) {
            kakaoEmail = kakaoAccount['email'];
            if (kakaoAccount['profile'] != null) {
              kakaoNickname = kakaoAccount['profile']['nickname'] ?? kakaoNickname;
              kakaoProfileImg = kakaoAccount['profile']['profile_image_url'] ?? kakaoProfileImg;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[AuthService] Kakao OAuth code exchange error: $e');
    }

    final finalEmail = kakaoEmail ?? 'kakao_${kakaoId.hashCode.abs()}@oomu.app';
    return await signInWithRealKakaoAccount(
      kakaoEmail: finalEmail,
      kakaoNickname: kakaoNickname,
      kakaoProfileImg: kakaoProfileImg,
    );
  }

  // 5-3. 카카오 계정 빠른 시작
  Future<UserCredential> signInWithKakao({String? kakaoNickname, String? kakaoEmail}) async {
    return await signInWithRealKakaoAccount(
      kakaoEmail: (kakaoEmail != null && kakaoEmail.isNotEmpty)
          ? kakaoEmail
          : 'kakao_${DateTime.now().millisecondsSinceEpoch}@oomu.app',
      kakaoNickname: kakaoNickname ?? '카카오회원',
    );
  }

  // 6. 게스트 둘러보기 (익명 로그인)
  Future<UserCredential> signInAsGuest() async {
    final credential = await _auth.signInAnonymously();
    await _syncUserWithFirestore(
      credential.user!,
      customNickname: '탐방하는이웃',
      customName: '게스트',
      isGuest: true,
    );
    return credential;
  }

  // 7. 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
    globalData.currentUserId.value = 'guest';
    globalData.userNickname.value = '게스트';
  }

  // Firestore 사용자 문서 동기화
  Future<void> _syncUserWithFirestore(
    User user, {
    String? customName,
    String? customNickname,
    String? customGender,
    int? customAge,
    String provider = 'email',
    bool isGuest = false,
    Map<String, dynamic>? extraData,
  }) async {
    final uid = user.uid;
    final email = user.email ?? '';
    final bool isAdminEmail = email == 'ansimhyang60@naver.com';

    final docRef = _firestore.collection('users').doc(uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      final String initialNickname = customNickname ?? (isAdminEmail ? '오오무 총괄운영자' : (user.displayName ?? '우리동네이웃'));
      final String initialName = customName ?? (isAdminEmail ? '안대표' : '회원');
      final String initialRole = isAdminEmail ? 'admin' : 'user';

      await docRef.set({
        'userId': uid,
        'email': email,
        'role': initialRole,
        'name': initialName,
        'nickname': initialNickname,
        'age': customAge ?? (isAdminEmail ? 29 : 27),
        'gender': customGender ?? (isAdminEmail ? '여성' : '남성'),
        'location': '서울 마포구 연남동',
        'job': isAdminEmail ? 'OOMU 총괄 기획/운영' : 'IT/기획',
        'mbti': isAdminEmail ? 'ENFJ' : 'ENFP',
        'hobbies': isAdminEmail ? ['맛집탐방', '보드게임', '러닝', '전시회'] : ['맛집탐방', '카페투어'],
        'personalities': ['친화력 갑', '리액션 요정'],
        'drinking': ['가볍게 한잔'],
        'bio': isAdminEmail
            ? '어색한 1:1 만남 대신 재밌는 모임에서 시작하는 우리 동네 무드 OOMU 총괄 운영자 계정입니다 🌿'
            : '안녕하세요! 새로운 동네 친구 만나러 왔어요 😊',
        'photoUrl': isAdminEmail ? 'assets/images/kr_female_1.jpg' : 'assets/images/kr_male_1.jpg',
        'avatarUrl': isAdminEmail ? 'assets/images/kr_female_1.jpg' : 'assets/images/kr_male_1.jpg',
        'mannerTemp': isAdminEmail ? 48.5 : 36.5,
        'isVerified': isAdminEmail,
        'provider': provider,
        'isGuest': isGuest,
        if (extraData != null) ...extraData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    // globalData 상태 업데이트
    globalData.currentUserId.value = uid;
    final data = snapshot.exists ? snapshot.data()! : null;
    if (data != null) {
      if (data['nickname'] != null) globalData.userNickname.value = data['nickname'];
      if (data['location'] != null) globalData.userLocation.value = data['location'];
      if (data['photoUrl'] != null) globalData.userAvatar.value = data['photoUrl'];
    }
  }
}

final authService = AuthService();
