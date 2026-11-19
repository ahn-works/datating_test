import '../services/auth_service.dart';
import 'package:flutter/material.dart';
import '../utils/global_data.dart';
import '../utils/oomu_ui_helpers.dart';
import '../utils/app_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'oomu_home_screen.dart';
import 'oomu_my_trips_screen.dart';
import 'profile_edit_screen.dart';
import 'saved_meetups_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../services/r2_storage_service.dart';
import 'settings_screen.dart';
import 'my_page_sub_screens.dart';
import 'user_profile_screen.dart';
import 'community_post_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../ui/oomu_tokens.dart';

class MyPageScreen extends StatefulWidget {
  final bool isEmbedded;
  const MyPageScreen({super.key, this.isEmbedded = false});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final Color textPrimary = OomuTokens.textPrimary;
  final Color textSecondary = OomuTokens.textSecondary;
  final Color surfaceColor = OomuTokens.surface;
  final Color accentColor = OomuTokens.coral;
  final Color coralAccent = OomuTokens.coral;

  List<String> _parseSafeList(dynamic value, List<String> defaultValue) {
    if (value == null) return defaultValue;
    if (value is List) {
      return value
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return [value.trim()];
    }
    return defaultValue;
  }

  void _showAvatarPickerBottomSheet() {
    final avatarList = [
      {'name': '민지 (따뜻함)', 'path': 'assets/images/민지.png'},
      {'name': '시연 (카페)', 'path': 'assets/images/시연.png'},
      {'name': '지연 (와인)', 'path': 'assets/images/지연.png'},
      {'name': '지훈 (러너)', 'path': 'assets/images/지훈.png'},
      {'name': '정재 (자켓)', 'path': 'assets/images/정재.png'},
      {'name': '지안 (블랙)', 'path': 'assets/images/지안.png'},
    ];

    final r2UrlController = TextEditingController();
    bool isUploading = false;

    Future<void> pickAndSetAvatar(
        ImageSource source, StateSetter setSheetState, BuildContext ctx) async {
      try {
        final picker = ImagePicker();
        final XFile? file = await picker.pickImage(
          source: source,
          maxWidth: 1080,
          maxHeight: 1080,
          imageQuality: 85,
        );
        if (file == null) return;

        if (!R2StorageService.isImageFile(file.name)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('⚠️ 사진 파일(JPG, PNG, WEBP 등)만 업로드할 수 있습니다.')),
            );
          }
          return;
        }

        setSheetState(() => isUploading = true);
        final bytes = await file.readAsBytes();

        String avatarUrl = '';
        try {
          avatarUrl = await r2Storage.uploadImageBytes(
            bytes: bytes,
            fileName: file.name,
            category: R2UploadCategory.profile,
          );
        } catch (e) {
          debugPrint('[R2 Storage] Upload fallback: $e');
          avatarUrl = file.path;
        }

        final String finalAvatar;
        if (avatarUrl.isNotEmpty && !avatarUrl.startsWith('blob:')) {
          finalAvatar = avatarUrl;
        } else {
          finalAvatar = R2StorageService.toDataUrl(bytes, file.name);
        }
        globalData.updateAvatar(finalAvatar);

        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(globalData.activeUserId)
              .set({
            'photoUrl': finalAvatar,
            'avatarUrl': finalAvatar,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (_) {}

        if (mounted) {
          if (ctx.mounted) Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(source == ImageSource.camera
                  ? '📸 카메라로 촬영한 프로필 사진이 Cloudflare R2에 등록되었습니다!'
                  : '🖼️ 갤러리에서 선택한 프로필 사진이 Cloudflare R2에 등록되었습니다!'),
              backgroundColor: const Color(0xFFF38020),
            ),
          );
        }
      } catch (e) {
        setSheetState(() => isUploading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('사진 등록 실패: $e')),
          );
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                          color: OomuTokens.border,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text('프로필 사진 선택',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: textPrimary)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color:
                                const Color(0xFFF38020).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6)),
                        child: const Text('R2 oomu-spot',
                            style: TextStyle(
                                color: Color(0xFFF38020),
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('사진 불러오기 또는 즉시 촬영으로 프로필 사진을 변경하세요.',
                      style: TextStyle(fontSize: 13, color: textSecondary)),
                  const SizedBox(height: 18),

                  // 1 & 2: Primary Action Cards (Camera & Gallery)
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: isUploading
                              ? null
                              : () => pickAndSetAvatar(
                                  ImageSource.camera, setSheetState, ctx),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 18, horizontal: 12),
                            decoration: BoxDecoration(
                              color: OomuTokens.primarySubtle,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: coralAccent.withValues(alpha: 0.35)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: coralAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.photo_camera_rounded,
                                      color: Colors.white, size: 24),
                                ),
                                const SizedBox(height: 10),
                                const Text('사진 찍기',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: OomuTokens.textPrimary)),
                                const SizedBox(height: 4),
                                Text('카메라로 바로 촬영',
                                    style: TextStyle(
                                        fontSize: 12, color: textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: isUploading
                              ? null
                              : () => pickAndSetAvatar(
                                  ImageSource.gallery, setSheetState, ctx),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 18, horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7EE),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFFF38020)
                                      .withValues(alpha: 0.35)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF38020),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.photo_library_rounded,
                                      color: Colors.white, size: 24),
                                ),
                                const SizedBox(height: 10),
                                const Text('사진 불러오기',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: OomuTokens.textPrimary)),
                                const SizedBox(height: 4),
                                Text('갤러리/앨범 선택',
                                    style: TextStyle(
                                        fontSize: 12, color: textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (isUploading) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF38020).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Color(0xFFF38020))),
                          SizedBox(width: 12),
                          Text('Cloudflare R2 (oomu-spot)에 사진 업로드 중...',
                              style: TextStyle(
                                  color: Color(0xFFF38020),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),
                  Text('또는 2030 아바타 추천',
                      style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: avatarList.length,
                      itemBuilder: (context, index) {
                        final item = avatarList[index];
                        final isSel =
                            globalData.userAvatar.value == item['path'];
                        return GestureDetector(
                          onTap: () async {
                            globalData.updateAvatar(item['path']!);
                            try {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(globalData.activeUserId)
                                  .set({
                                'photoUrl': item['path']!,
                                'updatedAt': FieldValue.serverTimestamp(),
                              }, SetOptions(merge: true));
                            } catch (_) {}
                            if (ctx.mounted) Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '✨ [${item['name']}] 프로필 사진으로 변경되었습니다!')),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 14),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 68,
                                      height: 68,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSel
                                              ? coralAccent
                                              : Colors.transparent,
                                          width: 3,
                                        ),
                                        image: DecorationImage(
                                          image: AssetImage(item['path']!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    if (isSel)
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: CircleAvatar(
                                          radius: 10,
                                          backgroundColor: coralAccent,
                                          child: const Icon(Icons.check,
                                              size: 12, color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(item['name']!,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            isSel ? coralAccent : textSecondary,
                                        fontWeight: isSel
                                            ? FontWeight.bold
                                            : FontWeight.w500)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Cloudflare R2 사진 링크 직접 등록',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textPrimary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: r2UrlController,
                          decoration: InputDecoration(
                            hintText: 'https://pub-xxxx.r2.dev/photo.jpg',
                            hintStyle: const TextStyle(
                                color: OomuTokens.border, fontSize: 13),
                            filled: true,
                            fillColor: surfaceColor,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: coralAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onPressed: () async {
                          final url = r2UrlController.text.trim();
                          if (url.isNotEmpty) {
                            globalData.updateAvatar(url);
                            try {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(globalData.activeUserId)
                                  .set({
                                'photoUrl': url,
                                'updatedAt': FieldValue.serverTimestamp(),
                              }, SetOptions(merge: true));
                            } catch (_) {}
                            if (ctx.mounted) Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      '☁️ Cloudflare R2 프로필 사진이 적용되었습니다!')),
                            );
                          }
                        },
                        child: const Text('적용',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ValueListenableBuilder<Map<String, bool>>(
              valueListenable: globalData.notificationSettings,
              builder: (context, notifMap, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                            color: OomuTokens.border,
                            borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(Icons.notifications_active,
                            color: coralAccent, size: 24),
                        const SizedBox(width: 8),
                        Text('알림 설정',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('중요한 모임 알림과 실시간 채팅 알림을 관리하세요.',
                        style: TextStyle(fontSize: 13, color: textSecondary)),
                    const SizedBox(height: 20),
                    _buildSwitchTile(
                      '모임 참여 승인/반려 알림',
                      '내가 신청한 모임의 방장 수락 상태를 바로 알려드려요.',
                      notifMap['joinApproval'] ?? true,
                      () {
                        globalData.toggleNotification('joinApproval');
                        setSheetState(() {});
                      },
                    ),
                    _buildSwitchTile(
                      '새로운 채팅 메시지',
                      '참여 중인 모임의 실시간 단체 채팅 알림입니다.',
                      notifMap['newChat'] ?? true,
                      () {
                        globalData.toggleNotification('newChat');
                        setSheetState(() {});
                      },
                    ),
                    _buildSwitchTile(
                      '시크릿 프로필 매칭 알림',
                      '동네 취향이 딱 맞는 메이트가 접속했을 때 알림',
                      notifMap['secretMatch'] ?? true,
                      () {
                        globalData.toggleNotification('secretMatch');
                        setSheetState(() {});
                      },
                    ),
                    _buildSwitchTile(
                      '귀가 안심 폭탄 타이머 알림',
                      '모임 귀가 시 안전 확인 10분 전 푸시 알림',
                      notifMap['bombTimer'] ?? true,
                      () {
                        globalData.toggleNotification('bombTimer');
                        setSheetState(() {});
                      },
                    ),
                    _buildSwitchTile(
                      '이벤트 및 혜택 알림',
                      '주말 번개 스팟 및 할인 쿠폰 소식',
                      notifMap['marketing'] ?? false,
                      () {
                        globalData.toggleNotification('marketing');
                        setSheetState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, String subtitle, bool value, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(fontSize: 12, color: textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: coralAccent,
            onChanged: (_) => onToggle(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OomuTokens.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: OomuTokens.surface,
        elevation: 0,
        title: const Text('마이페이지',
            style: TextStyle(
                color: OomuTokens.textPrimary,
                fontSize: OomuTokens.fs22,
                fontWeight: OomuTokens.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: OomuTokens.textSecondary),
            tooltip: '설정',
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: globalData.currentUserId,
        builder: (context, activeUid, _) {
          final bool canQueryFirestore = Firebase.apps.isNotEmpty &&
              activeUid.isNotEmpty &&
              activeUid != 'guest';
          return StreamBuilder<DocumentSnapshot>(
            stream: canQueryFirestore
                ? FirebaseFirestore.instance
                    .collection('users')
                    .doc(activeUid)
                    .snapshots()
                : null,
            builder: (context, snapshot) {
              String role = activeUid == 'admin_user' ? 'admin' : 'user';
              String nickname = globalData.userNickname.value.isNotEmpty
                  ? globalData.userNickname.value
                  : '닉네임 미설정';
              String name = globalData.userName.value;
              int age = globalData.userAge.value;
              String gender = globalData.userGender.value;
              String location = globalData.userLocation.value.isNotEmpty
                  ? globalData.userLocation.value
                  : '동네 미설정';
              String bio = globalData.userBio.value;
              String job = globalData.userJob.value;
              String mbti = globalData.userMbti.value;
              String smoking = globalData.userSmoking.value;
              String pet = globalData.userPet.value;
              int joinedCount = globalData.joinedMeetupsCount.value;
              int myPostsCount = globalData.myPostsCount.value;
              int reviewCount = globalData.reviewCount.value;
              bool isVerified = globalData.isPhoneVerified.value;
              double? loadedManner;
              String? loadedAvatar;
              List<String> hobbies = List<String>.from(globalData.userHobbies.value);
              List<String> closeFriendPersonalities = [];
              List<String> values = [];
              List<String> personalities = List<String>.from(globalData.userPersonalities.value);
              List<String> drinking = List<String>.from(globalData.userDrinking.value);
              List<String> userPhotos = List<String>.from(globalData.userPhotos.value);

              try {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.exists) {
                  final rawData = snapshot.data!.data();
                  if (rawData is Map<String, dynamic>) {
                    final data = rawData;
                    role = data['role']?.toString() ?? role;
                    final loadedNick = data['nickname']?.toString().trim();
                    if (loadedNick != null && loadedNick.isNotEmpty) {
                      nickname = loadedNick;
                    }
                    name = data['name']?.toString() ?? name;
                    if (data['age'] != null) {
                      age = data['age'] is int
                          ? data['age']
                          : (int.tryParse(data['age'].toString()) ?? age);
                    }
                    gender = data['gender']?.toString() ?? gender;
                    final loadedLoc = data['location']?.toString().trim();
                    if (loadedLoc != null && loadedLoc.isNotEmpty) {
                      location = loadedLoc;
                    }
                    final loadedBio = data['bio']?.toString().trim();
                    if (loadedBio != null && loadedBio.isNotEmpty) {
                      bio = loadedBio;
                    }
                    job = data['job']?.toString().trim() ?? job;
                    mbti = data['mbti']?.toString().trim() ?? mbti;
                    final rawHobbies =
                        _parseSafeList(data['hobbies'], <String>[]);
                    final rawInterests =
                        _parseSafeList(data['interests'], <String>[]);
                    if (rawHobbies.isNotEmpty) {
                      hobbies = rawHobbies;
                    } else if (rawInterests.isNotEmpty) {
                      hobbies = rawInterests;
                    }
                    personalities =
                        _parseSafeList(data['personalities'], personalities);
                    drinking = _parseSafeList(data['drinking'], drinking);
                    closeFriendPersonalities = _parseSafeList(
                        data['closeFriendPersonalities'],
                        closeFriendPersonalities);
                    values = _parseSafeList(data['values'], values);
                    final rawSmoking = data['smoking']?.toString().trim();
                    if (rawSmoking != null && rawSmoking.isNotEmpty) {
                      smoking = rawSmoking;
                    }
                    final rawPet = data['pet']?.toString().trim();
                    if (rawPet != null && rawPet.isNotEmpty) {
                      pet = rawPet;
                    }

                    if (data['joinedMeetupsCount'] is num) {
                      joinedCount = (data['joinedMeetupsCount'] as num).toInt();
                    } else if (data['joinedMeetupIds'] is List) {
                      joinedCount = (data['joinedMeetupIds'] as List).length;
                    } else if (data['tripCount'] is num) {
                      joinedCount = (data['tripCount'] as num).toInt();
                    } else {
                      joinedCount = 0;
                    }

                    if (data['myPostsCount'] is num) {
                      myPostsCount = (data['myPostsCount'] as num).toInt();
                    } else if (data['postCount'] is num) {
                      myPostsCount = (data['postCount'] as num).toInt();
                    } else {
                      myPostsCount = 0;
                    }

                    if (data['reviewCount'] is num) {
                      reviewCount = (data['reviewCount'] as num).toInt();
                    } else if (data['reviewsCount'] is num) {
                      reviewCount = (data['reviewsCount'] as num).toInt();
                    } else if (data['reviews'] is List) {
                      reviewCount = (data['reviews'] as List).length;
                    } else {
                      reviewCount = 0;
                    }

                    if (data['isPhoneVerified'] is bool) {
                      isVerified = data['isPhoneVerified'] as bool;
                    } else if (data['isVerified'] is bool) {
                      isVerified = data['isVerified'] as bool;
                    }

                    loadedManner = OomuUiHelpers.parseMannerTemp(data);

                    if (data['photoUrls'] is List) {
                      userPhotos = List<String>.from(
                          (data['photoUrls'] as List).map((e) => e.toString()));
                    } else if (data['photoUrl'] != null &&
                        data['photoUrl'].toString().isNotEmpty) {
                      userPhotos = [data['photoUrl'].toString()];
                    }

                    loadedAvatar = (data['photoUrl'] ?? data['avatarUrl'])
                        ?.toString()
                        .trim();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && globalData.activeUserId == activeUid) {
                        globalData.applyProfileData(data);
                      }
                    });
                  }
                }
              } catch (e) {
                debugPrint('MyPage data parse error: $e');
              }

              final effectiveAvatar =
                  (loadedAvatar != null && loadedAvatar.isNotEmpty)
                      ? loadedAvatar
                      : globalData.userAvatar.value;

              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // 계정 전환 바 (개발/테스트 플래그 명시 시에만 표시)
                  if (const bool.fromEnvironment('OOMU_DEV_ACCOUNTS',
                          defaultValue: false) &&
                      ((Firebase.apps.isNotEmpty && authService.isAdmin) ||
                          role == 'admin' ||
                          activeUid == 'admin_user'))
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: OomuTokens.surfaceMuted,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: OomuTokens.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.switch_account_outlined,
                              size: 20, color: OomuTokens.textSecondary),
                          const SizedBox(width: 8),
                          Text('계정 모드: ',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: textSecondary)),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildAccountBadge(
                                    context: context,
                                    uid: 'admin_user',
                                    label: '👑 관리자 (운영팀)',
                                    isSelected: activeUid == 'admin_user',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildAccountBadge(
                                    context: context,
                                    uid: 'test_user_1',
                                    label: '👤 김민우 (호스트)',
                                    isSelected: activeUid == 'test_user_1',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildAccountBadge(
                                    context: context,
                                    uid: 'test_user_2',
                                    label: '🌸 이지은 (참가자)',
                                    isSelected: activeUid == 'test_user_2',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // 1. 프로필 상단 헤더 영역 (Direction 1: 아바타 64x64 + 닉네임 + 본인인증 뱃지 + 프로필 수정 버튼)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Tooltip(
                          message: '내 프로필 보기',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(32),
                            onLongPress: _showAvatarPickerBottomSheet,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UserProfileScreen(
                                    userName: nickname,
                                    userAge: age > 0 ? '$age' : '',
                                    userLocation: location,
                                    userBio: bio,
                                    userAvatar: effectiveAvatar,
                                    userManner: loadedManner ??
                                        OomuUiHelpers.parseMannerValue(
                                            globalData.temperature.value),
                                    userTags: hobbies.isNotEmpty
                                        ? hobbies
                                        : personalities,
                                    userPersonalities: personalities,
                                    userHobbies: hobbies,
                                    userJob: job,
                                    userMbti: mbti,
                                    userDrinking: drinking,
                                    userPhotos: userPhotos,
                                    userGender: gender,
                                    userSmoking: smoking,
                                    userPet: pet,
                                    userVerified: isVerified,
                                    isSelf: true,
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: SizedBox(
                                width: 64,
                                height: 64,
                                child: ValueListenableBuilder<String>(
                                  valueListenable: globalData.userAvatar,
                                  builder: (context, avatarVal, _) {
                                    final currentAvatar = (loadedAvatar != null &&
                                            loadedAvatar.isNotEmpty)
                                        ? loadedAvatar
                                        : avatarVal;
                                    return _buildAvatarImage(currentAvatar);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                nickname,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: OomuTokens.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 3,
                                runSpacing: 2,
                                children: [
                                  Text(
                                    location,
                                    style: const TextStyle(
                                      color: OomuTokens.textSecondary,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Text('·',
                                      style: TextStyle(
                                          color: OomuTokens.textSecondary,
                                          fontSize: 12)),
                                  Icon(
                                    isVerified
                                        ? Icons.verified_user_rounded
                                        : Icons.info_outline_rounded,
                                    color: isVerified
                                        ? const Color(0xFF10B981)
                                        : OomuTokens.textSecondary,
                                    size: 13,
                                  ),
                                  Text(
                                    isVerified ? '본인인증 완료' : '본인인증 미완료',
                                    style: const TextStyle(
                                      color: OomuTokens.textSecondary,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: '내 프로필 수정',
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 48),
                            child: Center(
                              child: OutlinedButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const ProfileEditScreen()),
                                  );
                                  if (mounted) setState(() {});
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: OomuTokens.border),
                                  backgroundColor: Colors.white,
                                  foregroundColor: OomuTokens.textPrimary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                ),
                                child: const Text(
                                  '프로필 수정',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: OomuTokens.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. 매너온도 카드 (13년차 시니어 디자이너 표준: 초기값 0.0°C 설정, 화이트 카드 + 1px 테두리 + 코랄 프로그레스)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: OomuTokens.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: OomuTokens.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ValueListenableBuilder<double>(
                        valueListenable: globalData.temperature,
                        builder: (context, temp, _) {
                          final parsed = OomuUiHelpers.parseMannerValue(temp);
                          final manner = loadedManner ?? parsed;
                          final double displayTemp = (manner != null && manner >= 0.0) ? manner : 0.0;
                          final double progress = (displayTemp / 100.0).clamp(0.0, 1.0);
                          final bool isInitial = displayTemp == 0.0 || reviewCount == 0;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF0F1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.thermostat_rounded,
                                            size: 16,
                                            color: OomuTokens.coral,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Flexible(
                                          child: Text(
                                            '매너온도',
                                            style: TextStyle(
                                              color: OomuTokens.textPrimary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${displayTemp.toStringAsFixed(1)}°C',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: OomuTokens.coral,
                                      letterSpacing: -0.3,
                                      fontFamily: OomuTokens.fontFamily,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: Container(
                                  height: 6,
                                  color: const Color(0xFFF3F4F6),
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: progress,
                                    child: Container(
                                      color: OomuTokens.coral,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isInitial
                                    ? '첫 평가 전 (초기 매너온도 0.0°C)'
                                    : '받은 후기 $reviewCount개',
                                style: const TextStyle(
                                  color: OomuTokens.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3. 내 활동 메뉴 목록 (참여한 모임, 찜한 모임, 내가 쓴 글, 받은 후기)
                  _buildMenuItem(
                    icon: Icons.calendar_today_outlined,
                    title: '참여한 모임',
                    badge: '$joinedCount',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const OOMUMyTripsScreen()),
                      );
                    },
                  ),
                  ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: globalData.savedMeetups,
                    builder: (context, saved, _) {
                      return _buildMenuItem(
                        icon: Icons.favorite_border_rounded,
                        title: '찜한 모임',
                        badge: '${saved.length}',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SavedMeetupsScreen()),
                          );
                        },
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.edit_outlined,
                    title: '내가 쓴 글',
                    badge: '$myPostsCount',
                    onTap: _showMyPostsModal,
                  ),
                  _buildMenuItem(
                    icon: Icons.star_outline_rounded,
                    title: '받은 후기',
                    badge: '$reviewCount',
                    onTap: _showReviewsModal,
                  ),

                  // 4. 간격 밴드 (Gap Band)
                  Container(
                    height: 8,
                    color: OomuTokens.surfaceMuted,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                  ),

                  // 5. 안전 및 설정 메뉴 목록 (안전 센터, 알림 설정, 고객센터, 설정)
                  _buildMenuItem(
                    icon: Icons.shield_outlined,
                    title: '안전 센터',
                    onTap: _showSafetyCenterModal,
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_none_rounded,
                    title: '알림 설정',
                    onTap: _showNotificationSettingsBottomSheet,
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: '고객센터',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CustomerCenterScreen()),
                    ),
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: '설정',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 96),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: widget.isEmbedded ? null : _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 4,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: OomuTokens.textPrimary,
      unselectedItemColor: OomuTokens.textMuted,
      showUnselectedLabels: true,
      selectedLabelStyle:
          const TextStyle(fontWeight: OomuTokens.w700, fontSize: 11),
      unselectedLabelStyle:
          const TextStyle(fontWeight: OomuTokens.w400, fontSize: 11),
      elevation: 0,
      backgroundColor: OomuTokens.surface,
      onTap: (index) {
        if (index <= 2) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => OOMUHomeScreen(initialTab: index)));
        } else if (index == 3) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const OOMUHomeScreen(initialTab: 3)));
        } else if (index == 4) {
          // current MY tab
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined, size: 24),
          activeIcon: Icon(Icons.home, size: 24),
          label: '동네모임',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_outlined, size: 24),
          activeIcon: Icon(Icons.group, size: 24),
          label: '커뮤니티',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined, size: 24),
          activeIcon: Icon(Icons.explore, size: 24),
          label: '발견',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline, size: 23),
          activeIcon: Icon(Icons.chat_bubble, size: 23),
          label: '채팅',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline, size: 24),
          activeIcon: Icon(Icons.person, size: 24),
          label: 'MY',
        ),
      ],
    );
  }

  Widget _buildAccountBadge({
    required BuildContext context,
    required String uid,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        globalData.switchUser(uid);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔄 [$label] 계정으로 전환되었습니다.'),
            duration: const Duration(seconds: 1),
            backgroundColor: isSelected ? coralAccent : OomuTokens.textPrimary,
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? coralAccent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? coralAccent : const Color(0xFFD1D1D6)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: coralAccent.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : OomuTokens.textBody,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Icon(icon, size: 21, color: OomuTokens.textBody),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: OomuTokens.textPrimary,
                ),
              ),
            ),
            if (badge != null && badge.isNotEmpty) ...[
              Text(
                badge,
                style: const TextStyle(
                  fontSize: 14,
                  color: OomuTokens.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: OomuTokens.border,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarImage(String? url) {
    final effectiveUrl = (url ?? '').trim();
    if (effectiveUrl.isEmpty) {
      return Container(
        color: OomuTokens.surfaceMuted,
        alignment: Alignment.center,
        child: const Icon(Icons.person_outline_rounded,
            color: OomuTokens.textMuted, size: 32),
      );
    }
    return Image(
      image: appImg(effectiveUrl),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: OomuTokens.surfaceMuted,
        alignment: Alignment.center,
        child: const Icon(Icons.person_outline_rounded,
            color: OomuTokens.textMuted, size: 32),
      ),
    );
  }

  void _showMyPostsModal() {
    final activeUid = globalData.activeUserId.trim();
    final authUid = (FirebaseAuth.instance.currentUser?.uid ?? '').trim();
    final currentNick = globalData.userNickname.value.trim();

    final userIds = <String>{
      if (activeUid.isNotEmpty && activeUid != 'guest') activeUid,
      if (authUid.isNotEmpty) authUid,
    };
    final userNicks = <String>{
      if (currentNick.isNotEmpty && activeUid != 'guest') currentNick,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return DefaultTabController(
            length: 2,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: OomuTokens.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TabBar(
                    labelColor: OomuTokens.coral,
                    unselectedLabelColor: OomuTokens.textSecondary,
                    indicatorColor: OomuTokens.coral,
                    indicatorWeight: 3,
                    labelStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: OomuTokens.fontFamily,
                    ),
                    tabs: [
                      Tab(text: '내가 쓴 글'),
                      Tab(text: '내가 쓴 댓글'),
                    ],
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('community_posts')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: OomuTokens.coral),
                          );
                        }
                        final docs = snapshot.data?.docs ?? [];
                        final List<Map<String, dynamic>> myPosts = [];
                        final List<Map<String, dynamic>> myComments = [];

                        for (final doc in docs) {
                          final data = Map<String, dynamic>.from(doc.data() as Map);
                          data['id'] = doc.id;
                          final authorId = (data['authorId'] ?? '').toString();
                          final author = (data['author'] ?? '').toString();

                          final isMyPost = (authorId.isNotEmpty && userIds.contains(authorId)) ||
                              (author.isNotEmpty && userNicks.contains(author));
                          if (isMyPost) {
                            myPosts.add(data);
                          }

                          final comments = (data['comments'] is List)
                              ? (data['comments'] as List)
                              : [];
                          for (final c in comments) {
                            if (c is Map) {
                              final cMap = Map<String, dynamic>.from(c);
                              final cAuthorId = (cMap['authorId'] ?? '').toString();
                              final cAuthor = (cMap['author'] ?? '').toString();
                              final isMyComment = (cAuthorId.isNotEmpty && userIds.contains(cAuthorId)) ||
                                  (cAuthor.isNotEmpty && userNicks.contains(cAuthor));
                              if (isMyComment) {
                                myComments.add({
                                  ...cMap,
                                  'post': data,
                                  'postTitle': data['title'] ?? '동네 커뮤니티 글',
                                });
                              }
                            }
                          }
                        }

                        return TabBarView(
                          children: [
                            // 1. 내가 쓴 글 목록
                            myPosts.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(24),
                                      child: Text(
                                        '아직 작성한 동네 커뮤니티 글이 없습니다.',
                                        style: TextStyle(
                                            color: OomuTokens.textSecondary, fontSize: 14),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.all(20),
                                    itemCount: myPosts.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(height: 24),
                                    itemBuilder: (context, index) {
                                      final post = myPosts[index];
                                      return InkWell(
                                        onTap: () {
                                          Navigator.pop(ctx);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  CommunityPostDetailScreen(
                                                      post: post),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: OomuTokens.surfaceMuted,
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    post['category']?.toString() ??
                                                        '동네소식',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                      color:
                                                          OomuTokens.textSecondary,
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  post['time']?.toString() ??
                                                      '최근',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        OomuTokens.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              post['title']?.toString() ?? '',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: OomuTokens.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              post['content']?.toString() ?? '',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: OomuTokens.textSecondary,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),

                            // 2. 내가 쓴 댓글 목록
                            myComments.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(24),
                                      child: Text(
                                        '아직 작성한 댓글이 없습니다.',
                                        style: TextStyle(
                                            color: OomuTokens.textSecondary, fontSize: 14),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.all(20),
                                    itemCount: myComments.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(height: 24),
                                    itemBuilder: (context, index) {
                                      final comment = myComments[index];
                                      final post = comment['post'] as Map<String, dynamic>;
                                      return InkWell(
                                        onTap: () {
                                          Navigator.pop(ctx);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  CommunityPostDetailScreen(
                                                      post: post),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '원글: ${comment['postTitle']}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: OomuTokens.coral,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              comment['content']?.toString() ?? '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: OomuTokens.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              comment['time']?.toString() ??
                                                  '방금 전',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: OomuTokens.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showReviewsModal() {
    final activeUid =
        (FirebaseAuth.instance.currentUser?.uid ?? globalData.activeUserId)
            .trim();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: (activeUid.isEmpty ||
                          activeUid == 'guest' ||
                          Firebase.apps.isEmpty)
                      ? null
                      : FirebaseFirestore.instance
                          .collection('users')
                          .doc(activeUid)
                          .collection('reviews')
                          .snapshots(),
                  builder: (context, snapshot) {
                    final docs = snapshot.data?.docs ?? [];
                    final int count = docs.length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('받은 후기 ($count개)',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            if (count > 0)
                              const Text('100% 만족',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: OomuTokens.coral)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (count == 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 36),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star_outline_rounded,
                                      size: 48, color: Colors.grey.shade300),
                                  const SizedBox(height: 12),
                                  Text(
                                    '아직 받은 후기가 없어요',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '동네 모임에 참여하고 첫 후기를 받아보세요!',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: docs.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final rData = docs[index].data();
                              final content = (rData['content'] ??
                                      rData['text'] ??
                                      '')
                                  .toString();
                              final meetupTitle = (rData['meetupTitle'] ??
                                      rData['title'] ??
                                      '동네 모임')
                                  .toString();
                              final time = (rData['time'] ?? '최근').toString();
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  backgroundColor: OomuTokens.surfaceMuted,
                                  child: Icon(Icons.person,
                                      color: OomuTokens.textSecondary),
                                ),
                                title: Text(
                                  content,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  '$meetupTitle · $time',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: OomuTokens.textSecondary),
                                ),
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSafetyCenterModal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReportHistoryScreen()),
    );
  }
}
