import 'package:flutter/material.dart';
import 'party_detail_screen.dart'; import 'party_host_screen.dart';
class PartyScreen extends StatelessWidget { const PartyScreen({super.key}); @override Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.white, appBar: AppBar(title: const Text('여행·소개팅 모임', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)), backgroundColor: Colors.white, elevation: 0, actions: [IconButton(icon: const Icon(Icons.add_box_outlined, color: Colors.black), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PartyHostScreen())))]), body: Column(children: [
  Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search, color: Colors.grey), hintText: '전 세계 / 지역, 일정, 연령대 키워드 입력', hintStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 14)))),
  Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
    _tripCard(context, '제주도 풀빌라 2:2 남녀 짝맞춰서 가실분!', '여 2/남 1 (남자 1명 급구)', '제주도', '26.09.10 - 26.09.12 (2일)', ['#23~34세', '#소개팅', '#풀빌라'], '화려한윌리59', '20대 · 여성', true, 'https://picsum.photos/200?random=11'), const Divider(height: 32),
    _tripCard(context, '도교 벚꽃여행 부분동행 또는 야간 펍 가실분', '남 2/여 1 (여성 1명 추가모집)', '도쿄', '26.09.18 - 26.09.21 (3일)', ['#2030', '#야간펍', '#동행'], 'JaySeo', '30대 · 남성', true, 'https://picsum.photos/200?random=12'), const Divider(height: 32),
    _tripCard(context, '부산 해운대 요트투어 3:3 미팅 하실분 구해요', '남 3/여 3 (모집완료)', '부산', '26.09.22 - 26.09.23 (1일)', ['#20대초반', '#요트미팅', '#파티'], '바다요정', '20대 · 여성', false, 'https://picsum.photos/200?random=13'),
  ]))
]));
  Widget _tripCard(BuildContext ctx, String title, String status, String loc, String date, List<String> tags, String author, String authorInfo, bool isUrgent, String img) => InkWell(onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const PartyDetailScreen())), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 6, runSpacing: 6, children: tags.map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)), child: Text(t, style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 11, fontWeight: FontWeight.bold)))).toList()), const SizedBox(height: 8),
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 6),
      Row(children: [Text(status, style: TextStyle(color: isUrgent ? const Color(0xFFFF3B30) : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13))]), const SizedBox(height: 12),
      Row(children: [const Icon(Icons.person_pin, size: 14, color: Colors.grey), const SizedBox(width: 4), Text('$author · $authorInfo', style: const TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(width: 4), const Icon(Icons.verified, size: 14, color: Colors.green)]), const SizedBox(height: 4),
      Row(children: [const Icon(Icons.calendar_today, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12))]),
    ])), const SizedBox(width: 16),
    Column(children: [ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(img, width: 80, height: 80, fit: BoxFit.cover)), const SizedBox(height: 6), Text(loc, style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 13))])
  ]));
}
