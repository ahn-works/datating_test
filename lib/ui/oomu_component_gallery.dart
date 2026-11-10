import 'package:flutter/material.dart';

import 'ui.dart';

/// OOMU 디자인 시스템 공통 부품 개발용 갤러리 화면
/// - 모든 부품의 변형(variant) 및 상태(state)를 한곳에서 확인
class OomuComponentGallery extends StatefulWidget {
  const OomuComponentGallery({super.key});

  @override
  State<OomuComponentGallery> createState() => _OomuComponentGalleryState();
}

class _OomuComponentGalleryState extends State<OomuComponentGallery> {
  int _selectedChipIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OomuTokens.background,
      appBar: const OomuAppBar(
        title: 'OOMU UI 컴포넌트 갤러리',
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: OomuTokens.pagePadding,
          vertical: OomuTokens.s16,
        ),
        children: [
          // 1. OomuButton
          const OomuSectionHeader(
            title: '1. OomuButton',
            subtitle: 'Primary / Secondary / Text (52dp / 48dp)',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: OomuTokens.s12),
          OomuButton(
            label: '주요 액션 (Primary 52dp)',
            icon: Icons.check_circle_outline_rounded,
            onPressed: () {},
          ),
          const SizedBox(height: OomuTokens.s8),
          OomuButton.secondary(
            label: '보조 액션 (Secondary 52dp)',
            icon: Icons.map_outlined,
            onPressed: () {},
          ),
          const SizedBox(height: OomuTokens.s8),
          Row(
            children: [
              Expanded(
                child: OomuButton(
                  label: '소형 (48dp)',
                  size: OomuButtonSize.small,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: OomuTokens.s8),
              Expanded(
                child: OomuButton.secondary(
                  label: '로딩 상태',
                  size: OomuButtonSize.small,
                  isLoading: true,
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: OomuTokens.s8),
          Center(
            child: OomuButton.text(
              label: '텍스트 버튼 (Text 48dp 터치 보장)',
              icon: Icons.refresh_rounded,
              onPressed: () {},
            ),
          ),

          const SizedBox(height: OomuTokens.sectionGap),

          // 2. OomuChip
          const OomuSectionHeader(
            title: '2. OomuChip',
            subtitle: '필터용 칩 (시각적 36dp, 터치 48dp 보장)',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: OomuTokens.s12),
          Wrap(
            spacing: OomuTokens.s8,
            runSpacing: OomuTokens.s4,
            children: [
              OomuChip(
                label: '전체',
                count: '12',
                isSelected: _selectedChipIndex == 0,
                onTap: () => setState(() => _selectedChipIndex = 0),
              ),
              OomuChip(
                label: '오늘 번개',
                icon: Icons.bolt_rounded,
                isSelected: _selectedChipIndex == 1,
                onTap: () => setState(() => _selectedChipIndex = 1),
              ),
              OomuChip(
                label: '취향 아지트',
                icon: Icons.coffee_rounded,
                isSelected: _selectedChipIndex == 2,
                onTap: () => setState(() => _selectedChipIndex = 2),
              ),
              OomuChip(
                label: '라이프 메이트',
                icon: Icons.directions_run_rounded,
                isSelected: _selectedChipIndex == 3,
                onTap: () => setState(() => _selectedChipIndex = 3),
              ),
            ],
          ),

          const SizedBox(height: OomuTokens.sectionGap),

          // 3. OomuTag & OomuBadge
          const OomuSectionHeader(
            title: '3. OomuTag & OomuBadge',
            subtitle: '중립 칩(성향/관심사) 및 이미지 배지',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: OomuTokens.s12),
          const Wrap(
            spacing: OomuTokens.s8,
            runSpacing: OomuTokens.s8,
            children: [
              OomuTag(label: '#러닝·운동'),
              OomuTag(label: '#소규모와인'),
              OomuTag.pill(label: '비흡연'),
              OomuTag.pill(label: 'ENFP'),
              OomuBadge(label: 'D-Day 1'),
              OomuBadge.coral(label: '모집 마감 임박'),
              OomuBadge.neutral(label: '도보 150m'),
            ],
          ),

          const SizedBox(height: OomuTokens.sectionGap),

          // 4. OomuAvatar
          const OomuSectionHeader(
            title: '4. OomuAvatar',
            subtitle: '사진 로드 및 이니셜 대체 처리',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: OomuTokens.s12),
          const Row(
            children: [
              OomuAvatar.small(name: '지연'),
              SizedBox(width: OomuTokens.s12),
              OomuAvatar(name: '민지'),
              SizedBox(width: OomuTokens.s12),
              OomuAvatar.large(name: '초연'),
              SizedBox(width: OomuTokens.s12),
              OomuAvatar(imageUrl: 'assets/images/cover_cafe.jpg'),
            ],
          ),

          const SizedBox(height: OomuTokens.sectionGap),

          // 5. OomuInfoRow
          const OomuSectionHeader(
            title: '5. OomuInfoRow',
            subtitle: '일시 · 장소 · 인원 · 비용 정보 행',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: OomuTokens.s12),
          Container(
            padding: const EdgeInsets.all(OomuTokens.cardPadding),
            decoration: BoxDecoration(
              color: OomuTokens.surface,
              borderRadius: BorderRadius.circular(OomuTokens.r16),
              border: Border.all(color: OomuTokens.border, width: 1),
            ),
            child: const Column(
              children: [
                OomuInfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: '일시',
                  value: '오늘 저녁 7시 30분',
                ),
                OomuInfoRow(
                  icon: Icons.place_outlined,
                  label: '장소',
                  value: '마포구 연남동 경의선숲길 잔디마당',
                ),
                OomuInfoRow(
                  icon: Icons.people_outline_rounded,
                  label: '인원',
                  value: '2/4명 참여 (2자리 남음)',
                ),
              ],
            ),
          ),

          const SizedBox(height: OomuTokens.sectionGap),

          // 6. OomuMeetupCard (Block & List)
          const OomuSectionHeader(
            title: '6. OomuMeetupCard (Block / List)',
            subtitle: '16:9 사진 / 2줄 제목 / 매너온도 칩 배제',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: OomuTokens.s12),
          OomuMeetupCard(
            title: '연남동 연트럴파크 돗자리 캔맥주 급구 (초보 환영)',
            imageUrl: 'assets/images/cover_wine.jpg',
            date: '오늘 저녁 8시',
            location: '마포구 연남동 경의선숲길',
            hostName: '연트럴피플',
            members: '3/4',
            statusBadge: '오늘 번개',
            infoBadge: '도보 180m',
            onTap: () {},
          ),
          const SizedBox(height: OomuTokens.cardGap),
          OomuMeetupCard.list(
            title: '주말 아침 망원 한강공원 가벼운 5km 러닝 크루',
            imageUrl: 'assets/images/cover_running.jpg',
            date: '이번 주 토요일 09:00',
            location: '마포구 망원동 한강공원',
            hostName: '러너_지안',
            members: '2/5',
            statusBadge: '러닝·운동',
            onTap: () {},
          ),

          const SizedBox(height: OomuTokens.sectionGap),

          // 7. OomuEmptyState
          const OomuSectionHeader(
            title: '7. OomuEmptyState',
            subtitle: '아이콘 + 한 줄 + 버튼 1개',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: OomuTokens.s12),
          Container(
            decoration: BoxDecoration(
              color: OomuTokens.surface,
              borderRadius: BorderRadius.circular(OomuTokens.r16),
              border: Border.all(color: OomuTokens.border, width: 1),
            ),
            child: OomuEmptyState(
              icon: Icons.location_off_outlined,
              title: '등록된 모임이 아직 없어요',
              subtitle: '우리 동네 첫 번째 모임을 직접 개설해보세요!',
              buttonLabel: '첫 모임 개설하기',
              onButtonPressed: () {},
            ),
          ),

          const SizedBox(height: OomuTokens.sectionGap),

          // 8. OomuSkeleton
          const OomuSectionHeader(
            title: '8. OomuSkeleton',
            subtitle: '회색 블록 로딩 스켈레톤',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: OomuTokens.s12),
          const OomuMeetupCardSkeleton(),

          const SizedBox(height: OomuTokens.sectionGap),

          // 9. OomuSheet
          const OomuSectionHeader(
            title: '9. OomuSheet',
            subtitle: '24dp 상단 모서리 + 40x4 핸들 바텀시트',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: OomuTokens.s12),
          OomuButton.secondary(
            label: 'OomuSheet 바텀시트 미리보기 열기',
            onPressed: () {
              OomuSheet.show(
                context: context,
                builder: (ctx) => OomuSheet(
                  title: '참여 신청하기',
                  subtitle: '호스트에게 보낼 첫인사 메시지를 남겨주세요',
                  child: Padding(
                    padding: const EdgeInsets.all(OomuTokens.pagePadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const OomuInfoRow(
                          icon: Icons.info_outline_rounded,
                          label: '안내',
                          value: '모임장이 승인하면 단체 채팅방에 초대됩니다.',
                        ),
                        const SizedBox(height: OomuTokens.s16),
                        OomuButton(
                          label: '신청서 전송하기',
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: OomuTokens.s32),
        ],
      ),
    );
  }
}

