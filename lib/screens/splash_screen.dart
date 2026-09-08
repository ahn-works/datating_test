
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFFFF3B30), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.travel_explore, color: Colors.white, size: 44)),
      const SizedBox(height: 20),
      const Text('Travel Buddy', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
      const SizedBox(height: 8),
      const Text('동네 친구와 여행을', style: TextStyle(color: Colors.grey, fontSize: 16)),
    ])),
  );
}
