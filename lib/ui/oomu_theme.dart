import 'package:flutter/material.dart';

import 'oomu_tokens.dart';

/// OOMU 공통 ThemeData. 모든 값은 [OomuTokens]에서만 가져옵니다.
/// 방향: "따뜻한 미니멀" — 흰 바탕, 따뜻한 먹색 글자, 1px 헤어라인, 코랄은 포인트에만.
ThemeData buildOomuTheme() {
  TextStyle style(double size, FontWeight weight,
          {Color color = OomuTokens.textPrimary,
          double height = 1.4,
          double letterSpacing = 0}) =>
      TextStyle(
        fontFamily: OomuTokens.fontFamily,
        fontFamilyFallback: OomuTokens.fontFallback,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  final scheme = ColorScheme.fromSeed(
    seedColor: OomuTokens.coral,
    primary: OomuTokens.coral,
    secondary: OomuTokens.textPrimary,
    surface: OomuTokens.surface,
    error: OomuTokens.error,
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: OomuTokens.fontFamily,
    fontFamilyFallback: OomuTokens.fontFallback,
    primaryColor: OomuTokens.coral,
    colorScheme: scheme,
    scaffoldBackgroundColor: OomuTokens.background,
    cardColor: OomuTokens.surface,
    dividerColor: OomuTokens.border,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      backgroundColor: OomuTokens.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle:
          style(OomuTokens.fs20, OomuTokens.w700, letterSpacing: -0.4),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: OomuTokens.surface,
      elevation: 0,
      selectedItemColor: OomuTokens.textPrimary,
      unselectedItemColor: OomuTokens.textTertiary,
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: const DividerThemeData(
      color: OomuTokens.border,
      thickness: 1,
      space: 1,
    ),
    // 입력창은 화면마다 자체 decoration을 쓰므로 전역 채움/테두리는 강제하지 않고
    // 힌트 글자색만 통일합니다.
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: style(OomuTokens.fs15, OomuTokens.w400,
          color: OomuTokens.textTertiary, height: 1.4),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: OomuTokens.textPrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OomuTokens.radiusCardSm),
      ),
      contentTextStyle:
          style(OomuTokens.fs14, OomuTokens.w600, color: OomuTokens.surface),
    ),
    textTheme: TextTheme(
      // 24 · 화면 큰 제목
      headlineMedium: style(OomuTokens.fs24, OomuTokens.w700,
          height: 1.35, letterSpacing: -0.6),
      // 20 · 앱바 제목
      titleLarge: style(OomuTokens.fs20, OomuTokens.w700,
          letterSpacing: -0.4),
      // 17 · 카드 제목, 섹션 제목
      titleMedium: style(OomuTokens.fs17, OomuTokens.w600,
          height: 1.45, letterSpacing: -0.25),
      // 15 · 본문
      bodyLarge: style(OomuTokens.fs15, OomuTokens.w400,
          color: OomuTokens.textBody, height: 1.6, letterSpacing: -0.15),
      bodyMedium: style(OomuTokens.fs14, OomuTokens.w400,
          color: OomuTokens.textBody, height: 1.5, letterSpacing: -0.1),
      // 13 · 날짜·장소·인원 등 보조 정보
      bodySmall: style(OomuTokens.fs13, OomuTokens.w400,
          color: OomuTokens.textMuted, height: 1.5, letterSpacing: -0.05),
      labelMedium: style(OomuTokens.fs12, OomuTokens.w600,
          color: OomuTokens.textSecondary),
      // 11 · 탭바 라벨, 채팅 시간
      labelSmall: style(OomuTokens.fs11, OomuTokens.w600,
          color: OomuTokens.textMuted, height: 1.4),
    ),
  );
}
