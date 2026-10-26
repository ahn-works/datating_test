---
name: shadcn-mobile-components
description: Shadcn UI 스타일의 미니멀·고품격 모바일 컴포넌트 가이드. 1px 정밀 보더 카드, 인피드 아코디언 더보기/접기, 슬림 필 도트 인디케이터(━━ • • •), 커스텀 세그먼트 탭을 구현합니다.
license: MIT
---

# Shadcn 스타일 모바일 컴포넌트 가이드

본 스킬은 웹에서 가장 각광받는 `shadcn/ui`의 정갈하고 미니멀한 시각 감각을 Flutter 모바일 환경에 이식하여, 머티리얼의 둔탁함을 걷어내고 세련된 프리미엄 앱 UI를 완성하는 위젯 모음입니다.

## 1. 상용화 및 라이선스 (Commercial Viability)
- **라이선스**: MIT License (상업적 이용 및 완전한 자체 커스텀 가능)

## 2. 1px 미세 보더 카드 컴포넌트 (Shadcn Border Card)
부담스러운 그림자 대신 1.0dp 정밀 스트로크와 미세한 음영으로 모던함을 구현합니다:

```dart
Widget buildShadcnCard({
  required Widget child,
  EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  VoidCallback? onTap,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08000000), // 아주 은은한 3% 투명도
          blurRadius: 4,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    ),
  );
}
```

## 3. 슬림 필 도트 인디케이터 (Pill-Dot PageView Indicator)
`PageView` 스냅 페이징 시 현재 페이지를 강조하는 트렌디한 인디케이터:

```dart
Widget buildPillDotIndicator({required int totalCount, required int currentIndex}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(totalCount, (index) {
      final isSelected = index == currentIndex;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        height: 4,
        width: isSelected ? 18 : 6, // 선택된 페이지는 긴 바 형태
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B4A) : const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }),
  );
}
```
