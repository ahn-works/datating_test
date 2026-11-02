---
name: escrow-split-billing
description: 동네 소모임 투명 1/N 정산 계산서 및 송금 모달 UI 가이드. 모든 색상·타이포·금액 표기 원칙은 docs/OOMU_UI_GUIDE.md 단일 기준을 따릅니다.
license: MIT
---

# 1/N 정산 계산서 & 결제 모달 UI 가이드

본 스킬은 모임 종료 후 참가비 정산을 돕는 Flutter 정산 계산서 바텀시트 컴포넌트 가이드입니다.

## 1. 금액 표기 및 디자인 기준 (`docs/OOMU_UI_GUIDE.md` 단일 기준)
- **라이선스**: MIT License
- **금액 표기 원칙 준수**: 피드나 상세 화면에서 실제 확인된 비용 정보(`fee`/`cost`/`price`)가 있을 때만 표시하며, 확인되지 않은 모임에 임의의 `'무료 참여'`나 `'1/N 안심 정산'` 배지를 일괄 강제하지 않습니다 ([`docs/OOMU_UI_GUIDE.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md) `[3. 레이아웃 & 컴포넌트 규칙]` 참조).
- **컬러·타이포그래피 단일 기준**: 구형 주황(`#FF6B4A`, `#FFF4EB`) 대신 [`docs/OOMU_UI_GUIDE.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md) 및 [`OomuUiHelpers`](file:///c:/Users/DT4/Downloads/oomu_app/lib/utils/oomu_ui_helpers.dart)의 컬러·타이포 토큰을 사용합니다.

## 2. 1/N 정산 계산서 바텀시트 (Split Bill Sheet)

영수증 총액을 입력하면 참석 인원수대로 균등 분할하는 모달 예시입니다:

```dart
Widget buildSplitBillReceiptSheet(BuildContext context, {
  required int totalAmount,
  required int participantCount,
  required VoidCallback onTossPay,
  required VoidCallback onKakaoPay,
}) {
  final perPerson = (totalAmount / participantCount).ceil();

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: OomuUiHelpers.surfaceWhite,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.receipt_long_rounded, color: OomuUiHelpers.brandCoral, size: 22),
            SizedBox(width: 8),
            Text('1/N 정산 계산서', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: OomuUiHelpers.textPrimary)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: OomuUiHelpers.bgWarmIvory, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('총 결제 금액 (총 $participantCount명)', style: const TextStyle(fontSize: 14, color: OomuUiHelpers.textSecondary)),
              Text('${totalAmount}원',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: OomuUiHelpers.textPrimary)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: OomuUiHelpers.coralSoftBg, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('1인당 정산 금액', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: OomuUiHelpers.brandCoralDark)),
              Text('${perPerson}원',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: OomuUiHelpers.brandCoralDark)),
            ],
          ),
        ),
      ],
    ),
  );
}
```
