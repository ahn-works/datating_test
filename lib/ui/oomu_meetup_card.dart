import 'package:flutter/material.dart';

import 'oomu_avatar.dart';
import 'oomu_badge.dart';
import 'oomu_tokens.dart';

enum OomuMeetupCardVariant {
  block,
  list,
}

/// OOMU 공통 모임 카드 컴포넌트
/// - block / list 두 가지 변형 지원하는 단일 부품
/// - 구성: 사진(16:9, 배지 최대 2개) → 제목(16sp/w600, 최대 2줄 말줄임) → 일정·장소(14sp 보조색, 아이콘) → 호스트 아바타·닉네임·정원(예: 2/4)
/// - 매너온도 칩 및 분위기 이미지 라벨 원천 배제
/// - 그림자 없이 1px #EAECF0 테두리, 모서리 16dp
class OomuMeetupCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String? date;
  final String? location;
  final String? hostName;
  final String? hostAvatar;
  final String? members; // 예: "2/4"
  final String? statusBadge; // 좌상단 배지 (예: "오늘 번개")
  final String? infoBadge; // 우하단 배지 (예: "도보 180m")
  final VoidCallback? onTap;
  final OomuMeetupCardVariant variant;

  const OomuMeetupCard({
    super.key,
    required this.title,
    this.imageUrl,
    this.date,
    this.location,
    this.hostName,
    this.hostAvatar,
    this.members,
    this.statusBadge,
    this.infoBadge,
    this.onTap,
    this.variant = OomuMeetupCardVariant.block,
  });

  const OomuMeetupCard.list({
    super.key,
    required this.title,
    this.imageUrl,
    this.date,
    this.location,
    this.hostName,
    this.hostAvatar,
    this.members,
    this.statusBadge,
    this.infoBadge,
    this.onTap,
  }) : variant = OomuMeetupCardVariant.list;

  Widget _buildImagePlaceholder() {
    return Container(
      color: OomuTokens.surfaceMuted,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 28,
        color: OomuTokens.textMuted,
      ),
    );
  }

  Widget _buildImageContent() {
    final url = imageUrl?.trim() ?? '';
    if (url.isEmpty) {
      return _buildImagePlaceholder();
    }
    final isNetwork = url.startsWith('http://') || url.startsWith('https://');
    return isNetwork
        ? Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
          )
        : Image.asset(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
          );
  }

  @override
  Widget build(BuildContext context) {
    if (variant == OomuMeetupCardVariant.list) {
      return _buildListCard();
    }
    return _buildBlockCard();
  }

  Widget _buildBlockCard() {
    return Material(
      color: OomuTokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OomuTokens.r16),
        side: const BorderSide(color: OomuTokens.border, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(OomuTokens.r16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. 사진 (16:9 비율, 배지 최대 2개)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(OomuTokens.r16),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImageContent(),
                    if (statusBadge != null)
                      Positioned(
                        top: OomuTokens.s8,
                        left: OomuTokens.s8,
                        child: OomuBadge.dark(label: statusBadge!),
                      ),
                    if (infoBadge != null)
                      Positioned(
                        bottom: OomuTokens.s8,
                        right: OomuTokens.s8,
                        child: OomuBadge.dark(label: infoBadge!),
                      ),
                  ],
                ),
              ),
            ),

            // 2. 카드 본문 정보
            Padding(
              padding: const EdgeInsets.all(OomuTokens.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목: 16dp / w600 / 최대 2줄 말줄임
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: OomuTokens.fontFamily,
                      fontFamilyFallback: OomuTokens.fontFallback,
                      fontSize: OomuTokens.fs16,
                      fontWeight: OomuTokens.w600,
                      color: OomuTokens.textPrimary,
                      height: 1.4,
                    ),
                  ),

                  if (date != null || location != null) ...[
                    const SizedBox(height: OomuTokens.s8),
                    // 일정·장소: 14dp 보조색 + 아이콘
                    if (date != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: OomuTokens.textSecondary,
                          ),
                          const SizedBox(width: OomuTokens.s4),
                          Expanded(
                            child: Text(
                              date!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: OomuTokens.fontFamily,
                                fontFamilyFallback: OomuTokens.fontFallback,
                                fontSize: OomuTokens.fs14,
                                fontWeight: OomuTokens.w400,
                                color: OomuTokens.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (location != null) ...[
                      const SizedBox(height: OomuTokens.s4),
                      Row(
                        children: [
                          const Icon(
                            Icons.place_outlined,
                            size: 14,
                            color: OomuTokens.textSecondary,
                          ),
                          const SizedBox(width: OomuTokens.s4),
                          Expanded(
                            child: Text(
                              location!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: OomuTokens.fontFamily,
                                fontFamilyFallback: OomuTokens.fontFallback,
                                fontSize: OomuTokens.fs14,
                                fontWeight: OomuTokens.w400,
                                color: OomuTokens.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],

                  const SizedBox(height: OomuTokens.s12),
                  const Divider(color: OomuTokens.border, height: 1, thickness: 1),
                  const SizedBox(height: OomuTokens.s8),

                  // 호스트 아바타 · 닉네임 · 정원 (매너온도 칩 없음)
                  Row(
                    children: [
                      OomuAvatar.small(
                        imageUrl: hostAvatar,
                        name: hostName,
                      ),
                      const SizedBox(width: OomuTokens.s8),
                      Expanded(
                        child: Text(
                          hostName ?? '호스트',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: OomuTokens.fontFamily,
                            fontFamilyFallback: OomuTokens.fontFallback,
                            fontSize: OomuTokens.fs12,
                            fontWeight: OomuTokens.w600,
                            color: OomuTokens.textPrimary,
                          ),
                        ),
                      ),
                      if (members != null) ...[
                        const SizedBox(width: OomuTokens.s8),
                        Text(
                          '$members 참여',
                          style: const TextStyle(
                            fontFamily: OomuTokens.fontFamily,
                            fontFamilyFallback: OomuTokens.fontFallback,
                            fontSize: OomuTokens.fs12,
                            fontWeight: OomuTokens.w600,
                            color: OomuTokens.textSecondary,
                          ),
                        ),
                      ],
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

  Widget _buildListCard() {
    return Material(
      color: OomuTokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OomuTokens.r16),
        side: const BorderSide(color: OomuTokens.border, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(OomuTokens.r16),
        child: Padding(
          padding: const EdgeInsets.all(OomuTokens.cardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 썸네일 (96x96dp)
              ClipRRect(
                borderRadius: BorderRadius.circular(OomuTokens.r12),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildImageContent(),
                      if (statusBadge != null)
                        Positioned(
                          top: OomuTokens.s4,
                          left: OomuTokens.s4,
                          child: OomuBadge.dark(label: statusBadge!),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: OomuTokens.s12),

              // 정보 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: OomuTokens.fontFamily,
                        fontFamilyFallback: OomuTokens.fontFallback,
                        fontSize: OomuTokens.fs16,
                        fontWeight: OomuTokens.w600,
                        color: OomuTokens.textPrimary,
                        height: 1.35,
                      ),
                    ),
                    if (date != null || location != null) ...[
                      const SizedBox(height: OomuTokens.s4),
                      Text(
                        [if (date != null) date!, if (location != null) location!]
                            .join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: OomuTokens.fontFamily,
                          fontFamilyFallback: OomuTokens.fontFallback,
                          fontSize: OomuTokens.fs14,
                          fontWeight: OomuTokens.w400,
                          color: OomuTokens.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: OomuTokens.s8),
                    Row(
                      children: [
                        OomuAvatar.small(
                          imageUrl: hostAvatar,
                          name: hostName,
                        ),
                        const SizedBox(width: OomuTokens.s8),
                        Expanded(
                          child: Text(
                            hostName ?? '호스트',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: OomuTokens.fontFamily,
                              fontFamilyFallback: OomuTokens.fontFallback,
                              fontSize: OomuTokens.fs12,
                              fontWeight: OomuTokens.w600,
                              color: OomuTokens.textPrimary,
                            ),
                          ),
                        ),
                        if (members != null) ...[
                          const SizedBox(width: OomuTokens.s4),
                          Flexible(
                            child: Text(
                              '$members 참여',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: OomuTokens.fontFamily,
                                fontFamilyFallback: OomuTokens.fontFallback,
                                fontSize: OomuTokens.fs12,
                                fontWeight: OomuTokens.w600,
                                color: OomuTokens.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

