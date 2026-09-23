import 'package:flutter/material.dart';

class OOMUChatScreen extends StatefulWidget {
  final String title;
  final int memberCount;

  const OOMUChatScreen({super.key, required this.title, required this.memberCount});

  @override
  State<OOMUChatScreen> createState() => _OOMUChatScreenState();
}

class _OOMUChatScreenState extends State<OOMUChatScreen> {
  final Color textPrimary = const Color(0xFF111111);
  final Color textSecondary = const Color(0xFF767676);
  final Color surfaceColor = const Color(0xFFF5F5F7);
  final Color accentColor = const Color(0xFFF19E39);
  
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {'type': 'system', 'text': '매운맛킬러(방장)님이 모임을 개설했습니다.'},
    {'type': 'system', 'text': '달리는 민우님이 참여 승인되어 합류했습니다! 🎉'},
    {'type': 'text', 'sender': '매운맛킬러', 'text': '안녕하세요! 다들 마라탕 좋아하시죠?', 'isMe': false, 'time': '오후 2:30'},
    {'type': 'text', 'sender': '달리는 민우', 'text': '네 완전 좋아합니다ㅎㅎ 잘 부탁드려요!', 'isMe': true, 'time': '오후 2:32'},
    {'type': 'text', 'sender': '매운맛킬러', 'text': '그럼 이번주 토요일 6시에 홍대에서 봬요!', 'isMe': false, 'time': '오후 2:35'},
    {'type': 'settlement', 'sender': '매운맛킬러', 'total': 45000, 'perPerson': 15000, 'title': '마라탕 & 카페 N빵', 'isMe': false, 'time': '오후 8:00'},
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'type': 'text',
        'sender': '달리는 민우',
        'text': _controller.text.trim(),
        'isMe': true,
        'time': '오후 8:05',
      });
      _controller.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7), // Soft chat background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${widget.memberCount}명 참여중', style: TextStyle(color: textSecondary, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.menu, color: textPrimary), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // [MVP 우선순위 3] 채팅 기반 약속 카드 (상단 고정)
          _buildAppointmentCard(),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                if (msg['type'] == 'system') return _buildSystemMessage(msg['text']);
                if (msg['type'] == 'settlement') return _buildSettlementMessage(msg);
                return _buildTextMessage(msg);
              },
            ),
          ),

          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  // 약속 카드 UI (다음 지도 API 연동 예시)
  Widget _buildAppointmentCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month, color: accentColor, size: 20),
                  const SizedBox(width: 8),
                  Text('약속 확정!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFFEFE5), borderRadius: BorderRadius.circular(12)),
                child: Text('D-2', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('일시: 2026. 9. 26 (토) 오후 6:00', style: TextStyle(fontSize: 14, color: textPrimary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('장소: 홍대입구역 9번 출구 앞', style: TextStyle(fontSize: 14, color: textPrimary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          // 다음 지도 (Kakao Map) 썸네일 예시
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800&q=80'), // Placeholder for map
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withOpacity(0.3),
              ),
              child: const Center(
                child: Text('📍 카카오맵에서 위치 보기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
          child: Text(text, style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  // [MVP 우선순위 4] 정산(N빵) UI 예시
  Widget _buildSettlementMessage(Map<String, dynamic> msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 18, backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&q=80'), backgroundColor: surfaceColor),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(msg['sender'], style: TextStyle(fontSize: 13, color: textSecondary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                width: 240,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_long, color: Color(0xFFF19E39), size: 20),
                        const SizedBox(width: 6),
                        Text('1/N 정산 요청', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(msg['title'], style: TextStyle(fontSize: 13, color: textSecondary)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('총 지출', style: TextStyle(fontSize: 13, color: textSecondary)),
                        Text('${msg['total']}원', style: TextStyle(fontSize: 13, color: textPrimary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('내가 보낼 금액', style: TextStyle(fontSize: 14, color: textPrimary, fontWeight: FontWeight.bold)),
                        Text('${msg['perPerson']}원', style: TextStyle(fontSize: 16, color: const Color(0xFFF19E39), fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF19E39),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('정산 송금 화면으로 이동합니다.')));
                        },
                        child: const Text('보내기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextMessage(Map<String, dynamic> msg) {
    bool isMe = msg['isMe'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(radius: 18, backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&q=80'), backgroundColor: surfaceColor),
            const SizedBox(width: 10),
          ],
          Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe) ...[
                Text(msg['sender'], style: TextStyle(fontSize: 13, color: textSecondary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isMe) Padding(padding: const EdgeInsets.only(right: 6), child: Text(msg['time'], style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA)))),
                  Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe ? accentColor : Colors.white,
                      borderRadius: isMe 
                        ? const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomLeft: Radius.circular(16))
                        : const BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                    ),
                    child: Text(msg['text'], style: TextStyle(fontSize: 15, color: isMe ? Colors.white : textPrimary, height: 1.4)),
                  ),
                  if (!isMe) Padding(padding: const EdgeInsets.only(left: 6), child: Text(msg['time'], style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA)))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(icon: const Icon(Icons.add_circle_outline, color: Color(0xFFC7C7CC)), onPressed: () {}),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24)),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: '메시지를 입력하세요', border: InputBorder.none, hintStyle: TextStyle(color: Color(0xFFC7C7CC))),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            IconButton(icon: Icon(Icons.send, color: accentColor), onPressed: _sendMessage),
          ],
        ),
      ),
    );
  }
}
