import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/soso_car_home_screen.dart';
import 'services/r2_storage_service.dart';

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
      theme: ThemeData(
        primaryColor: const Color(0xFFF25767),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF25767),
          primary: const Color(0xFFF25767),
          secondary: const Color(0xFF0D9488),
          surface: const Color(0xFFFAF6F7),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF6F7),
        cardColor: const Color(0xFFFFFFFF),
        dividerColor: const Color(0xFFEFE4E6),
      ),
      builder: (context, child) => Container(
        color: const Color(0xFFD8CFD2),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(color: const Color(0xFFFAF6F7), child: child!),
          ),
        ),
      ),
      home: const OOMUHomeScreen(),
    );
  }
}
