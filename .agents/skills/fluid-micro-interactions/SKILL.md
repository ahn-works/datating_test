---
name: fluid-micro-interactions
description: gskinner Wonderous 및 29CM급 유려한 네이티브 모바일 마이크로 인터랙션 가이드. 슬리버(Sliver) 패럴랙스 스크롤 헤더, 햅틱 피드백(Haptics), 스프링 바운스 스크롤 피직스를 구현합니다.
license: MIT
---

# 플루이드 마이크로 인터랙션 & 햅틱 가이드

본 스킬은 전 세계 플러터 커뮤니티의 벤치마크인 **gskinner Wonderous**의 마이크로 인터랙션 기법을 OOMU 모바일 앱에 이식하여, 유저가 손끝으로 조작할 때 '살아있는 완성도'를 체감하게 만듭니다.

## 1. 상용화 및 라이선스 (Commercial Viability)
- **라이선스**: MIT License (상업적 이용 100% 보장)

## 2. 햅틱 피드백(Haptic Feedback) 표준 매트릭스
모바일 유저 경험에서 시각만큼 중요한 것이 촉각적 피드백입니다:

```dart
class OomuHaptics {
  // 1. 일반 탭, 칩 선택, 카테고리 전환 시
  static void selection() => HapticFeedback.selectionClick();

  // 2. 좋아요, 찜, 참여 신청 버튼 탭 시
  static void light() => HapticFeedback.lightImpact();

  // 3. 결제 완료, 동네 인증 성공 등 중요한 성취 시
  static void medium() => HapticFeedback.mediumImpact();

  // 4. 차단, 신고, 에러 경고 시
  static void heavy() => HapticFeedback.heavyImpact();
}
```

## 3. 슬리버 패럴랙스 모임 상세 헤더 (Sliver Parallax Header)
모임 대표 이미지가 스크롤 시 부드럽게 축소되며 앱바로 트랜지션되는 구조:

```dart
Widget buildParallaxDetailHeader({
  required String imageUrl,
  required String title,
}) {
  return SliverAppBar(
    expandedHeight: 280.0,
    pinned: true,
    stretch: true,
    backgroundColor: Colors.white,
    elevation: 0,
    flexibleSpace: FlexibleSpaceBar(
      title: Text(
        title,
        style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w700),
      ),
      background: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
```
