import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/party_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/my_page_screen.dart';

void main() {
  runApp(const Spot10App());
}

class Spot10App extends StatelessWidget {
  const Spot10App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel Buddy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF3B30),
          primary: const Color(0xFFFF3B30),
        ),
        useMaterial3: true,
        fontFamily: 'Pretendard',
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const PartyScreen(),
    const ChatScreen(),
    const MyPageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFFFF3B30),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.travel_explore), label: '여행'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: '채팅'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'MY'),
        ],
      ),
    );
  }
}
