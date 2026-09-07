import 'package:flutter/material.dart';
import 'chat_room_screen.dart';

class ProfileDetailScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  const ProfileDetailScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400.0,
            pinned: true,
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black87),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(userData['profileUrl'], fit: BoxFit.cover),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${userData['name']}, ${userData['age']}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('📍 ${userData['location']} · 매너온도 ${userData['temp']}°', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 32),
                  const Text('자기소개', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(userData['bio'], style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
                  const SizedBox(height: 32),
                  const Text('나의 취향', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: (userData['tags'] as List<String>).map((tag) => _buildTag(tag)).toList(),
                  ),
                  const SizedBox(height: 60),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoomScreen(title: userData['name'])));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8A65),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('⏱️ 10분 익명 대화 신청하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFFFF0EC), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFFFF8A65), fontWeight: FontWeight.bold)),
    );
  }
}
