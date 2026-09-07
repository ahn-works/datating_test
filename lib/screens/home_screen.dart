import 'package:flutter/material.dart';
import 'dart:ui'; // ImageFilter 를 위해 추가
import '../data/dummy_data.dart';
import 'profile_detail_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Spot10', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF8A65), fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87, size: 28),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
            },
          ),
        ],
      ),
      body: PageView.builder(
        itemCount: DummyData.users.length,
        itemBuilder: (context, index) {
          final user = DummyData.users[index];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileDetailScreen(userData: user)),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 블러 처리된 프로필 사진 영역
                    Expanded(
                      flex: 4,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(user['profileUrl'], fit: BoxFit.cover),
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(color: Colors.black.withOpacity(0.1)),
                            ),
                            const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 40),
                                  SizedBox(height: 8),
                                  Text('터치하여 프로필 엿보기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              )
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${user['name']}, ${user['age']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('📍 ${user['location']} · ${user['temp']}°', style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8, runSpacing: 8,
                              children: (user['tags'] as List<String>).map((tag) => _buildTag(tag)).toList(),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileDetailScreen(userData: user)));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF8A65),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text('⏱️ 10분 익명 대화 시작', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
