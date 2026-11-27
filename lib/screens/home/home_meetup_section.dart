import 'package:flutter/material.dart';

import '../../ui/oomu_empty_state.dart';
import '../../ui/oomu_meetup_card.dart';
import '../../ui/oomu_skeleton.dart';
import '../../ui/oomu_tokens.dart';
import '../../utils/global_data.dart';
import '../../utils/meetup_member_helper.dart';
import '../../utils/oomu_ui_helpers.dart';

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
    final visibleMeetups = meetups.where((m) {
      final title = (m['title'] ?? '').toString();
      if (title.contains('[QA테스트]') ||
          title.contains('테스트 모임') ||
          title.contains('[테스트]')) {
        return false;
      }
      final hostUid =
          (m['hostId'] ?? m['hostUid'] ?? m['userId'] ?? '').toString();
      final hostName = (m['host'] ?? m['hostName'] ?? '').toString();
      if (globalData.isTargetBlocked(uid: hostUid, nickname: hostName)) {
        return false;
      }
      final loc = (m['location'] ?? '').toString();
      return OomuUiHelpers.matchesRegionFilter(currentLocation, loc);
    }).toList();

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
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
            padding:
                const EdgeInsets.symmetric(horizontal: OomuTokens.spacingLg),
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
        else if (visibleMeetups.isEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 180),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: OomuTokens.spacingLg,
                vertical: OomuTokens.spacingXl,
              ),
              child: OomuEmptyState(
                icon: Icons.search_off_rounded,
                title: (selectedCategoryIndex == 0 &&
                        (selectedSubCategory == '전체' ||
                            selectedSubCategory.isEmpty) &&
                        (selectedVibe == null || selectedVibe == '전체'))
                    ? '아직 등록된 모임이 없어요'
                    : '조건에 맞는 모임이 없어요',
                subtitle: (selectedCategoryIndex == 0 &&
                        (selectedSubCategory == '전체' ||
                            selectedSubCategory.isEmpty) &&
                        (selectedVibe == null || selectedVibe == '전체'))
                    ? '우리 동네 첫 번째 모임을 직접 열어보세요!'
                    : '필터를 재설정하거나 새로운 모임을 직접 열어보세요.',
                buttonLabel: (selectedCategoryIndex == 0 &&
                        (selectedSubCategory == '전체' ||
                            selectedSubCategory.isEmpty) &&
                        (selectedVibe == null || selectedVibe == '전체'))
                    ? '모임 열기'
                    : '필터 초기화',
                onButtonPressed: () {
                  if (selectedCategoryIndex == 0 &&
                      (selectedSubCategory == '전체' ||
                          selectedSubCategory.isEmpty) &&
                      (selectedVibe == null || selectedVibe == '전체')) {
                    Navigator.pushNamed(context, '/host');
                  } else {
                    onResetFilters();
                  }
                },
              ),
            ),
          )
        else
          Column(
            children: [
              ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: OomuTokens.spacingLg),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: showAllMeetups
                    ? visibleMeetups.length
                    : visibleMeetups.length.clamp(0, initialCount),
                itemBuilder: (context, index) {
                  final data = visibleMeetups[index];
                  final isBlock = !isListView && index == 0;

                  final String title = OomuUiHelpers.formatTitle(
                      (data['title'] ?? '').toString());
                  final String? imageUrl = (data['imageUrl'] ??
                          (data['photos'] is List &&
                                  (data['photos'] as List).isNotEmpty
                              ? data['photos'][0]
                              : null))
                      ?.toString();
                  final String? date =
                      (data['date'] ?? data['time'])?.toString();
                  final String? location = data['location']?.toString();
                  final String? category =
                      (data['category'] ?? data['mainCategory'])?.toString();
                  final String? hostName = data['host']?.toString();
                  final String? hostAvatar = data['hostAvatar']?.toString();
                  final String members =
                      MeetupMemberHelper.formatMembersLabel(data);

                  String? statusBadge;
                  final cap = MeetupMemberHelper.parseCapacity(data);
                  final att = MeetupMemberHelper.parseAttendance(data);
                  final isClosed = MeetupMemberHelper.isClosed(data);
                  if (cap > 0 && att < cap) {
                    // 대표님 지시(Item 04): 2/4명이면 잔여석이 있으므로 정상 '모집중' 표시
                    statusBadge = '모집중';
                  } else if (isClosed) {
                    final isFull = att >= cap;
                    statusBadge = isFull ? '인원 마감' : '모집 마감';
                  } else {
                    statusBadge = '모집중';
                  }

                  final double? mannerTemp =
                      OomuUiHelpers.parseMannerTemp(data);
                  final String? ageLimit = data['ageLimit']?.toString();

                  String? infoBadge;
                  final distance = data['distance']?.toString();
                  if (distance != null && distance.isNotEmpty) {
                    infoBadge = distance;
                  }

                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: OomuTokens.spacingMd),
                    child: isBlock
                        ? OomuMeetupCard(
                            title: title,
                            imageUrl: imageUrl,
                            date: date,
                            location: location,
                            category: category,
                            hostName: hostName,
                            hostAvatar: hostAvatar,
                            mannerTemp: mannerTemp,
                            ageLimit: ageLimit,
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
                            mannerTemp: mannerTemp,
                            ageLimit: ageLimit,
                            members: members,
                            statusBadge: statusBadge,
                            infoBadge: infoBadge,
                            onTap: () => onMeetupTap(data),
                          ),
                  );
                },
              ),

              // 더보기 버튼 (13년차 시니어 디자이너 표준: 정갈한 화이트 표면 + 1px 초미세 보더)
              if (visibleMeetups.length > initialCount)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    OomuTokens.spacingLg,
                    0,
                    OomuTokens.spacingLg,
                    OomuTokens.spacingMd,
                  ),
                  child: InkWell(
                    onTap: onToggleShowAll,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        minHeight: 44,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: OomuTokens.spacingMd,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFE5E7EB), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            showAllMeetups
                                ? '모임 목록 접기'
                                : '동네 모임 더보기 (+${visibleMeetups.length - initialCount}개)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF262626),
                              fontFamily: 'Pretendard',
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            showAllMeetups
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: const Color(0xFF8E8E93),
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
