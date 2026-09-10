import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; import 'screens/home_screen.dart'; import 'screens/party_screen.dart'; import 'screens/chat_screen.dart'; import 'screens/my_page_screen.dart';

void main() { runApp(const Spot10App()); }

class Spot10App extends StatelessWidget {
  const Spot10App({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false, title: 'Travel Buddy',
    theme: ThemeData(
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF3B30), primary: const Color(0xFFFF3B30)),
      useMaterial3: true, fontFamily: 'Pretendard',
      appBarTheme: const AppBarTheme(backgroundColor: Colors.white, elevation: 0, centerTitle: true, iconTheme: IconThemeData(color: Colors.black), titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.5)),
    ),
    builder: (context, child) => Container(
      color: Colors.grey.shade300, // PC 배경
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480), // 핵심: 모바일 비율 강제 고정
          child: Container(
            color: Colors.white,
            child: child!,
          ),
        ),
      ),
    ),
    home: const SplashScreen(),
  );
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override State<MainNavigation> createState() => _MainNavigationState();
}
class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _screens = [const HomeScreen(), const PartyScreen(), const ChatScreen(), const MyPageScreen()];
  @override Widget build(BuildContext context) => Scaffold(
    body: _screens[_currentIndex],
    bottomNavigationBar: Container(
      decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]),
      child: BottomNavigationBar(
        backgroundColor: Colors.white, elevation: 0,
        currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFFFF3B30), unselectedItemColor: Colors.grey.shade400, type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.travel_explore), label: '여행'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: '채팅'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'MY'),
        ],
      ),
    ),
  );
}
