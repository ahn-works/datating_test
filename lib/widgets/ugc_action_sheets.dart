import 'package:flutter/material.dart';
import '../utils/global_data.dart';

/// 앱스토어 Guideline 1.2(UGC) 대응을 위한 표준 신고 및 차단 액션시트 유틸리티
class UgcActionSheets {
  /// 게시글/댓글/채팅 메시지 등 콘텐츠 단위 옵션 액션시트
  static void showContentOptions({
    required BuildContext context,
    required String contentType, // 예: '게시글', '메시지', '댓글'
    required String contentId,
    required String author,
    VoidCallback? onContentHidden,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    '$contentType 관리',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.flag_outlined, color: Colors.red, size: 20),
                ),
                title: Text('이 $contentType 신고하기', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('부적절한 내용, 스팸, 혐오 표현 등', style: TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                onTap: () {
                  Navigator.pop(ctx);
                  showReportDialog(
                    context: context,
                    targetType: contentType,
                    targetId: contentId,
                    targetUser: author,
                    onReportSubmitted: onContentHidden,
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.block, color: Colors.deepOrange, size: 20),
                ),
                title: Text('작성자($author) 차단하기', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('이 사용자의 모든 글과 메시지를 즉시 숨깁니다', style: TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                onTap: () {
                  Navigator.pop(ctx);
                  showBlockConfirmDialog(
                    context: context,
                    userName: author,
                    onUserBlocked: onContentHidden,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 사용자 프로필 / 대화 상대방 단위 옵션 액션시트
  static void showUserOptions({
    required BuildContext context,
    required String userName,
    VoidCallback? onUserBlocked,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    '$userName님 관리',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.report_problem_outlined, color: Colors.red, size: 20),
                ),
                title: const Text('이 사용자 신고하기', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('비매너 행위, 불쾌한 언어, 사기 사칭 등', style: TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                onTap: () {
                  Navigator.pop(ctx);
                  showReportDialog(
                    context: context,
                    targetType: '사용자',
                    targetId: 'user_$userName',
                    targetUser: userName,
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.block, color: Colors.deepOrange, size: 20),
                ),
                title: const Text('이 사용자 차단하기', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('모임 및 대화에서 서로 영구 제외됩니다', style: TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                onTap: () {
                  Navigator.pop(ctx);
                  showBlockConfirmDialog(
                    context: context,
                    userName: userName,
                    onUserBlocked: onUserBlocked,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 표준 신고 사유 선택 다이얼로그 (Apple App Store Guideline 1.2 준수)
  static void showReportDialog({
    required BuildContext context,
    required String targetType,
    required String targetId,
    required String targetUser,
    VoidCallback? onReportSubmitted,
  }) {
    final reasons = [
      {'title': '🔞 음란물 / 선정적인 콘텐츠', 'desc': '성적 불쾌감을 주는 사진이나 글'},
      {'title': '🤬 욕설 / 혐오 / 비방 발언', 'desc': '타인을 모욕하거나 차별하는 표현'},
      {'title': '📢 스팸 / 불법 광고 / 도배', 'desc': '상업적 홍보나 반복적인 게시물'},
      {'title': '💸 사기 / 금전 요구 / 계정 사칭', 'desc': '금전 갈취, 사기 행위, 타인 사칭'},
      {'title': '⚠️ 만남 노쇼 / 비매너 행위', 'desc': '약속 미이행 또는 오프라인 위협'},
      {'title': '📝 기타 부적절한 사유', 'desc': '커뮤니티 운영 원칙 위배'},
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.report, color: Colors.redAccent, size: 22),
            const SizedBox(width: 8),
            Text('$targetType 신고 사유 선택', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '신고 내용은 24시간 이내에 운영팀에서 검토되며, 운영 정책 위반 시 해당 콘텐츠 삭제 및 계정 영구 제재가 진행됩니다.',
                style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: reasons.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final item = reasons[index];
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      subtitle: Text(item['desc']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      onTap: () {
                        Navigator.pop(ctx);
                        globalData.submitReport(
                          targetType: targetType,
                          targetId: targetId,
                          targetUser: targetUser,
                          reason: item['title']!,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🚨 신고가 접수되었습니다. 24시간 이내에 운영진이 검토 후 영구 제재 조치합니다.'),
                            backgroundColor: Colors.black87,
                            duration: Duration(seconds: 3),
                          ),
                        );
                        onReportSubmitted?.call();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  /// 차단 확인 다이얼로그 (Apple App Store Guideline 1.2 준수)
  static void showBlockConfirmDialog({
    required BuildContext context,
    required String userName,
    VoidCallback? onUserBlocked,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.block, color: Colors.redAccent, size: 22),
            SizedBox(width: 8),
            Text('사용자 차단', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          '$userName님을 차단하시겠습니까?\n\n'
          '• 차단 즉시 서로의 모든 게시글, 댓글, 채팅 메시지가 숨겨집니다.\n'
          '• 모임 및 소개팅 추천 매칭에서 영구 제외됩니다.\n'
          '• 설정 > 차단 관리 메뉴에서 언제든지 차단을 해제할 수 있습니다.',
          style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF333333)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              globalData.blockUser(userName);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🚫 $userName님이 차단되었습니다. 모든 게시글과 대화가 즉시 숨김 처리됩니다.'),
                  backgroundColor: Colors.redAccent,
                  duration: const Duration(seconds: 3),
                ),
              );
              onUserBlocked?.call();
            },
            child: const Text('차단하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
