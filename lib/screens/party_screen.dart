import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'party_detail_screen.dart'; 
import 'party_host_screen.dart';
import 'neighborhood_crew_screen.dart';

class PartyScreen extends StatefulWidget { 
  const PartyScreen({super.key}); 
  @override 
  State<PartyScreen> createState() => _PartyScreenState(); 
}

class _PartyScreenState extends State<PartyScreen> {
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();

  // OOMU 표준 카테고리 체계 준수
  final List<String> _filters = [
    '전체',
    '⚡ 오늘 번개',
    '☕ 취향 아지트',
    '🏃‍♂️ 라이프 메이트',
    '🚗 드라이브',
    '🏕️ 동성 캠핑'
  ];

  final List<Map<String, dynamic>> _allParties = [
    {
      'id': 'meetup_1',
      'category': '⚡ 오늘 번개',
      'title': '이번 주말 양양 드라이브 서핑 🚙 (제 차로 편하게 가요!)',
      'status': '1자리 남음',
      'loc': '강원 양양군 / 잠실역 집결',
      'date': '9.19 (토) 08:00',
      'tags': ['#드라이브', '#서핑', '#30대직장인'],
      'author': '스윗드라이버',
      'authorInfo': '30대 · 남성 · 베스트드라이버',
      'mannerTemp': '42.1°C',
      'currentMembers': 3,
      'maxMembers': 4,
      'isUrgent': true,
      'img': 'https://picsum.photos/400?random=20'
    },
    {
      'id': 'meetup_2',
      'category': '☕ 취향 아지트',
      'title': '성수동 에스프레소 바 투어 & 북토크 ☕️',
      'status': '여성 안심',
      'loc': '서울 성동구 성수동',
      'date': '9.17 (목) 19:30',
      'tags': ['#카페투어', '#책과커피', '#퇴근길'],
      'author': '북앤커피',
      'authorInfo': '30대 · 여성 · 에디터',
      'mannerTemp': '39.5°C',
      'currentMembers': 2,
      'maxMembers': 4,
      'isUrgent': false,
      'img': 'https://picsum.photos/400?random=21'
    },
    {
      'id': 'meetup_3',
      'category': '🏃‍♂️ 라이프 메이트',
      'title': '한강 반포 달빛러닝 5K (페이스 630 함께 뛰어요)',
      'status': '모집 중',
      'loc': '서울 서초구 반포한강공원',
      'date': '9.18 (금) 20:00',
      'tags': ['#러닝크루', '#초보환영', '#퇴근런'],
      'author': '러너스하이',
      'authorInfo': '30대 · 남성 · 마라토너',
      'mannerTemp': '41.0°C',
      'currentMembers': 4,
      'maxMembers': 6,
      'isUrgent': false,
      'img': 'https://picsum.photos/400?random=15'
    },
    {
      'id': 'meetup_4',
      'category': '☕ 취향 아지트',
      'title': '을지로 LP바에서 재즈 들으며 가볍게 한잔 🎷',
      'status': '마감 임박',
      'loc': '서울 중구 을지로3가',
      'date': '9.20 (일) 18:00',
      'tags': ['#LP바', '#재즈', '#불토친목'],
      'author': '재즈매니아',
      'authorInfo': '30대 · 여성 · 기획자',
      'mannerTemp': '38.8°C',
      'currentMembers': 3,
      'maxMembers': 4,
      'isUrgent': true,
      'img': 'https://picsum.photos/400?random=13'
    },
    {
      'id': 'meetup_5',
      'category': '🏕️ 동성 캠핑',
      'title': '가평 숲속 글램핑 불멍 & 바베큐 힐링 🏕️',
      'status': '동성 전용',
      'loc': '경기 가평군 청평면',
      'date': '10.05 (토) 13:00',
      'tags': ['#글램핑', '#불멍', '#주말힐링'],
      'author': '감성캠퍼',
      'authorInfo': '30대 · 남성 · 캠퍼',
      'mannerTemp': '37.9°C',
      'currentMembers': 2,
      'maxMembers': 4,
      'isUrgent': false,
      'img': 'https://picsum.photos/400?random=18'
    }
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override 
  Widget build(BuildContext context) {
    String query = _searchController.text.trim().toLowerCase();
    List<Map<String, dynamic>> displayedParties = _allParties.where((p) {
      if (_selectedFilter != 0) {
        String filterName = _filters[_selectedFilter];
        if (p['category'] != filterName) return false;
      }
      if (query.isNotEmpty) {
        final title = (p['title'] as String).toLowerCase();
        final loc = (p['loc'] as String).toLowerCase();
        final tags = (p['tags'] as List<String>).join(' ').toLowerCase();
        if (!title.contains(query) && !loc.contains(query) && !tags.contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F7), // OOMU 오트밀 로즈 크림
      appBar: AppBar(
        title: const Text(
          '동네 모임 & 번개',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ), 
        backgroundColor: Colors.white, 
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline_rounded, color: Color(0xFFFF6B4A), size: 26), 
            tooltip: '단골 크루', 
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NeighborhoodCrewScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF0F172A), size: 26), 
            tooltip: '모임 만들기',
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PartyHostScreen()));
            },
          ),
          const SizedBox(width: 4),
        ],
      ), 
      body: Column(
        children: [
          // 1. 검색창 (TDS 스타일 미니멀 폼)
          Container(
            color: Colors.white, 
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12), 
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)), 
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: Color(0xFF94A3B8), size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                hintText: '동네명, 취향 키워드 검색 (서핑, LP바, 러닝 등)', 
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14), 
                filled: true, 
                fillColor: const Color(0xFFF1F5F9), 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), 
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // 2. 카테고리 칩 목록
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(_filters.length, (i) {
                  final isSelected = _selectedFilter == i;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedFilter = i);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _filters[i],
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // 3. 모임 리스트 (당근마켓 스타일 88x88 정방형 피드 & 1/N 안심 정산 뱃지)
          Expanded(
            child: displayedParties.isEmpty 
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF4EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.explore_off_rounded, color: Color(0xFFFF6B4A), size: 40),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '해당 조건의 모임이 아직 없어요',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '직접 첫 번째 아지트 모임을 열고\n마음 맞는 30대 동네 친구를 찾아보세요!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PartyHostScreen())),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('모임 직접 개설하기', style: TextStyle(fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B4A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), 
                  itemCount: displayedParties.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final p = displayedParties[i];
                    return _hyperlocalMeetupCard(context, p);
                  },
                ),
          ),
        ],
      ),
    );
  }

  // 당근마켓/문토 하이퍼로컬 표준 88x88 정방형 피드 카드
  Widget _hyperlocalMeetupCard(BuildContext ctx, Map<String, dynamic> party) {
    final title = party['title'] as String;
    final status = party['status'] as String;
    final loc = party['loc'] as String;
    final date = party['date'] as String;
    final author = party['author'] as String;
    final mannerTemp = party['mannerTemp'] as String;
    final currentMembers = party['currentMembers'] as int;
    final maxMembers = party['maxMembers'] as int;
    final isUrgent = party['isUrgent'] as bool;
    final img = party['img'] as String;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEFF1F5), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => PartyDetailScreen(partyData: party)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 좌측: 88x88 정방형 썸네일 (Karrot-Hyperlocal-Feed 규격)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    img,
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 88,
                      height: 88,
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(Icons.image_not_supported_rounded, color: Color(0xFF94A3B8), size: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // 우측: 태그, 2줄 말줄임 제목, 일정, 참여자 수, 1/N 안심 정산 뱃지
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 상단 뱃지 행 (긴급/여성안심 + 1/N 안심 정산)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: isUrgent ? const Color(0xFFFFF1F2) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: isUrgent ? const Color(0xFFE11D48) : const Color(0xFF475569),
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4EB),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '1/N 안심 정산',
                              style: TextStyle(
                                color: Color(0xFFFF6B4A),
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // 제목: 2줄 말줄임 (TextOverflow.ellipsis)
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // 위치 및 일시
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 13, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              loc,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            date,
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // 하단: 호스트 매너온도 및 참여 인원수 (예: 3/4명)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                author,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                mannerTemp,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFFF6B4A)),
                              ),
                            ],
                          ),
                          Text(
                            '$currentMembers/$maxMembers명 참여',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
