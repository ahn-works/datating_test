import 'dart:ui';
import 'screens/profile_setup_screen.dart';
import 'services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/soso_car_home_screen.dart';
import 'screens/soso_car_detail_screen.dart';
import 'screens/login_screen.dart';
import 'services/r2_storage_service.dart';
import 'utils/global_data.dart';
import 'ui/oomu_tokens.dart';
import 'ui/oomu_component_gallery.dart';
import 'utils/oomu_ui_helpers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDWOPC60MA39jq2HAVg6UpKnLB5DalDu7U",
        authDomain: "test-b54fc.firebaseapp.com",
        projectId: "test-b54fc",
        storageBucket: "test-b54fc.firebasestorage.app",
        messagingSenderId: "610801542567",
        appId: "1:610801542567:web:6eb035b321d9ac7b688282",
        measurementId: "G-341F6S06TG",
      ),
    );
    await r2Storage.initFromFirestore();
  } catch (e) {
    debugPrint("Firebase/R2 init error: $e");
  }
  runApp(const Spot10App());
}

class Spot10App extends StatelessWidget {
  const Spot10App({super.key});

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
            constraints: const BoxConstraints(maxWidth: OomuTokens.appFrameMaxWidth),
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
                            color:
                                Colors.black.withValues(alpha: 0.12),
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
          final uri = Uri.base;
          final isHome = uri.queryParameters['home'] == 'true' || uri.fragment.contains('home=true');
          final isGallery = uri.queryParameters['gallery'] == 'true' || uri.fragment.contains('gallery=true');
          final isDetail = uri.queryParameters['detail'] == 'true' || uri.fragment.contains('detail=true');

          if (isGallery) {
            return const OomuComponentGallery();
          }
          if (isHome) {
            globalData.switchUser('guest');
            return const OOMUHomeScreen();
          }
          if (isDetail) {
            globalData.switchUser('guest');
            return const OOMUDetailScreen();
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
              return const LoginScreen();
            },
          );
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
    if (user.email == 'ansimhyang60@naver.com' || authService.isAdmin) {
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
        if (profileSnapshot.data == false) {
          return const ProfileSetupScreen();
        }
        return const OOMUHomeScreen();
      },
    );
  }
}
