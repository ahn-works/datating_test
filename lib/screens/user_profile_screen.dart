
import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  final String userName;
  const UserProfileScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final Color textPrimary = const Color(0xFF111111);
    final Color textSecondary = const Color(0xFF767676);
    final Color surfaceColor = const Color(0xFFF5F5F7);
    final Color accentColor = const Color(0xFFF19E39);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        title: Text('프로필', style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500&q=80'), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 16),
                Text(userName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textPrimary)),
                const SizedBox(height: 8),
                Text('IT/개발 • ENFP', style: TextStyle(color: accentColor, fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Text('"새로운 사람 만나는 걸 좋아해요! 잘 부탁드립니다 😊"', style: TextStyle(color: textSecondary, fontSize: 15, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Manner Temp
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('매너 온도', style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary, fontSize: 16)),
                Row(
                  children: [
                    Text('42.5°C', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: accentColor)),
                    const SizedBox(width: 4),
                    Icon(Icons.thermostat, color: accentColor, size: 20),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Tags Section
          Text('성향 및 라이프스타일', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
          const SizedBox(height: 16),
          _buildInfoRow('성격', ['리액션 요정', '친화력 갑', '긍정적'], surfaceColor, textPrimary),
          const SizedBox(height: 12),
          _buildInfoRow('음주', ['가볍게 한잔', '분위기 메이커'], surfaceColor, textPrimary),
          const SizedBox(height: 32),

          Text('관심사 / 취향', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: ['맛집탐방', '러닝', '전시회', '와인'].map((hobby) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEBEBEF))),
              child: Text(hobby, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
            )).toList(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, List<String> tags, Color surfaceColor, Color textPrimary) {
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
}
