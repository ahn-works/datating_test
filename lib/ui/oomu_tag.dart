import 'package:flutter/material.dart';

import 'oomu_tokens.dart';

/// OOMU 중립 라벨/태그 컴포넌트
/// - 성향·관심사·카테고리 서브태그 등에 일관되게 사용되는 무채색 태그
/// - #F2F4F7 배경 + #6B7684 텍스트
class OomuTag extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isPill;

  const OomuTag({
    super.key,
    required this.label,
    this.icon,
    this.isPill = false,
  });

  const OomuTag.pill({
    super.key,
    required this.label,
    this.icon,
  }) : isPill = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OomuTokens.s8,
        vertical: OomuTokens.s4,
      ),
      decoration: BoxDecoration(
        color: OomuTokens.surfaceMuted,
        borderRadius: BorderRadius.circular(
          isPill ? OomuTokens.rPill : OomuTokens.r8,
        ),
        border: Border.all(color: OomuTokens.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: OomuTokens.textSecondary),
            const SizedBox(width: OomuTokens.s4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: OomuTokens.fontFamily,
                fontFamilyFallback: OomuTokens.fontFallback,
                fontSize: OomuTokens.fs11,
                fontWeight: OomuTokens.w600,
                color: OomuTokens.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

