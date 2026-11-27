import 'package:flutter/foundation.dart';
import '../utils/location_helper.dart';
import '../utils/oomu_ui_helpers.dart';
import 'naver_map_service.dart';

/// 사용자가 가입하거나 설정한 동네(예: 영등포구 신길동, 여수시 화장동 등 전국 모든 읍·면·동)에
/// 활성 모임이 부족할 때, 해당 동네의 실제 장소(네이버 지도 지오코딩 & GitHub Actions 주간 크롤러 연동)를 기반으로
/// 봇 호스트들이 자동으로 동네 놀거리·번개·취향 모임을 생성해 주는 서비스.
class RegionalBotMeetupService {
  RegionalBotMeetupService._();

  static final Map<String, List<Map<String, dynamic>>> _cachedByLocation = {};
  static final Set<String> _enrichingLocations = {};

  /// 동네명에서 짧은 핵심 동 이름 추출 (예: '서울 영등포구 신길동' -> '신길동')
  static String extractDongName(String rawLocation) {
    final clean = rawLocation.trim();
    if (clean.isEmpty) return '우리 동네';
    final parts = clean
        .replaceAll('(', ' ')
        .replaceAll(')', ' ')
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '우리 동네';
    for (final p in parts.reversed) {
      if (p.endsWith('동') ||
          p.endsWith('읍') ||
          p.endsWith('면') ||
          p.endsWith('가')) {
        return p;
      }
    }
    return parts.last;
  }

  /// 동네명에서 구/시+동 표준 라벨 추출 (예: '서울특별시 영등포구 신길동' -> '영등포구 신길동')
  static String extractRegionLabel(String rawLocation) {
    final clean = rawLocation.trim();
    if (clean.isEmpty) return '영등포구 신길동';
    final parts = clean.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[parts.length - 2]} ${parts.last}';
    }
    return clean;
  }

  /// 해당 동네의 기본 중심 좌표 조회
  static ({double lat, double lng}) _baseCoordsFor(String rawLocation) {
    final found = LocationHelper.findCoordsForLocation(rawLocation);
    if (found != null) {
      return (lat: found['lat']!, lng: found['lng']!);
    }
    if (rawLocation.contains('신길')) {
      return (lat: 37.5113, lng: 126.9214);
    }
    return (lat: 37.5113, lng: 126.9214);
  }

  /// 현재 설정된 동네에 맞는 '오늘 번개' 상단 가로 스팟 목록 반환 (타 지역 홍대 고정 노출 차단)
  static List<Map<String, dynamic>> getLiveLightningSpotsForLocation(
    String rawLocation,
  ) {
    final dong = extractDongName(rawLocation);
    final region = extractRegionLabel(rawLocation);
    final base = _baseCoordsFor(rawLocation);

    return [
      {
        'id': 'spot_${dong}_01',
        'title': '$dong 퇴근 후 수제맥주 & 하이볼 번개 🍺',
        'location': '$region 로데오거리 라운지',
        'distance': '$dong 중심 도보 4분',
        'timeLeft': '오늘 번개',
        'category': '오늘 번개',
        'members': '2/4',
        'host': '${dong}미식가_정재',
        'hostUid': 'bot_host_jeongjae',
        'hostAvatar': 'assets/images/정재.png',
        'memberAvatars': ['assets/images/정재.png', 'assets/images/민지.png'],
        'memberNames': ['${dong}미식가_정재', '${dong}이웃_민지'],
        'manner': 43.2,
        'image': 'assets/images/cover_wine.jpg',
        'imageUrl': 'assets/images/cover_wine.jpg',
        'isLightning': true,
        'date': '오늘 저녁 7시 30분',
        'lat': base.lat + 0.0018,
        'lng': base.lng - 0.0015,
      },
      {
        'id': 'spot_${dong}_02',
        'title': '$dong 감성 카페 디저트 & 커피 수다 ☕',
        'location': '$region 역세권 로스터리 카페',
        'distance': '$dong 기준 320m',
        'timeLeft': '오늘 번개',
        'category': '오늘 번개',
        'members': '2/4',
        'host': '${dong}카페러_민지',
        'hostUid': 'bot_host_minji',
        'hostAvatar': 'assets/images/민지.png',
        'memberAvatars': ['assets/images/민지.png', 'assets/images/지연.png'],
        'memberNames': ['${dong}카페러_민지', '${dong}디저트_지연'],
        'manner': 42.6,
        'image': 'assets/images/cover_cafe.jpg',
        'imageUrl': 'assets/images/cover_cafe.jpg',
        'isLightning': true,
        'date': '오늘 저녁 8시',
        'lat': base.lat + 0.0032,
        'lng': base.lng - 0.0028,
      },
      {
        'id': 'spot_${dong}_03',
        'title': '$dong 저녁 바람 쐬며 공원 산책 & 러닝 🏃',
        'location': '$region 근린공원 산책로 입구',
        'distance': '$dong 기준 450m',
        'timeLeft': '모집 중',
        'category': '오늘 번개',
        'members': '3/4',
        'host': '${dong}러너_지훈',
        'hostUid': 'bot_host_jihoon',
        'hostAvatar': 'assets/images/지훈.png',
        'memberAvatars': [
          'assets/images/지훈.png',
          'assets/images/시연.png',
          'assets/images/정재.png'
        ],
        'memberNames': ['${dong}러너_지훈', '${dong}산책_시연', '${dong}이웃_정재'],
        'manner': 44.1,
        'image': 'assets/images/cover_running.jpg',
        'imageUrl': 'assets/images/cover_running.jpg',
        'isLightning': true,
        'date': '오늘 밤 8시 30분',
        'lat': base.lat - 0.0024,
        'lng': base.lng - 0.0035,
      },
    ];
  }

  /// 해당 동네에 매칭되는 모임이 부족할 때 즉시 반환 + 실제 네이버 장소로 비동기 보강
  static List<Map<String, dynamic>> ensureMeetupsForLocation(
    String rawLocation,
    List<Map<String, dynamic>> currentMeetups, {
    VoidCallback? onEnriched,
  }) {
    final cleanLoc = rawLocation.trim();
    if (cleanLoc.isEmpty) return currentMeetups;

    final matching = currentMeetups.where((m) {
      final loc = (m['location'] ?? '').toString();
      return OomuUiHelpers.matchesRegionFilter(cleanLoc, loc);
    }).toList();

    if (matching.length >= 3) {
      return currentMeetups;
    }

    final dong = extractDongName(cleanLoc);
    final generated = _cachedByLocation[dong] ?? _buildDefaultRegionalMeetups(cleanLoc);
    _cachedByLocation[dong] = generated;

    if (!_enrichingLocations.contains(dong)) {
      _enrichingLocations.add(dong);
      _enrichWithRealNaverPlaces(cleanLoc, dong, onEnriched);
    }

    final existingIds =
        currentMeetups.map((m) => (m['id'] ?? '').toString()).toSet();
    final merged = List<Map<String, dynamic>>.from(currentMeetups);
    for (final item in generated) {
      final id = (item['id'] ?? '').toString();
      if (!existingIds.contains(id)) {
        merged.add(item);
      }
    }
    return merged;
  }

  static List<Map<String, dynamic>> _buildDefaultRegionalMeetups(
    String rawLocation,
  ) {
    final dong = extractDongName(rawLocation);
    final region = extractRegionLabel(rawLocation);
    final base = _baseCoordsFor(rawLocation);

    final bool isSingil = dong.contains('신길') || rawLocation.contains('영등포');

    final cafePlace = isSingil ? '스타벅스 신길역점 ($region)' : '$region 감성 로스터리 카페';
    final foodPlace =
        isSingil ? '$region 신길역 로컬 다이닝 & 하이볼 바' : '$region 로컬 맛집 & 와인바';
    final parkPlace =
        isSingil ? '$region 신길근린공원 산책로 입구' : '$region 근린공원 산책로';
    final playPlace =
        isSingil ? '$region 신길역 코인노래방 & 보드게임 아지트' : '$region 보드게임 & 코인노래방';

    return [
      {
        'id': 'bot_auto_${dong}_cafe_01',
        'title': '$dong 감성 카페에서 퇴근 후 커피 & 디저트 토크',
        'description':
            '$region 근처에 사는 동네 이웃끼리 편하게 커피와 디저트 먹으며 이야기 나눠요! 처음 오시는 분들도 어색하지 않게 호스트가 반갑게 맞이해 드립니다.',
        'location': cafePlace,
        'distance': '$dong 기준 320m · 도보 5분',
        'category': '카페·디저트',
        'mainCategory': '일상 & 푸드',
        'vibe': '소소하게',
        'members': '2/4',
        'maxMembers': 4,
        'host': '${dong}카페러_민지',
        'hostUid': 'bot_host_minji',
        'hostAvatar': 'assets/images/민지.png',
        'memberAvatars': ['assets/images/민지.png', 'assets/images/지연.png'],
        'memberNames': ['${dong}카페러_민지', '${dong}디저트_지연'],
        'manner': 43.2,
        'mannerTemp': 43.2,
        'imageUrl': 'assets/images/cover_cafe.jpg',
        'photos': ['assets/images/cover_cafe.jpg'],
        'date': '이번 주 금요일 오후 7시 30분',
        'price': '각자 결제 (1만원 내외)',
        'transport': '$dong 중심 도보 이동',
        'status': 'open',
        'isVerified': true,
        'lat': base.lat + 0.0035,
        'lng': base.lng - 0.0032,
      },
      {
        'id': 'bot_auto_${dong}_dining_02',
        'title': '$dong 퇴근 후 로컬 맛집 & 시원한 하이볼 한잔 모임',
        'description':
            '퇴근하고 집에만 있기 아쉬운 저녁, $region 숨은 로컬 맛집에서 맛있는 안주에 하이볼·맥주 가볍게 한잔하며 동네 친구 만들어요!',
        'location': foodPlace,
        'distance': '$dong 기준 410m · 도보 6분',
        'category': '오늘 번개',
        'mainCategory': '일상 & 푸드',
        'vibe': '퇴근후한잔',
        'members': '3/4',
        'maxMembers': 4,
        'host': '${dong}미식가_정재',
        'hostUid': 'bot_host_jeongjae',
        'hostAvatar': 'assets/images/정재.png',
        'memberAvatars': [
          'assets/images/정재.png',
          'assets/images/지훈.png',
          'assets/images/시연.png'
        ],
        'memberNames': ['${dong}미식가_정재', '${dong}러너_지훈', '${dong}코노퀸_시연'],
        'manner': 44.0,
        'mannerTemp': 44.0,
        'imageUrl': 'assets/images/cover_wine.jpg',
        'photos': ['assets/images/cover_wine.jpg'],
        'date': '오늘 저녁 8시',
        'price': '1/N 정산',
        'transport': '$dong 역세권 집결',
        'status': 'open',
        'isVerified': true,
        'isLightning': true,
        'lat': base.lat - 0.0018,
        'lng': base.lng - 0.0022,
      },
      {
        'id': 'bot_auto_${dong}_running_03',
        'title': '$dong 저녁 바람 쐬며 공원 산책 & 가벼운 4km 러닝',
        'description':
            '혼자 뛰면 금방 지치는데 같이 달리고 산책하면 시간 가는 줄 몰라요! 초보 페이스로 천천히 달리고 시원한 이온음료 한잔해요.',
        'location': parkPlace,
        'distance': '$dong 기준 480m · 도보 7분',
        'category': '러닝',
        'mainCategory': '운동 & 액티비티',
        'vibe': '갓생살기',
        'members': '2/4',
        'maxMembers': 4,
        'host': '${dong}러너_지훈',
        'hostUid': 'bot_host_jihoon',
        'hostAvatar': 'assets/images/지훈.png',
        'memberAvatars': ['assets/images/지훈.png', 'assets/images/주아.png'],
        'memberNames': ['${dong}러너_지훈', '${dong}베이커리_주아'],
        'manner': 43.8,
        'mannerTemp': 43.8,
        'imageUrl': 'assets/images/cover_running.jpg',
        'photos': ['assets/images/cover_running.jpg'],
        'date': '이번 주 토요일 오후 8시',
        'price': '참가비 무료',
        'transport': '$dong 공원 입구 집결',
        'status': 'open',
        'isVerified': true,
        'lat': base.lat - 0.0032,
        'lng': base.lng - 0.0045,
      },
      {
        'id': 'bot_auto_${dong}_play_04',
        'title': '$dong 스트레스 확 풀리는 코인노래방 & 보드게임 팟',
        'description':
            '$region 근처에서 퇴근 후나 주말에 보드게임 한 판 하고 코인노래방에서 신나게 노래 부를 동네 친구 구해요!',
        'location': playPlace,
        'distance': '$dong 기준 290m · 도보 4분',
        'category': '이번 주말',
        'mainCategory': '문화 & 엔터',
        'vibe': '신나게',
        'members': '2/4',
        'maxMembers': 4,
        'host': '${dong}코노퀸_시연',
        'hostUid': 'bot_host_siyeon',
        'hostAvatar': 'assets/images/시연.png',
        'memberAvatars': ['assets/images/시연.png', 'assets/images/민지.png'],
        'memberNames': ['${dong}코노퀸_시연', '${dong}카페러_민지'],
        'manner': 42.5,
        'mannerTemp': 42.5,
        'imageUrl': 'assets/images/cover_food.jpg',
        'photos': ['assets/images/cover_food.jpg'],
        'date': '이번 주 토요일 오후 5시',
        'price': '각자 결제',
        'transport': '$dong 중심가 집결',
        'status': 'open',
        'isVerified': true,
        'lat': base.lat + 0.0012,
        'lng': base.lng - 0.0018,
      },
    ];
  }

  static Future<void> _enrichWithRealNaverPlaces(
    String rawLocation,
    String dong,
    VoidCallback? onEnriched,
  ) async {
    try {
      final base = _baseCoordsFor(rawLocation);
      final region = extractRegionLabel(rawLocation);
      final list = _cachedByLocation[dong];
      if (list == null || list.length < 4) return;

      final results = await Future.wait([
        NaverMapService.searchKeyword('$dong 카페', lat: base.lat, lng: base.lng, size: 3),
        NaverMapService.searchKeyword('$dong 맛집', lat: base.lat, lng: base.lng, size: 3),
        NaverMapService.searchKeyword('$dong 공원', lat: base.lat, lng: base.lng, size: 3),
        NaverMapService.searchKeyword('$dong 노래방', lat: base.lat, lng: base.lng, size: 3),
      ]);

      bool updated = false;
      for (int i = 0; i < 4; i++) {
        final places = results[i];
        if (places.isNotEmpty) {
          final p = places.first;
          list[i]['location'] = '${p.name} ($region)';
          list[i]['lat'] = p.lat;
          list[i]['lng'] = p.lng;
          list[i]['distance'] = NaverMapService.formatDistanceFromNeighborhood(
            p.lat,
            p.lng,
            userLocation: rawLocation,
          );
          updated = true;
        }
      }
      if (updated && onEnriched != null) {
        onEnriched();
      }
    } catch (_) {}
  }
}
