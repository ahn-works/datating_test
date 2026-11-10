import 'package:flutter/material.dart';

import '../../ui/oomu_badge.dart';
import '../../ui/oomu_tokens.dart';
import '../../utils/app_image.dart';
import '../../utils/oomu_ui_helpers.dart';
import '../soso_spot_screen.dart';

/// 홈 화면 실시간 오늘 번개 캐러셀 컴포넌트
class HomeLightningSection extends StatelessWidget {
  final List<Map<String, dynamic>> spots;
  final ValueChanged<Map<String, dynamic>> onSpotTap;

  const HomeLightningSection({
    super.key,
    required this.spots,
    required this.onSpotTap,
  });

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 섹션 헤더
        Padding(
          padding: const EdgeInsets.only(
            left: OomuTokens.spacingLg,
            right: OomuTokens.spacingLg,
            top: OomuTokens.spacingMd,
            bottom: OomuTokens.spacingSm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        OomuBadge.coral(label: '오늘 번개'),
                        SizedBox(width: OomuTokens.spacingSm),
                        Expanded(
                          child: Text(
                            '지금 내 주변 즉시 번개',
                            style: TextStyle(
                              fontSize: OomuTokens.fontBase,
                              fontWeight: OomuTokens.weightBold,
                              color: OomuTokens.textPrimary,
                              fontFamily: OomuTokens.fontFamily,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: OomuTokens.spacingXs),
                    Text(
                      '10~30분 내 바로 합류할 수 있는 동네 즉석 팟',
                      style: TextStyle(
                        fontSize: OomuTokens.fontXs,
                        color: OomuTokens.textSecondary,
                        fontFamily: OomuTokens.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: OomuTokens.spacingSm),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SoSoSpotScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OomuTokens.spacingSm,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: OomuTokens.surfaceMuted,
                    borderRadius: BorderRadius.circular(OomuTokens.radiusPill),
                    border: Border.all(color: OomuTokens.border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '전체 지도',
                        style: TextStyle(
                          fontSize: OomuTokens.fontXs,
                          fontWeight: OomuTokens.weightSemiBold,
                          color: OomuTokens.textBody,
                          fontFamily: OomuTokens.fontFamily,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 14,
                        color: OomuTokens.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. 가로 스크롤 카드 리스트
        LayoutBuilder(
          builder: (context, constraints) {
            final double cardWidth =
                ((constraints.maxWidth - 52) / 2).clamp(150.0, 260.0);
            return SizedBox(
              height: 184,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: OomuTokens.spacingLg),
                scrollDirection: Axis.horizontal,
                itemCount: spots.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: OomuTokens.spacingSm),
                itemBuilder: (context, index) {
                  final spot = spots[index];
                  final timeLeft = (spot['timeLeft'] ?? '오늘 번개').toString();
                  final distance = (spot['distance'] ?? '동네 모임').toString();

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSpotTap(spot),
                    child: Container(
                      width: cardWidth,
                      decoration: BoxDecoration(
                        color: OomuTokens.surface,
                        borderRadius:
                            BorderRadius.circular(OomuTokens.radiusCard),
                        border: Border.all(color: OomuTokens.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 썸네일 + 배지 최대 2개 (좌상단 상태, 우상단 거리)
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(OomuTokens.radiusCard - 1),
                                ),
                                child: Image(
                                  image: appImg(spot['image']),
                                  width: cardWidth,
                                  height: 84,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: cardWidth,
                                    height: 84,
                                    color: OomuTokens.surfaceMuted,
                                    child: const Icon(
                                      Icons.image_outlined,
                                      color: OomuTokens.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: OomuBadge.coral(label: timeLeft),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: OomuBadge.dark(label: distance),
                              ),
                            ],
                          ),
                          // 카드 본문
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(OomuTokens.spacingSm),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    OomuUiHelpers.formatTitle(spot['title']),
                                    style: const TextStyle(
                                      fontSize: OomuTokens.fontSm,
                                      fontWeight: OomuTokens.weightSemiBold,
                                      color: OomuTokens.textPrimary,
                                      fontFamily: OomuTokens.fontFamily,
                                      height: 1.25,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 9,
                                              backgroundImage:
                                                  appImg(spot['hostAvatar']),
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                spot['host']?.toString() ?? '',
                                                style: const TextStyle(
                                                  fontSize: OomuTokens.fontXs,
                                                  color: OomuTokens.textSecondary,
                                                  fontFamily:
                                                      OomuTokens.fontFamily,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: OomuTokens.surfaceMuted,
                                          borderRadius: BorderRadius.circular(
                                              OomuTokens.radiusPill),
                                        ),
                                        child: Text(
                                          '${spot['members'] ?? '2/4'} 참여',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight:
                                                OomuTokens.weightSemiBold,
                                            color: OomuTokens.textBody,
                                            fontFamily: OomuTokens.fontFamily,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

