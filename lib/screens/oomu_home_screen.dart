import 'dart:async';
import 'package:flutter/material.dart';
import '../data/oomu_categories.dart';
import '../ui/oomu_tokens.dart';
import '../utils/firestore_time.dart';
import '../utils/global_data.dart';
import '../utils/app_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/oomu_ui_helpers.dart';
import '../services/kakao_map_service.dart';
import '../services/regional_bot_meetup_service.dart';
import 'chat_screen.dart';
import 'event_detail_screen.dart';
import 'my_page_screen.dart';
import 'oomu_detail_screen.dart';
import 'oomu_spot_screen.dart';
import '../utils/location_helper.dart';
import 'oomu_chat_room_screen.dart';
import '../widgets/bouncy_tap.dart';
import '../widgets/oomu_discovery_lifestyle_hub.dart';
import 'home/home_category_tabs.dart';
import 'oomu_host_screen.dart';
import 'home/home_community_section.dart';
import 'home/home_discovery_section.dart';
import 'home/home_header.dart';
import 'home/home_lightning_section.dart';
import 'home/home_meetup_section.dart';

class OOMUHomeScreen extends StatefulWidget {
  final int initialTab;
  final List<Map<String, dynamic>>? initialCommunityPosts;
  const OOMUHomeScreen(
      {super.key, this.initialTab = 0, this.initialCommunityPosts});

  @override
  State<OOMUHomeScreen> createState() => _OOMUHomeScreenState();
}

class _OOMUHomeScreenState extends State<OOMUHomeScreen> {
  final Color textPrimary = OomuTokens.textPrimary;
  final Color textSecondary = OomuTokens.textSecondary;
  final Color surfaceColor = OomuTokens.background;
  final Color accentColor = OomuTokens.coral;
  final Color coralAccent = OomuTokens.coral;
  final Color destructiveColor = OomuTokens.error;
  final Color trustColor = OomuTokens.verified;

  late int _homeDashboardTab; // 0: 모임, 1: 커뮤니티, 2: 소개팅, 3: 채팅, 4: MY

  final List<Map<String, dynamic>> _liveSpots = [
    {
      'id': 'spot_01',
      'title': '홍대입구역 9번 출구 인생네컷 & 와플 🧇',
      'location': '마포구 홍대입구역 9번 출구 앞',
      'distance': '홍대입구역',
      'timeLeft': '오늘 번개',
      'category': '오늘 번개',
      'members': '2/4',
      'host': '달콤한와플',
      'hostAvatar': 'assets/images/시연.png',
      'manner': 42.1,
      'image': 'assets/images/cover_cafe.jpg',
      'isLightning': true,
      'date': '오늘 저녁 (시간 조율 가능)',
    },
    {
      'id': 'spot_02',
      'title': '연남동 연트럴파크 돗자리 캔맥주 급구 🍺',
      'location': '마포구 경의선숲길 잔디광장',
      'distance': '연트럴파크',
      'timeLeft': '오늘 번개',
      'category': '오늘 번개',
      'members': '3/4',
      'host': '연트럴피플',
      'hostAvatar': 'assets/images/정재.png',
      'manner': 39.4,
      'image': 'assets/images/cover_wine.jpg',
      'isLightning': true,
      'date': '오늘 저녁 8시',
    },
    {
      'id': 'spot_03',
      'title': '성수동 서울숲 잔디마당 플랫화이트 번개 ☕',
      'location': '성동구 서울숲 메인 출구',
      'distance': '서울숲',
      'timeLeft': '모집 중',
      'category': '오늘 번개',
      'members': '1/3',
      'host': '성수동힙스터',
      'hostAvatar': 'assets/images/지연.png',
      'manner': 43.0,
      'image': 'assets/images/cover_cafe.jpg',
      'isLightning': true,
      'date': '오늘 오후 3시',
    },
    {
      'id': 'spot_04',
      'title': '망원 한강공원 야경 산책 & 라면 먹방 🏃',
      'location': '마포구 망원 한강공원 편의점 앞',
      'distance': '망원 한강공원',
      'timeLeft': '오늘 번개',
      'category': '오늘 번개',
      'members': '2/4',
      'host': '망원라이더',
      'hostAvatar': 'assets/images/지훈.png',
      'manner': 41.5,
      'image': 'assets/images/cover_running.jpg',
      'isLightning': true,
      'date': '오늘 밤 9시',
    },
  ];

  final List<Map<String, dynamic>> _yeosuLiveSpots = [
    {
      'id': 'spot_yeosu_01',
      'title': '화장동 선소상가 바삭 와플 & 크로플 🧇',
      'location': '여수시 화장동 선소상가거리',
      'distance': '선소상가',
      'timeLeft': '오늘 번개',
      'category': '오늘 번개',
      'members': '2/4',
      'host': '여수와플러',
      'hostAvatar': 'assets/images/시연.png',
      'manner': 42.1,
      'image': 'assets/images/cover_cafe.jpg',
      'isLightning': true,
      'date': '오늘 저녁 (시간 조율 가능)',
    },
    {
      'id': 'spot_yeosu_02',
      'title': '성산공원 호수 둘레길 야경 산책 & 힐링 🏃',
      'location': '여수시 화장동 성산공원 입구',
      'distance': '성산공원 둘레길',
      'timeLeft': '오늘 번개',
      'category': '오늘 번개',
      'members': '3/4',
      'host': '화장동이웃',
      'hostAvatar': 'assets/images/정재.png',
      'manner': 43.5,
      'image': 'assets/images/cover_running.jpg',
      'isLightning': true,
      'date': '오늘 저녁 8시반',
    },
    {
      'id': 'spot_yeosu_03',
      'title': '웅천 친수공원 잔디마당 노을 캔맥주 급구 🍺',
      'location': '여수시 웅천동 해변공원',
      'distance': '웅천 친수공원',
      'timeLeft': '모집 중',
      'category': '오늘 번개',
      'members': '2/4',
      'host': '웅천피플_준',
      'hostAvatar': 'assets/images/지훈.png',
      'manner': 41.2,
      'image': 'assets/images/cover_wine.jpg',
      'isLightning': true,
      'date': '오늘 저녁 7시',
    },
    {
      'id': 'spot_yeosu_04',
      'title': '무선지구 롯데마트 앞 소금빵 & 카페 나들이 ☕',
      'location': '여수시 화장동 롯데마트 인근',
      'distance': '무선지구',
      'timeLeft': '모집 중',
      'category': '오늘 번개',
      'members': '1/3',
      'host': '무선빵순이',
      'hostAvatar': 'assets/images/지연.png',
      'manner': 44.0,
      'image': 'assets/images/cover_cafe.jpg',
      'isLightning': true,
      'date': '오늘 오후 2시',
    },
  ];

  List<Map<String, dynamic>> _getLiveSpotsForLocation(String location) {
    final clean = location.trim();
    if (clean.contains('여수') || clean.contains('화장동') || clean.contains('학동')) {
      return _yeosuLiveSpots;
    }
    if (clean.contains('마포') ||
        clean.contains('서교') ||
        clean.contains('연남') ||
        clean.contains('망원') ||
        clean.contains('합정') ||
        clean.contains('홍대')) {
      return _liveSpots;
    }
    return RegionalBotMeetupService.getLiveLightningSpotsForLocation(clean);
  }

  List<Map<String, dynamic>> _getActiveCommunityPosts() {
    // 운영 환경에서 더미 커뮤니티 글 18건을 실데이터처럼 노출하지 않음 (실제 Firestore 문서만 표시)
    return widget.initialCommunityPosts ?? const <Map<String, dynamic>>[];
  }

  int _calculateLocationRelevanceScore(String itemLocation) {
    return OomuUiHelpers.calculateLocationRelevanceScore(
        _currentLocation, itemLocation);
  }

  String _currentLocation = '마포구 서교동';
  String? _selectedVibe;
  int _selectedCategoryIndex = 0;
  String _selectedSubCategory = '전체';
  StreamSubscription<QuerySnapshot>? _meetupSubscription;
  List<Map<String, dynamic>> _loadedMeetups = [];
  bool _isMeetupsLoading = true;
  Object? _meetupsError;
  bool _showAllMeetups = false;
  Position? _devicePosition;
  bool _isListView = false;
  bool _isSubCategoryExpanded = false;

  void _resetAllMeetupFilters() {
    setState(() {
      _selectedCategoryIndex = 0;
      _selectedSubCategory = '전체';
      _selectedVibe = null;
      _isSubCategoryExpanded = false;
    });
  }

  final List<Map<String, dynamic>> _categories = [
    {'icon': '', 'name': '전체', 'desc': '실시간 전체 모임'},
    {'icon': '', 'name': '오늘 번개', 'desc': '오늘 바로 만나는 당일 번개'},
    {'icon': '', 'name': '이번 주말', 'desc': '주말 취향 아지트 모임'},
    {'icon': '', 'name': '카페·디저트', 'desc': '카페, 디저트, 베이커리 모임'},
    {'icon': '', 'name': '러닝', 'desc': '러닝, 운동, 산책 모임'},
    {'icon': '', 'name': '맛집', 'desc': '맛집 탐방, 소셜 다이닝 모임'},
  ];

  static const Map<String, List<String>> _officialSubCategories = {
    '오늘 번개': ['혼술바동행', '불금코노·술', '맛집털기', '오늘번개', '심야드라이브', '야식팟'],
    '이번 주말': ['공연·전시', '카페·디저트', '보드게임·방탈출', '북카페·독서', 'LP청음', '원데이클래스'],
    '카페·디저트': ['소금빵오픈런', '베이커리투어', '디저트카페', '핸드드립', '브런치'],
    '러닝': ['한강러닝', '트랙러닝', '야간러닝', '플로깅', '동네산책'],
    '맛집': ['노포탐방', '와인바', '소셜다이닝', '미식회', '오마카세'],
  };

  // 전국 시·도 및 읍면동 핫스팟 리스트
  static const Map<String, List<String>> _nationwideRegions = {
    '서울': [
      '영등포구 신길동',
      '영등포구 여의도동',
      '영등포구 문래동',
      '영등포구 당산동',
      '동작구 노량진동',
      '관악구 신림동',
      '마포구 서교동',
      '마포구 연남동',
      '마포구 망원동',
      '마포구 합정동',
      '성동구 성수동',
      '용산구 한남동',
      '용산구 이태원동',
      '강남구 신사동',
      '강남구 역삼동',
      '송파구 잠실동',
      '중구 을지로동',
      '종로구 익선동',
      '광진구 자양동(건대)',
    ],
    '경기/인천': [
      '성남시 분당구 판교동',
      '성남시 분당구 정자동',
      '수원시 영통구 광교동',
      '고양시 일산동구 장항동',
      '인천 연수구 송도동',
      '하남시 미사동',
      '용인시 수지구 풍덕천동',
      '안양시 동안구 평촌동',
      '부천시 원미구 중동',
    ],
    '부산/경상': [
      '부산 해운대구 우동',
      '부산 해운대구 중동',
      '부산 부산진구 전포동',
      '부산 수영구 광안동',
      '대구 수성구 범어동',
      '대구 중구 동성로',
      '울산 남구 삼산동',
      '창원시 성산구 상남동',
    ],
    '대전/충청': [
      '대전 유성구 봉명동',
      '대전 서구 둔산동',
      '세종시 나성동',
      '청주시 상당구 성안동',
      '천안시 서북구 불당동',
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
      '강릉시 교동',
      '속초시 조양동',
      '춘천시 효자동',
      '제주시 노형동',
      '제주시 연동',
      '제주시 아라동',
      '서귀포시 중문동',
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
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                            color: const Color(0xFFE5E5EA),
                            borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text('우리 동네 설정',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: textPrimary)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: const Color(0xFFFFF0EB),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text('전국 지원',
                              style: TextStyle(
                                  color: coralAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('내 위치를 공유하거나 원하는 동네를 검색해보세요.',
                        style: TextStyle(fontSize: 13, color: textSecondary)),
                    const SizedBox(height: 16),

                    // 1. GPS 현재 위치로 찾기 Button (실제 GPS + 역지오코딩 연동)
                    GestureDetector(
                      onTap: isGpsLocating
                          ? null
                          : () async {
                              setModalState(() => isGpsLocating = true);
                              final detected =
                                  await LocationHelper.getCurrentDongName();
                              setModalState(() => isGpsLocating = false);

                              if (detected != null && detected.isNotEmpty) {
                                setState(() {
                                  _currentLocation = detected;
                                });
                                globalData.updateLocation(detected);
                                _loadDevicePosition();
                                try {
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(globalData.activeUserId)
                                      .set({
                                    'location': detected,
                                    'updatedAt': FieldValue.serverTimestamp(),
                                  }, SetOptions(merge: true));
                                } catch (_) {}
                                if (!mounted) return;
                                if (ctx.mounted) Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.my_location,
                                            color: Colors.white, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                            child: Text(
                                                '📍 내 현재 위치 자동 할당 완료: $detected')),
                                      ],
                                    ),
                                    backgroundColor: coralAccent,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              } else {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          '⚠️ 위치 권한을 확인해주시거나 동네를 직접 검색해주세요.')),
                                );
                              }
                            },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF4EE), Color(0xFFFFECE5)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: coralAccent.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isGpsLocating)
                              const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Color(0xFFF25767)))
                            else
                              Icon(Icons.my_location,
                                  color: coralAccent, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              isGpsLocating
                                  ? 'GPS 위치 확인 및 동네 분석 중...'
                                  : '현재 위치로 동네 자동 찾기 (GPS 연동)',
                              style: TextStyle(
                                  color: coralAccent,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14),
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
                        hintStyle:
                            TextStyle(fontSize: 13, color: textSecondary),
                        prefixIcon: const Icon(Icons.search,
                            size: 20, color: Color(0xFF8E8E93)),
                        filled: true,
                        fillColor: surfaceColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none),
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
                              onTap: () =>
                                  setModalState(() => selectedRegionTab = reg),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? const Color(0xFF1E1E24)
                                      : surfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  reg,
                                  style: TextStyle(
                                    color: isSel ? Colors.white : textPrimary,
                                    fontWeight: isSel
                                        ? FontWeight.bold
                                        : FontWeight.w500,
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
                                  Icon(Icons.search_off,
                                      size: 40, color: textSecondary),
                                  const SizedBox(height: 8),
                                  Text('\'$searchQuery\' 검색 결과가 없습니다.',
                                      style: TextStyle(
                                          color: textSecondary, fontSize: 13)),
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
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  leading: Icon(
                                    Icons.location_on,
                                    color: isSelected
                                        ? coralAccent
                                        : const Color(0xFFC7C7CC),
                                    size: 20,
                                  ),
                                  title: Text(
                                    dong,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? coralAccent
                                          : textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(Icons.check_circle,
                                          color: coralAccent, size: 20)
                                      : null,
                                  onTap: () {
                                    setState(() => _currentLocation = dong);
                                    globalData.updateLocation(dong);
                                    try {
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(globalData.activeUserId)
                                          .set({
                                        'location': dong,
                                        'updatedAt':
                                            FieldValue.serverTimestamp(),
                                      }, SetOptions(merge: true));
                                    } catch (_) {}
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('📍 $dong(으)로 동네를 변경했어요')),
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
    if (globalData.userLocation.value.isNotEmpty) {
      _currentLocation = globalData.userLocation.value;
    }
    _homeDashboardTab = widget.initialTab;
    // Demo data must never be created as a side effect of opening production.
    if (const bool.fromEnvironment('OOMU_SEED_DEMO_DATA')) {
      _seedDatabase();
    }
    _loadUserLocation();
    _loadDevicePosition();
    globalData.userLocation.addListener(_onGlobalLocationChanged);
    globalData.currentUserId.addListener(_onActiveUserChanged);
    _subscribeMeetups();
  }

  @override
  void dispose() {
    _meetupSubscription?.cancel();
    globalData.userLocation.removeListener(_onGlobalLocationChanged);
    globalData.currentUserId.removeListener(_onActiveUserChanged);
    super.dispose();
  }

  void _subscribeMeetups() {
    _meetupSubscription?.cancel();
    if (Firebase.apps.isEmpty) {
      if (mounted) {
        setState(() {
          _isMeetupsLoading = false;
          _loadedMeetups = [];
          _meetupsError = null;
        });
      } else {
        _isMeetupsLoading = false;
        _loadedMeetups = [];
        _meetupsError = null;
      }
      return;
    }
    if (mounted) {
      setState(() {
        _isMeetupsLoading = _loadedMeetups.isEmpty;
        _meetupsError = null;
      });
    }
    try {
      _meetupSubscription = FirebaseFirestore.instance
          .collection('meetups')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .snapshots()
          .listen(
        (snapshot) {
          if (!mounted) return;
          final List<Map<String, dynamic>> items = [];
          for (final doc in snapshot.docs) {
            final data = Map<String, dynamic>.from(doc.data())..['id'] = doc.id;
            // 대표님 피드백 반영: 마포구 모임 맥락 일치 (강남역 보드게임 -> 홍대입구역 마포 보드게임 카페로 정정)
            if (data['title']?.toString().contains('강남역') == true &&
                data['title']?.toString().contains('보드게임') == true) {
              data['title'] = data['title'].toString().replaceAll('강남역', '홍대입구역');
              data['location'] = '서울 마포구 홍대입구역 9번 출구 레드버튼 앞';
              data['transport'] = '홍대입구역 9번 출구 집결';
            }
            items.add(data);
          }
          setState(() {
            _loadedMeetups = RegionalBotMeetupService.ensureMeetupsForLocation(
              _currentLocation,
              items,
              onEnriched: () {
                if (mounted) setState(() {});
              },
            );
            _isMeetupsLoading = false;
            _meetupsError = null;
          });
        },
        onError: (err) {
          if (!mounted) return;
          setState(() {
            _isMeetupsLoading = false;
            _meetupsError = err;
          });
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMeetupsLoading = false;
          _meetupsError = e;
        });
      } else {
        _isMeetupsLoading = false;
        _meetupsError = e;
      }
    }
  }

  Future<void> _seedDatabase() async {}
  int _locationLoadGeneration = 0;

  void _onActiveUserChanged() {
    if (mounted) {
      final targetLoc = globalData.userLocation.value.isNotEmpty
          ? globalData.userLocation.value
          : '마포구 서교동';
      if (_currentLocation != targetLoc) {
        setState(() {
          _currentLocation = targetLoc;
        });
      }
      _loadUserLocation();
    }
  }

  void _onGlobalLocationChanged() {
    if (!mounted) return;
    final targetLoc = globalData.userLocation.value.isNotEmpty
        ? globalData.userLocation.value
        : '마포구 서교동';
    if (_currentLocation != targetLoc) {
      setState(() {
        _currentLocation = targetLoc;
        _loadedMeetups = RegionalBotMeetupService.ensureMeetupsForLocation(
          _currentLocation,
          _loadedMeetups,
          onEnriched: () {
            if (mounted) setState(() {});
          },
        );
      });
    }
  }

  Future<void> _loadUserLocation() async {
    final int reqGen = ++_locationLoadGeneration;
    final int reqSession = globalData.sessionGeneration;
    if (Firebase.apps.isEmpty) return;
    try {
      final activeUid = globalData.activeUserId;
      final uid = (activeUid.isNotEmpty && activeUid != 'guest')
          ? activeUid
          : (FirebaseAuth.instance.currentUser?.uid ?? '');
      if (uid.isNotEmpty && uid != 'guest') {
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (!mounted ||
            reqGen != _locationLoadGeneration ||
            !globalData.isActiveSession(reqSession, uid)) {
          return;
        }
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final loc = data['location'] as String?;
          if (loc != null && loc.trim().isNotEmpty) {
            final trimmedLoc = loc.trim();
            if (mounted) {
              setState(() {
                _currentLocation = trimmedLoc;
              });
            }
            globalData.userLocation.value = trimmedLoc;
          }
          final nick = data['nickname'] as String?;
          if (nick != null && nick.trim().isNotEmpty) {
            globalData.userNickname.value = nick.trim();
          }
          final avatar = (data['photoUrl'] ??
                  data['profileImage'] ??
                  data['avatarUrl'] ??
                  data['authorAvatar'])
              ?.toString()
              .trim();
          if (avatar != null && avatar.isNotEmpty) {
            globalData.userAvatar.value = avatar;
          }
        }
      }
    } catch (e) {
      debugPrint('[HomeScreen] _loadUserLocation error: $e');
    }
  }

  Future<void> _loadDevicePosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(timeLimit: Duration(seconds: 6)),
      );
      if (mounted) {
        setState(() => _devicePosition = position);
      }
    } catch (_) {
      // Permission, GPS and web browser errors leave distance hidden.
    }
  }

  String? _meetupDistance(Map<String, dynamic> meetup,
      {({double lat, double lng})? resolvedCoords}) {
    final position = _devicePosition;
    final coords = OomuUiHelpers.extractValidCoords(meetup) ?? resolvedCoords;
    if (position == null || coords == null) return null;
    final meters = KakaoMapService.calculateDistanceInMeters(
      position.latitude,
      position.longitude,
      coords.lat,
      coords.lng,
    );
    return '내 위치에서 ${KakaoMapService.formatDistance(meters)}';
  }

  void _showAllTrendsBottomSheet(
      BuildContext context, List<Map<String, dynamic>> items) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: OomuTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(OomuTokens.r24)),
      ),
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: items.isNotEmpty
                ? Future.value(items)
                : (Firebase.apps.isNotEmpty
                    ? FirebaseFirestore.instance
                        .collection('trend_events')
                        .limit(50)
                        .get()
                        .then((snap) => snap.docs.map((d) {
                              final data = Map<String, dynamic>.from(d.data());
                              data['id'] = d.id;
                              return data;
                            }).toList())
                        .catchError((_) => <Map<String, dynamic>>[])
                    : Future.value(<Map<String, dynamic>>[])),
            builder: (ctx, snapshot) {
              final resolvedItems = snapshot.data ?? items;
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: OomuTokens.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '우리 동네 인기 트렌드 전체',
                          style: TextStyle(
                            fontSize: OomuTokens.fs18,
                            fontWeight: FontWeight.bold,
                            color: OomuTokens.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: OomuTokens.textSecondary),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: OomuTokens.border),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: resolvedItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final item = resolvedItems[i];
                        final title = OomuUiHelpers.formatTitle(
                            (item['title'] ?? '').toString());
                        final rawLoc = (item['location'] ??
                                item['place'] ??
                                item['region'] ??
                                '')
                            .toString()
                            .trim();
                        final location = rawLoc.isNotEmpty ? rawLoc : '지역 미확인';
                        final category =
                            (item['category'] ?? item['tag'] ?? '').toString();
                        final period = (item['period'] ?? '').toString();
                        final poster =
                            (item['poster'] ?? 'assets/images/cover_food.jpg')
                                .toString();

                        return InkWell(
                          borderRadius: BorderRadius.circular(OomuTokens.r12),
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EventDetailScreen(event: item),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: OomuTokens.surface,
                              borderRadius:
                                  BorderRadius.circular(OomuTokens.r12),
                              border: Border.all(color: OomuTokens.border),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(OomuTokens.r8),
                                  child: SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: Image(
                                      image: appImg(poster),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Image.asset(
                                        'assets/images/cover_food.jpg',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (category.isNotEmpty) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: OomuTokens.primarySubtle,
                                            borderRadius: BorderRadius.circular(
                                                OomuTokens.r4),
                                          ),
                                          child: Text(
                                            category,
                                            style: const TextStyle(
                                              fontSize: OomuTokens.fs11,
                                              fontWeight: FontWeight.bold,
                                              color: OomuTokens.coral,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                      ],
                                      Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: OomuTokens.fs15,
                                          fontWeight: FontWeight.w700,
                                          color: OomuTokens.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.place_outlined,
                                              size: 13,
                                              color: OomuTokens.textSecondary),
                                          const SizedBox(width: 2),
                                          Flexible(
                                            child: Text(
                                              location,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: OomuTokens.fs12,
                                                color: OomuTokens.textSecondary,
                                              ),
                                            ),
                                          ),
                                          if (period.isNotEmpty) ...[
                                            const SizedBox(width: 8),
                                            Text(
                                              period,
                                              style: const TextStyle(
                                                fontSize: OomuTokens.fs11,
                                                color: OomuTokens.textMuted,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showFullCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5EA),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OOMU 카테고리 전체 체계도',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '대분류 ➔ 중분류 ➔ 소분류로 원하는 모임을 탐색하세요',
                            style:
                                TextStyle(fontSize: 12, color: textSecondary),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {
                              _resetAllMeetupFilters();
                              Navigator.pop(ctx);
                            },
                            child: Text(
                              '필터 초기화',
                              style: TextStyle(
                                color: coralAccent,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    children: [
                      Text('지금 내 상황',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textPrimary)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: OOMUCategoryData.vibes.map((v) {
                          final isSelected = _selectedVibe == v.title;
                          return ChoiceChip(
                            label: Text(v.title),
                            selected: isSelected,
                            selectedColor: const Color(0xFFFFECE5),
                            labelStyle: TextStyle(
                              color: isSelected ? coralAccent : textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            onSelected: (val) {
                              setState(() {
                                _selectedVibe = val ? v.title : null;
                              });
                              Navigator.pop(ctx);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Text('전체 카테고리',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textPrimary)),
                      const SizedBox(height: 12),
                      ...OOMUCategoryData.mainCategories.map((mainCat) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEBEBEF)),
                          ),
                          child: Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              initiallyExpanded: true,
                              leading: Icon(mainCat.iconData,
                                  size: 22, color: OomuTokens.textSecondary),
                              title: Text(
                                mainCat.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: textPrimary),
                              ),
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: mainCat.subCategories.map((sub) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                int mappedCatIdx = 0;
                                                if (mainCat.id == 'food') {
                                                  mappedCatIdx =
                                                      sub.name.contains('생활')
                                                          ? 3
                                                          : 1;
                                                } else if (mainCat.id ==
                                                        'culture' ||
                                                    mainCat.id == 'game' ||
                                                    mainCat.id == 'hobby') {
                                                  mappedCatIdx = 2;
                                                } else if (mainCat.id ==
                                                        'activity' ||
                                                    mainCat.id == 'travel') {
                                                  mappedCatIdx = 3;
                                                }
                                                setState(() {
                                                  _selectedCategoryIndex =
                                                      mappedCatIdx;
                                                  _selectedSubCategory = '전체';
                                                  _selectedVibe = null;
                                                  _isSubCategoryExpanded =
                                                      false;
                                                });
                                                Navigator.pop(ctx);
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .subdirectory_arrow_right,
                                                      size: 16,
                                                      color: coralAccent),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    sub.name,
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: textPrimary),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              children:
                                                  sub.exampleTags.map((tag) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    int mappedCatIdx = 0;
                                                    if (mainCat.id == 'food') {
                                                      mappedCatIdx = sub.name
                                                              .contains('생활')
                                                          ? 3
                                                          : 1;
                                                    } else if (mainCat.id ==
                                                            'culture' ||
                                                        mainCat.id == 'game' ||
                                                        mainCat.id == 'hobby') {
                                                      mappedCatIdx = 2;
                                                    } else if (mainCat.id ==
                                                            'activity' ||
                                                        mainCat.id ==
                                                            'travel') {
                                                      mappedCatIdx = 3;
                                                    }
                                                    setState(() {
                                                      _selectedCategoryIndex =
                                                          mappedCatIdx;
                                                      _selectedSubCategory =
                                                          '전체';
                                                      _selectedVibe = null;
                                                      _isSubCategoryExpanded =
                                                          false;
                                                    });
                                                    Navigator.pop(ctx);
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                          color: const Color(
                                                              0xFFE4E4EB)),
                                                    ),
                                                    child: Text('#$tag',
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            color:
                                                                textSecondary)),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _matchesFilters(Map<String, dynamic> item) {
    final title = (item['title'] ?? '').toString();
    // 0. QA 테스트 또는 임시 더미 모임은 라이브 피드에서 원천 배제
    if (title.contains('[QA테스트]') ||
        title.contains('테스트 모임') ||
        title.contains('[테스트]')) {
      return false;
    }

    final host = (item['host'] ?? '').toString();
    final hostUid =
        (item['hostUid'] ?? item['userId'] ?? item['creatorId'] ?? '')
            .toString();
    if (globalData.isTargetBlocked(uid: hostUid, nickname: host)) {
      return false;
    }

    final itemLoc = (item['location'] ?? '').toString();
    if (!OomuUiHelpers.matchesRegionFilter(_currentLocation, itemLoc)) {
      return false;
    }

    // 1. Category Filter (대분류 & 서브태그)
    if (_selectedCategoryIndex > 0) {
      final selectedCat = _categories[_selectedCategoryIndex]['name'] as String;

      // [오늘 번개 기준]: 오늘 일정 (당일 만남, 오늘 날짜 기준 번개에 도래하는 것)
      if (selectedCat == '오늘 번개') {
        final dateStr = (item['date'] ?? '').toString();
        final now = DateTime.now();
        final todayStr1 =
            '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
        final todayStr2 =
            '${(now.year % 100).toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
        final bool isTodayDate = dateStr.contains('오늘') ||
            dateStr.contains('당일') ||
            dateStr.contains('즉시') ||
            dateStr.contains(todayStr1) ||
            dateStr.contains(todayStr2) ||
            item['isLightning'] == true;
        final bool hasLightningKeyword = (item['category'] ?? '')
                .toString()
                .contains('번개') ||
            (item['title'] ?? '').toString().contains('번개') ||
            ((item['tags'] as List?)?.any((t) => t.toString().contains('번개')) ??
                false);
        if (!isTodayDate && !hasLightningKeyword) {
          return false;
        }
      }

      final bool hasVibe = OOMUCategoryData.hasVibe(selectedCat);
      final bool vibeMatch =
          hasVibe && OOMUCategoryData.matchesVibe(item, selectedCat);
      final bool filterMatch = OOMUCategoryData.matchesFilter(
          item, selectedCat, _selectedSubCategory);

      // 서브태그가 '전체'일 때는 바이브 매칭이나 필터 매칭 둘 중 하나라도 통과하면 OK
      if (_selectedSubCategory == '전체') {
        if (!vibeMatch && !filterMatch) return false;
      } else {
        // 특정 서브태그 선택 시 해당 태그 매칭 검사
        final cat = (item['category'] ?? '').toString();
        final mainCatField = (item['mainCategory'] ?? '').toString();
        final title = (item['title'] ?? '').toString();
        final desc = (item['description'] ?? '').toString();
        final tags =
            (item['tags'] as List?)?.map((t) => t.toString()).toList() ?? [];
        final allText =
            '$cat $mainCatField $title $desc ${tags.join(' ')}'.toLowerCase();

        final sub = _selectedSubCategory.toLowerCase();
        if (!allText.contains(sub) && !filterMatch) {
          return false;
        }
      }
    } else if (_selectedSubCategory != '전체') {
      if (!OOMUCategoryData.matchesFilter(item, '전체', _selectedSubCategory)) {
        return false;
      }
    }

    // 2. Vibe Filter (상황별 필터)
    if (_selectedVibe != null) {
      if (!OOMUCategoryData.matchesVibe(item, _selectedVibe!)) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OomuTokens.background,
      appBar: _homeDashboardTab == 0
          ? HomeHeaderAppBar(
              currentLocation: _currentLocation,
              onLocationTap: _showLocationPickerBottomSheet,
              onNotificationTabSelected: (tab) {
                if (mounted) setState(() => _homeDashboardTab = tab);
              },
            )
          : null,
      body: _homeDashboardTab == 0
          ? _buildMeetupDashboard()
          : (_homeDashboardTab == 1
              ? _buildCommunityDashboard()
              : (_homeDashboardTab == 2
                  ? _buildDiscoveryDashboard()
                  : (_homeDashboardTab == 3
                      ? ChatScreen(
                          isEmbedded: true,
                          onExplore: () =>
                              setState(() => _homeDashboardTab = 0))
                      : const MyPageScreen(isEmbedded: true)))),
      floatingActionButton: _homeDashboardTab == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        OOMUHostScreen(initialLocation: _currentLocation),
                  ),
                );
              },
              backgroundColor: OomuTokens.textPrimary,
              foregroundColor: Colors.white,
              elevation: 1,
              highlightElevation: 2,
              shape: const StadiumBorder(),
              tooltip: '새 모임 열기',
              icon: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white,
                child: Icon(Icons.event_available_outlined, color: OomuTokens.textPrimary, size: 16),
              ),
              label: const Text(
                '모임 열기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: OomuTokens.fontFamily,
                ),
              ),
            )
          : null,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildMeetupDashboard() {
    return CustomScrollView(
      slivers: [
        // 1. 카테고리 탭 & 서브태그 바
        SliverToBoxAdapter(
          child: HomeCategoryTabs(
            categories: _categories,
            selectedCategoryIndex: _selectedCategoryIndex,
            selectedSubCategory: _selectedSubCategory,
            selectedVibe: _selectedVibe,
            isSubCategoryExpanded: _isSubCategoryExpanded,
            onCategorySelected: (idx) {
              setState(() {
                _selectedCategoryIndex = idx;
                _selectedSubCategory = '전체';
                _selectedVibe = null;
                _isSubCategoryExpanded = false;
              });
            },
            onSubCategorySelected: (sub) {
              setState(() => _selectedSubCategory = sub);
            },
            onResetFilters: _resetAllMeetupFilters,
            onToggleSubCategoryExpanded: () {
              setState(() => _isSubCategoryExpanded = !_isSubCategoryExpanded);
            },
            onClearVibe: () => setState(() => _selectedVibe = null),
            onShowFullCategories: _showFullCategoryBottomSheet,
            officialSubCategories: _officialSubCategories,
          ),
        ),

        // 2. 오늘 번개 탭 진입 시 실시간 캐러셀 노출
        if (_selectedCategoryIndex == 1)
          SliverToBoxAdapter(
            child: HomeLightningSection(
              spots: _getLiveSpotsForLocation(_currentLocation),
              onSpotTap: (spot) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SoSoSpotDetailScreen(spot: spot),
                  ),
                );
              },
            ),
          ),

        // 3. 메인 모임 피드 (Firestore Real meetups + OomuMeetupCard)
        SliverToBoxAdapter(
          child: _buildMeetupSectionContent(),
        ),

        // 4. 동네 문화 행사·핫플 큐레이션 (모든 카테고리 탭에서 항상 렌더)
        SliverToBoxAdapter(
          child: HomeDiscoverySection(
            items: const [],
            currentLocation: _currentLocation,
            onShowAllBottomSheet: () =>
                _showAllTrendsBottomSheet(context, const []),
          ),
        ),

        // 하단 여백: 플로팅 버튼('모임 열기')과 바텀 네비게이션에 콘텐츠가 가려지지 않도록 넉넉하게 110px 확보
        const SliverToBoxAdapter(child: SizedBox(height: 110)),
      ],
    );
  }

  Widget _buildCommunityDashboard() {
    return HomeCommunitySection(
      currentLocation: _currentLocation,
      initialPosts: _getActiveCommunityPosts(),
    );
  }

  Widget _buildDiscoveryDashboard() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 110, top: 8),
      children: [
        OomuDiscoveryLifestyleHub(currentLocation: _currentLocation),
      ],
    );
  }

  String _meetupCoverImage(Map<String, dynamic> meetup) {
    final source = (meetup['imageUrl'] ?? '').toString();
    final title = (meetup['title'] ?? '').toString();
    // 비정상적인 단색 base64 더미 이미지인 경우 실제 고화질 커버 에셋으로 안전 대체
    if (source.startsWith('data:image') && source.length < 5000) {
      if (title.contains('카페') ||
          title.contains('디저트') ||
          title.contains('커피')) {
        return 'assets/images/cover_cafe.jpg';
      }
      if (title.contains('와인') || title.contains('맥주') || title.contains('술')) {
        return 'assets/images/cover_wine.jpg';
      }
      return 'assets/images/cover_food.jpg';
    }
    if ((title.contains('소금빵') || source.contains('salt_bread')) &&
        (source == 'assets/images/cover_cafe.jpg' ||
            source.contains('salt_bread'))) {
      return 'assets/images/cover_salt_bread.jpg';
    }
    final location = (meetup['location'] ?? '').toString();
    final isSeoulArea = location.contains('서울') ||
        location.contains('마포') ||
        location.contains('망원') ||
        location.contains('한강');
    if ((source == 'assets/images/cover_running.jpg' ||
            source.contains('running_hangang') ||
            (source.contains('run') && isSeoulArea)) &&
        isSeoulArea) {
      return 'assets/images/cover_running_hangang.jpg';
    }
    return source.isEmpty ? 'assets/images/cover_food.jpg' : source;
  }

  Map<String, dynamic> _meetupForDetail(Map<String, dynamic> meetup) {
    final image = _meetupCoverImage(meetup);
    return {
      ...meetup,
      'imageUrl': image,
      'coverIsIllustrative': image == 'assets/images/cover_salt_bread.jpg',
    };
  }

  Widget _buildMeetupSectionContent() {
    if (_meetupsError != null && _loadedMeetups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.refresh_rounded,
                  size: 40, color: OomuTokens.textSecondary),
              const SizedBox(height: 12),
              const Text(
                '모임 목록을 불러오지 못했어요.',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: OomuTokens.textPrimary),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _subscribeMeetups,
                child: const Text('다시 시도하기',
                    style: TextStyle(
                        color: OomuTokens.coral, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    if (_isMeetupsLoading && _loadedMeetups.isEmpty) {
      return HomeMeetupSection(
        currentLocation: _currentLocation,
        selectedCategoryIndex: _selectedCategoryIndex,
        selectedSubCategory: _selectedSubCategory,
        selectedVibe: _selectedVibe,
        isListView: _isListView,
        isLoading: true,
        meetups: const [],
        showAllMeetups: _showAllMeetups,
        onToggleView: (val) => setState(() => _isListView = val),
        onToggleShowAll: () =>
            setState(() => _showAllMeetups = !_showAllMeetups),
        onMeetupTap: (meetup) {},
        onResetFilters: _resetAllMeetupFilters,
      );
    }

    final filteredDocs =
        _loadedMeetups.where((data) => _matchesFilters(data)).map((m) {
      final copy = Map<String, dynamic>.from(m);
      copy['distance'] ??= _meetupDistance(copy);
      return copy;
    }).toList();

    filteredDocs.sort((dataA, dataB) {
      final scoreA =
          _calculateLocationRelevanceScore(dataA['location']?.toString() ?? '');
      final scoreB =
          _calculateLocationRelevanceScore(dataB['location']?.toString() ?? '');
      if (scoreA != scoreB) {
        return scoreB.compareTo(scoreA);
      }
      return compareFirestoreTimes(dataA['createdAt'], dataB['createdAt']);
    });

    return HomeMeetupSection(
      currentLocation: _currentLocation,
      selectedCategoryIndex: _selectedCategoryIndex,
      selectedSubCategory: _selectedSubCategory,
      selectedVibe: _selectedVibe,
      isListView: _isListView,
      isLoading: false,
      meetups: filteredDocs,
      showAllMeetups: _showAllMeetups,
      onToggleView: (val) => setState(() => _isListView = val),
      onToggleShowAll: () => setState(() => _showAllMeetups = !_showAllMeetups),
      onMeetupTap: (meetup) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OOMUDetailScreen(
              meetup: _meetupForDetail(meetup),
            ),
          ),
        );
      },
      onResetFilters: _resetAllMeetupFilters,
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: OomuTokens.border, width: 1),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _homeDashboardTab.clamp(0, 4),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: OomuTokens.textPrimary,
          unselectedItemColor: OomuTokens.textMuted,
          showUnselectedLabels: true,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          elevation: 0,
          backgroundColor: Colors.white,
          onTap: (index) {
            OomuHaptics.selection();
            if (index == 3) {
              oomuChatStore.syncWithCurrentUser();
            }
            setState(() {
              _homeDashboardTab = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 23),
              activeIcon: Icon(Icons.home_rounded, size: 23),
              label: '동네모임',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined, size: 23),
              activeIcon: Icon(Icons.group_rounded, size: 23),
              label: '커뮤니티',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined, size: 23),
              activeIcon: Icon(Icons.explore_rounded, size: 23),
              label: '발견',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded, size: 22),
              activeIcon: Icon(Icons.chat_bubble_rounded, size: 22),
              label: '채팅',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded, size: 23),
              activeIcon: Icon(Icons.person_rounded, size: 23),
              label: 'MY',
            ),
          ],
        ),
      ),
    );
  }
}
