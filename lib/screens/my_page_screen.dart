import 'package:flutter/material.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('MY', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(radius: 48, backgroundColor: Color(0xFFFF3B30), child: Icon(Icons.person, size: 48, color: Colors.white)),
          const SizedBox(height: 16),
          const Center(child: Text('안싼향', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          const Center(child: Text('26세 · 광주', style: TextStyle(color: Colors.grey))),
          const SizedBox(height: 32),
          _menuItem(Icons.history, '여행 내역'),
          _menuItem(Icons.account_balance_wallet, '지갑 / 비용'),
          _menuItem(Icons.star, '리뷰 내역'),
          _menuItem(Icons.settings, '설정'),
        ],
      ),
    );
  }

  static Widget _menuItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFF3B30)),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
