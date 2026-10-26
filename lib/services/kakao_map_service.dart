import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// 카카오맵 장소 데이터 모델
class KakaoPlace {
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

  const KakaoPlace({
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

  factory KakaoPlace.fromKakaoJson(Map<String, dynamic> json) {
    final road = json['road_address_name']?.toString() ?? '';
    final jibun = json['address_name']?.toString() ?? '';
    return KakaoPlace(
      id: json['id']?.toString() ?? '',
      name: json['place_name']?.toString() ?? '',
      address: jibun.isNotEmpty ? jibun : road,
      roadAddress: road.isNotEmpty ? road : jibun,
      category: json['category_group_name']?.toString().isNotEmpty == true
          ? json['category_group_name'].toString()
          : (json['category_name']?.toString().split('>').last.trim() ?? '모임장소'),
      lat: double.tryParse(json['y']?.toString() ?? '37.5665') ?? 37.5665,
      lng: double.tryParse(json['x']?.toString() ?? '126.9780') ?? 126.9780,
      placeUrl: json['place_url']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      distance: json['distance']?.toString() ?? '',
    );
  }
}

/// 카카오맵 & 카카오 로컬 REST API 통합 서비스 (Single Source of Truth)
class KakaoMapService {
  /// 카카오 공식 REST API 키 (일일 300,000회 무료 호출)
  /// 카카오 공식 REST API 키 (일 300,000회 무료 호출)
  static const String kakaoRestApiKey = '3f91399ac9b6731d96f6d4b9ac13c502';

  /// 카카오 공식 JavaScript 키 (웹/인앱 지도 렌더링용)
  static const String kakaoJsApiKey = '277e860aee05a0dd1504f70ce7ac8e74';

  /// 카카오 공식 어드민 키
  static const String kakaoAdminKey = '831cb7442067257f17f9a5111a281ce5';

  static Map<String, String> get _authHeaders => {
    'Authorization': 'KakaoAK $kakaoRestApiKey',
    'User-Agent': 'OOMUSpotApp/1.0 (Android; iOS; Web)',
  };

  /// 1. 카카오 키워드 장소 검색 API (dapi.kakao.com/v2/local/search/keyword.json)
  static Future<List<KakaoPlace>> searchKeyword(
    String query, {
    double? lat,
    double? lng,
    int? radius,
    int size = 15,
  }) async {
    final clean = query.trim();
    if (clean.isEmpty) return [];

    try {
      String url = 'https://dapi.kakao.com/v2/local/search/keyword.json?query=${Uri.encodeComponent(clean)}&size=$size';
      if (lat != null && lng != null) {
        url += '&x=$lng&y=$lat';
        if (radius != null) {
          url += '&radius=$radius&sort=distance';
        }
      }

      final res = await http.get(Uri.parse(url), headers: _authHeaders).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = json.decode(utf8.decode(res.bodyBytes));
        final docs = data['documents'] as List<dynamic>? ?? [];
        return docs.map((doc) => KakaoPlace.fromKakaoJson(doc as Map<String, dynamic>)).toList();
      } else {
        debugPrint('[KakaoMapService] searchKeyword error ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      debugPrint('[KakaoMapService] searchKeyword exception: $e');
    }
    return [];
  }

  /// 2. 카카오 주소 검색 API (dapi.kakao.com/v2/local/search/address.json)
  static Future<List<KakaoPlace>> searchAddress(String address, {int size = 10}) async {
    final clean = address.trim();
    if (clean.isEmpty) return [];

    try {
      final url = 'https://dapi.kakao.com/v2/local/search/address.json?query=${Uri.encodeComponent(clean)}&size=$size';
      final res = await http.get(Uri.parse(url), headers: _authHeaders).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = json.decode(utf8.decode(res.bodyBytes));
        final docs = data['documents'] as List<dynamic>? ?? [];
        return docs.map((doc) {
          final m = doc as Map<String, dynamic>;
          final road = m['road_address'] as Map<String, dynamic>?;
          final jibun = m['address'] as Map<String, dynamic>?;
          final roadName = road != null ? (road['address_name']?.toString() ?? '') : '';
          final jibunName = jibun != null ? (jibun['address_name']?.toString() ?? '') : (m['address_name']?.toString() ?? '');
          return KakaoPlace(
            id: m['id']?.toString() ?? clean.hashCode.toString(),
            name: roadName.isNotEmpty ? roadName : jibunName,
            address: jibunName,
            roadAddress: roadName.isNotEmpty ? roadName : jibunName,
            category: '주소',
            lat: double.tryParse(m['y']?.toString() ?? '37.5665') ?? 37.5665,
            lng: double.tryParse(m['x']?.toString() ?? '126.9780') ?? 126.9780,
            placeUrl: 'https://map.kakao.com/link/search/${Uri.encodeComponent(clean)}',
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('[KakaoMapService] searchAddress exception: $e');
    }
    return [];
  }

  /// 3. 카카오 역지오코딩 - 좌표 -> 읍·면·동 행정동/법정동 이름 (coord2regioncode.json)
  static Future<String?> coordToRegionName(double lat, double lng) async {
    try {
      final url = 'https://dapi.kakao.com/v2/local/geo/coord2regioncode.json?x=$lng&y=$lat';
      final res = await http.get(Uri.parse(url), headers: _authHeaders).timeout(const Duration(milliseconds: 2500));
      if (res.statusCode == 200) {
        final data = json.decode(utf8.decode(res.bodyBytes));
        final docs = data['documents'] as List<dynamic>? ?? [];
        // 행정동('H') 우선, 없으면 법정동('B')
        Map<String, dynamic>? targetDoc;
        for (final doc in docs) {
          final m = doc as Map<String, dynamic>;
          if (m['region_type'] == 'H') {
            targetDoc = m;
            break;
          }
        }
        targetDoc ??= docs.isNotEmpty ? (docs.first as Map<String, dynamic>) : null;

        if (targetDoc != null) {
          final region2 = targetDoc['region_2depth_name']?.toString() ?? '';
          final region3 = targetDoc['region_3depth_name']?.toString() ?? '';
          if (region2.isNotEmpty && region3.isNotEmpty) {
            return '$region2 $region3';
          }
          final full = targetDoc['address_name']?.toString() ?? '';
          if (full.isNotEmpty) {
            final parts = full.split(' ');
            if (parts.length >= 2) {
              return parts.skip(1).join(' ');
            }
            return full;
          }
        }
      }
    } catch (e) {
      debugPrint('[KakaoMapService] coordToRegionName exception: $e');
    }
    return null;
  }

  /// 4. 카카오 역지오코딩 - 좌표 -> 상세 도로명/지번 주소 (coord2address.json)
  static Future<String?> coordToRoadAddress(double lat, double lng) async {
    try {
      final url = 'https://dapi.kakao.com/v2/local/geo/coord2address.json?x=$lng&y=$lat';
      final res = await http.get(Uri.parse(url), headers: _authHeaders).timeout(const Duration(milliseconds: 2500));
      if (res.statusCode == 200) {
        final data = json.decode(utf8.decode(res.bodyBytes));
        final docs = data['documents'] as List<dynamic>? ?? [];
        if (docs.isNotEmpty) {
          final m = docs.first as Map<String, dynamic>;
          final road = m['road_address'] as Map<String, dynamic>?;
          if (road != null && road['address_name']?.toString().isNotEmpty == true) {
            return road['address_name'].toString();
          }
          final jibun = m['address'] as Map<String, dynamic>?;
          if (jibun != null && jibun['address_name']?.toString().isNotEmpty == true) {
            return jibun['address_name'].toString();
          }
        }
      }
    } catch (e) {
      debugPrint('[KakaoMapService] coordToRoadAddress exception: $e');
    }
    return null;
  }

  /// 5. Haversine 정밀 거리 계산 (미터 단위 반환)
  static double calculateDistanceInMeters(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters
    final dLat = (lat2 - lat1) * pi / 180.0;
    final dLon = (lon2 - lon1) * pi / 180.0;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180.0) * cos(lat2 * pi / 180.0) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  /// 6. 사용자 친화적 거리 포맷팅 (예: '150m', '1.4km')
  static String formatDistance(double meters) {
    if (meters < 0) return '거리 계산 불가';
    if (meters < 1000) {
      return '${meters.round()}m';
    }
    return '${(meters / 1000.0).toStringAsFixed(1)}km';
  }

  /// 7. 현재 기기 위치 기준 특정 좌표까지의 실시간 거리 문자열 (예: '내 위치에서 350m')
  static Future<String> getDistanceTextFromCurrent(double targetLat, double targetLng) async {
    try {
      Position? pos;
      try {
        pos = await Geolocator.getLastKnownPosition();
      } catch (_) {}
      pos ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 1),
      ).catchError((_) => Position(
            latitude: 37.5568,
            longitude: 126.9238,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          ));

      final dist = calculateDistanceInMeters(pos.latitude, pos.longitude, targetLat, targetLng);
      return '내 위치에서 ${formatDistance(dist)}';
    } catch (_) {
      return '내 위치 기준 거리 확인';
    }
  }

  /// 8. 카카오맵 지도 핀 바로가기 링크 생성
  static String getKakaoMapPinUrl(String placeName, double lat, double lng) {
    final clean = placeName.trim().isNotEmpty ? placeName.trim() : '약속장소';
    return 'https://map.kakao.com/link/map/${Uri.encodeComponent(clean)},$lat,$lng';
  }

  /// 9. 카카오맵 길찾기 바로가기 링크 생성
  static String getKakaoRouteUrl(String placeName, double lat, double lng) {
    final clean = placeName.trim().isNotEmpty ? placeName.trim() : '약속장소';
    return 'https://map.kakao.com/link/to/${Uri.encodeComponent(clean)},$lat,$lng';
  }

  /// 10. 카카오맵 키워드 검색 바로가기 링크 생성
  static String getKakaoSearchUrl(String keyword) {
    return 'https://map.kakao.com/link/search/${Uri.encodeComponent(keyword.trim())}';
  }

  /// 11. 카카오맵 앱/웹 열기 통합 실행
  static Future<bool> launchMap(String placeName, {double? lat, double? lng}) async {
    final Uri url;
    if (lat != null && lng != null && lat > 0 && lng > 0) {
      url = Uri.parse(getKakaoMapPinUrl(placeName, lat, lng));
    } else {
      url = Uri.parse(getKakaoSearchUrl(placeName));
    }

    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      return await launchUrl(url);
    }
  }

  /// 12. 카카오맵 길찾기 앱/웹 열기 통합 실행
  static Future<bool> launchDirections(String placeName, {double? lat, double? lng}) async {
    final Uri url;
    if (lat != null && lng != null && lat > 0 && lng > 0) {
      url = Uri.parse(getKakaoRouteUrl(placeName, lat, lng));
    } else {
      url = Uri.parse(getKakaoSearchUrl(placeName));
    }

    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      return await launchUrl(url);
    }
  }
}
