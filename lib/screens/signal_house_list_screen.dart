
import 'package:flutter/material.dart';
import 'signal_group_chat_screen.dart';

class SignalHouseListScreen extends StatelessWidget {
  const SignalHouseListScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(title: const Text('시그널 하우스', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0),
    body: ListView.builder(padding: const EdgeInsets.all(16), itemCount: 3, itemBuilder: (_, i) {
      final rooms = [['목포 낙만 투어 하우스', '2026.10.15 | 8명'], ['여수 밤바다 하우스', '2026.10.22 | 6명'], ['전주 릹가 투어 하우스', '2026.11.01 | 8명']];
      return GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignalGroupChatScreen())),
        child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFFF3B30).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.home, color: Color(0xFFFF3B30))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(rooms[i][0], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(rooms[i][1], style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ])),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ]),
        ),
      );
    }),
  );
}
