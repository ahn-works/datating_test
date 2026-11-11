import 'package:flutter/material.dart';

import 'oomu_avatar.dart';
import 'oomu_tokens.dart';

enum OomuMeetupCardVariant {
  block,
  list,
}

/// OOMU 공통 모임 카드 컴포넌트 ("따뜻한 미니멀")
/// - block / list 두 가지 변형을 지원하는 단일 부품
/// - 구성: 사진(16:10) → 분류·장소(13sp 회색) → 제목(17sp/w600, 최대 2줄) → 일정·거리(13sp)
///   → 호스트 아바타·닉네임·정원 + 우측 상태 라벨
/// - 카드 테두리·그림자·속 박스 없음(사진과 여백만으로 한 덩어리). 코랄은 상태 라벨에만 사용
class OomuMeetupCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String? date;
  final String? location;
  final String? category; // 분류 (예: "러닝·운동")
  final String? hostName;
  final String? hostAvatar;
  final String? members; // 예: "2/4"
  final String? statusBadge; // 우측 상태 라벨 (예: "오늘 번개")
  final String? infoBadge; // 일정 옆 보조 정보 (예: "도보 180m")
  final VoidCallback? onTap;
  final OomuMeetupCardVariant variant;

  const OomuMeetupCard({
    super.key,
    required this.title,
    this.imageUrl,
    this.date,
    this.location,
    this.category,
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
    this.category,
    this.hostName,
    this.hostAvatar,
    this.members,
    this.statusBadge,
    this.infoBadge,
    this.onTap,
  }) : variant = OomuMeetupCardVariant.list;

  static const TextStyle _caption = TextStyle(
    fontFamily: OomuTokens.fontFamily,
    fontFamilyFallback: OomuTokens.fontFallback,
    fontSize: OomuTokens.fs13,
    fontWeight: OomuTokens.w400,
    color: OomuTokens.textMuted,
    height: 1.5,
  );

  static const TextStyle _headline = TextStyle(
    fontFamily: OomuTokens.fontFamily,
    fontFamilyFallback: OomuTokens.fontFallback,
    fontSize: OomuTokens.fs17,
    fontWeight: OomuTokens.w600,
    color: OomuTokens.textPrimary,
    height: 1.4,
    letterSpacing: -0.25,
  );

  Widget _buildImagePlaceholder() {
    return Container(
      color: OomuTokens.surfaceMuted,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 28,
        color: OomuTokens.textTertiary,
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

  /// "분류 · 장소" 한 줄
  String? get _kickerText {
    final parts = <String>[
      if (category != null && category!.trim().isNotEmpty) category!.trim(),
      if (location != null && location!.trim().isNotEmpty) location!.trim(),
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// "일정 · 거리" 한 줄
  String? get _whenText {
    final parts = <String>[
      if (date != null && date!.trim().isNotEmpty) date!.trim(),
      if (infoBadge != null && infoBadge!.trim().isNotEmpty) infoBadge!.trim(),
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  Widget _buildFooter() {
    return Row(
      children: [
        OomuAvatar(imageUrl: hostAvatar, name: hostName, radius: 11),
        const SizedBox(width: OomuTokens.s8),
        Expanded(
          flex: 3,
          child: Text(
            hostName ?? '호스트',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: OomuTokens.fontFamily,
              fontFamilyFallback: OomuTokens.fontFallback,
              fontSize: OomuTokens.fs13,
              fontWeight: OomuTokens.w600,
              color: OomuTokens.textBody,
            ),
          ),
        ),
        if (members != null) ...[
          const SizedBox(width: OomuTokens.s8),
          Flexible(
            flex: 2,
            child: Text(
              '$members 참여',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _caption,
            ),
          ),
        ],
        if (statusBadge != null) ...[
          const SizedBox(width: OomuTokens.s8),
          Flexible(
            flex: 2,
            child: Text(
              statusBadge!,
              maxLines: 1,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: OomuTokens.fontFamily,
                fontFamilyFallback: OomuTokens.fontFallback,
                fontSize: OomuTokens.fs13,
                fontWeight: OomuTokens.w700,
                color: OomuTokens.coralText,
              ),
            ),
          ),
        ],
      ],
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
    final kicker = _kickerText;
    final when = _whenText;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(OomuTokens.radiusCard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(OomuTokens.radiusCard),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: _buildImageContent(),
            ),
          ),
          if (kicker != null) ...[
            const SizedBox(height: OomuTokens.s12),
            Text(kicker,
                maxLines: 1, overflow: TextOverflow.ellipsis, style: _caption),
          ] else
            const SizedBox(height: OomuTokens.s12),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _headline,
            ),
          ),
          if (when != null) ...[
            const SizedBox(height: OomuTokens.s4),
            Text(
              when,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _caption.copyWith(color: OomuTokens.textBody),
            ),
          ],
          const SizedBox(height: OomuTokens.s12),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildListCard() {
    final kicker = _kickerText;
    final when = _whenText;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: OomuTokens.s16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: OomuTokens.border, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (kicker != null) ...[
                    Text(kicker,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _caption),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _headline,
                  ),
                  if (when != null) ...[
                    const SizedBox(height: OomuTokens.s4),
                    Text(
                      when,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _caption.copyWith(color: OomuTokens.textBody),
                    ),
                  ],
                  const SizedBox(height: OomuTokens.s12),
                  _buildFooter(),
                ],
              ),
            ),
            const SizedBox(width: OomuTokens.s16),
            ClipRRect(
              borderRadius: BorderRadius.circular(OomuTokens.radiusCardSm),
              child: SizedBox(
                width: 88,
                height: 88,
                child: _buildImageContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
