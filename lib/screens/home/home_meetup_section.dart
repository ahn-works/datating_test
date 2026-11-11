import 'package:flutter/material.dart';

import '../../ui/oomu_empty_state.dart';
import '../../ui/oomu_meetup_card.dart';
import '../../ui/oomu_skeleton.dart';
import '../../ui/oomu_tokens.dart';

/// 홈 화면 메인 모임 피드 섹션 컴포넌트
class HomeMeetupSection extends StatelessWidget {
  final String currentLocation;
  final int selectedCategoryIndex;
  final String selectedSubCategory;
  final String? selectedVibe;
  final bool isListView;
  final bool isLoading;
  final List<Map<String, dynamic>> meetups;
  final bool showAllMeetups;
  final int initialCount;
  final ValueChanged<bool> onToggleView;
  final VoidCallback onToggleShowAll;
  final ValueChanged<Map<String, dynamic>> onMeetupTap;
  final VoidCallback onResetFilters;

  const HomeMeetupSection({
    super.key,
    required this.currentLocation,
    required this.selectedCategoryIndex,
    required this.selectedSubCategory,
    this.selectedVibe,
    required this.isListView,
    required this.isLoading,
    required this.meetups,
    required this.showAllMeetups,
    this.initialCount = 4,
    required this.onToggleView,
    required this.onToggleShowAll,
    required this.onMeetupTap,
    required this.onResetFilters,
  });

  String _getDongName() {
    final parts = currentLocation.trim().split(' ');
    if (parts.length >= 2) {
      return parts.last;
    }
    return parts.first;
  }

  String _getSectionTitle() {
    switch (selectedCategoryIndex) {
      case 1:
        return '오늘 바로 만나는 번개';
      case 2:
        return '이번 주말 취향 아지트';
      case 3:
        return '동네 카페·디저트 투어';
      case 4:
        return '동네 러닝 & 피트니스';
      case 5:
        return '동네 맛집 & 소셜 다이닝';
      default:
        return '이번 주 우리 동네 모임';
    }
  }

  String _getSectionSubtitle() {
    if (selectedVibe != null) {
      return '\'$selectedVibe\' 필터링 중';
    }
    if (selectedCategoryIndex > 0) {
      if (selectedSubCategory != '전체') {
        return '#$selectedSubCategory 모임';
      }
      return selectedCategoryIndex == 1
          ? '오늘 바로 만나는 우리 동네 번개'
          : '취향이 통하는 이웃과 만나는 모임';
    }
    return selectedSubCategory != '전체'
        ? '#$selectedSubCategory 모임'
        : '가까운 이웃과 편하게 만나는 동네 모임';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 헤더 (동 이름 일치 타이틀 + 블럭/목록 뷰 전환 토글)
        Padding(
          padding: const EdgeInsets.only(
            left: OomuTokens.spacingLg,
            right: OomuTokens.spacingLg,
            top: OomuTokens.spacingMd,
            bottom: OomuTokens.spacingSm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getSectionTitle(),
                      style: const TextStyle(
                        fontSize: OomuTokens.fs20,
                        fontWeight: OomuTokens.weightBold,
                        color: OomuTokens.textPrimary,
                        fontFamily: OomuTokens.fontFamily,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getSectionSubtitle(),
                      style: const TextStyle(
                        fontSize: OomuTokens.fontSm,
                        color: OomuTokens.textSecondary,
                        fontFamily: OomuTokens.fontFamily,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: OomuTokens.spacingSm),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    '최신순',
                    style: TextStyle(
                      fontSize: OomuTokens.fs13,
                      color: OomuTokens.textMuted,
                      fontFamily: OomuTokens.fontFamily,
                      fontWeight: OomuTokens.w500,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: OomuTokens.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. 모임 본문 피드 (로딩 / 빈 상태 / 카드 목록)
        if (isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: OomuTokens.spacingLg),
            child: Column(
              children: List.generate(
                3,
                (_) => const Padding(
                  padding: EdgeInsets.only(bottom: OomuTokens.spacingMd),
                  child: OomuMeetupCardSkeleton(),
                ),
              ),
            ),
          )
        else if (meetups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: OomuTokens.spacingLg,
              vertical: OomuTokens.spacingXl,
            ),
            child: OomuEmptyState(
              icon: Icons.search_off_rounded,
              title: '조건에 맞는 모임이 없어요',
              subtitle: '필터를 재설정하거나 새로운 모임을 직접 열어보세요.',
              buttonLabel: '필터 초기화',
              onButtonPressed: onResetFilters,
            ),
          )
        else
          Column(
            children: [
              ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: OomuTokens.spacingLg),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: showAllMeetups
                    ? meetups.length
                    : meetups.length.clamp(0, initialCount),
                itemBuilder: (context, index) {
                  final data = meetups[index];
                  final isBlock = !isListView && index == 0;

                  final String title = (data['title'] ?? '').toString();
                  final String? imageUrl = (data['imageUrl'] ??
                          (data['photos'] is List &&
                                  (data['photos'] as List).isNotEmpty
                              ? data['photos'][0]
                              : null))
                      ?.toString();
                  final String? date = (data['date'] ?? data['time'])?.toString();
                  final String? location = data['location']?.toString();
                  final String? category =
                      (data['category'] ?? data['mainCategory'])?.toString();
                  final String? hostName = data['host']?.toString();
                  final String? hostAvatar = data['hostAvatar']?.toString();
                  final String? members = (data['members'] ?? '2/4')?.toString();

                  String? statusBadge;
                  if (data['isFemaleOnly'] == true) {
                    statusBadge = '여성 전용';
                  } else if (data['isLightning'] == true ||
                      (data['tags'] is List &&
                          (data['tags'] as List).contains('오늘번개'))) {
                    statusBadge = '오늘 번개';
                  }

                  String? infoBadge;
                  final distance = data['distance']?.toString();
                  if (distance != null && distance.isNotEmpty) {
                    infoBadge = distance;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: OomuTokens.spacingMd),
                    child: isBlock
                        ? OomuMeetupCard(
                            title: title,
                            imageUrl: imageUrl,
                            date: date,
                            location: location,
                            category: category,
                            hostName: hostName,
                            hostAvatar: hostAvatar,
                            members: members,
                            statusBadge: statusBadge,
                            infoBadge: infoBadge,
                            onTap: () => onMeetupTap(data),
                          )
                        : OomuMeetupCard.list(
                            title: title,
                            imageUrl: imageUrl,
                            date: date,
                            location: location,
                            category: category,
                            hostName: hostName,
                            hostAvatar: hostAvatar,
                            members: members,
                            statusBadge: statusBadge,
                            infoBadge: infoBadge,
                            onTap: () => onMeetupTap(data),
                          ),
                  );
                },
              ),

              // 더보기 버튼
              if (meetups.length > initialCount)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    OomuTokens.spacingLg,
                    0,
                    OomuTokens.spacingLg,
                    OomuTokens.spacingMd,
                  ),
                  child: InkWell(
                    onTap: onToggleShowAll,
                    borderRadius: BorderRadius.circular(OomuTokens.radiusCardSm),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        minHeight: OomuTokens.touchTargetMin,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: OomuTokens.spacingMd,
                        vertical: OomuTokens.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        color: OomuTokens.surfaceMuted,
                        borderRadius:
                            BorderRadius.circular(OomuTokens.radiusCardSm),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              showAllMeetups
                                  ? '모임 목록 접기'
                                  : '동네 모임 더보기 (+${meetups.length - initialCount}개)',
                              style: const TextStyle(
                                fontSize: OomuTokens.fontSm,
                                fontWeight: OomuTokens.weightBold,
                                color: OomuTokens.textBody,
                                fontFamily: OomuTokens.fontFamily,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            showAllMeetups
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: OomuTokens.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
