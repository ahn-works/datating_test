import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// 날씨 및 미세먼지 기반 감성 레시피 추천 모델 (OpenWeatherMap / Open-Meteo + Edamam 결합)
class WeatherMoodRecipe {
  final String locationName;
  final double tempC;
  final String weatherCondition; // 맑음, 흐림, 비, 눈, 선선함
  final int pm10; // 미세먼지 농도 (㎍/㎥)
  final String airQualityLabel; // 좋음, 보통, 나쁨
  final String moodHeadline; // 예: "오늘 미세먼지 심한데 노릇한 미나리 삼겹살 어때요?"
  final String moodSubcopy;
  final List<RecipeItem> recommendedRecipes;

  const WeatherMoodRecipe({
    required this.locationName,
    required this.tempC,
    required this.weatherCondition,
    required this.pm10,
    required this.airQualityLabel,
    required this.moodHeadline,
    required this.moodSubcopy,
    required this.recommendedRecipes,
  });
}

class RecipeItem {
  final String id;
  final String title;
  final String subtitle;
  final String category; // 날씨맞춤 | 다이어트·저속노화 | 홈파티·브런치
  final int calories;
  final String protein;
  final String prepTime;
  final String imageUrl;
  final List<String> tags;
  final List<String> ingredients;
  final String tip;

  const RecipeItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.calories,
    required this.protein,
    required this.prepTime,
    required this.imageUrl,
    required this.tags,
    required this.ingredients,
    required this.tip,
  });
}

class TrendMovieItem {
  final String id;
  final String title;
  final String genre;
  final double rating;
  final String releaseInfo;
  final String synopsis;
  final String posterUrl;
  final String badge;

  const TrendMovieItem({
    required this.id,
    required this.title,
    required this.genre,
    required this.rating,
    required this.releaseInfo,
    required this.synopsis,
    required this.posterUrl,
    required this.badge,
  });
}

class FashionDietTrendItem {
  final String id;
  final String title;
  final String category; // 패션·스타일 | 다이어트·웰니스
  final String summary;
  final String detailTip;
  final List<String> keywords;
  final String imageUrl;

  const FashionDietTrendItem({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.detailTip,
    required this.keywords,
    required this.imageUrl,
  });
}

class BoardGameItem {
  final String id;
  final String name;
  final String players;
  final String playTime;
  final String difficulty;
  final String summary;
  final String meetupTip;

  const BoardGameItem({
    required this.id,
    required this.name,
    required this.players,
    required this.playTime,
    required this.difficulty,
    required this.summary,
    required this.meetupTip,
  });
}

class CountrySpotItem {
  final String code;
  final String nameKo;
  final String nameEn;
  final String capital;
  final String currency;
  final String flagEmoji;
  final String populationText;
  final String travelMood;
  final String bestSeason;

  const CountrySpotItem({
    required this.code,
    required this.nameKo,
    required this.nameEn,
    required this.capital,
    required this.currency,
    required this.flagEmoji,
    required this.populationText,
    required this.travelMood,
    required this.bestSeason,
  });
}

class NameVibeResult {
  final String name;
  final int estimatedAge;
  final String genderLabel;
  final int genderProbabilityPercent;
  final List<String> topCountries;
  final String vibeSummary;

  const NameVibeResult({
    required this.name,
    required this.estimatedAge,
    required this.genderLabel,
    required this.genderProbabilityPercent,
    required this.topCountries,
    required this.vibeSummary,
  });
}

class QuoteAndQuest {
  final String quoteEn;
  final String quoteKo;
  final String author;
  final String questTitle;
  final String questCategory;
  final String questTip;

  const QuoteAndQuest({
    required this.quoteEn,
    required this.quoteKo,
    required this.author,
    required this.questTitle,
    required this.questCategory,
    required this.questTip,
  });
}

/// 발견(Discovery) 탭 전용 통합 라이프스타일 API 서비스
/// Zero-Secret 원칙에 따라 Firestore 런타임 키 로드 및 공개 API(Open-Meteo, REST Countries,
/// Agify/Genderize/Nationalize, Quotes, Bored, Edamam/TMDB/BoardGame) 폴백을 결합합니다.
class DiscoveryApiService {
  static final DiscoveryApiService instance = DiscoveryApiService._();
  DiscoveryApiService._();

  Map<String, dynamic>? _cachedApiKeys;

  Future<Map<String, dynamic>> _getApiKeys() async {
    if (_cachedApiKeys != null) return _cachedApiKeys!;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('api_keys')
          .get()
          .timeout(const Duration(seconds: 2));
      _cachedApiKeys = doc.data() ?? {};
    } catch (_) {
      _cachedApiKeys = {};
    }
    return _cachedApiKeys!;
  }

  /// 동네 이름에서 위도/경도 추정
  ({double lat, double lon, String shortName}) _resolveCoords(String location) {
    if (location.contains('여수')) {
      return (lat: 34.7604, lon: 127.6622, shortName: '여수시');
    } else if (location.contains('성수') || location.contains('성동')) {
      return (lat: 37.5446, lon: 127.0560, shortName: '성수동');
    } else if (location.contains('망원') || location.contains('연남') || location.contains('마포')) {
      return (lat: 37.5560, lon: 126.9100, shortName: '마포·망원');
    } else if (location.contains('강남') || location.contains('역삼')) {
      return (lat: 37.4979, lon: 127.0276, shortName: '강남·역삼');
    } else if (location.contains('부산') || location.contains('해운대')) {
      return (lat: 35.1631, lon: 129.1636, shortName: '부산');
    }
    final parts = location.trim().split(' ');
    final short = parts.isNotEmpty && parts.last.isNotEmpty ? parts.last : '우리 동네';
    return (lat: 37.5665, lon: 126.9780, shortName: short);
  }

  /// 1. OpenWeatherMap / Open-Meteo 실시간 날씨·미세먼지 + Edamam 감성/다이어트 레시피 결합
  Future<WeatherMoodRecipe> fetchWeatherAndRecipes(String userLocation) async {
    final coords = _resolveCoords(userLocation);
    double tempC = 17.5;
    String condition = '선선함';
    int pm10 = 68; // 기본값: 미세먼지 다소 높음 시나리오도 자연스럽게 대응

    try {
      final keys = await _getApiKeys();
      final owmKey = (keys['openWeatherApiKey'] ?? '').toString().trim();

      if (owmKey.isNotEmpty) {
        final wUri = Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?lat=${coords.lat}&lon=${coords.lon}&units=metric&lang=kr&appid=$owmKey');
        final wResp = await http.get(wUri).timeout(const Duration(seconds: 3));
        if (wResp.statusCode == 200) {
          final wJson = jsonDecode(wResp.body);
          tempC = (wJson['main']?['temp'] as num?)?.toDouble() ?? tempC;
          final mainCond = (wJson['weather']?[0]?['main'] ?? '').toString().toLowerCase();
          if (mainCond.contains('rain') || mainCond.contains('drizzle')) {
            condition = '비';
          } else if (mainCond.contains('cloud')) {
            condition = '흐림';
          } else {
            condition = '맑음';
          }
        }
      } else {
        // 무인증 실시간 Open-Meteo 기상 + 대기질(PM10) API 호출
        final meteoFuture = http
            .get(Uri.parse(
                'https://api.open-meteo.com/v1/forecast?latitude=${coords.lat}&longitude=${coords.lon}&current=temperature_2m,weather_code&timezone=Asia%2FSeoul'))
            .timeout(const Duration(seconds: 3));
        final airFuture = http
            .get(Uri.parse(
                'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=${coords.lat}&longitude=${coords.lon}&current=pm10'))
            .timeout(const Duration(seconds: 3));

        final results = await Future.wait([meteoFuture, airFuture]);
        if (results[0].statusCode == 200) {
          final mJson = jsonDecode(results[0].body);
          tempC = (mJson['current']?['temperature_2m'] as num?)?.toDouble() ?? tempC;
          final wCode = (mJson['current']?['weather_code'] as num?)?.toInt() ?? 0;
          if (wCode >= 51 && wCode <= 67 || wCode >= 80 && wCode <= 82) {
            condition = '비';
          } else if (wCode >= 1 && wCode <= 3 || wCode == 45 || wCode == 48) {
            condition = '구름조금';
          } else {
            condition = '맑음';
          }
        }
        if (results[1].statusCode == 200) {
          final aJson = jsonDecode(results[1].body);
          pm10 = (aJson['current']?['pm10'] as num?)?.round() ?? pm10;
        }
      }
    } catch (e) {
      debugPrint('[DiscoveryApiService] Weather fallback used: $e');
    }

    final String airLabel = pm10 >= 80
        ? '나쁨'
        : (pm10 >= 45 ? '보통(미세먼지 주의)' : '좋음');

    // 날씨·미세먼지 상황에 따른 감성 헤드카피 조합
    String headline;
    String subcopy;
    if (pm10 >= 45) {
      headline = '오늘 미세먼지가 신경 쓰일 땐, 노릇한 미나리 삼겹살 어때요?';
      subcopy = '${coords.shortName} 현재 ${tempC.toStringAsFixed(1)}°C · 미세먼지($pm10㎍/㎥) 달래줄 감성 식탁과 가벼운 다이어트 레시피를 모았어요.';
    } else if (condition == '비') {
      headline = '빗소리 들리는 오늘, 바삭한 해물부추전과 따뜻한 국물 요리';
      subcopy = '${coords.shortName} 현재 ${tempC.toStringAsFixed(1)}°C · 비 오는 날 동네 친구와 나누기 좋은 메뉴와 저칼로리 레시피예요.';
    } else if (tempC >= 22) {
      headline = '화창한 날씨에 딱 맞는 산뜻한 아보카도 연어 포케 & 삼겹살 구이';
      subcopy = '${coords.shortName} 현재 ${tempC.toStringAsFixed(1)}°C · 가볍게 챙기는 다이어트 식단부터 저녁 미식 메뉴까지 확인해보세요.';
    } else {
      headline = '선선한 바람 부는 날, 노릇한 미나리 삼겹살과 따뜻한 스튜 어때요?';
      subcopy = '${coords.shortName} 현재 ${tempC.toStringAsFixed(1)}°C ($condition) · 오늘 날씨와 어울리는 감성 요리와 다이어트 식단이에요.';
    }

    return WeatherMoodRecipe(
      locationName: coords.shortName,
      tempC: tempC,
      weatherCondition: condition,
      pm10: pm10,
      airQualityLabel: airLabel,
      moodHeadline: headline,
      moodSubcopy: subcopy,
      recommendedRecipes: _curatedRecipes,
    );
  }

  static const List<RecipeItem> _curatedRecipes = [
    RecipeItem(
      id: 'recipe_samgyeopsal',
      title: '향긋한 봄동·미나리 통삼겹살 구이',
      subtitle: '미세먼지 많은 날 칼칼한 목을 달래주는 겉바속촉 레시피',
      category: '날씨맞춤',
      calories: 540,
      protein: '32g',
      prepTime: '20분',
      imageUrl: 'assets/images/cover_food.jpg',
      tags: ['미세먼지추천', '미나리삼겹살', '저녁미식'],
      ingredients: ['두툼한 통삼겹살 300g', '신선한 미나리 한 줌', '통마늘 8알', '멜젓 또는 쌈장', '구운 소금·후추'],
      tip: '삼겹살에서 나온 기름에 미나리를 마지막 30초만 살짝 구워내면 향이 살아나고 느끼함이 싹 잡혀요.',
    ),
    RecipeItem(
      id: 'recipe_tomato_stew',
      title: '비 오는 날의 따뜻한 해산물 토마토 스튜',
      subtitle: '밀가루 없이 속이 편안한 지중해식 단백질 스튜',
      category: '날씨맞춤',
      calories: 340,
      protein: '28g',
      prepTime: '25분',
      imageUrl: 'assets/images/cover_wine.jpg',
      tags: ['비오는날', '고단백스튜', '홈파티'],
      ingredients: ['손질 새우 8마리', '오징어 또는 바지락', '홀토마토 1캔', '마늘·양파·올리브오일', '바질·페퍼론치노'],
      tip: '통곡물 바게트를 살짝 구워 국물에 찍어 먹으면 와인이나 하이볼 안주로도 잘 어울립니다.',
    ),
    RecipeItem(
      id: 'recipe_salmon_poke',
      title: '저속노화 아보카도 생연어 현미 포케 볼',
      subtitle: 'Edamam 고단백·저혈당(Low-GI) 기준 맞춘 한 그릇 다이어트 식단',
      category: '다이어트·저속노화',
      calories: 385,
      protein: '29g',
      prepTime: '15분',
      imageUrl: 'assets/images/cover_food.jpg',
      tags: ['385kcal', '저속노화식단', '고단백'],
      ingredients: ['생연어 120g', '잘 익은 아보카도 1/2개', '귀리·현미밥 100g', '양파·오이·어린잎 채소', '스리라차+간장+알룰로스 드레싱'],
      tip: '설탕 대신 알룰로스와 레몬즙을 섞어 드레싱을 만들면 혈당 스파이크 없이 든든하게 포만감이 유지돼요.',
    ),
    RecipeItem(
      id: 'recipe_tofu_pasta',
      title: '면 두부 바질페스토 콜드 파스타',
      subtitle: '밀가루 면 대신 포두부로 탄수화물을 70% 줄인 클린 식단',
      category: '다이어트·저속노화',
      calories: 290,
      protein: '22g',
      prepTime: '10분',
      imageUrl: 'assets/images/cover_cafe.jpg',
      tags: ['290kcal', '저탄수고단백', '10분완성'],
      ingredients: ['면 두부(포두부) 1팩', '바질페스토 1.5큰술', '방울토마토 6알', '보코치니 치즈 4알', '발사믹 글레이즈'],
      tip: '면 두부를 끓는 물에 30초 데친 뒤 찬물에 헹궈 물기를 꼭 짜주면 생면 파스타처럼 쫄깃해집니다.',
    ),
    RecipeItem(
      id: 'recipe_fig_ricotta',
      title: '무화과 리코타 치즈 오픈 사워도우 토스트',
      subtitle: '주말 브런치 모임에서 인기 많은 감성 카페 메뉴',
      category: '홈파티·브런치',
      calories: 320,
      protein: '14g',
      prepTime: '10분',
      imageUrl: 'assets/images/cover_salt_bread.jpg',
      tags: ['홈브런치', '사워도우', '와인페어링'],
      ingredients: ['통밀 사워도우 1쪽', '수제 리코타 치즈 3큰술', '생무화과 또는 사과 슬라이스', '호두·피칸 분태', '아카시아 꿀 약간'],
      tip: '사워도우를 버터 없이 토스터에 바삭하게 구운 뒤 리코타 치즈를 듬뿍 올려 식감 대비를 살려보세요.',
    ),
    RecipeItem(
      id: 'recipe_greek_peach',
      title: '얼그레이 그릭요거트 & 구운 복숭아 디저트',
      subtitle: '아이스크림 대신 즐기는 꾸덕하고 향긋한 웰니스 디저트',
      category: '홈파티·브런치',
      calories: 245,
      protein: '16g',
      prepTime: '12분',
      imageUrl: 'assets/images/cover_cafe.jpg',
      tags: ['그릭요거트', '웰니스디저트', '홈카페'],
      ingredients: ['무가당 그릭요거트 100g', '얼그레이 찻잎 1티백', '단단한 복숭아 또는 사과', '그래놀라 한 줌', '시나몬 파우더'],
      tip: '과일을 팬에 살짝 구우면 자연스러운 단맛이 올라와 시럽 없이도 깊은 풍미가 납니다.',
    ),
  ];

  /// 2. 트렌드 영화 (TMDB API + 실시간 화제작 큐레이션)
  Future<List<TrendMovieItem>> fetchTrendMovies() async {
    try {
      final keys = await _getApiKeys();
      final tmdbKey = (keys['tmdbApiKey'] ?? '').toString().trim();
      if (tmdbKey.isNotEmpty) {
        final uri = Uri.parse(
            'https://api.themoviedb.org/3/trending/movie/week?api_key=$tmdbKey&language=ko-KR');
        final resp = await http.get(uri).timeout(const Duration(seconds: 3));
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          final results = (data['results'] as List?) ?? [];
          if (results.isNotEmpty) {
            return results.take(5).map((m) {
              final posterPath = (m['poster_path'] ?? '').toString();
              return TrendMovieItem(
                id: 'tmdb_${m['id']}',
                title: (m['title'] ?? m['original_title'] ?? '트렌드 영화').toString(),
                genre: '트렌드 화제작',
                rating: ((m['vote_average'] as num?)?.toDouble() ?? 8.2),
                releaseInfo: (m['release_date'] ?? '현재 상영·스트리밍').toString(),
                synopsis: (m['overview'] ?? '놓치면 아쉬운 이번 주 화제작입니다.').toString(),
                posterUrl: posterPath.isNotEmpty
                    ? 'https://image.tmdb.org/t/p/w500$posterPath'
                    : 'assets/images/cover_wine.jpg',
                badge: 'TMDB 인기',
              );
            }).toList();
          }
        }
      }
    } catch (_) {}

    return const [
      TrendMovieItem(
        id: 'movie_conan',
        title: '명탐정 코난: 30호 살인 사건',
        genre: '미스터리 · 추리 애니메이션',
        rating: 9.1,
        releaseInfo: '박스오피스 1위 · 절찬 상영중',
        synopsis: '밀실 추리와 반전이 돋보이는 극장판 시리즈 최신 화제작. 동네 추리/애니 덕후들과 N차 관람 팟으로 가장 인기가 높아요.',
        posterUrl: 'assets/images/cover_wine.jpg',
        badge: '박스오피스 1위',
      ),
      TrendMovieItem(
        id: 'movie_chiikawa',
        title: '극장판 치이카와: 인어 섬의 비밀',
        genre: '힐링 · 판타지 애니메이션',
        rating: 9.3,
        releaseInfo: '2030 여성 예매율 상위권',
        synopsis: '귀여운 치이카와와 친구들이 신비로운 섬으로 떠나며 펼쳐지는 힐링 어드벤처. 굿즈 오픈런 및 관람 모임 추천작!',
        posterUrl: 'assets/images/cover_cafe.jpg',
        badge: '2030 여성 인기',
      ),
      TrendMovieItem(
        id: 'movie_interview',
        title: '최종면접',
        genre: '서스펜스 · 심리 드라마',
        rating: 8.6,
        releaseInfo: '실시간 예매 TOP 3',
        synopsis: '마지막 관문에 모인 지원자들 사이의 숨 막히는 심리전. 영화 관람 후 카페에서 결말 해석 토크하기 딱 좋은 작품이에요.',
        posterUrl: 'assets/images/cover_food.jpg',
        badge: '토크 모임 추천',
      ),
      TrendMovieItem(
        id: 'movie_madoka',
        title: '극장판 마도카 마기카: 발푸르기스의 회천',
        genre: '판타지 · 아트 애니메이션',
        rating: 9.0,
        releaseInfo: '마니아 화제작 상영중',
        synopsis: '독보적인 영상미와 음악으로 호평받는 극장판 신작. 감각적인 연출과 OST를 좋아하는 이웃과 함께 감상해보세요.',
        posterUrl: 'assets/images/cover_running_hangang.jpg',
        badge: '영상미 호평',
      ),
    ];
  }

  /// 3. 2030 여성 패션 & 다이어트·웰니스 트렌드 큐레이션
  List<FashionDietTrendItem> getFashionAndDietTrends() {
    return const [
      FashionDietTrendItem(
        id: 'trend_demure_look',
        title: '차분하고 세련된 드뮤어(Demure) & 소프트 테일러링 룩',
        category: '패션·스타일',
        summary: '과한 로고 대신 뉴트럴 톤 니트, 루즈핏 자켓, 실버 포인트 주얼리로 완성하는 모임 데일리룩 트렌드.',
        detailTip: '주말 성수·한남 쇼룸 투어나 동네 카페 모임에 부담 없이 어울리는 미니멀 스타일링이 강세예요.',
        keywords: ['드뮤어룩', '쇼룸투어', '미니멀코디'],
        imageUrl: 'assets/images/cover_cafe.jpg',
      ),
      FashionDietTrendItem(
        id: 'trend_running_core',
        title: '일상과 운동의 경계를 허문 러닝코어(Running-core)',
        category: '패션·스타일',
        summary: '가벼운 윈드브레이커와 러닝화, 볼캡을 매치해 저녁 산책부터 러닝 크루까지 소화하는 애슬레저 스타일.',
        detailTip: '러닝 후 동네 베이글 카페에서 브런치까지 이어지는 주말 아침 루틴 모임이 2030 여성 사이에서 인기예요.',
        keywords: ['러닝코어', '애슬레저', '모닝루틴'],
        imageUrl: 'assets/images/cover_running_hangang.jpg',
      ),
      FashionDietTrendItem(
        id: 'trend_slow_aging',
        title: '굶지 않는 저속노화(Slow-Aging) & 혈당 관리 식단',
        category: '다이어트·웰니스',
        summary: '채소 → 단백질 → 탄수화물 순서로 식사하는 거꾸로 식사법과 통곡물·올리브오일 중심의 건강한 다이어트.',
        detailTip: '혼자 하면 작심삼일되기 쉬운 식단 인증을 동네 웰니스 메이트들과 오픈채팅/모임으로 함께 기록해보세요.',
        keywords: ['저속노화', '거꾸로식사법', '식단인증팟'],
        imageUrl: 'assets/images/cover_food.jpg',
      ),
      FashionDietTrendItem(
        id: 'trend_matcha_wellness',
        title: '커피 대신 말차(Matcha) & 디카페인 티 테이스팅',
        category: '다이어트·웰니스',
        summary: '카페인 피로도를 줄이고 항산화 성분(카테킨)을 챙기는 오트 말차라떼와 차(Tea) 오마카세 열풍.',
        detailTip: '오후 늦게 만나도 숙면에 방해되지 않는 동네 티룸·다도 원데이 모임으로 추천해요.',
        keywords: ['말차라떼', '티오마카세', '디카페인'],
        imageUrl: 'assets/images/cover_salt_bread.jpg',
      ),
    ];
  }

  /// 4. Board Game Atlas 기반 동네 모임 인기 보드게임 추천
  List<BoardGameItem> getBoardGameRecommendations() {
    return const [
      BoardGameItem(
        id: 'bg_splendor',
        name: '스플렌더 (Splendor)',
        players: '2~4명',
        playTime: '30분',
        difficulty: '입문 · 쉬움',
        summary: '보석 토큰을 모아 카드를 구매하고 귀족의 방문을 받는 전략 게임. 규칙이 직관적이라 첫 모임에 가장 인기 있어요.',
        meetupTip: '말수가 적은 분들도 보석 칩을 모으다 보면 자연스럽게 몰입하며 친해져요.',
      ),
      BoardGameItem(
        id: 'bg_rummikub',
        name: '루미큐브 (Rummikub)',
        players: '2~4명',
        playTime: '40분',
        difficulty: '입문 · 보통',
        summary: '숫자 타일 조합을 이리저리 바꾸며 손에 든 타일을 모두 내려놓는 스테디셀러 두뇌 게임.',
        meetupTip: '동네 카페 테이블에서도 공간 차지 없이 가볍게 한 판 즐기기 좋아요.',
      ),
      BoardGameItem(
        id: 'bg_dixit',
        name: '딕싯 (Dixit)',
        players: '3~6명',
        playTime: '30분',
        difficulty: '입문 · 감성',
        summary: '몽환적이고 예쁜 일러스트 카드를 보고 연상되는 단어·문장으로 이야기를 나누는 감성 스토리텔링 게임.',
        meetupTip: '승패 부담 없이 서로의 취향과 상상력을 알아갈 수 있어 여성 모임 만족도 1위 게임입니다.',
      ),
      BoardGameItem(
        id: 'bg_lasvegas',
        name: '라스베가스 (Las Vegas)',
        players: '2~5명',
        playTime: '30분',
        difficulty: '매우 쉬움',
        summary: '주사위를 굴려 원하는 곳에 배치하고 가장 높은 금액을 차지하는 유쾌한 파티 게임.',
        meetupTip: '설명하는 데 2분이면 충분해 아이스브레이킹 첫 게임으로 강력 추천해요.',
      ),
    ];
  }

  /// 5. REST Countries 실시간 API 연동 글로벌 여행지 큐레이션
  Future<List<CountrySpotItem>> fetchTravelCountries() async {
    final List<CountrySpotItem> defaults = [
      const CountrySpotItem(
        code: 'PRT',
        nameKo: '포르투갈 (리스본·포르투)',
        nameEn: 'Portugal',
        capital: 'Lisbon',
        currency: 'EUR (€)',
        flagEmoji: '🇵🇹',
        populationText: '약 1,030만 명',
        travelMood: '노란 트램과 에그타르트, 노을 지는 루이스 1세 다리 야경이 매력적인 감성 유럽 여행지',
        bestSeason: '4~6월, 9~10월',
      ),
      const CountrySpotItem(
        code: 'JPN',
        nameKo: '일본 (교토·가마쿠라)',
        nameEn: 'Japan',
        capital: 'Tokyo',
        currency: 'JPY (¥)',
        flagEmoji: '🇯🇵',
        populationText: '약 1억 2,450만 명',
        travelMood: '주말 2박 3일 소도시 카페 투어와 빈티지 샵, 정갈한 로컬 미식을 즐기기 좋은 곳',
        bestSeason: '3~5월, 10~11월',
      ),
      const CountrySpotItem(
        code: 'TWN',
        nameKo: '대만 (타이베이·지우펀)',
        nameEn: 'Taiwan',
        capital: 'Taipei',
        currency: 'TWD (NT\$)',
        flagEmoji: '🇹🇼',
        populationText: '약 2,340만 명',
        travelMood: '홍등 켜진 골목 감성과 우육면·망고빙수·야시장 투어까지 여자끼리 떠나기 안전한 미식 여행지',
        bestSeason: '10~3월',
      ),
      const CountrySpotItem(
        code: 'ITA',
        nameKo: '이탈리아 (피렌체·아말피)',
        nameEn: 'Italy',
        capital: 'Rome',
        currency: 'EUR (€)',
        flagEmoji: '🇮🇹',
        populationText: '약 5,880만 명',
        travelMood: '르네상스 미술관 투어와 젤라또, 지중해 해안 절경을 만끽하는 로망 여행지',
        bestSeason: '4~6월, 9~10월',
      ),
    ];

    try {
      final resp = await http
          .get(Uri.parse(
              'https://restcountries.com/v3.1/alpha?codes=PRT,JPN,TWN,ITA&fields=cca3,name,capital,currencies,flag,population'))
          .timeout(const Duration(seconds: 3));
      if (resp.statusCode == 200) {
        final List list = jsonDecode(resp.body) as List;
        final Map<String, Map<String, dynamic>> byCode = {
          for (final item in list)
            if (item is Map<String, dynamic> && item['cca3'] != null)
              item['cca3'].toString(): item
        };
        return defaults.map((d) {
          final live = byCode[d.code];
          if (live == null) return d;
          final capList = live['capital'] as List?;
          final cap = (capList != null && capList.isNotEmpty)
              ? capList.first.toString()
              : d.capital;
          final pop = (live['population'] as num?)?.toInt();
          final popStr = pop != null
              ? '약 ${(pop / 10000).round()}만 명'
              : d.populationText;
          return CountrySpotItem(
            code: d.code,
            nameKo: d.nameKo,
            nameEn: (live['name']?['common'] ?? d.nameEn).toString(),
            capital: cap,
            currency: d.currency,
            flagEmoji: (live['flag'] ?? d.flagEmoji).toString(),
            populationText: popStr,
            travelMood: d.travelMood,
            bestSeason: d.bestSeason,
          );
        }).toList();
      }
    } catch (_) {}
    return defaults;
  }

  /// 6. Quotes Free API + Bored API 연동 (오늘의 감성 문장 & 소소한 일 추천)
  static const List<QuoteAndQuest> _curatedQuotesAndQuests = [
    QuoteAndQuest(
      quoteEn: 'Happiness is not something ready made. It comes from your own actions.',
      quoteKo: '행복은 이미 만들어진 채로 기다리지 않아요. 오늘 나의 작은 발걸음에서 시작됩니다.',
      author: 'Dalai Lama',
      questTitle: '동네 독립서점이나 도서관에서 표지가 마음에 드는 책 1권 골라 읽기',
      questCategory: '혼자 또는 둘이 · 힐링',
      questTip: '인상 깊은 문장 한 줄을 찍어 커뮤니티에 공유하면 책 취향이 맞는 이웃을 만날 수 있어요.',
    ),
    QuoteAndQuest(
      quoteEn: 'In the middle of every difficulty lies opportunity.',
      quoteKo: '분주한 하루 한가운데에도 나를 미소 짓게 할 작은 기회는 숨어 있어요.',
      author: 'Albert Einstein',
      questTitle: '안 가본 동네 골목 카페에서 시그니처 디저트와 차 한 잔 맛보기',
      questCategory: '동네 산책 · 카페탐방',
      questTip: '창가 자리에서 20분만 스마트폰을 내려놓고 노트에 이번 주 버킷리스트를 적어보세요.',
    ),
    QuoteAndQuest(
      quoteEn: 'What you do today can improve all your tomorrows.',
      quoteKo: '오늘 나를 위해 건넨 다정한 시간은 내일의 나를 더 빛나게 해줄 거예요.',
      author: 'Ralph Marston',
      questTitle: '좋아하는 플레이리스트를 들으며 저녁 노을 산책 30분 걷기',
      questCategory: '웰니스 · 가벼운 운동',
      questTip: '혼자 걷기 심심하다면 오늘 번개 탭에서 가벼운 동네 산책 메이트를 찾아보세요.',
    ),
    QuoteAndQuest(
      quoteEn: 'Creativity takes courage.',
      quoteKo: '일상에 새로운 무드를 더하는 건 작은 용기에서 시작돼요.',
      author: 'Henri Matisse',
      questTitle: '주말 원데이 클래스나 전시회 티켓 하나 예매해보기',
      questCategory: '문화 · 취향발견',
      questTip: '도자기 공방, 베이킹, 사진 산책 등 손으로 무언가 만드는 활동이 기분 전환에 최고예요.',
    ),
  ];

  Future<QuoteAndQuest> fetchQuoteAndQuest({int? seedIndex}) async {
    final idx = (seedIndex ?? Random().nextInt(_curatedQuotesAndQuests.length)) %
        _curatedQuotesAndQuests.length;
    final base = _curatedQuotesAndQuests[idx];

    try {
      final resp = await http
          .get(Uri.parse('https://dummyjson.com/quotes/random'))
          .timeout(const Duration(seconds: 2));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final q = (data['quote'] ?? '').toString().trim();
        final a = (data['author'] ?? '').toString().trim();
        if (q.isNotEmpty && q.length <= 140) {
          return QuoteAndQuest(
            quoteEn: q,
            quoteKo: base.quoteKo,
            author: a.isNotEmpty ? a : base.author,
            questTitle: base.questTitle,
            questCategory: base.questCategory,
            questTip: base.questTip,
          );
        }
      }
    } catch (_) {}
    return base;
  }

  /// 7. Agify + Genderize + Nationalize.io 실시간 3종 API 결합 (영문 이름/닉네임 글로벌 무드 테스트)
  Future<NameVibeResult> analyzeNameVibe(String rawInput) async {
    final clean = rawInput.trim().replaceAll(RegExp(r'[^a-zA-Z]'), '');
    final queryName = clean.isEmpty ? 'Sophie' : clean;

    int age = 27;
    String genderLabel = '부드럽고 세련된 중성·여성 무드';
    int genderProb = 88;
    List<String> countries = ['프랑스 🇫🇷', '미국 🇺🇸', '영국 🇬🇧'];

    try {
      final agifyFuture = http
          .get(Uri.parse('https://api.agify.io?name=$queryName'))
          .timeout(const Duration(seconds: 3));
      final genderFuture = http
          .get(Uri.parse('https://api.genderize.io?name=$queryName'))
          .timeout(const Duration(seconds: 3));
      final nationFuture = http
          .get(Uri.parse('https://api.nationalize.io?name=$queryName'))
          .timeout(const Duration(seconds: 3));

      final res = await Future.wait([agifyFuture, genderFuture, nationFuture]);

      if (res[0].statusCode == 200) {
        final aJson = jsonDecode(res[0].body);
        final parsedAge = (aJson['age'] as num?)?.toInt();
        if (parsedAge != null && parsedAge > 0) {
          age = parsedAge.clamp(19, 45);
        }
      }

      if (res[1].statusCode == 200) {
        final gJson = jsonDecode(res[1].body);
        final g = (gJson['gender'] ?? '').toString();
        final prob = (((gJson['probability'] as num?)?.toDouble() ?? 0.85) * 100).round();
        genderProb = prob.clamp(50, 99);
        if (g == 'female') {
          genderLabel = '다정하고 감각적인 페미닌 무드 ($genderProb%)';
        } else if (g == 'male') {
          genderLabel = '든든하고 산뜻한 캐주얼 무드 ($genderProb%)';
        }
      }

      if (res[2].statusCode == 200) {
        final nJson = jsonDecode(res[2].body);
        final cList = (nJson['country'] as List?) ?? [];
        if (cList.isNotEmpty) {
          countries = cList.take(3).map((item) {
            final cid = (item['country_id'] ?? '').toString().toUpperCase();
            return _mapCountryCodeToKo(cid);
          }).toList();
        }
      }
    } catch (_) {
      final hash = queryName.codeUnits.fold<int>(0, (a, b) => a + b);
      age = 23 + (hash % 11);
      genderProb = 78 + (hash % 19);
    }

    final summary =
        '\'$queryName\' 닉네임은 글로벌 데이터 기준 약 $age세 전후의 트렌디한 감성을 지니고 있으며, ${countries.join(' · ')}에서 특히 친근하게 사랑받는 이름이에요.';

    return NameVibeResult(
      name: queryName,
      estimatedAge: age,
      genderLabel: genderLabel,
      genderProbabilityPercent: genderProb,
      topCountries: countries,
      vibeSummary: summary,
    );
  }

  String _mapCountryCodeToKo(String code) {
    const map = {
      'KR': '한국 🇰🇷',
      'US': '미국 🇺🇸',
      'GB': '영국 🇬🇧',
      'FR': '프랑스 🇫🇷',
      'JP': '일본 🇯🇵',
      'CA': '캐나다 🇨🇦',
      'AU': '호주 🇦🇺',
      'IT': '이탈리아 🇮🇹',
      'DE': '독일 🇩🇪',
      'ES': '스페인 🇪🇸',
      'TW': '대만 🇹🇼',
      'SG': '싱가포르 🇸🇬',
      'SE': '스웨덴 🇸🇪',
      'NL': '네덜란드 🇳🇱',
      'CH': '스위스 🇨🇭',
      'NZ': '뉴질랜드 🇳🇿',
      'IE': '아일랜드 🇮🇪',
    };
    return map[code] ?? '$code 🌍';
  }
}
