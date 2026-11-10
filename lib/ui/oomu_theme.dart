import 'package:flutter/material.dart';

import 'oomu_tokens.dart';

/// OOMU 공통 ThemeData. 모든 값은 [OomuTokens]에서만 가져옵니다.
ThemeData buildOomuTheme() {
  TextStyle style(double size, FontWeight weight,
          {Color color = OomuTokens.textPrimary, double height = 1.4}) =>
      TextStyle(
        fontFamily: OomuTokens.fontFamily,
        fontFamilyFallback: OomuTokens.fontFallback,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
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
      titleTextStyle: style(OomuTokens.fs18, OomuTokens.w700),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: OomuTokens.surface,
      elevation: 0,
      selectedItemColor: OomuTokens.coral,
      unselectedItemColor: OomuTokens.textMuted,
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: const DividerThemeData(
      color: OomuTokens.border,
      thickness: 1,
      space: 1,
    ),
    textTheme: TextTheme(
      headlineMedium: style(OomuTokens.fs22, OomuTokens.w700, height: 1.35),
      titleLarge: style(OomuTokens.fs18, OomuTokens.w700),
      titleMedium: style(OomuTokens.fs16, OomuTokens.w600),
      bodyLarge: style(OomuTokens.fs16, OomuTokens.w400,
          color: OomuTokens.textBody, height: 1.5),
      bodyMedium: style(OomuTokens.fs14, OomuTokens.w400,
          color: OomuTokens.textBody, height: 1.5),
      bodySmall: style(OomuTokens.fs12, OomuTokens.w400,
          color: OomuTokens.textSecondary),
      labelMedium: style(OomuTokens.fs12, OomuTokens.w600,
          color: OomuTokens.textSecondary),
      labelSmall: style(OomuTokens.fs11, OomuTokens.w400,
          color: OomuTokens.textMuted),
    ),
  );
}
