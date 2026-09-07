import 'package:flutter/material.dart';
import 'middle_spot_map_screen.dart'; // 새롭게 추가된 지도 화면 임포트

class ChatRoomScreen extends StatelessWidget {
  final String title;
  final bool isGroup;

  const ChatRoomScreen({super.key, required this.title, this.isGroup = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (!isGroup)
              const Text('⏳ 05:23 남음', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          if (!isGroup)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: () {
                  // '중간지점 제안' 클릭 시 지도 및 보증금 결제 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MiddleSpotMapScreen()),
                  );
                },
                icon: const Icon(Icons.location_on, color: Color(0xFFFF8A65), size: 18),
                label: const Text('중간지점 제안', style: TextStyle(color: Color(0xFFFF8A65), fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSystemMessage('10분 익명 대화가 시작되었습니다.\n취향과 모임을 주제로 편하게 대화해보세요!'),
                const SizedBox(height: 16),
                _buildChatBubble(isMe: false, message: '안녕하세요! 취향 태그 보고 말 걸어봤어요. 😊'),
                const SizedBox(height: 8),
                _buildChatBubble(isMe: true, message: '안녕하세요! 반갑습니다 ㅎㅎ\n커피 좋아하시나봐요!'),
                const SizedBox(height: 8),
                _buildChatBubble(isMe: false, message: '네 완전 좋아해요! 주말마다 카페 투어 다니거든요.'),
              ],
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(String text) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(20)),
        child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ),
    );
  }

  Widget _buildChatBubble({required bool isMe, required String message}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFFF8A65) : Colors.white,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
            bottomLeft: !isMe ? const Radius.circular(0) : const Radius.circular(20),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Text(
          message,
          style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.grey, size: 28),
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: '메시지를 입력하세요...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: const Color(0xFFFF8A65),
              radius: 20,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
