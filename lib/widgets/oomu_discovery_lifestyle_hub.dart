import 'package:flutter/material.dart';
import '../screens/soso_car_host_screen.dart';
import '../services/discovery_api_service.dart';
import '../utils/app_image.dart';
import 'bouncy_tap.dart';

/// 발견(Discovery) 탭 전용 2030 여성 라이프스타일 & 트렌드 큐레이션 허브
/// docs/OOMU_UI_GUIDE.md 단일 디자인 기준(60-30-10 무채색 베이스 + 코랄 포인트,
/// Card-in-Card 배제, 48dp 터치 타깃)을 준수합니다.
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

  // 1. 날씨 × 감성 레시피 상태
  WeatherMoodRecipe? _weatherRecipe;
  bool _loadingWeather = true;
  String _selectedRecipeFilter = '전체'; // 전체 | 날씨맞춤 | 다이어트·저속노화 | 홈파티·브런치

  // 2. 2030 트렌드 탭 (영화 | 패션·다이어트 | 보드게임 | 글로벌 여행지)
  int _selectedLifestyleTab = 0;
  List<TrendMovieItem> _movies = const [];
  List<FashionDietTrendItem> _fashionDietItems = const [];
  List<BoardGameItem> _boardGames = const [];
  List<CountrySpotItem> _countries = const [];

  // 3. 오늘의 감성 문장 & 심심할 때 퀘스트 (Quotes + Bored API)
  QuoteAndQuest? _quoteQuest;
  int _quoteSeed = 0;

  // 4. 영문 닉네임 글로벌 이미지 분석 (Agify + Genderize + Nationalize.io)
  final TextEditingController _nameController =
      TextEditingController(text: 'Sophie');
  NameVibeResult? _nameResult;
  bool _analyzingName = false;

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

  void _openHostWithTopic({
    required String title,
    required String mainCategory,
    String vibe = '소소하게',
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OOMUHostScreen(
          initialTitle: title,
          initialLocation: widget.currentLocation,
          initialMainCategory: mainCategory,
          initialVibe: vibe,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 1: OpenWeatherMap + Edamam 결합 (오늘 날씨 × 감성 레시피 & 다이어트 식단)
        _buildWeatherRecipeSection(),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Divider(height: 1, color: borderSlate),
        ),

        // 섹션 2: 2030 여성 트렌드 라이프스타일 (트렌드 영화 · 패션/다이어트 · 보드게임 · 글로벌 여행지)
        _buildLifestyleTrendsSection(),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Divider(height: 1, color: borderSlate),
        ),

        // 섹션 3: Quotes Free API + Bored API (오늘의 감성 문장 & 심심할 때 소소한 퀘스트)
        _buildQuoteAndQuestSection(),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Divider(height: 1, color: borderSlate),
        ),

        // 섹션 4: Agify / Genderize / Nationalize.io (영문 닉네임 글로벌 무드 테스트)
        _buildNameVibeSection(),
      ],
    );
  }

  // =========================================================================
  // 1. 오늘 날씨 × 감성 식탁 & 다이어트 레시피 (OpenWeatherMap + Edamam 결합)
  // =========================================================================
  Widget _buildWeatherRecipeSection() {
    final data = _weatherRecipe;
    final allRecipes = data?.recommendedRecipes ?? const <RecipeItem>[];
    final filtered = _selectedRecipeFilter == '전체'
        ? allRecipes
        : allRecipes.where((r) => r.category == _selectedRecipeFilter).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '오늘 날씨 × 감성 식탁 & 레시피',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data != null
                          ? '${data.locationName} ${data.tempC.toStringAsFixed(1)}°C · 미세먼지 ${data.pm10}㎍/㎥ (${data.airQualityLabel})'
                          : '현재 동네 날씨와 어울리는 식단을 불러오는 중이에요',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _loadWeatherAndRecipes,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                tooltip: '날씨 새로고침',
                icon: const Icon(Icons.refresh_rounded,
                    size: 20, color: textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 날씨 감성 브리핑 배너 (단일 1px 보더 카드, 중첩 박스 없음)
          Container(
            width: double.infinity,
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: brandTint,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        data != null && data.pm10 >= 45
                            ? '😷 미세먼지 케어 식탁'
                            : '🌤️ 오늘의 무드 식탁',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: brandCoral,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'OpenWeather · Edamam 큐레이션',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _loadingWeather && data == null
                      ? '오늘 미세먼지가 신경 쓰일 땐, 노릇한 미나리 삼겹살 어때요?'
                      : (data?.moodHeadline ?? ''),
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data?.moodSubcopy ??
                      '칼칼한 목을 달래줄 삼겹살 구이부터 300kcal대 저속노화 다이어트 포케까지 준비했어요.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 레시피 필터 칩 (전체 / 날씨맞춤 / 다이어트·저속노화 / 홈파티·브런치)
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['전체', '날씨맞춤', '다이어트·저속노화', '홈파티·브런치'].map((cat) {
                final isSelected = _selectedRecipeFilter == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedRecipeFilter = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? textPrimary : subtleSurface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF4E5968),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // 레시피 가로 스크롤 카드
          SizedBox(
            height: 232,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final recipe = filtered[index];
                return _buildRecipeCard(recipe);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(RecipeItem recipe) {
    return BouncyTap(
      scaleDown: 0.98,
      onTap: () => _showRecipeDetailSheet(recipe),
      child: Container(
        width: 224,
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
                height: 108,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image(
                      image: appImg(recipe.imageUrl),
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
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          recipe.category,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
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
                    recipe.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${recipe.calories}kcal · 단백질 ${recipe.protein}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: brandCoral,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        recipe.prepTime,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: textMuted,
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

  void _showRecipeDetailSheet(RecipeItem recipe) {
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
                  Text(
                    '${recipe.calories}kcal · 단백질 ${recipe.protein} · 조리 ${recipe.prepTime}',
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
                '맛있게 만드는 팁',
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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandCoral,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _openHostWithTopic(
                      title: '우리 동네 ${recipe.title} 같이 먹어요',
                      mainCategory: '일상 & 푸드 > 맛집 탐방',
                    );
                  },
                  child: const Text(
                    '이 메뉴로 동네 미식 모임 열기',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
  // 2. 2030 여성 트렌드 큐레이션 (영화 · 패션/다이어트 · 보드게임 · 글로벌 여행지)
  // =========================================================================
  Widget _buildLifestyleTrendsSection() {
    final tabs = [
      '🎬 트렌드 영화',
      '👗 패션·다이어트',
      '🎲 보드게임 추천',
      '✈️ 글로벌 여행지',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '요즘 2030 트렌드 & 취향 큐레이션',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            '요즘 유행하는 영화·패션·다이어트·보드게임·여행지를 한눈에 모아봤어요.',
            style: TextStyle(
              fontSize: 12.5,
              color: textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // 단일 카테고리 스위처
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final isSel = _selectedLifestyleTab == idx;
                return GestureDetector(
                  onTap: () => setState(() => _selectedLifestyleTab = idx),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? textPrimary : subtleSurface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tabs[idx],
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                        color: isSel ? Colors.white : const Color(0xFF4E5968),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          if (_selectedLifestyleTab == 0) _buildMoviesList(),
          if (_selectedLifestyleTab == 1) _buildFashionDietList(),
          if (_selectedLifestyleTab == 2) _buildBoardGamesList(),
          if (_selectedLifestyleTab == 3) _buildCountriesList(),
        ],
      ),
    );
  }

  Widget _buildMoviesList() {
    if (_movies.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return Column(
      children: _movies.map((m) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: BouncyTap(
            scaleDown: 0.99,
            onTap: () => _openHostWithTopic(
              title: '[영화 번개] ${m.title} 같이 보러 가요',
              mainCategory: '문화 & 엔터 > 영화 & OTT',
            ),
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
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 68,
                      height: 92,
                      child: Image(
                        image: appImg(m.posterUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/cover_wine.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: brandTint,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                m.badge,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: brandCoral,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '★ ${m.rating.toStringAsFixed(1)} · ${m.genre}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          m.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.synopsis,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: textBody,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFashionDietList() {
    return Column(
      children: _fashionDietItems.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: brandTint,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: brandCoral,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.keywords.map((k) => '#$k').join(' '),
                        style: const TextStyle(
                          fontSize: 12,
                          color: textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.summary,
                  style: const TextStyle(
                    fontSize: 13,
                    color: textBody,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '💡 ${item.detailTip}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBoardGamesList() {
    return Column(
      children: _boardGames.map((bg) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
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
                    Expanded(
                      child: Text(
                        bg.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: subtleSurface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${bg.players} · ${bg.playTime} · ${bg.difficulty}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  bg.summary,
                  style: const TextStyle(
                    fontSize: 13,
                    color: textBody,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '🎲 모임 팁: ${bg.meetupTip}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCountriesList() {
    return Column(
      children: _countries.map((c) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
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
                    Text(
                      c.flagEmoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.nameKo,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            '수도 ${c.capital} · 통화 ${c.currency} · 추천시즌 ${c.bestSeason}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  c.travelMood,
                  style: const TextStyle(
                    fontSize: 13,
                    color: textBody,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // =========================================================================
  // 3. 오늘의 감성 문장 & 심심할 때 소소한 퀘스트 (Quotes + Bored API)
  // =========================================================================
  Widget _buildQuoteAndQuestSection() {
    final qq = _quoteQuest;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _refreshQuoteAndQuest(),
                  style: TextButton.styleFrom(
                    foregroundColor: brandCoral,
                    minimumSize: const Size(48, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                  label: const Text(
                    '다른 추천 뽑기',
                    style:
                        TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              qq != null
                  ? '"${qq.quoteKo}"'
                  : '"오늘 나를 위해 건넨 다정한 시간은 내일의 나를 더 빛나게 해줄 거예요."',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textPrimary,
                height: 1.45,
              ),
            ),
            if (qq != null) ...[
              const SizedBox(height: 3),
              Text(
                '${qq.quoteEn} — ${qq.author}',
                style: const TextStyle(
                  fontSize: 12,
                  color: textMuted,
                  height: 1.35,
                ),
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: borderSlate),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: subtleSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '오늘 뭐 하지?',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        qq?.questTitle ??
                            '동네 독립서점이나 도서관에서 표지가 마음에 드는 책 1권 골라 읽기',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        qq?.questTip ??
                            '인상 깊은 문장 한 줄을 찍어 커뮤니티에 공유하면 취향이 맞는 이웃을 만날 수 있어요.',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 4. 재미로 보는 영문 이름·닉네임 글로벌 이미지 (Agify / Genderize / Nationalize)
  // =========================================================================
  Widget _buildNameVibeSection() {
    final res = _nameResult;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'Agify · Genderize · Nationalize 글로벌 통계로 내 영어 이름의 분위기를 확인해보세요.',
              style: TextStyle(
                fontSize: 12.5,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: TextField(
                      controller: _nameController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (v) => _runNameAnalysis(v),
                      style: const TextStyle(fontSize: 14, color: textPrimary),
                      decoration: InputDecoration(
                        hintText: '영문 이름 입력 (예: Sophie, Minji, Chloe)',
                        hintStyle:
                            const TextStyle(fontSize: 13, color: textMuted),
                        filled: true,
                        fillColor: subtleSurface,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: textPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _analyzingName
                        ? null
                        : () => _runNameAnalysis(_nameController.text),
                    child: Text(
                      _analyzingName ? '분석중' : '분석하기',
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            if (res != null) ...[
              const SizedBox(height: 12),
              Text(
                res.vibeSummary,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: textBody,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildMetaTag('이미지 연령 약 ${res.estimatedAge}세'),
                  _buildMetaTag(res.genderLabel),
                  ...res.topCountries.map((c) => _buildMetaTag('친숙도 $c')),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetaTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: subtleSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
      ),
    );
  }
}
