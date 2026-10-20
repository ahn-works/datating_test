import '../utils/global_data.dart';

class SimpleListScreen extends StatelessWidget {
  final String title; final List<String> items;
  const SimpleListScreen({super.key, required this.title, required this.items});
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.white, appBar: AppBar(title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)), body: ListView.separated(padding: const EdgeInsets.all(16), itemCount: items.length, separatorBuilder: (_,__) => const Divider(), itemBuilder: (_, i) => ListTile(title: Text(items[i]), trailing: const Icon(Icons.chevron_right, color: Colors.grey))));
}

class BlockManageScreen extends StatelessWidget {
  const BlockManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('차단 사용자 관리', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined, size: 50, color: Colors.teal),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    '차단된 사용자가 없습니다',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '동네 모임과 커뮤니티에서 안심하고 대화하세요.\n불쾌한 사용자는 프로필이나 채팅에서 언제든 차단할 수 있습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xFFFAF6F7),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Color(0xFFF25767)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '차단된 사용자는 내 모임, 커뮤니티 글, 채팅에서 즉시 숨겨지며 추천에서 제외됩니다.',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF635559), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: blockedList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final userName = blockedList[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFFFECEE),
                        child: const Icon(Icons.person_off, color: Color(0xFFF25767), size: 20),
                      ),
                      title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      subtitle: const Text('모든 활동 및 대화 숨김 상태', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      trailing: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE5E5EA)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        child: const Text('차단 해제', style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600)),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('신고 접수 및 처리 내역', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
                  borderRadius: BorderRadius.circular(14),
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
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'OOMU는 건전한 만남과 안전한 커뮤니티 환경을 위해 모든 접수된 신고를 24시간 이내에 전담 운영진이 직접 검토하여 불량 콘텐츠 즉시 삭제 및 가해 유저 영구 제재를 집행합니다.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF333333), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text('내가 접수한 신고 목록', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              if (history.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text('접수된 신고 내역이 없습니다.', style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                ...history.map((rep) {
                  final isResolved = (rep['status'] ?? '').toString().contains('완료');
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E5EA)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isResolved ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                rep['status'] ?? '접수됨',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isResolved ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                                ),
                              ),
                            ),
                            Text(rep['date'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${rep['targetType'] ?? '대상'}: ${rep['targetUser'] ?? ''}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '신고 사유: ${rep['reason'] ?? ''}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
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
  @override Widget build(BuildContext context) => SimpleListScreen(title: '공지사항', items: ['[안내] 가을 맞이 동네 커플 매칭 이벤트', '[업데이트] 여행 모임 기능 개편 안내 v2.0', '[필독] 안전한 만남을 위한 커뮤니티 가이드']);
}

class CustomerCenterScreen extends StatelessWidget {
  const CustomerCenterScreen({super.key});
  @override Widget build(BuildContext context) => SimpleListScreen(title: '고객센터', items: ['자주 묻는 질문 (FAQ)', '1:1 문의하기', '이용 약관', '개인정보 처리방침']);
}
