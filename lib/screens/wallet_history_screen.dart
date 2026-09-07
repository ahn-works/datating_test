import 'package:flutter/material.dart';

class WalletHistoryScreen extends StatelessWidget {
  const WalletHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('보증금 지갑 내역', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFFFFF0EC), borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                const Text('현재 보유 보증금', style: TextStyle(color: Colors.black54, fontSize: 16)),
                const SizedBox(height: 8),
                const Text('10,000 원', style: TextStyle(color: Color(0xFFFF8A65), fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: (){}, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8A65), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ), 
                  child: const Text('출금하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('결제 및 환불 내역', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildHistoryTile('환불 완료 (성수 하이볼 팟)', '+10,000원', '2023.10.25', Colors.green),
          const Divider(height: 24, color: Color(0xFFEEEEEE)),
          _buildHistoryTile('보증금 결제 (성수 하이볼 팟)', '-10,000원', '2023.10.24', Colors.black87),
          const Divider(height: 24, color: Color(0xFFEEEEEE)),
          _buildHistoryTile('환불 완료 (1:1 익명 대화)', '+10,000원', '2023.10.20', Colors.green),
          const Divider(height: 24, color: Color(0xFFEEEEEE)),
          _buildHistoryTile('보증금 결제 (1:1 익명 대화)', '-10,000원', '2023.10.19', Colors.black87),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(String title, String amount, String date, Color amountColor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ),
      trailing: Text(amount, style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
