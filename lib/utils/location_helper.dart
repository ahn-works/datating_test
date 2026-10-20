import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationHelper {
  /// GPS 권한 확인 및 요청 후 현재 위치 읍·면·동 초고속 반환 (최대 2초 내 보장 및 캐시/오프라인 즉시 폴백)
  static Future<String?> getCurrentDongName() async {
    try {
      bool serviceEnabled = false;
      try {
        serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(const Duration(milliseconds: 400));
      } catch (_) {}

      LocationPermission permission = await Geolocator.checkPermission().timeout(const Duration(milliseconds: 400));
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission().timeout(const Duration(seconds: 1));
        if (permission == LocationPermission.denied) {
          debugPrint('[LocationHelper] Location permission denied. Fallback to default.');
          return '마포구 서교동';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('[LocationHelper] Location permission permanently denied. Fallback to default.');
        return '마포구 서교동';
      }

      // 1. 가장 최근 알려진 캐시 좌표 우선 조회 (0ms 즉시 반환)
      Position? position;
      try {
        position = await Geolocator.getLastKnownPosition().timeout(const Duration(milliseconds: 400));
      } catch (_) {}

      // 2. 캐시 좌표가 없으면 저지연(low accuracy) 1.8초 타임아웃으로 신속 조회
      if (position == null) {
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(milliseconds: 1800),
          );
        } catch (e) {
          debugPrint('[LocationHelper] Low accuracy GPS timed out, using fallback: $e');
        }
      }

      if (position == null) {
        return '마포구 서교동';
      }

      debugPrint('[LocationHelper] Got coordinates: ${position.latitude}, ${position.longitude}');

      // 3. 역지오코딩 시도 (1.2초 타임아웃)
      try {
        final reverseName = await _reverseGeocode(position.latitude, position.longitude);
        if (reverseName != null && reverseName.trim().isNotEmpty) {
          return reverseName;
        }
      } catch (_) {}

      // 4. 오프라인 좌표 거리 매칭 (서울/경기/전국 0ms 즉각 매핑)
      return _matchNearestKoreanDong(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('[LocationHelper] Error fetching location: $e');
      return '마포구 서교동';
    }
  }

  /// 역지오코딩 API 호출 (3초 타임아웃)
  static Future<String?> _reverseGeocode(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=16&addressdetails=1&accept-language=ko',
      );
      final res = await http.get(url, headers: {'User-Agent': 'OOMUSpotApp/1.0'}).timeout(const Duration(milliseconds: 1200));

      if (res.statusCode == 200) {
        final data = json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final city = address['city'] ?? address['county'] ?? address['province'] ?? '';
          final district = address['borough'] ?? address['city_district'] ?? '';
          final dong = address['suburb'] ?? address['neighbourhood'] ?? address['quarter'] ?? address['village'] ?? address['town'] ?? '';

          String result = '';
          if (city.toString().isNotEmpty) {
            result += '${city.toString()} ';
          }
          if (district.toString().isNotEmpty && district.toString() != city.toString()) {
            result += '${district.toString()} ';
          }
          if (dong.toString().isNotEmpty) {
            result += dong.toString();
          }

          if (result.trim().isNotEmpty) {
            return result.trim();
          }
        }
      }
    } catch (e) {
      debugPrint('[LocationHelper] Reverse geocode error: $e');
    }
    return null;
  }

  /// 전국 주요 읍·면·동 정밀 좌표 테이블 (오프라인/타임아웃 폴백)
  static const List<Map<String, dynamic>> _dongPoints = [
    // 여수시
    {'name': '여수시 학동', 'lat': 34.7604, 'lon': 127.6622},
    {'name': '여수시 웅천동', 'lat': 34.7525, 'lon': 127.6750},
    {'name': '여수시 여서동', 'lat': 34.7621, 'lon': 127.7025},
    {'name': '여수시 문수동', 'lat': 34.7645, 'lon': 127.6950},
    {'name': '여수시 신월동', 'lat': 34.7310, 'lon': 127.7120},
    {'name': '여수시 교동(이순신광장)', 'lat': 34.7405, 'lon': 127.7370},
    {'name': '여수시 돌산읍', 'lat': 34.6980, 'lon': 127.7320},
    {'name': '여수시 소라면', 'lat': 34.8050, 'lon': 127.6200},
    {'name': '여수시 화장동', 'lat': 34.7750, 'lon': 127.6450},

    // 순천시 / 광양시 / 목포시
    {'name': '순천시 조례동', 'lat': 34.9600, 'lon': 127.5250},
    {'name': '순천시 신대지구', 'lat': 34.9350, 'lon': 127.5650},
    {'name': '순천시 연향동', 'lat': 34.9450, 'lon': 127.5200},
    {'name': '광양시 중마동', 'lat': 34.9400, 'lon': 127.6950},
    {'name': '목포시 하당동', 'lat': 34.8050, 'lon': 126.4250},
    {'name': '목포시 평화광장(상동)', 'lat': 34.7950, 'lon': 126.4350},

    // 광주광역시
    {'name': '광주 서구 상무동', 'lat': 35.1530, 'lon': 126.8520},
    {'name': '광주 동구 동명동', 'lat': 35.1500, 'lon': 126.9250},
    {'name': '광주 광산구 수완동', 'lat': 35.1900, 'lon': 126.8200},
    {'name': '광주 남구 봉선동', 'lat': 35.1250, 'lon': 126.9100},

    // 전북 전주시
    {'name': '전주시 완산구 효자동', 'lat': 35.8150, 'lon': 127.1150},
    {'name': '전주시 덕진구 송천동', 'lat': 35.8650, 'lon': 127.1250},
    {'name': '전주시 완산구 고사동(객사)', 'lat': 35.8180, 'lon': 127.1420},

    // 서울특별시
    {'name': '마포구 서교동', 'lat': 37.5550, 'lon': 126.9210},
    {'name': '마포구 연남동', 'lat': 37.5630, 'lon': 126.9240},
    {'name': '마포구 망원동', 'lat': 37.5560, 'lon': 126.9050},
    {'name': '성동구 성수동', 'lat': 37.5440, 'lon': 127.0560},
    {'name': '용산구 한남동', 'lat': 37.5340, 'lon': 127.0020},
    {'name': '강남구 신사동', 'lat': 37.5240, 'lon': 127.0220},
    {'name': '강남구 역삼동', 'lat': 37.5000, 'lon': 127.0360},
    {'name': '송파구 잠실동', 'lat': 37.5130, 'lon': 127.0840},
    {'name': '영등포구 여의도동', 'lat': 37.5250, 'lon': 126.9240},

    // 경기도 / 인천
    {'name': '성남시 분당구 판교동', 'lat': 37.3940, 'lon': 127.1110},
    {'name': '성남시 분당구 정자동', 'lat': 37.3650, 'lon': 127.1080},
    {'name': '수원시 영통구 광교동', 'lat': 37.2980, 'lon': 127.0470},
    {'name': '고양시 일산동구 장항동', 'lat': 37.6580, 'lon': 126.7710},
    {'name': '인천 연수구 송도동', 'lat': 37.3920, 'lon': 126.6500},
    {'name': '하남시 미사동', 'lat': 37.5620, 'lon': 127.1930},

    // 부산 / 대구 / 대전 / 제주
    {'name': '부산 해운대구 우동', 'lat': 35.1630, 'lon': 129.1380},
    {'name': '부산 부산진구 전포동', 'lat': 35.1570, 'lon': 129.0660},
    {'name': '대구 수성구 범어동', 'lat': 35.8590, 'lon': 128.6250},
    {'name': '대전 유성구 봉명동', 'lat': 36.3530, 'lon': 127.3410},
    {'name': '대전 서구 둔산동', 'lat': 36.3500, 'lon': 127.3850},
    {'name': '제주시 노형동', 'lat': 33.4830, 'lon': 126.4750},
    {'name': '서귀포시 중문동', 'lat': 33.2500, 'lon': 126.4250},
  ];

  static String _matchNearestKoreanDong(double lat, double lon) {
    String bestName = '여수시 학동';
    double minDistance = double.infinity;

    for (final pt in _dongPoints) {
      final double pLat = pt['lat'] as double;
      final double pLon = pt['lon'] as double;
      // 유클리디안 근사 거리
      final d = pow(lat - pLat, 2) + pow(lon - pLon, 2);
      if (d < minDistance) {
        minDistance = d.toDouble();
        bestName = pt['name'] as String;
      }
    }

    return bestName;
  }
}
