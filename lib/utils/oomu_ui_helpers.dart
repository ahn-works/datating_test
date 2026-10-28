import 'package:flutter/material.dart';

/// OOMU 공통 UI/데이터 정규화 헬퍼 및 테마 토큰 (docs/OOMU_UI_GUIDE.md 단일 기준)
class OomuUiHelpers {
  OomuUiHelpers._();

  // 1. 핵심 컬러 토큰
  static const Color brandCoral = Color(0xFFF25767);
  static const Color brandCoralSoft = Color(0xFFFFF0F2);
  static const Color brandCoralBorder = Color(0xFFF8C6CD);
  static const Color brandCoralText = Color(0xFFC83243);

  static const Color backgroundNeutral = Color(0xFFFAF6F7);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF3EAEB);
  static const Color borderSubtle = Color(0xFFEFE4E6);
  static const Color borderNeutral = Color(0xFFE7E9ED);

  static const Color textPrimary = Color(0xFF221B1D);
  static const Color textSecondary = Color(0xFF635559);
  static const Color textMuted = Color(0xFF8E8285);

  static const Color safeTeal = Color(0xFF0D9488);
  static const Color safeTealBg = Color(0xFFE6F7F5);

  static const List<String> koreanFontFallback = [
    'Pretendard',
    'Malgun Gothic',
    'Apple SD Gothic Neo',
    'Noto Sans KR',
    'sans-serif',
  ];

  /// 2. 제목 문자열 정규화 (서로게이트 페어 및 ZWJ 조합 이모지 100% 보존)
  /// 기존 UTF-16 단위 `split('').join('\u2060')`를 사용하지 않고 원문을 보존하며,
  /// 이전에 삽입된 `\u2060`(Word Joiner)이 있으면 제거하여 깨진 이모지를 복원합니다.
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
  /// 값이 없을 때 임의의 하드코딩 기본값(36.5, 41.2, 37.0)을 생성하지 않고 null을 반환합니다.
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

  /// 6. 매너온도 구간별 일관된 텍스트/강조 색상
  static Color mannerTempColor(double? temp) {
    if (temp == null) return textSecondary;
    if (temp < 36.5) return const Color(0xFF64748B);
    if (temp < 40.0) return safeTeal;
    if (temp < 50.0) return const Color(0xFFB45309);
    return brandCoralText;
  }

  /// 7. 매너온도 구간별 배지 배경 색상
  static Color mannerTempBgColor(double? temp) {
    if (temp == null) return surfaceMuted;
    if (temp < 36.5) return const Color(0xFFF1F5F9);
    if (temp < 40.0) return safeTealBg;
    if (temp < 50.0) return const Color(0xFFFFFBEB);
    return brandCoralSoft;
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
        if (diff <= 0) return '마감 임박';
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
    // 대한민국 및 인접 유효 위경도 범위 점검 (위도 30~45, 경도 120~135)
    if (lat < 30.0 || lat > 45.0 || lng < 120.0 || lng > 135.0) return null;
    return (lat: lat, lng: lng);
  }

  /// 11. OOMU 공통 ThemeData 생성 (시스템 폰트 폴백 적용)
  static ThemeData buildTheme() {
    const baseTextStyle = TextStyle(
      fontFamilyFallback: koreanFontFallback,
      color: textPrimary,
    );
    return ThemeData(
      primaryColor: brandCoral,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandCoral,
        primary: brandCoral,
        secondary: safeTeal,
        surface: backgroundNeutral,
      ),
      scaffoldBackgroundColor: backgroundNeutral,
      cardColor: surfaceCard,
      dividerColor: borderSubtle,
      textTheme: TextTheme(
        headlineMedium: baseTextStyle.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          height: 1.32,
          letterSpacing: -0.4,
        ),
        titleLarge: baseTextStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          height: 1.35,
          letterSpacing: -0.3,
        ),
        titleMedium: baseTextStyle.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.35,
          letterSpacing: -0.2,
        ),
        bodyLarge: baseTextStyle.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 1.55,
        ),
        bodyMedium: baseTextStyle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        labelMedium: baseTextStyle.copyWith(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
      ),
    );
  }
}

