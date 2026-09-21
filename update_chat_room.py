import io

chat_room_code = '''import 'package:flutter/material.dart';
import 'soso_car_detail_screen.dart';

class OOMUChatScreen extends StatefulWidget {
  final String title;
  final int memberCount;

  const OOMUChatScreen({
    super.key, 
    this.title = '우무 동네 모임', 
    this.memberCount = 4
  });

  @override
  State<OOMUChatScreen> createState() => _OOMUChatScreenState();
}

class _OOMUChatScreenState extends State<OOMUChatScreen> {
  final Color textPrimary = const Color(0xFF111111);
  final Color textSecondary = const Color(0xFF767676);
  final Color surfaceColor = const Color(0xFFF5F5F7);
  final Color accentColor = const Color(0xFF007AFF);
  
  final TextEditingController _controller = TextEditingController();
  
  final List<Map<String, dynamic>> _messages = [
    {
      'type': 'system',
      'text': '매운맛킬러님이 채팅방을 개설했습니다.'
    },
    {
      'type': 'system',
      'text': '모임 장소가 \\'홍대입구역 9번 출구 앞\\'으로 설정되었습니다.'
    },
    {
      'type': 'user',
      'isMe': false,
      'sender': '매운맛킬러',
      'avatar': 'https://i.pravatar.cc/150?img=47',
      'text': '안녕하세요! 다들 마라탕 4단계 가능하시죠? 😆',
      'time': '오후 2:15'
    },
    {
      'type': 'user',
      'isMe': true,
      'text': '안녕하세요~ 완전 가능합니다! 엽떡 오리지널도 기대되네요 ㅎㅎ',
      'time': '오후 2:18'
    },
    {
      'type': 'user',
      'isMe': false,
      'sender': '마라사랑',
      'avatar': 'https://i.pravatar.cc/150?img=9',
      'text': '저도요!! 토요일 너무 기다려집니다 ㅠㅠ 홍대 9출 앞에서 봬요!',
      'time': '오후 2:30'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 16),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text('${widget.memberCount}', style: const TextStyle(color: Color(0xFFAEAEC2), fontSize: 16, fontWeight: FontWeight.w600))
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.menu, color: textPrimary), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Meetup Banner (Ultra minimal)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFEBEBEF))),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month_outlined, color: textSecondary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('이번주 토요일 오후 6시', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textPrimary)),
                      const SizedBox(height: 2),
                      Text('홍대입구역 9번 출구 앞', style: TextStyle(color: textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OOMUDetailScreen(), fullscreenDialog: true)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Text('상세 보기', style: TextStyle(color: accentColor, fontWeight: FontWeight.w700, fontSize: 13)),
                )
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                if (msg['type'] == 'system') {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20)),
                      child: Text(msg['text'], style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w600)),
                    ),
                  );
                }

                bool isMe = msg['isMe'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMe) ...[
                        CircleAvatar(radius: 20, backgroundImage: NetworkImage(msg['avatar'])),
                        const SizedBox(width: 12),
                      ],
                      Flexible(
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (!isMe) ...[
                              Text(msg['sender'], style: TextStyle(fontSize: 13, color: textSecondary, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                            ],
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (isMe) ...[
                                  Text(msg['time'], style: const TextStyle(fontSize: 11, color: Color(0xFFAEAEC2), fontWeight: FontWeight.w500)),
                                  const SizedBox(width: 8),
                                ],
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isMe ? textPrimary : surfaceColor,
                                    borderRadius: BorderRadius.circular(20).copyWith(
                                      topLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                                      topRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    msg['text'],
                                    style: TextStyle(
                                      color: isMe ? Colors.white : textPrimary,
                                      fontSize: 15, height: 1.4,
                                    ),
                                  ),
                                ),
                                if (!isMe) ...[
                                  const SizedBox(width: 8),
                                  Text(msg['time'], style: const TextStyle(fontSize: 11, color: Color(0xFFAEAEC2), fontWeight: FontWeight.w500)),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: const Color(0xFFEBEBEF))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 28),
                    color: const Color(0xFFAEAEC2),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24)),
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(color: textPrimary, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: '메시지를 입력하세요',
                          hintStyle: const TextStyle(color: Color(0xFFAEAEC2)),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.send, color: textPrimary, size: 20),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
'''
with io.open('lib/screens/soso_car_chat_screen.dart', 'w', encoding='utf-8') as f:
    f.write(chat_room_code)

print("soso_car_chat_screen.dart updated")
