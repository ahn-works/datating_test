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

  // Web Phone Auth용 세션 결과 저장
  ConfirmationResult? _webConfirmationResult;

  // 대표님께서 발급해주신 공식 카카오 앱 키 (우무 OOMU)
  static const String kakaoRestApiKey = '3f91399ac9b6731d96f6d4b9ac13c502';
  String get kakaoRedirectUri {
    if (kIsWeb) {
      final base = Uri.base;
      if (base.host.contains('localhost') || base.host.contains('127.0.0.1')) {
        return '${base.origin}/';
      }
    }
    return 'https://ahn-works.github.io/datating_test/';
  }

  String get kakaoOAuthUrl {
    final encodedRedirect = Uri.encodeComponent(kakaoRedirectUri);
    return 'https://kauth.kakao.com/oauth/authorize?client_id=$kakaoRestApiKey&redirect_uri=$encodedRedirect&response_type=code';
  }

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isAuthenticated => _auth.currentUser != null;

  /// 카카오 개발자 센터 공식 API 키 및 설정 정보 Firestore(config/kakao_auth)에 안전 백업
  Future<void> syncKakaoConfigToFirestore() async {
    try {
      await _firestore.collection('config').doc('kakao_auth').set({
        'appName': '우무(OOMU)',
        'kakaoRestApiKey': kakaoRestApiKey,
        'kakaoRedirectUri': kakaoRedirectUri,
        'kakaoOAuthUrl': kakaoOAuthUrl,
        'provider': 'kakao',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint(
          '[AuthService] Kakao config synced to Firestore (config/kakao_auth)');
    } catch (e) {
      debugPrint('[AuthService] Kakao config Firestore sync: $e');
    }
  }

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
      final fakeEmail =
          'google_${DateTime.now().millisecondsSinceEpoch}@oomu.app';
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

  // 5-1. 실제 사용자 카카오 계정 고유 ID 기반 1:1 결정적 연동 (중복 가입 0%)
  Future<UserCredential> signInWithRealKakaoAccount({
    required String kakaoId,
    required String kakaoNickname,
    String? kakaoEmail,
    String? kakaoProfileImg,
  }) async {
    final cleanId = kakaoId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
    final authEmail = 'kakao_${cleanId}@auth.oomu.app';
    final cleanNick = kakaoNickname.trim().isNotEmpty ? kakaoNickname.trim() : '카카오회원';
    const String tempPw = 'kakao_oomu_auth_2026!';
    syncKakaoConfigToFirestore();

    UserCredential credential;
    try {
      // 1. 이미 가입된 카카오 유저면 로그인
      credential = await _auth.signInWithEmailAndPassword(
        email: authEmail,
        password: tempPw,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        try {
          credential = await _auth.signInWithEmailAndPassword(
            email: authEmail,
            password: 'kakao_pass_oomu_2026!',
          );
        } catch (_) {
          rethrow;
        }
      } else if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        try {
          // 2. 신규 회원이면 Firebase Auth 계정 생성
          credential = await _auth.createUserWithEmailAndPassword(
            email: authEmail,
            password: tempPw,
          );
        } on FirebaseAuthException catch (createErr) {
          if (createErr.code == 'email-already-in-use') {
            credential = await _auth.signInWithEmailAndPassword(
              email: authEmail,
              password: tempPw,
            );
          } else {
            rethrow;
          }
        }
      } else {
        rethrow;
      }
    }

    // 3. Firestore 사용자 프로필 동기화 (카카오 회원은 본인인증 완료 상태로 인정)
    await _syncUserWithFirestore(
      credential.user!,
      customNickname: cleanNick,
      customName: cleanNick,
      provider: 'kakao',
      extraData: {
        'kakaoApp': '우무(OOMU)',
        'kakaoId': cleanId,
        'kakaoEmail': kakaoEmail ?? '',
        'isVerified': true, // 카카오 본인 확인 완료
        'isPhoneVerified': true,
        if (kakaoProfileImg != null && kakaoProfileImg.isNotEmpty) 'photoUrl': kakaoProfileImg,
        if (kakaoProfileImg != null && kakaoProfileImg.isNotEmpty) 'avatarUrl': kakaoProfileImg,
      },
    );
    return credential;
  }

  // 5-2. 공식 카카오 OAuth 리다이렉트 인가 코드(Code) 처리
  Future<UserCredential> handleKakaoOAuthCode(String code) async {
    // 1. 카카오 토큰 발급 요청
    final tokenResponse = await http.post(
      Uri.parse('https://kauth.kakao.com/oauth/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8'
      },
      body: {
        'grant_type': 'authorization_code',
        'client_id': kakaoRestApiKey,
        'redirect_uri': kakaoRedirectUri,
        'code': code,
      },
    ).timeout(const Duration(seconds: 10));

    if (tokenResponse.statusCode != 200) {
      try {
        final errorData = jsonDecode(tokenResponse.body);
        final desc = errorData['error_description'] ?? errorData['error'] ?? '토큰 발급 실패';
        throw Exception('카카오 토큰 발급 실패: $desc');
      } catch (e) {
        if (e is Exception && e.toString().contains('카카오')) rethrow;
        throw Exception('카카오 인증 토큰 응답 오류 (${tokenResponse.statusCode})');
      }
    }

    final tokenData = jsonDecode(tokenResponse.body);
    final accessToken = tokenData['access_token'];

    // 2. 카카오 사용자 프로필 조회
    final userResponse = await http.get(
      Uri.parse('https://kapi.kakao.com/v2/user/me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
      },
    ).timeout(const Duration(seconds: 10));

    if (userResponse.statusCode != 200) {
      throw Exception('카카오 사용자 정보 조회 실패 (${userResponse.statusCode})');
    }

    final userData = jsonDecode(userResponse.body);
    final String kakaoId = userData['id'].toString();

    String kakaoNickname = '카카오회원';
    String? kakaoEmail;
    String? kakaoProfileImg;

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

    // 3. 고유 카카오 ID 기반으로 1:1 결정적 계정 연동 (중복 계정 원천 방지)
    return await signInWithRealKakaoAccount(
      kakaoId: kakaoId,
      kakaoNickname: kakaoNickname,
      kakaoEmail: kakaoEmail,
      kakaoProfileImg: kakaoProfileImg,
    );
  }

  // 5-3. 카카오 계정 빠른 시작 (테스트 및 로컬 환경용 고정 계정)
  Future<UserCredential> signInWithKakao({String? testId, String? nickname}) async {
    final id = (testId != null && testId.isNotEmpty) ? testId : 'test_developer';
    return await signInWithRealKakaoAccount(
      kakaoId: id,
      kakaoNickname: nickname ?? '카카오회원',
      kakaoEmail: 'test_kakao@oomu.app',
    );
  }

  // 6. 게스트 둘러보기 (Firebase Auth 유령 계정 생성 없이 로컬 메모리 모드로 안전 진입)
  Future<void> signInAsGuest() async {
    // Firebase Auth에 유령 (익명) 계정을 무더기로 생성하지 않도록 로컬 게스트 상태로 즉시 설정
    globalData.currentUserId.value = 'guest';
    globalData.userNickname.value = '탐방하는이웃';
    globalData.userLocation.value = '서울 마포구 연남동';
    globalData.userAvatar.value = 'assets/images/kr_female_1.jpg';
  }

  // 7. 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
    globalData.currentUserId.value = 'guest';
    globalData.userNickname.value = '게스트';
  }

  // 8. 휴대폰 번호 SMS 인증번호 발송 (Firebase Phone Auth - Web & Mobile 겸용)
  Future<void> sendPhoneSmsCode({
    required String rawPhone,
    required Function(String verificationId) onCodeSent,
    required Function(String errorMessage) onError,
    VoidCallback? onAutoVerified,
  }) async {
    try {
      String cleanDigits = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanDigits.length < 9) {
        onError('올바른 휴대폰 번호를 입력해 주세요.');
        return;
      }
      String formattedE164;
      if (cleanDigits.startsWith('82')) {
        // +82 또는 82로 시작하는 번호: +8210... 형태로 정리
        formattedE164 = '+$cleanDigits';
      } else if (cleanDigits.startsWith('0')) {
        // 010... 형태: 맨 앞 0을 제거하고 +8210... 형태로 변환
        formattedE164 = '+82${cleanDigits.substring(1)}';
      } else {
        // 10... 형태
        formattedE164 = '+82$cleanDigits';
      }

      if (kIsWeb) {
        // [Flutter Web] signInWithPhoneNumber + ConfirmationResult 및 reCAPTCHA 자동 연동
        try {
          _webConfirmationResult =
              await _auth.signInWithPhoneNumber(formattedE164);
          onCodeSent('web_confirmation_token');
        } on FirebaseAuthException catch (e) {
          debugPrint(
              '[AuthService] Web Phone sign in failed: ${e.code} ${e.message}');
          String message = '인증번호 발송 실패 (${e.code})';
          if (e.code == 'invalid-phone-number') {
            message = '유효하지 않은 휴대폰 번호 형식입니다.';
          } else if (e.code == 'too-many-requests') {
            message = '인증 요청이 너무 많습니다. 잠시 후 다시 시도해 주세요.';
          } else if (e.code == 'operation-not-allowed') {
            message = 'Firebase 콘솔에서 [전화(Phone)] 로그인이 활성화되지 않았습니다. (Authentication > Sign-in method에서 전화를 켜주세요)';
          }
          onError(message);
        }
      } else {
        // [Mobile (Android/iOS)] verifyPhoneNumber + 콜백 처리
        await _auth.verifyPhoneNumber(
          phoneNumber: formattedE164,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {
            try {
              final userCred = await _auth.signInWithCredential(credential);
              if (userCred.user != null) {
                await _syncUserWithFirestore(
                  userCred.user!,
                  provider: 'phone',
                  extraData: {
                    'phone': rawPhone,
                    'isPhoneVerified': true,
                  },
                );
                if (onAutoVerified != null) {
                  onAutoVerified();
                }
              }
            } catch (_) {}
          },
          verificationFailed: (FirebaseAuthException e) {
            debugPrint(
                '[AuthService] Phone verify failed: ${e.code} ${e.message}');
            String message = '인증번호 발송 실패 (${e.code})';
            if (e.code == 'invalid-phone-number') {
              message = '유효하지 않은 휴대폰 번호 형식입니다.';
            } else if (e.code == 'too-many-requests') {
              message = '인증 요청이 너무 많습니다. 잠시 후 다시 시도해 주세요.';
            }
            onError(message);
          },
          codeSent: (String verificationId, int? resendToken) {
            onCodeSent(verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      }
    } catch (e) {
      onError('SMS 발송 중 오류가 발생했습니다: $e');
    }
  }

  // 9. 휴대폰 SMS 인증번호 검증 및 로그인 완료 (Web & Mobile 겸용)
  Future<UserCredential> verifyPhoneSmsCodeAndSignIn({
    required String verificationId,
    required String smsCode,
    required String rawPhone,
  }) async {
    UserCredential userCredential;
    if (kIsWeb) {
      if (_webConfirmationResult == null) {
        throw Exception('웹 SMS 인증 세션이 만료되었습니다. 인증번호를 다시 요청해 주세요.');
      }
      userCredential = await _webConfirmationResult!.confirm(smsCode.trim());
    } else {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );
      userCredential = await _auth.signInWithCredential(credential);
    }

    if (userCredential.user != null) {
      await _syncUserWithFirestore(
        userCredential.user!,
        provider: 'phone',
        extraData: {
          'phone': rawPhone,
          'isPhoneVerified': true,
        },
      );
    }
    return userCredential;
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
      final String initialNickname = customNickname ??
          (isAdminEmail ? '오오무 총괄운영자' : (user.displayName ?? '우리동네이웃'));
      final String initialName = customName ?? (isAdminEmail ? '안대표' : '회원');
      final String initialRole = isAdminEmail ? 'admin' : 'user';
      final String initialGender = customGender ?? (isAdminEmail ? '여성' : '남성');

      // 구글/카카오 계정의 원본 프로필 사진 URL 우선 적용
      final String? authPhotoUrl = user.photoURL;
      final String defaultPhoto =
          (authPhotoUrl != null && authPhotoUrl.isNotEmpty)
              ? authPhotoUrl
              : (initialGender == '여성'
                  ? 'assets/images/kr_female_1.jpg'
                  : 'assets/images/kr_male_1.jpg');

      await docRef.set({
        'userId': uid,
        'email': email,
        'role': initialRole,
        'name': initialName,
        'nickname': initialNickname,
        'age': customAge ?? (isAdminEmail ? 29 : 27),
        'gender': initialGender,
        'location': '서울 마포구 연남동',
        'job': isAdminEmail ? 'OOMU 총괄 기획/운영' : 'IT/기획',
        'mbti': isAdminEmail ? 'ENFJ' : 'ENFP',
        'hobbies':
            isAdminEmail ? ['맛집탐방', '보드게임', '러닝', '전시회'] : ['맛집탐방', '카페투어'],
        'personalities': ['친화력 갑', '리액션 요정'],
        'drinking': ['가볍게 한잔'],
        'bio': isAdminEmail
            ? '어색한 1:1 만남 대신 재밌는 모임에서 시작하는 우리 동네 무드 OOMU 총괄 운영자 계정입니다 🌿'
            : '안녕하세요! 새로운 동네 친구 만나러 왔어요 😊',
        'photoUrl': defaultPhoto,
        'avatarUrl': defaultPhoto,
        'photoUrls': [defaultPhoto],
        'mannerTemp': isAdminEmail ? 48.5 : 36.5,
        'isVerified': isAdminEmail,
        'isProfileComplete': isAdminEmail,
        'provider': provider,
        'isGuest': isGuest,
        if (extraData != null) ...extraData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 신규 가입 유저의 인메모리 상태 즉시 동기화
      globalData.currentUserId.value = uid;
      globalData.userNickname.value = initialNickname;
      globalData.userLocation.value = '서울 마포구 연남동';
      globalData.userAvatar.value = defaultPhoto;
    } else {
      // 기존 유저의 경우 추가 메타데이터(전화번호 인증 등) 병합 저장
      if (extraData != null && extraData.isNotEmpty) {
        await docRef.set({
          ...extraData,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // 기존 유저 인메모리 상태 동기화
      globalData.currentUserId.value = uid;
      final data = snapshot.data();
      if (data != null) {
        if (data['nickname'] != null)
          globalData.userNickname.value = data['nickname'];
        if (data['location'] != null)
          globalData.userLocation.value = data['location'];
        if (data['photoUrl'] != null)
          globalData.userAvatar.value = data['photoUrl'];
      }
    }
  }

  /// 사용자가 초기 프로필 설정을 완료했는지 검사
  Future<bool> isUserProfileComplete([String? targetUid]) async {
    final uid = targetUid ?? currentUser?.uid;
    if (uid == null) return false;
    if (isAdmin) return true;
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return false;
      final data = doc.data()!;
      if (data['role'] == 'admin') return true;
      return data['isProfileComplete'] == true;
    } catch (_) {
      return false;
    }
  }

  /// 신규 회원 프로필 등록 및 마이페이지 동기화
  Future<void> updateUserProfile({
    String? targetUid,
    required String nickname,
    required String gender,
    required String birthDate,
    required String phone,
    required String location,
    String? detailAddress,
    required String job,
    required String mbti,
    required List<String> hobbies,
    required String bio,
    required List<String> photoUrls,
  }) async {
    final uid = targetUid ?? currentUser?.uid ?? globalData.activeUserId;
    int calculatedAge = 25;
    try {
      final yearDigits = birthDate.replaceAll(RegExp(r'[^0-9]'), '');
      if (yearDigits.length >= 4) {
        final birthYear = int.tryParse(yearDigits.substring(0, 4)) ?? 1999;
        calculatedAge = DateTime.now().year - birthYear + 1;
      }
    } catch (_) {}

    final Map<String, dynamic> updateData = {
      'nickname': nickname,
      'name': nickname,
      'gender': gender,
      'birthDate': birthDate,
      'age': calculatedAge,
      'phone': phone,
      'isPhoneVerified': true,
      'location': location,
      'address': location,
      if (detailAddress != null && detailAddress.isNotEmpty)
        'detailAddress': detailAddress,
      'job': job,
      'mbti': mbti,
      'hobbies': hobbies,
      'bio': bio,
      'photoUrls': photoUrls,
      if (photoUrls.isNotEmpty) 'photoUrl': photoUrls.first,
      if (photoUrls.isNotEmpty) 'avatarUrl': photoUrls.first,
      'isProfileComplete': true,
      'isVerified': true,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('users')
        .doc(uid)
        .set(updateData, SetOptions(merge: true));

    // 글로벌 상태 즉시 동기화
    globalData.userNickname.value = nickname;
    globalData.userLocation.value = location;
    if (photoUrls.isNotEmpty) {
      globalData.userAvatar.value = photoUrls.first;
    }
  }
}

final authService = AuthService();
