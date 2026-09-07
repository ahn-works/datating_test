import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import 'chat_room_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('대화', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.separated(
        itemCount: DummyData.chats.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF5F5F5)),
        itemBuilder: (context, index) {
          final chat = DummyData.chats[index];
          final hasProfile = chat['profileUrl'] != null;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[200],
              backgroundImage: hasProfile ? NetworkImage(chat['profileUrl']) : null,
              child: !hasProfile ? const Icon(Icons.person_search, color: Colors.grey) : null,
            ),
            title: Text(chat['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(chat['lastMessage'], style: const TextStyle(color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(chat['time'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 6),
                if (chat['unread'] > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Color(0xFFFF8A65), shape: BoxShape.circle),
                    child: Text('${chat['unread']}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoomScreen(title: chat['name'])));
            },
          );
        },
      ),
    );
  }
}
