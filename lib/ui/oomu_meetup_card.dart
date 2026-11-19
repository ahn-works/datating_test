import 'package:flutter/material.dart';

import '../utils/app_image.dart';
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
  final double? mannerTemp;
  final String? ageLimit;
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
    this.mannerTemp,
    this.ageLimit,
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
    this.mannerTemp,
    this.ageLimit,
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
    return Image(
      image: appImg(url, fallback: 'assets/images/cover_food.jpg'),
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
    final bool isClosedBadge = statusBadge != null &&
        (statusBadge!.contains('마감') || statusBadge!.contains('종료'));

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OomuAvatar(imageUrl: hostAvatar, name: hostName, radius: 10),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 80),
              child: Text(
                hostName ?? '호스트',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: OomuTokens.fontFamily,
                  fontFamilyFallback: OomuTokens.fontFallback,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: OomuTokens.textBody,
                ),
              ),
            ),
          ],
        ),
        if (mannerTemp != null && mannerTemp! > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFFFD4D8), width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.thermostat_rounded,
                    size: 11, color: OomuTokens.coral),
                const SizedBox(width: 2),
                Text(
                  '${mannerTemp!.toStringAsFixed(1)}°C',
                  style: const TextStyle(
                    fontFamily: OomuTokens.fontFamily,
                    fontFamilyFallback: OomuTokens.fontFallback,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: OomuTokens.coral,
                  ),
                ),
              ],
            ),
          ),
        if (members != null && members!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_outline_rounded,
                    size: 11, color: Color(0xFF6B7280)),
                const SizedBox(width: 3),
                Text(
                  members!.endsWith('명') ? members! : '${members!}명',
                  style: const TextStyle(
                    fontFamily: OomuTokens.fontFamily,
                    fontFamilyFallback: OomuTokens.fontFallback,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
        if (ageLimit != null && ageLimit!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              ageLimit!,
              style: const TextStyle(
                fontFamily: OomuTokens.fontFamily,
                fontFamilyFallback: OomuTokens.fontFallback,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
        if (statusBadge != null && statusBadge!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isClosedBadge
                  ? const Color(0xFFF3F4F6)
                  : const Color(0xFFFFF0F1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isClosedBadge
                    ? const Color(0xFFE5E7EB)
                    : const Color(0xFFFFD4D8),
                width: 0.8,
              ),
            ),
            child: Text(
              statusBadge!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: OomuTokens.fontFamily,
                fontFamilyFallback: OomuTokens.fontFallback,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isClosedBadge
                    ? const Color(0xFF6B7280)
                    : const Color(0xFFFF5A5F),
              ),
            ),
          ),
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
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(OomuTokens.radiusCard),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: _buildImageContent(),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.favorite_border_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ),
              ),
            ],
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
