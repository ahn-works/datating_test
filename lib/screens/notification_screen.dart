import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../ui/oomu_empty_state.dart';
import '../ui/oomu_skeleton.dart';
import '../ui/oomu_tokens.dart';
import '../utils/global_data.dart';
import 'oomu_detail_screen.dart';

/// 실시간 알림 목록 화면 (§4-4)
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  Stream<QuerySnapshot<Map<String, dynamic>>>? _stream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    final uid = globalData.activeUserId.trim();
    if (globalData.isGuest) {
      _stream = null;
      return;
    }
    _stream = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .limit(50)
        .snapshots();
  }

  String _formatRelativeTime(dynamic ts) {
    if (ts == null) return '';
    DateTime? dt;
    if (ts is Timestamp) {
      dt = ts.toDate();
    } else if (ts is String) {
      dt = DateTime.tryParse(ts);
    }
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${dt.month}월 ${dt.day}일';
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'meetup_decision':
        return Icons.celebration_rounded;
      case 'meetup_request':
        return Icons.group_add_rounded;
      case 'chat':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Future<void> _handleNotificationTap(
      String docId, Map<String, dynamic> data) async {
    if (data['read'] != true) {
      try {
        await FirebaseFirestore.instance
            .collection('notifications')
            .doc(docId)
            .update({'read': true});
      } catch (_) {}
    }
    final meetupId = (data['meetupId'] ?? '').toString();
    if (meetupId.isNotEmpty && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OOMUDetailScreen(meetup: {'id': meetupId}),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isGuest = globalData.isGuest;

    return Scaffold(
      backgroundColor: OomuTokens.bgCanvas,
      appBar: AppBar(
        backgroundColor: OomuTokens.surface,
        surfaceTintColor: OomuTokens.surface,
        elevation: 0,
        title: Text(
          '알림',
          style: TextStyle(
            color: OomuTokens.textPrimary,
            fontSize: OomuTokens.fs18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          tooltip: '뒤로가기',
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: isGuest
            ? Center(
                child: OomuEmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: '로그인이 필요한 서비스예요',
                  subtitle: '로그인하면 내 모임의 새 소식과\n신청 결과를 실시간으로 받아볼 수 있어요.',
                  buttonLabel: '동네 모임 둘러보기',
                  onButtonPressed: () => Navigator.pop(context, 0),
                ),
              )
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: OomuEmptyState(
                        icon: Icons.error_outline_rounded,
                        title: '알림을 불러오지 못했어요',
                        subtitle: '잠시 후 다시 시도해 주세요.',
                        buttonLabel: '다시 시도',
                        onButtonPressed: () {
                          setState(_initStream);
                        },
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      itemCount: 4,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (_, __) => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const OomuSkeleton.circle(size: 40),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const OomuSkeleton(height: 16, width: 140),
                                const SizedBox(height: 8),
                                OomuSkeleton(
                                    height: 14,
                                    width: MediaQuery.of(context).size.width *
                                        0.6),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs.toList() ?? [];
                  docs.sort((a, b) {
                    final ta = a.data()['createdAt'];
                    final tb = b.data()['createdAt'];
                    final da = ta is Timestamp
                        ? ta.toDate()
                        : (DateTime.tryParse(ta?.toString() ?? '') ??
                            DateTime.fromMillisecondsSinceEpoch(0));
                    final db = tb is Timestamp
                        ? tb.toDate()
                        : (DateTime.tryParse(tb?.toString() ?? '') ??
                            DateTime.fromMillisecondsSinceEpoch(0));
                    return db.compareTo(da);
                  });

                  if (docs.isEmpty) {
                    return Center(
                      child: OomuEmptyState(
                        icon: Icons.notifications_none_rounded,
                        title: '새로운 알림이 없어요',
                        subtitle: '동네 모임 소식과 신청 결과를\n여기서 실시간으로 알려드려요.',
                        buttonLabel: '동네 모임 둘러보기',
                        onButtonPressed: () => Navigator.pop(context, 0),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 16,
                      endIndent: 16,
                      color: OomuTokens.border,
                    ),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();
                      final isRead = data['read'] == true;
                      final type = (data['type'] ?? '').toString();
                      final title = (data['title'] ?? '').toString();
                      final body = (data['body'] ?? '').toString();
                      final timeStr = _formatRelativeTime(data['createdAt']);

                      return InkWell(
                        onTap: () => _handleNotificationTap(doc.id, data),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          color: isRead
                              ? OomuTokens.bgCanvas
                              : OomuTokens.coral.withValues(alpha: 0.04),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isRead
                                      ? OomuTokens.surfaceElevated
                                      : OomuTokens.coral.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getTypeIcon(type),
                                  size: 20,
                                  color: isRead
                                      ? OomuTokens.textSecondary
                                      : OomuTokens.coral,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            title,
                                            style: TextStyle(
                                              color: isRead
                                                  ? OomuTokens.textSecondary
                                                  : OomuTokens.textPrimary,
                                              fontSize: OomuTokens.fs15,
                                              fontWeight: isRead
                                                  ? FontWeight.w500
                                                  : FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        if (timeStr.isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 8),
                                            child: Text(
                                              timeStr,
                                              style: TextStyle(
                                                color: OomuTokens.textMuted,
                                                fontSize: OomuTokens.fs12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (body.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        body,
                                        style: TextStyle(
                                          color: isRead
                                              ? OomuTokens.textMuted
                                              : OomuTokens.textSecondary,
                                          fontSize: OomuTokens.fs13,
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
