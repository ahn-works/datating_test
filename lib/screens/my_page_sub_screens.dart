import '../services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../ui/oomu_tokens.dart';
import '../utils/global_data.dart';

class SimpleListScreen extends StatelessWidget {
  final String title;
  final List<String> items;
  final List<VoidCallback>? onTaps;
  const SimpleListScreen({
    super.key,
    required this.title,
    required this.items,
    this.onTaps,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: OomuTokens.surface,
      appBar: AppBar(
          title: Text(title,
              style: const TextStyle(
                  color: OomuTokens.textPrimary, fontWeight: FontWeight.bold)),
          backgroundColor: OomuTokens.surface,
          elevation: 0,
          iconTheme: const IconThemeData(color: OomuTokens.textPrimary)),
      body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(
              height: 1,
              thickness: 0.5,
              indent: 16,
              endIndent: 16,
              color: OomuTokens.border),
          itemBuilder: (_, i) => ListTile(
              title: Text(items[i]),
              trailing: const Icon(Icons.chevron_right, color: OomuTokens.textSecondary),
              onTap: onTaps != null && i < onTaps!.length ? onTaps![i] : null)));
}

class BlockManageScreen extends StatelessWidget {
  const BlockManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OomuTokens.surface,
      appBar: AppBar(
        title: const Text('차단 사용자 관리',
            style: TextStyle(color: OomuTokens.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: OomuTokens.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: OomuTokens.textPrimary),
      ),
      body: ValueListenableBuilder<List<String>>(
        valueListenable: globalData.blockedUsers,
        builder: (context, blockedList, _) {
          if (blockedList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: OomuTokens.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined,
                        size: 50, color: Colors.teal),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    '차단된 사용자가 없습니다',
                    style: TextStyle(
                        fontSize: OomuTokens.fs18,
                        fontWeight: FontWeight.bold,
                        color: OomuTokens.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '동네 모임과 커뮤니티에서 안심하고 대화하세요.\n불쾌한 사용자는 프로필이나 채팅에서 언제든 차단할 수 있습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: OomuTokens.fs13, color: OomuTokens.textSecondary, height: 1.4),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: OomuTokens.surfaceMuted,
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: OomuTokens.coral),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '차단된 사용자는 내 모임, 커뮤니티 글, 채팅에서 즉시 숨겨지며 추천에서 제외됩니다.',
                        style: TextStyle(
                            fontSize: OomuTokens.fs12,
                            color: OomuTokens.textSecondary,
                            height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: blockedList.length,
                  separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 16,
                      endIndent: 16,
                      color: OomuTokens.border),
                  itemBuilder: (context, index) {
                    final userName = blockedList[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      leading: const CircleAvatar(
                        backgroundColor: OomuTokens.primarySubtle,
                        child: Icon(Icons.person_off,
                            color: OomuTokens.coral, size: 20),
                      ),
                      title: Text(userName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: OomuTokens.fs15)),
                      subtitle: const Text('모든 활동 및 대화 숨김 상태',
                          style: TextStyle(fontSize: OomuTokens.fs12, color: OomuTokens.textSecondary)),
                      trailing: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: OomuTokens.border),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(OomuTokens.r8)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                        ),
                        onPressed: () {
                          globalData.unblockUser(userName);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('🎉 $userName님의 차단이 해제되었습니다.'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text('차단 해제',
                            style: TextStyle(
                                color: OomuTokens.textPrimary,
                                fontSize: OomuTokens.fs12,
                                fontWeight: FontWeight.w600)),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ReportHistoryScreen extends StatelessWidget {
  const ReportHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OomuTokens.surface,
      appBar: AppBar(
        title: const Text('신고 접수 및 처리 내역',
            style: TextStyle(color: OomuTokens.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: OomuTokens.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: OomuTokens.textPrimary),
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: globalData.reportHistory,
        builder: (context, history, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 24시간 처리 보장 안내 배너 (애플 Guideline 1.2 요구사항 완벽 대응)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(OomuTokens.r14),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.verified_user, color: Colors.teal, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🛡️ 24시간 이내 신속 검토 및 조치 보장',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: OomuTokens.fs14,
                                color: Colors.teal),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'OOMU는 건전한 만남과 안전한 커뮤니티 환경을 위해 모든 접수된 신고를 24시간 이내에 전담 운영진이 직접 검토하여 불량 콘텐츠 즉시 삭제 및 가해 유저 영구 제재를 집행합니다.',
                            style: TextStyle(
                                fontSize: OomuTokens.fs12,
                                color: OomuTokens.textBody,
                                height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text('내가 접수한 신고 목록',
                  style: TextStyle(fontSize: OomuTokens.fs15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              if (history.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text('접수된 신고 내역이 없습니다.',
                        style: TextStyle(color: OomuTokens.textSecondary)),
                  ),
                )
              else
                ...history.map((rep) {
                  final isResolved =
                      (rep['status'] ?? '').toString().contains('완료');
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: OomuTokens.surface,
                      borderRadius: BorderRadius.circular(OomuTokens.r12),
                      border: Border.all(color: OomuTokens.border),
                      boxShadow: [
                        BoxShadow(
                            color: OomuTokens.textPrimary.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isResolved
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(OomuTokens.r6),
                              ),
                              child: Text(
                                rep['status'] ?? '접수됨',
                                style: TextStyle(
                                  fontSize: OomuTokens.fs11,
                                  fontWeight: FontWeight.bold,
                                  color: isResolved
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFE65100),
                                ),
                              ),
                            ),
                            Text(rep['date'] ?? '',
                                style: const TextStyle(
                                    fontSize: OomuTokens.fs11, color: OomuTokens.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${rep['targetType'] ?? '대상'}: ${rep['targetUser'] ?? ''}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: OomuTokens.fs14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '신고 사유: ${rep['reason'] ?? ''}',
                          style: const TextStyle(
                              fontSize: OomuTokens.fs12, color: OomuTokens.textBody),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OomuTokens.surface,
      appBar: AppBar(
        title: const Text(
          '공지사항',
          style: TextStyle(color: OomuTokens.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: OomuTokens.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: OomuTokens.textPrimary),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notices')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 48,
                    color: OomuTokens.border,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '등록된 공지사항이 없어요',
                    style: TextStyle(
                      fontSize: OomuTokens.fs15,
                      fontWeight: FontWeight.w600,
                      color: OomuTokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '새로운 소식이 생기면 여기에 바로 알려드릴게요.',
                    style: TextStyle(
                      fontSize: OomuTokens.fs13,
                      color: OomuTokens.textMuted,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: docs.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: OomuTokens.border),
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>? ?? {};
              final title = (data['title'] ?? '').toString();
              final body = (data['content'] ?? data['body'] ?? '').toString();
              final date = (data['date'] ?? '').toString();

              return Theme(
                data:
                    Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontSize: OomuTokens.fs15,
                      fontWeight: FontWeight.w600,
                      color: OomuTokens.textPrimary,
                    ),
                  ),
                  subtitle: date.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            date,
                            style: const TextStyle(
                              fontSize: OomuTokens.fs12,
                              color: OomuTokens.textSecondary,
                            ),
                          ),
                        )
                      : null,
                  children: [
                    if (body.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: OomuTokens.surfaceMuted,
                          borderRadius: BorderRadius.circular(OomuTokens.r8),
                        ),
                        child: Text(
                          body,
                          style: const TextStyle(
                            fontSize: OomuTokens.fs13,
                            height: 1.5,
                            color: OomuTokens.textBody,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CustomerCenterScreen extends StatelessWidget {
  const CustomerCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleListScreen(
      title: '고객센터',
      items: const [
        '자주 묻는 질문 (FAQ)',
        '1:1 문의하기',
        '이용 약관',
        '개인정보 처리방침',
      ],
      onTaps: [
        () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FaqDetailScreen()),
            ),
        () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InquiryDetailScreen()),
            ),
        () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsDetailScreen()),
            ),
        () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const PrivacyPolicyDetailScreen()),
            ),
      ],
    );
  }
}

class FaqDetailScreen extends StatelessWidget {
  const FaqDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': '모임 참여는 어떻게 하나요?',
        'a': '원하는 모임 상세 화면에서 [신청하기] 버튼을 누른 뒤, 호스트에게 간단한 신청 메시지를 전달해 보세요. 호스트가 승인하면 모임 대화방에 자동 초대됩니다.'
      },
      {
        'q': '매너온도는 어떻게 올라가나요?',
        'a': '모임 참여 완료 후 상호 매너 평가와 칭찬 배지, 커뮤니티의 따뜻한 소통 활동에 따라 매너온도가 단계별로 상승합니다.'
      },
      {
        'q': '비매너 사용자를 차단하거나 신고하고 싶어요.',
        'a': '상대방 프로필 화면의 우상단 더보기(⋮) 또는 채팅방 메뉴에서 [차단하기] 또는 [신고하기]를 누르면 즉시 모든 게시글, 댓글, 채팅이 숨김 처리되며 운영팀 검토 후 제재됩니다.'
      },
      {
        'q': '프로필 정보를 수정하고 싶어요.',
        'a': '마이페이지 상단의 [프로필 수정] 버튼을 통해 닉네임, 직무, MBTI, 라이프스타일(음주, 흡연, 반려동물) 및 대표 사진을 언제든지 변경할 수 있습니다.'
      },
    ];

    return Scaffold(
      backgroundColor: OomuTokens.surface,
      appBar: AppBar(
        title: const Text('자주 묻는 질문 (FAQ)',
            style: TextStyle(color: OomuTokens.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: OomuTokens.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: OomuTokens.textPrimary),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, i) {
          final item = faqs[i];
          return ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 8),
            title: Text(item['q']!,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: OomuTokens.fs15)),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(item['a']!,
                    style: const TextStyle(
                        fontSize: OomuTokens.fs14, color: OomuTokens.textBody, height: 1.5)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class InquiryDetailScreen extends StatefulWidget {
  const InquiryDetailScreen({super.key});

  @override
  State<InquiryDetailScreen> createState() => _InquiryDetailScreenState();
}

class _InquiryDetailScreenState extends State<InquiryDetailScreen> {
  final TextEditingController _msgController = TextEditingController();
  String _selectedCategory = '서비스 이용';
  bool _isSubmitted = false;

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OomuTokens.surface,
      appBar: AppBar(
        title: const Text('1:1 문의하기',
            style: TextStyle(color: OomuTokens.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: OomuTokens.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: OomuTokens.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: OomuTokens.surfaceMuted,
                borderRadius: BorderRadius.circular(OomuTokens.r12),
                border: Border.all(color: OomuTokens.border),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📞 고객지원 안내',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: OomuTokens.fs15)),
                  SizedBox(height: 6),
                  Text('• 운영시간: 평일 10:00 ~ 18:00 (주말 및 공휴일 휴무)',
                      style: TextStyle(fontSize: OomuTokens.fs13, color: OomuTokens.textSecondary)),
                  Text('• 문의 이메일: support@oomu.app',
                      style: TextStyle(fontSize: OomuTokens.fs13, color: OomuTokens.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('문의 유형',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: OomuTokens.fs14)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(OomuTokens.r10)),
              ),
              items: ['서비스 이용', '계정 및 인증', '신고 및 제재', '기타 건의']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 20),
            const Text('문의 내용',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: OomuTokens.fs14)),
            const SizedBox(height: 8),
            TextField(
              controller: _msgController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: '궁금한 점이나 건의사항을 자세히 적어주시면 신속하게 답변해 드립니다.',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(OomuTokens.r10)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: OomuTokens.coral,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(OomuTokens.r10)),
                  elevation: 0,
                ),
                onPressed: _isSubmitted
                    ? null
                    : () async {
                        final content = _msgController.text.trim();
                        if (content.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('문의 내용을 입력해 주세요.')),
                          );
                          return;
                        }
                        final uid = authService.currentUser?.uid ?? globalData.activeUserId;
                        if (uid.isEmpty || uid == 'guest') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('1:1 문의를 남기려면 먼저 로그인해 주세요.'),
                              backgroundColor: OomuTokens.coral,
                            ),
                          );
                          return;
                        }
                        setState(() => _isSubmitted = true);
                        try {
                          await FirebaseFirestore.instance.collection('inquiries').add({
                            'userId': uid,
                            'category': _selectedCategory,
                            'content': content,
                            'status': 'pending',
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  '문의가 접수되었습니다. 검토 후 신속히 답변드리겠습니다.'),
                              backgroundColor: OomuTokens.coral,
                            ),
                          );
                          Navigator.pop(context);
                        } catch (e) {
                          if (!context.mounted) return;
                          setState(() => _isSubmitted = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('문의 접수 중 오류가 발생했습니다: $e'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                child: const Text('문의 접수하기',
                    style: TextStyle(
                        color: OomuTokens.surface,
                        fontWeight: FontWeight.bold,
                        fontSize: OomuTokens.fs15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TermsDetailScreen extends StatelessWidget {
  const TermsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OomuTokens.surface,
      appBar: AppBar(
        title: const Text('이용 약관',
            style: TextStyle(color: OomuTokens.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: OomuTokens.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: OomuTokens.textPrimary),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text(
          '제1조 (목적)\n'
          '본 약관은 OOMU(이하 "회사")가 제공하는 동네 기반 취향 모임 및 소셜 네트워킹 서비스(이하 "서비스")의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.\n\n'
          '제2조 (회원가입 및 자격)\n'
          '1. 만 19세 이상의 성인만 서비스에 가입할 수 있습니다.\n'
          '2. 타인의 정보를 도용하거나 허위 사실을 기재하여 가입한 경우 서비스 이용이 제한되거나 계정이 영구 삭제될 수 있습니다.\n\n'
          '제3조 (서비스 이용 및 회원 의무)\n'
          '1. 회원은 상호 존중과 신뢰를 바탕으로 건전한 커뮤니티 문화를 조성하여야 합니다.\n'
          '2. 음란물 배포, 사기, 욕설, 타인 비방, 무단 광고 등 불법 행위는 엄격히 금지됩니다.\n\n'
          '제4조 (계약 해지 및 이용 제한)\n'
          '회원이 본 약관의 의무를 위반하거나 운영 정책에 반하는 행위를 한 경우, 회사는 경고, 일시 정지, 영구 제재 등의 조치를 취할 수 있습니다.',
          style: TextStyle(fontSize: OomuTokens.fs14, height: 1.7, color: OomuTokens.textBody),
        ),
      ),
    );
  }
}

class PrivacyPolicyDetailScreen extends StatelessWidget {
  const PrivacyPolicyDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OomuTokens.surface,
      appBar: AppBar(
        title: const Text('개인정보 처리방침',
            style: TextStyle(color: OomuTokens.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: OomuTokens.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: OomuTokens.textPrimary),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text(
          'OOMU(이하 "회사")는 정보통신망 이용촉진 및 정보보호 등에 관한 법률 및 개인정보 보호법에 따라 정보주체의 개인정보를 보호하고 관련 고충을 신속하게 처리하기 위하여 다음과 같이 개인정보 처리방침을 수립·공개합니다.\n\n'
          '1. 개인정보의 수집 항목 및 방법\n'
          '• 필수항목: 닉네임, 성별, 나이, 활동 동네, 프로필 사진, 직무, MBTI\n'
          '• 인증항목: 휴대전화번호 (문자 본인확인 시에만 수집하며 별도 안전 분리 보관)\n'
          '• 서비스 이용과정에서 생성되는 정보: 기기 식별값, 서비스 이용 기록, 접속 로그\n\n'
          '2. 개인정보의 수집 및 이용 목적\n'
          '• 회원 식별 및 본인 확인, 부정 이용 방지\n'
          '• 동네 기반 맞춤 모임 추천 및 참가자 간 소셜 매칭\n'
          '• 고객 불만 접수 및 분쟁 처리, 공지사항 전달\n\n'
          '3. 개인정보의 제3자 제공\n'
          '회사는 원칙적으로 이용자의 개인정보를 외부에 제공하지 않습니다. 단, 다음의 경우는 예외로 합니다:\n'
          '• 이용자가 사전에 동의한 경우\n'
          '• 법령의 규정에 의거하거나, 수사 목적으로 법령에 정해진 절차와 방법에 따라 수사기관의 요구가 있는 경우\n'
          '• 모임 참여 시 모임 진행을 위해 필요한 최소한의 프로필 정보(닉네임, 매너온도 등)가 참가자에게 노출됩니다.\n\n'
          '4. 개인정보 처리의 위탁\n'
          '회사는 원활한 서비스 제공을 위해 다음과 같이 개인정보 처리 업무를 외부 전문기관에 위탁하고 있습니다:\n'
          '• Cloudflare Inc. (R2 Storage): 프로필 및 콘텐츠 미디어 파일의 안전한 저장 및 CDN 전송\n'
          '• Google LLC (Firebase / Firestore): 데이터베이스 호스팅 및 인증 인프라 운영\n'
          '• (주)누리고 (Solapi SMS): 본인확인 SMS 인증번호 및 알림 발송 대행\n\n'
          '5. 개인정보의 보유 및 파기\n'
          '회사는 원칙적으로 개인정보 수집 및 이용 목적이 달성된 후에는 해당 정보를 지체 없이 파기합니다. 단, 전자상거래 등에서의 소비자보호에 관한 법률 등 관계 법령의 규정에 따라 보존할 필요가 있는 경우 법정 기간 동안 안전하게 분리 보관합니다.\n\n'
          '6. 정보주체와 법정대리인의 권리·의무 및 행사방법\n'
          '이용자는 언제든지 등록되어 있는 자신의 개인정보를 조회하거나 수정할 수 있으며, 회원 탈퇴를 통해 개인정보의 수집 및 이용에 대한 동의를 철회할 수 있습니다.\n\n'
          '7. 개인정보 보호책임자 및 고충처리 문의처\n'
          '회사는 개인정보 처리에 관한 업무를 총괄해서 책임지고, 개인정보 처리와 관련한 정보주체의 불만처리 및 피해구제 등을 위하여 아래와 같이 개인정보 보호책임자를 지정하고 있습니다:\n'
          '• 개인정보 보호책임자: OOMU 개인정보보호팀\n'
          '• 담당 부서: 서비스 운영팀\n'
          '• 문의 이메일: support@oomu.app\n'
          '• 문의 창구: 앱 내 고객센터 1:1 문의',
          style: TextStyle(fontSize: OomuTokens.fs14, height: 1.7, color: OomuTokens.textBody),
        ),
      ),
    );
  }
}
