import 'package:flutter/material.dart';
import 'party_detail_screen.dart'; 
import 'party_host_screen.dart';

class PartyScreen extends StatefulWidget { 
  const PartyScreen({super.key}); 
  @override State<PartyScreen> createState() => _PartyScreenState(); 
}

class _PartyScreenState extends State<PartyScreen> {
  int _selectedFilter = 0;
  final _filters = ['전체', '🚗 카풀/드라이브', '✈️ 해외여행', '🏖️ 국내여행', '🏕️ 캠핑/차박'];

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F9FA), 
    appBar: AppBar(
      title: const Text('여행·모임 찾기', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.5)), 
      backgroundColor: Colors.white, 
      elevation: 0, 
      actions: [IconButton(icon: const Icon(Icons.add_box_outlined, color: Colors.black, size: 28), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PartyHostScreen())))]
    ), 
    body: Column(
      children: [
        Container(
          color: Colors.white, 
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12), 
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Colors.grey), 
              hintText: '지역명 / 캠핑, 서핑, 드라이브 등 키워드', 
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 15), 
              filled: true, 
              fillColor: Colors.grey.shade100, 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), 
              contentPadding: const EdgeInsets.symmetric(vertical: 16)
            )
          )
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(bottom: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(_filters.length, (i) => GestureDetector(
                onTap: () => setState(() => _selectedFilter = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _selectedFilter == i ? Colors.black : Colors.white,
                    border: Border.all(color: _selectedFilter == i ? Colors.black : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_filters[i], style: TextStyle(color: _selectedFilter == i ? Colors.white : Colors.black87, fontWeight: _selectedFilter == i ? FontWeight.bold : FontWeight.w600, fontSize: 14)),
                )
              ))
            )
          )
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), 
            children: [
              _premiumCard(context, '이번 주말 양양 카풀 서핑 🚙 (제 차로 편하게 가요!)', '여 1/남 1 (여성 1명 급구)', '양양/강릉', '26.09.19 - 26.09.20 (1박 2일)', ['#카풀', '#서핑', '#2030'], '스윗드라이버', '30대 · 남성', true, 'https://picsum.photos/400?random=20'), 
              const SizedBox(height: 20),
              _premiumCard(context, '제주도 풀빌라 2:2 남녀 짝맞춰서 가실분!', '여 2/남 1 (남자 1명 급구)', '제주도', '26.09.25 - 26.09.27 (2박 3일)', ['#23~34세', '#소개팅', '#풀빌라'], '화려한윌리59', '20대 · 여성', true, 'https://picsum.photos/400?random=11'), 
              const SizedBox(height: 20),
              _premiumCard(context, '서울 근교 남양주 카페 드라이브 번개 ☕️', '여 1/남 2 (여성 1명 모집)', '남양주', '26.09.16 (당일치기)', ['#드라이브', '#카페투어', '#저녁벙'], '커피매니아', '20대 · 남성', false, 'https://picsum.photos/400?random=21'), 
              const SizedBox(height: 20),
              _premiumCard(context, '오사카 식도락 3:3 미팅 하실분 구해요', '여 3/남 3 (마감완료)', '오사카', '26.10.12 - 26.10.15 (3박 4일)', ['#맛집탐방', '#미팅', '#해외여행'], '타코야끼', '30대 · 여성', false, 'https://picsum.photos/400?random=13'), 
              const SizedBox(height: 40),
            ]
          )
        )
      ]
    )
  );

  Widget _premiumCard(BuildContext ctx, String title, String status, String loc, String date, List<String> tags, String author, String authorInfo, bool isUrgent, String img) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))]), child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(24), onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const PartyDetailScreen())), child: Padding(padding: const EdgeInsets.all(20), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 8, runSpacing: 8, children: tags.map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFE8F5E9).withOpacity(0.7), borderRadius: BorderRadius.circular(10)), child: Text(t, style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.w700)))).toList()), const SizedBox(height: 12),
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.4, letterSpacing: -0.5), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 10),
      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: isUrgent ? const Color(0xFFFF3B30).withOpacity(0.08) : Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: Text(status, style: TextStyle(color: isUrgent ? const Color(0xFFFF3B30) : Colors.grey.shade700, fontWeight: FontWeight.w700, fontSize: 13))), const SizedBox(height: 16),
      Row(children: [const CircleAvatar(radius: 10, backgroundColor: Color(0xFFFF3B30), child: Icon(Icons.person, size: 12, color: Colors.white)), const SizedBox(width: 8), Text(' · ', style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500)), const SizedBox(width: 4), const Icon(Icons.verified, size: 14, color: Colors.green)]), const SizedBox(height: 8),
      Row(children: [Icon(Icons.calendar_month_rounded, size: 16, color: Colors.grey.shade400), const SizedBox(width: 8), Text(date, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500))]),
    ])), const SizedBox(width: 20),
    Column(children: [ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(img, width: 100, height: 120, fit: BoxFit.cover)), const SizedBox(height: 10), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.location_on, color: Colors.white, size: 12), const SizedBox(width: 4), Text(loc, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))]))])
  ])))));
}