import 'package:flutter/material.dart';
import '../services/discovery_api_service.dart';
import '../services/kakao_map_service.dart';
import '../utils/app_image.dart';
import 'bouncy_tap.dart';

/// 발견(Discovery) 탭 전용 에이블리(ABLY) 스타일 동네 큐레이션 허브
/// - 동네모임 탭과 명확히 차별화하여 '우리 동네에만 있는 할인·이벤트·날씨 맞춤 맛집/레시피·청년지원금·트렌드'를
///   에이블리 스타일 원형 아이콘 카테고리 + 2열 블럭/리스트 뷰로 정돈해 보여줍니다.
/// - 레시피/맛집 상세 모달에서는 비 오는 날 모임 개설 유도를 제거하고,
///   상세 레시피 조리법과 동네 근처 식당 추천(카카오맵 연동)을 제공합니다.
class OomuDiscoveryLifestyleHub extends StatefulWidget {
  final String currentLocation;

  const OomuDiscoveryLifestyleHub({
    super.key,
    required this.currentLocation,
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
  int _selectedAblyCategory = 0;
  bool _isGridView = true; // true: 에이블리 2열 블럭형, false: 리스트형

  // API 데이터 상태
  WeatherMoodRecipe? _weatherRecipe;
  bool _loadingWeather = true;
  List<TrendMovieItem> _movies = const [];
  List<FashionDietTrendItem> _fashionDietItems = const [];
  List<BoardGameItem> _boardGames = const [];
  List<CountrySpotItem> _countries = const [];
  QuoteAndQuest? _quoteQuest;
  int _quoteSeed = 0;

  final TextEditingController _nameController =
      TextEditingController(text: 'Sophie');
  NameVibeResult? _nameResult;
  bool _analyzingName = false;

  static const List<Map<String, String>> _ablyCategories = [
    {'icon': '🔥', 'label': '전체추천', 'sub': '우리 동네 인기 발견'},
    {'icon': '🥓', 'label': '날씨·맛집', 'sub': '삼겹살·파전·레시피'},
    {'icon': '🏷️', 'label': '할인·이벤트', 'sub': '동네 가게 특가·혜택'},
    {'icon': '💰', 'label': '청년지원금', 'sub': '월세·교통·문화 지원'},
    {'icon': '🎬', 'label': '요즘트렌드', 'sub': '영화·패션·다이어트'},
    {'icon': '🎲', 'label': '놀거리·운세', 'sub': '보드게임·이름테스트'},
  ];

  @override
  void initState() {
    super.initState();
    _fashionDietItems = _service.getFashionAndDietTrends();
    _boardGames = _service.getBoardGameRecommendations();
    _loadAllDiscoveryData();
  }

  @override
  void didUpdateWidget(covariant OomuDiscoveryLifestyleHub oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLocation != widget.currentLocation) {
      _loadWeatherAndRecipes();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadAllDiscoveryData() async {
    _loadWeatherAndRecipes();
    _loadMoviesAndCountries();
    _refreshQuoteAndQuest(initial: true);
    _runNameAnalysis('Sophie');
  }

  Future<void> _loadWeatherAndRecipes() async {
    if (mounted) setState(() => _loadingWeather = true);
    final res = await _service.fetchWeatherAndRecipes(widget.currentLocation);
    if (mounted) {
      setState(() {
        _weatherRecipe = res;
        _loadingWeather = false;
      });
    }
  }

  Future<void> _loadMoviesAndCountries() async {
    final results = await Future.wait([
      _service.fetchTrendMovies(),
      _service.fetchTravelCountries(),
    ]);
    if (mounted) {
      setState(() {
        _movies = results[0] as List<TrendMovieItem>;
        _countries = results[1] as List<CountrySpotItem>;
      });
    }
  }

  Future<void> _refreshQuoteAndQuest({bool initial = false}) async {
    if (!initial) _quoteSeed++;
    final res = await _service.fetchQuoteAndQuest(seedIndex: _quoteSeed);
    if (mounted) {
      setState(() => _quoteQuest = res);
    }
  }

  Future<void> _runNameAnalysis(String input) async {
    if (mounted) setState(() => _analyzingName = true);
    final res = await _service.analyzeNameVibe(input);
    if (mounted) {
      setState(() {
        _nameResult = res;
        _analyzingName = false;
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
  // 동네 전용 큐레이션 데이터 (날씨 맞춤 삼겹살/파전 맛집, 동네 할인/이벤트, 청년지원금)
  // ---------------------------------------------------------------------------
  List<Map<String, dynamic>> _getLocalFoodSpots() {
    final dong = _dongLabel;
    if (_isYeosu) {
      return [
        {
          'id': 'food_yeosu_1',
          'badge': '바람·비 오는 날 추천',
          'category': '날씨·맛집',
          'title': '화장동 성산공원 앞 참숯 생삼겹 & 미나리 구이',
          'subtitle': '바람 불고 쌀쌀한 저녁, 향긋한 청도 미나리와 육즙 가득 숙성 통삼겹살 맛집',
          'benefit': '첫 주문 시 된장술밥 서비스 · 1인 16,000원',
          'placeName': '여수 화장동 미나리삼겹살',
          'distance': '$dong 도보 5분',
          'hours': '매일 16:00 - 23:30',
          'image': 'assets/images/cover_food.jpg',
          'menus': [
            '숙성 통삼겹살 (180g) 16,000원',
            '생미나리 추가 5,000원',
            '김치말이 국수 6,000원'
          ],
        },
        {
          'id': 'food_yeosu_2',
          'badge': '비·바람 불 때 1위',
          'category': '날씨·맛집',
          'title': '학동 선소상가 바삭 해물파전 & 바지락 칼국수',
          'subtitle': '바닷바람 부는 날 생각나는 오징어·새우 듬뿍 철판 해물파전과 시원한 국물',
          'benefit': '해물파전 + 칼국수 2인 세트 27,000원',
          'placeName': '여수 학동 선소 해물파전 칼국수',
          'distance': '$dong 차량 6분',
          'hours': '매일 11:30 - 22:00',
          'image': 'assets/images/cover_wine.jpg',
          'menus': ['철판 해물파전 18,000원', '들깨 바지락 칼국수 9,000원', '생막걸리 5,000원'],
        },
      ];
    }
    return [
      {
        'id': 'food_seoul_1',
        'badge': '바람·미세먼지 추천',
        'category': '날씨·맛집',
        'title': '$dong 참숯 미나리 통삼겹살 & 멜젓 직화구이',
        'subtitle': '바람 불거나 미세먼지 심한 날, 삼겹살 기름에 구운 향긋한 미나리 한 입',
        'benefit': '오후 7시 이전 방문 시 껍데기 1인분 무료',
        'placeName': '${widget.currentLocation} 미나리 삼겹살',
        'distance': '$dong 도보 4분',
        'hours': '매일 16:30 - 24:00',
        'image': 'assets/images/cover_food.jpg',
        'menus': ['봄동·미나리 통삼겹 17,000원', '미나리 무침 추가 5,000원', '차돌 된장찌개 7,000원'],
      },
      {
        'id': 'food_seoul_2',
        'badge': '바람·비 오는 날 인기',
        'category': '날씨·맛집',
        'title': '$dong 골목 노포 철판 해물파전 & 수제비 전골',
        'subtitle': '선선한 바람 불 때 지글지글 소리부터 설레는 통오징어 해물파전 로컬 맛집',
        'benefit': '파전 + 얼큰 수제비 세트 2,000원 할인',
        'placeName': '${widget.currentLocation} 해물파전 칼국수',
        'distance': '$dong 도보 6분',
        'hours': '매일 12:00 - 23:00',
        'image': 'assets/images/cover_wine.jpg',
        'menus': ['통오징어 해물파전 19,000원', '감자전 15,000원', '얼큰 해물 수제비 10,000원'],
      },
    ];
  }

  List<Map<String, dynamic>> _getLocalDiscountEvents() {
    final dong = _dongLabel;
    return [
      {
        'id': 'deal_1',
        'badge': '오늘 마감할인 30%',
        'category': '할인·이벤트',
        'title': '$dong 수제 소금빵·휘낭시에 베이커리 마감 타임세일',
        'subtitle': '당일 구운 유기농 밀가루 소금빵과 바스크 치즈케이크 저녁 7시 이후 전 품목 30% 할인',
        'benefit': '저녁 7시~9시 30% 즉시 할인 (소진 시 마감)',
        'placeName': '${widget.currentLocation} 베이커리 카페',
        'distance': '$dong 도보 3분',
        'image': 'assets/images/cover_salt_bread.jpg',
      },
      {
        'id': 'deal_2',
        'badge': '동네 오픈 이벤트',
        'category': '할인·이벤트',
        'title': '$dong 신상 로스터리 카페 아메리카노·라떼 1+1 주간',
        'subtitle': '동네 주민 인증 시 스페셜티 원두 커피 1잔 가격에 2잔 제공 & 디저트 10% 할인',
        'benefit': '음료 1+1 쿠폰 (이번 주 일요일까지)',
        'placeName': '${widget.currentLocation} 로스터리 카페',
        'distance': '$dong 도보 5분',
        'image': 'assets/images/cover_cafe.jpg',
      },
      {
        'id': 'deal_3',
        'badge': '주민 전용 50% 특가',
        'category': '할인·이벤트',
        'title': '$dong 1:1 기구 필라테스 & 체형교정 원데이 체험 특가',
        'subtitle': '퇴근 후 거북목·라운드숄더 교정을 위한 50분 프라이빗 레슨 동네 주민 반값 이벤트',
        'benefit': '1회 체험권 50,000원 → 22,000원',
        'placeName': '${widget.currentLocation} 필라테스',
        'distance': '$dong 도보 4분',
        'image': 'assets/images/cover_running.jpg',
      },
      {
        'id': 'deal_4',
        'badge': '동네 플리마켓·팝업',
        'category': '할인·이벤트',
        'title': '$dong 주말 핸드메이드 소품·향수·빈티지 플리마켓',
        'subtitle': '동네 공방 작가 18팀이 참여하는 주말 마켓! 방문객 전원 시향 스틱 & 엽서 증정',
        'benefit': '무료 입장 + 현장 3,000원 할인권 증정',
        'placeName': '${widget.currentLocation} 문화광장',
        'distance': '$dong 도보 7분',
        'image': 'assets/images/cover_wine.jpg',
      },
    ];
  }

  List<Map<String, dynamic>> _getYouthSubsidies() {
    final cityLabel = _isYeosu ? '여수시·전남' : '서울·마포구';
    return [
      {
        'id': 'sub_1',
        'badge': '월 최대 20만 원',
        'category': '청년지원금',
        'title': '2026 청년월세 한시 특별지원 (최대 240만 원 현금 지원)',
        'subtitle': '부모님과 별도 거주하는 만 19~34세 무주택 청년에게 월 최대 20만 원씩 12개월간 임차료 지원',
        'benefit': '월 최대 20만 원 × 12개월 (복지로·주민센터 신청)',
        'target': '만 19세~34세 무주택 1인 가구 청년 (중위소득 60% 이하)',
        'howToApply': '복지로(bokjiro.go.kr) 온라인 신청 또는 관할 행정복지센터 방문',
        'image': 'assets/images/cover_cafe.jpg',
      },
      {
        'id': 'sub_2',
        'badge': '대중교통 30% 환급',
        'category': '청년지원금',
        'title': 'K-패스 (구 알뜰교통카드) 청년 대중교통비 매월 30% 환급',
        'subtitle':
            '월 15회 이상 지하철·버스·광역버스 이용 시 청년(만 19~34세) 사용 금액의 30%를 다음 달 계좌로 환급',
        'benefit': '매월 교통비 30% 자동 환급 (일반 20%, 청년 30%)',
        'target': '만 19세~34세 전국 청년 누구나 (월 15회 이상 대중교통 이용)',
        'howToApply': 'K-패스 공식 앱 또는 카드사 홈페이지에서 카드 발급 후 회원가입',
        'image': 'assets/images/cover_running.jpg',
      },
      {
        'id': 'sub_3',
        'badge': '연 최대 15만 원',
        'category': '청년지원금',
        'title': '청년 문화예술패스 & $cityLabel 청년 문화생활 바우처',
        'subtitle': '뮤지컬·콘서트·연극·전시회 티켓 예매 시 즉시 사용할 수 있는 문화예술 지원금 포인트',
        'benefit': '1인당 연 10만~15만 원 공연·전시 관람비 지원',
        'target': '관내 거주 청년 (인터파크·예스24 티켓 연동 즉시 사용)',
        'howToApply': '문화예술패스 누리집 및 $cityLabel 청년포털 온라인 즉시 발급',
        'image': 'assets/images/cover_wine.jpg',
      },
      {
        'id': 'sub_4',
        'badge': '$cityLabel 청년혜택',
        'category': '청년지원금',
        'title': '$cityLabel 청년 자격증 응시료 & 이사비·중개보수 지원금',
        'subtitle':
            '어학(토익·오픽)·국가기술자격증 응시료 실비 지원 및 1인 가구 청년 전월세 이사비용 최대 40만 원 지원',
        'benefit': '자격증 응시료 최대 10만 원 · 이사비 최대 40만 원',
        'target': '$cityLabel 주민등록 거주 만 19~39세 미취업·재직 청년',
        'howToApply': '정부24 보조금24 또는 $cityLabel 시·구청 청년지원과 온라인 접수',
        'image': 'assets/images/cover_food.jpg',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 상단 날씨 × 바람/비 오는 날 삼겹살·파전 근처 맛집 & 레시피 히어로 배너
        _buildWeatherFoodHeroBanner(),

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
      ],
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
                      data != null
                          ? '🌬️ ${data.locationName} ${data.tempC.toStringAsFixed(1)}°C · 미세먼지 ${data.airQualityLabel}'
                          : '🌬️ $_dongLabel 실시간 날씨 맞춤 추천',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: brandCoral,
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
            Text(
              _loadingWeather && data == null
                  ? '바람 불고 출출한 오늘, $_dongLabel 삼겹살·해물파전 맛집 & 집밥 레시피'
                  : '바람 불고 쌀쌀한 날엔 노릇한 미나리 삼겹살 & 바삭한 해물파전 어때요?',
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '모임 부담 없이! 집에서 뚝딱 만드는 황금 레시피와 우리 동네 근처 식당을 바로 확인해보세요.',
              style: TextStyle(
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
                    label: '🥓 근처 미나리 삼겹살 맛집',
                    onTap: () => _showLocalFoodDetailSheet(localFoods.first),
                  ),
                if (localFoods.length > 1)
                  _buildQuickPill(
                    label: '🥞 근처 철판 해물파전·칼국수',
                    onTap: () => _showLocalFoodDetailSheet(localFoods[1]),
                  ),
                if (recipes.isNotEmpty)
                  _buildQuickPill(
                    label: '🍳 삼겹살·집밥 레시피 보기',
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
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textPrimary,
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
                    child: Text(
                      item['icon']!,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['label']!,
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
                  '${currentCat['icon']} $_dongLabel ${currentCat['label']}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentCat['sub']!,
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
                      '블럭',
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
            'image': 'assets/images/cover_cafe.jpg',
            'tip': f.detailTip,
          }),
      ..._countries.take(2).map((c) => {
            'type': 'trend',
            'badge': '${c.flagEmoji} 해외여행',
            'category': '글로벌 여행지',
            'title': '${c.nameKo} (${c.capital})',
            'subtitle': c.travelMood,
            'benefit': '추천시즌 ${c.bestSeason} · 통화 ${c.currency}',
            'image': 'assets/images/cover_running.jpg',
            'tip': '항공권 특가 시즌에 맞춰 떠나기 좋은 추천 여행지',
          }),
    ];

    switch (_selectedAblyCategory) {
      case 1: // 날씨·맛집
        return [
          ...foods.map((e) => {...e, 'type': 'food'}),
          ...recipeCards,
        ];
      case 2: // 할인·이벤트
        return deals.map((e) => {...e, 'type': 'deal'}).toList();
      case 3: // 청년지원금
        return subsidies.map((e) => {...e, 'type': 'subsidy'}).toList();
      case 4: // 요즘트렌드
        return trendCards;
      case 0: // 전체추천 (골고루 큐레이션)
      default:
        return [
          ...foods.map((e) => {...e, 'type': 'food'}),
          ...deals.take(2).map((e) => {...e, 'type': 'deal'}),
          ...subsidies.take(2).map((e) => {...e, 'type': 'subsidy'}),
          ...recipeCards.take(2),
          ...trendCards.take(2),
        ];
    }
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
                    Image(
                      image: appImg(
                          (item['image'] ?? 'assets/images/cover_food.jpg')
                              .toString()),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/cover_food.jpg',
                        fit: BoxFit.cover,
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
                      color: brandCoral,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    (item['title'] ?? '').toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      height: 1.32,
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
                      (item['image'] ?? 'assets/images/cover_food.jpg')
                          .toString()),
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
                          KakaoMapService.launchMap(
                              '${widget.currentLocation} 삼겹살 파전 맛집');
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
                    KakaoMapService.launchMap(
                        (spot['placeName'] ?? spot['title'] ?? _dongLabel)
                            .toString());
                  },
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text(
                    '카카오맵에서 근처 위치 보기',
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
  // 카테고리 5: 놀거리·운세 (보드게임 추천 + 오늘의 문장 + 영문 닉네임 무드)
  // =========================================================================
  Widget _buildPlayAndFortuneSection() {
    final qq = _quoteQuest;
    final res = _nameResult;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._boardGames.map((bg) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
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
                          Expanded(
                            child: Text(
                              '🎲 ${bg.name}',
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            '${bg.players} · ${bg.playTime}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: brandCoral,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        bg.summary,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: textBody,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 6),
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
                  children: [
                    const Expanded(
                      child: Text(
                        '오늘의 감성 한 줄 & 소소한 일 추천',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _refreshQuoteAndQuest(),
                      child: const Text(
                        '다른 문장 뽑기',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: brandCoral,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  qq != null
                      ? '"${qq.quoteKo}"'
                      : '"오늘 나를 위해 건넨 다정한 시간은 내일의 나를 더 빛나게 해줄 거예요."',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '✨ 오늘의 소소한 추천: ${qq?.questTitle ?? '동네 독립서점에서 표지가 마음에 드는 책 1권 골라 읽기'}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
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
                const Text(
                  '재미로 보는 영문 닉네임 글로벌 첫인상',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: TextField(
                          controller: _nameController,
                          onSubmitted: (v) => _runNameAnalysis(v),
                          style: const TextStyle(
                              fontSize: 13.5, color: textPrimary),
                          decoration: InputDecoration(
                            hintText: '영문 이름 입력 (예: Sophie)',
                            filled: true,
                            fillColor: subtleSurface,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: textPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _analyzingName
                            ? null
                            : () => _runNameAnalysis(_nameController.text),
                        child: const Text(
                          '분석',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
                if (res != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    res.vibeSummary,
                    style: const TextStyle(
                        fontSize: 12.5, color: textBody, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
