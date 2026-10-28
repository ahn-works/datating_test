import 'dart:ui';
import 'screens/profile_setup_screen.dart';
import 'services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/soso_car_home_screen.dart';
import 'screens/login_screen.dart';
import 'services/r2_storage_service.dart';
import 'utils/global_data.dart';
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
        color: const Color(0xFFD8CFD2),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                size: Size(
                  MediaQuery.of(context).size.width > 480 ? 480 : MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height,
                ),
              ),
              child: Container(color: const Color(0xFFFAF6F7), child: child!),
            ),
          ),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFFFAF6F7),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFF25767)),
              ),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            final user = snapshot.data!;
            globalData.currentUserId.value = user.uid;
            return _AuthGate(user: user);
          }
          return const LoginScreen();
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
            backgroundColor: Color(0xFFFAF6F7),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFF25767)),
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
