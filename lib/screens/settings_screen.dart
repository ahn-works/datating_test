import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'my_page_sub_screens.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _marketingNotifications = false;
  bool _meetingAlerts = true;

  static const Color _bgLight = Color(0xFFFAF6F7);
  static const Color _coralAccent = Color(0xFFF25767);
  static const Color _coralLight = Color(0xFFFDE8EC);
  static const Color _textPrimary = Color(0xFF221B1D);
  static const Color _textSecondary = Color(0xFF635559);
  static const Color _cardBorder = Color(0xFFEFE4E6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: _textPrimary),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _cardBorder, height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // 1. 프로필 요약 카드
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _coralAccent.withOpacity(0.3), width: 2),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/kr_female_1.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '김민서',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _coralLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '36.5°C',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _coralAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        '서울 강남구 역삼동 · 본인인증 완료',
                        style: TextStyle(fontSize: 12, color: _textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. 계정 및 안전 (UGC 보호)
          _buildSectionHeader('계정 및 안전 (안심 보호)'),
          _buildCardGroup([
            _buildTile(
              icon: Icons.shield_outlined,
              iconColor: _coralAccent,
              title: '차단 사용자 관리',
              subtitle: '차단한 사용자는 내 피드와 채팅에서 즉시 숨겨집니다',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BlockManageScreen()),
              ),
            ),
            const Divider(height: 1, indent: 56, color: _cardBorder),
            _buildTile(
              icon: Icons.flag_outlined,
              iconColor: const Color(0xFFE53935),
              title: '신고 접수 및 처리 내역',
              subtitle: '24시간 내 운영팀 검토 내역 및 조치 결과 확인',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportHistoryScreen()),
              ),
            ),
          ]),

          const SizedBox(height: 20),

          // 3. 알림 설정
          _buildSectionHeader('알림 설정'),
          _buildCardGroup([
            _buildSwitchTile(
              icon: Icons.notifications_active_outlined,
              title: '실시간 알림',
              subtitle: '새로운 댓글, 채팅, 모임 참여 신청 알림',
              value: _pushNotifications,
              onChanged: (val) => setState(() => _pushNotifications = val),
            ),
            const Divider(height: 1, indent: 56, color: _cardBorder),
            _buildSwitchTile(
              icon: Icons.bolt_outlined,
              title: '동네 번개 및 모임 알림',
              subtitle: '내 관심 지역의 새로운 핫스팟 및 번개 소식',
              value: _meetingAlerts,
              onChanged: (val) => setState(() => _meetingAlerts = val),
            ),
            const Divider(height: 1, indent: 56, color: _cardBorder),
            _buildSwitchTile(
              icon: Icons.campaign_outlined,
              title: '이벤트 및 혜택 알림',
              subtitle: 'KOPIS 제휴 공연 할인 및 앱 혜택 소식 수신',
              value: _marketingNotifications,
              onChanged: (val) => setState(() => _marketingNotifications = val),
            ),
          ]),

          const SizedBox(height: 20),

          // 4. 고객 지원 및 가이드
          _buildSectionHeader('고객 지원 및 정책'),
          _buildCardGroup([
            _buildTile(
              icon: Icons.announcement_outlined,
              iconColor: _coralAccent,
              title: '공지사항',
              subtitle: 'OOMU의 새로운 기능과 커뮤니티 업데이트',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NoticeScreen()),
              ),
            ),
            const Divider(height: 1, indent: 56, color: _cardBorder),
            _buildTile(
              icon: Icons.support_agent_outlined,
              iconColor: const Color(0xFF0D9488),
              title: '고객센터 & 커뮤니티 가이드라인',
              subtitle: '1:1 문의, 안전 수칙 및 클린 커뮤니티 규칙',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomerCenterScreen()),
              ),
            ),
            const Divider(height: 1, indent: 56, color: _cardBorder),
            _buildTile(
              icon: Icons.description_outlined,
              iconColor: _textSecondary,
              title: '이용약관 및 개인정보 처리방침',
              subtitle: '서비스 이용 약관, 위치정보, 개인정보 보호정책',
              onTap: () => _showTermsDialog(context),
            ),
          ]),

          const SizedBox(height: 24),

          // 5. 로그아웃 및 계정 탈퇴
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showLogoutDialog(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _cardBorder),
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      '로그아웃',
                      style: TextStyle(
                        color: _textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showWithdrawDialog(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.withOpacity(0.3)),
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      '회원 탈퇴',
                      style: TextStyle(
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 6. 앱 버전 정보 푸터
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _cardBorder),
                  ),
                  child: const Text(
                    'OOMU v1.4.0 (최신 버전)',
                    style: TextStyle(fontSize: 11.5, color: _textSecondary, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '동네와 취향을 잇는 가장 따뜻한 소셜 플랫폼',
                  style: TextStyle(fontSize: 11, color: Color(0xFF9E8E93)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: _textSecondary,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: _textSecondary,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFC7C7CC), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _coralLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _coralAccent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: _textSecondary,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: _coralAccent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: _coralAccent, size: 22),
            SizedBox(width: 8),
            Text('로그아웃', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textPrimary)),
          ],
        ),
        content: const Text(
          '정말 로그아웃 하시겠습니까?\n로그아웃 후에도 계정 데이터는 안전하게 보관됩니다.',
          style: TextStyle(fontSize: 13.5, color: _textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소', style: TextStyle(color: _textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _coralAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('로그아웃', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFE53935), size: 22),
            SizedBox(width: 8),
            Text('회원 탈퇴 안내', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textPrimary)),
          ],
        ),
        content: const Text(
          '회원 탈퇴 시 작성하신 모임, 게시글, 매너 온도 및 프로필 정보가 영구 삭제되며 복구할 수 없습니다.\n정말 탈퇴를 진행하시겠습니까?',
          style: TextStyle(fontSize: 13, color: _textSecondary, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소', style: TextStyle(color: _textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('회원 탈퇴 처리가 안전하게 완료되었습니다.')),
              );
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('탈퇴하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFFDDDDDD), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: _coralAccent, size: 22),
                  SizedBox(width: 8),
                  Text('이용약관 및 커뮤니티 정책', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textPrimary)),
                ],
              ),
            ),
            const Divider(height: 1, color: _cardBorder),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: const [
                  Text(
                    '제1조 (목적 및 안심 플랫폼 운영)\n본 약관은 OOMU 서비스(동네 모임, 핫스팟, 문화예술 소모임, 소개팅 매칭)를 이용함에 있어 이용자와 당사 간의 권리 및 의무를 규정합니다.\n\n'
                    '제2조 (UGC 및 불건전 콘텐츠 무관용 원칙)\nOOMU는 애플 App Store 및 구글 Play 커뮤니티 가이드라인을 엄격히 준수합니다. 비방, 혐오 발언, 성희롱, 무단 광고성 게시물은 24시간 내 무관용 원칙으로 삭제되며 가해자는 즉시 영구 차단 조치됩니다.\n\n'
                    '제3조 (개인정보 보호 및 위치기반 서비스)\n이용자의 정확한 GPS 좌표는 서버에 영구 저장되지 않으며, 동네 인증 및 반경 거리 계산 목적으로만 실시간 활용됩니다. 프로필 교환은 상호 수락 시에만 제한적으로 공개됩니다.\n\n'
                    '제4조 (매너 온도 및 매칭 신뢰 시스템)\n36.5°C를 기본으로 하며, 모임 참여자들의 상호 매너 평가를 통해 신뢰도를 유지합니다.',
                    style: TextStyle(fontSize: 13, color: _textSecondary, height: 1.6),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _coralAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('확인', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
