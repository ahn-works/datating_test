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
  // 실제 영업 장소 목록 (OpenStreetMap Nominatim 2026-11-27 조회 좌표). 예전 AI 생성 가상 가게 목록을 대체.
    NaverPlace(
      id: 'osm_real_01',
      name: '탐앤탐스',
      address: '서울 영등포구 신길동',
      roadAddress: '서울 영등포구 신길로62길',
      category: '카페·디저트',
      lat: 37.515171,
      lng: 126.91728,
      placeUrl: 'https://map.naver.com/p/search/%ED%83%90%EC%95%A4%ED%83%90%EC%8A%A4%20%EC%98%81%EB%93%B1%ED%8F%AC%EA%B5%AC%20%EC%8B%A0%EA%B8%B8%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_02',
      name: '라라에프앤비 요거트 온유(YOGURT ON YOU)',
      address: '서울 영등포구 신길동',
      roadAddress: '서울 영등포구 도신로53길 15',
      category: '카페·디저트',
      lat: 37.512268,
      lng: 126.915134,
      placeUrl: 'https://map.naver.com/p/search/%EB%9D%BC%EB%9D%BC%EC%97%90%ED%94%84%EC%95%A4%EB%B9%84%20%EC%9A%94%EA%B1%B0%ED%8A%B8%20%EC%98%A8%EC%9C%A0%28YOGURT%20ON%20YOU%29%20%EC%98%81%EB%93%B1%ED%8F%AC%EA%B5%AC%20%EC%8B%A0%EA%B8%B8%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_03',
      name: '한가네마늘보쌈',
      address: '서울 영등포구 신길동',
      roadAddress: '서울 영등포구 도신로 238',
      category: '음식점',
      lat: 37.512414,
      lng: 126.917606,
      placeUrl: 'https://map.naver.com/p/search/%ED%95%9C%EA%B0%80%EB%84%A4%EB%A7%88%EB%8A%98%EB%B3%B4%EC%8C%88%20%EC%98%81%EB%93%B1%ED%8F%AC%EA%B5%AC%20%EC%8B%A0%EA%B8%B8%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_04',
      name: '돼지게티',
      address: '서울 영등포구 신길동',
      roadAddress: '서울 영등포구 영등포로72길 16',
      category: '음식점',
      lat: 37.512738,
      lng: 126.918412,
      placeUrl: 'https://map.naver.com/p/search/%EB%8F%BC%EC%A7%80%EA%B2%8C%ED%8B%B0%20%EC%98%81%EB%93%B1%ED%8F%AC%EA%B5%AC%20%EC%8B%A0%EA%B8%B8%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_05',
      name: '신길마라탕',
      address: '서울 영등포구 신길동',
      roadAddress: '서울 영등포구 영등포로 357',
      category: '음식점',
      lat: 37.514741,
      lng: 126.918396,
      placeUrl: 'https://map.naver.com/p/search/%EC%8B%A0%EA%B8%B8%EB%A7%88%EB%9D%BC%ED%83%95%20%EC%98%81%EB%93%B1%ED%8F%AC%EA%B5%AC%20%EC%8B%A0%EA%B8%B8%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_06',
      name: '고향만두점',
      address: '서울 영등포구 신길동',
      roadAddress: '서울 영등포구 도신로48길 4',
      category: '음식점',
      lat: 37.510835,
      lng: 126.912874,
      placeUrl: 'https://map.naver.com/p/search/%EA%B3%A0%ED%96%A5%EB%A7%8C%EB%91%90%EC%A0%90%20%EC%98%81%EB%93%B1%ED%8F%AC%EA%B5%AC%20%EC%8B%A0%EA%B8%B8%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_07',
      name: '해례커피',
      address: '서울 영등포구 여의도',
      roadAddress: '서울 영등포구 여의대로 108',
      category: '카페·디저트',
      lat: 37.525636,
      lng: 126.929226,
      placeUrl: 'https://map.naver.com/p/search/%ED%95%B4%EB%A1%80%EC%BB%A4%ED%94%BC%20%EC%98%81%EB%93%B1%ED%8F%AC%EA%B5%AC%20%EC%97%AC%EC%9D%98%EB%8F%84',
    ),
    NaverPlace(
      id: 'osm_real_08',
      name: '호우섬',
      address: '서울 영등포구 여의도',
      roadAddress: '서울 영등포구 여의대로 108',
      category: '음식점',
      lat: 37.525982,
      lng: 126.927879,
      placeUrl: 'https://map.naver.com/p/search/%ED%98%B8%EC%9A%B0%EC%84%AC%20%EC%98%81%EB%93%B1%ED%8F%AC%EA%B5%AC%20%EC%97%AC%EC%9D%98%EB%8F%84',
    ),
    NaverPlace(
      id: 'osm_real_09',
      name: '삼씨오화',
      address: '서울 영등포구 여의도',
      roadAddress: '서울 영등포구 의사당대로 83',
      category: '음식점',
      lat: 37.523324,
      lng: 126.92351,
      placeUrl: 'https://map.naver.com/p/search/%EC%82%BC%EC%94%A8%EC%98%A4%ED%99%94%20%EC%98%81%EB%93%B1%ED%8F%AC%EA%B5%AC%20%EC%97%AC%EC%9D%98%EB%8F%84',
    ),
    NaverPlace(
      id: 'osm_real_10',
      name: '유어홈커피(YOURHOME COFFEE ROASTERS)',
      address: '서울 영등포구 문래동',
      roadAddress: '서울 영등포구 도림로133길 20',
      category: '카페·디저트',
      lat: 37.512794,
      lng: 126.893698,
      placeUrl: 'https://map.naver.com/p/search/%EC%9C%A0%EC%96%B4%ED%99%88%EC%BB%A4%ED%94%BC%28YOURHOME%20COFFEE%20ROASTERS%29%20%EC%98%81%EB%93%B1%ED%8F%AC%EA%B5%AC%20%EB%AC%B8%EB%9E%98%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_11',
      name: '스페셜티스튜디오',
      address: '서울 영등포구 문래동',
      roadAddress: '서울 영등포구 도림로139길 4',
      category: '카페·디저트',
      lat: 37.514483,
      lng: 126.893405,
      placeUrl: 'https://map.naver.com/p/search/%EC%8A%A4%ED%8E%98%EC%85%9C%ED%8B%B0%EC%8A%A4%ED%8A%9C%EB%94%94%EC%98%A4%20%EC%98%81%EB%93%B1%ED%8F%AC%EA%B5%AC%20%EB%AC%B8%EB%9E%98%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_12',
      name: 'LIDbar',
      address: '서울 영등포구 문래동',
      roadAddress: '서울 영등포구 도림로139길 12-1',
      category: '술집',
      lat: 37.513894,
      lng: 126.892767,
      placeUrl: 'https://map.naver.com/p/search/LIDbar%20%EC%98%81%EB%93%B1%ED%8F%AC%EA%B5%AC%20%EB%AC%B8%EB%9E%98%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_13',
      name: 'Café Moro',
      address: '서울 마포구 연남동',
      roadAddress: '서울 마포구 동교로38길',
      category: '카페·디저트',
      lat: 37.561925,
      lng: 126.925622,
      placeUrl: 'https://map.naver.com/p/search/Caf%C3%A9%20Moro%20%EB%A7%88%ED%8F%AC%EA%B5%AC%20%EC%97%B0%EB%82%A8%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_14',
      name: '라디오 시티',
      address: '서울 마포구 연남동',
      roadAddress: '서울 마포구 동교로32길 5',
      category: '음식점',
      lat: 37.560824,
      lng: 126.924642,
      placeUrl: 'https://map.naver.com/p/search/%EB%9D%BC%EB%94%94%EC%98%A4%20%EC%8B%9C%ED%8B%B0%20%EB%A7%88%ED%8F%AC%EA%B5%AC%20%EC%97%B0%EB%82%A8%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_15',
      name: '일본라멘무메이',
      address: '서울 마포구 연남동',
      roadAddress: '서울 마포구 동교로27길 12',
      category: '음식점',
      lat: 37.558876,
      lng: 126.922876,
      placeUrl: 'https://map.naver.com/p/search/%EC%9D%BC%EB%B3%B8%EB%9D%BC%EB%A9%98%EB%AC%B4%EB%A9%94%EC%9D%B4%20%EB%A7%88%ED%8F%AC%EA%B5%AC%20%EC%97%B0%EB%82%A8%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_16',
      name: '마콘도',
      address: '서울 마포구 연남동',
      roadAddress: '서울 마포구 홍익로6길 48',
      category: '음식점',
      lat: 37.556199,
      lng: 126.92424,
      placeUrl: 'https://map.naver.com/p/search/%EB%A7%88%EC%BD%98%EB%8F%84%20%EB%A7%88%ED%8F%AC%EA%B5%AC%20%EC%97%B0%EB%82%A8%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_17',
      name: 'Golden Crema',
      address: '서울 마포구 홍대',
      roadAddress: '서울 마포구 어울마당로 121',
      category: '카페·디저트',
      lat: 37.555529,
      lng: 126.923596,
      placeUrl: 'https://map.naver.com/p/search/Golden%20Crema%20%EB%A7%88%ED%8F%AC%EA%B5%AC%20%ED%99%8D%EB%8C%80',
    ),
    NaverPlace(
      id: 'osm_real_18',
      name: 'MALT&',
      address: '서울 마포구 홍대',
      roadAddress: '서울 마포구 어울마당로 146-1',
      category: '술집',
      lat: 37.556344,
      lng: 126.926243,
      placeUrl: 'https://map.naver.com/p/search/MALT%26%20%EB%A7%88%ED%8F%AC%EA%B5%AC%20%ED%99%8D%EB%8C%80',
    ),
    NaverPlace(
      id: 'osm_real_19',
      name: '뉴올재즈라운지',
      address: '서울 마포구 홍대',
      roadAddress: '서울 마포구 동교로23길 14',
      category: '술집',
      lat: 37.556792,
      lng: 126.920764,
      placeUrl: 'https://map.naver.com/p/search/%EB%89%B4%EC%98%AC%EC%9E%AC%EC%A6%88%EB%9D%BC%EC%9A%B4%EC%A7%80%20%EB%A7%88%ED%8F%AC%EA%B5%AC%20%ED%99%8D%EB%8C%80',
    ),
    NaverPlace(
      id: 'osm_real_20',
      name: '에포크',
      address: '서울 마포구 합정동',
      roadAddress: '서울 마포구 독막로 17-1',
      category: '카페·디저트',
      lat: 37.548719,
      lng: 126.915537,
      placeUrl: 'https://map.naver.com/p/search/%EC%97%90%ED%8F%AC%ED%81%AC%20%EB%A7%88%ED%8F%AC%EA%B5%AC%20%ED%95%A9%EC%A0%95%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_21',
      name: '우지커피 합정역점 500호점',
      address: '서울 마포구 합정동',
      roadAddress: '서울 마포구 독막로 11',
      category: '카페·디저트',
      lat: 37.548826,
      lng: 126.914836,
      placeUrl: 'https://map.naver.com/p/search/%EC%9A%B0%EC%A7%80%EC%BB%A4%ED%94%BC%20%ED%95%A9%EC%A0%95%EC%97%AD%EC%A0%90%20500%ED%98%B8%EC%A0%90%20%EB%A7%88%ED%8F%AC%EA%B5%AC%20%ED%95%A9%EC%A0%95%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_22',
      name: '투게더다이닝',
      address: '서울 마포구 합정동',
      roadAddress: '서울 마포구 양화진4길 17',
      category: '음식점',
      lat: 37.547342,
      lng: 126.911254,
      placeUrl: 'https://map.naver.com/p/search/%ED%88%AC%EA%B2%8C%EB%8D%94%EB%8B%A4%EC%9D%B4%EB%8B%9D%20%EB%A7%88%ED%8F%AC%EA%B5%AC%20%ED%95%A9%EC%A0%95%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_23',
      name: '구가네김밥',
      address: '서울 마포구 합정동',
      roadAddress: '서울 마포구 월드컵로3길 28',
      category: '음식점',
      lat: 37.550418,
      lng: 126.911161,
      placeUrl: 'https://map.naver.com/p/search/%EA%B5%AC%EA%B0%80%EB%84%A4%EA%B9%80%EB%B0%A5%20%EB%A7%88%ED%8F%AC%EA%B5%AC%20%ED%95%A9%EC%A0%95%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_24',
      name: '키싸',
      address: '서울 마포구 망원동',
      roadAddress: '서울 마포구 포은로5길 30',
      category: '카페·디저트',
      lat: 37.555358,
      lng: 126.90335,
      placeUrl: 'https://map.naver.com/p/search/%ED%82%A4%EC%8B%B8%20%EB%A7%88%ED%8F%AC%EA%B5%AC%20%EB%A7%9D%EC%9B%90%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_25',
      name: '바리아토(Variato)',
      address: '서울 마포구 망원동',
      roadAddress: '서울 마포구 동교로 16',
      category: '카페·디저트',
      lat: 37.551789,
      lng: 126.904463,
      placeUrl: 'https://map.naver.com/p/search/%EB%B0%94%EB%A6%AC%EC%95%84%ED%86%A0%28Variato%29%20%EB%A7%88%ED%8F%AC%EA%B5%AC%20%EB%A7%9D%EC%9B%90%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_26',
      name: '서울브루어리',
      address: '서울 성동구 성수동',
      roadAddress: '서울 성동구 연무장길 28-12',
      category: '술집',
      lat: 37.543003,
      lng: 127.052425,
      placeUrl: 'https://map.naver.com/p/search/%EC%84%9C%EC%9A%B8%EB%B8%8C%EB%A3%A8%EC%96%B4%EB%A6%AC%20%EC%84%B1%EB%8F%99%EA%B5%AC%20%EC%84%B1%EC%88%98%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_27',
      name: '대취',
      address: '서울 성동구 성수동',
      roadAddress: '서울 성동구 연무장7가길 2',
      category: '술집',
      lat: 37.543126,
      lng: 127.054642,
      placeUrl: 'https://map.naver.com/p/search/%EB%8C%80%EC%B7%A8%20%EC%84%B1%EB%8F%99%EA%B5%AC%20%EC%84%B1%EC%88%98%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_28',
      name: '더스토리지룸',
      address: '서울 성동구 성수동',
      roadAddress: '서울 성동구 연무장7길 8-1',
      category: '술집',
      lat: 37.543437,
      lng: 127.054687,
      placeUrl: 'https://map.naver.com/p/search/%EB%8D%94%EC%8A%A4%ED%86%A0%EB%A6%AC%EC%A7%80%EB%A3%B8%20%EC%84%B1%EB%8F%99%EA%B5%AC%20%EC%84%B1%EC%88%98%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_29',
      name: '커피나인 성수',
      address: '서울 성동구 성수동',
      roadAddress: '서울 성동구 아차산로7나길 18',
      category: '카페·디저트',
      lat: 37.547702,
      lng: 127.057464,
      placeUrl: 'https://map.naver.com/p/search/%EC%BB%A4%ED%94%BC%EB%82%98%EC%9D%B8%20%EC%84%B1%EC%88%98%20%EC%84%B1%EB%8F%99%EA%B5%AC%20%EC%84%B1%EC%88%98%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_30',
      name: '우리만선호프',
      address: '서울 중구 을지로',
      roadAddress: '서울 중구 충무로9길 14',
      category: '술집',
      lat: 37.566744,
      lng: 126.990741,
      placeUrl: 'https://map.naver.com/p/search/%EC%9A%B0%EB%A6%AC%EB%A7%8C%EC%84%A0%ED%98%B8%ED%94%84%20%EC%A4%91%EA%B5%AC%20%EC%9D%84%EC%A7%80%EB%A1%9C',
    ),
    NaverPlace(
      id: 'osm_real_31',
      name: '을지',
      address: '서울 중구 을지로',
      roadAddress: '서울 중구 충무로 41',
      category: '술집',
      lat: 37.565743,
      lng: 126.992502,
      placeUrl: 'https://map.naver.com/p/search/%EC%9D%84%EC%A7%80%20%EC%A4%91%EA%B5%AC%20%EC%9D%84%EC%A7%80%EB%A1%9C',
    ),
    NaverPlace(
      id: 'osm_real_32',
      name: '주주상회',
      address: '서울 중구 을지로',
      roadAddress: '서울 중구 충무로2길 35',
      category: '술집',
      lat: 37.562397,
      lng: 126.995425,
      placeUrl: 'https://map.naver.com/p/search/%EC%A3%BC%EC%A3%BC%EC%83%81%ED%9A%8C%20%EC%A4%91%EA%B5%AC%20%EC%9D%84%EC%A7%80%EB%A1%9C',
    ),
    NaverPlace(
      id: 'osm_real_33',
      name: '9988숯불구이',
      address: '서울 중구 을지로',
      roadAddress: '서울 중구 삼일대로12길 20',
      category: '음식점',
      lat: 37.566838,
      lng: 126.989044,
      placeUrl: 'https://map.naver.com/p/search/9988%EC%88%AF%EB%B6%88%EA%B5%AC%EC%9D%B4%20%EC%A4%91%EA%B5%AC%20%EC%9D%84%EC%A7%80%EB%A1%9C',
    ),
    NaverPlace(
      id: 'osm_real_34',
      name: '빵그읏',
      address: '전남 여수시 화장동',
      roadAddress: '전남 여수시 화산로',
      category: '카페·디저트',
      lat: 34.772276,
      lng: 127.642971,
      placeUrl: 'https://map.naver.com/p/search/%EB%B9%B5%EA%B7%B8%EC%9D%8F%20%EC%97%AC%EC%88%98%EC%8B%9C%20%ED%99%94%EC%9E%A5%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_35',
      name: '피그레',
      address: '전남 여수시 화장동',
      roadAddress: '전남 여수시 성산5길',
      category: '카페·디저트',
      lat: 34.773695,
      lng: 127.643943,
      placeUrl: 'https://map.naver.com/p/search/%ED%94%BC%EA%B7%B8%EB%A0%88%20%EC%97%AC%EC%88%98%EC%8B%9C%20%ED%99%94%EC%9E%A5%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_36',
      name: '소문',
      address: '전남 여수시 화장동',
      roadAddress: '전남 여수시 화산2길',
      category: '카페·디저트',
      lat: 34.773187,
      lng: 127.646353,
      placeUrl: 'https://map.naver.com/p/search/%EC%86%8C%EB%AC%B8%20%EC%97%AC%EC%88%98%EC%8B%9C%20%ED%99%94%EC%9E%A5%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_37',
      name: '십장생산꼼장어',
      address: '전남 여수시 화장동',
      roadAddress: '전남 여수시 성산5길',
      category: '음식점',
      lat: 34.774424,
      lng: 127.643473,
      placeUrl: 'https://map.naver.com/p/search/%EC%8B%AD%EC%9E%A5%EC%83%9D%EC%82%B0%EA%BC%BC%EC%9E%A5%EC%96%B4%20%EC%97%AC%EC%88%98%EC%8B%9C%20%ED%99%94%EC%9E%A5%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_38',
      name: '미스즈야',
      address: '전남 여수시 화장동',
      roadAddress: '전남 여수시 성산로',
      category: '음식점',
      lat: 34.776314,
      lng: 127.646134,
      placeUrl: 'https://map.naver.com/p/search/%EB%AF%B8%EC%8A%A4%EC%A6%88%EC%95%BC%20%EC%97%AC%EC%88%98%EC%8B%9C%20%ED%99%94%EC%9E%A5%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_39',
      name: '조선다방',
      address: '전남 여수시 학동',
      roadAddress: '전남 여수시 시청동1길',
      category: '카페·디저트',
      lat: 34.760044,
      lng: 127.664141,
      placeUrl: 'https://map.naver.com/p/search/%EC%A1%B0%EC%84%A0%EB%8B%A4%EB%B0%A9%20%EC%97%AC%EC%88%98%EC%8B%9C%20%ED%95%99%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_40',
      name: '대감게장',
      address: '전남 여수시 학동',
      roadAddress: '전남 여수시 시청서2길 51-8',
      category: '음식점',
      lat: 34.760323,
      lng: 127.660175,
      placeUrl: 'https://map.naver.com/p/search/%EB%8C%80%EA%B0%90%EA%B2%8C%EC%9E%A5%20%EC%97%AC%EC%88%98%EC%8B%9C%20%ED%95%99%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_41',
      name: '연화식당',
      address: '전남 여수시 학동',
      roadAddress: '전남 여수시 시청서4길 42',
      category: '음식점',
      lat: 34.758981,
      lng: 127.660154,
      placeUrl: 'https://map.naver.com/p/search/%EC%97%B0%ED%99%94%EC%8B%9D%EB%8B%B9%20%EC%97%AC%EC%88%98%EC%8B%9C%20%ED%95%99%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_42',
      name: '학동골목길',
      address: '전남 여수시 학동',
      roadAddress: '전남 여수시 도원로 262',
      category: '음식점',
      lat: 34.760679,
      lng: 127.659859,
      placeUrl: 'https://map.naver.com/p/search/%ED%95%99%EB%8F%99%EA%B3%A8%EB%AA%A9%EA%B8%B8%20%EC%97%AC%EC%88%98%EC%8B%9C%20%ED%95%99%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_43',
      name: '스타벅스 영등포신길점',
      address: '서울 영등포구 신길동',
      roadAddress: '서울 영등포구 신길로 137',
      category: '카페·디저트',
      lat: 37.504593,
      lng: 126.91003,
      placeUrl: 'https://map.naver.com/p/search/%EC%8A%A4%ED%83%80%EB%B2%85%EC%8A%A4%20%EC%98%81%EB%93%B1%ED%8F%AC%EC%8B%A0%EA%B8%B8%EC%A0%90%20%EC%98%81%EB%93%B1%ED%8F%AC%EA%B5%AC%20%EC%8B%A0%EA%B8%B8%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_44',
      name: '메낙골 근린공원',
      address: '서울 영등포구 신길동',
      roadAddress: '서울 영등포구 신길동',
      category: '공원',
      lat: 37.50755,
      lng: 126.91533,
      placeUrl: 'https://map.naver.com/p/search/%EB%A9%94%EB%82%99%EA%B3%A8%20%EA%B7%BC%EB%A6%B0%EA%B3%B5%EC%9B%90%20%EC%98%81%EB%93%B1%ED%8F%AC%EA%B5%AC%20%EC%8B%A0%EA%B8%B8%EB%8F%99',
    ),
    NaverPlace(
      id: 'osm_real_45',
      name: '수노래연습장',
      address: '서울 마포구 홍대',
      roadAddress: '서울 마포구 신촌로12길',
      category: '노래방',
      lat: 37.55557,
      lng: 126.93251,
      placeUrl: 'https://map.naver.com/p/search/%EC%88%98%EB%85%B8%EB%9E%98%EC%97%B0%EC%8A%B5%EC%9E%A5%20%EB%A7%88%ED%8F%AC%EA%B5%AC%20%ED%99%8D%EB%8C%80',
    ),
    NaverPlace(
      id: 'osm_real_46',
      name: '망원한강공원',
      address: '서울 마포구 망원동',
      roadAddress: '서울 마포구 망원동',
      category: '공원',
      lat: 37.55019,
      lng: 126.90216,
      placeUrl: 'https://map.naver.com/p/search/%EB%A7%9D%EC%9B%90%ED%95%9C%EA%B0%95%EA%B3%B5%EC%9B%90%20%EB%A7%88%ED%8F%AC%EA%B5%AC%20%EB%A7%9D%EC%9B%90%EB%8F%99',
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

    // 검색어 단어가 많이 겹칠수록 앞에 둔다. 단어 하나만 겹치는 결과(예: '여수')는
    // 더 많이 겹치는 결과가 있을 때 버려서 엉뚱한 장소가 잡히지 않게 한다.
    int score(NaverPlace p) {
      final hay =
          '${p.name} ${p.address} ${p.roadAddress} ${p.category}'.toLowerCase();
      return tokens.where((t) => hay.contains(t)).length;
    }

    final scored = <MapEntry<NaverPlace, int>>[
      for (final p in allPlaces)
        if (score(p) > 0) MapEntry(p, score(p)),
    ];
    if (scored.isEmpty) return [];
    final best = scored.map((e) => e.value).reduce(max);
    final minScore = tokens.length >= 2 && best >= 2 ? 2 : 1;
    final matched = scored.where((e) => e.value >= minScore).toList();

    matched.sort((a, b) {
      final byScore = b.value.compareTo(a.value);
      if (byScore != 0 || lat == null || lng == null) return byScore;
      final da = calculateDistanceInMeters(lat, lng, a.key.lat, a.key.lng);
      final db = calculateDistanceInMeters(lat, lng, b.key.lat, b.key.lng);
      return da.compareTo(db);
    });
    return matched.map((e) => e.key).take(size).toList();
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
