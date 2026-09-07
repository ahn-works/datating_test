import 'package:flutter/material.dart';
import 'chat_room_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('진행 중인 시그널', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('1:1 익명 대화'),
          _buildChatTile(
            context: context,
            name: '익명의 누군가',
            message: '안녕하세요! 취향 태그 보고 말 걸어봤어요. 😊',
            isGroup: false,
            trailingText: '05:23 남음',
            trailingColor: Colors.redAccent,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('시그널 하우스 단톡방'),
          _buildChatTile(
            context: context,
            name: '시그널 하우스 3기 (4:4)',
            message: '오늘의 미션: 가장 좋아하는 음악 공유 완료!',
            isGroup: true,
            trailingText: '미션 달성률 80%',
            trailingColor: Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildChatTile({
    required BuildContext context,
    required String name,
    required String message,
    required bool isGroup,
    required String trailingText,
    required Color trailingColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        onTap: () {
          // 채팅 타일을 누르면 해당 채팅방 내부로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(title: name, isGroup: isGroup),
            ),
          );
        },
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: isGroup ? const Color(0xFFFFF0EC) : Colors.grey[300],
          child: Icon(
            isGroup ? Icons.home_rounded : Icons.person,
            color: isGroup ? const Color(0xFFFF8A65) : Colors.white,
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(message, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: trailingColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                trailingText,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: trailingColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
