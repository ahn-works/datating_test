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
  final Color darkGreen = const Color(0xFF14422D);
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
      backgroundColor: const Color(0xFFFBF9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${widget.memberCount}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            )
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.menu, color: Colors.black87), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Meetup Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFE8ECEF), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.calendar_month, color: darkGreen, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('이번주 토요일 오후 6시', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 2),
                      Text('홍대입구역 9번 출구 앞', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OOMUDetailScreen()));
                  },
                  child: Text('모임 상세', style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                if (msg['type'] == 'system') {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(msg['text'], style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ),
                  );
                }

                bool isMe = msg['isMe'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMe) ...[
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(msg['avatar']),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Flexible(
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (!isMe) ...[
                              Text(msg['sender'], style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                            ],
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (isMe) ...[
                                  Text(msg['time'], style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                                  const SizedBox(width: 8),
                                ],
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isMe ? darkGreen : Colors.white,
                                    borderRadius: BorderRadius.circular(20).copyWith(
                                      topLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                                      topRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                                    ),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
                                  ),
                                  child: Text(
                                    msg['text'],
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black87,
                                      fontSize: 15,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                if (!isMe) ...[
                                  const SizedBox(width: 8),
                                  Text(msg['time'], style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.grey.shade600),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF9F6),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: '메시지 보내기',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: darkGreen,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () {},
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

print("Updated soso_car_chat_screen.dart")
