import 'package:flutter/material.dart';

import '../ui/oomu_theme.dart';
import '../ui/oomu_tokens.dart';

/// OOMU 공통 UI/데이터 정규화 헬퍼 및 테마 토큰 (docs/OOMU_UI_GUIDE.md 60-30-10 단일 기준)
class OomuUiHelpers {
  OomuUiHelpers._();

  static String formatMeetupCost(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || text.contains('안심 정산') || text.contains('안심정산')) {
      return '비용 안내 확인 필요';
    }
    return text;
  }

  // 1. 핵심 컬러 토큰 (무채색 90% + 코랄 포인트 10% 원칙)
  static const Color brandCoral = OomuTokens.coral;
  static const Color brandCoralSoft = Color(0xFFFFF0F2);
  static const Color brandCoralBorder = Color(0xFFFCD3D9);
  static const Color brandCoralText = OomuTokens.coralText;

  static const Color backgroundNeutral = OomuTokens.background;
  static const Color surfaceCard = OomuTokens.surface;
  static const Color surfaceMuted = OomuTokens.surfaceMuted;
  static const Color borderSubtle = OomuTokens.border;
  static const Color borderNeutral = OomuTokens.border;

  static const Color textPrimary = OomuTokens.textPrimary;
  static const Color textBody = OomuTokens.textBody;
  static const Color textSecondary = OomuTokens.textSecondary;
  static const Color textMuted = OomuTokens.textMuted;

  static const Color safeTeal = OomuTokens.verified;
  static const Color safeTealBg = Color(0xFFF0FDFA);

  static const List<String> koreanFontFallback = OomuTokens.fontFallback;

  /// 2. 제목 문자열 정규화 (원문 데이터 및 서로게이트 페어·ZWJ·국기 이모지 100% 보존)
  static String formatTitle(String? title, {String fallback = '취향 모임'}) {
    if (title == null) return fallback;
    final cleaned = title.replaceAll('\u2060', '').trim();
    if (cleaned.isEmpty) return fallback;
    return cleaned;
  }

  /// 3. 단일 매너온도 값 파싱 (num 및 숫자 문자열 호환, 유효하지 않으면 null 반환)
  static double? parseMannerValue(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) {
      final val = raw.toDouble();
      if (val.isNaN || val.isInfinite || val <= 0) return null;
      return val;
    }
    if (raw is String) {
      final cleaned = raw
          .replaceAll('°C', '')
          .replaceAll('℃', '')
          .replaceAll('도', '')
          .trim();
      if (cleaned.isEmpty) return null;
      final parsed = double.tryParse(cleaned);
      if (parsed == null || parsed.isNaN || parsed.isInfinite || parsed <= 0) {
        return null;
      }
      return parsed;
    }
    return null;
  }

  /// 4. 모임/게시글 Map에서 호스트 매너온도 추출 (우선순위: `manner` -> `mannerTemp`)
  static double? parseMannerTemp(Map<String, dynamic>? data) {
    if (data == null) return null;
    return parseMannerValue(data['manner']) ??
        parseMannerValue(data['mannerTemp']);
  }

  /// 5. 매너온도 일관된 문자열 포맷팅
  static String formatMannerTemp(double? temp, {bool shortEmpty = true}) {
    if (temp == null) {
      return shortEmpty ? '정보 없음' : '매너온도 정보 없음';
    }
    return '${temp.toStringAsFixed(1)}°C';
  }

  /// 6. 매너온도 구간별 일관된 텍스트 색상 (원색 충돌 방지를 위해 차분한 슬레이트/틸 톤 유지)
  static Color mannerTempColor(double? temp) {
    if (temp == null) return textSecondary;
    if (temp < 36.5) return textSecondary;
    return textBody;
  }

  /// 7. 매너온도 구간별 배지 배경 색상 (우측 코랄 배지와 충돌하지 않는 중립 쿨그레이 칩)
  static Color mannerTempBgColor(double? temp) {
    return surfaceMuted;
  }

  /// 8. 매너온도 구간별 이모지
  static String mannerTempEmoji(double? temp) {
    if (temp == null) return '🌡️';
    if (temp < 36.5) return '🙂';
    if (temp < 40.0) return '😊';
    if (temp < 50.0) return '😄';
    return '🔥';
  }

  /// 9. 잔여석 계산 헬퍼 (null 안전 보장)
  static String calcRemainingSeats(dynamic memberValue, {String fallback = '잔여석 있음'}) {
    if (memberValue == null) return fallback;
    final memberStr = memberValue.toString().trim();
    if (memberStr.isEmpty) return fallback;
    try {
      final parts = memberStr.split('/');
      if (parts.length == 2) {
        final current = int.parse(parts[0].replaceAll(RegExp(r'[^0-9]'), ''));
        final total = int.parse(parts[1].replaceAll(RegExp(r'[^0-9]'), ''));
        final diff = total - current;
        if (diff <= 0) return '모집 마감';
        return '$diff자리 남음';
      }
    } catch (_) {}
    return fallback;
  }

  /// 10. 모임 데이터에 저장된 유효 좌표 추출 (유효하지 않거나 0이면 null)
  static ({double lat, double lng})? extractValidCoords(Map<String, dynamic>? data) {
    if (data == null) return null;
    final rawLat = data['lat'] ?? data['latitude'];
    final rawLng = data['lng'] ?? data['longitude'];
    final lat = rawLat is num
        ? rawLat.toDouble()
        : double.tryParse(rawLat?.toString() ?? '');
    final lng = rawLng is num
        ? rawLng.toDouble()
        : double.tryParse(rawLng?.toString() ?? '');
    if (lat == null || lng == null) return null;
    if (lat.isNaN || lng.isNaN || lat <= 0 || lng <= 0) return null;
    if (lat < 30.0 || lat > 45.0 || lng < 120.0 || lng > 135.0) return null;
    return (lat: lat, lng: lng);
  }

  /// 11. OOMU 공통 ThemeData (정의는 lib/ui/oomu_theme.dart 단일 원천)
  static ThemeData buildTheme() => buildOomuTheme();
}
