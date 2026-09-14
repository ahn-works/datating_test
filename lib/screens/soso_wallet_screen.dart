import 'package:flutter/material.dart';

class SosoWalletScreen extends StatelessWidget {
  const SosoWalletScreen({super.key});
  
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F9FA),
    appBar: AppBar(title: const Text('소소카 정산 지갑', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF3B30), Color(0xFFFF7A00)]), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: const Color(0xFFFF3B30).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('나의 소소카 포인트', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              const Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [Text('25,400', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)), SizedBox(width: 4), Text('P', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: ElevatedButton.icon(onPressed: (){}, icon: const Icon(Icons.local_cafe, color: Color(0xFFFF3B30), size: 18), label: const Text('쿠폰 교환', style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton.icon(onPressed: (){}, icon: const Icon(Icons.account_balance, color: Colors.white, size: 18), label: const Text('계좌 송금', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))))
                ]
              )
            ]
          )
        ),
        const SizedBox(height: 32),
        const Text('카풀 간편 정산기 (1/N)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('총 주행 거리', style: TextStyle(color: Colors.grey)), Text('약 45 km', style: TextStyle(fontWeight: FontWeight.bold))]),
              const SizedBox(height: 12),
              const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('예상 유류비 (연비 12km/L)', style: TextStyle(color: Colors.grey)), Text('약 6,500 원', style: TextStyle(fontWeight: FontWeight.bold))]),
              const SizedBox(height: 12),
              const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('예상 톨게이트비', style: TextStyle(color: Colors.grey)), Text('2,400 원', style: TextStyle(fontWeight: FontWeight.bold))]),
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
              const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('총 발생 비용', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text('8,900 원', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFFF3B30)))]),
              const SizedBox(height: 8),
              const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('인원 (운전자 포함)', style: TextStyle(color: Colors.grey)), Text('3 명', style: TextStyle(fontWeight: FontWeight.bold))]),
              const SizedBox(height: 24),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(12)), child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('1인당 정산 금액', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text('2,960 원', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20))])),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: (){}, icon: const Icon(Icons.send, color: Colors.black87), label: const Text('카카오페이 1/N 링크 공유', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFEE500), minimumSize: const Size(double.infinity, 56), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))))
            ]
          )
        ),
        const SizedBox(height: 32),
        const Text('최근 정산 내역', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        _historyItem('양양 카풀 서핑 🚙', '완료 (1/N 입금됨)', '+ 12,000 P', '9. 12', true),
        _historyItem('남양주 카페 드라이브', '톨비 정산 (하이패스 연동)', '- 3,200 P', '9. 10', false),
      ]
    )
  );

  Widget _historyItem(String title, String sub, String amount, String date, bool isPlus) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: isPlus ? Colors.green.shade50 : Colors.red.shade50, shape: BoxShape.circle), child: Icon(isPlus ? Icons.arrow_downward : Icons.arrow_upward, color: isPlus ? Colors.green : Colors.red, size: 20)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), const SizedBox(height: 4), Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12))])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isPlus ? Colors.green : Colors.black87)), const SizedBox(height: 4), Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12))])
      ]
    )
  );
}