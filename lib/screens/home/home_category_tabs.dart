import 'package:flutter/material.dart';

import '../../ui/oomu_chip.dart';
import '../../ui/oomu_tokens.dart';
import '../../widgets/bouncy_tap.dart';

/// 홈 화면 카테고리 탭 & 서브태그 트레이 컴포넌트
class HomeCategoryTabs extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final int selectedCategoryIndex;
  final String selectedSubCategory;
  final String? selectedVibe;
  final bool isSubCategoryExpanded;
  final ValueChanged<int> onCategorySelected;
  final ValueChanged<String> onSubCategorySelected;
  final VoidCallback onResetFilters;
  final VoidCallback onToggleSubCategoryExpanded;
  final VoidCallback onClearVibe;
  final VoidCallback onShowFullCategories;
  final Map<String, List<String>> officialSubCategories;

  const HomeCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedCategoryIndex,
    required this.selectedSubCategory,
    this.selectedVibe,
    required this.isSubCategoryExpanded,
    required this.onCategorySelected,
    required this.onSubCategorySelected,
    required this.onResetFilters,
    required this.onToggleSubCategoryExpanded,
    required this.onClearVibe,
    required this.onShowFullCategories,
    required this.officialSubCategories,
  });

  IconData _getCategoryIcon(int index) {
    switch (index) {
      case 0:
        return Icons.whatshot_rounded;
      case 1:
        return Icons.bolt_rounded;
      case 2:
        return Icons.local_cafe_rounded;
      case 3:
        return Icons.directions_run_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 카테고리 탭 (가로 스크롤) + '전체보기' 버튼
        Padding(
          padding: const EdgeInsets.only(
            top: OomuTokens.spacingMd,
            bottom: OomuTokens.spacingSm,
            left: OomuTokens.spacingLg,
            right: OomuTokens.spacingLg,
          ),
          child: SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == categories.length) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: OomuTokens.spacingSm),
                      child: OomuChip(
                        label: '전체보기',
                        isSelected: false,
                        onTap: onShowFullCategories,
                      ),
                    ),
                  );
                }

                final isSelected = selectedCategoryIndex == index;
                final catName = categories[index]['name'] as String;

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: OomuTokens.spacingSm),
                    child: OomuChip(
                      label: catName,
                      isSelected: isSelected,
                      onTap: () {
                        if (index == 0) {
                          onResetFilters();
                        } else {
                          onCategorySelected(index);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // 2. 분위기 필터 칩 (활성화 시)
        if (selectedVibe != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: OomuTokens.spacingLg,
              vertical: OomuTokens.spacingXs,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: OomuTokens.spacingMd,
                vertical: OomuTokens.spacingSm,
              ),
              decoration: BoxDecoration(
                color: OomuTokens.surfaceMuted,
                borderRadius: BorderRadius.circular(OomuTokens.radiusCardSm),
                border: Border.all(color: OomuTokens.border),
              ),
              child: Row(
                children: [
                  Text(
                    '\'$selectedVibe\' 분위기 모임 필터링 중',
                    style: const TextStyle(
                      fontWeight: OomuTokens.weightBold,
                      color: OomuTokens.coralText,
                      fontSize: OomuTokens.fontSm,
                      fontFamily: OomuTokens.fontFamily,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onClearVibe,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close, size: 14, color: OomuTokens.coral),
                        SizedBox(width: 2),
                        Text(
                          '필터 해제',
                          style: TextStyle(
                            fontSize: OomuTokens.fontXs,
                            fontWeight: OomuTokens.weightBold,
                            color: OomuTokens.coralText,
                            fontFamily: OomuTokens.fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 3. 서브태그 트레이 (특정 카테고리 진입 시에만 한 줄로 깔끔하게 표시)
        if (selectedCategoryIndex > 0) _buildSubCategoryBar(context),
      ],
    );
  }

  Widget _buildSubCategoryBar(BuildContext context) {
    final mainCatName = categories[selectedCategoryIndex]['name'] as String;
    final List<String> subList = [
      '전체',
      ...(officialSubCategories[mainCatName] ?? [])
    ];

    return Padding(
      padding: const EdgeInsets.only(
        bottom: OomuTokens.spacingSm,
        left: OomuTokens.spacingLg,
        right: OomuTokens.spacingLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSubCategoryExpanded)
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  // 스크롤 가능한 서브태그 칩 목록 (오른쪽 버튼과 겹침 없는 안전 영역 확보)
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(right: OomuTokens.spacingSm),
                      itemCount: subList.length,
                      itemBuilder: (context, idx) {
                        final subName = subList[idx];
                        final isSubSelected = selectedSubCategory == subName;
                        final displayLabel =
                            subName == '전체' ? '전체' : '#$subName';

                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: OomuTokens.spacingSm),
                            child: OomuChip(
                              label: displayLabel,
                              isSelected: isSubSelected,
                              onTap: () => onSubCategorySelected(subName),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: OomuTokens.spacingXs),
                  // 우측 고정 '+더보기' 버튼 (최소 48dp 터치 영역 보장)
                  BouncyTap(
                    scaleDown: 0.94,
                    onTap: onToggleSubCategoryExpanded,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: OomuTokens.touchTargetMin,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: OomuTokens.spacingSm,
                          vertical: OomuTokens.spacingSm,
                        ),
                        decoration: BoxDecoration(
                          color: OomuTokens.surfaceMuted,
                          borderRadius:
                              BorderRadius.circular(OomuTokens.radiusCardSm),
                          border: Border.all(color: OomuTokens.border),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '+더보기',
                              style: TextStyle(
                                fontSize: OomuTokens.fontXs,
                                fontWeight: OomuTokens.weightBold,
                                color: OomuTokens.textBody,
                                fontFamily: OomuTokens.fontFamily,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 14,
                              color: OomuTokens.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(OomuTokens.spacingMd),
              decoration: BoxDecoration(
                color: OomuTokens.surface,
                borderRadius: BorderRadius.circular(OomuTokens.radiusCard),
                border: Border.all(color: OomuTokens.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$mainCatName 태그 선택',
                        style: const TextStyle(
                          fontSize: OomuTokens.fontSm,
                          fontWeight: OomuTokens.weightBold,
                          color: OomuTokens.textPrimary,
                          fontFamily: OomuTokens.fontFamily,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onToggleSubCategoryExpanded,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: OomuTokens.spacingSm,
                            vertical: OomuTokens.spacingXs,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '접기',
                                style: TextStyle(
                                  fontSize: OomuTokens.fontXs,
                                  color: OomuTokens.textSecondary,
                                  fontFamily: OomuTokens.fontFamily,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_up,
                                size: 14,
                                color: OomuTokens.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: OomuTokens.spacingSm),
                  Wrap(
                    spacing: OomuTokens.spacingSm,
                    runSpacing: OomuTokens.spacingSm,
                    children: subList.map((subName) {
                      final isSubSelected = selectedSubCategory == subName;
                      final displayLabel =
                          subName == '전체' ? '전체' : '#$subName';
                      return OomuChip(
                        label: displayLabel,
                        isSelected: isSubSelected,
                        onTap: () {
                          onSubCategorySelected(subName);
                          onToggleSubCategoryExpanded();
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

