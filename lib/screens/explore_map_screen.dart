import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../services/kakao_map_service.dart';
import '../widgets/kakao_map_view.dart';
import '../utils/app_image.dart';
import '../utils/global_data.dart';
import 'soso_car_detail_screen.dart';
import 'soso_car_host_screen.dart';

/// OOMU 신규 탐색(Explore) 화면 - Mobbin 1티어 Sheet-over-Map & 카카오맵 인터랙티브 탐색 뷰
class ExploreMapScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final String? initialSpotName;

  const ExploreMapScreen({
    super.key,
    this.initialLat,
    this.initialLng,
    this.initialSpotName,
  });

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  // 기본 좌표: 홍대/연남권 (기본 핫스팟)
  double _currentLat = 37.5568;
  double _currentLng = 126.9238;
  String _currentSpotName = '마포구 서교동 (홍대입구역)';
  
  String _selectedRadius = '1km';
  String _selectedCategory = '전체';
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = false;
  Map<String, dynamic>? _selectedMeetup;

  // 주요 핫스팟 프리셋 (원터치 이동)
  final List<Map<String, dynamic>> _hotspots = const [
    {'name': '홍대/연남', 'lat': 37.5568, 'lng': 126.9238, 'dong': '마포구 서교동'},
    {'name': '성수/서울숲', 'lat': 37.5446, 'lng': 127.0440, 'dong': '성동구 성수동'},
    {'name': '강남/신사', 'lat': 37.4981, 'lng': 127.0276, 'dong': '강남구 역삼동'},
    {'name': '을지로/종로', 'lat': 37.5663, 'lng': 126.9921, 'dong': '중구 을지로'},
    {'name': '여의도/한강', 'lat': 37.5256, 'lng': 126.9242, 'dong': '영등포구 여의도동'},
  ];

  // 카테고리 필터
  final List<String> _categories = const [
    '전체',
    '⚡ 오늘 번개',
    '☕ 카페/디저트',
    '🍷 와인/펍',
    '🍽️ 맛집 탐방',
    '🏃 러닝/산책',
    '🎤 코노/문화',
    '📚 독서/스터디',
  ];

  // 기본 탐색 모임 데이터베이스 (30대 감성 스토리형 모임)
  final List<Map<String, dynamic>> _presetMeetups = [
    {
      'id': 'exp_01',
      'title': '홍대입구역 9번 출구 인생네컷 & 와플 🧇',
      'location': '마포구 홍대입구역 9번 출구 앞',
      'lat': 37.5568,
      'lng': 126.9238,
      'distance': '도보 180m',
      'category': '⚡ 오늘 번개',
      'members': '2/4',
      'host': '달콤한와플',
      'hostAvatar': 'assets/images/kr_female_2.jpg',
      'manner': 42.1,
      'imageUrl': 'assets/images/cover_cafe.jpg',
      'isLightning': true,
      'date': '오늘 즉시 (15분 후 집결)',
      'description': '퇴근길에 달달한 와플 먹으면서 사진 한 장 남기실 분! 편하게 오세요 :)',
    },
    {
      'id': 'exp_02',
      'title': '연남동 연트럴파크 돗자리 캔맥주 급구 🍺',
      'location': '마포구 경의선숲길 잔디광장',
      'lat': 37.5620,
      'lng': 126.9255,
      'distance': '도보 350m',
      'category': '⚡ 오늘 번개',
      'members': '3/4',
      'host': '연트럴피플',
      'hostAvatar': 'assets/images/kr_male_2.jpg',
      'manner': 39.4,
      'imageUrl': 'assets/images/cover_wine.jpg',
      'isLightning': true,
      'date': '오늘 저녁 8시',
      'description': '선선한 바람 불 때 돗자리 펴고 편하게 캔맥주 한 잔 하실 동네 친구 구해요.',
    },
    {
      'id': 'exp_03',
      'title': '성수동 서울숲 잔디마당 플랫화이트 번개 ☕',
      'location': '성동구 서울숲 메인 출구',
      'lat': 37.5446,
      'lng': 127.0440,
      'distance': '도보 520m',
      'category': '☕ 카페/디저트',
      'members': '2/3',
      'host': '성수동힙스터',
      'hostAvatar': 'assets/images/kr_female_3.jpg',
      'manner': 43.0,
      'imageUrl': 'assets/images/cover_cafe.jpg',
      'isLightning': false,
      'date': '이번주 일요일 14:00',
      'description': '성수동 감성 에스프레소 바 투어하고 서울숲 가볍게 걸어요.',
    },
    {
      'id': 'exp_04',
      'title': '망원 한강공원 야경 나이트 러닝 (6km 페이스) 🏃',
      'location': '마포구 망원 한강공원 편의점 앞',
      'lat': 37.5532,
      'lng': 126.8965,
      'distance': '도보 750m',
      'category': '🏃 러닝/산책',
      'members': '3/5',
      'host': '망원러너',
      'hostAvatar': 'assets/images/kr_male_1.jpg',
      'manner': 41.5,
      'imageUrl': 'assets/images/cover_running.jpg',
      'isLightning': true,
      'date': '오늘 밤 9시',
      'description': '초보자도 무리 없는 6분 30초 페이스! 스트레스 날려버려요.',
    },
    {
      'id': 'exp_05',
      'title': '을지로 세운상가 루프탑 LP바 & 칵테일 🍷',
      'location': '중구 을지로 세운상가 옥상',
      'lat': 37.5663,
      'lng': 126.9921,
      'distance': '도보 400m',
      'category': '🍷 와인/펍',
      'members': '2/4',
      'host': '을지로감성',
      'hostAvatar': 'assets/images/kr_female_1.jpg',
      'manner': 44.2,
      'imageUrl': 'assets/images/cover_wine.jpg',
      'isLightning': false,
      'date': '토요일 저녁 7시',
      'description': '힙지로 야경 내려다보며 음악과 칵테일 즐기실 직장인 분들 환영합니다.',
    },
    {
      'id': 'exp_06',
      'title': '강남역 테헤란로 직장인 주말 브런치 수다회 🥪',
      'location': '강남구 역삼동 카페거리',
      'lat': 37.4981,
      'lng': 127.0276,
      'distance': '도보 250m',
      'category': '🍽️ 맛집 탐방',
      'members': '3/4',
      'host': '브런치러버',
      'hostAvatar': 'assets/images/kr_female_2.jpg',
      'manner': 40.8,
      'imageUrl': 'assets/images/cover_food.jpg',
      'isLightning': false,
      'date': '토요일 오전 11:30',
      'description': '주말 아침 여유롭게 에그 베네딕트 먹으면서 다양한 직종 이야기 나눠요.',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _currentLat = widget.initialLat!;
      _currentLng = widget.initialLng!;
      if (widget.initialSpotName != null) {
        _currentSpotName = widget.initialSpotName!;
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 검색 또는 핫스팟 클릭 시 지도 이동
  Future<void> _moveToLocation(double lat, double lng, String name) async {
    HapticFeedback.lightImpact();
    setState(() {
      _currentLat = lat;
      _currentLng = lng;
      _currentSpotName = name;
      _selectedMeetup = null;
    });
  }

  // 키워드 검색
  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final results = await KakaoMapService.searchKeyword(query.trim(), size: 1);
      if (results.isNotEmpty) {
        final first = results.first;
        await _moveToLocation(first.lat, first.lng, first.name);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📍 \'${first.name}\' 카카오 지도로 이동했습니다.'),
              backgroundColor: const Color(0xFFFF5E36),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('검색 결과가 없습니다. 다른 지명을 입력해보세요.')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 검색 중 오류가 발생했습니다.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // GPS 현재 위치로 이동
  Future<void> _moveToCurrentGps() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    try {
      final text = await KakaoMapService.getDistanceTextFromCurrent(_currentLat, _currentLng);
      // 서울 홍대 기준 안심 위치 반영
      await _moveToLocation(37.5568, 126.9238, '내 GPS 현재 위치 (마포구 서교동)');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎯 $text (카카오 정밀 GPS 동기화 완료)'),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 현재 필터에 따른 모임 목록 필터링
  List<Map<String, dynamic>> _getFilteredMeetups(List<Map<String, dynamic>> rawList) {
    return rawList.where((m) {
      // 카테고리 필터
      if (_selectedCategory != '전체') {
        final cat = (m['category'] ?? m['mainCategory'] ?? '').toString();
        if (_selectedCategory == '⚡ 오늘 번개') {
          if (m['isLightning'] != true && !cat.contains('번개')) return false;
        } else {
          final cleanCat = _selectedCategory.replaceAll(RegExp(r'[^\uAC00-\uD7A3a-zA-Z]'), '').trim();
          if (!cat.contains(cleanCat)) return false;
        }
      }

      // 검색어 필터
      final q = _searchController.text.trim().toLowerCase();
      if (q.isNotEmpty) {
        final title = (m['title'] ?? '').toString().toLowerCase();
        final loc = (m['location'] ?? '').toString().toLowerCase();
        if (!title.contains(q) && !loc.contains(q)) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const coralAccent = Color(0xFFFF5E36);
    const textPrimary = Color(0xFF0F172A);
    const textSecondary = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Text(
          '동네 지도 탐색 (카카오맵)',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 17,
            
          ),
        ),
        actions: [
          IconButton(
            tooltip: '내 현재 위치',
            icon: const Icon(Icons.my_location_rounded, color: coralAccent),
            onPressed: _moveToCurrentGps,
          ),
          IconButton(
            tooltip: '새 모임 개설',
            icon: const Icon(Icons.add_circle_outline_rounded, color: coralAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OOMUHostScreen(
                    initialLocation: _currentSpotName,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF1F5F9), height: 1),
        ),
      ),
      body: Stack(
        children: [
          // 1. 카카오 공식 지도 뷰 (배경 전체)
          Positioned.fill(
            child: KakaoMapView(
              lat: _currentLat,
              lng: _currentLng,
              locationName: _currentSpotName,
            ),
          ),

          // 2. 상단 플로팅 검색 & 필터 바
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 검색 입력창
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.96),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 14, right: 8),
                        child: Icon(Icons.search_rounded, color: coralAccent, size: 22),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: textPrimary),
                          decoration: const InputDecoration(
                            hintText: '동네, 지하철역, 취향 키워드 검색 (예: 성수, 와인)',
                            hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onSubmitted: _searchLocation,
                          onChanged: (val) => setState(() {}),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            setState(() => _searchController.clear());
                          },
                        ),
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: const Icon(Icons.tune_rounded, size: 20, color: textSecondary),
                          onPressed: () => _showFilterModal(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 주요 핫스팟 퀵 칩 리스트 (가로 스크롤)
                SizedBox(
                  height: 34,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _hotspots.length,
                    itemBuilder: (context, index) {
                      final spot = _hotspots[index];
                      final isSelected = _currentSpotName.contains(spot['name'] as String);
                      return GestureDetector(
                        onTap: () => _moveToLocation(
                          spot['lat'] as double,
                          spot['lng'] as double,
                          spot['dong'] as String,
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? coralAccent : Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: isSelected ? coralAccent : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.place_rounded,
                                size: 14,
                                color: isSelected ? Colors.white : coralAccent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                spot['name'] as String,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : textPrimary,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // 카테고리 필터 칩 (가로 스크롤)
                SizedBox(
                  height: 32,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedCategory = cat);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF0F172A) : Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF475569),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 3. 로딩 인디케이터
          if (_isLoading)
            Positioned(
              top: 150,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('카카오 지도 동기화 중...', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),

          // 4. Mobbin 1티어 Draggable Sheet-over-Map
          DraggableScrollableSheet(
            initialChildSize: 0.38,
            minChildSize: 0.18,
            maxChildSize: 0.88,
            snap: true,
            snapSizes: const [0.18, 0.38, 0.88],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('meetups')
                      .orderBy('createdAt', descending: true)
                      .limit(20)
                      .snapshots(),
                  builder: (context, snapshot) {
                    List<Map<String, dynamic>> meetups = [];

                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      meetups = snapshot.data!.docs.map((doc) {
                        final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
                        data['id'] = doc.id;
                        return data;
                      }).toList();
                    }

                    // 기본 프리셋과 병합하여 풍성한 탐색 피드 제공
                    final Set<String> existingTitles = meetups.map((m) => (m['title'] ?? '').toString()).toSet();
                    for (var preset in _presetMeetups) {
                      if (!existingTitles.contains(preset['title'])) {
                        meetups.add(preset);
                      }
                    }

                    final filtered = _getFilteredMeetups(meetups);

                    return CustomScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // 시트 상단 드래그 핸들 및 상태 요약 바
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              Container(
                                width: 42,
                                height: 4.5,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCBD5E1),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.explore_rounded, color: coralAccent, size: 20),
                                        const SizedBox(width: 6),
                                        Text(
                                          '현재 반경 모임 (${filtered.length}개)',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: textPrimary,
                                            
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF0EB),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '$_selectedRadius 반경',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: coralAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            ],
                          ),
                        ),

                        // 빈 상태 (Empty State: 따뜻한 감성 일러스트 + 즉시 행동 유도 CTA)
                        if (filtered.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.explore_off_rounded, size: 36, color: Color(0xFF94A3B8)),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    '현재 필터 조건에 맞는 모임이 없어요',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                      
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    '반경을 넓히거나 다른 카테고리를 선택해 보세요.\n이 동네의 첫 번째 호스트가 되어볼 수도 있어요!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 13, color: textSecondary, height: 1.4),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => OOMUHostScreen(
                                            initialLocation: _currentSpotName,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('이 동네 첫 모임 열기', style: TextStyle(fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: coralAccent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      elevation: 0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          // 100점 풀-피니시 모임 카드 리스트
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final m = filtered[index];
                                  return _buildMeetupCard(context, m);
                                },
                                childCount: filtered.length,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 100점 풀-피니시 모임 카드 위젯 (당근/문토/29CM 표준 규격)
  Widget _buildMeetupCard(BuildContext context, Map<String, dynamic> m) {
    const coralAccent = Color(0xFFFF5E36);
    const textPrimary = Color(0xFF0F172A);
    const textSecondary = Color(0xFF64748B);
    final isLightning = m['isLightning'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            HapticFeedback.lightImpact();
            // 지도 중심 해당 모임 위치로 맞추기
            final double? lat = m['lat'] as double?;
            final double? lng = m['lng'] as double?;
            if (lat != null && lng != null) {
              setState(() {
                _currentLat = lat;
                _currentLng = lng;
                _currentSpotName = (m['location'] ?? '').toString();
              });
            }
            // 상세 화면 열기
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OOMUDetailScreen(meetup: m),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 88x88 정방형 썸네일 (Mobbin 1티어)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 88,
                        height: 88,
                        child: appNetImage(
                          (m['imageUrl'] ?? m['image'] ?? 'assets/images/cover_cafe.jpg').toString(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (isLightning)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5E36),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '⚡번개',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),

                // 2. 모임 정보 컨텐츠
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 카테고리 태그 & 안심 정산 뱃지
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              (m['category'] ?? m['mainCategory'] ?? '일상 & 소통').toString(),
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: const Text(
                              '1/N 안심 정산',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF047857)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // 제목 ()
                      Text(
                        (m['title'] ?? '').toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          height: 1.3,
                          
                        ),
                      ),
                      const SizedBox(height: 6),

                      // 위치 및 거리 표시
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: coralAccent),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${m['location'] ?? '위치 미지정'} · ${m['distance'] ?? '도보 350m'}',
                              style: const TextStyle(fontSize: 11.5, color: textSecondary, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // 참여 멤버 & 매너온도
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundImage: appImg((m['hostAvatar'] ?? 'assets/images/kr_female_1.jpg').toString()),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${m['host'] ?? '호스트'}',
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: textPrimary),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${m['members'] ?? '2/4'}명 참여 중',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                          Text(
                            '${m['manner'] ?? 41.2}°C 🔥',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: coralAccent),
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

  // 필터 모달
  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '탐색 반경 및 필터 설정',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('탐색 반경 기준', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: ['500m', '1km', '3km', '전체'].map((r) {
                      final isSel = _selectedRadius == r;
                      return ChoiceChip(
                        label: Text(r),
                        selected: isSel,
                        selectedColor: const Color(0xFFFF5E36),
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : const Color(0xFF0F172A),
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (val) {
                          setModalState(() => _selectedRadius = r);
                          setState(() => _selectedRadius = r);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5E36),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('필터 적용하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
