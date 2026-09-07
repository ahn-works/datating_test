import 'package:flutter/material.dart';
import 'travel_gps_checkin_screen.dart';

class TravelPaymentScreen extends StatelessWidget {
  const TravelPaymentScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('결제 및 참가 확정', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('[목폼] 낙만포차와 당일치기', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          _row('여행 참가비', '30,000원'),
          const SizedBox(height: 12),
          _row('노쉬 보증금 (환불예정)', '20,000원', red: true),
          const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider()),
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('성 결제 금액', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('50,000원', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFF3B30))),
          ]),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: const Row(children: [Icon(Icons.info_outline, color: Colors.grey), SizedBox(width: 12), Expanded(child: Text('현장 체크인 시 보증금 2만원이 즉시 환불됩니다.', style: TextStyle(fontSize: 13, height: 1.4)))]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TravelGpsCheckinScreen())),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Text('토스페이 / 카카오페이 결제하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ]),
      ),
    );
  }
  Widget _row(String l, String p, {bool red = false}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(l, style: TextStyle(fontSize: 16, color: red ? const Color(0xFFFF3B30) : Colors.black87, fontWeight: red ? FontWeight.bold : FontWeight.normal)),
    Text(p, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: red ? const Color(0xFFFF3B30) : Colors.black)),
  ]);
}
