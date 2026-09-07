import 'package:flutter/material.dart';
import 'meet_proposal_screen.dart';
import 'middle_spot_map_screen.dart';

class ChatRoomScreen extends StatefulWidget {
  final String title;
  final bool isGroup;

  const ChatRoomScreen({super.key, required this.title, this.isGroup = false});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final String _timeLeft = "05:23"; // dummy time

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (!widget.isGroup)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: ElevatedButton(
                onPressed: () {
                  showDialog(context: context, builder: (context) => const MeetProposalScreen());
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A65), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('만남 제안', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          if (!widget.isGroup)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  '$_timeLeft / 10:00',
                  style: const TextStyle(color: Color(0xFFFF8A65), fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSystemMessage('10분 익명 대화가 시작되었습니다\n취향과 모임의 주제를 편하게 이야기해보세요.'),
                const SizedBox(height: 16),
                _buildChatBubble(isMe: false, message: '안녕하세요! 취향 태그 보고 말걸어봤어요 ㅎㅎ'),
                const SizedBox(height: 8),
                _buildChatBubble(isMe: true, message: '안녕하세요 반갑습니다!ㅎㅎ\n커피 좋아하시나봐요'),
                const SizedBox(height: 8),
                _buildChatBubble(isMe: false, message: '네 완전 좋아해요! 주말마다 카페 투어 다니거든요'),
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
