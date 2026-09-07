import 'package:flutter/material.dart';
import '../data/dummy_data.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('알림', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.separated(
        itemCount: DummyData.notifications.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
        itemBuilder: (context, index) {
          final noti = DummyData.notifications[index];
          final isRead = noti['isRead'];
          return Container(
            color: isRead ? Colors.white : const Color(0xFFFFF0EC).withOpacity(0.5),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              leading: CircleAvatar(
                backgroundColor: isRead ? Colors.grey[200] : const Color(0xFFFF8A65),
                child: Icon(
                  noti['title'].contains('보증금') ? Icons.payments : Icons.notifications,
                  color: isRead ? Colors.grey : Colors.white,
                ),
              ),
              title: Text(noti['title'], style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(noti['body'], style: const TextStyle(color: Colors.black87)),
              ),
              trailing: Text(noti['time'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          );
        },
      ),
    );
  }
}
