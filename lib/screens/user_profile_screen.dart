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
      body: CustomScrollView(
        slivers: [
          // 1. Hero Image Gallery (SliverAppBar)
          SliverAppBar(
            expandedHeight: 460.0,
            pinned: true,
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView(
                    children: [
                      Image.network('https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&q=80', fit: BoxFit.cover),
                      Image.network('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80', fit: BoxFit.cover),
                    ],
                  ),
                  // Gradient for better text readability
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    height: 160,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter, end: Alignment.topCenter,
                          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  // Name and Basic Info Overlay
                  Positioned(
                    bottom: 24, left: 24, right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(userName, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
                            const SizedBox(width: 8),
                            Text('28', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w400, color: Colors.white)),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(6)),
                              child: const Row(
                                children: [
                                  Icon(Icons.verified, color: Colors.white, size: 12),
                                  SizedBox(width: 4),
                                  Text('본명인증', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            const Text('마포구 연남동 · 1.2km', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.work, color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            const Text('IT/개발기획', style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          // 2. Profile Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Manner Temp
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEBEBEF)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
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
                  const SizedBox(height: 36),

                  // Basic Profile Info Tags (Social App Style)
                  Text('기본 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8, runSpacing: 12,
                    children: [
                      _buildProfileTag('🎓', '서울 상위권 대학교', surfaceColor, textPrimary),
                      _buildProfileTag('📏', '178cm', surfaceColor, textPrimary),
                      _buildProfileTag('🎨', 'ENFP', surfaceColor, textPrimary),
                      _buildProfileTag('🍻', '가볍게 한잔', surfaceColor, textPrimary),
                      _buildProfileTag('🚭', '비흡연', surfaceColor, textPrimary),
                      _buildProfileTag('🐶', '반려동물 있음', surfaceColor, textPrimary),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Prompts (Self Interview - Hinge Style)
                  Text('나의 이야기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                  const SizedBox(height: 16),
                  _buildPromptCard('쉬는 날에는 주로...', '보통 한강에서 러닝을 하거나, 예쁜 카페에 가서 책 읽는 걸 좋아해요! 요즘은 테니스도 배우고 있습니다 🎾', surfaceColor, textPrimary, accentColor),
                  const SizedBox(height: 12),
                  _buildPromptCard('내가 찾고 있는 사람은...', '서로 긍정적인 에너지를 주고받을 수 있는 사람! 티키타카가 잘 맞으면 좋겠어요.', surfaceColor, textPrimary, accentColor),
                  const SizedBox(height: 40),

                  // Interests
                  Text('관심사 / 취향', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8, runSpacing: 10,
                    children: ['#맛집탐방', '#러닝', '#전시회', '#와인', '#드라이브'].map((hobby) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(20), 
                        border: Border.all(color: const Color(0xFFEBEBEF))
                      ),
                      child: Text(hobby, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                    )).toList(),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      // Sticky Bottom Action Bar
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () { Navigator.pop(context); },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: const Color(0xFFEBEBEF), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Icon(Icons.close, color: textSecondary, size: 28),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: () {
                     // TODO: Send Like logic
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('호감을 보냈습니다!')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      const Text('호감 보내기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTag(String emoji, String text, Color surfaceColor, Color textPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildPromptCard(String question, String answer, Color surfaceColor, Color textPrimary, Color accentColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: accentColor)),
          const SizedBox(height: 12),
          Text(answer, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary, height: 1.5)),
        ],
      ),
    );
  }
}
