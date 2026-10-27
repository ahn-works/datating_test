import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'party_application_screen.dart';

class PartyDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? partyData;

  const PartyDetailScreen({
    super.key,
    this.partyData,
  });

  @override
  State<PartyDetailScreen> createState() => _PartyDetailScreenState();
}

class _PartyDetailScreenState extends State<PartyDetailScreen> {
  bool _isLiked = false;

  void _showHostManagementModal(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '호스트 전용 관리',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF6B4A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '동승·모임 신청자 목록 (2명)',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _applicantCard(
                    ctx: context,
                    name: '지훈',
                    info: '28세 · 남성 · 직장인',
                    mannerTemp: 42.5,
                    reviews: ['약속 시간 칼같아요 ⏰', '안전 매너 최고 🛡️', '조용한 분위기 🎧'],
                    smoke: '비흡연자',
                    talk: '편안하고 자연스러운 대화 선호',
                    music: '아이유, 잔잔한 어쿠스틱 인디',
                    avatarUrl: 'https://picsum.photos/100?random=800',
                  ),
                  const SizedBox(height: 16),
                  _applicantCard(
                    ctx: context,
                    name: '수아',
                    info: '26세 · 여성 · 디자이너',
                    mannerTemp: 38.2,
                    reviews: ['분위기 메이커 🥳', '동네 핫플 박사 ☕'],
                    smoke: '비흡연자',
                    talk: '유쾌하고 긍정적인 티키타카',
                    music: '신나는 팝 & 시티팝',
                    avatarUrl: 'https://picsum.photos/100?random=801',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _applicantCard({
    required BuildContext ctx,
    required String name,
    required String info,
    required double mannerTemp,
    required List<String> reviews,
    required String smoke,
    required String talk,
    required String music,
    required String avatarUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFF1F5), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFF1F5F9),
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded, color: Color(0xFF0064FF), size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('매너온도', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w600)),
                    Text(
                      '$mannerTemp°C',
                      style: const TextStyle(
                        color: Color(0xFFFF6B4A),
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('이전 모임 매너 후기', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: reviews.map((r) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                r,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )).toList(),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: Color(0xFFF1F5F9), height: 1),
          ),
          const Text('취향 & 스타일', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.smoke_free_rounded, size: 15, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Text(smoke, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.forum_outlined, size: 15, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Text(talk, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.music_note_rounded, size: 15, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '선곡 스타일: $music',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('정중하게 거절 메시지를 전달했습니다.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('거절하기', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('참여 수락 완료! 안전 모임 단톡방이 열렸습니다.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B4A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('수락하기', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showSafetyReportSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Icon(Icons.shield_outlined, color: Color(0xFFFF6B4A), size: 22),
                SizedBox(width: 8),
                Text('안심 클린 가이드 & 신고', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'OOMU는 건전하고 안전한 30대 동네 모임을 지향합니다.\n부적절한 언행, 영리 목적, 노쇼 등의 행위는 즉시 영구 이용 제한 조치됩니다.',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.block_flipped, color: Color(0xFFE11D48)),
              title: const Text('이 모임 및 호스트 차단하기', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFE11D48))),
              subtitle: const Text('피드 및 모임 탐색에서 더 이상 노출되지 않습니다.', style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('해당 모임과 호스트가 차단되었습니다.'), behavior: SnackBarBehavior.floating),
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.report_problem_outlined, color: Color(0xFF64748B)),
              title: const Text('비매너/허위 정보 신고하기', style: TextStyle(fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('신고가 접수되었습니다. 운영팀이 24시간 내 조치합니다.'), behavior: SnackBarBehavior.floating),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.partyData?['title'] ?? '이번 주말 양양 드라이브 서핑 🚙 (제 차로 편하게 가요!)';
    final category = widget.partyData?['category'] ?? '⚡ 오늘 번개';
    final location = widget.partyData?['loc'] ?? '강원 양양군 / 잠실역 4번 출구 집결';
    final date = widget.partyData?['date'] ?? '9월 19일 (토) 오전 8:00 출발';
    final hostName = widget.partyData?['author'] ?? '스윗드라이버';
    final hostInfo = widget.partyData?['authorInfo'] ?? '30대 · 남성 · 베스트 드라이버';
    final imageUrl = widget.partyData?['img'] ?? 'https://picsum.photos/600/400?random=11';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F7), // OOMU 오트밀 로즈 크림 베이스
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. 유려한 슬리버 패럴랙스 헤더 (Fluid Micro-Interactions)
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                ),
                onPressed: () => _showSafetyReportSheet(context),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('모임 공유 링크가 클립보드에 복사되었습니다.'), behavior: SnackBarBehavior.floating),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFE2E8F0),
                      child: const Center(
                        child: Icon(Icons.image_not_supported_rounded, color: Color(0xFF94A3B8), size: 40),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B4A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.lock_clock_rounded, color: Colors.white70, size: 13),
                              SizedBox(width: 4),
                              Text('여성 안심 승인제', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. 본문 컨텐츠
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 호스트 관리 뱃지 액션
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4EB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFE0D0)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF6B4A), size: 14),
                            SizedBox(width: 4),
                            Text(
                              '실시간 신청 급증 모임',
                              style: TextStyle(
                                color: Color(0xFFFF6B4A),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showHostManagementModal(context),
                        icon: const Icon(Icons.manage_accounts_rounded, size: 16, color: Color(0xFF0F172A)),
                        label: const Text(
                          '호스트 전용 관리',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 모임 제목 (한글 타이포그래피 행간 1.4 준수)
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.4,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 참여 인원 아바타 스택 (Event-Meetup-Engine 규격)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEFF1F5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 34,
                              width: 34 + (2 * (34 * 0.65)),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const CircleAvatar(
                                        radius: 15,
                                        backgroundImage: NetworkImage('https://picsum.photos/100?random=301'),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 22,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const CircleAvatar(
                                        radius: 15,
                                        backgroundImage: NetworkImage('https://picsum.photos/100?random=302'),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 44,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const CircleAvatar(
                                        radius: 15,
                                        backgroundImage: NetworkImage('https://picsum.photos/100?random=303'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '3명 참여 확정 (정원 4명)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '마지막 1자리 남음 · 선착순 마감',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFFF6B4A),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '75%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 상세 일정 & 장소 카드
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEFF1F5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '모임 안내 및 일정',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.calendar_today_rounded, color: Color(0xFF475569), size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('일정', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                                  const SizedBox(height: 2),
                                  Text(date, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Color(0xFFF1F5F9), height: 1),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.location_on_rounded, color: Color(0xFFFF6B4A), size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('집결 및 목적지', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                                  const SizedBox(height: 2),
                                  Text(location, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. 참여 비용 안내 (제0원칙 준수: 원화 직접 표기 전면 배제 및 1/N 안심 정산 표기)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEFF1F5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '정산 방식',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                            ),
                            Text(
                              '1/N 안심 정산',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFFF6B4A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4EB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.verified_user_rounded, color: Color(0xFFFF6B4A), size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    '투명 1/N 에스크로 정산 시스템',
                                    style: TextStyle(
                                      color: Color(0xFFFF6B4A),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6),
                              Text(
                                '모임 종료 후 실제 발생한 주유/식대 영수증을 기준으로 정확히 N분의 1 자동 정산됩니다. 사전 과도한 참가비나 사설 입금 요구는 없습니다.',
                                style: TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 12,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. 호스트 신뢰도 카드 (Manner-Temp-Badges)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEFF1F5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '호스트 신뢰 정보',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 26,
                              backgroundColor: Color(0xFFF1F5F9),
                              backgroundImage: NetworkImage('https://picsum.photos/100?random=20'),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        hostName,
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F5E9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text('본인인증완료', style: TextStyle(color: Color(0xFF2E7D32), fontSize: 10, fontWeight: FontWeight.w700)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(hostInfo, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('매너온도', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600)),
                                const Text(
                                  '42.1°C',
                                  style: TextStyle(
                                    color: Color(0xFFFF6B4A),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 5. 모임 상세 내용 소개
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEFF1F5)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '모임 상세 소개',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '안녕하세요! 이번 주말에 서핑하러 양양에 가는데 혼자 가기 심심해서 드라이브 인원 모집합니다. 제 차는 싼타페라 뒷자리 넉넉하고 트렁크 공간도 충분해요! 운전은 제가 다 할 테니 편하게 오시면 됩니다. 휴게소에서 소떡소떡 쏘실 분 환영해요 😆\n\n- 흡연/비매너는 절대 사절합니다.\n- 출발 전 단톡방에서 상세 일정 및 동선 공유합니다.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // 6. 하단 고정 신청 바텀시트 (Sticky Bottom Apply Bar - Event-Meetup-Engine 규격)
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            )
          ],
          border: const Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1.0)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isLiked = !_isLiked);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isLiked ? '관심 모임에 저장되었습니다.' : '관심 모임에서 제외되었습니다.'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                icon: Icon(
                  _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _isLiked ? const Color(0xFFFF3B30) : const Color(0xFF94A3B8),
                  size: 26,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PartyApplicationScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B4A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text(
                    '모임 참여 신청하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}