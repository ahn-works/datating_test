---
name: escrow-split-billing
description: 동네 소모임 투명 1/N 안심 정산 및 노쇼 방지 에스크로 UI 가이드. 원화 직접 표기 배제 원칙 준수, 1/N 정산 계산서, 카카오페이/토스 송금 딥링크 모달, 예약금 보관증 위젯을 제공합니다.
license: MIT
---

# 1/N 안심 에스크로 정산 & 결제 UI 가이드

본 스킬은 오프라인 모임의 가장 큰 마찰 지점인 **참가비 정산과 노쇼(No-show) 문제**를 해결하기 위한 Flutter 투명 정산 시스템 컴포넌트입니다.

## 1. 상용화 및 결제 보안 (Payment Compliance)
- **라이선스**: MIT License (전자상거래 및 플랫폼 수수료 BM 100% 대응)
- **OOMU 표기 원칙 준수**: 피드 목록에서 거부감을 주는 원화 금액(`15,000원`) 대신 **`1/N 안심 정산`** 뱃지로 표기하여 사용자 참여 심리 장벽을 대폭 낮춥니다.

## 2. 1/N 자동 정산 계산서 바텀시트 (Split Bill Sheet)

영수증 총액을 입력하면 참석 인원수대로 균등 분할하고 각자의 송금 상태를 체크하는 모달입니다:

```dart
Widget buildSplitBillReceiptSheet(BuildContext context, {
  required int totalAmount,
  required int participantCount,
  required List<ParticipantPayStatus> participants,
  required VoidCallback onTossPay,
  required VoidCallback onKakaoPay,
}) {
  final perPerson = (totalAmount / participantCount).ceil();

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.receipt_long_rounded, color: Color(0xFFFF6B4A), size: 22),
            SizedBox(width: 8),
            Text('1/N 투명 안심 정산서', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('총 결제 금액 (총 $participantCount명)', style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
              Text('${totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFFFFF4EB), borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('1인당 정산 금액', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFFF6B4A))),
              Text('${perPerson.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFFF6B4A))),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // 간편 송금 버튼 (토스 / 카카오페이)
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onKakaoPay,
                icon: const Icon(Icons.payment, size: 16, color: Colors.black87),
                label: const Text('카카오페이 송금', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFEE500), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onTossPay,
                icon: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                label: const Text('토스 송금', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0064FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
```
