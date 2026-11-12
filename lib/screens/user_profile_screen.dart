import 'package:flutter/material.dart';
import '../utils/app_image.dart';
import '../utils/global_data.dart';
import '../utils/oomu_ui_helpers.dart';
import '../ui/oomu_tokens.dart';
import '../ui/oomu_button.dart';
import '../ui/oomu_tag.dart';
import 'chat_screen.dart';

class UserProfileScreen extends StatelessWidget {
  final String userName;
  final String? userAge;
  final String? userLocation;
  final String? userBio;
  final String? userAvatar;
  final double? userManner;
  final List<String>? userTags;
  final List<String>? userPersonalities;
  final List<String>? userHobbies;
  final String? userJob;
  final String? userMbti;
  final List<String>? userDrinking;
  final List<String>? userPhotos;
  final String? userGender;
  final String? userSmoking;
  final String? userPet;
  final bool isSelf;

  const UserProfileScreen({
    super.key,
    required this.userName,
    this.userAge,
    this.userLocation,
    this.userBio,
    this.userAvatar,
    this.userManner,
    this.userTags,
    this.userPersonalities,
    this.userHobbies,
    this.userJob,
    this.userMbti,
    this.userDrinking,
    this.userPhotos,
    this.userGender,
    this.userSmoking,
    this.userPet,
    this.isSelf = false,
  });

  void _showReportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(OomuTokens.r24))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: OomuTokens.divider,
                      borderRadius: BorderRadius.circular(OomuTokens.r2))),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.report_problem_outlined,
                    color: Colors.redAccent),
                title: const Text('이 사용자 신고하기',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showReportReasonDialog(context, '사용자');
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.redAccent),
                title: const Text('이 사용자 차단 및 매칭 제외',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showBlockConfirmDialog(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showReportReasonDialog(BuildContext context, String targetType) {
    final reasons = [
      '🔞 음란물 / 선정적인 콘텐츠',
      '🤬 욕설 / 혐오 / 비방 발언',
      '📢 스팸 및 불법 광고',
      '💸 사기 / 금전 요구 / 계정 사칭',
      '⚠️ 만남 노쇼 / 비매너 행위',
      '📝 기타 부적절한 사유'
    ];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OomuTokens.r20)),
        title: Text('$targetType 신고 사유 선택',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: OomuTokens.fs16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reasons
              .map((r) => ListTile(
                    dense: true,
                    title: Text(r,
                        style: const TextStyle(
                            fontSize: OomuTokens.fs13, fontWeight: FontWeight.w600)),
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
                          content:
                              Text('🚨 운영진에게 신고 접수되었습니다. 24시간 이내에 검토 후 조치됩니다.'),
                          backgroundColor: Colors.black87,
                        ),
                      );
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showBlockConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OomuTokens.r20)),
        title:
            const Text('사용자 차단', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            '$userName님을 차단하시겠습니까?\n\n• 차단 즉시 서로의 모든 게시글, 댓글, 채팅 메시지가 숨겨집니다.\n• 모임 및 소개팅 추천 매칭에서 영구 제외됩니다.\n• 설정 > 차단 관리 메뉴에서 언제든지 차단을 해제할 수 있습니다.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(OomuTokens.r10)),
                elevation: 0),
            onPressed: () {
              Navigator.pop(ctx);
              globalData.blockUser(userName);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text('🚫 $userName님이 차단되었습니다. 모든 게시글과 대화가 즉시 숨김 처리됩니다.'),
                  backgroundColor: Colors.redAccent));
              Navigator.pop(context);
            },
            child: const Text('차단하기',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 3인 페르소나 데이터 사전 정의
    final personaMap = {
      '김민서': {
        'age': '24',
        'location': '마포구 서교동',
        'manner': 37.2,
        'avatar': 'assets/images/민지.png',
        'job': '콘텐츠 디자이너',
        'bio': '연트럴파크 산책 & 전시회·디저트 탐방 좋아해요 ✨ 동네에서 편하게 볼 수 있는 좋은 친구 사귀고 싶어요!',
        'tags': ['산책메이트', '감성전시', '디저트덕후', '연트럴파크'],
      },
      '이준호': {
        'age': '28',
        'location': '성동구 성수동',
        'manner': 38.5,
        'avatar': 'assets/images/지훈.png',
        'job': '브랜드 마케터',
        'bio': '성수동 스페셜티 커피 & 주말 저녁 한강 러닝 크루 🏃‍♂️ 퇴근 후 가벼운 맥주나 러닝 함께해요!',
        'tags': ['러닝크루', '에스프레소', '헬스', '성수동'],
      },
      '박지연': {
        'age': '26',
        'location': '마포구 연남동',
        'manner': 36.8,
        'avatar': 'assets/images/시연.png',
        'job': '파티시에 & 베이킹',
        'bio': '동네 숨은 베이킹 카페 탐방 & 반려견 산책 🐶 주말에 조용한 북카페에서 같이 책 읽으실 분 환영해요!',
        'tags': ['베이킹', '댕댕이', '북카페', '연남동'],
      },
    };

    final resolvedData = personaMap[userName] ?? {};
    final displayAge = userAge ?? (resolvedData['age'] as String?) ?? '26';
    final displayLocation =
        userLocation ?? (resolvedData['location'] as String?) ?? '마포구 서교동';
    final displayBio = userBio ??
        (resolvedData['bio'] as String?) ??
        '안녕하세요! OOMU에서 취향이 맞는 동네 친구들을 만나고 싶어요 ✨';
    final displayAvatar = userAvatar ??
        (resolvedData['avatar'] as String?) ??
        'assets/images/민지.png';
    final double? displayManner =
        userManner ?? OomuUiHelpers.parseMannerValue(resolvedData['manner']);
    final displayJob = (userJob != null && userJob!.isNotEmpty)
        ? userJob!
        : ((resolvedData['job'] as String?) ?? '');
    final displayTags = (userTags != null && userTags!.isNotEmpty)
        ? userTags!
        : ((resolvedData['tags'] as List<String>?) ??
            ['#동네친구', '#취향공유', '#소소한일상']);
    final displayMbti = (userMbti != null && userMbti!.isNotEmpty)
        ? userMbti!
        : ((resolvedData['mbti'] as String?) ?? '');

    final String fallbackPhoto = (userName.contains('초연') || isSelf)
        ? 'assets/images/초연.png'
        : 'assets/images/민지.png';

    final effectivePersonalities = (userPersonalities != null && userPersonalities!.isNotEmpty)
        ? userPersonalities!
        : (userTags != null && userTags!.isNotEmpty ? userTags! : ['리액션 요정', '친화력 갑']);
    final effectiveHobbies = (userHobbies != null && userHobbies!.isNotEmpty)
        ? userHobbies!
        : (displayTags.isNotEmpty ? displayTags : ['맛집탐방', '보드게임', '카페투어']);

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
            actions: isSelf
                ? const []
                : [
                    Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.more_vert,
                            color: Colors.white, size: 20),
                        onPressed: () => _showReportBottomSheet(context),
                      ),
                    ),
                  ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView(
                    children: (userPhotos != null && userPhotos!.isNotEmpty)
                        ? userPhotos!
                            .map((p) => appNetImage(p, fit: BoxFit.cover, fallback: fallbackPhoto))
                            .toList()
                        : [
                            appNetImage(displayAvatar, fit: BoxFit.cover, fallback: fallbackPhoto),
                          ],
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 160,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.8),
                            Colors.transparent
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            Text(userName,
                                style: TextStyle(
                                    fontSize: OomuTokens.fsSplash,
                                    fontWeight: OomuTokens.w700,
                                    color: Colors.white)),
                            if (displayAge.isNotEmpty)
                              Text('$displayAge세',
                                  style: TextStyle(
                                      fontSize: OomuTokens.fs20,
                                      fontWeight: OomuTokens.w400,
                                      color: Colors.white70)),
                            const Icon(Icons.verified,
                                color: OomuTokens.coral, size: 20),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '$displayLocation · 동네 이웃',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: OomuTokens.fs15,
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.work,
                                color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                displayJob,
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: OomuTokens.fs15,
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                  // Manner Temp (방향 1: 플랫 서피스)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: OomuTokens.surfaceMuted,
                      borderRadius: BorderRadius.circular(OomuTokens.r16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('매너 온도',
                                style: TextStyle(
                                    fontWeight: OomuTokens.w700,
                                    color: OomuTokens.textPrimary,
                                    fontSize: OomuTokens.fs16)),
                            Text(
                              OomuUiHelpers.formatMannerTemp(displayManner,
                                  shortEmpty: false),
                              style: TextStyle(
                                fontWeight: OomuTokens.w700,
                                fontSize: displayManner == null
                                    ? OomuTokens.fs14
                                    : OomuTokens.fs18,
                                color: displayManner == null
                                    ? OomuTokens.textMuted
                                    : OomuTokens.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (displayManner != null) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(OomuTokens.r2),
                            child: LinearProgressIndicator(
                              value: ((displayManner - 30.0) / 70.0)
                                  .clamp(0.0, 1.0),
                              minHeight: 4,
                              backgroundColor: OomuTokens.background,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  OomuTokens.textPrimary),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: OomuTokens.s24),

                  // 1. Basic Profile Info Tags
                  const Text('기본 정보',
                      style: TextStyle(
                          fontSize: OomuTokens.fs16,
                          fontWeight: OomuTokens.w700,
                          color: OomuTokens.textPrimary)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (displayJob.isNotEmpty) OomuTag(label: '💼 $displayJob'),
                      if (displayMbti.isNotEmpty) OomuTag(label: '🎨 $displayMbti'),
                      if (userDrinking != null && userDrinking!.isNotEmpty)
                        OomuTag(label: '🍻 ${userDrinking!.join(", ")}')
                      else
                        const OomuTag(label: '🍻 가볍게 한잔'),
                      if (displayAge.isNotEmpty)
                        OomuTag(label: '🎂 $displayAge세'),
                      if (userGender != null && userGender!.isNotEmpty)
                        OomuTag(label: '👤 ${userGender!}'),
                      OomuTag(label: userSmoking != null && userSmoking!.isNotEmpty ? '🚭 $userSmoking' : '🚭 비흡연'),
                      OomuTag(label: userPet != null && userPet!.isNotEmpty ? '🐶 $userPet' : '🐶 반려동물 있음'),
                    ],
                  ),
                  const SizedBox(height: OomuTokens.s20),

                  // 2. Personality & Charm Tags
                  if (effectivePersonalities.isNotEmpty) ...[
                    const Text('성격 및 매력 태그',
                        style: TextStyle(
                            fontSize: OomuTokens.fs16,
                            fontWeight: OomuTokens.w700,
                            color: OomuTokens.textPrimary)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: effectivePersonalities
                          .map((p) => OomuTag(label: '✨ $p'))
                          .toList(),
                    ),
                    const SizedBox(height: OomuTokens.s20),
                  ],

                  // 3. Bio / Introduction
                  const Text('한줄 소개',
                      style: TextStyle(
                          fontSize: OomuTokens.fs16,
                          fontWeight: OomuTokens.w700,
                          color: OomuTokens.textPrimary)),
                  const SizedBox(height: 12),
                  _buildPromptCard('나의 이야기', displayBio),
                  const SizedBox(height: OomuTokens.s20),

                  // 4. Interests / Hobbies
                  const Text('관심사 / 취향',
                      style: TextStyle(
                          fontSize: OomuTokens.fs16,
                          fontWeight: OomuTokens.w700,
                          color: OomuTokens.textPrimary)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: effectiveHobbies
                        .map((hobby) => OomuTag(label: '#$hobby'))
                        .toList(),
                  ),
                  const SizedBox(height: OomuTokens.s32),
                ],
              ),
            ),
          ),
        ],
      ),
      // Sticky Bottom Action Bar
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: OomuTokens.s20, vertical: OomuTokens.s12),
          child: isSelf
              ? OomuButton.secondary(
                  label: '프로필 닫기',
                  onPressed: () => Navigator.pop(context),
                )
              : OomuButton(
                  label: '대화 시작하기',
                  icon: Icons.chat_bubble_outline,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ChatScreen()),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildPromptCard(String question, String answer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(OomuTokens.s16),
      decoration: BoxDecoration(
        color: OomuTokens.surfaceMuted,
        borderRadius: BorderRadius.circular(OomuTokens.r12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question,
              style: const TextStyle(
                  fontSize: OomuTokens.fs12,
                  fontWeight: OomuTokens.w600,
                  color: OomuTokens.textSecondary)),
          const SizedBox(height: 8),
          Text(answer,
              style: const TextStyle(
                  fontSize: OomuTokens.fs14,
                  fontWeight: OomuTokens.w400,
                  color: OomuTokens.textPrimary,
                  height: 1.5)),
        ],
      ),
    );
  }
}
