import 'package:flutter/material.dart';

/// OOMU 디자인 토큰. 값의 기준은 docs/OOMU_DESIGN_SYSTEM.md 입니다.
/// 화면 파일은 Color(0x..)·fontSize 숫자·BorderRadius 숫자를 직접 쓰지 말고 이 클래스만 사용합니다.
class OomuTokens {
  OomuTokens._();

  // ── 색 ──
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF2F4F7);
  static const Color border = Color(0xFFEAECF0);

  static const Color textPrimary = Color(0xFF191F28);
  static const Color textBody = Color(0xFF333D4B);
  static const Color textSecondary = Color(0xFF6B7684);
  static const Color textMuted = Color(0xFF8B95A1);

  static const Color coral = Color(0xFFF25767);
  static const Color coralText = Color(0xFFD9384A);
  static const Color error = Color(0xFFE11D48);
  static const Color verified = Color(0xFF0D9488);

  // ── 의미론적 색상 별칭 (docs/OOMU_DESIGN_SYSTEM.md) ──
  static const Color primary = coral;
  static const Color primarySubtle = Color(0xFFFDE8EC);
  static const Color primaryBorder = Color(0xFFFFD8A8);
  static const Color bgCanvas = Color(0xFFF8FAFC);
  static const Color surfaceElevated = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color mannerYellowBg = Color(0xFFFFFBEB);
  static const Color mannerYellowBorder = Color(0xFFFDE68A);
  static const Color mannerYellowText = Color(0xFFB45309);
  static const Color warningRed = Color(0xFFE53935);

  // ── 소셜 브랜드 컬러 ──
  static const Color kakaoYellow = Color(0xFFFEE500);
  static const Color kakaoText = Color(0xFF191919);
  static const Color naverGreen = Color(0xFF03C75A);
  static const Color googleText = Color(0xFF3C3C3C);
  static const Color googleRed = Color(0xFFEA4335);
  static const Color googleYellow = Color(0xFFFBBC05);
  static const Color googleGreen = Color(0xFF34A853);
  static const Color googleBlue = Color(0xFF4285F4);

  // ── 글자 ──
  static const String fontFamily = 'Pretendard';
  static const List<String> fontFallback = [
    'Pretendard',
    'Malgun Gothic',
    'Apple SD Gothic Neo',
    'Noto Sans KR',
    'sans-serif',
  ];

  static const double fs11 = 11;
  static const double fs12 = 12;
  static const double fs13 = 13;
  static const double fs14 = 14;
  static const double fs15 = 15;
  static const double fs16 = 16;
  static const double fs17 = 17;
  static const double fs18 = 18;
  static const double fs20 = 20;
  static const double fs22 = 22;
  static const double fs24 = 24;
  static const double fs26 = 26;
  static const double fsSplash = 28;
  static const double fs32 = 32;
  static const double fs36 = 36;

  static const FontWeight w400 = FontWeight.w400;
  static const FontWeight w600 = FontWeight.w600;
  static const FontWeight w700 = FontWeight.w700;

  // ── 모서리 ──
  static const double r2 = 2;
  static const double r3 = 3;
  static const double r4 = 4;
  static const double r6 = 6;
  static const double r8 = 8;
  static const double r9 = 9;
  static const double r10 = 10;
  static const double r12 = 12;
  static const double r14 = 14;
  static const double r16 = 16;
  static const double r18 = 18;
  static const double r20 = 20;
  static const double r22 = 22;
  static const double r24 = 24;
  static const double r28 = 28;
  static const double rPill = 999;

  // ── 간격 ──
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;

  static const double pagePadding = s20;
  static const double cardPadding = s16;
  static const double cardGap = s12;
  static const double sectionGap = s32;

  // ── 크기 ──
  static const double touchTarget = 48;
  static const double buttonHeight = 52;
  static const double buttonHeightSmall = 48;
  static const double inputHeight = 52;
  static const double appFrameMaxWidth = 480;

  // ── 의미론적 별칭 (Semantic Aliases) ──
  static const double spacingXs = s4;
  static const double spacingSm = s8;
  static const double spacingMd = s16;
  static const double spacingLg = s20;
  static const double spacingXl = s24;
  static const double spacingXxl = s32;

  static const double fontXs = fs12;
  static const double fontSm = fs14;
  static const double fontBase = fs16;
  static const double fontLg = fs18;
  static const double fontXl = fs22;

  static const FontWeight weightRegular = w400;
  static const FontWeight weightSemiBold = w600;
  static const FontWeight weightBold = w700;

  static const double radiusCardSm = r12;
  static const double radiusCard = r16;
  static const double radiusCardLg = r24;
  static const double radiusPill = rPill;

  static const double touchTargetMin = touchTarget;
}

