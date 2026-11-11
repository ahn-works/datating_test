import 'login_screen.dart';
import '../services/auth_service.dart';
import 'package:flutter/material.dart';
import '../utils/global_data.dart';
import '../utils/oomu_ui_helpers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'oomu_home_screen.dart';
import 'chat_screen.dart';
import 'oomu_my_trips_screen.dart';
import 'profile_edit_screen.dart';
import 'saved_meetups_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../services/r2_storage_service.dart';
import 'settings_screen.dart';
import 'my_page_sub_screens.dart';
import 'user_profile_screen.dart';
import '../widgets/bouncy_tap.dart';
import '../ui/oomu_tokens.dart';
import '../ui/oomu_button.dart';
import '../ui/oomu_tag.dart';
import '../ui/oomu_avatar.dart';
import '../ui/oomu_sheet.dart';

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

        final finalAvatar = avatarUrl.isNotEmpty ? avatarUrl : file.path;
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
          Navigator.pop(ctx);
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
                          color: const Color(0xFFE5E5EA),
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
                              color: const Color(0xFFFFF0F2),
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
                                        color: Color(0xFF111111))),
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
                                        color: Color(0xFF111111))),
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
                            Navigator.pop(ctx);
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
                                color: Color(0xFFC7C7CC), fontSize: 13),
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
                            Navigator.pop(ctx);
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
                            color: const Color(0xFFE5E5EA),
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

  void _showCustomerCenterModal() {
    final inquiryCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                      color: const Color(0xFFE5E5EA),
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.support_agent, color: coralAccent, size: 26),
                  const SizedBox(width: 8),
                  Text('고객 센터 & FAQ',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: textPrimary)),
                ],
              ),
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Q. 모임 참여는 어떻게 승인되나요?',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('방장이 프로필과 매너 온도를 확인 후 승인하면 채팅방에 자동으로 초대됩니다.',
                        style: TextStyle(fontSize: 13, color: textSecondary)),
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text('Q. 찜한 모임은 어디서 확인하나요?',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('마이페이지 > [내가 찜한 모임] 메뉴에서 언제든 확인 및 참여하실 수 있습니다.',
                        style: TextStyle(fontSize: 13, color: textSecondary)),
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text('Q. 비매너 사용자를 신고하고 싶어요.',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('채팅방 우측 상단 더보기 > [신고하기]를 누르면 운영팀에 실시간 접수됩니다.',
                        style: TextStyle(fontSize: 13, color: textSecondary)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('1:1 문의 남기기',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textPrimary)),
              const SizedBox(height: 8),
              TextField(
                controller: inquiryCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '문의 내용을 작성해 주시면 24시간 이내에 답변드립니다.',
                  hintStyle:
                      const TextStyle(color: Color(0xFFC7C7CC), fontSize: 13),
                  filled: true,
                  fillColor: surfaceColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: coralAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    if (inquiryCtrl.text.trim().isNotEmpty) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('📨 문의가 정상적으로 접수되었습니다. 빠르게 확인하겠습니다!')),
                      );
                    }
                  },
                  child: const Text('문의 접수하기',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
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
            icon: const Icon(Icons.settings_outlined, color: OomuTokens.textSecondary),
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
          final bool canQueryFirestore =
              Firebase.apps.isNotEmpty && activeUid.isNotEmpty;
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
              String name = '';
              int age = 0;
              String gender = '';
              String location = globalData.userLocation.value.isNotEmpty
                  ? globalData.userLocation.value
                  : '동네 미설정';
              String bio = '자기소개가 아직 등록되지 않았어요.';
              String job = '';
              String mbti = '';
              String jobAndMbti = '프로필 정보 미설정';
              List<String> hobbies = [];
              List<String> closeFriendPersonalities = [];
              List<String> values = [];
              List<String> personalities = [];
              List<String> drinking = [];
              List<String> userPhotos = [];

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
                    final metaParts = <String>[
                      if (age > 0) '$age세',
                      if (gender.isNotEmpty) gender,
                      if (job.isNotEmpty) job,
                      if (mbti.isNotEmpty) mbti,
                    ];
                    jobAndMbti = metaParts.isNotEmpty
                        ? metaParts.join(' · ')
                        : '프로필 정보 미설정';
                    final rawInterests =
                        _parseSafeList(data['interests'], <String>[]);
                    final rawHobbies =
                        _parseSafeList(data['hobbies'], <String>[]);
                    final combinedHobbies =
                        <String>{...rawInterests, ...rawHobbies}.toList();
                    if (combinedHobbies.isNotEmpty) {
                      hobbies = combinedHobbies;
                    } else {
                      hobbies = _parseSafeList(data['hobbies'], hobbies);
                    }
                    personalities =
                        _parseSafeList(data['personalities'], personalities);
                    drinking = _parseSafeList(data['drinking'], drinking);
                    closeFriendPersonalities = _parseSafeList(
                        data['closeFriendPersonalities'],
                        closeFriendPersonalities);
                    values = _parseSafeList(data['values'], values);
                    if (data['photoUrls'] is List) {
                      userPhotos = List<String>.from(
                          (data['photoUrls'] as List).map((e) => e.toString()));
                    } else if (data['photoUrl'] != null &&
                        data['photoUrl'].toString().isNotEmpty) {
                      userPhotos = [data['photoUrl'].toString()];
                    }

                    final loadedAvatar = (data['photoUrl'] ?? data['avatarUrl'])
                        ?.toString()
                        .trim();
                    if (loadedAvatar != null &&
                        loadedAvatar.isNotEmpty &&
                        globalData.userAvatar.value != loadedAvatar) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && globalData.activeUserId == activeUid) {
                          globalData.userAvatar.value = loadedAvatar;
                        }
                      });
                    }
                    if (loadedNick != null &&
                        loadedNick.isNotEmpty &&
                        globalData.userNickname.value != loadedNick) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && globalData.activeUserId == activeUid) {
                          globalData.userNickname.value = loadedNick;
                        }
                      });
                    }
                    if (loadedLoc != null &&
                        loadedLoc.isNotEmpty &&
                        globalData.userLocation.value != loadedLoc) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && globalData.activeUserId == activeUid) {
                          globalData.userLocation.value = loadedLoc;
                        }
                      });
                    }
                  }
                }
              } catch (e) {
                debugPrint('MyPage data parse error: $e');
              }

              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // 계정 전환 바 (총괄 관리자 및 관리자 권한만 표시)
                  if ((Firebase.apps.isNotEmpty && authService.isAdmin) ||
                      role == 'admin' ||
                      activeUid == 'admin_user')
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E5EA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.switch_account_outlined,
                              size: 20, color: Color(0xFF8E8E93)),
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
                  // User Profile Card (방향 1: 플랫 서피스)
                  Container(
                    padding: const EdgeInsets.all(OomuTokens.s20),
                    decoration: BoxDecoration(
                      color: OomuTokens.surface,
                      borderRadius: BorderRadius.circular(OomuTokens.r16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _showAvatarPickerBottomSheet,
                              child: Stack(
                                children: [
                                  ValueListenableBuilder<String>(
                                    valueListenable: globalData.userAvatar,
                                    builder: (context, avatar, _) {
                                      return OomuAvatar(
                                        radius: 36,
                                        imageUrl: avatar,
                                      );
                                    },
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: OomuTokens.textPrimary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: OomuTokens.surface, width: 2),
                                      ),
                                      child: const Icon(Icons.camera_alt,
                                          size: 12, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: OomuTokens.s16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          nickname,
                                          maxLines: 1,
                                          style: const TextStyle(
                                              fontSize: OomuTokens.fs18,
                                              fontWeight: OomuTokens.w700,
                                              color: OomuTokens.textPrimary),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (role == 'admin') ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: OomuTokens.background,
                                            borderRadius:
                                                BorderRadius.circular(OomuTokens.r8),
                                          ),
                                          child: const Text(
                                            '운영팀',
                                            style: TextStyle(
                                                color: OomuTokens.textSecondary,
                                                fontSize: 11,
                                                fontWeight: OomuTokens.w600),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(jobAndMbti,
                                      style: const TextStyle(
                                          color: OomuTokens.textSecondary,
                                          fontSize: OomuTokens.fs12,
                                          fontWeight: OomuTokens.w400)),
                                  const SizedBox(height: 4),
                                  ValueListenableBuilder<String>(
                                    valueListenable: globalData.userLocation,
                                    builder: (context, loc, _) {
                                      final displayLoc =
                                          loc.isNotEmpty ? loc : location;
                                      return Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 13, color: OomuTokens.textMuted),
                                          const SizedBox(width: 2),
                                          Flexible(
                                              child: Text(
                                                  displayLoc,
                                                  style: const TextStyle(
                                                      color: OomuTokens.textSecondary,
                                                      fontSize: OomuTokens.fs12),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis)),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: OomuTokens.s16),
                        // 소개 (박스 없이 본문 14)
                        Text(
                          bio,
                          style: const TextStyle(
                              fontSize: OomuTokens.fs14,
                              color: OomuTokens.textBody,
                              height: 1.5),
                        ),
                        const SizedBox(height: OomuTokens.s16),

                        // 명확한 '내 프로필 보기' & '프로필 수정' 액션 바: 같은 폭의 Secondary 버튼 2개
                        Row(
                          children: [
                            Expanded(
                              child: Tooltip(
                                message: '내 프로필 보기',
                                child: SizedBox(
                                  height: 48,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => UserProfileScreen(
                                            userName: nickname,
                                            userAge: age > 0 ? '' : '',
                                            userLocation: location,
                                            userBio: bio,
                                            userAvatar:
                                                globalData.userAvatar.value,
                                            userManner:
                                                OomuUiHelpers.parseMannerValue(
                                                    globalData.temperature.value),
                                            userTags: hobbies.isNotEmpty
                                                ? hobbies
                                                : personalities,
                                            userJob: job,
                                            userMbti: mbti,
                                            userDrinking: drinking,
                                            userPhotos: userPhotos,
                                            userGender: gender,
                                            isSelf: true,
                                          ),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: OomuTokens.border),
                                      backgroundColor: OomuTokens.surface,
                                      foregroundColor: OomuTokens.textPrimary,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(OomuTokens.r12)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                    ),
                                    child: const Text(
                                      '내 프로필 보기',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: OomuTokens.fs14,
                                          fontWeight: OomuTokens.w600,
                                          color: OomuTokens.textPrimary),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: OomuTokens.s8),
                            Expanded(
                              child: Tooltip(
                                message: '내 프로필 수정',
                                child: SizedBox(
                                  height: 48,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const ProfileEditScreen()));
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: OomuTokens.border),
                                      backgroundColor: OomuTokens.surface,
                                      foregroundColor: OomuTokens.textPrimary,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(OomuTokens.r12)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                    ),
                                    child: const Text(
                                      '프로필 수정',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: OomuTokens.fs14,
                                          fontWeight: OomuTokens.w600,
                                          color: OomuTokens.textPrimary),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: OomuTokens.s16),

                        // OOMU Plus 멤버십 보조 영역 (흰 카드의 한 줄 항목)
                        InkWell(
                          onTap: () => _showOomuPlusModal(context),
                          borderRadius: BorderRadius.circular(OomuTokens.r12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: OomuTokens.background,
                              borderRadius: BorderRadius.circular(OomuTokens.r12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.workspace_premium_outlined,
                                    color: OomuTokens.textSecondary, size: 20),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'OOMU Plus',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: OomuTokens.textPrimary,
                                      fontWeight: OomuTokens.w700,
                                      fontSize: OomuTokens.fs12,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '시크릿 프로필 · 무제한 탐색',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: OomuTokens.textSecondary,
                                        fontSize: OomuTokens.fs12),
                                  ),
                                ),
                                Icon(Icons.chevron_right,
                                    size: 16, color: OomuTokens.textMuted),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: OomuTokens.s20),
                        const Divider(height: 1, color: OomuTokens.border),
                        const SizedBox(height: OomuTokens.s16),

                        // 매너온도 (숫자와 얇은 막대, 코랄 대신 진한 중립색)
                        ValueListenableBuilder<double>(
                          valueListenable: globalData.temperature,
                          builder: (context, temp, _) {
                            final manner = OomuUiHelpers.parseMannerValue(temp);
                            final hasManner = manner != null;
                            final progress = hasManner
                                ? ((manner - 30.0) / 70.0).clamp(0.0, 1.0)
                                : 0.0;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Flexible(
                                      child: Text(
                                        '나의 매너온도',
                                        style: TextStyle(
                                            fontWeight: OomuTokens.w600,
                                            color: OomuTokens.textSecondary,
                                            fontSize: OomuTokens.fs14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      OomuUiHelpers.formatMannerTemp(manner),
                                      style: const TextStyle(
                                          fontWeight: OomuTokens.w700,
                                          fontSize: OomuTokens.fs16,
                                          color: OomuTokens.textPrimary),
                                    ),
                                  ],
                                ),
                                if (hasManner) ...[
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 4,
                                      backgroundColor: OomuTokens.background,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              OomuTokens.textPrimary),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: OomuTokens.s24),

                  // 성향 및 라이프스타일
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(OomuTokens.s20),
                    decoration: BoxDecoration(
                      color: OomuTokens.surface,
                      borderRadius: BorderRadius.circular(OomuTokens.r16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                '성향 및 라이프스타일',
                                style: TextStyle(
                                    fontSize: OomuTokens.fs16,
                                    fontWeight: OomuTokens.w700,
                                    color: OomuTokens.textPrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Tooltip(
                              message: '성향 및 라이프스타일 수정',
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(OomuTokens.r8),
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const ProfileEditScreen())),
                                child: const SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: Center(
                                    child: Icon(Icons.edit_outlined,
                                        size: 18,
                                        color: OomuTokens.textSecondary),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: OomuTokens.s16),
                        _buildLifestyleRow('성격', personalities),
                        if (drinking.isNotEmpty) ...[
                          const SizedBox(height: OomuTokens.s12),
                          _buildLifestyleRow('음주', drinking),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: OomuTokens.s24),

                  if (hobbies.isNotEmpty) ...[
                    const Text('나의 관심사 / 취향',
                        style: TextStyle(
                            fontSize: OomuTokens.fs16,
                            fontWeight: OomuTokens.w700,
                            color: OomuTokens.textPrimary)),
                    const SizedBox(height: OomuTokens.s12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: hobbies
                          .map((hobby) => OomuTag(label: hobby))
                          .toList(),
                    ),
                    const SizedBox(height: OomuTokens.s24),
                  ],

                  if (closeFriendPersonalities.isNotEmpty) ...[
                    const Text('찐친이랑 있을 때 내 성격 🤪',
                        style: TextStyle(
                            fontSize: OomuTokens.fs16,
                            fontWeight: OomuTokens.w700,
                            color: OomuTokens.textPrimary)),
                    const SizedBox(height: OomuTokens.s12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: closeFriendPersonalities
                          .map((p) => OomuTag(label: p.toString()))
                          .toList(),
                    ),
                    const SizedBox(height: OomuTokens.s24),
                  ],

                  if (values.isNotEmpty) ...[
                    const Text('내가 중요하게 생각하는 가치관 💎',
                        style: TextStyle(
                            fontSize: OomuTokens.fs16,
                            fontWeight: OomuTokens.w700,
                            color: OomuTokens.textPrimary)),
                    const SizedBox(height: OomuTokens.s12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: values
                          .map((v) => OomuTag(label: v.toString()))
                          .toList(),
                    ),
                    const SizedBox(height: OomuTokens.s24),
                  ],

                  Text('설정 및 관리',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textPrimary)),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: globalData.savedMeetups,
                    builder: (context, saved, _) {
                      return _buildInteractiveMenuItem(
                        icon: Icons.favorite,
                        iconColor: coralAccent,
                        title: '내가 찜한 모임',
                        badge: '${saved.length}개',
                        textPrimary: textPrimary,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SavedMeetupsScreen()));
                        },
                      );
                    },
                  ),
                  _buildInteractiveMenuItem(
                    icon: Icons.history,
                    iconColor: textSecondary,
                    title: '참여/개설 내역',
                    textPrimary: textPrimary,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const OOMUMyTripsScreen()));
                    },
                  ),
                  _buildInteractiveMenuItem(
                    icon: Icons.notifications_outlined,
                    iconColor: textSecondary,
                    title: '알림 설정',
                    textPrimary: textPrimary,
                    onTap: _showNotificationSettingsBottomSheet,
                  ),
                  _buildInteractiveMenuItem(
                    icon: Icons.support_agent,
                    iconColor: textSecondary,
                    title: '고객 센터 & FAQ',
                    textPrimary: textPrimary,
                    onTap: _showCustomerCenterModal,
                  ),

                  _buildInteractiveMenuItem(
                    icon: Icons.block,
                    iconColor: textSecondary,
                    title: '차단 사용자 관리',
                    badge: '${globalData.blockedUsers.value.length}명',
                    textPrimary: textPrimary,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const BlockManageScreen())),
                  ),
                  _buildInteractiveMenuItem(
                    icon: Icons.shield_outlined,
                    iconColor: textSecondary,
                    title: '신고 내역 및 커뮤니티 가이드',
                    textPrimary: textPrimary,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ReportHistoryScreen())),
                  ),
                  _buildInteractiveMenuItem(
                    icon: Icons.settings_outlined,
                    iconColor: textSecondary,
                    title: '환경설정',
                    textPrimary: textPrimary,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen())),
                  ),
                  _buildInteractiveMenuItem(
                    icon: Icons.logout_rounded,
                    iconColor: const Color(0xFFE53935),
                    title: '로그아웃',
                    textPrimary: const Color(0xFFE53935),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          title: const Text('로그아웃',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          content:
                              const Text('현재 계정에서 로그아웃하고 첫 화면으로 돌아가시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('취소',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: coralAccent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('로그아웃',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await authService.signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      }
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: widget.isEmbedded ? null : _buildBottomNav(context),
    );
  }

  Widget _buildLifestyleRow(String label, List<String> tags) {
    if (tags.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 52,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: OomuTokens.fs12,
                fontWeight: OomuTokens.w600,
                color: OomuTokens.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags.map((t) => OomuTag(label: t)).toList(),
          ),
        ),
      ],
    );
  }

  void _showOomuPlusModal(BuildContext context) {
    OomuSheet.show(
      context: context,
      builder: (ctx) => OomuSheet(
        title: 'OOMU Plus 멤버십',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(OomuTokens.s16),
              decoration: BoxDecoration(
                color: OomuTokens.surfaceMuted,
                borderRadius: BorderRadius.circular(OomuTokens.r12),
                border: Border.all(color: OomuTokens.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.workspace_premium_outlined,
                      color: OomuTokens.textPrimary, size: 28),
                  SizedBox(width: OomuTokens.s12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OOMU Plus',
                        style: TextStyle(
                          color: OomuTokens.textPrimary,
                          fontWeight: OomuTokens.w700,
                          fontSize: OomuTokens.fs16,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '나만의 특별한 동네 라이프스타일',
                        style: TextStyle(
                          color: OomuTokens.textSecondary,
                          fontSize: OomuTokens.fs12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: OomuTokens.s16),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.visibility_outlined,
                  color: OomuTokens.textSecondary),
              title: Text(
                '시크릿 프로필 무제한 열람',
                style: TextStyle(
                    fontWeight: OomuTokens.w600,
                    fontSize: OomuTokens.fs14,
                    color: OomuTokens.textPrimary),
              ),
              subtitle: Text(
                '내 프로필을 열람한 사람을 실시간 확인',
                style: TextStyle(
                    fontSize: OomuTokens.fs12, color: OomuTokens.textSecondary),
              ),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.favorite_outline,
                  color: OomuTokens.textSecondary),
              title: Text(
                '매일 슈퍼라이크 5개 증정',
                style: TextStyle(
                    fontWeight: OomuTokens.w600,
                    fontSize: OomuTokens.fs14,
                    color: OomuTokens.textPrimary),
              ),
              subtitle: Text(
                '더 빠르고 확실한 호감 매칭',
                style: TextStyle(
                    fontSize: OomuTokens.fs12, color: OomuTokens.textSecondary),
              ),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  Icon(Icons.bolt_outlined, color: OomuTokens.textSecondary),
              title: Text(
                '실시간 번개 우선 노출',
                style: TextStyle(
                    fontWeight: OomuTokens.w600,
                    fontSize: OomuTokens.fs14,
                    color: OomuTokens.textPrimary),
              ),
              subtitle: Text(
                '내가 주최한 번개 모임이 동네 상단에 고정',
                style: TextStyle(
                    fontSize: OomuTokens.fs12, color: OomuTokens.textSecondary),
              ),
            ),
            const SizedBox(height: OomuTokens.s20),
            OomuButton(
              label: '7일 무료 체험 시작하기',
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('🎉 OOMU Plus 7일 무료 체험이 활성화되었습니다!')),
                );
              },
            ),
            const SizedBox(height: OomuTokens.s12),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveMenuItem({
    required IconData icon,
    Color? iconColor,
    required String title,
    String? badge,
    required Color textPrimary,
    required VoidCallback onTap,
  }) {
    final showBadge = badge != null &&
        badge != '0' &&
        badge != '0개' &&
        badge != '0명' &&
        !badge.startsWith('0');

    return BouncyTap(
      scaleDown: 0.98,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? textPrimary).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(OomuTokens.r8),
              ),
              child: Icon(icon, color: iconColor ?? textPrimary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: OomuTokens.fs14,
                  fontWeight: OomuTokens.w600,
                  color: OomuTokens.textPrimary,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (showBadge)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: OomuTokens.background,
                  borderRadius: BorderRadius.circular(OomuTokens.r8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: OomuTokens.fs12,
                    fontWeight: OomuTokens.w600,
                    color: OomuTokens.textSecondary,
                  ),
                ),
              ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: OomuTokens.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 4,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: OomuTokens.coral,
      unselectedItemColor: OomuTokens.textSecondary,
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
              context, MaterialPageRoute(builder: (_) => const ChatScreen()));
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
          icon: Icon(Icons.favorite_border, size: 24),
          activeIcon: Icon(Icons.favorite, size: 24),
          label: '소개팅',
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
            backgroundColor: isSelected ? coralAccent : const Color(0xFF111111),
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
            color: isSelected ? Colors.white : const Color(0xFF333333),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
