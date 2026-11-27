import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../services/discovery_api_service.dart';
import '../services/naver_map_service.dart';
import '../ui/oomu_tokens.dart';
import '../utils/app_image.dart';
import '../utils/oomu_ui_helpers.dart';
import 'balanced_text.dart';
import 'bouncy_tap.dart';
import 'balanced_heading.dart';

/// 발견(Discovery) 탭 전용 에이블리(ABLY) 스타일 동네 큐레이션 허브
/// - 동네모임 탭과 명확히 차별화하여 '우리 동네에만 있는 할인·이벤트·날씨 맞춤 맛집/레시피·청년지원금·트렌드'를
///   에이블리 스타일 원형 아이콘 카테고리 + 2열 블럭/리스트 뷰로 정돈해 보여줍니다.
/// - 레시피/맛집 상세 모달에서는 비 오는 날 모임 개설 유도를 제거하고,
///   상세 레시피 조리법과 동네 근처 식당 추천(네이버 지도 연동)을 제공합니다.
class OomuDiscoveryLifestyleHub extends StatefulWidget {
  final String currentLocation;
  final int initialCategoryIndex;

  const OomuDiscoveryLifestyleHub({
    super.key,
    required this.currentLocation,
    this.initialCategoryIndex = 0,
  });

  @override
  State<OomuDiscoveryLifestyleHub> createState() =>
      _OomuDiscoveryLifestyleHubState();
}

class _OomuDiscoveryLifestyleHubState extends State<OomuDiscoveryLifestyleHub> {
  // docs/OOMU_UI_GUIDE.md 공식 컬러 토큰
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color subtleSurface = Color(0xFFF2F4F7);
  static const Color borderSlate = Color(0xFFEAECF0);
  static const Color textPrimary = Color(0xFF191F28);
  static const Color textBody = Color(0xFF333D4B);
  static const Color textSecondary = Color(0xFF6B7684);
  static const Color textMuted = Color(0xFF8B95A1);
  static const Color brandCoral = Color(0xFFF25767);
  static const Color brandTint = Color(0xFFFFF0F2);

  final DiscoveryApiService _service = DiscoveryApiService.instance;

  // 에이블리 스타일 상단 메인 카테고리 인덱스
  // 0: 전체추천 | 1: 날씨·맛집 | 2: 할인·이벤트 | 3: 청년지원금 | 4: 요즘트렌드 | 5: 놀거리·운세
  late int _selectedAblyCategory;
  bool _isGridView = true; // true: 에이블리 2열 블럭형, false: 리스트형

  // API 데이터 상태
  WeatherMoodRecipe? _weatherRecipe;
  List<TrendMovieItem> _movies = const [];
  List<FashionDietTrendItem> _fashionDietItems = const [];
  List<CountrySpotItem> _countries = const [];
  List<Map<String, dynamic>> _realTrendEvents = const [];
  List<Map<String, dynamic>> _liveLocalFoodSpots = const [];
  List<Map<String, dynamic>> _naverRealtimeTrends = const [
    {
      'rank': 1,
      'keyword': '고프코어 러닝화 & 바람막이 코디',
      'category': '패션·쇼핑',
      'change': '▲ 4'
    },
    {
      'rank': 2,
      'keyword': '무알콜 하이볼 & 싱글몰트 위스키바',
      'category': '맛집·핫플',
      'change': 'HOT'
    },
    {
      'rank': 3,
      'keyword': '저속노화 아보카도 연어 포케 식단',
      'category': '다이어트·건강',
      'change': '▲ 2'
    },
    {
      'rank': 4,
      'keyword': '퇴근 후 도자기·드로잉 원데이클래스',
      'category': '취미·라이프',
      'change': 'NEW'
    },
    {
      'rank': 5,
      'keyword': '화덕피자 & 내추럴와인 비스트로',
      'category': '맛집·핫플',
      'change': '▲ 3'
    },
    {
      'rank': 6,
      'keyword': '야간 공원 4km 슬로우 러닝',
      'category': '운동·액티비티',
      'change': 'HOT'
    },
    {
      'rank': 7,
      'keyword': '빈티지 필름카메라 동네 출사',
      'category': '취미·라이프',
      'change': '▲ 1'
    },
    {
      'rank': 8,
      'keyword': '직장인 북카페 & 독립서점 투어',
      'category': '문화·트렌드',
      'change': '▲ 2'
    },
    {
      'rank': 9,
      'keyword': 'LP 바이닐 바 & 시티팝 청음',
      'category': '문화·트렌드',
      'change': 'NEW'
    },
    {
      'rank': 10,
      'keyword': '수제 소금빵 & 피스타치오 디저트',
      'category': '맛집·핫플',
      'change': '▲ 1'
    },
  ];
  bool _isTrendsExpanded = false;

  // 놀거리·운세 인터랙티브 미니게임 상태
  final Map<int, bool> _tarotFlipped = {0: false, 1: false, 2: false};
  int? _balanceVote;
  int _balanceVotesA = 154;
  int _balanceVotesB = 128;

  static const List<Map<String, dynamic>> _ablyCategories = [
    {
      'iconData': Icons.auto_awesome_outlined,
      'label': '전체추천',
      'sub': '우리 동네 인기 발견'
    },
    {
      'iconData': Icons.restaurant_outlined,
      'label': '날씨·맛집',
      'sub': '동네 로컬맛집·다이닝'
    },
    {
      'iconData': Icons.local_offer_outlined,
      'label': '할인·이벤트',
      'sub': '동네 가게 특가·혜택'
    },
    {
      'iconData': Icons.account_balance_wallet_outlined,
      'label': '청년지원금',
      'sub': '월세·교통·문화 지원'
    },
    {'iconData': Icons.movie_outlined, 'label': '요즘트렌드', 'sub': '영화·패션·다이어트'},
    {'iconData': Icons.casino_outlined, 'label': '놀거리·운세', 'sub': '타로·밸런스 배틀'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedAblyCategory = widget.initialCategoryIndex;
    _fashionDietItems = _service.getFashionAndDietTrends();
    _loadAllDiscoveryData();
  }

  @override
  void didUpdateWidget(covariant OomuDiscoveryLifestyleHub oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLocation != widget.currentLocation) {
      _loadWeatherAndRecipes();
      _loadLiveNeighborhoodFoodSpots();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadAllDiscoveryData() async {
    _loadWeatherAndRecipes();
    _loadLiveNeighborhoodFoodSpots();
    _loadNaverRealtimeTrends();
    _loadMoviesAndCountries();
  }

  Future<void> _loadNaverRealtimeTrends() async {
    if (Firebase.apps.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('naver_trends')
          .get()
          .timeout(const Duration(seconds: 3));
      if (!mounted || !doc.exists || doc.data() == null) return;
      final items = doc.data()!['items'];
      if (items is List && items.isNotEmpty) {
        final parsed = items
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        if (parsed.isNotEmpty) {
          setState(() {
            _naverRealtimeTrends = parsed;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _loadLiveNeighborhoodFoodSpots() async {
    final dong = _dongLabel;
    try {
      final places = await NaverMapService.searchKeyword(
        '$dong 맛집',
        size: 6,
      );
      if (!mounted || places.isEmpty) return;
      final images = [
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&q=80',
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80',
        'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800&q=80',
        'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&q=80',
      ];
      final badges = ['$_dongLabel 실시간 인기', '퇴근 후 추천', '로컬 찐맛집', '분위기 다이닝'];
      final List<Map<String, dynamic>> mapped = [];
      for (int i = 0; i < places.length && i < 4; i++) {
        final p = places[i];
        final distLabel = NaverMapService.formatDistanceFromNeighborhood(
          p.lat,
          p.lng,
          userLocation: widget.currentLocation,
        );
        mapped.add({
          'id': 'live_food_${p.id}',
          'badge': badges[i % badges.length],
          'category': '날씨·맛집',
          'shortLabel': p.name,
          'title': '${p.name} (${p.category})',
          'subtitle':
              '${p.roadAddress.isNotEmpty ? p.roadAddress : p.address} · $_dongLabel 이웃들이 자주 찾는 로컬 맛집',
          'benefit': '$_dongLabel 동네 모임 추천 스팟 · 네이버 지도 길찾기 연동',
          'placeName': '${p.name} ${p.address}',
          'distance': distLabel,
          'hours': p.phone.isNotEmpty ? '전화: ${p.phone}' : '매일 11:30 - 22:30',
          'image': images[i % images.length],
          'lat': p.lat,
          'lng': p.lng,
          'menus': [
            '${p.category} 시그니처 메뉴',
            '2~4인 동네 소셜 다이닝 추천',
            '네이버 지도 위치 및 리뷰 확인 가능',
          ],
        });
      }
      if (mounted && mapped.isNotEmpty) {
        setState(() {
          _liveLocalFoodSpots = mapped;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadWeatherAndRecipes() async {
    final res = await _service.fetchWeatherAndRecipes(widget.currentLocation);
    if (mounted) {
      setState(() {
        _weatherRecipe = res;
      });
    }
  }

  Future<void> _loadMoviesAndCountries() async {
    final results = await Future.wait([
      _service.fetchTrendMovies().catchError((_) => const <TrendMovieItem>[]),
      _service
          .fetchTravelCountries()
          .catchError((_) => const <CountrySpotItem>[]),
      _service
          .fetchRealTrendEvents()
          .catchError((_) => const <Map<String, dynamic>>[]),
    ]);
    if (mounted) {
      setState(() {
        _movies = results[0] as List<TrendMovieItem>;
        _countries = results[1] as List<CountrySpotItem>;
        _realTrendEvents = results[2] as List<Map<String, dynamic>>;
      });
    }
  }

  String get _dongLabel {
    final parts = widget.currentLocation.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.last : '우리 동네';
  }

  bool get _isYeosu =>
      widget.currentLocation.contains('여수') ||
      widget.currentLocation.contains('화장동');

  // ---------------------------------------------------------------------------
  // 동네 전용 큐레이션 데이터 (실시간 네이버 지도 맛집 연동 + 동네별 맞춤 다이닝 폴백)
  // ---------------------------------------------------------------------------
  List<Map<String, dynamic>> _getLocalFoodSpots() {
    if (_liveLocalFoodSpots.isNotEmpty) {
      return _liveLocalFoodSpots;
    }
    final dong = _dongLabel;
    if (_isYeosu) {
      return [
        {
          'id': 'food_yeosu_1',
          'badge': '$dong 오션뷰 인기',
          'category': '날씨·맛집',
          'shortLabel': '선소 수제버거 & 브런치',
          'title': '화장동·학동 선소 오션뷰 수제버거 & 브런치 다이닝',
          'subtitle': '바닷바람 쐬며 즐기는 수제 비프버거와 화덕 브런치 플래터 맛집',
          'benefit': '아메리카노 세트 2,000원 할인 · 1인 14,500원',
          'placeName': '여수 학동 선소 브런치 카페',
          'distance': '$dong 기준 380m · 도보 5분',
          'hours': '매일 10:30 - 22:00',
          'image':
              'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&q=80',
          'menus': [
            '시그니처 아보카도 수제버거 13,500원',
            '트러플 감자튀김 & 에이드 8,500원',
            '바질 페스토 파스타 16,000원'
          ],
        },
        {
          'id': 'food_yeosu_2',
          'badge': '퇴근 후 하이볼 명소',
          'category': '날씨·맛집',
          'shortLabel': '학동 숙성회 & 하이볼 바',
          'title': '학동 부영3단지 골목 숙성 연어·사시미 & 하이볼 이자카야',
          'subtitle': '도란도란 대화 나누기 좋은 감성 조명과 여수 제철 해산물 다이닝',
          'benefit': '2인 모둠 사시미 주문 시 유자 하이볼 1잔 서비스',
          'placeName': '여수 학동 이자카야 다이닝',
          'distance': '$dong 기준 520m · 도보 7분',
          'hours': '매일 17:30 - 01:00',
          'image':
              'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80',
          'menus': [
            '숙성 사시미 2인 플레이트 34,000원',
            '해물 나베 전골 23,000원',
            '얼그레이 하이볼 7,500원'
          ],
        },
        {
          'id': 'food_yeosu_3',
          'badge': '주말 소셜 다이닝',
          'category': '날씨·맛집',
          'shortLabel': '웅천 화덕피자 & 와인',
          'title': '화장동·웅천 루프탑 화덕피자 & 내추럴 와인 비스트로',
          'subtitle': '참나무 화덕에서 갓 구운 루꼴라 피자와 글라스 와인을 즐기는 핫플',
          'benefit': '피자 + 파스타 2인 페어링 세트 36,000원',
          'placeName': '여수 화덕피자 와인바',
          'distance': '$dong 기준 1.2km · 차량 5분',
          'hours': '매일 11:30 - 23:00',
          'image':
              'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800&q=80',
          'menus': [
            '부라타 치즈 루꼴라 화덕피자 21,000원',
            '해산물 오일 파스타 17,000원',
            '하우스 글라스 와인 8,000원'
          ],
        },
      ];
    }
    return [
      {
        'id': 'food_seoul_1',
        'badge': '$dong 직장인 인기 1위',
        'category': '날씨·맛집',
        'shortLabel': '$dong 화덕피자 & 와인바',
        'title': '$dong 골목 감성 화덕피자 & 내추럴 와인 비스트로',
        'subtitle': '퇴근 후 동네 이웃과 가볍게 글라스 와인·하이볼 한잔하기 좋은 캐주얼 다이닝',
        'benefit': '저녁 8시 이전 방문 시 트러플 감자튀김 서비스',
        'placeName': '${widget.currentLocation} 화덕피자 와인바',
        'distance': '$dong 기준 320m · 도보 4분',
        'hours': '매일 17:00 - 24:00',
        'image':
            'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&q=80',
        'menus': [
          '부라타 프로슈토 화덕피자 21,000원',
          '바질 생면 파스타 17,500원',
          '글라스 와인·하이볼 8,000원'
        ],
      },
      {
        'id': 'food_seoul_2',
        'badge': '퇴근 후 소셜 다이닝',
        'category': '날씨·맛집',
        'shortLabel': '$dong 수제버거 & 탭하우스',
        'title': '$dong 아메리칸 수제버거 & 크래프트비어 탭하우스',
        'subtitle': '육즙 가득 스매쉬 치즈버거와 시원한 수제 에일 맥주를 즐기는 로컬 핫플',
        'benefit': '버거 + 수제맥주 샘플러 세트 1,500원 할인',
        'placeName': '${widget.currentLocation} 수제버거 수제맥주',
        'distance': '$dong 기준 450m · 도보 6분',
        'hours': '매일 11:30 - 23:30',
        'image':
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80',
        'menus': [
          '더블 스매쉬 치즈버거 11,800원',
          '칠리 치즈 프라이 7,500원',
          '페일에일·바이젠 생맥주 6,500원'
        ],
      },
      {
        'id': 'food_seoul_3',
        'badge': '$dong 로컬 찐맛집',
        'category': '날씨·맛집',
        'shortLabel': '$dong 숙성사시미 & 이자카야',
        'title': '$dong 역세권 숙성 연어사시미 & 모츠나베 심야식당',
        'subtitle': '선선한 저녁 따뜻한 전골 국물과 신선한 사시미로 소규모 모임하기 좋은 곳',
        'benefit': '모츠나베 주문 시 우동사리 무료 추가',
        'placeName': '${widget.currentLocation} 이자카야 모츠나베',
        'distance': '$dong 기준 390m · 도보 5분',
        'hours': '매일 17:30 - 01:00',
        'image':
            'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800&q=80',
        'menus': [
          '후쿠오카식 한우 모츠나베 25,000원',
          '생연어 사시미 22,000원',
          '유자·얼그레이 하이볼 7,500원'
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getLocalDiscountEvents() {
    // 가짜 할인 4건을 운영 데이터처럼 표시하지 않고 실제 등록된 할인 이벤트만 반환
    return _realTrendEvents
        .where((e) => (e['category'] ?? '').toString().contains('할인'))
        .toList();
  }

  List<Map<String, dynamic>> _getYouthSubsidies() {
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 상단 날씨 × 동네 로컬 맛집 & 레시피 히어로 배너
        _buildWeatherFoodHeroBanner(),

        const SizedBox(height: 12),

        // 1-2. 네이버 데이터랩 연동 2040 실시간 급상승 트렌드 (실검 차트)
        _buildNaverDataLabRealtimeTrendCard(),

        const SizedBox(height: 16),

        // 2. 에이블리(ABLY) 스타일 원형 아이콘 카테고리 바 (깔끔한 6열 정렬)
        _buildAblyCategoryGrid(),

        const Padding(
          padding: EdgeInsets.fromLTRB(20, 14, 20, 12),
          child: Divider(height: 1, color: borderSlate),
        ),

        // 3. 선택된 카테고리 헤더 + [2열 블럭 / 리스트] 보기 전환
        _buildSectionHeaderWithToggle(),

        const SizedBox(height: 10),

        // 4. 선택된 카테고리별 정돈된 추천 콘텐츠 피드
        _buildSelectedCategoryContent(),

        const Padding(
          padding: OomuInsets.listBottomWithTabs,
        ),
      ],
    );
  }

  // =========================================================================
  // 1-2. 네이버 데이터랩(DataLab) 연동 「이번 주 2040 실시간 급상승 검색어 (실검)」
  // =========================================================================
  Widget _buildNaverDataLabRealtimeTrendCard() {
    final visibleList = _isTrendsExpanded
        ? _naverRealtimeTrends.take(10).toList()
        : _naverRealtimeTrends.take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(OomuTokens.r16),
          border: Border.all(color: borderSlate),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: OomuTokens.naverGreen,
                    borderRadius: BorderRadius.circular(OomuTokens.r6),
                  ),
                  child: const Text(
                    'N 실검',
                    style: TextStyle(
                      fontSize: OomuTokens.fs11,
                      fontWeight: FontWeight.w800,
                      color: surfaceWhite,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '실시간 인기 검색어', // 360px에서 잘려 짧게
                    style: TextStyle(
                      fontSize: OomuTokens.fs15,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  flex: 0,
                  child: InkWell(
                    onTap: () =>
                        setState(() => _isTrendsExpanded = !_isTrendsExpanded),
                    borderRadius: BorderRadius.circular(OomuTokens.r8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      child: Text(
                        _isTrendsExpanded ? '접기 ▲' : '더보기 ▼',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: OomuTokens.fs12,
                          fontWeight: FontWeight.w700,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...visibleList.map((item) {
              final rank = item['rank'] ?? 1;
              final keyword = (item['keyword'] ?? '').toString();
              final category = (item['category'] ?? '').toString();
              final change = (item['change'] ?? 'HOT').toString();
              final isTop3 = (rank is num && rank <= 3) ||
                  int.tryParse(rank.toString()) != null &&
                      int.parse(rank.toString()) <= 3;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    SizedBox(
                      width: 26,
                      child: Text(
                        '$rank',
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontSize: OomuTokens.fs14,
                          fontWeight: FontWeight.w900,
                          color: isTop3 ? textPrimary : textSecondary, // 순위 강조는 굵기·명도로(코랄 남용 방지)
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        keyword,
                        style: const TextStyle(
                          fontSize: OomuTokens.fs13,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: subtleSurface,
                          borderRadius: BorderRadius.circular(OomuTokens.r6),
                        ),
                        child: Text(
                          category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: OomuTokens.fs11,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      change,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: OomuTokens.fs11,
                        fontWeight: FontWeight.w800,
                        // 변동 표시는 중립색(코랄은 CTA·선택 탭·하트·안 읽음 점에만)
                        color: change.contains('▲') ||
                                change == 'HOT' ||
                                change == 'NEW'
                            ? textPrimary
                            : textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 1. 상단 날씨 × 동네 삼겹살·파전 맛집 & 레시피 히어로 배너
  // =========================================================================
  Widget _buildWeatherFoodHeroBanner() {
    final data = _weatherRecipe;
    final recipes = data?.recommendedRecipes ?? const <RecipeItem>[];
    final localFoods = _getLocalFoodSpots();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderSlate),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: brandTint,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      data != null && data.hasWeather
                          ? '🌬️ ${data.locationName} ${data.tempC.toStringAsFixed(1)}°C · 미세먼지 ${data.airQualityLabel}'
                          : '🌬️ $_dongLabel 날씨 정보를 불러올 수 없어요',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: _loadWeatherAndRecipes,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.refresh_rounded,
                        size: 18, color: textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 단어 중간 줄바꿈("다/이닝") 방지
            BalancedHeading(
              data != null && data.hasWeather
                  ? data.moodHeadline
                  : '오늘 $_dongLabel에서 즐기기 좋은 실시간 로컬 맛집 & 다이닝 큐레이션',
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$_dongLabel 주변 실제 인기 맛집과 집에서 간편하게 즐기는 홈다이닝 레시피를 확인해보세요.',
              style: const TextStyle(
                fontSize: 12.5,
                color: textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (localFoods.isNotEmpty)
                  _buildQuickPill(
                    icon: Icons.restaurant_outlined,
                    label: (localFoods.first['shortLabel'] ??
                            localFoods.first['title'] ??
                            '$_dongLabel 인기 맛집')
                        .toString(),
                    onTap: () => _showLocalFoodDetailSheet(localFoods.first),
                  ),
                if (localFoods.length > 1)
                  _buildQuickPill(
                    icon: Icons.local_dining_outlined,
                    label: (localFoods[1]['shortLabel'] ??
                            localFoods[1]['title'] ??
                            '$_dongLabel 추천 다이닝')
                        .toString(),
                    onTap: () => _showLocalFoodDetailSheet(localFoods[1]),
                  ),
                if (recipes.isNotEmpty)
                  _buildQuickPill(
                    icon: Icons.menu_book_outlined,
                    label: '고단백 홈다이닝 레시피',
                    onTap: () => _showRecipeDetailSheet(recipes.first),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPill({
    IconData icon = Icons.restaurant_outlined,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: subtleSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textPrimary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 3),
            const Icon(Icons.chevron_right_rounded,
                size: 15, color: textSecondary),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 2. 에이블리(ABLY) 스타일 원형 아이콘 카테고리 그리드
  // =========================================================================
  Widget _buildAblyCategoryGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_ablyCategories.length, (idx) {
          final item = _ablyCategories[idx];
          final isSelected = _selectedAblyCategory == idx;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _selectedAblyCategory = idx),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected ? brandCoral : subtleSurface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? brandCoral : borderSlate,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      item['iconData'] as IconData,
                      size: 20,
                      color: isSelected ? Colors.white : textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['label'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? brandCoral : textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // =========================================================================
  // 3. 섹션 헤더 + [2열 블럭 / 리스트] 보기 토글
  // =========================================================================
  Widget _buildSectionHeaderWithToggle() {
    final currentCat = _ablyCategories[_selectedAblyCategory];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_dongLabel ${currentCat['label']}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentCat['sub'] as String,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: subtleSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isGridView = true),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: _isGridView ? surfaceWhite : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      '블록',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight:
                            _isGridView ? FontWeight.w700 : FontWeight.w500,
                        color: _isGridView ? textPrimary : textSecondary,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _isGridView = false),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: !_isGridView ? surfaceWhite : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      '리스트',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight:
                            !_isGridView ? FontWeight.w700 : FontWeight.w500,
                        color: !_isGridView ? textPrimary : textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 4. 선택된 카테고리별 정돈된 카드 피드 (에이블리 2열 블럭 / 리스트)
  // =========================================================================
  Widget _buildSelectedCategoryContent() {
    if (_selectedAblyCategory == 5) {
      return _buildPlayAndFortuneSection();
    }

    final List<Map<String, dynamic>> feedItems = _collectFeedItems();

    if (feedItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: OomuTokens.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline,
                    size: 26, color: textSecondary),
              ),
              const SizedBox(height: 12),
              const Text(
                '등록된 정보가 아직 없어요',
                style: TextStyle(
                  fontSize: OomuTokens.fs15,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '새로운 소식이 등록되면 빠르게 알려드릴게요!',
                style: TextStyle(
                  fontSize: OomuTokens.fs13,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _loadWeatherAndRecipes,
                icon: const Icon(Icons.refresh, size: 16, color: brandCoral),
                label: const Text('다시 불러오기',
                    style: TextStyle(
                        color: brandCoral,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: brandCoral),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isGridView) {
      final int rowCount = (feedItems.length + 1) ~/ 2;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: List.generate(rowCount, (rowIdx) {
            final left = feedItems[rowIdx * 2];
            final right = (rowIdx * 2 + 1) < feedItems.length
                ? feedItems[rowIdx * 2 + 1]
                : null;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildAblyBlockCard(left)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: right != null
                        ? _buildAblyBlockCard(right)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          }),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: feedItems
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildAblyListCard(item),
                ))
            .toList(),
      ),
    );
  }

  List<Map<String, dynamic>> _collectFeedItems() {
    final foods = _getLocalFoodSpots();
    final deals = _getLocalDiscountEvents();
    final subsidies = _getYouthSubsidies();
    final recipes = _weatherRecipe?.recommendedRecipes ?? const <RecipeItem>[];

    final List<Map<String, dynamic>> recipeCards = recipes
        .map((r) => {
              'type': 'recipe',
              'badge': r.category,
              'category': '홈레시피',
              'title': r.title,
              'subtitle': r.subtitle,
              'benefit': '${r.calories}kcal · 조리 ${r.prepTime}',
              'image': r.imageUrl,
              'rawRecipe': r,
            })
        .toList();

    final List<Map<String, dynamic>> trendCards = [
      if (_realTrendEvents.isNotEmpty) ..._realTrendEvents,
      ..._movies.map((m) => {
            'type': 'trend',
            'badge': m.badge,
            'category': '트렌드 영화',
            'title': m.title,
            'subtitle': m.synopsis,
            'benefit': '★ ${m.rating.toStringAsFixed(1)} · ${m.genre}',
            'image': m.posterUrl,
            'tip': '주말 동네 영화관 또는 OTT 정주행 추천작',
          }),
      ..._fashionDietItems.map((f) => {
            'type': 'trend',
            'badge': f.category,
            'category': '패션·다이어트',
            'title': f.title,
            'subtitle': f.summary,
            'benefit': f.keywords.map((k) => '#$k').take(2).join(' '),
            'image':
                'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800&q=80',
            'tip': f.detailTip,
          }),
      ..._countries.take(2).map((c) => {
            'type': 'trend',
            'badge': '${c.flagEmoji} 해외여행',
            'category': '글로벌 여행지',
            'title': '${c.nameKo} (${c.capital})',
            'subtitle': c.travelMood,
            'benefit': '추천시즌 ${c.bestSeason} · 통화 ${c.currency}',
            'image':
                'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=800&q=80',
            'tip': '항공권 특가 시즌에 맞춰 떠나기 좋은 추천 여행지',
          }),
    ];

    List<Map<String, dynamic>> rawItems;
    switch (_selectedAblyCategory) {
      case 1: // 날씨·맛집
        rawItems = [
          ...foods.map((e) => {...e, 'type': 'food'}),
          ...recipeCards,
        ];
        break;
      case 2: // 할인·이벤트
        rawItems = deals.map((e) => {...e, 'type': 'deal'}).toList();
        break;
      case 3: // 청년지원금
        rawItems = subsidies.map((e) => {...e, 'type': 'subsidy'}).toList();
        break;
      case 4: // 요즘트렌드
        rawItems = trendCards;
        break;
      case 0: // 전체추천 (골고루 큐레이션)
      default:
        // _realTrendEvents가 trendCards의 앞부분에도 포함되어 있으므로
        // 전체추천에서는 중복 삽입을 피하고 큐레이션합니다.
        final remainingTrends = trendCards
            .where((t) => !_realTrendEvents
                .any((r) => r['id'] != null && r['id'] == t['id']))
            .toList();
        rawItems = [
          if (_realTrendEvents.isNotEmpty) ..._realTrendEvents.take(4),
          ...foods.map((e) => {...e, 'type': 'food'}),
          ...deals.take(2).map((e) => {...e, 'type': 'deal'}),
          ...subsidies.take(2).map((e) => {...e, 'type': 'subsidy'}),
          ...recipeCards.take(2),
          ...remainingTrends.take(4),
        ];
        break;
    }

    // 카드 고유 id 또는 title 기준 중복 렌더링 방지
    final seen = <String>{};
    final List<Map<String, dynamic>> deduplicated = [];
    for (final item in rawItems) {
      final key = (item['id'] ?? item['title'] ?? '').toString();
      if (key.isNotEmpty && seen.contains(key)) continue;
      if (key.isNotEmpty) seen.add(key);
      deduplicated.add(item);
    }
    return deduplicated;
  }

  void _handleItemTap(Map<String, dynamic> item) {
    final type = (item['type'] ?? '').toString();
    if (type == 'recipe' && item['rawRecipe'] is RecipeItem) {
      _showRecipeDetailSheet(item['rawRecipe'] as RecipeItem);
    } else if (type == 'food' || type == 'deal') {
      _showLocalFoodDetailSheet(item);
    } else if (type == 'subsidy') {
      _showSubsidyDetailSheet(item);
    } else {
      _showTrendDetailSheet(item);
    }
  }

  Widget _buildAblyBlockCard(Map<String, dynamic> item) {
    return BouncyTap(
      scaleDown: 0.98,
      onTap: () => _handleItemTap(item),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderSlate),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: SizedBox(
                height: 112,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    (item['image']?.toString().trim().isNotEmpty ?? false)
                        ? Image(
                            image: appImg(item['image'].toString()),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: OomuTokens.surfaceMuted,
                              child: const Center(
                                child: Icon(Icons.image_outlined,
                                    color: OomuTokens.textMuted),
                              ),
                            ),
                          )
                        : Container(
                            color: OomuTokens.surfaceMuted,
                            child: const Center(
                              child: Icon(Icons.image_outlined,
                                  color: OomuTokens.textMuted),
                            ),
                          ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: textPrimary.withValues(alpha: 0.86),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          (item['badge'] ?? '').toString(),
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (item['category'] ?? '').toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  SizedBox(
                    height: 36,
                    // 어절 경계 줄바꿈("하이/볼" 방지)
                    // 3줄 이상이라 말줄임되는 제목도 어절 단위로 끊기게(표시 전용 연결 문자, 원문 불변)
                    child: BalancedHeading(
                      BalancedText.display(OomuUiHelpers.formatTitle(
                          (item['title'] ?? '').toString())),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        height: 1.32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (item['benefit'] ?? '').toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 11, color: textSecondary),
                          const SizedBox(width: 2),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 65),
                            child: Text(
                              (item['location'] ?? item['area'] ?? _dongLabel)
                                  .toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: brandTint,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item['mannerTemp'] != null
                              ? '${item['mannerTemp']}°C'
                              : '36.5°C',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: textSecondary,
                          ),
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
    );
  }

  Widget _buildAblyListCard(Map<String, dynamic> item) {
    return BouncyTap(
      scaleDown: 0.99,
      onTap: () => _handleItemTap(item),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderSlate),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 80,
                height: 80,
                child: Image(
                  image: appImg(
                      ((item['image']?.toString().trim().isNotEmpty ?? false)
                          ? item['image'].toString()
                          : 'assets/images/cover_food.jpg')),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: brandTint,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          (item['badge'] ?? '').toString(),
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: brandCoral,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          (item['category'] ?? '').toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    (item['title'] ?? '').toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    (item['subtitle'] ?? '').toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    (item['benefit'] ?? '').toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: brandCoral,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 상세 바텀시트 1: 레시피 추천 + 동네 근처 식당 안내 ('모임 열기' 제거 완료!)
  // =========================================================================
  void _showRecipeDetailSheet(RecipeItem recipe) {
    final nearbySpots = _getLocalFoodSpots();
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderSlate,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: brandTint,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      recipe.category,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: brandCoral,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${recipe.calories}kcal · 단백질 ${recipe.protein} · 조리 ${recipe.prepTime}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                recipe.title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                recipe.subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: textBody,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: borderSlate),
              const SizedBox(height: 14),
              const Text(
                '준비 재료',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: recipe.ingredients
                    .map(
                      (ing) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: subtleSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ing,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: textBody,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              const Text(
                '맛있게 만드는 레시피 팁',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                recipe.tip,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: textBody,
                  height: 1.5,
                ),
              ),
              if (nearbySpots.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: subtleSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🍴 직접 요리하기 귀찮을 땐? $_dongLabel 근처 추천 식당',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...nearbySpots.map((spot) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.storefront_rounded,
                                    size: 15, color: brandCoral),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${spot['title']} (${spot['distance']})',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: textBody,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          side: const BorderSide(color: borderSlate),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          NaverMapService.launchMap(
                              '${widget.currentLocation} 인기 맛집');
                        },
                        icon: const Icon(Icons.place_outlined,
                            size: 16, color: brandCoral),
                        label: const Text(
                          '근처 식당 지도 보기',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: textPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          '레시피 확인 완료',
                          style: TextStyle(
                              fontSize: 13.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 상세 바텀시트 2: 동네 근처 맛집 / 할인·이벤트 매장 상세
  // =========================================================================
  void _showLocalFoodDetailSheet(Map<String, dynamic> spot) {
    final List<String> menus =
        (spot['menus'] as List?)?.map((e) => e.toString()).toList() ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderSlate,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: brandTint,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      (spot['badge'] ?? '동네 추천').toString(),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: brandCoral,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    (spot['distance'] ?? _dongLabel).toString(),
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                (spot['title'] ?? '').toString(),
                style: const TextStyle(
                  fontSize: 18.5,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                (spot['subtitle'] ?? '').toString(),
                style: const TextStyle(
                  fontSize: 13.5,
                  color: textBody,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: subtleSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎁 동네 혜택: ${(spot['benefit'] ?? '').toString()}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: brandCoral,
                      ),
                    ),
                    if (spot['hours'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '⏰ 영업시간: ${spot['hours']}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (menus.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text(
                  '대표 메뉴',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                ...menus.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $m',
                        style: const TextStyle(
                            fontSize: 13, color: textBody, height: 1.4),
                      ),
                    )),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: textPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    NaverMapService.launchMap(
                        (spot['placeName'] ?? spot['title'] ?? _dongLabel)
                            .toString());
                  },
                  icon: const Icon(Icons.my_location_rounded, size: 18),
                  label: const Text(
                    '네이버 지도에서 근처 위치 보기',
                    style:
                        TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 상세 바텀시트 3: 청년지원금 상세 안내
  // =========================================================================
  void _showSubsidyDetailSheet(Map<String, dynamic> sub) {
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderSlate,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: brandTint,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '💰 ${(sub['badge'] ?? '청년지원금').toString()}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: brandCoral,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                (sub['title'] ?? '').toString(),
                style: const TextStyle(
                  fontSize: 18.5,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                (sub['subtitle'] ?? '').toString(),
                style: const TextStyle(
                  fontSize: 13.5,
                  color: textBody,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: subtleSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '지원 내용: ${sub['benefit']}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '지원 대상: ${sub['target']}',
                      style: const TextStyle(
                          fontSize: 12.5, color: textBody, height: 1.4),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '신청 방법: ${sub['howToApply']}',
                      style: const TextStyle(
                          fontSize: 12.5, color: textSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: textPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    '지원금 안내 확인',
                    style:
                        TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 상세 바텀시트 4: 요즘 트렌드 (영화 / 패션·다이어트 / 여행지) 상세
  // =========================================================================
  void _showTrendDetailSheet(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderSlate,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: brandTint,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  (item['badge'] ?? '요즘 트렌드').toString(),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: brandCoral,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                (item['title'] ?? '').toString(),
                style: const TextStyle(
                  fontSize: 18.5,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                (item['subtitle'] ?? '').toString(),
                style: const TextStyle(
                  fontSize: 13.5,
                  color: textBody,
                  height: 1.45,
                ),
              ),
              if (item['tip'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: subtleSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '💡 ${item['tip']}',
                    style: const TextStyle(
                        fontSize: 12.5, color: textBody, height: 1.4),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: textPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    '닫기',
                    style:
                        TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 카테고리 5: 놀거리·운세 (타로 뒤집기 + 밸런스 배틀 + 행운지수)
  // =========================================================================
  Widget _buildPlayAndFortuneSection() {
    final tarotCards = [
      {
        'title': '인연·연애운',
        'icon': '🔮',
        'revealedName': '🌸 The Lovers (연인)',
        'score': '98점 (최상)',
        'desc': '오늘 감성 카페나 산책길에서 티키타카가 통하는 뜻밖의 설레는 인연을 만날 확률이 아주 높아요!',
      },
      {
        'title': '성공·재물운',
        'icon': '☀️',
        'revealedName': '☀️ The Sun (태양)',
        'score': '95점 (대길)',
        'desc': '자신감과 활기가 넘치는 하루! 망설였던 새로운 취미 시작이나 번개 제안이 큰 호응을 얻어요.',
      },
      {
        'title': '동네·소셜운',
        'icon': '🌟',
        'revealedName': '🌟 The Star (별)',
        'score': '96점 (인기 폭발)',
        'desc': '다정한 배려와 유쾌한 리액션으로 오늘 어떤 모임에 가도 가장 빛나는 인기인이 되는 날이에요.',
      },
    ];

    final int totalBalance = _balanceVotesA + _balanceVotesB;
    final int percentA =
        totalBalance > 0 ? ((_balanceVotesA / totalBalance) * 100).round() : 50;
    final int percentB = 100 - percentA;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 오늘의 행운 지수 게이지 카드
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderSlate),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text('🍀 ', style: TextStyle(fontSize: 16)),
                        Text(
                          '오늘의 동네 행운 지수',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: brandTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '96점 · 최상 ✨',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: brandCoral,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    children: [
                      Container(height: 10, color: subtleSurface),
                      FractionallySizedBox(
                        widthFactor: 0.96,
                        child: Container(
                          height: 10,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF8A94), brandCoral],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: subtleSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('🌸 행운의 컬러: 코랄 핑크',
                          style: TextStyle(
                              fontSize: 11.5,
                              color: textBody,
                              fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: subtleSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('☕ 행운의 장소: 로컬 감성 카페',
                          style: TextStyle(
                              fontSize: 11.5,
                              color: textBody,
                              fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: subtleSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('⏰ 행운의 시간대: 16:00 ~ 18:00',
                          style: TextStyle(
                              fontSize: 11.5,
                              color: textBody,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 2. 인터랙티브 타로 궁합 카드 뒤집기
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderSlate),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('🔮 ', style: TextStyle(fontSize: 16)),
                    Text(
                      '오늘의 소셜 & 인연 타로 카드',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  '카드를 탭하여 뒤집으면 오늘의 운세가 즉시 공개돼요!',
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
                const SizedBox(height: 14),
                Row(
                  children: List.generate(3, (idx) {
                    final item = tarotCards[idx];
                    final isFlipped = _tarotFlipped[idx] == true;

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: idx < 2 ? 8.0 : 0, left: idx > 0 ? 0 : 0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _tarotFlipped[idx] = !isFlipped;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 140,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isFlipped ? brandTint : subtleSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isFlipped ? brandCoral : borderSlate,
                                width: isFlipped ? 1.5 : 1.0,
                              ),
                              boxShadow: isFlipped
                                  ? [
                                      BoxShadow(
                                        color:
                                            brandCoral.withValues(alpha: 0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isFlipped
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item['revealedName']!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: brandCoral,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['score']!,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['desc']!,
                                        style: const TextStyle(
                                          fontSize: 9.5,
                                          color: textBody,
                                          height: 1.25,
                                        ),
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(item['icon']!,
                                          style: const TextStyle(fontSize: 28)),
                                      const SizedBox(height: 6),
                                      Text(
                                        item['title']!,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: textPrimary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: surfaceWhite,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border:
                                              Border.all(color: borderSlate),
                                        ),
                                        child: const Text(
                                          '탭하여 확인',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w600,
                                            color: brandCoral,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 3. 실시간 밸런스 토론 배틀 (동네 투표)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderSlate),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text('⚖️ ', style: TextStyle(fontSize: 16)),
                        Text(
                          '오늘의 동네 밸런스 토론',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '총 $totalBalance명 참여 중',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '"금요일 저녁, 더 끌리는 나만의 힐링 시간은?"',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Option A
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_balanceVote != 0) {
                        _balanceVote = 0;
                        _balanceVotesA++;
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _balanceVote == 0 ? brandTint : subtleSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _balanceVote == 0 ? brandCoral : borderSlate,
                        width: _balanceVote == 0 ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'A. 동네 이웃들과 삼겹살에 시원한 하이볼 한잔 🍻',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '$percentA% ($_balanceVotesA표)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color:
                                _balanceVote == 0 ? brandCoral : textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Option B
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_balanceVote != 1) {
                        _balanceVote = 1;
                        _balanceVotesB++;
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _balanceVote == 1 ? brandTint : subtleSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _balanceVote == 1 ? brandCoral : borderSlate,
                        width: _balanceVote == 1 ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'B. 포근한 침대에서 넷플릭스 보며 마라탕 배달 🛋️',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '$percentB% ($_balanceVotesB표)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color:
                                _balanceVote == 1 ? brandCoral : textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
