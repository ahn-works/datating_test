import 'package:flutter/material.dart';
import '../utils/global_data.dart';
import '../utils/app_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'soso_car_home_screen.dart';
import 'soso_car_host_screen.dart';
import 'oomu_my_trips_screen.dart';
import 'profile_edit_screen.dart';
import 'saved_meetups_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final Color textPrimary = const Color(0xFF111111);
  final Color textSecondary = const Color(0xFF767676);
  final Color surfaceColor = const Color(0xFFF5F5F7);
  final Color accentColor = const Color(0xFFF19E39);
  final Color coralAccent = const Color(0xFFFF5E36);

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
              Text('프로필 사진 선택', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary)),
              const SizedBox(height: 6),
              Text('2030 한국인 아바타 또는 Cloudflare R2 링크를 선택하세요.', style: TextStyle(fontSize: 13, color: textSecondary)),
              const SizedBox(height: 20),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: avatarList.length,
                  itemBuilder: (context, index) {
                    final item = avatarList[index];
                    final isSel = globalData.userAvatar.value == item['path'];
                    return GestureDetector(
                      onTap: () {
                        globalData.updateAvatar(item['path']!);
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
                    onPressed: () {
                      final url = r2UrlController.text.trim();
                      if (url.isNotEmpty) {
                        globalData.updateAvatar(url);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('마이페이지', style: TextStyle(color: accentColor, fontSize: 24, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: accentColor),
            tooltip: '프로필 수정',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen()));
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc('test_user_1').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: accentColor));
          }

          String nickname = '매운맛킬러';
          String location = '마포구 서교동';
          String bio = '새로운 사람 만나는 걸 좋아해요! 잘 부탁드립니다 😊';
          String jobAndMbti = 'IT/개발 • ENFP';
          List<String> hobbies = ['맛집탐방', '코노'];
          List<String> closeFriendPersonalities = [];
          List<String> values = [];
          List<String> personalities = ['리액션 요정', '친화력 갑'];
          List<String> drinking = ['가볍게 한잔'];

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            nickname = data['nickname'] ?? nickname;
            location = data['location'] ?? location;
            bio = data['bio'] ?? bio;
            final job = data['job'] ?? 'IT/개발';
            final mbti = data['mbti'] ?? 'ENFP';
            jobAndMbti = '$job • $mbti';
            if (data['hobbies'] != null) hobbies = List<String>.from(data['hobbies']);
            if (data['personalities'] != null) personalities = List<String>.from(data['personalities']);
            if (data['drinking'] != null) drinking = List<String>.from(data['drinking']);
            if (data['closeFriendPersonalities'] != null) closeFriendPersonalities = List<String>.from(data['closeFriendPersonalities']);
            if (data['values'] != null) values = List<String>.from(data['values']);
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(nickname, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary)),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFC7C7CC)),
                                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
                                  ),
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
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16)),
                      child: Text('"$bio"', style: TextStyle(fontSize: 14, color: textSecondary, fontStyle: FontStyle.italic)),
                    ),
                    const SizedBox(height: 24),
                    Container(height: 1, color: const Color(0xFFEBEBEF)),
                    const SizedBox(height: 20),
                    // Freemium Banner
                    Container(
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

              // Lifestyle Tags
              Text('성향 및 라이프스타일', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
              const SizedBox(height: 16),
              _buildInfoRow('성격', personalities, surfaceColor, textPrimary),
              const SizedBox(height: 12),
              _buildInfoRow('음주', drinking, surfaceColor, textPrimary),
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

              const SizedBox(height: 40),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(context),
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

  Widget _buildBadge(String emoji, String title, String subtitle, Color textPrimary) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(20),
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
      currentIndex: 3,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF111111),
      unselectedItemColor: const Color(0xFFC7C7CC),
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      elevation: 20,
      backgroundColor: Colors.white,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_,__,___) => const OOMUHomeScreen(), transitionDuration: Duration.zero));
        } else if (index == 1) { 
          Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => const OOMUHostScreen(), transitionDuration: Duration.zero)); 
        } else if (index == 2) {
          Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_,__,___) => const OOMUMyTripsScreen(), transitionDuration: Duration.zero));
        }
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined, size: 26), activeIcon: Icon(Icons.explore, size: 26), label: '탐색'),
        const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 26), activeIcon: Icon(Icons.add_circle, size: 26), label: '만들기'),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.chat_bubble_outline, size: 24),
              Positioned(right: -6, top: -6, child: Container(padding: const EdgeInsets.all(5), decoration: const BoxDecoration(color: Color(0xFFFF3B30), shape: BoxShape.circle), child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
            ],
          ),
          activeIcon: const Icon(Icons.chat_bubble, size: 24),
          label: '내 모임',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 26), activeIcon: Icon(Icons.person, size: 26), label: 'MY'),
      ],
    );
  }
}
