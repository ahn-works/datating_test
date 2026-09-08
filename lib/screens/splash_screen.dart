import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
class SplashScreen extends StatefulWidget { const SplashScreen({super.key}); @override State<SplashScreen> createState() => _SplashScreenState(); }
class _SplashScreenState extends State<SplashScreen> {
  @override void initState() { super.initState(); Future.delayed(const Duration(seconds: 2), () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()))); }
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: const Color(0xFFFF3B30), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.favorite, size: 80, color: Colors.white), const SizedBox(height: 24), const Text('위피 버디', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)), const SizedBox(height: 8), Text('우리 동네 친구들과 떠나는 여행', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16))])));
}
