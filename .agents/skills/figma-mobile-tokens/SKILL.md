---
name: figma-mobile-tokens
description: 피그마(Figma) 디자인 시스템 토큰을 Flutter ThemeData 및 OomuUiHelpers로 매핑하는 가이드. 모든 색상·타이포그래피·간격 수치는 docs/OOMU_DESIGN_SYSTEM.md 단일 기준을 따릅니다.
license: MIT
---

# 피그마 디자인 토큰 ↔ Flutter 동기화 가이드

> **단일 디자인 기준**:
> 색상·타이포그래피·간격·반경·터치 타깃 수치는 여러 파일에 중복 정의하지 않고 유일한 기준 문서인 **[`docs/OOMU_DESIGN_SYSTEM.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_DESIGN_SYSTEM.md)**와 실제 구현 코드인 [`lib/utils/oomu_ui_helpers.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/utils/oomu_ui_helpers.dart) (`OomuUiHelpers`)를 그대로 참조합니다.

## 1. 상용화 및 라이선스 (Commercial Viability)
- **라이선스**: MIT License

## 2. OOMU 공식 모바일 디자인 토큰 참조 (`OomuUiHelpers`)
- 구형 분홍 배경(`#FAF6F7`) 및 구형 주황 강조(`#FF6B4A`)는 **사용 금지 예시**입니다.
- 코드에서는 별도 중복 토큰 클래스를 만들지 않고 [`lib/utils/oomu_ui_helpers.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/utils/oomu_ui_helpers.dart)의 `OomuUiHelpers` 상수를 사용합니다:

```dart
import 'package:spot10_app/utils/oomu_ui_helpers.dart';

// docs/OOMU_DESIGN_SYSTEM.md 단일 기준 토큰 사용 예시:
// - 배경: OomuUiHelpers.bgWarmIvory
// - 카드 표면: OomuUiHelpers.surfaceWhite
// - 보더: OomuUiHelpers.borderSoftRose
// - 비활성 칩 배경: OomuUiHelpers.surfaceMutedCream
// - 주 텍스트: OomuUiHelpers.textPrimary
// - 본문/보조 텍스트: OomuUiHelpers.textSecondary
// - 캡션/비활성: OomuUiHelpers.textMuted
// - 브랜드 강조 포인트: OomuUiHelpers.brandCoral
```

## 3. 타이포그래피 및 줄바꿈 원칙
- 모든 텍스트 크기·두께·줄간격 수치는 [`docs/OOMU_DESIGN_SYSTEM.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_DESIGN_SYSTEM.md)의 `[2. 타이포그래피 위계]`를 따릅니다.
- **주의**: Flutter `TextStyle`에는 CSS의 `WordBreak.keepAll` 속성이 존재하지 않으므로 이를 지시하거나 사용하지 않으며, 제목 문자열에 `\u2060` 등을 삽입하지 않고 [`OomuUiHelpers.formatTitle`](file:///c:/Users/DT4/Downloads/oomu_app/lib/utils/oomu_ui_helpers.dart)을 통해 원문과 이모지를 보존합니다.
