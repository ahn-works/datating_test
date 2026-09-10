import 'package:flutter/material.dart';
class WalletHistoryScreen extends StatelessWidget {
  const WalletHistoryScreen({super.key});
  final _items = const [
    ['목포 당일치기 노쇼 보증금 환불', '+20,000원', '2026.10.15'],
    ['목포 당일치기 참가비 결제', '-50,000원', '2026.10.12']
  ];
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(title: const Text('결제 내역', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
    body: Column(children: [
      Container(padding: const EdgeInsets.all(24), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('정산 예정', style: TextStyle(color: Colors.grey)), const Text('20,000원', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFF3B30)))])),
      const Divider(height: 1),
      Expanded(child: ListView.separated(padding: const EdgeInsets.all(16), itemCount: _items.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (_, i) => ListTile(title: Text(_items[i][0], style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(_items[i][2], style: const TextStyle(color: Colors.grey, fontSize: 13)), trailing: Text(_items[i][1], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _items[i][1].startsWith('+') ? const Color(0xFF4CAF50) : Colors.black)))))
    ])
  );
}
