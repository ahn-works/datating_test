---
name: wippy-social-jamanchu
description: 위피(Wippy) 및 감성 소셜 디스커버리 앱 스타일의 30대 자연스러운 자만추·스토리형 프로필 UI/UX 가이드. 스와이프를 배제하고 가치관 문답, 라이프스타일 칩, 동네 아지트 소개 카드를 구성할 때 사용합니다.
license: MIT
---

# 위피 스타일 30대 자연스러운 자만추 프로필 UI 가이드

본 스킬은 사람을 물건처럼 좌우로 넘겨버리는 틴더식 스와이프 UI를 배제하고, **위피(WIPPY)**와 **문토(MUNTO)**에서 검증된 **"자연스러운 대화와 취향 중심의 30대 자만추 스토리 프로필"**을 구현하는 지침입니다.

## 1. 상용화 및 라이선스 (Commercial Viability)
- **라이선스**: MIT License (상업적 배포 및 유료 수익화 100% 보장)
- **법적 안정성**: 특정 브랜드의 시각 자산을 베끼지 않고, 모바일 앱 일반적인 버티컬 스크롤 스토리 카드 패턴을 따릅니다.

## 2. 30대 취향 스토리 카드 구조 (Story Profile Architecture)

```dart
Widget buildJamanchuProfileCard(BuildContext context, UserProfile profile) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 대표 사진 + 매너온도 뱃지 오버레이
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: AspectRatio(
                aspectRatio: 1.1,
                child: CachedNetworkImage(
                  imageUrl: profile.avatarUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥 ', style: TextStyle(fontSize: 12)),
                    Text('${profile.mannerTemp.toStringAsFixed(1)}°C',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
        // 2. 닉네임 & 나이 & 동네 정보
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(profile.nickname, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  const SizedBox(width: 6),
                  Text('${profile.age}세', style: const TextStyle(fontSize: 15, color: Color(0xFF64748B))),
                  const Spacer(),
                  // 안심 본인인증 뱃지
                  if (profile.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, size: 12, color: Color(0xFF2E7D32)),
                          SizedBox(width: 3),
                          Text('본인인증 완료', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32))),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              // 3. 라이프스타일 & 취향 태그 칩 (Wrap)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: profile.lifestyleTags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF6F7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFE4E6), width: 0.8),
                  ),
                  child: Text(tag, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFBE185D))),
                )).toList(),
              ),
              const SizedBox(height: 14),
              // 4. 가치관 한줄 Q&A (대화 아이스브레이킹 유도)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💬 Q. ${profile.valueQuestion}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                    const SizedBox(height: 4),
                    Text(profile.valueAnswer, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
```

## 3. 심리적 안전감 & 과열 방지 규칙
- 일방적인 무차별 1:1 메시지 보내기 버튼은 숨기고, **"모임에서 만나기"** 또는 **"호스트 주최 모임에 참여 신청하기"**로 그룹 단위를 유도합니다.
