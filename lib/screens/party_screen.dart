import 'package:flutter/material.dart';
import 'party_detail_screen.dart'; 
import 'party_host_screen.dart';
import 'neighborhood_crew_screen.dart';

class PartyScreen extends StatefulWidget { 
  const PartyScreen({super.key}); 
  @override State<PartyScreen> createState() => _PartyScreenState(); 
}

class _PartyScreenState extends State<PartyScreen> {
  int _selectedFilter = 0;
  final _filters = ['전체', '🚗 카풀/드라이브', '✈️ 해외여행', '🎒 배낭여행', '🏖️ 호캉스', '🏕️ 캠핑/차박'];

  final List<Map<String, dynamic>> _allParties = [
    {
      'category': '🚗 카풀/드라이브',
      'title': '이번 주말 양양 카풀 서핑 🚙 (제 차로 편하게 가요!)',
      'status': '여1/남1 (여성 1명 급구)',
      'loc': '양양/강릉',
      'date': '26.09.19 - 26.09.20 (1박2일)',
      'tags': ['#카풀', '#서핑', '#2030'],
      'author': '스윗드라이버',
      'authorInfo': '30대 · 남성',
      'isUrgent': true,
      'img': 'https://picsum.photos/400?random=20'
    },
    {
      'category': '🏖️ 호캉스',
      'title': '제주도 풀빌라 2:2 여행 짝맞춰서 가실분!',
      'status': '여2/남1 (남자 1명 급구)',
      'loc': '제주도',
      'date': '26.09.25 - 26.09.27 (2박3일)',
      'tags': ['#23~34세', '#소개팅', '#풀빌라'],
      'author': '올려치기99',
      'authorInfo': '20대 · 여성',
      'isUrgent': true,
      'img': 'https://picsum.photos/400?random=11'
    },
    {
      'category': '🚗 카풀/드라이브',
      'title': '서울 근교 남양주 카페 드라이브 번개 ☕️',
      'status': '남1/여2 (남성 1명 모집)',
      'loc': '남양주',
      'date': '26.09.16 (당일치기)',
      'tags': ['#드라이브', '#카페투어', '#친목벙'],
      'author': '커피매니아',
      'authorInfo': '20대 · 남성',
      'isUrgent': false,
      'img': 'https://picsum.photos/400?random=21'
    },
    {
      'category': '✈️ 해외여행',
      'title': '오사카 식도락 3:3 미팅 현실판 구해요',
      'status': '여3/남3 (마감완료)',
      'loc': '오사카',
      'date': '26.10.12 - 26.10.15 (3박4일)',
      'tags': ['#맛집탐방', '#미팅', '#해외여행'],
      'author': '타코야끼',
      'authorInfo': '30대 · 여성',
      'isUrgent': false,
      'img': 'https://picsum.photos/400?random=13'
    },
    {
      'category': '🏕️ 캠핑/차박',
      'title': '가평 글램핑 불멍하러 가실 분~',
      'status': '여1/남1 (모집중)',
      'loc': '가평',
      'date': '26.10.05 - 26.10.06 (1박2일)',
      'tags': ['#글램핑', '#불멍', '#바베큐'],
      'author': '캠핑러버',
      'authorInfo': '20대 · 남성',
      'isUrgent': false,
      'img': 'https://picsum.photos/400?random=15'
    }
  ];

  @override Widget build(BuildContext context) {
    List<Map<String, dynamic>> displayedParties = _allParties;
    if (_selectedFilter != 0) {
      String filterName = _filters[_selectedFilter];
      displayedParties = _allParties.where((p) => p['category'] == filterName).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      appBar: AppBar(
        title: const Text('여행·모임 찾기', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.5)), 
        backgroundColor: Colors.white, 
        elevation: 0, 
        actions: [
          IconButton(icon: const Icon(Icons.people_alt, color: Color(0xFFFF3B30), size: 28), tooltip: '단골 크루', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NeighborhoodCrewScreen()))),
          IconButton(icon: const Icon(Icons.add_box_outlined, color: Colors.black, size: 28), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PartyHostScreen())))
        ]
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
            child: displayedParties.isEmpty 
              ? Center(child: Text('해당 카테고리의 모임이 없습니다.', style: TextStyle(color: Colors.grey.shade600)))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), 
                  itemCount: displayedParties.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (ctx, i) {
                    final p = displayedParties[i];
                    return _premiumCard(context, p['title'], p['status'], p['loc'], p['date'], p['tags'], p['author'], p['authorInfo'], p['isUrgent'], p['img']);
                  }
                )
          )
        ]
      )
    );
  }

  Widget _premiumCard(BuildContext ctx, String title, String status, String loc, String date, List<String> tags, String author, String authorInfo, bool isUrgent, String img) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))]), child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(24), onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const PartyDetailScreen())), child: Padding(padding: const EdgeInsets.all(20), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 8, runSpacing: 8, children: tags.map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFE8F5E9).withOpacity(0.7), borderRadius: BorderRadius.circular(10)), child: Text(t, style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.w700)))).toList()), const SizedBox(height: 12),
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.4, letterSpacing: -0.5), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 10),
      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: isUrgent ? const Color(0xFFFF3B30).withOpacity(0.08) : Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: Text(status, style: TextStyle(color: isUrgent ? const Color(0xFFFF3B30) : Colors.grey.shade700, fontWeight: FontWeight.w700, fontSize: 13))), const SizedBox(height: 16),
      Row(children: [CircleAvatar(radius: 10, backgroundColor: Colors.grey.shade200, child: const Icon(Icons.person, size: 12, color: Colors.grey)), const SizedBox(width: 8), Text(author, style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)), Text(' · ', style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500)), Text(authorInfo, style: TextStyle(color: Colors.grey.shade600, fontSize: 12))]), const SizedBox(height: 8),
      Row(children: [Icon(Icons.calendar_month_rounded, size: 16, color: Colors.grey.shade400), const SizedBox(width: 8), Text(date, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500))]),
    ])), const SizedBox(width: 20),
    Column(children: [ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(img, width: 100, height: 120, fit: BoxFit.cover)), const SizedBox(height: 10), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.location_on, color: Colors.white, size: 12), const SizedBox(width: 4), Text(loc, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))]))])
  ])))));
}
