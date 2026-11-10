import 'package:flutter/material.dart';

import '../../ui/oomu_badge.dart';
import '../../ui/oomu_chip.dart';
import '../../ui/oomu_tokens.dart';
import '../../utils/app_image.dart';
import '../event_detail_screen.dart';

/// 홈 화면 트렌드 공연·전시 및 동네 발견 큐레이션 섹션
class HomeDiscoverySection extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String currentLocation;
  final VoidCallback onShowAllBottomSheet;

  const HomeDiscoverySection({
    super.key,
    required this.items,
    required this.currentLocation,
    required this.onShowAllBottomSheet,
  });

  @override
  State<HomeDiscoverySection> createState() => _HomeDiscoverySectionState();
}

class _HomeDiscoverySectionState extends State<HomeDiscoverySection> {
  String _selectedCategory = '전체';
  int _currentPageIndex = 0;
  bool _isExpanded = false;
  late final PageController _pageController;

  static const List<String> _trendCategories = [
    '전체',
    '우리동네',
    '콘서트',
    '뮤지컬',
    '페스티벌',
    '스포츠',
    '영화',
    '핫플·팝업',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _matchesFilter(Map<String, dynamic> item, String filter) {
    if (filter == '전체') return true;
    final cat = (item['category'] ?? '').toString();
    final tag = (item['tag'] ?? '').toString();
    final title = (item['title'] ?? '').toString();
    final loc = (item['location'] ?? '').toString();

    if (filter == '우리동네') {
      return item['isSuggested'] == true ||
          loc.contains('마포') ||
          loc.contains('망원') ||
          loc.contains('여수') ||
          loc.contains(widget.currentLocation.split(' ').first);
    }
    if (filter == '콘서트') return cat.contains('공연') || tag.contains('콘서트');
    if (filter == '뮤지컬') return cat.contains('뮤지컬') || tag.contains('뮤지컬');
    if (filter == '페스티벌') return cat.contains('페스티벌') || tag.contains('페스티벌');
    if (filter == '스포츠') {
      return cat.contains('스포츠') ||
          title.contains('야구') ||
          title.contains('축구') ||
          title.contains('KBO');
    }
    if (filter == '영화') {
      return cat.contains('영화') ||
          cat.contains('CGV') ||
          title.contains('영화');
    }
    if (filter == '핫플·팝업') {
      return cat.contains('팝업') ||
          cat.contains('전시') ||
          tag.contains('핫플') ||
          tag.contains('SNS');
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final filteredItems = widget.items
        .where((it) => _matchesFilter(it, _selectedCategory))
        .toList();

    final int totalPages = (filteredItems.length / 2).ceil().clamp(1, 99);
    final int safePage = _currentPageIndex.clamp(0, totalPages - 1);
    final int expandedRowCount = (filteredItems.length / 2).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 헤더 (공연·전시와 동네 발견 + 전체보기)
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '공연·전시와 동네 발견',
                      style: TextStyle(
                        fontSize: OomuTokens.fontBase,
                        fontWeight: OomuTokens.weightBold,
                        color: OomuTokens.textPrimary,
                        fontFamily: OomuTokens.fontFamily,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      '동네 문화 행사와 핫플을 가볍게 둘러보세요.',
                      style: TextStyle(
                        fontSize: OomuTokens.fontXs,
                        color: OomuTokens.textSecondary,
                        fontFamily: OomuTokens.fontFamily,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: OomuTokens.spacingSm),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onShowAllBottomSheet,
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: OomuTokens.spacingSm,
                    vertical: OomuTokens.spacingXs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '전체보기',
                        style: TextStyle(
                          fontSize: OomuTokens.fontXs,
                          fontWeight: OomuTokens.weightBold,
                          color: OomuTokens.textSecondary,
                          fontFamily: OomuTokens.fontFamily,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: OomuTokens.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. 카테고리 칩 필터 바
        Padding(
          padding: const EdgeInsets.only(bottom: OomuTokens.spacingSm),
          child: SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: OomuTokens.spacingLg),
              itemCount: _trendCategories.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: OomuTokens.spacingSm),
              itemBuilder: (context, idx) {
                final cat = _trendCategories[idx];
                final isSel = _selectedCategory == cat;
                return Center(
                  child: OomuChip(
                    label: cat,
                    isSelected: isSel,
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                        _currentPageIndex = 0;
                        _isExpanded = false;
                      });
                      if (_pageController.hasClients) {
                        _pageController.jumpToPage(0);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ),

        // 3. 카드 목록 (기본: PageView 2열 카드 / 펼침: 2열 그리드)
        if (!_isExpanded) ...[
          SizedBox(
            height: 290,
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalPages,
              onPageChanged: (p) => setState(() => _currentPageIndex = p),
              itemBuilder: (context, pageIdx) {
                final int sIdx = pageIdx * 2;
                final lItem =
                    sIdx < filteredItems.length ? filteredItems[sIdx] : null;
                final rItem = (sIdx + 1) < filteredItems.length
                    ? filteredItems[sIdx + 1]
                    : null;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: OomuTokens.spacingLg),
                  child: Row(
                    children: [
                      Expanded(
                        child: lItem != null
                            ? _buildCard(context, lItem)
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(width: OomuTokens.spacingSm),
                      Expanded(
                        child: rItem != null
                            ? _buildCard(context, rItem)
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.only(top: OomuTokens.spacingSm),
              child: Center(
                child: Text(
                  '${safePage + 1} / $totalPages',
                  style: const TextStyle(
                    fontSize: OomuTokens.fontXs,
                    color: OomuTokens.textSecondary,
                    fontFamily: OomuTokens.fontFamily,
                  ),
                ),
              ),
            ),
        ] else ...[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: OomuTokens.spacingLg),
            child: Column(
              children: List.generate(expandedRowCount, (rowIdx) {
                final int sIdx = rowIdx * 2;
                final lItem =
                    sIdx < filteredItems.length ? filteredItems[sIdx] : null;
                final rItem = (sIdx + 1) < filteredItems.length
                    ? filteredItems[sIdx + 1]
                    : null;
                return Padding(
                  padding: const EdgeInsets.only(bottom: OomuTokens.spacingSm),
                  child: Row(
                    children: [
                      Expanded(
                        child: lItem != null
                            ? _buildCard(context, lItem)
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(width: OomuTokens.spacingSm),
                      Expanded(
                        child: rItem != null
                            ? _buildCard(context, rItem)
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],

        // 4. 더보기 버튼
        if (filteredItems.length > 2)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              OomuTokens.spacingLg,
              OomuTokens.spacingSm,
              OomuTokens.spacingLg,
              0,
            ),
            child: InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(OomuTokens.radiusCardSm),
              child: Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: OomuTokens.surface,
                  borderRadius: BorderRadius.circular(OomuTokens.radiusCardSm),
                  border: Border.all(color: OomuTokens.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isExpanded ? '트렌드 접기' : '트렌드 더보기',
                      style: const TextStyle(
                        fontSize: OomuTokens.fontSm,
                        fontWeight: OomuTokens.weightBold,
                        color: OomuTokens.textBody,
                        fontFamily: OomuTokens.fontFamily,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isExpanded
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
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> item) {
    final title = (item['title'] ?? '').toString();
    final poster = (item['poster'] ?? '').toString();
    final location = (item['location'] ?? '').toString();
    final period = (item['period'] ?? '').toString();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailScreen(event: item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: OomuTokens.surface,
          borderRadius: BorderRadius.circular(OomuTokens.radiusCard),
          border: Border.all(color: OomuTokens.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(OomuTokens.radiusCard - 1),
              ),
              child: Stack(
                children: [
                  Image(
                    image: appImg(poster),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: OomuTokens.surfaceMuted,
                      child: const Center(
                        child: Icon(Icons.image_outlined,
                            color: OomuTokens.textMuted),
                      ),
                    ),
                  ),
                  if (item['rank'] != null && (item['rank'] as num) <= 3)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: OomuBadge.coral(label: 'TOP ${item['rank']}'),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(OomuTokens.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: OomuTokens.fontSm,
                      fontWeight: OomuTokens.weightBold,
                      color: OomuTokens.textPrimary,
                      fontFamily: OomuTokens.fontFamily,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: OomuTokens.spacingXs),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: OomuTokens.fontXs,
                      color: OomuTokens.textSecondary,
                      fontFamily: OomuTokens.fontFamily,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    period,
                    style: TextStyle(
                      fontSize: OomuTokens.fs11,
                      color: OomuTokens.textMuted,
                      fontFamily: OomuTokens.fontFamily,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

