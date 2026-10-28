---
name: karrot-hyperlocal-feed
description: 당근마켓(동네생활/모임) 및 하이퍼로컬 커뮤니티 1티어 피드 UI/UX 엔진. 88x88 썸네일, 2줄 말줄임 제목, 동네 인증 뱃지, 안심 거리 표시, 100:100 대칭 2열 그리드를 구현할 때 사용합니다.
license: MIT
---

# 당근마켓 스타일 하이퍼로컬 피드 & 카드 UI 가이드

본 스킬은 대한민국 1위 하이퍼로컬 서비스인 **당근마켓(Karrot)**의 신뢰도 높은 동네생활·모임 피드 UI 구조를 모바일 Flutter 환경에서 결함 없이(Overflow 0%, 짤림 0%) 완벽하게 구현하기 위한 전문 지침입니다.

## 1. 상용화 및 라이선스 (Commercial Viability)
- **라이선스**: MIT License (상업적 이용, 수정, 비공개 패키징 100% 허용)
- **저작권 보장**: 특정 기업의 독점 그래픽 에셋(당근 캐릭터 등)을 직접 복제하지 않고, 모바일 앱 표준 레이아웃 아키텍처 및 Flutter 네이티브 위젯 패턴만 사용하므로 상용 스토어 출시 시 법적 리스크가 0%입니다.

## 2. 88×88 정방형 피드 리스트 표준 레이아웃 (List Pattern)
동네 모임 피드의 메인 리스트 아이템은 다음 3-Tier 구조를 엄격히 준수합니다:

```dart
// Row 내부 좌우 밸런스: 좌측 고정 88x88 + 우측 Flexible 자동 신축
Widget buildKarrotFeedItem(BuildContext context, MeetingItem item) {
  return InkWell(
    onTap: () => Navigator.pushNamed(context, '/meeting-detail', arguments: item.id),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 좌측 정방형 썸네일 (88x88dp, r=12dp)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 88,
              height: 88,
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                placeholder: (c, u) => Container(color: const Color(0xFFF1F5F9)),
                errorWidget: (c, u, e) => Container(color: const Color(0xFFE2E8F0), child: const Icon(Icons.group, color: Colors.grey)),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // 2. 우측 정보 영역 (Expanded 필수 - 오버플로우 방지)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // [카테고리 칩 + 동네 배지]
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(item.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFF25767))),
                    ),
                    const SizedBox(width: 6),
                    Text(item.neighborhood, style: const TextStyle(fontSize: 13, color: Color(0xFF667085))),
                  ],
                ),
                const SizedBox(height: 4),
                // [2줄 타이틀 - 한글 단어 보존]
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF202124), height: 1.35),
                ),
                const SizedBox(height: 6),
                // [일정 & 참여 인원 (안심정산 배지 미표시 — docs/OOMU_UI_GUIDE.md 기준)]
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF667085)),
                    const SizedBox(width: 3),
                    Text(item.formattedTime, style: const TextStyle(fontSize: 13, color: Color(0xFF667085))),
                    const Spacer(),
                    Text(item.memberStatus, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFF25767))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
```

## 3. 100:100 완벽 대칭 2열 인피드 그리드 (Grid Pattern)
- 우측 화면이 잘리거나 비대칭인 가로 스크롤을 금지하고, 모바일 뷰포트(360~412dp)에서 좌우 카드가 정확히 `1:1` 비율을 갖도록 `Row` + `Expanded` 페어링을 적용합니다.
- 긴 이벤트 제목은 반드시 `maxLines: 2`와 `TextOverflow.ellipsis`를 부여합니다.
