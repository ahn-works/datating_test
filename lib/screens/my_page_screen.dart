
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
        title: Text('마이페이지', style: TextStyle(color: accentColor, fontSize: 24, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: accentColor),
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
          String bio = '새로운 사람 만나는 걸 좋아해요! 잘 부탁드립니다 😊';
          String jobAndMbti = 'IT/개발 • ENFP';
          double manner = 41.2;
          List<String> hobbies = ['맛집탐방', '코노'];
          List<String> closeFriendPersonalities = [];
          List<String> values = [];
          List<String> personalities = ['리액션 요정', '친화력 갑'];
          List<String> drinking = ['가볍게 한잔'];
          
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            nickname = data['nickname'] ?? nickname;
            location = data['location'] ?? location;
            bio = data['bio'] ?? bio;
            final job = data['job'] ?? 'IT/개발';
            final mbti = data['mbti'] ?? 'ENFP';
            jobAndMbti = '$job • $mbti';
            manner = (data['manner'] ?? manner).toDouble();
            if (data['hobbies'] != null) hobbies = List<String>.from(data['hobbies']);
            if (data['personalities'] != null) personalities = List<String>.from(data['personalities']);
            if (data['drinking'] != null) drinking = List<String>.from(data['drinking']);
            if (data['closeFriendPersonalities'] != null) closeFriendPersonalities = List<String>.from(data['closeFriendPersonalities']);
            if (data['values'] != null) values = List<String>.from(data['values']);
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // User Profile Card (Rich Style)
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
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 72, height: 72,
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
                                    Text(nickname, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary)),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFC7C7CC)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(jobAndMbti, style: TextStyle(color: accentColor, fontSize: 14, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(location, style: TextStyle(color: textSecondary, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16)),
                        child: Text('"$bio"', style: TextStyle(fontSize: 14, color: textSecondary, fontStyle: FontStyle.italic)),
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
                              Text('${manner}°C', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: accentColor)),
                              const SizedBox(width: 4),
                              Icon(Icons.thermostat, color: accentColor, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Lifestyle Tags
              Text('성향 및 라이프스타일', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
              const SizedBox(height: 16),
              _buildInfoRow('성격', personalities, surfaceColor, textPrimary),
              const SizedBox(height: 12),
              _buildInfoRow('음주', drinking, surfaceColor, textPrimary),
              const SizedBox(height: 32),
              
              if (hobbies.isNotEmpty) ...[
                Text('나의 관심사 / 취향', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: hobbies.map((hobby) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEBEBEF))),
                    child: Text(hobby, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                  )).toList(),
                ),
                const SizedBox(height: 32),
              ],
              
              if (closeFriendPersonalities.isNotEmpty) ...[
                Text('찐친이랑 있을 때 내 성격 🤪', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: closeFriendPersonalities.map((p) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEBEBEF))),
                    child: Text(p.toString(), style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                  )).toList(),
                ),
                const SizedBox(height: 32),
              ],
              
              if (values.isNotEmpty) ...[
                Text('내가 중요하게 생각하는 가치관 💎', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: values.map((v) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEBEBEF))),
                    child: Text(v.toString(), style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
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

              Text('설정 및 관리', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: accentColor)),
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

  Widget _buildInfoRow(String title, List<String> tags, Color surfaceColor, Color textPrimary) {
    if (tags.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 60, child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF767676), height: 1.5))),
        Expanded(
          child: Wrap(
            spacing: 8, runSpacing: 8,
            children: tags.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(8)),
              child: Text(t, style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            )).toList(),
          ),
        ),
      ],
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
