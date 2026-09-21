import 'package:flutter/material.dart';
import 'soso_car_home_screen.dart';
import 'soso_car_host_screen.dart';
import 'chat_screen.dart';
import 'oomu_my_trips_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color textPrimary = const Color(0xFF111111);
    final Color textSecondary = const Color(0xFF767676);
    final Color surfaceColor = const Color(0xFFF5F5F7);
    final Color accentColor = const Color(0xFF007AFF);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('마이페이지', style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(icon: Icon(Icons.settings_outlined, color: textPrimary), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // User Profile Card (Toss Style)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEBEBEF)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(image: NetworkImage('https://i.pravatar.cc/150?img=47'), fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('매운맛킬러', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary)),
                          const SizedBox(height: 4),
                          Text('마포구 연남동', style: TextStyle(color: textSecondary, fontSize: 14)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: surfaceColor, shape: BoxShape.circle),
                      child: Icon(Icons.edit, color: textSecondary, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('나의 매너 온도', style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary, fontSize: 14)),
                      Row(
                        children: [
                          Text('41.2°C', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: accentColor)),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          
          Text('나의 활동 배지', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildBadge(Icons.verified_user, 'AI 신원인증', const Color(0xFFE5F0FF), accentColor),
                const SizedBox(width: 12),
                _buildBadge(Icons.directions_car, '안심 카풀러', const Color(0xFFF5F5F7), textPrimary),
                const SizedBox(width: 12),
                _buildBadge(Icons.star, '인기 호스트', const Color(0xFFFFF4E5), const Color(0xFFFF9500)),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Menu List (No Dividers, Clean Layout)
          Text('설정 및 관리', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
          const SizedBox(height: 16),
          _buildMenuItem(Icons.favorite_border, '내가 찜한 모임'),
          _buildMenuItem(Icons.history, '참여/개설 내역'),
          _buildMenuItem(Icons.local_offer_outlined, '나의 취향 태그 수정'),
          _buildMenuItem(Icons.directions_car_outlined, '카풀 차량 정보 관리'),
          _buildMenuItem(Icons.help_outline, '고객센터 / 자주 묻는 질문'),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: iconColor, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return InkWell(
      onTap: () {},
      highlightColor: const Color(0xFFF5F5F7),
      splashColor: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: const Color(0xFF111111), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF111111)))),
            const Icon(Icons.chevron_right, color: Color(0xFFC7C7CC)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 4,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF111111),
      unselectedItemColor: const Color(0xFFC7C7CC),
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      elevation: 20,
      backgroundColor: Colors.white,
      onTap: (index) {
        if (index == 0) { Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => const OOMUHomeScreen(), transitionDuration: Duration.zero)); }
        else if (index == 1) { Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => const OOMUHostScreen(), transitionDuration: Duration.zero)); }
        else if (index == 2) { Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => const ChatScreen(), transitionDuration: Duration.zero)); }
        else if (index == 3) { Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => const OOMUMyTripsScreen(), transitionDuration: Duration.zero)); }
        else if (index == 4) { }
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined, size: 26), activeIcon: Icon(Icons.explore, size: 26), label: '탐색'),
        const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 26), activeIcon: Icon(Icons.add_circle, size: 26), label: '모집하기'),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.chat_bubble_outline, size: 24),
              Positioned(right: -6, top: -6, child: Container(padding: const EdgeInsets.all(5), decoration: const BoxDecoration(color: Color(0xFFFF3B30), shape: BoxShape.circle), child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
            ],
          ),
          activeIcon: const Icon(Icons.chat_bubble, size: 24),
          label: '채팅',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.directions_car_outlined, size: 26), activeIcon: Icon(Icons.directions_car, size: 26), label: '내 모임'),
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 26), activeIcon: Icon(Icons.person, size: 26), label: '마이'),
      ],
    );
  }
}
