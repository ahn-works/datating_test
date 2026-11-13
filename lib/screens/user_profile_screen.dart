import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../utils/app_image.dart';
import '../utils/global_data.dart';
import '../utils/oomu_ui_helpers.dart';
import '../ui/oomu_tokens.dart';
import '../ui/oomu_button.dart';
import '../ui/oomu_tag.dart';
import 'chat_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String? userId;
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
    this.userId,
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

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late String _userName;
  late String _userAge;
  late String _userLocation;
  late String _userBio;
  String? _userAvatar;
  double? _userManner;
  late List<String> _userPersonalities;
  late List<String> _userHobbies;
  late String _userJob;
  late String _userMbti;
  late List<String> _userDrinking;
  late List<String> _userPhotos;
  late String _userGender;
  late String _userSmoking;
  late String _userPet;

  @override
  void initState() {
    super.initState();
    _initDefaults();
    _fetchUserData();
  }

  void _initDefaults() {
    _userName = widget.userName;
    _userAge = widget.userAge ?? '';
    _userLocation = widget.userLocation ?? '';
    _userBio = widget.userBio ?? '';
    _userAvatar = widget.userAvatar;
    _userManner = widget.userManner;
    _userPersonalities = widget.userPersonalities ?? widget.userTags ?? [];
    _userHobbies = widget.userHobbies ?? [];
    _userJob = widget.userJob ?? '';
    _userMbti = widget.userMbti ?? '';
    _userDrinking = widget.userDrinking ?? [];
    _userPhotos = widget.userPhotos ??
        (_userAvatar != null && _userAvatar!.isNotEmpty ? [_userAvatar!] : []);
    _userGender = widget.userGender ?? '';
    _userSmoking = widget.userSmoking ?? '';
    _userPet = widget.userPet ?? '';
  }

  Future<void> _fetchUserData() async {
    final uid = widget.userId?.trim();
    if (uid == null || uid.isEmpty || uid == 'guest') {
      if (widget.isSelf) {
        _syncFromGlobalData();
      }
      return;
    }

    if (Firebase.apps.isEmpty) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists || !mounted) return;
      final data = doc.data();
      if (data == null) return;

      setState(() {
        _userName = (data['nickname'] ?? data['name'] ?? widget.userName).toString();
        final ageVal = data['age'];
        if (ageVal != null) {
          _userAge = ageVal.toString();
        }
        final loc = (data['location'] ?? data['address'])?.toString();
        if (loc != null && loc.isNotEmpty) {
          _userLocation = loc;
        }
        final bioVal = data['bio']?.toString();
        if (bioVal != null && bioVal.isNotEmpty) {
          _userBio = bioVal;
        }
        final av = (data['avatarUrl'] ?? data['photoUrl'])?.toString();
        if (av != null && av.isNotEmpty) {
          _userAvatar = av;
        }
        final mannerVal = data['mannerTemp'] ?? data['manner'];
        if (mannerVal is num) {
          _userManner = mannerVal.toDouble();
        }
        final jobVal = data['job']?.toString();
        if (jobVal != null && jobVal.isNotEmpty) {
          _userJob = jobVal;
        }
        final mbtiVal = data['mbti']?.toString();
        if (mbtiVal != null && mbtiVal.isNotEmpty) {
          _userMbti = mbtiVal;
        }
        final genderVal = data['gender']?.toString();
        if (genderVal != null && genderVal.isNotEmpty) {
          _userGender = genderVal;
        }
        if (data['personalities'] is List) {
          _userPersonalities =
              (data['personalities'] as List).map((e) => e.toString()).toList();
        }
        if (data['hobbies'] is List) {
          _userHobbies =
              (data['hobbies'] as List).map((e) => e.toString()).toList();
        }
        if (data['drinking'] is List) {
          _userDrinking =
              (data['drinking'] as List).map((e) => e.toString()).toList();
        }
        final smokeVal = data['smoking']?.toString();
        if (smokeVal != null && smokeVal.isNotEmpty) {
          _userSmoking = smokeVal;
        }
        final petVal = data['pet']?.toString();
        if (petVal != null && petVal.isNotEmpty) {
          _userPet = petVal;
        }
        if (data['photoUrls'] is List && (data['photoUrls'] as List).isNotEmpty) {
          _userPhotos =
              (data['photoUrls'] as List).map((e) => e.toString()).toList();
        } else if (_userAvatar != null && _userAvatar!.isNotEmpty) {
          _userPhotos = [_userAvatar!];
        }
      });
    } catch (e) {
      debugPrint('[UserProfileScreen] fetch error: $e');
    }
  }

  void _syncFromGlobalData() {
    setState(() {
      if (globalData.userNickname.value.isNotEmpty) {
        _userName = globalData.userNickname.value;
      }
      if (globalData.userLocation.value.isNotEmpty) {
        _userLocation = globalData.userLocation.value;
      }
      if (globalData.userAvatar.value.isNotEmpty) {
        _userAvatar = globalData.userAvatar.value;
        if (_userPhotos.isEmpty) _userPhotos = [_userAvatar!];
      }
      if (globalData.temperature.value > 0) {
        _userManner = globalData.temperature.value;
      }
    });
  }

  void _showReportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(OomuTokens.r24))),
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OomuTokens.r20)),
        title: Text('$targetType 신고 사유 선택',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: OomuTokens.fs16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reasons
              .map((r) => ListTile(
                    dense: true,
                    title: Text(r,
                        style: const TextStyle(
                            fontSize: OomuTokens.fs13,
                            fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(ctx);
                      globalData.submitReport(
                        targetType: targetType,
                        targetId: widget.userId ?? _userName,
                        targetUser: _userName,
                        reason: r,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('신고가 정상 접수되었습니다. 24시간 내 운영팀이 조치합니다.'),
                          backgroundColor: OomuTokens.coral,
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OomuTokens.r20)),
        title: const Text('사용자 차단',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: OomuTokens.fs16)),
        content: Text('$_userName님을 차단하시겠습니까?\n차단된 사용자의 모임과 대화가 즉시 숨김 처리됩니다.'),
        actions: [
          TextButton(
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text('차단하기', style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              Navigator.pop(ctx);
              globalData.blockUser(widget.userId ?? _userName);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('사용자가 차단되었습니다.'),
                  backgroundColor: OomuTokens.coral,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayAge = _userAge;
    final displayLocation =
        _userLocation.isNotEmpty ? _userLocation : '동네 이웃';
    final displayBio = _userBio.isNotEmpty
        ? _userBio
        : '안녕하세요! OOMU에서 취향이 맞는 동네 친구들을 만나고 싶어요 ✨';
    final displayAvatar = (_userAvatar != null && _userAvatar!.isNotEmpty)
        ? _userAvatar!
        : 'assets/images/초연.png';
    final double? displayManner = _userManner;
    final displayJob = _userJob;
    final displayMbti = _userMbti;
    final userPhotos = _userPhotos;

    final String fallbackPhoto = (_userName.contains('초연') || widget.isSelf)
        ? 'assets/images/초연.png'
        : 'assets/images/민지.png';

    final effectivePersonalities = _userPersonalities.isNotEmpty
        ? _userPersonalities
        : ['리액션 요정', '친화력 갑'];
    final effectiveHobbies = _userHobbies.isNotEmpty
        ? _userHobbies
        : ['맛집탐방', '카페투어'];

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
            actions: widget.isSelf
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
                    children: userPhotos.isNotEmpty
                        ? userPhotos
                            .map((p) => appNetImage(p,
                                fit: BoxFit.cover, fallback: fallbackPhoto))
                            .toList()
                        : [
                            appNetImage(displayAvatar,
                                fit: BoxFit.cover, fallback: fallbackPhoto),
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
                            Text(_userName,
                                style: const TextStyle(
                                    fontSize: OomuTokens.fsSplash,
                                    fontWeight: OomuTokens.w700,
                                    color: Colors.white)),
                            if (displayAge.isNotEmpty)
                              Text('$displayAge세',
                                  style: const TextStyle(
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
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: OomuTokens.fs15,
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (displayJob.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.work,
                                  color: Colors.white70, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  displayJob,
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: OomuTokens.fs15,
                                      fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
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
                  // Manner Temp
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
                      if (displayJob.isNotEmpty)
                        OomuTag(label: '💼 $displayJob'),
                      if (displayMbti.isNotEmpty)
                        OomuTag(label: '🎨 $displayMbti'),
                      if (_userDrinking.isNotEmpty)
                        OomuTag(label: '🍻 ${_userDrinking.join(", ")}')
                      else
                        const OomuTag(label: '🍻 가볍게 한잔'),
                      if (displayAge.isNotEmpty)
                        OomuTag(label: '🎂 $displayAge세'),
                      if (_userGender.isNotEmpty)
                        OomuTag(label: '👤 $_userGender'),
                      OomuTag(label: _userSmoking.isNotEmpty ? '🚭 $_userSmoking' : '🚭 비흡연'),
                      OomuTag(label: _userPet.isNotEmpty ? '🐶 $_userPet' : '🐶 반려동물 있음'),
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
          child: widget.isSelf
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
                      MaterialPageRoute(builder: (_) => const ChatScreen()),
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
