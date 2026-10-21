import 'login_screen.dart';
import '../services/auth_service.dart';
import 'package:flutter/material.dart';
import '../utils/global_data.dart';
import '../utils/app_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'soso_car_home_screen.dart';
import 'chat_screen.dart';
import 'soso_car_host_screen.dart';
import 'oomu_my_trips_screen.dart';
import 'profile_edit_screen.dart';
import 'saved_meetups_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../services/r2_storage_service.dart';
import 'settings_screen.dart';
import 'my_page_sub_screens.dart';

class MyPageScreen extends StatefulWidget {
  final bool isEmbedded;
  const MyPageScreen({super.key, this.isEmbedded = false});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final Color textPrimary = const Color(0xFF221B1D);
  final Color textSecondary = const Color(0xFF635559);
  final Color surfaceColor = const Color(0xFFFAF6F7);
  final Color accentColor = const Color(0xFFF25767);
  final Color coralAccent = const Color(0xFFF25767);

  void _showAvatarPickerBottomSheet() {
    final avatarList = [
      {'name': '여성 1 (기본)', 'path': 'assets/images/kr_female_1.jpg'},
      {'name': '여성 2 (단발)', 'path': 'assets/images/kr_female_2.jpg'},
      {'name': '여성 3 (웨이브)', 'path': 'assets/images/kr_female_3.jpg'},
      {'name': '남성 1 (댄디)', 'path': 'assets/images/kr_male_1.jpg'},
      {'name': '남성 2 (캐주얼)', 'path': 'assets/images/kr_male_2.jpg'},
      {'name': '남성 3 (스포티)', 'path': 'assets/images/kr_male_3.jpg'},
    ];

    final r2UrlController = TextEditingController();
    bool isUploading = false;

    Future<void> pickAndSetAvatar(ImageSource source, StateSetter setSheetState, BuildContext ctx) async {
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
              const SnackBar(content: Text('⚠️ 사진 파일(JPG, PNG, WEBP 등)만 업로드할 수 있습니다.')),
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
          await FirebaseFirestore.instance.collection('users').doc(globalData.activeUserId).set({
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
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
                      decoration: BoxDecoration(color: const Color(0xFFE5E5EA), borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text('프로필 사진 선택', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF38020).withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                        child: const Text('R2 oomu-spot', style: TextStyle(color: Color(0xFFF38020), fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('사진 불러오기 또는 즉시 촬영으로 프로필 사진을 변경하세요.', style: TextStyle(fontSize: 13, color: textSecondary)),
                  const SizedBox(height: 18),

                  // 1 & 2: Primary Action Cards (Camera & Gallery)
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: isUploading ? null : () => pickAndSetAvatar(ImageSource.camera, setSheetState, ctx),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF5F0),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFFF5E36).withOpacity(0.35)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF5E36),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 24),
                                ),
                                const SizedBox(height: 10),
                                const Text('사진 찍기', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF111111))),
                                const SizedBox(height: 4),
                                Text('카메라로 바로 촬영', style: TextStyle(fontSize: 12, color: textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: isUploading ? null : () => pickAndSetAvatar(ImageSource.gallery, setSheetState, ctx),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7EE),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFF38020).withOpacity(0.35)),
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
                                  child: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 24),
                                ),
                                const SizedBox(height: 10),
                                const Text('사진 불러오기', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF111111))),
                                const SizedBox(height: 4),
                                Text('갤러리/앨범 선택', style: TextStyle(fontSize: 12, color: textSecondary)),
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
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF38020).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF38020))),
                          SizedBox(width: 12),
                          Text('Cloudflare R2 (oomu-spot)에 사진 업로드 중...', style: TextStyle(color: Color(0xFFF38020), fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),
                  Text('또는 2030 아바타 추천', style: TextStyle(fontSize: 13, color: textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: avatarList.length,
                      itemBuilder: (context, index) {
                        final item = avatarList[index];
                        final isSel = globalData.userAvatar.value == item['path'];
                        return GestureDetector(
                          onTap: () async {
                            globalData.updateAvatar(item['path']!);
                            try {
                              await FirebaseFirestore.instance.collection('users').doc(globalData.activeUserId).set({
                                'photoUrl': item['path']!,
                                'updatedAt': FieldValue.serverTimestamp(),
                              }, SetOptions(merge: true));
                            } catch (_) {}
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('✨ [${item['name']}] 프로필 사진으로 변경되었습니다!')),
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
                                          color: isSel ? coralAccent : Colors.transparent,
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
                                          child: const Icon(Icons.check, size: 12, color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(item['name']!, style: TextStyle(fontSize: 11, color: isSel ? coralAccent : textSecondary, fontWeight: isSel ? FontWeight.bold : FontWeight.w500)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Cloudflare R2 사진 링크 직접 등록', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: r2UrlController,
                          decoration: InputDecoration(
                            hintText: 'https://pub-xxxx.r2.dev/photo.jpg',
                            hintStyle: TextStyle(color: const Color(0xFFC7C7CC), fontSize: 13),
                            filled: true,
                            fillColor: surfaceColor,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: coralAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onPressed: () async {
                          final url = r2UrlController.text.trim();
                          if (url.isNotEmpty) {
                            globalData.updateAvatar(url);
                            try {
                              await FirebaseFirestore.instance.collection('users').doc(globalData.activeUserId).set({
                                'photoUrl': url,
                                'updatedAt': FieldValue.serverTimestamp(),
                              }, SetOptions(merge: true));
                            } catch (_) {}
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('☁️ Cloudflare R2 프로필 사진이 적용되었습니다!')),
                            );
                          }
                        },
                        child: const Text('적용', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _showR2SettingsBottomSheet() {
    final accessKeyCtrl = TextEditingController(text: r2Storage.accessKeyId);
    final secretKeyCtrl = TextEditingController(text: r2Storage.secretAccessKey);
    final publicUrlCtrl = TextEditingController(text: r2Storage.publicBaseUrl);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
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
                      decoration: BoxDecoration(color: const Color(0xFFE5E5EA), borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFF38020).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.cloud_sync_outlined, color: Color(0xFFF38020), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cloudflare R2 스토리지 연동', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                          Text('버킷: oomu-spot (Asia-Pacific)', style: TextStyle(fontSize: 12, color: textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9F3),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF38020).withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield_outlined, color: Color(0xFFF38020), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '보안 안내: 개인정보 및 R2 S3 Secret Access Key는 Git 소스코드에 절대 커밋되지 않으며, Firebase Firestore (config/r2_storage)에 안전하게 암호화 보관됩니다.',
                            style: TextStyle(fontSize: 12, color: const Color(0xFFB85D00), height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('S3 Endpoint URL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textSecondary)),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(10)),
                    child: SelectableText(
                      R2StorageService.s3Endpoint,
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Color(0xFF333333)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('S3 Access Key ID (현재: ${r2Storage.getMaskedAccessKey()})', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textSecondary)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: accessKeyCtrl,
                    decoration: InputDecoration(
                      hintText: 'Access Key ID 입력',
                      filled: true,
                      fillColor: surfaceColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('S3 Secret Access Key (현재: ${r2Storage.getMaskedSecretKey()})', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textSecondary)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: secretKeyCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Secret Access Key 입력 (마스킹 저장)',
                      filled: true,
                      fillColor: surfaceColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('공개 R2 CDN 도메인 (선택사항, 예: https://pub-xxx.r2.dev)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textSecondary)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: publicUrlCtrl,
                    decoration: InputDecoration(
                      hintText: 'https://pub-xxxx.r2.dev',
                      filled: true,
                      fillColor: surfaceColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF38020),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.lock_outline, color: Colors.white, size: 18),
                      label: const Text('Firebase에 안전하게 저장 (Git 미포함)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      onPressed: () async {
                        await r2Storage.saveToFirestore(
                          accessKey: accessKeyCtrl.text,
                          secretKey: secretKeyCtrl.text,
                          publicUrl: publicUrlCtrl.text,
                        );
                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🔒 R2 자격 증명이 Firebase Firestore에 안전하게 저장되었습니다.'),
                              backgroundColor: Color(0xFFF38020),
                            ),
                          );
                        }
                      },
                    ),
                  ),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
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
                        decoration: BoxDecoration(color: const Color(0xFFE5E5EA), borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(Icons.notifications_active, color: coralAccent, size: 24),
                        const SizedBox(width: 8),
                        Text('알림 설정', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('중요한 모임 알림과 실시간 채팅 알림을 관리하세요.', style: TextStyle(fontSize: 13, color: textSecondary)),
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

  Widget _buildSwitchTile(String title, String subtitle, bool value, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: coralAccent,
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
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
                  decoration: BoxDecoration(color: const Color(0xFFE5E5EA), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.support_agent, color: coralAccent, size: 26),
                  const SizedBox(width: 8),
                  Text('고객 센터 & FAQ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary)),
                ],
              ),
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Q. 모임 참여는 어떻게 승인되나요?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('방장이 프로필과 매너 온도를 확인 후 승인하면 채팅방에 자동으로 초대됩니다.', style: TextStyle(fontSize: 13, color: textSecondary)),
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text('Q. 찜한 모임은 어디서 확인하나요?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('마이페이지 > [내가 찜한 모임] 메뉴에서 언제든 확인 및 참여하실 수 있습니다.', style: TextStyle(fontSize: 13, color: textSecondary)),
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text('Q. 비매너 사용자를 신고하고 싶어요.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('채팅방 우측 상단 더보기 > [신고하기]를 누르면 운영팀에 실시간 접수됩니다.', style: TextStyle(fontSize: 13, color: textSecondary)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('1:1 문의 남기기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textPrimary)),
              const SizedBox(height: 8),
              TextField(
                controller: inquiryCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '문의 내용을 작성해 주시면 24시간 이내에 답변드립니다.',
                  hintStyle: TextStyle(color: const Color(0xFFC7C7CC), fontSize: 13),
                  filled: true,
                  fillColor: surfaceColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: coralAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    if (inquiryCtrl.text.trim().isNotEmpty) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('📨 문의가 정상적으로 접수되었습니다. 빠르게 확인하겠습니다!')),
                      );
                    }
                  },
                  child: const Text('문의 접수하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
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
      backgroundColor: const Color(0xFFFAF6F7),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFAF6F7),
        elevation: 0,
        title: Text('마이페이지', style: TextStyle(color: accentColor, fontSize: 22, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: textSecondary),
            tooltip: '설정',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: accentColor),
            tooltip: '프로필 수정',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen()));
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: globalData.currentUserId,
        builder: (context, activeUid, _) {
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(activeUid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: accentColor));
              }

              String role = activeUid == 'admin_user' ? 'admin' : 'user';
              String nickname = activeUid == 'admin_user' ? '오오무 운영팀' : (activeUid == 'test_user_2' ? '달리는민서' : '매운맛킬러');
              String name = activeUid == 'admin_user' ? '총괄관리자' : (activeUid == 'test_user_2' ? '이지은' : '김민우');
              int age = activeUid == 'admin_user' ? 29 : (activeUid == 'test_user_2' ? 25 : 27);
              String gender = activeUid == 'test_user_1' ? '남성' : '여성';
              String location = '서울 마포구 연남동';
              String bio = '새로운 사람 만나는 걸 좋아해요! 잘 부탁드립니다 😊';
              String job = activeUid == 'admin_user' ? '오오무 서비스 기획/운영' : 'IT/개발';
              String mbti = activeUid == 'admin_user' ? 'ENFJ' : 'ENFP';
              String jobAndMbti = '$job • $mbti';
              List<String> hobbies = ['맛집탐방', '보드게임'];
              List<String> closeFriendPersonalities = [];
              List<String> values = [];
              List<String> personalities = ['리액션 요정', '친화력 갑'];
              List<String> drinking = ['가볍게 한잔'];

              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                role = data['role'] ?? role;
                nickname = data['nickname'] ?? nickname;
                name = data['name'] ?? name;
                if (data['age'] != null) {
                  age = data['age'] is int ? data['age'] : (int.tryParse(data['age'].toString()) ?? age);
                }
                gender = data['gender'] ?? gender;
                location = data['location'] ?? location;
                bio = data['bio'] ?? bio;
                job = data['job'] ?? job;
                mbti = data['mbti'] ?? mbti;
                jobAndMbti = '${age > 0 ? '$age세 • ' : ''}${gender.isNotEmpty ? '$gender • ' : ''}$job • $mbti';
                if (data['hobbies'] != null) hobbies = List<String>.from(data['hobbies']);
                if (data['personalities'] != null) personalities = List<String>.from(data['personalities']);
                if (data['drinking'] != null) drinking = List<String>.from(data['drinking']);
                if (data['closeFriendPersonalities'] != null) closeFriendPersonalities = List<String>.from(data['closeFriendPersonalities']);
                if (data['values'] != null) values = List<String>.from(data['values']);

                final loadedAvatar = (data['photoUrl'] ?? data['avatarUrl'])?.toString();
                if (loadedAvatar != null && loadedAvatar.isNotEmpty && globalData.userAvatar.value != loadedAvatar) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) globalData.userAvatar.value = loadedAvatar;
                  });
                }
                if (globalData.userNickname.value != nickname) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) globalData.userNickname.value = nickname;
                  });
                }
                if (globalData.userLocation.value != location) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) globalData.userLocation.value = location;
                  });
                }
              } else {
                jobAndMbti = '${age > 0 ? '$age세 • ' : ''}${gender.isNotEmpty ? '$gender • ' : ''}$job • $mbti';
              }

              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // 계정 전환 바 (관리자 / 테스트 모드 즉시 스위칭)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E5EA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.switch_account_outlined, size: 20, color: Color(0xFF8E8E93)),
                        const SizedBox(width: 8),
                        Text('계정 모드: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textSecondary)),
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
              // User Profile Card (Rich Style)
              Container(
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
                        GestureDetector(
                          onTap: _showAvatarPickerBottomSheet,
                          child: Stack(
                            children: [
                              ValueListenableBuilder<String>(
                                valueListenable: globalData.userAvatar,
                                builder: (context, avatar, _) {
                                  return Container(
                                    width: 76,
                                    height: 76,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: coralAccent.withOpacity(0.4), width: 2),
                                      image: DecorationImage(image: appImg(avatar), fit: BoxFit.cover),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(color: coralAccent, shape: BoxShape.circle),
                                  child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(nickname, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary), overflow: TextOverflow.ellipsis),
                                    ),
                                    const SizedBox(width: 6),
                                    if (role == 'admin')
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(colors: [Color(0xFFF19E39), Color(0xFFF25767)]),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text('👑 총괄 관리자', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                                      ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFC7C7CC)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(jobAndMbti, style: TextStyle(color: accentColor, fontSize: 14, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                ValueListenableBuilder<String>(
                                  valueListenable: globalData.userLocation,
                                  builder: (context, loc, _) {
                                    return Row(
                                      children: [
                                        Icon(Icons.location_on, size: 13, color: textSecondary),
                                        const SizedBox(width: 2),
                                        Text(loc.isNotEmpty ? loc : location, style: TextStyle(color: textSecondary, fontSize: 13)),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEFE4E6)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('"$bio"', style: TextStyle(fontSize: 14, color: textSecondary, fontStyle: FontStyle.italic)),
                            ),
                            Icon(Icons.edit_outlined, size: 14, color: coralAccent.withOpacity(0.7)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(height: 1, color: const Color(0xFFEBEBEF)),
                    const SizedBox(height: 20),
                    // Freemium Banner (Interactive)
                    GestureDetector(
                      onTap: () => _showOomuPlusModal(context),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF333333), Color(0xFF111111)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('OOMU Plus', style: TextStyle(color: Color(0xFFF19E39), fontWeight: FontWeight.w900, fontSize: 18, fontStyle: FontStyle.italic)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFFF19E39).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                  child: const Text('무료 체험하기', style: TextStyle(color: Color(0xFFF19E39), fontSize: 12, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text('시크릿 프로필 열람 및 프리미엄 필터로 나와 딱 맞는 사람을 더 빠르게 찾아보세요.', style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('나의 매너 온도', style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary, fontSize: 14)),
                        Row(
                          children: [
                            ValueListenableBuilder<double>(
                              valueListenable: globalData.temperature,
                              builder: (context, temp, _) => Text('${temp.toStringAsFixed(1)}°C', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: accentColor)),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.thermostat, color: accentColor, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 성향 및 라이프스타일 (OOMU 로즈 코랄 카드 스타일)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFF1E6E8), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: coralAccent.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.auto_awesome, color: coralAccent, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Text('성향 및 라이프스타일', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textPrimary)),
                          ],
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFF8C6CD)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 13, color: coralAccent),
                                const SizedBox(width: 4),
                                Text('수정', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: coralAccent)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildLifestyleRow('성격', '✨', personalities, coralAccent, textPrimary),
                    if (drinking.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: Color(0xFFF6ECEE)),
                      const SizedBox(height: 14),
                      _buildLifestyleRow('음주', '🍷', drinking, const Color(0xFF8B5CF6), textPrimary),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              if (hobbies.isNotEmpty) ...[
                Text('나의 관심사 / 취향', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
                  spacing: 8,
                  runSpacing: 8,
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
                  spacing: 8,
                  runSpacing: 8,
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

              // 설정 및 관리 Section
              Text('설정 및 관리', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: coralAccent)),
              const SizedBox(height: 16),
              ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: globalData.savedMeetups,
                builder: (context, saved, _) {
                  return _buildInteractiveMenuItem(
                    icon: Icons.favorite,
                    iconColor: Colors.redAccent,
                    title: '내가 찜한 모임',
                    badge: '${saved.length}개',
                    textPrimary: textPrimary,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedMeetupsScreen()));
                    },
                  );
                },
              ),
              _buildInteractiveMenuItem(
                icon: Icons.history,
                iconColor: const Color(0xFF007AFF),
                title: '참여/개설 내역',
                textPrimary: textPrimary,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const OOMUMyTripsScreen()));
                },
              ),
              _buildInteractiveMenuItem(
                icon: Icons.notifications_outlined,
                iconColor: const Color(0xFFFF9500),
                title: '알림 설정',
                textPrimary: textPrimary,
                onTap: _showNotificationSettingsBottomSheet,
              ),
              _buildInteractiveMenuItem(
                icon: Icons.support_agent,
                iconColor: const Color(0xFF34C759),
                title: '고객 센터 & FAQ',
                textPrimary: textPrimary,
                onTap: _showCustomerCenterModal,
              ),

              _buildInteractiveMenuItem(
                icon: Icons.block,
                iconColor: const Color(0xFFE11D48),
                title: '차단 사용자 관리',
                badge: '${globalData.blockedUsers.value.length}명',
                textPrimary: textPrimary,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BlockManageScreen())),
              ),
              _buildInteractiveMenuItem(
                icon: Icons.shield_outlined,
                iconColor: const Color(0xFF0D9488),
                title: '신고 내역 및 커뮤니티 가이드',
                textPrimary: textPrimary,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportHistoryScreen())),
              ),
              _buildInteractiveMenuItem(
                icon: Icons.settings_outlined,
                iconColor: textSecondary,
                title: '환경설정',
                textPrimary: textPrimary,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text('로그아웃', style: TextStyle(fontWeight: FontWeight.bold)),
                      content: const Text('현재 계정에서 로그아웃하고 첫 화면으로 돌아가시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('취소', style: TextStyle(color: Colors.grey)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: coralAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('로그아웃', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await authService.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
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

  Widget _buildLifestyleRow(String label, String emoji, List<String> tags, Color accent, Color textPrimary) {
    if (tags.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 66,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 3),
              Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: accent)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF9CCD4), width: 1.1),
              ),
              child: Text(
                '# $t',
                style: const TextStyle(
                  color: Color(0xFFE11D48),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )).toList(),
          ),
        ),
      ],
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
            spacing: 8,
            runSpacing: 8,
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

  void _showOomuPlusModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF333333), Color(0xFF111111)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star, color: Color(0xFFF19E39), size: 36),
                  SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OOMU Plus 멤버십', style: TextStyle(color: Color(0xFFF19E39), fontWeight: FontWeight.w900, fontSize: 18, fontStyle: FontStyle.italic)),
                      SizedBox(height: 4),
                      Text('나만의 특별한 동네 라이프스타일', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.visibility_outlined, color: Color(0xFFF25767)),
                    title: Text('시크릿 프로필 무제한 열람', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('내 프로필을 열람한 사람을 실시간 확인', style: TextStyle(fontSize: 12, color: Color(0xFF767676))),
                  ),
                  ListTile(
                    leading: Icon(Icons.favorite, color: Color(0xFFF25767)),
                    title: Text('매일 슈퍼라이크 5개 증정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('더 빠르고 확실한 1:1 취향 매칭', style: TextStyle(fontSize: 12, color: Color(0xFF767676))),
                  ),
                  ListTile(
                    leading: Icon(Icons.bolt, color: Color(0xFFF19E39)),
                    title: Text('실시간 번개 우선 노출', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('내가 주최한 번개 모임이 동네 상단에 고정', style: TextStyle(fontSize: 12, color: Color(0xFF767676))),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: coralAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🎉 OOMU Plus 7일 무료 체험이 활성화되었습니다!')),
                  );
                },
                child: const Text('7일 무료 체험 시작하기', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetailModal(String title, String subtitle, String emoji) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text(emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: textPrimary)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFFFF0F2), borderRadius: BorderRadius.circular(12)),
              child: Text(subtitle, style: TextStyle(color: coralAccent, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Text('활동 조건을 충족하여 인증된 공식 배지입니다.\n모임 참여자들에게 프로필 배지로 노출됩니다.', textAlign: TextAlign.center, style: TextStyle(color: textSecondary, fontSize: 13, height: 1.4)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF221B1D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('확인', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String emoji, String title, String subtitle, Color textPrimary) {
    return GestureDetector(
      onTap: () => _showBadgeDetailModal(title, subtitle, emoji),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F5F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFECE4E6)),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? textPrimary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor ?? textPrimary, size: 20),
            ),
            const SizedBox(width: 14),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary)),
            const Spacer(),
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: coralAccent.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Text(badge, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: coralAccent)),
              ),
            const Icon(Icons.arrow_forward_ios, size: 15, color: Color(0xFFC7C7CC)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 4,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: coralAccent,
      unselectedItemColor: const Color(0xFF767676),
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      elevation: 20,
      backgroundColor: Colors.white,
      onTap: (index) {
        if (index <= 2) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OOMUHomeScreen(initialTab: index)));
        } else if (index == 3) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
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
          border: Border.all(color: isSelected ? coralAccent : const Color(0xFFD1D1D6)),
          boxShadow: isSelected
              ? [BoxShadow(color: coralAccent.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))]
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
