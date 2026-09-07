import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'party_screen.dart';
import 'chat_screen.dart';
import 'my_page_screen.dart'; // 추가됨

void main() {
  runApp(const Spot10App());
}

class Spot10App extends StatelessWidget {
  const Spot10App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spot10',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8A65),
          primary: const Color(0xFFFF8A65),
          background: const Color(0xFFFFF8F5),
        ),
        useMaterial3: true,
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
  
  // 마이페이지가 4번째 탭으로 추가됨
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
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // 탭 4개 이상일 때 설정
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.celebration), label: '모임'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: '대화'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이'),
        ],
      ),
    );
  }
}
