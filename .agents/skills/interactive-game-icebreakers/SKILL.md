---
name: interactive-game-icebreakers
description: 30대 동네친구/자만추 온라인 아이스브레이킹 미니게임 UI 컴포넌트 킷. 온라인 노래방 점수 배틀(벌칙 내기), 캐치마인드 드로잉 캔버스, 타로 궁합 카드 뒤집기, 밸런스 토론 배틀 위젯을 제공합니다.
license: MIT
---

# 온라인 아이스브레이킹 & 게이미피케이션 UI 가이드

본 스킬은 어색한 첫 대화의 벽을 허물고 친밀감을 극대화하기 위해, 실제 유저들이 열광하는 **4대 인터랙티브 미니게임 UI 컴포넌트**를 Flutter로 구현하는 지침입니다.

## 1. 상용화 및 디자인 단일 기준 (`docs/OOMU_DESIGN_SYSTEM.md`)
- **라이선스**: MIT License (상업적 이용, 인앱 결제 재화 연동 가능)
- **단일 디자인 기준**: 모든 색상·타이포그래피·간격 수치는 [`docs/OOMU_DESIGN_SYSTEM.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_DESIGN_SYSTEM.md) 및 `OomuUiHelpers`를 따릅니다 (구형 주황 `#FF6B4A` 사용 금지).

## 2. 밸런스 토론 배틀 (Balance Debate Game) 위젯
채팅방 또는 피드에서 양자택일 질문을 던지고 유저들의 실시간 투표 비율을 시각화합니다:

```dart
Widget buildBalanceGameCard({
  required String question,
  required String optionA,
  required String optionB,
  required int countA,
  required int countB,
  required Function(String choice) onVote,
}) {
  final total = countA + countB;
  final percentA = total == 0 ? 50 : ((countA / total) * 100).round();
  final percentB = 100 - percentA;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚖️ ', style: TextStyle(fontSize: 16)),
            Text(question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // 옵션 A (코랄)
            Expanded(
              flex: percentA > 0 ? percentA : 1,
              child: GestureDetector(
                onTap: () => onVote('A'),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: const BoxDecoration(
                    color: OomuUiHelpers.brandCoral,
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text('$optionA ($percentA%)',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis),
                ),
              ),
            ),
            // 옵션 B (네이비)
            Expanded(
              flex: percentB > 0 ? percentB : 1,
              child: GestureDetector(
                onTap: () => onVote('B'),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                  ),
                  alignment: Alignment.centerRight,
                  child: Text('$optionB ($percentB%)',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
```

## 3. 노래방 점수 배틀 & 타로 궁합 카드
- **노래방 점수 내기**: 점수 입력 및 벌칙(아이스 아메리카노 쏘기 등) 당첨자 축하 팡파레 Lottie 애니메이션.
- **타로 궁합**: 3D 카드 플립 애니메이션(`Transform(transform: Matrix4.rotationY(...))`)으로 상호 호환도 점수 공개.
