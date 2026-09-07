import 'package:flutter/material.dart';
import 'travel_payment_screen.dart';

class PartyScreen extends StatefulWidget {
  const PartyScreen({super.key});
  @override
  State<PartyScreen> createState() => _PartyScreenState();
}

class _PartyScreenState extends State<PartyScreen> {
  final List<String> regions = ['전체', '광주', '목포', '전주', '여수'];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('여행 모집', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(children: [
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: regions.length,
            itemBuilder: (ctx, i) {
              final sel = selectedIndex == i;
              return GestureDetector(
                onTap: () => setState(() => selectedIndex = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: sel ? Colors.black : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(regions[i], style: TextStyle(color: sel ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _card(context, '[목포] 낙만포차 당일치기', '2026.10.15 (토)', '광주 유스쿨어', 3, 4, 4, 4, true),
              const SizedBox(height: 16),
              _card(context, '[여수] 밤바다 요트 투어', '2026.10.22 (토)', '순천역', 1, 4, 2, 4, false),
            ],
          ),
        )
      ]),
    );
  }

  Widget _card(BuildContext ctx, String title, String date, String dep, int mc, int mm, int fc, int fm, bool closed) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(date + ' | ' + dep, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 16),
            Row(children: [const Text('남성', style: TextStyle(fontSize: 13, color: Colors.blue)), const SizedBox(width: 8), Expanded(child: LinearProgressIndicator(value: mc/mm, backgroundColor: Colors.grey.shade200, color: Colors.blue, minHeight: 8, borderRadius: BorderRadius.circular(4))), const SizedBox(width: 8), Text('$mc/$mm', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 8),
            Row(children: [const Text('여성', style: TextStyle(fontSize: 13, color: Color(0xFFFF3B30))), const SizedBox(width: 8), Expanded(child: LinearProgressIndicator(value: fc/fm, backgroundColor: Colors.grey.shade200, color: const Color(0xFFFF3B30), minHeight: 8, borderRadius: BorderRadius.circular(4))), const SizedBox(width: 8), Text('$fc/$fm', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: closed ? const Color(0xFFFF3B30) : Colors.black))]),
            if (closed) const Align(alignment: Alignment.centerRight, child: Text('* 여성 마감', style: TextStyle(color: Color(0xFFFF3B30), fontSize: 11, fontWeight: FontWeight.bold))),
          ]),
        ),
        InkWell(
          onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const TravelPaymentScreen())),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(color: Color(0xFFFF3B30), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))),
            alignment: Alignment.center,
            child: const Text('상세보기 및 신청하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        )
      ]),
    );
  }
}
