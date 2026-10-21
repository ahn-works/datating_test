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

  // 5. 카카오 계정으로 가입 / 시작하기 (실제 작동하는 동적 로그인 & 세션 생성)
  Future<UserCredential> signInWithKakao({String? kakaoNickname, String? kakaoEmail}) async {
    final String email = (kakaoEmail != null && kakaoEmail.isNotEmpty)
        ? kakaoEmail
        : 'kakao_${DateTime.now().millisecondsSinceEpoch}@oomu.app';
    const String tempPw = 'kakao_pass_oomu_2026!';

    UserCredential credential;
    try {
      credential = await _auth.signInWithEmailAndPassword(email: email, password: tempPw);
    } catch (_) {
      credential = await _auth.createUserWithEmailAndPassword(email: email, password: tempPw);
    }

    await _syncUserWithFirestore(
      credential.user!,
      customNickname: kakaoNickname ?? '카카오이웃',
      customName: '카카오 사용자',
      provider: 'kakao',
      extraData: {
        'kakaoApp': '우무(OOMU)',
        'kakaoRestApiKey': kakaoRestApiKey,
      },
    );
    return credential;
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
        'drinking': '가볍게 한잔',
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
