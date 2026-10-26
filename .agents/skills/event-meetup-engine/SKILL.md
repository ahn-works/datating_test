---
name: event-meetup-engine
description: 문토(Munto) 및 이벤트허브(EventHub) 스타일의 동네 모임 상세 화면 및 4단계 개설 플로우 UI/UX 엔진. 참여자 아바타 스택(AvatarStack), D-Day 카운트다운 뱃지, 호스트 신뢰도 카드, 하단 플로팅 신청 바텀시트를 구현합니다.
license: MIT
---

# 이벤트 & 모임(Event & Meetup) UI/UX 엔진 가이드

본 스킬은 **문토(MUNTO)** 및 글로벌 1위 이벤트 템플릿인 **EventHub**의 검증된 모임 인터페이스를 기반으로, 모임 상세 화면과 신청 절차를 모바일 최적화 규격으로 구현합니다.

## 1. 상용화 및 라이선스 (Commercial Viability)
- **라이선스**: MIT License (완전한 상업적 소프트웨어 상용화 보장)
- **법적 검증**: 특정 업체의 독점 소스가 아닌, 오픈소스 이벤트 프레임워크 표준 구조를 적용합니다.

## 2. 참여자 아바타 스택 (AvatarStack) 컴포넌트
참가자들의 프로필 사진이 겹쳐지며 시각적으로 신뢰도와 인기를 증명하는 위젯입니다:

```dart
Widget buildAvatarStack({
  required List<String> avatarUrls,
  required int currentCount,
  required int maxCount,
  double size = 32.0,
}) {
  final displayAvatars = avatarUrls.take(4).toList();
  return Row(
    children: [
      SizedBox(
        height: size,
        width: size + (displayAvatars.length - 1) * (size * 0.65),
        child: Stack(
          children: List.generate(displayAvatars.length, (index) {
            return Positioned(
              left: index * (size * 0.65),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: (size / 2) - 2,
                  backgroundImage: CachedNetworkImageProvider(displayAvatars[index]),
                ),
              ),
            );
          }),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        '$currentCount/$maxCount명 참여 중',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
      ),
    ],
  );
}
```

## 3. 하단 고정 신청 바텀시트 (Sticky Bottom CTA Bar)
스크롤 위치에 관계없이 엄지손가락으로 즉시 닿을 수 있는 하단 플로팅 바입니다:

```dart
Widget buildStickyBottomApplyBar({
  required BuildContext context,
  required bool isHost,
  required bool isFull,
  required VoidCallback onApply,
}) {
  return SafeArea(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1.0)),
      ),
      child: Row(
        children: [
          // 찜하기 / 관심 버튼
          IconButton(
            onPressed: () => HapticFeedback.lightImpact(),
            icon: const Icon(Icons.favorite_border_rounded, color: Color(0xFF64748B)),
          ),
          const SizedBox(width: 12),
          // 핵심 참여 신청 버튼 (Expanded)
          Expanded(
            child: ElevatedButton(
              onPressed: isFull ? null : () {
                HapticFeedback.mediumImpact();
                onApply();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B4A),
                disabledBackgroundColor: const Color(0xFFE2E8F0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                isFull ? '모집 정원 마감' : '모임 참여 신청하기',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
```
