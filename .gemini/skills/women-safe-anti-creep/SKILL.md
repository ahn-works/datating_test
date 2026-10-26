---
name: women-safe-anti-creep
description: 여성 안심(Women-First) 및 악성/변태 유저 차단(Anti-Creep) 전용 안전 UI/UX 가이드. 호스트 승인제 신청 모달, 여성 전용 필터 칩, 1-Click 비밀 신고/차단, 안심 귀가 타이머 위젯을 제공합니다.
license: MIT
---

# 여성 안심(Women-First) & 클린 커뮤니티 UI 가이드

본 스킬은 **"여성이 안심하고 편안하게 활동해야 매너 있는 남성이 모이고 건강한 커뮤니티가 완성된다"**는 OOMU의 핵심 철학을 실체화하는 전용 안전 UI/UX 컴포넌트 규격입니다.

## 1. 상용화 및 구글 플레이 정책 준수 (Google Play UGC Policy Compliant)
- **라이선스**: MIT License (상업적 배포 보장)
- **구글 플레이 필수 정책 100% 충족**: 구글 플레이의 사용자 생성 콘텐츠(UGC) 안전 가이드라인에 따른 **'신고 기능(Report)', '즉시 차단(Block)', '호스트 승인 필터'**를 상시 내장하여 심사 리젝을 원천 방지합니다.

## 2. 1-Click 비밀 신고 & 즉시 차단 바텀시트
유저가 불쾌감을 느꼈을 때 상대방 모르게 즉각 조치할 수 있는 안심 바텀시트입니다:

```dart
void showSafeReportBlockSheet(BuildContext context, {required String targetUserId, required String targetNickname}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Color(0xFFEF4444), size: 22),
                  SizedBox(width: 8),
                  Text('안심 보호 & 신고 센터', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                ],
              ),
              const SizedBox(height: 8),
              Text('$targetNickname 님과의 대화나 프로필에서 불쾌함을 느끼셨나요? 상대방 모르게 안전하게 조치됩니다.',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4)),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(backgroundColor: Color(0xFFFEE2E2), child: Icon(Icons.block, color: Color(0xFFEF4444), size: 20)),
                title: const Text('이 사용자와 상호 즉시 차단하기', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: const Text('서로의 프로필과 개설 모임이 영구적으로 보이지 않습니다.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                onTap: () {
                  Navigator.pop(ctx);
                  // 차단 로직 실행 + 스낵바 안내
                },
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(backgroundColor: Color(0xFFFEF3C7), child: Icon(Icons.flag_outlined, color: Color(0xFFD97706), size: 20)),
                title: const Text('비매너 / 성적 수치심 / 사기 신고하기', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: const Text('24시간 운영팀에 즉각 접수되며 익명이 철저히 보장됩니다.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                onTap: () {
                  Navigator.pop(ctx);
                  // 신고 상세 사유 선택 모달 호출
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
```

## 3. 안심 귀가 타이머 (Safe Return Timer) 위젯
모임 종료 후 유저가 안전하게 귀가했는지 확인하고 이상 시 비상 연락망에 알리는 여성 안심 특화 위젯입니다.
