import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'soso_car_home_screen.dart';
import 'soso_car_host_screen.dart';
import 'chat_screen.dart';
import 'oomu_my_trips_screen.dart';
import 'profile_edit_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color textPrimary = const Color(0xFF111111);
    final Color textSecondary = const Color(0xFF767676);
    final Color surfaceColor = const Color(0xFFF5F5F7);
    final Color accentColor = const Color(0xFFF19E39);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('마이페이지', style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: textPrimary),
            tooltip: '프로필 수정',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen()));
            }
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc('test_user_1').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: accentColor));
          }
          
          String nickname = '매운맛킬러';
          String location = '마포구 연남동';
          double manner = 41.2;
          List<String> hobbies = [];
          
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            nickname = data['nickname'] ?? nickname;
            location = data['location'] ?? location;
            manner = (data['manner'] ?? manner).toDouble();
            if (data['hobbies'] != null) {
              hobbies = List<String>.from(data['hobbies']);
            }
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // User Profile Card (Toss Style)
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen()));
                },
                child: Container(
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
                              image: DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&q=80'), fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(nickname, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary)),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFC7C7CC)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(location, style: TextStyle(color: textSecondary, fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(height: 1, color: const Color(0xFFEBEBEF)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('나의 매너 온도', style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary, fontSize: 14)),
                          Row(
                            children: [
                              Text('${manner}°C', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: accentColor)),
                              const SizedBox(width: 4),
                              Icon(Icons.thermostat, color: accentColor, size: 18),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              if (hobbies.isNotEmpty) ...[
                Text('나의 관심사 / 취향', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: hobbies.map((hobby) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(hobby, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                  )).toList(),
                ),
                const SizedBox(height: 40),
              ],
              
              Text('나의 활동 배지', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    _buildBadge('👑', '파티 마스터', '모임 개설 10회', textPrimary),
                    _buildBadge('🗣️', '핵인싸', '모임 참여 20회', textPrimary),
                    _buildBadge('💖', '매너왕', '매너 온도 40도+', textPrimary),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),

              // Menu List (No Dividers, Clean Layout)
              Text('설정 및 관리', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
              const SizedBox(height: 16),
              _buildMenuItem(Icons.favorite_border, '내가 찜한 모임', textPrimary),
              _buildMenuItem(Icons.history, '참여/개설 내역', textPrimary),
              _buildMenuItem(Icons.notifications_outlined, '알림 설정', textPrimary),
              _buildMenuItem(Icons.support_agent, '고객 센터', textPrimary),
              
              const SizedBox(height: 40),
            ],
          );
        }
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBadge(String emoji, String title, String subtitle, Color textPrimary) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: textPrimary)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF767676))),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: textPrimary, size: 24),
          const SizedBox(width: 16),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFC7C7CC)),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF111111),
      unselectedItemColor: const Color(0xFFC7C7CC),
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      elevation: 20,
      backgroundColor: Colors.white,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_,__,___) => const OOMUHomeScreen(), transitionDuration: Duration.zero));
        } else if (index == 1) { 
          Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => const OOMUHostScreen(), transitionDuration: Duration.zero)); 
        } else if (index == 2) {
          Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_,__,___) => const OOMUMyTripsScreen(), transitionDuration: Duration.zero));
        }
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined, size: 26), activeIcon: Icon(Icons.explore, size: 26), label: '탐색'),
        const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 26), activeIcon: Icon(Icons.add_circle, size: 26), label: '만들기'),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.chat_bubble_outline, size: 24),
              Positioned(right: -6, top: -6, child: Container(padding: const EdgeInsets.all(5), decoration: const BoxDecoration(color: Color(0xFFFF3B30), shape: BoxShape.circle), child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
            ],
          ),
          activeIcon: const Icon(Icons.chat_bubble, size: 24),
          label: '내 모임',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 26), activeIcon: Icon(Icons.person, size: 26), label: 'MY'),
      ],
    );
  }
}
