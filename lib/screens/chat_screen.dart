import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('채팅', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, i) {
          final names = ['지은', '민서', '유스', '하나', '언니'];
          final msgs = ['오늘 여행 언제에요?', '냔일 끈 등산 가고 싶이!', '계획저 보내드릴게요', '좋아요!! 함께 가요', '다음 여행은 언제죣?'];
          return ListTile(
            leading: CircleAvatar(backgroundColor: const Color(0xFFFF3B30).withOpacity(0.1 * (i + 1)), child: Text(names[i][0], style: const TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold))),
            title: Text(names[i], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(msgs[i], overflow: TextOverflow.ellipsis),
            trailing: const Text('오전', style: TextStyle(color: Colors.grey, fontSize: 12)),
          );
        },
      ),
    );
  }
}
