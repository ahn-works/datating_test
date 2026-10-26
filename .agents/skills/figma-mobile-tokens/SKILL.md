---
name: figma-mobile-tokens
description: 피그마(Figma) 디자인 시스템 토큰을 Flutter 네이티브 ThemeData 및 확장 클래스로 매핑하는 표준 가이드. 선셋 코랄 팔레트, 8dp 그리드 스페이싱, Pretendard 타이포그래피 스케일을 동기화합니다.
license: MIT
---

# 피그마 디자인 토큰 ↔ Flutter 동기화 가이드

본 스킬은 피그마에서 정의된 스타일 변수(Color, Typography, Spacing, Radius)를 Flutter 코드로 오차 없이 1:1 매핑하여 디자이너와 개발자 간의 간극을 제로로 만듭니다.

## 1. 상용화 및 라이선스 (Commercial Viability)
- **라이선스**: MIT License (상업적 이용 및 자체 지식재산권 확보)

## 2. OOMU 공식 모바일 디자인 토큰 클래스 (Design Tokens)

```dart
class OomuTokens {
  // 1. Color Tokens
  static const Color primary = Color(0xFFFF6B4A);       // 선셋 코랄
  static const Color primaryLight = Color(0xFFFFF4EB);  // 코랄 파스텔 틴트
  static const Color secondary = Color(0xFF0F172A);     // 트러스트 네이비
  static const Color background = Color(0xFFFAF6F7);    // 오트밀 로즈 크림
  static const Color surface = Color(0xFFFFFFFF);       // 순백 카드 표면
  static const Color textMain = Color(0xFF0F172A);      // 본문 메인 텍스트
  static const Color textSub = Color(0xFF64748B);       // 서브 라벨 / 날짜
  static const Color border = Color(0xFFE2E8F0);        // 1px 정밀 보더
  static const Color verified = Color(0xFF10B981);      // 세이지 에메랄드 인증

  // 2. 8dp Grid Spacing Tokens
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  // 3. Border Radius Tokens
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 14.0;
  static const double radiusLarge = 20.0;
  static const double radiusPill = 999.0;

  // 4. Mobile Touch Target
  static const double minTouchTarget = 48.0;
}
```

## 3. 타이포그래피 스케일 (Pretendard TextTheme)
- **Display**: 22sp / Bold / Height 1.3 / LetterSpacing -0.5
- **Heading**: 18sp / Bold / Height 1.3 / LetterSpacing -0.3
- **Subheading**: 15sp / SemiBold / Height 1.4 / LetterSpacing -0.2
- **Body**: 14sp / Regular / Height 1.5 / LetterSpacing 0.0
- **Caption**: 12sp / Medium / Height 1.4 / LetterSpacing 0.0
- **규칙**: 한글 어색한 단어 잘림 방지를 위해 `wordBreak: WordBreak.keepAll`을 전체 텍스트 스타일에 전역 적용합니다.
