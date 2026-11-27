import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'dart:async';
import 'dart:ui';
import 'screens/profile_setup_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/my_page_screen.dart';
import 'services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/oomu_home_screen.dart';
import 'screens/oomu_detail_screen.dart';
import 'screens/community_post_detail_screen.dart';
import 'screens/login_screen.dart';
import 'services/r2_storage_service.dart';
import 'utils/global_data.dart';
import 'ui/oomu_tokens.dart';
import 'ui/oomu_component_gallery.dart';
import 'utils/oomu_ui_helpers.dart';
import 'services/kakao_map_service.dart';

/// 테스트용 URI 주입 훅
Uri Function()? resolveAppUri;

bool _isSampleOrBlockedId(String rawId) {
  final id = rawId.trim();
  if (id.isEmpty) return true;
  const blocked = <String>{
    'test_post',
    'test11',
    'choyeon',
    'sample_01',
    'sample_yeosu_01',
    'post_sample_01',
    'sample_chat_room_01',
  };
  return blocked.contains(id);
}

Widget resolveInitialRouteWidget(
  Uri uri, {
  bool enableDevRoutes = const bool.fromEnvironment('OOMU_DEV_ROUTES'),
}) {
  final isHome = uri.queryParameters['home'] == 'true' ||
      uri.fragment.contains('home=true');
  final isGallery = uri.queryParameters['gallery'] == 'true' ||
      uri.fragment.contains('gallery=true');
  final isDetail = uri.queryParameters['detail'] == 'true' ||
      uri.fragment.contains('detail=true');
  final isCommDetail = uri.queryParameters['comm_detail'] == 'true' ||
      uri.fragment.contains('comm_detail=true');
  final isLogin = uri.queryParameters['login'] == 'true' ||
      uri.fragment.contains('login=true');
  final isTestPost = uri.queryParameters['test_post'] == 'true' ||
      uri.fragment.contains('test_post=true');

  final hasDebugOnlyFlag = isGallery ||
      isTestPost ||
      uri.queryParameters.containsKey('my') ||
      uri.queryParameters.containsKey('profile') ||
      uri.queryParameters.containsKey('edit') ||
      uri.queryParameters.containsKey('comm_create') ||
      uri.queryParameters.containsKey('chat') ||
      uri.queryParameters.containsKey('chat_room') ||
      uri.queryParameters.containsKey('discovery') ||
      uri.queryParameters.containsKey('fortune') ||
      uri.queryParameters.containsKey('profile_setup') ||
      uri.queryParameters.containsKey('setup') ||
      uri.queryParameters.containsKey('preview') ||
      uri.queryParameters.containsKey('my_trips') ||
      uri.queryParameters.containsKey('user') ||
      uri.fragment.contains('gallery=true') ||
      uri.fragment.contains('my=true') ||
      uri.fragment.contains('user=');

  if (enableDevRoutes && isGallery) {
    return const OomuComponentGallery();
  }

  if (enableDevRoutes && uri.queryParameters['setup'] == 'true') {
    return const ProfileSetupScreen();
  }

  if (enableDevRoutes && uri.queryParameters['my'] == 'true') {
    return const MyPageScreen();
  }

  if (enableDevRoutes && uri.queryParameters['preview'] == 'true') {
    return const UserProfileScreen(
      userName: '',
      isSelf: true,
    );
  }

  // 릴리스에서 디버그 라우트(?gallery, ?my, user= 등) 진입 시 세션 변경 없이 정상 게스트 홈으로 이동
  if (!enableDevRoutes &&
      hasDebugOnlyFlag &&
      !isLogin &&
      !isDetail &&
      !isCommDetail) {
    globalData.switchUser('guest');
    return const OOMUHomeScreen();
  }

  if (isHome) {
    // user= 파라미터로 세션 신원을 바꾸지 않고 게스트로만 시작
    globalData.switchUser('guest');
    return const OOMUHomeScreen();
  }

  if (isLogin) {
    globalData.switchUser('guest');
    return const LoginScreen(initialStage: 2);
  }

  if (isDetail) {
    final docId = (uri.queryParameters['id'] ?? '').trim();
    if (_isSampleOrBlockedId(docId)) {
      return const OOMUHomeScreen();
    }
    return _withRestoredSession(OOMUDetailScreen(meetup: {'id': docId}));
  }

  if (isCommDetail) {
    final docId = (uri.queryParameters['id'] ?? '').trim();
    if (isTestPost || _isSampleOrBlockedId(docId)) {
      return const OOMUHomeScreen();
    }
    return _withRestoredSession(CommunityPostDetailScreen(post: {'id': docId}));
  }

  if (Firebase.apps.isEmpty) {
    globalData.switchUser('guest');
    return const LoginScreen(initialStage: 2);
  }

  return StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(
          backgroundColor: OomuTokens.background,
          body: Center(
            child: CircularProgressIndicator(color: OomuTokens.coral),
          ),
        );
      }
      if (snapshot.hasData && snapshot.data != null) {
        final user = snapshot.data!;
        globalData.switchUser(user.uid);
        return _AuthGate(user: user);
      }
      globalData.switchUser('guest');
      return const LoginScreen(initialStage: 2);
    },
  );
}

// Public links remain readable by guests, but must not erase the identity of a
// signed-in visitor while Firebase restores browser persistence.
Widget _withRestoredSession(Widget child) {
  if (Firebase.apps.isEmpty) {
    globalData.switchUser('guest');
    return child;
  }
  return StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      globalData.switchUser(snapshot.data?.uid ?? 'guest');
      return child;
    },
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
          ? null
          : const FirebaseOptions(
              apiKey: "AIzaSyDWOPC60MA39jq2HAVg6UpKnLB5DalDu7U",
              authDomain: "test-b54fc.firebaseapp.com",
              projectId: "test-b54fc",
              storageBucket: "test-b54fc.firebasestorage.app",
              messagingSenderId: "610801542567",
              appId: "1:610801542567:web:6eb035b321d9ac7b688282",
              measurementId: "G-341F6S06TG",
            ),
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  // 비동기 서비스 초기화는 앱 렌더링을 블로킹하지 않도록 3초 타임아웃과 함께 백그라운드로 처리
  unawaited(Future.wait([
    r2Storage
        .initFromFirestore()
        .timeout(const Duration(seconds: 3), onTimeout: () {}),
    KakaoMapService.ensureKeysLoaded()
        .timeout(const Duration(seconds: 3), onTimeout: () {}),
  ]).catchError((e) {
    debugPrint("Background services init error: $e");
    return <void>[];
  }));

  runApp(const OomuApp());
}

class OomuApp extends StatelessWidget {
  const OomuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OOMU',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),
      theme: OomuUiHelpers.buildTheme(),
      builder: (context, child) => Container(
        color: OomuTokens.surfaceMuted,
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: OomuTokens.appFrameMaxWidth),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                size: Size(
                  MediaQuery.of(context).size.width > 480
                      ? 480
                      : MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: OomuTokens.background,
                  boxShadow: MediaQuery.of(context).size.width > 480
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 32,
                            offset: const Offset(0, 10),
                          ),
                        ]
                      : null,
                ),
                child: child!,
              ),
            ),
          ),
        ),
      ),
      home: Builder(
        builder: (context) {
          final uri = resolveAppUri?.call() ?? Uri.base;
          return resolveInitialRouteWidget(uri);
        },
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  final User user;
  const _AuthGate({required this.user});

  @override
  Widget build(BuildContext context) {
    if (authService.isAdmin || globalData.skipProfileSetup) {
      return const OOMUHomeScreen();
    }
    return FutureBuilder<bool>(
      future: authService.isUserProfileComplete(user.uid),
      builder: (context, profileSnapshot) {
        if (profileSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: OomuTokens.background,
            body: Center(
              child: CircularProgressIndicator(color: OomuTokens.coral),
            ),
          );
        }
        if (profileSnapshot.data == false && !globalData.skipProfileSetup) {
          return const ProfileSetupScreen();
        }
        return const OOMUHomeScreen();
      },
    );
  }
}
