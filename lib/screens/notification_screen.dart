import 'package:flutter/material.dart';
import 'soso_car_chat_screen.dart';
import 'chat_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final Color textPrimary = const Color(0xFF221B1D);
  final Color textSecondary = const Color(0xFF635559);
  final Color surfaceColor = const Color(0xFFFAF6F7);
  final Color coralAccent = const Color(0xFFF25767);
  final Color cardColor = Colors.white;

  int _selectedTab = 0; // 0: 전체, 1: 모임, 2: 커뮤니티, 3: 소개팅/매칭

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'noti_01',
      'category': '모임',
      'title': '🎉 모임 참여 승인이 완료되었습니다!',
      'body': '[성수 소소스팟 비스트로 와인 모임] 방장님이 참여를 승인했습니다. 지금 단톡방에서 인사를 나눠보세요.',
      'time': '3분 전',
      'isRead': false,
      'icon': Icons.celebration_rounded,
      'iconColor': Color(0xFFF25767),
      'targetType': 'chat',
      'targetTitle': '성수 소소스팟 비스트로 와인 모임',
    },
    {
      'id': 'noti_02',
      'category': '커뮤니티',
      'title': '💬 내 글에 새로운 댓글이 달렸습니다.',
      'body': '\'스위니토드 샤롯데 꿀자리 추천\' 글에 달콤빵순이님이 "B구역 8열 진짜 시야 최고예요!" 댓글을 남겼습니다.',
      'time': '18분 전',
      'isRead': false,
      'icon': Icons.chat_bubble_rounded,
      'iconColor': Color(0xFF6366F1),
      'targetType': 'community',
    },
    {
      'id': 'noti_03',
      'category': '소개팅/매칭',
      'title': '💖 새로운 호감 시그널이 도착했습니다!',
      'body': '마포구 서교동의 이웃이 회원님에게 호감을 보냈습니다. 프로필을 확인하고 시크릿 매칭을 이어가보세요.',
      'time': '1시간 전',
      'isRead': false,
      'icon': Icons.favorite_rounded,
      'iconColor': Color(0xFFEC4899),
      'targetType': 'dating',
    },
    {
      'id': 'noti_04',
      'category': '모임',
      'title': '⚡ 10분 컷 실시간 번개 알림',
      'body': '내 주변 200m [홍대입구역 9번 출구 인생네컷 & 와플] 즉석 번개가 열렸습니다. (남은 인원 2명)',
      'time': '2시간 전',
      'isRead': true,
      'icon': Icons.bolt_rounded,
      'iconColor': Color(0xFFFF8A3D),
      'targetType': 'spot',
    },
    {
      'id': 'noti_05',
      'category': '모임',
      'title': '⭐ 매너온도가 0.5°C 상승했습니다!',
      'body': '최근 참석하신 모임원들로부터 "시간 약속을 잘 지켜요", "친절해요" 칭찬 배지를 받았습니다.',
      'time': '어제',
      'isRead': true,
      'icon': Icons.thumb_up_rounded,
      'iconColor': Color(0xFF0D9488),
      'targetType': 'profile',
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('모든 알림을 읽음 처리했습니다.')),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> noti) {
    setState(() {
      noti['isRead'] = true;
    });

    final targetType = noti['targetType'];
    if (targetType == 'chat') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OOMUChatScreen(
            title: noti['targetTitle'] ?? '성수 소소스팟 비스트로 와인 모임',
            memberCount: 4,
            chatRoomId: 'room_wine_01',
          ),
        ),
      );
    } else if (targetType == 'dating' || targetType == 'spot' || targetType == 'community') {
      Navigator.pop(context); // Go back to home to see relevant tab
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _notifications.where((n) {
      if (_selectedTab == 0) return true;
      if (_selectedTab == 1) return n['category'] == '모임';
      if (_selectedTab == 2) return n['category'] == '커뮤니티';
      if (_selectedTab == 3) return n['category'] == '소개팅/매칭';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '알림 센터',
          style: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: Text(
              '모두 읽음',
              style: TextStyle(color: coralAccent, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildTabChip('전체', 0),
                const SizedBox(width: 8),
                _buildTabChip('동네모임', 1),
                const SizedBox(width: 8),
                _buildTabChip('커뮤니티', 2),
                const SizedBox(width: 8),
                _buildTabChip('소개팅/매칭', 3),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEFE4E6)),

          // Notifications List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 48, color: textSecondary.withOpacity(0.4)),
                        const SizedBox(height: 12),
                        Text(
                          '새로운 알림이 없습니다',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '새로운 모임 소식이나 매칭이 도착하면 알려드릴게요.',
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3EAEB)),
                    itemBuilder: (context, index) {
                      final noti = filtered[index];
                      final bool isRead = noti['isRead'] ?? false;

                      return InkWell(
                        onTap: () => _handleNotificationTap(noti),
                        child: Container(
                          color: isRead ? Colors.transparent : const Color(0xFFFFF7F8),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon badge
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: (noti['iconColor'] as Color).withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  noti['icon'] as IconData,
                                  color: noti['iconColor'] as Color,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF3EAEB),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            noti['category'],
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: textSecondary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          noti['time'],
                                          style: TextStyle(fontSize: 11, color: textSecondary),
                                        ),
                                        const Spacer(),
                                        if (!isRead)
                                          Container(
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              color: coralAccent,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      noti['title'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      noti['body'],
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        height: 1.35,
                                        color: isRead ? const Color(0xFF767676) : const Color(0xFF444444),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? coralAccent : const Color(0xFFF3EAEB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : textPrimary,
          ),
        ),
      ),
    );
  }
}
