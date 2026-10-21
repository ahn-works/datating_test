import 'package:flutter/material.dart';
import '../utils/app_image.dart';
import '../utils/global_data.dart';

class UserProfileScreen extends StatelessWidget {
  final String userName;
  final String? userAge;
  final String? userLocation;
  final String? userBio;
  final String? userAvatar;
  final double? userManner;
  final List<String>? userTags;

  const UserProfileScreen({
    super.key,
    required this.userName,
    this.userAge,
    this.userLocation,
    this.userBio,
    this.userAvatar,
    this.userManner,
    this.userTags,
  });


  void _showReportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.report_problem_outlined, color: Colors.redAccent),
                title: const Text('이 사용자 신고하기', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showReportReasonDialog(context, '사용자');
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.redAccent),
                title: const Text('이 사용자 차단 및 매칭 제외', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showBlockConfirmDialog(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );
  }

  void _showReportReasonDialog(BuildContext context, String targetType) {
    final reasons = ['🔞 음란물 / 선정적인 콘텐츠', '🤬 욕설 / 혐오 / 비방 발언', '📢 스팸 및 불법 광고', '💸 사기 / 금전 요구 / 계정 사칭', '⚠️ 만남 노쇼 / 비매너 행위', '📝 기타 부적절한 사유'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('$targetType 신고 사유 선택', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reasons.map((r) => ListTile(
            dense: true,
            title: Text(r, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(ctx);
              globalData.submitReport(
                targetType: targetType,
                targetId: 'user_$userName',
                targetUser: userName,
                reason: r,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🚨 운영진에게 신고 접수되었습니다. 24시간 이내에 검토 후 조치됩니다.'),
                  backgroundColor: Colors.black87,
                ),
              );
            },
          )).toList(),
        ),
      )
    );
  }

  void _showBlockConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('사용자 차단', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('$userName님을 차단하시겠습니까?\n\n• 차단 즉시 서로의 모든 게시글, 댓글, 채팅 메시지가 숨겨집니다.\n• 모임 및 소개팅 추천 매칭에서 영구 제외됩니다.\n• 설정 > 차단 관리 메뉴에서 언제든지 차단을 해제할 수 있습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
            onPressed: () {
              Navigator.pop(ctx);
              globalData.blockUser(userName);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🚫 $userName님이 차단되었습니다. 모든 게시글과 대화가 즉시 숨김 처리됩니다.'), backgroundColor: Colors.redAccent));
              Navigator.pop(context); 
            }, 
            child: const Text('차단하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          ),
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color textPrimary = const Color(0xFF111111);
    final Color textSecondary = const Color(0xFF767676);
    final Color surfaceColor = const Color(0xFFFAF6F7);
    final Color accentColor = const Color(0xFFF25767);

    // 3인 페르소나 데이터 사전 정의
    final personaMap = {
      '김민서': {
        'age': '24',
        'location': '마포구 서교동',
        'manner': 37.2,
        'avatar': 'assets/images/kr_female_1.jpg',
        'job': '콘텐츠 디자이너',
        'bio': '연트럴파크 산책 & 전시회·디저트 탐방 좋아해요 ✨ 동네에서 편하게 볼 수 있는 좋은 친구 사귀고 싶어요!',
        'tags': ['산책메이트', '감성전시', '디저트덕후', '연트럴파크'],
      },
      '이준호': {
        'age': '28',
        'location': '성동구 성수동',
        'manner': 38.5,
        'avatar': 'assets/images/kr_male_1.jpg',
        'job': '브랜드 마케터',
        'bio': '성수동 스페셜티 커피 & 주말 저녁 한강 러닝 크루 🏃‍♂️ 퇴근 후 가벼운 맥주나 러닝 함께해요!',
        'tags': ['러닝크루', '에스프레소', '헬스', '성수동'],
      },
      '박지연': {
        'age': '26',
        'location': '마포구 연남동',
        'manner': 36.8,
        'avatar': 'assets/images/kr_female_2.jpg',
        'job': '파티시에 & 베이킹',
        'bio': '동네 숨은 베이킹 카페 탐방 & 반려견 산책 🐶 주말에 조용한 북카페에서 같이 책 읽으실 분 환영해요!',
        'tags': ['베이킹', '댕댕이', '북카페', '연남동'],
      },
    };

    final resolvedData = personaMap[userName] ?? {};
    final displayAge = userAge ?? (resolvedData['age'] as String?) ?? '26';
    final displayLocation = userLocation ?? (resolvedData['location'] as String?) ?? '마포구 서교동';
    final displayBio = userBio ?? (resolvedData['bio'] as String?) ?? '안녕하세요! OOMU에서 취향이 맞는 동네 친구들을 만나고 싶어요 ✨';
    final displayAvatar = userAvatar ?? (resolvedData['avatar'] as String?) ?? 'assets/images/kr_female_1.jpg';
    final displayManner = userManner ?? (resolvedData['manner'] as double?) ?? 37.0;
    final displayJob = (resolvedData['job'] as String?) ?? 'IT/콘텐츠 기획';
    final displayTags = userTags ?? (resolvedData['tags'] as List<String>?) ?? ['#동네친구', '#취향공유', '#소소한일상'];

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

            actions: [
              Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                  onPressed: () => _showReportBottomSheet(context),
                )
              )
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView(
                    children: [
                      appNetImage(displayAvatar, fit: BoxFit.cover),
                      appNetImage('assets/images/kr_female_1.jpg', fit: BoxFit.cover),
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
                            Text(displayAge, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w400, color: Colors.white)),
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
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFF4A90E2), borderRadius: BorderRadius.circular(6)),
                              child: const Row(
                                children: [
                                  Icon(Icons.work, color: Colors.white, size: 12),
                                  SizedBox(width: 4),
                                  Text('N사 재직', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFF34C759), borderRadius: BorderRadius.circular(6)),
                              child: const Row(
                                children: [
                                  Icon(Icons.school, color: Colors.white, size: 12),
                                  SizedBox(width: 4),
                                  Text('홍대졸업', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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
                            Text('$displayLocation · 동네 이웃', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.work, color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(displayJob, style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500)),
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
                            Text('${displayManner.toStringAsFixed(1)}°C', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: accentColor)),
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
                  _buildPromptCard('쉬는 날에는 주로...', displayBio, surfaceColor, textPrimary, accentColor),
                  const SizedBox(height: 12),
                  _buildPromptCard('내가 찾고 있는 사람은...', '서로 긍정적인 에너지를 주고받을 수 있는 사람! 티키타카가 잘 맞으면 좋겠어요.', surfaceColor, textPrimary, accentColor),
                  const SizedBox(height: 40),

                  // Interests
                  Text('관심사 / 취향', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8, runSpacing: 10,
                    children: displayTags.map((hobby) => Container(
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
