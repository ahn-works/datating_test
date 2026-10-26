---
name: manner-temp-badges
description: 당근마켓 매너온도 및 신뢰 평판 배지 시스템 UI 가이드. 36.5도 기준 색상 변화 온도계 게이지, 본인인증(PASS/SMS) 배지, 클린 호스트 마크, 칭찬 후기 칩 컴포넌트를 제공합니다.
license: MIT
---

# 매너온도 & 신뢰 평판 배지(Trust Badges) UI 가이드

본 스킬은 C2C 커뮤니티에서 가장 중요한 **사용자 간 신뢰 지표(Manner Temperature & Verified Badges)**를 직관적이고 감성적으로 시각화하는 위젯 규격입니다.

## 1. 상용화 및 라이선스 (Commercial Viability)
- **라이선스**: MIT License (상업적 이용 및 상표권 침해 없음)
- **법적 검증**: 섭씨온도(`°C`) 기반의 동적 게이지와 표준 인증 배지 레이아웃을 독자적으로 구현하여 지식재산권 분쟁이 없습니다.

## 2. 동적 매너온도 게이지 (Dynamic Temperature Gauge)

온도 수치에 따라 색상과 표정 이모지가 자동으로 반응하는 네이티브 위젯입니다:

```dart
Widget buildMannerTemperatureGauge(double temp) {
  // 온도별 컬러 및 상태 이모지 매핑
  Color tempColor;
  String emoji;
  if (temp < 36.5) {
    tempColor = const Color(0xFF64748B); // 슬레이트 블루 (기본/주의)
    emoji = '🙂';
  } else if (temp < 40.0) {
    tempColor = const Color(0xFF2563EB); // 블루 (양호)
    emoji = '😊';
  } else if (temp < 50.0) {
    tempColor = const Color(0xFF059669); // 그린 (우수)
    emoji = '😄';
  } else {
    tempColor = const Color(0xFFFF6B4A); // 선셋 코랄 (열정/최고)
    emoji = '🔥';
  }

  // 100도 기준 퍼센트 계산
  final progress = (temp / 100.0).clamp(0.0, 1.0);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${temp.toStringAsFixed(1)}°C', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: tempColor)),
          const SizedBox(width: 4),
          Text(emoji, style: const TextStyle(fontSize: 18)),
        ],
      ),
      const SizedBox(height: 4),
      SizedBox(
        width: 100,
        height: 6,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(tempColor),
          ),
        ),
      ),
    ],
  );
}
```

## 3. 칭찬 태그 칩 (Praise Chips)
- *"⏰ 시간 약속을 잘 지켜요"*
- *"💬 대화가 편안하고 배려심 넘쳐요"*
- *"✨ 다음 모임에도 또 함께하고 싶어요"*
- 가벼운 파스텔 틴트 배경(`#F8FAFC`)과 얇은 보더로 깔끔하게 정돈된 그리드로 노출합니다.
