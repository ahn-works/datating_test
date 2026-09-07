import 'package:flutter/material.dart';

class SignalGroupChatScreen extends StatelessWidget {
  const SignalGroupChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(title: const Text('시그널 하우스 4기 (익명)', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 1, iconTheme: const IconThemeData(color: Colors.black)),
      body: Column(
        children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), color: const Color(0xFFFFF0EC), child: const Row(children: [Icon(Icons.campaign, color: Color(0xFFFF8A65)), SizedBox(width: 8), Expanded(child: Text('오늘 자정, 첫 번째 호감도 투표가 열립니다!', style: TextStyle(color: Color(0xFFFF8A65), fontWeight: FontWeight.bold)))])),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMessage('남자 1호', '다들 퇴근하셨나요? 오늘 날씨 좋네요 ㅎㅎ', false),
                const SizedBox(height: 12),
                _buildMessage('여자 3호', '네 방금 퇴근했습니다~', false),
                const SizedBox(height: 12),
                _buildMessage('나 (남자 2호)', '저녁 뭐 드시나요 다들?', true),
              ],
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildMessage(String sender, String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(sender, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: isMe ? const Color(0xFFFF8A65) : Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
          )
        ],
      )
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: SafeArea(child: Row(children: [Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)), child: const TextField(decoration: InputDecoration(hintText: '메시지 입력...', border: InputBorder.none)))), const SizedBox(width: 8), const CircleAvatar(backgroundColor: Color(0xFFFF8A65), child: Icon(Icons.send, color: Colors.white, size: 20))])),
    );
  }
}
