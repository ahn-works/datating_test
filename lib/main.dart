import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/soso_car_home_screen.dart';

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
  } catch (e) {
    debugPrint("Firebase init error: $e");
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
        primaryColor: const Color(0xFF111111), 
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF111111), primary: const Color(0xFF111111)), 
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      ), 
      builder: (context, child) => Container(
        color: Colors.grey.shade300, 
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480), 
            child: Container(color: Colors.white, child: child!)
          )
        )
      ), 
      home: const OOMUHomeScreen()
    ); 
  }
}
