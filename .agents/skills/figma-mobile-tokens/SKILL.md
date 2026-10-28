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
  // 1. Color Tokens (docs/OOMU_UI_GUIDE.md 단일 기준)
  static const Color primary = Color(0xFFF25767);       // 코랄 로즈
  static const Color primaryLight = Color(0xFFFFF0F2);  // 로즈 파스텔 틴트
  static const Color background = Color(0xFFFAF6F7);    // 소프트 로즈 크림
  static const Color surface = Color(0xFFFFFFFF);       // 순백 카드 표면
  static const Color textMain = Color(0xFF202124);      // 본문 메인 텍스트
  static const Color textSub = Color(0xFF667085);       // 서브 라벨 / 날짜
  static const Color border = Color(0xFFE7E9ED);        // 1px 정밀 보더
  static const Color verified = Color(0xFF0D9488);      // 딥 틸 인증/거리

  // 2. 8dp Grid Spacing Tokens
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  // 3. Border Radius Tokens (docs/OOMU_UI_GUIDE.md 기준)
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0; // 버튼/인풋
  static const double radiusLarge = 16.0;  // 카드 표면
  static const double radiusSheet = 24.0;  // 바텀시트
  static const double radiusPill = 999.0;

  // 4. Mobile Touch Target
  static const double minTouchTarget = 48.0;
}
```

## 3. 타이포그래피 스케일 (`docs/OOMU_UI_GUIDE.md` 기준)
- **Display**: 20~22sp / Bold / Height 1.3~1.38
- **Heading / Host**: 17~18sp / SemiBold~Bold / Height 1.35~1.4
- **Subheading / Card Title**: 16~17sp / SemiBold~Bold / Height 1.35~1.4
- **Body**: 15~16sp / Regular~Medium / Height 1.5~1.6
- **Caption / Meta**: 13~14sp / Medium / Height 1.35
- **규칙**: Flutter `Text`에 존재하지 않는 `wordBreak: WordBreak.keepAll`은 사용하지 않으며, 공식 `Text` API(`softWrap`, `overflow`, `maxLines`)와 grapheme cluster 보존 원칙을 준수합니다.
