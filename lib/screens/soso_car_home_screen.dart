import 'package:flutter/material.dart';
import '../utils/app_image.dart';
import '../utils/global_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'soso_car_host_screen.dart';
import 'chat_screen.dart';
import 'oomu_my_trips_screen.dart';
import 'my_page_screen.dart';
import 'soso_car_detail_screen.dart';
import 'filter_screen.dart';
import 'soso_spot_screen.dart';
import '../utils/location_helper.dart';

class OOMUHomeScreen extends StatefulWidget {
  const OOMUHomeScreen({super.key});

  @override
  State<OOMUHomeScreen> createState() => _OOMUHomeScreenState();
}

class _OOMUHomeScreenState extends State<OOMUHomeScreen> {
  final Color textPrimary = const Color(0xFF111111);
  final Color textSecondary = const Color(0xFF767676);
  final Color surfaceColor = const Color(0xFFF5F5F7);
  final Color accentColor = const Color(0xFFF19E39);
  final Color coralAccent = const Color(0xFFFF5E36);
  final Color destructiveColor = const Color(0xFFFF3B30);

  String _currentLocation = '마포구 서교동';
  String? _selectedVibe;
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'icon': '🔥', 'name': '전체'},
    {'icon': '🎤', 'name': '코노/노래'},
    {'icon': '🍻', 'name': '술/맛집'},
    {'icon': '☕', 'name': '카페/수다'},
    {'icon': '✈️', 'name': '여행/드라이브'},
    {'icon': '🎳', 'name': '액티비티'},
  ];

  // 전국 시·도 및 읍면동 핫스팟 리스트
  static const Map<String, List<String>> _nationwideRegions = {
    '서울': [
      '마포구 서교동', '마포구 연남동', '마포구 망원동', '마포구 합정동',
      '성동구 성수동', '용산구 한남동', '용산구 이태원동', '강남구 신사동',
      '강남구 역삼동', '송파구 잠실동', '영등포구 여의도동', '중구 을지로동',
      '종로구 익선동', '광진구 자양동(건대)',
    ],
    '경기/인천': [
      '성남시 분당구 판교동', '성남시 분당구 정자동', '수원시 영통구 광교동',
      '고양시 일산동구 장항동', '인천 연수구 송도동', '하남시 미사동',
      '용인시 수지구 풍덕천동', '안양시 동안구 평촌동', '부천시 원미구 중동',
    ],
    '부산/경상': [
      '부산 해운대구 우동', '부산 해운대구 중동', '부산 부산진구 전포동',
      '부산 수영구 광안동', '대구 수성구 범어동', '대구 중구 동성로',
      '울산 남구 삼산동', '창원시 성산구 상남동',
    ],
    '대전/충청': [
      '대전 유성구 봉명동', '대전 서구 둔산동', '세종시 나성동',
      '청주시 상당구 성안동', '천안시 서북구 불당동',
    ],
    '광주/전라': [
      // 전남 여수시 (전역 정밀 지원)
      '여수시 학동', '여수시 웅천동', '여수시 여서동', '여수시 문수동',
      '여수시 신월동', '여수시 교동(이순신광장)', '여수시 돌산읍',
      '여수시 소라면', '여수시 화장동', '여수시 봉산동(게장거리)',
      '여수시 덕충동(엑스포역)', '여수시 미평동(전남대)', '여수시 국동',
      // 전남 순천시 / 광양시 / 목포시 / 나주시
      '순천시 조례동', '순천시 연향동', '순천시 신대지구', '순천시 중앙동',
      '광양시 중마동', '광양시 광영동',
      '목포시 하당동', '목포시 평화광장(상동)', '목포시 남악',
      '나주시 빛가람동(혁신도시)',
      // 전북 전주시 / 익산시 / 군산시
      '전주시 완산구 효자동', '전주시 덕진구 송천동', '전주시 완산구 고사동(객사)',
      '전주시 덕진구 혁신도시', '익산시 영등동', '군산시 수송동',
      // 광주광역시
      '광주 서구 상무동', '광주 동구 동명동', '광주 광산구 수완동',
      '광주 남구 봉선동', '광주 북구 용봉동(전남대)', '광주 광산구 첨단동',
    ],
    '강원/제주': [
      '강릉시 교동', '속초시 조양동', '춘천시 효자동',
      '제주시 노형동', '제주시 연동', '제주시 아라동', '서귀포시 중문동',
    ],
  };

  void _showLocationPickerBottomSheet() {
    String searchQuery = '';
    String selectedRegionTab = '서울';
    bool isGpsLocating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          // 검색 필터링된 리스트
          List<String> displayedList = [];
          if (searchQuery.trim().isNotEmpty) {
            final q = searchQuery.trim().toLowerCase();
            for (var regionList in _nationwideRegions.values) {
              for (var dong in regionList) {
                if (dong.toLowerCase().contains(q)) {
                  displayedList.add(dong);
                }
              }
            }
          } else {
            displayedList = _nationwideRegions[selectedRegionTab] ?? [];
          }

          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(color: const Color(0xFFE5E5EA), borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text('우리 동네 설정', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFFF0EB), borderRadius: BorderRadius.circular(8)),
                          child: Text('전국 지원', style: TextStyle(color: coralAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('내 위치를 공유하거나 원하는 동네를 검색해보세요.', style: TextStyle(fontSize: 13, color: textSecondary)),
                    const SizedBox(height: 16),

                    // 1. GPS 현재 위치로 찾기 Button (실제 GPS + 역지오코딩 연동)
                    GestureDetector(
                      onTap: isGpsLocating
                          ? null
                          : () async {
                              setModalState(() => isGpsLocating = true);
                              final detected = await LocationHelper.getCurrentDongName();
                              setModalState(() => isGpsLocating = false);

                              if (detected != null && detected.isNotEmpty) {
                                setState(() {
                                  _currentLocation = detected;
                                });
                                globalData.updateLocation(detected);
                                try {
                                  FirebaseFirestore.instance.collection('users').doc('test_user_1').set({
                                    'location': detected,
                                    'updatedAt': FieldValue.serverTimestamp(),
                                  }, SetOptions(merge: true));
                                } catch (_) {}
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.my_location, color: Colors.white, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text('📍 내 현재 위치 자동 할당 완료: $detected')),
                                      ],
                                    ),
                                    backgroundColor: coralAccent,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('⚠️ 위치 권한을 확인해주시거나 동네를 직접 검색해주세요.')),
                                );
                              }
                            },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF4EE), Color(0xFFFFECE5)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: coralAccent.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isGpsLocating)
                              const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF5E36)))
                            else
                              Icon(Icons.my_location, color: coralAccent, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              isGpsLocating ? 'GPS 위치 확인 및 동네 분석 중...' : '현재 위치로 동네 자동 찾기 (GPS 연동)',
                              style: TextStyle(color: coralAccent, fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 2. 동·읍·면 검색 TextField
                    TextField(
                      onChanged: (val) {
                        setModalState(() {
                          searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: '읍·면·동 검색 (예: 판교, 해운대, 서교, 둔산동)',
                        hintStyle: TextStyle(fontSize: 13, color: textSecondary),
                        prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF8E8E93)),
                        filled: true,
                        fillColor: surfaceColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 3. 지역 탭 (검색 중이 아닐 때)
                    if (searchQuery.trim().isEmpty)
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _nationwideRegions.keys.map((reg) {
                            final isSel = selectedRegionTab == reg;
                            return GestureDetector(
                              onTap: () => setModalState(() => selectedRegionTab = reg),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFF1E1E24) : surfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  reg,
                                  style: TextStyle(
                                    color: isSel ? Colors.white : textPrimary,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    const SizedBox(height: 10),

                    // 4. 동네 목록 List
                    Expanded(
                      child: displayedList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 40, color: textSecondary),
                                  const SizedBox(height: 8),
                                  Text('\'$searchQuery\' 검색 결과가 없습니다.', style: TextStyle(color: textSecondary, fontSize: 13)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: displayedList.length,
                              itemBuilder: (context, idx) {
                                final dong = displayedList[idx];
                                final isSelected = dong == _currentLocation;
                                return ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  leading: Icon(
                                    Icons.location_on,
                                    color: isSelected ? coralAccent : const Color(0xFFC7C7CC),
                                    size: 20,
                                  ),
                                  title: Text(
                                    dong,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                      color: isSelected ? coralAccent : textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(Icons.check_circle, color: coralAccent, size: 20)
                                      : null,
                                  onTap: () {
                                    setState(() => _currentLocation = dong);
                                    globalData.updateLocation(dong);
                                    try {
                                      FirebaseFirestore.instance.collection('users').doc('test_user_1').set({
                                        'location': dong,
                                        'updatedAt': FieldValue.serverTimestamp(),
                                      }, SetOptions(merge: true));
                                    } catch (_) {}
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('📍 $dong(으)로 동네를 변경했어요')),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _seedDatabase();
  }

  Future<void> _seedDatabase() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('meetups').limit(1).get();
      if (snapshot.docs.isEmpty) {
        final dummyMeetups = [
          {
            'title': '불금엔 역시 코노! 스트레스 풀 분 🎤',
            'category': '코노/노래',
            'location': '합정역 수코인노래방',
            'date': '오늘 저녁 8시',
            'host': '고음불가',
            'manner': 38.5,
            'price': 'N빵',
            'members': '2/4',
            'isFemaleOnly': true,
            'transport': '각자 이동',
            'imageUrl': 'assets/images/cover_wine.jpg',
            'tags': ['코노', '놀줄아는', '스트레스해소'],
            'createdAt': FieldValue.serverTimestamp()
          },
          {
            'title': '주말 엽떡+마라탕 조지실 분 🔥',
            'category': '술/맛집',
            'location': '홍대입구역 9번 출구',
            'date': '이번주 토요일 18:00',
            'host': '매운맛킬러',
            'manner': 41.2,
            'price': 'N빵',
            'members': '2/4',
            'isFemaleOnly': true,
            'transport': '각자 이동',
            'imageUrl': 'assets/images/cover_food.jpg',
            'tags': ['소셜다이닝', '메이트', '홍대맛집', '동네찐친'],
            'createdAt': FieldValue.serverTimestamp()
          },
          {
            'title': '성수동 대형 에스프레소 바 & 감성 북카페 나들이 ☕📚',
            'category': '카페/수다',
            'location': '성동구 성수동 카페거리',
            'date': '일요일 14:00',
            'host': '성수동힙스터',
            'manner': 42.8,
            'price': '각자 결제',
            'members': '2/4',
            'isFemaleOnly': false,
            'transport': '성수역 집결',
            'imageUrl': 'assets/images/cover_cafe.jpg',
            'tags': ['카페/수다', '소소하게', '성수동'],
            'createdAt': FieldValue.serverTimestamp()
          }
        ];
        for (var m in dummyMeetups) {
          await FirebaseFirestore.instance.collection('meetups').add(m);
        }
      }
    } catch (e) {
      debugPrint("Seed error: $e");
    }
  }

  Widget _buildVibeCard(String emoji, String title, String subtitle, Color bgColor) {
    final isSelected = _selectedVibe == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_selectedVibe == title) {
              _selectedVibe = null;
            } else {
              _selectedVibe = title;
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? coralAccent : Colors.transparent,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: coralAccent.withOpacity(0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? coralAccent : const Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? coralAccent.withOpacity(0.8) : const Color(0xFF767676),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (isSelected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: coralAccent,
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _matchesFilters(Map<String, dynamic> item) {
    // 1. Category Filter
    if (_selectedCategoryIndex > 0) {
      final selectedCat = _categories[_selectedCategoryIndex]['name'] as String;
      final itemCat = (item['category'] ?? '').toString();
      if (!itemCat.contains(selectedCat) && !selectedCat.contains(itemCat)) {
        return false;
      }
    }

    // 2. Vibe Filter
    if (_selectedVibe != null) {
      final cat = (item['category'] ?? '').toString();
      final title = (item['title'] ?? '').toString();
      final tags = (item['tags'] as List?)?.map((e) => e.toString()).toList() ?? [];

      if (_selectedVibe == '놀줄아는') {
        final matches = tags.contains('놀줄아는') || tags.contains('와인바') || cat.contains('술') || cat.contains('액티비티');
        if (!matches) return false;
      } else if (_selectedVibe == '소소하게') {
        final matches = tags.contains('소소하게') || cat.contains('카페') || title.contains('카페') || tags.contains('디저트');
        if (!matches) return false;
      } else if (_selectedVibe == '메이트') {
        final matches = tags.contains('메이트') || tags.contains('동네찐친') || cat.contains('맛집') || title.contains('러닝') || cat.contains('액티비티');
        if (!matches) return false;
      } else if (_selectedVibe == '소개팅') {
        final matches = tags.contains('소개팅') || tags.contains('취향') || item['isFemaleOnly'] == false;
        if (!matches) return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _showLocationPickerBottomSheet,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _currentLocation,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19, color: textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 22, color: textPrimary),
            ],
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('🔔 FCM 알림: [방장] 참여 승인이 완료되었습니다!'),
                backgroundColor: Color(0xFFFF5E36),
                duration: Duration(seconds: 3),
              ));
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: Color(0xFFF5F5F7), shape: BoxShape.circle),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.notifications_outlined, color: Color(0xFF111111), size: 22),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(radius: 3.5, backgroundColor: Colors.redAccent),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen())),
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: Color(0xFFF5F5F7), shape: BoxShape.circle),
              child: Icon(Icons.tune, color: textPrimary, size: 20),
            ),
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 1. Categories Tab (Horizontal Scroll) - High Contrast 2030 Hip Styling
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 20, left: 20),
              child: SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedCategoryIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [Color(0xFFFF5E36), Color(0xFFFF8A3D)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSelected ? null : const Color(0xFFF3F3F6),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : const Color(0xFFE4E4EB),
                            width: 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: coralAccent.withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_categories[index]['icon'], style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              _categories[index]['name'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF1E1E24),
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // 2. 지금 내 상황 (My Current Situation)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('지금 내 상황', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: textPrimary)),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedVibe = null;
                            _selectedCategoryIndex = 0;
                          });
                        },
                        child: Text('전체 보기', style: TextStyle(fontSize: 13, color: textSecondary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildVibeCard('⚡', '놀줄아는', '핫플·페스티벌', const Color(0xFFFFF4E6)),
                      const SizedBox(width: 10),
                      _buildVibeCard('☕', '소소하게', '카페·산책', const Color(0xFFF3F4F6)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildVibeCard('🍔', '메이트', '맛집·배달', const Color(0xFFFCE8E6)),
                      const SizedBox(width: 10),
                      _buildVibeCard('💖', '소개팅', '취향 기반', const Color(0xFFFCE4EC)),
                    ],
                  ),

                  // 활성화된 Vibe 필터 바
                  if (_selectedVibe != null)
                    Container(
                      margin: const EdgeInsets.only(top: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0EB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: coralAccent.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Text('✨', style: TextStyle(fontSize: 15)),
                          const SizedBox(width: 6),
                          Text(
                            '\'$_selectedVibe\' 분위기 모임 필터링 중',
                            style: TextStyle(fontWeight: FontWeight.bold, color: coralAccent, fontSize: 13),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => setState(() => _selectedVibe = null),
                            child: Row(
                              children: [
                                Icon(Icons.close, size: 14, color: coralAccent),
                                const SizedBox(width: 2),
                                Text('필터 해제', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: coralAccent)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 3. 소소스팟 (SoSo Spot) Real-Time Entry Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 28),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SoSoSpotScreen()));
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1F1F24), Color(0xFF2E2E3A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFFF5E36), Color(0xFFFF8A3D)]),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: const Text('⚡', style: TextStyle(fontSize: 26)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFF34C759), borderRadius: BorderRadius.circular(6)),
                                  child: const Text('LIVE 4개', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                                ),
                                const SizedBox(width: 6),
                                const Expanded(
                                  child: Text(
                                    '소소스팟 (SoSo Spot)',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '내 주변 10분 컷 핫플! 실시간 번개 즉시 합류',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. 우리 동네 취향 모임 Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 32, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('우리 동네\n취향 모임', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary, height: 1.2)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _selectedVibe != null
                          ? '$_selectedVibe 필터링 중'
                          : (_selectedCategoryIndex > 0 ? '${_categories[_selectedCategoryIndex]['name']} 모임' : '진행 중인 모임'),
                      style: TextStyle(fontSize: 13, color: coralAccent, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. StreamBuilder / Fallback with Filtering
          SliverToBoxAdapter(
            child: _getMeetupStream() == null
                ? _buildDummyMeetups()
                : StreamBuilder<QuerySnapshot>(
                    stream: _getMeetupStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: Colors.black)));
                      }
                      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildDummyMeetups();
                      }

                      final filteredDocs = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return _matchesFilters(data);
                      }).toList();

                      if (filteredDocs.isEmpty) {
                        return _buildEmptyFilterState();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          var doc = filteredDocs[index];
                          var data = doc.data() as Map<String, dynamic>;
                          data['id'] = doc.id;
                          return _buildMeetupCard(data);
                        },
                      );
                    },
                  ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildEmptyFilterState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off, size: 48, color: const Color(0xFFC7C7CC)),
            const SizedBox(height: 12),
            Text('선택한 조건의 모임이 아직 없어요', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
            const SizedBox(height: 6),
            Text('필터를 해제하거나 내가 먼저 모임을 개설해보세요!', style: TextStyle(fontSize: 13, color: textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: coralAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                setState(() {
                  _selectedVibe = null;
                  _selectedCategoryIndex = 0;
                });
              },
              child: const Text('필터 초기화', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetupCard(Map<String, dynamic> meetup) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OOMUDetailScreen(meetup: meetup))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFEBEBEF)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                image: DecorationImage(image: appImg(meetup['imageUrl'] ?? 'assets/images/cover_food.jpg'), fit: BoxFit.cover),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      gradient: LinearGradient(colors: [Colors.black.withOpacity(0.5), Colors.transparent], begin: Alignment.topCenter, end: Alignment.center),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(8)),
                          child: Text(meetup['category'] ?? '모임', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        if (meetup['isFemaleOnly'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: destructiveColor, borderRadius: BorderRadius.circular(8)),
                            child: const Text('여성 전용', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meetup['title'] ?? '취향 모임', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: textSecondary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          meetup['location'] ?? '위치 협의',
                          style: TextStyle(fontSize: 13, color: textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 16, color: textSecondary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          meetup['date'] ?? '일정 협의',
                          style: TextStyle(fontSize: 13, color: textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(height: 1, color: surfaceColor),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundImage: appImg(
                                meetup['hostAvatar'] ??
                                    (meetup['isFemaleOnly'] == true ? 'assets/images/kr_female_1.jpg' : 'assets/images/kr_male_1.jpg'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                meetup['host'] ?? '호스트',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.local_fire_department, size: 14, color: destructiveColor),
                            Text('${meetup['manner'] ?? 36.5}°C', style: TextStyle(fontSize: 12, color: textSecondary)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(8)),
                        child: Text('${meetup['members'] ?? '1/4'} 참여', style: TextStyle(fontSize: 12, color: textPrimary, fontWeight: FontWeight.bold)),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDummyMeetups() {
    final List<Map<String, dynamic>> allDummyData = [
      {
        'id': 'dummy_meetup_01',
        'title': '주말 엽떡+마라탕 조지실 분 🔥',
        'category': '술/맛집',
        'location': '마포구 홍대입구역 9번 출구',
        'date': '이번주 토요일 18:00',
        'imageUrl': 'assets/images/cover_food.jpg',
        'isFemaleOnly': true,
        'host': '매운맛킬러',
        'hostAvatar': 'assets/images/kr_female_1.jpg',
        'manner': 41.2,
        'members': '2/4',
        'price': 'N빵',
        'transport': '각자 이동',
        'schedule': '1차 엽떡+마라탕 먹방 ➔ 2차 인생네컷 & 보드게임 카페',
        'tags': ['소셜다이닝', '매운맛', '홍대맛집', '동네찐친', '메이트'],
        'photos': [
          'assets/images/cover_food.jpg',
          'assets/images/cover_food.jpg',
          'assets/images/cover_cafe.jpg',
        ],
      },
      {
        'id': 'dummy_meetup_02',
        'title': '성수동 대형 에스프레소 바 & 감성 북카페 나들이 ☕📚',
        'category': '카페/수다',
        'location': '성동구 성수동 카페거리',
        'date': '이번주 일요일 오후 2:00',
        'imageUrl': 'assets/images/cover_cafe.jpg',
        'isFemaleOnly': false,
        'host': '성수동힙스터',
        'hostAvatar': 'assets/images/kr_female_2.jpg',
        'manner': 38.5,
        'members': '2/4',
        'price': '각자 결제',
        'transport': '성수역 3번출구 집결',
        'schedule': '힙한 신상 에스프레소 바 ➔ 베이커리 북카페 & 디저트 탐방',
        'tags': ['소소하게', '성수카페', '디저트', '주말여유'],
        'photos': [
          'assets/images/cover_cafe.jpg',
          'assets/images/cover_cafe.jpg',
        ],
      },
      {
        'id': 'dummy_meetup_03',
        'title': '연남동 내추럴 와인바 소셜 다이닝 🍷',
        'category': '술/맛집',
        'location': '마포구 연남동 미로길',
        'date': '금요일 저녁 7:30',
        'imageUrl': 'assets/images/cover_wine.jpg',
        'isFemaleOnly': false,
        'host': '와인앤모어',
        'hostAvatar': 'assets/images/kr_male_1.jpg',
        'manner': 42.0,
        'members': '3/4',
        'price': '1/N 분담',
        'transport': '홍대입구역 3번출구 도보',
        'schedule': '내추럴 와인 2병 페어링 & 소소한 금요일 밤 이야기',
        'tags': ['놀줄아는', '와인바', '연남동', '소셜다이닝'],
        'photos': [
          'assets/images/cover_wine.jpg',
          'assets/images/cover_food.jpg',
        ],
      },
      {
        'id': 'dummy_meetup_04',
        'title': '망원 한강공원 야경 러닝 5km 🏃‍♀️',
        'category': '액티비티',
        'location': '마포구 망원 한강공원 입구',
        'date': '목요일 저녁 8:00',
        'imageUrl': 'assets/images/cover_running.jpg',
        'isFemaleOnly': false,
        'host': '러닝크루장',
        'hostAvatar': 'assets/images/kr_male_3.jpg',
        'manner': 39.8,
        'members': '4/6',
        'price': '무료',
        'transport': '망원역 집결',
        'schedule': '스트레칭 10분 ➔ 6분 페이스 5km 러닝 ➔ 이온음료 쿨다운',
        'tags': ['메이트', '러닝', '한강야경', '오운완'],
        'photos': [
          'assets/images/cover_running.jpg',
          'assets/images/cover_running.jpg',
        ],
      },
      {
        'id': 'dummy_meetup_05',
        'title': '불금엔 역시 코노! 스트레스 풀 분 🎤',
        'category': '코노/노래',
        'location': '합정역 수코인노래방',
        'date': '오늘 저녁 8시',
        'host': '고음불가',
        'hostAvatar': 'assets/images/kr_male_2.jpg',
        'manner': 38.5,
        'price': 'N빵',
        'members': '2/4',
        'isFemaleOnly': false,
        'transport': '각자 이동',
        'imageUrl': 'assets/images/cover_wine.jpg',
        'tags': ['코노/노래', '놀줄아는', '스트레스해소'],
        'photos': [
          'assets/images/cover_wine.jpg',
        ],
      },
    ];

    final filtered = allDummyData.where((m) => _matchesFilters(m)).toList();

    if (filtered.isEmpty) {
      return _buildEmptyFilterState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _buildMeetupCard(filtered[index]);
      },
    );
  }

  Stream<QuerySnapshot>? _getMeetupStream() {
    try {
      return FirebaseFirestore.instance.collection('meetups').orderBy('createdAt', descending: true).limit(20).snapshots();
    } catch (e) {
      return null;
    }
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: textPrimary,
      unselectedItemColor: const Color(0xFFC7C7CC),
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      elevation: 20,
      backgroundColor: const Color(0xFFF7F8FA),
      onTap: (index) {
        if (index == 0) {
        } else if (index == 1) {
          Navigator.push(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const OOMUHostScreen(), transitionDuration: Duration.zero));
        } else if (index == 2) {
          Navigator.push(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const ChatScreen(), transitionDuration: Duration.zero));
        } else if (index == 3) {
          Navigator.push(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const OOMUMyTripsScreen(), transitionDuration: Duration.zero));
        } else if (index == 4) {
          Navigator.push(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const MyPageScreen(), transitionDuration: Duration.zero));
        }
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined, size: 26), activeIcon: Icon(Icons.explore, size: 26), label: '탐색'),
        const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 26), activeIcon: Icon(Icons.add_circle, size: 26), label: '모집하기'),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.chat_bubble_outline, size: 24),
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(color: Color(0xFFFF3B30), shape: BoxShape.circle),
                  child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          activeIcon: const Icon(Icons.chat_bubble, size: 24),
          label: '채팅',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.directions_car_outlined, size: 26), activeIcon: Icon(Icons.directions_car, size: 26), label: '내 모임'),
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 26), activeIcon: Icon(Icons.person, size: 26), label: '마이'),
      ],
    );
  }
}
