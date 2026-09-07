import 'package:flutter/material.dart';

class ChatSettingsModal extends StatelessWidget {
  const ChatSettingsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 40),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          ListTile(leading: const Icon(Icons.notifications_off_outlined), title: const Text('채팅방 알림 끄기'), onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.report_gmailerrorred, color: Colors.red), title: const Text('신고하기', style: TextStyle(color: Colors.red)), onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.exit_to_app, color: Colors.red), title: const Text('채팅방 나가기', style: TextStyle(color: Colors.red)), onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
