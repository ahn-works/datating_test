import 'package:flutter/material.dart';

import 'oomu_tokens.dart';

enum OomuBadgeVariant {
  dark, // 사진 위 가독성용 반투명 딥차콜
  coral, // 핵심 상태용 코랄 단색
  neutral, // 정보 전달용 쿨그레이
}

/// OOMU 이미지 오버레이 및 상태 배지 컴포넌트
/// - 카드/사진 위 최대 2개까지 배치
class OomuBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final OomuBadgeVariant variant;

  const OomuBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = OomuBadgeVariant.dark,
  });

  const OomuBadge.dark({
    super.key,
    required this.label,
    this.icon,
  }) : variant = OomuBadgeVariant.dark;

  const OomuBadge.coral({
    super.key,
    required this.label,
    this.icon,
  }) : variant = OomuBadgeVariant.coral;

  const OomuBadge.neutral({
    super.key,
    required this.label,
    this.icon,
  }) : variant = OomuBadgeVariant.neutral;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Border? border;

    switch (variant) {
      case OomuBadgeVariant.dark:
        bg = OomuTokens.textPrimary.withValues(alpha: 0.88);
        fg = OomuTokens.surface;
        border = null;
        break;
      case OomuBadgeVariant.coral:
        bg = OomuTokens.coral;
        fg = OomuTokens.surface;
        border = null;
        break;
      case OomuBadgeVariant.neutral:
        bg = OomuTokens.surface;
        fg = OomuTokens.textSecondary;
        border = Border.all(color: OomuTokens.border, width: 1);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OomuTokens.s8,
        vertical: OomuTokens.s4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(OomuTokens.r8),
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: OomuTokens.s4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: OomuTokens.fontFamily,
                fontFamilyFallback: OomuTokens.fontFallback,
                fontSize: OomuTokens.fs11,
                fontWeight: OomuTokens.w700,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
