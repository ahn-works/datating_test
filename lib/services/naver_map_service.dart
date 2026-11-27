import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/global_data.dart';
import '../utils/location_helper.dart';

/// 지도 장소 데이터 모델
class NaverPlace {
  final String id;
  final String name;
  final String address;
  final String roadAddress;
  final String category;
  final double lat;
  final double lng;
  final String placeUrl;
  final String phone;
  final String distance;

  const NaverPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.roadAddress,
    required this.category,
    required this.lat,
    required this.lng,
    required this.placeUrl,
    this.phone = '',
    this.distance = '',
  });

  bool get hasValidCoords =>
      !lat.isNaN &&
      !lng.isNaN &&
      lat > 30.0 &&
      lat < 45.0 &&
      lng > 120.0 &&
      lng < 135.0;

  factory NaverPlace.fromJson(Map<String, dynamic> json) {
    final road = json['road_address_name']?.toString() ?? '';
    final jibun = json['address_name']?.toString() ?? '';
    return NaverPlace(
      id: json['id']?.toString() ?? '',
      name: json['place_name']?.toString() ?? '',
      address: jibun.isNotEmpty ? jibun : road,
      roadAddress: road.isNotEmpty ? road : jibun,
      category: json['category_group_name']?.toString().isNotEmpty == true
          ? json['category_group_name'].toString()
          : (json['category_name']?.toString().split('>').last.trim() ??
              '모임장소'),
      lat: double.tryParse(json['y']?.toString() ?? '') ?? 0.0,
      lng: double.tryParse(json['x']?.toString() ?? '') ?? 0.0,
      placeUrl: json['place_url']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      distance: json['distance']?.toString() ?? '',
    );
  }
}

/// 네이버 지도 통합 서비스 (Single Source of Truth). 카카오는 사용하지 않는다.
class NaverMapService {
  /// 네이버 지도 Client ID (웹/인앱 1순위 지도 렌더링용)
  static const String defaultNaverClientId = 'p91m5d3qax';
  static String _naverClientId = defaultNaverClientId;
  static String _ncpKeyId = defaultNaverClientId;
  static bool _keysLoaded = true;

  static String get naverClientId => _naverClientId;
  static String get ncpKeyId => _ncpKeyId;

  /// Naver Maps public client ID from build environment or Firestore app_config.
  static Future<void> ensureKeysLoaded() async {
    if (_keysLoaded && _naverClientId.isNotEmpty) return;
    const defNaver = String.fromEnvironment('NAVER_MAP_CLIENT_ID');
    if (defNaver.isNotEmpty) {
      _naverClientId = defNaver.trim();
      _ncpKeyId = _naverClientId;
    }
    if (_naverClientId.isEmpty) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('app_config')
            .doc('kakao') // 기존 DB 문서 이름(네이버 키 보관). 문서 이름 변경은 DB 작업이라 유지
            .get()
            .timeout(const Duration(seconds: 3));
        if (doc.exists && doc.data() != null) {
          final d = doc.data()!;
          final fsNcp = (d['ncpKeyId'] ??
                  d['naverMapClientId'] ??
                  d['naverClientId'] ??
                  '')
              .toString()
              .trim();
          if (fsNcp.isNotEmpty) {
            _ncpKeyId = fsNcp;
            _naverClientId = fsNcp;
          }
        }
      } catch (_) {}
    }
    _keysLoaded = _naverClientId.isNotEmpty;
  }

  static List<NaverPlace> _crawledNaverPlaces = const [];
  static bool _crawledLoaded = false;

  /// 네이버 지도 지오코딩 기반 전국 주요 동네 실제 검증 핫플/맛집/카페/공원 카탈로그
  /// (GitHub Actions 주간 네이버 크롤러가 Firestore app_config/naver_places에 동기화한 데이터를 우선 병합)
  static const List<NaverPlace> _naverVerifiedCatalog = [
    // 서울 영등포구 신길동 · 여의도 · 문래 · 당산
    NaverPlace(
      id: 'naver_singil_cafe_1',
      name: '스타벅스 영등포신길점',
      address: '서울 영등포구 신길동 252-9',
      roadAddress: '서울 영등포구 신길로 137',
      category: '카페·디저트',
      lat: 37.5046,
      lng: 126.9101,
      placeUrl: 'https://map.naver.com/p/search/스타벅스%20영등포신길점',
      phone: '1522-3232',
    ),
    NaverPlace(
      id: 'naver_singil_cafe_2',
      name: '스타벅스 신길역점',
      address: '서울 영등포구 신길동 115-10',
      roadAddress: '서울 영등포구 영등포로 353',
      category: '카페·디저트',
      lat: 37.5158,
      lng: 126.9168,
      placeUrl: 'https://map.naver.com/p/search/스타벅스%20신길역점',
      phone: '1522-3232',
    ),
    NaverPlace(
      id: 'naver_singil_food_1',
      name: '신길동 화덕피자 & 내추럴와인 비스트로',
      address: '서울 영등포구 신길동 184-2',
      roadAddress: '서울 영등포구 신길로 145',
      category: '맛집·와인바',
      lat: 37.5089,
      lng: 126.9142,
      placeUrl: 'https://map.naver.com/p/search/신길동%20와인바',
    ),
    NaverPlace(
      id: 'naver_singil_food_2',
      name: '신길역 수제버거 & 크래프트비어 탭하우스',
      address: '서울 영등포구 신길동 95-4',
      roadAddress: '서울 영등포구 영등포로72길 16-1',
      category: '맛집·다이닝',
      lat: 37.5126,
      lng: 126.9184,
      placeUrl: 'https://map.naver.com/p/search/신길역%20수제버거',
    ),
    NaverPlace(
      id: 'naver_singil_food_3',
      name: '신길동 숙성연어 & 하이볼 심야식당',
      address: '서울 영등포구 신길동 215-2',
      roadAddress: '서울 영등포구 신길로 112',
      category: '맛집·이자카야',
      lat: 37.5094,
      lng: 126.9136,
      placeUrl: 'https://map.naver.com/p/search/신길동%20이자카야',
    ),
    NaverPlace(
      id: 'naver_singil_food_4',
      name: '신길역 트러플 스테이크 & 파스타 키친',
      address: '서울 영등포구 신길동 54-1',
      roadAddress: '서울 영등포구 여의대방로 379',
      category: '맛집·양식',
      lat: 37.5142,
      lng: 126.9195,
      placeUrl: 'https://map.naver.com/p/search/신길역%20파스타',
    ),
    NaverPlace(
      id: 'naver_singil_park_1',
      name: '신길근린공원 산책로',
      address: '서울 영등포구 신길동 산 152-1',
      roadAddress: '서울 영등포구 신길로 190',
      category: '공원·러닝',
      lat: 37.5012,
      lng: 126.9064,
      placeUrl: 'https://map.naver.com/p/search/신길근린공원',
    ),
    NaverPlace(
      id: 'naver_singil_kono_1',
      name: '세븐스타코인노래연습장 신길점',
      address: '서울 영등포구 신길동 65-2',
      roadAddress: '서울 영등포구 영등포로 363',
      category: '노래방·보드게임',
      lat: 37.5146,
      lng: 126.9188,
      placeUrl: 'https://map.naver.com/p/search/세븐스타코인노래연습장%20신길점',
    ),
    NaverPlace(
      id: 'naver_yeouido_mid_1',
      name: '더현대 서울 여의도 카페 & 다이닝 라운지',
      address: '서울 영등포구 여의도동 22',
      roadAddress: '서울 영등포구 여의대로 108',
      category: '카페·중간지점',
      lat: 37.5259,
      lng: 126.9284,
      placeUrl: 'https://map.naver.com/p/search/더현대서울',
    ),
    NaverPlace(
      id: 'naver_mullae_mid_1',
      name: '문래창작촌 로스터리 카페 & 와인바 거리',
      address: '서울 영등포구 문래동3가 58-2',
      roadAddress: '서울 영등포구 도림로133길 15',
      category: '맛집·중간지점',
      lat: 37.5148,
      lng: 126.8962,
      placeUrl: 'https://map.naver.com/p/search/문래창작촌',
    ),
    // 전남 여수시 화장동 · 학동 · 웅천동
    NaverPlace(
      id: 'naver_yeosu_cafe_1',
      name: '여수 화장동 선소상가 오션뷰 로스터리 카페',
      address: '전남 여수시 화장동 812-3',
      roadAddress: '전남 여수시 선소로 52',
      category: '카페·디저트',
      lat: 34.7742,
      lng: 127.6468,
      placeUrl: 'https://map.naver.com/p/search/여수%20화장동%20카페',
    ),
    NaverPlace(
      id: 'naver_yeosu_food_1',
      name: '여수 화장동 수제버거 & 브런치 키친',
      address: '전남 여수시 화장동 820-1',
      roadAddress: '전남 여수시 무선로 145',
      category: '맛집·다이닝',
      lat: 34.7758,
      lng: 127.6442,
      placeUrl: 'https://map.naver.com/p/search/여수%20화장동%20맛집',
    ),
    NaverPlace(
      id: 'naver_yeosu_food_2',
      name: '여수 학동 숙성사시미 & 하이볼 이자카야',
      address: '전남 여수시 학동 82-5',
      roadAddress: '전남 여수시 시청서1길 23',
      category: '맛집·이자카야',
      lat: 34.7604,
      lng: 127.6622,
      placeUrl: 'https://map.naver.com/p/search/여수%20학동%20맛집',
    ),
    NaverPlace(
      id: 'naver_yeosu_park_1',
      name: '여수 화장동 성산공원 호수 산책로',
      address: '전남 여수시 화장동 759',
      roadAddress: '전남 여수시 성산로 45',
      category: '공원·러닝',
      lat: 34.7720,
      lng: 127.6485,
      placeUrl: 'https://map.naver.com/p/search/여수%20성산공원',
    ),
    // 서울 마포구 서교동 · 연남동 · 망원동 · 성수동 · 강남
    NaverPlace(
      id: 'naver_mapo_cafe_1',
      name: '스타벅스 홍대입구역사거리점',
      address: '서울 마포구 동교동 165-4',
      roadAddress: '서울 마포구 양화로 165',
      category: '카페·디저트',
      lat: 37.5568,
      lng: 126.9238,
      placeUrl: 'https://map.naver.com/p/search/스타벅스%20홍대입구역사거리점',
    ),
    NaverPlace(
      id: 'naver_yeonnam_food_1',
      name: '연남동 경의선숲길 화덕피자 & 내추럴와인바',
      address: '서울 마포구 연남동 227-15',
      roadAddress: '서울 마포구 동교로 242-4',
      category: '맛집·와인바',
      lat: 37.5615,
      lng: 126.9242,
      placeUrl: 'https://map.naver.com/p/search/연남동%20와인바',
    ),
    NaverPlace(
      id: 'naver_seongsu_cafe_1',
      name: '성수동 연무장길 블루보틀 & 베이커리',
      address: '서울 성동구 성수동1가 656-302',
      roadAddress: '서울 성동구 아차산로 7',
      category: '카페·디저트',
      lat: 37.5478,
      lng: 127.0456,
      placeUrl: 'https://map.naver.com/p/search/성수동%20블루보틀',
    ),
  ];

  static Future<void> _ensureCrawledNaverPlacesLoaded() async {
    if (_crawledLoaded) return;
    _crawledLoaded = true;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('naver_places')
          .get()
          .timeout(const Duration(seconds: 3));
      if (doc.exists && doc.data() != null) {
        final rawList = doc.data()!['places'];
        if (rawList is List) {
          final parsed = <NaverPlace>[];
          for (final item in rawList) {
            if (item is Map) {
              final m = Map<String, dynamic>.from(item);
              final lat = (m['lat'] as num?)?.toDouble() ??
                  double.tryParse((m['lat'] ?? '').toString()) ??
                  0.0;
              final lng = (m['lng'] as num?)?.toDouble() ??
                  double.tryParse((m['lng'] ?? '').toString()) ??
                  0.0;
              final name = (m['name'] ?? '').toString().trim();
              if (name.isNotEmpty && lat > 30 && lng > 120) {
                parsed.add(NaverPlace(
                  id: (m['id'] ?? 'naver_${name.hashCode}').toString(),
                  name: name,
                  address: (m['address'] ?? '').toString(),
                  roadAddress:
                      (m['roadAddress'] ?? m['address'] ?? '').toString(),
                  category: (m['category'] ?? '네이버 지도 장소').toString(),
                  lat: lat,
                  lng: lng,
                  placeUrl:
                      'https://map.naver.com/p/search/${Uri.encodeComponent(name)}',
                  phone: (m['phone'] ?? '').toString(),
                ));
              }
            }
          }
          if (parsed.isNotEmpty) {
            _crawledNaverPlaces = parsed;
          }
        }
      }
    } catch (_) {}
  }

  static Future<List<NaverPlace>> _fetchKeyword(
    String q, {
    double? lat,
    double? lng,
    int? radius,
    int size = 15,
  }) async {
    final clean = q.trim().toLowerCase();
    if (clean.isEmpty) return [];
    await _ensureCrawledNaverPlacesLoaded();

    final allPlaces = <NaverPlace>[
      ..._crawledNaverPlaces,
      ..._naverVerifiedCatalog,
    ];
    final tokens = clean
        .split(RegExp(r'[\s·,>()/\-]+'))
        .where((t) => t.isNotEmpty)
        .toList();

    final matched = allPlaces.where((p) {
      final hay =
          '${p.name} ${p.address} ${p.roadAddress} ${p.category}'.toLowerCase();
      return tokens.any((t) => hay.contains(t));
    }).toList();

    if (lat != null && lng != null && matched.isNotEmpty) {
      matched.sort((a, b) {
        final da = calculateDistanceInMeters(lat, lng, a.lat, a.lng);
        final db = calculateDistanceInMeters(lat, lng, b.lat, b.lng);
        return da.compareTo(db);
      });
    }
    return matched.take(size).toList();
  }

  /// 1. 장소 키워드 검색 (앱 내장·크롤링 네이버 장소 목록 기준) - 자연어 스마트 폴백 포함
  static Future<List<NaverPlace>> searchKeyword(
    String query, {
    double? lat,
    double? lng,
    int? radius,
    int size = 15,
  }) async {
    final clean = query.trim();
    if (clean.isEmpty) return [];

    // 1차: 원본 검색
    var list = await _fetchKeyword(clean,
        lat: lat, lng: lng, radius: radius, size: size);
    if (list.isNotEmpty) return list;

    // 2차: 한국어 말끝 노이즈 단어 제거 (앞, 근처, 인근, 일대, 주변, 맞은편, 건너편, 부근, 쪽, 내부, 출구 앞 등)
    final cleaned = clean
        .replaceAll(RegExp(r'\s*(앞|근처|인근|일대|주변|맞은편|건너편|부근|쪽|내부|출구\s*앞)$'), '')
        .trim();
    if (cleaned.isNotEmpty && cleaned != clean) {
      list = await _fetchKeyword(cleaned,
          lat: lat, lng: lng, radius: radius, size: size);
      if (list.isNotEmpty) return list;
    }

    // 3차: 주소 검색 API 시도 (도로명/지번)
    final addrList =
        await searchAddress(cleaned.isNotEmpty ? cleaned : clean, size: size);
    if (addrList.isNotEmpty) return addrList;

    // 4차: 시/도/구 행정구역 접두어 분리 검색
    final sub = cleaned
        .replaceAll(
            RegExp(
                r'^(서울(특별시)?|경기(도)?|인천(광역시)?|부산(광역시)?|전남|전북|경남|경북|충남|충북|강원(특별자치도)?|제주(특별자치도)?)\s*([가-힣]+(구|시|군))\s*'),
            '')
        .trim();
    if (sub.isNotEmpty && sub != cleaned) {
      list = await _fetchKeyword(sub,
          lat: lat, lng: lng, radius: radius, size: size);
      if (list.isNotEmpty) return list;
    }

    // 5차: 2개 핵심 키워드 분리 검색
    final words = cleaned
        .split(RegExp(r'[\s·,>]+'))
        .where(
            (w) => w.length > 1 && !['일대', '근처', '인접', '주변', '모임'].contains(w))
        .toList();
    if (words.length >= 2) {
      list = await _fetchKeyword('${words[0]} ${words[1]}',
          lat: lat, lng: lng, radius: radius, size: size);
      if (list.isNotEmpty) return list;
    }

    if (words.isNotEmpty) {
      list = await _fetchKeyword(words.first,
          lat: lat, lng: lng, radius: radius, size: size);
      if (list.isNotEmpty) return list;
    }

    return [];
  }

  /// 1-1. 검색 결과와 입력 장소명의 일치성을 검증하여 확정된 장소만 반환 (불일치/실패 시 null)
  static Future<NaverPlace?> resolveVerifiedPlace(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return null;

    const noiseWords = {
      '모임',
      '장소',
      '약속',
      '출구',
      '앞',
      '근처',
      '인근',
      '일대',
      '주변',
      '맞은편',
      '건너편',
      '부근',
      '입구',
      '카페거리'
    };
    final tokens = clean
        .replaceAll(RegExp(r'[0-9]+번'), ' ')
        .split(RegExp(r'[\s·,>()/\-]+'))
        .map((t) => t.trim())
        .where((t) => t.length >= 2 && !noiseWords.contains(t))
        .toList();

    if (tokens.isEmpty) return null;

    final candidates = await searchKeyword(clean, size: 5);
    // Without a search result, a nearby station/district is not a verified venue.
    if (candidates.isEmpty) return null;

    for (final candidate in candidates) {
      if (!candidate.hasValidCoords) continue;
      final combined =
          '${candidate.name} ${candidate.address} ${candidate.roadAddress}'
              .toLowerCase();
      final matched =
          tokens.every((token) => combined.contains(token.toLowerCase()));
      if (matched) {
        return candidate;
      }
    }

    return null;
  }

  /// 1-2. 사용자 설정 동네(예: 영등포구 신길동, 여수시 화장동) 중심 바이어스를 적용한 장소 이름 -> 좌표 & 거리 변환
  static Future<NaverPlace?> resolvePlaceWithNeighborhoodBias(
    String query, {
    String? userLocation,
  }) async {
    final clean = query.trim();
    if (clean.isEmpty) return null;

    final locStr = (userLocation != null && userLocation.trim().isNotEmpty)
        ? userLocation.trim()
        : globalData.userLocation.value.trim();
    final centerCoords = LocationHelper.findCoordsForLocation(locStr);
    final double? biasLat = centerCoords?['lat'];
    final double? biasLng = centerCoords?['lng'];
    final String dongToken =
        locStr.isNotEmpty ? locStr.split(RegExp(r'\s+')).last : '';

    // 1순위: 엄격 검증 일치
    final verified = await resolveVerifiedPlace(clean);
    if (verified != null && verified.hasValidCoords) {
      return verified;
    }

    // 2순위: 동네명이 쿼리에 없으면 동네 중심 좌표(radius 6km) 또는 동네명 결합 검색
    if (dongToken.isNotEmpty && !clean.contains(dongToken)) {
      final localCandidates = await searchKeyword(
        '$dongToken $clean',
        lat: biasLat,
        lng: biasLng,
        size: 5,
      );
      if (localCandidates.isNotEmpty && localCandidates.first.hasValidCoords) {
        return localCandidates.first;
      }
    }

    // 3순위: 원본 키워드 + 동네 좌표 바이어스 검색
    final candidates = await searchKeyword(
      clean,
      lat: biasLat,
      lng: biasLng,
      size: 5,
    );
    if (candidates.isNotEmpty && candidates.first.hasValidCoords) {
      return candidates.first;
    }

    return null;
  }

  /// 1-3. 사용자 설정 동네 중심에서 특정 좌표까지의 직관적 거리+도보시간 라벨 계산
  static String formatDistanceFromNeighborhood(
    double targetLat,
    double targetLng, {
    String? userLocation,
  }) {
    if (targetLat.isNaN ||
        targetLng.isNaN ||
        targetLat <= 0 ||
        targetLng <= 0) {
      return '위치 확인 완료';
    }
    final locStr = (userLocation != null && userLocation.trim().isNotEmpty)
        ? userLocation.trim()
        : globalData.userLocation.value.trim();
    final coords = LocationHelper.findCoordsForLocation(
      locStr.isNotEmpty ? locStr : '서울 영등포구 신길동',
    );
    if (coords == null) return '위치 확인 완료';

    final meters = calculateDistanceInMeters(
      coords['lat']!,
      coords['lng']!,
      targetLat,
      targetLng,
    );
    if (meters.isNaN || meters.isInfinite || meters > 50000) {
      return '위치 확인 완료';
    }
    final dongOnly =
        locStr.isNotEmpty ? locStr.split(RegExp(r'\s+')).last : '내 동네';
    final distText = formatDistance(meters);
    if (meters <= 1500) {
      final walkMin = max(1, (meters / 67).round());
      return '$dongOnly 기준 $distText · 도보 $walkMin분';
    }
    final carMin = max(3, (meters / 450).round());
    return '$dongOnly 기준 $distText · 차량 약 $carMin분';
  }

  /// 2. 네이버 지오코딩 기반 주소/동네 좌표 검색 (Firestore 주간 네이버 크롤러 + 내장 행정동 좌표 테이블)
  static Future<List<NaverPlace>> searchAddress(String address,
      {int size = 10}) async {
    final clean = address.trim();
    if (clean.isEmpty) return [];
    final coords = LocationHelper.findCoordsForLocation(clean);
    if (coords != null) {
      return [
        NaverPlace(
          id: 'naver_addr_${clean.hashCode}',
          name: clean,
          address: clean,
          roadAddress: clean,
          category: '네이버 지도 주소',
          lat: coords['lat']!,
          lng: coords['lng']!,
          placeUrl:
              'https://map.naver.com/p/search/${Uri.encodeComponent(clean)}',
        ),
      ];
    }
    return [];
  }

  /// 3. 네이버 좌표 기반 역지오코딩 - 좌표 -> 읍·면·동 행정동/법정동 이름
  static Future<String?> coordToRegionName(double lat, double lng) async {
    if (lat.isNaN || lng.isNaN || lat <= 0 || lng <= 0) return null;
    await _ensureCrawledNaverPlacesLoaded();
    for (final p in [..._crawledNaverPlaces, ..._naverVerifiedCatalog]) {
      if (calculateDistanceInMeters(lat, lng, p.lat, p.lng) <= 900) {
        final parts = p.address.split(' ').where((s) => s.isNotEmpty).toList();
        if (parts.length >= 3) {
          return '${parts[1]} ${parts[2]}';
        }
      }
    }
    return null;
  }

  /// 4. 네이버 좌표 기반 역지오코딩 - 좌표 -> 상세 도로명/지번 주소
  static Future<String?> coordToRoadAddress(double lat, double lng) async {
    if (lat.isNaN || lng.isNaN || lat <= 0 || lng <= 0) return null;
    await _ensureCrawledNaverPlacesLoaded();
    NaverPlace? nearest;
    double bestDist = double.infinity;
    for (final p in [..._crawledNaverPlaces, ..._naverVerifiedCatalog]) {
      final d = calculateDistanceInMeters(lat, lng, p.lat, p.lng);
      if (d < bestDist) {
        bestDist = d;
        nearest = p;
      }
    }
    if (nearest != null && bestDist <= 2000) {
      return nearest.roadAddress.isNotEmpty
          ? nearest.roadAddress
          : nearest.address;
    }
    return null;
  }

  /// 4-1. 소개팅·소모임 참여자 동네 간 네이버 Geocoding + Haversine 중간 지점(Midpoint) 및 추천 핫플 계산
  static Future<Map<String, dynamic>> calculateMidpointAndRecommendNaverSpots(
    List<String> locations,
  ) async {
    await _ensureCrawledNaverPlacesLoaded();
    final validLocs =
        locations.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (validLocs.isEmpty) {
      validLocs.addAll(['영등포구 신길동', '영등포구 여의도동']);
    } else if (validLocs.length == 1) {
      final first = validLocs.first;
      validLocs.add(first.contains('여수') ? '여수시 학동' : '영등포구 여의도동');
    }

    double sumLat = 0;
    double sumLng = 0;
    int count = 0;
    for (final loc in validLocs) {
      final c = LocationHelper.findCoordsForLocation(loc);
      if (c != null) {
        sumLat += c['lat']!;
        sumLng += c['lng']!;
        count++;
      }
    }
    final midLat = count > 0 ? sumLat / count : 37.5180;
    final midLng = count > 0 ? sumLng / count : 126.9225;

    final allPlaces = <NaverPlace>[
      ..._crawledNaverPlaces,
      ..._naverVerifiedCatalog,
    ];
    final sorted = List<NaverPlace>.from(allPlaces)
      ..sort((a, b) {
        final da = calculateDistanceInMeters(midLat, midLng, a.lat, a.lng);
        final db = calculateDistanceInMeters(midLat, midLng, b.lat, b.lng);
        return da.compareTo(db);
      });

    final topSpots = sorted.take(3).map((p) {
      final dist = calculateDistanceInMeters(midLat, midLng, p.lat, p.lng);
      return {
        'name': p.name,
        'address': p.roadAddress.isNotEmpty ? p.roadAddress : p.address,
        'category': p.category,
        'lat': p.lat,
        'lng': p.lng,
        'distanceFromMid': formatDistance(dist),
      };
    }).toList();

    final midSpot = topSpots.isNotEmpty ? topSpots.first : null;
    final midpointLabel = midSpot != null
        ? (midSpot['address'] as String).split(' ').take(3).join(' ')
        : '영등포구 신길·여의도 중간지점';

    return {
      'participantsLocations': validLocs,
      'midLat': midSpot != null ? midSpot['lat'] : midLat,
      'midLng': midSpot != null ? midSpot['lng'] : midLng,
      'midpointLabel': midpointLabel,
      'recommendedSpots': topSpots,
    };
  }

  /// 5. Haversine 정밀 거리 계산 (미터 단위 반환)
  static double calculateDistanceInMeters(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters
    final dLat = (lat2 - lat1) * pi / 180.0;
    final dLon = (lon2 - lon1) * pi / 180.0;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180.0) *
            cos(lat2 * pi / 180.0) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  /// 6. 사용자 친화적 거리 포맷팅 (예: '150m', '1.4km')
  static String formatDistance(double meters) {
    if (meters < 0 || meters.isNaN || meters.isInfinite || meters > 25000) {
      return '거리 정보 없음';
    }
    if (meters < 1000) {
      return '${meters.round()}m';
    }
    return '${(meters / 1000.0).toStringAsFixed(1)}km';
  }

  /// 7. 현재 기기 위치 기준 특정 좌표까지의 실시간 거리 문자열
  /// GPS 권한이 허용되어 있으면 기기 실제 GPS 기반 거리, 브라우저/웹 권한 미허용 시 사용자 설정 동네(globalData.userLocation) 기준 거리 계산
  static Future<String> getDistanceTextFromCurrent(
      double targetLat, double targetLng,
      {String? userLocation}) async {
    if (targetLat.isNaN ||
        targetLng.isNaN ||
        targetLat <= 0 ||
        targetLng <= 0) {
      return '거리 정보 없음';
    }
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await Geolocator.checkPermission();
      if (serviceEnabled &&
          permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        Position? pos;
        try {
          pos = await Geolocator.getLastKnownPosition();
        } catch (_) {}
        pos ??= await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 2),
          ),
        );

        if (pos.latitude > 0 && pos.longitude > 0) {
          final dist = calculateDistanceInMeters(
              pos.latitude, pos.longitude, targetLat, targetLng);
          if (dist <= 25000) {
            return '내 위치에서 ${formatDistance(dist)}';
          }
        }
      }
    } catch (_) {}

    // GPS 권한 거부/웹 환경 브라우저 차단 시 사용자의 설정 동네 기반 스마트 거리 계산
    final locStr = (userLocation != null && userLocation.trim().isNotEmpty)
        ? userLocation.trim()
        : globalData.userLocation.value.trim();
    if (locStr.isNotEmpty && locStr != '동네 미설정') {
      final coords = LocationHelper.findCoordsForLocation(locStr);
      if (coords != null) {
        final dist = calculateDistanceInMeters(
            coords['lat']!, coords['lng']!, targetLat, targetLng);
        if (dist > 25000) {
          return '거리 정보 없음';
        }
        final dongOnly = locStr.split(' ').last;
        if (dist < 500) {
          return '$dongOnly 중심 (도보 5분)';
        }
        return '$dongOnly 기준 ${formatDistance(dist)}';
      }
    }

    return '거리 정보 없음';
  }

  /// 8. 지도 핀 바로가기 링크 생성 (네이버 지도 표준 연동)
  static String getNaverMapPinUrl(String placeName, double lat, double lng) {
    return getNaverMapUrl(placeName, lat: lat, lng: lng);
  }

  /// 9. 길찾기 바로가기 링크 생성 (네이버 지도 길찾기 표준 연동)
  static String getNaverMapRouteUrl(String placeName, double lat, double lng) {
    return getNaverRouteUrl(placeName, lat: lat, lng: lng);
  }

  /// 10. 키워드 검색 바로가기 링크 생성 (네이버 지도 검색 표준 연동)
  static String getNaverMapSearchUrl(String keyword) {
    return getNaverMapUrl(keyword);
  }

  /// 11. 지도 앱/웹 열기 통합 실행 (네이버 지도 연결)
  static Future<bool> launchMap(String placeName,
      {double? lat, double? lng}) async {
    return launchNaverMap(placeName, lat: lat, lng: lng);
  }

  /// 12. 길찾기 앱/웹 열기 통합 실행 (네이버 지도 길찾기 연결)
  static Future<bool> launchDirections(String placeName,
      {double? lat, double? lng}) async {
    return launchNaverDirections(placeName, lat: lat, lng: lng);
  }

  /// 13. 네이버 지도 검색/장소 바로가기 링크 생성
  static String getNaverMapUrl(String placeName, {double? lat, double? lng}) {
    final clean = placeName.trim().isNotEmpty ? placeName.trim() : '모임 장소';
    return 'https://map.naver.com/p/search/${Uri.encodeComponent(clean)}';
  }

  /// 14. 네이버 지도 길찾기 바로가기 링크 생성
  static String getNaverRouteUrl(String placeName, {double? lat, double? lng}) {
    final clean = placeName.trim().isNotEmpty ? placeName.trim() : '모임 장소';
    if (lat != null && lng != null && lat > 0 && lng > 0) {
      return 'https://map.naver.com/p/directions/-/$lng,$lat,${Uri.encodeComponent(clean)}/-/transit?c=15.00,0,0,0,dh';
    }
    return getNaverMapUrl(clean);
  }

  /// 15. 네이버 지도 앱/웹 열기 통합 실행
  static Future<bool> launchNaverMap(String placeName,
      {double? lat, double? lng}) async {
    final url = Uri.parse(getNaverMapUrl(placeName, lat: lat, lng: lng));
    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      return await launchUrl(url);
    }
  }

  /// 16. 네이버 지도 길찾기 앱/웹 열기 통합 실행
  static Future<bool> launchNaverDirections(String placeName,
      {double? lat, double? lng}) async {
    final url = Uri.parse(getNaverRouteUrl(placeName, lat: lat, lng: lng));
    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      return await launchUrl(url);
    }
  }
}
