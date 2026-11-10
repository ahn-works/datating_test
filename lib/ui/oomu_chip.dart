import 'package:flutter/material.dart';

import 'oomu_tokens.dart';

/// OOMU 필터/선택 칩 컴포넌트
/// - 시각적 높이 36dp
/// - 최소 터치 영역 48x48dp 보장
class OomuChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final String? count;

  const OomuChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? OomuTokens.textPrimary : OomuTokens.surfaceMuted;
    final fg = isSelected ? OomuTokens.surface : OomuTokens.textSecondary;
    final border = isSelected
        ? Border.all(color: OomuTokens.textPrimary, width: 1)
        : Border.all(color: OomuTokens.border, width: 1);

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: OomuTokens.touchTarget,
        minHeight: OomuTokens.touchTarget,
      ),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(OomuTokens.rPill),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: OomuTokens.s12),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(OomuTokens.rPill),
                border: border,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 14, color: fg),
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
                        fontSize: OomuTokens.fs12,
                        fontWeight: isSelected ? OomuTokens.w700 : OomuTokens.w600,
                        color: fg,
                      ),
                    ),
                  ),
                  if (count != null) ...[
                    const SizedBox(width: OomuTokens.s4),
                    Text(
                      count!,
                      style: TextStyle(
                        fontFamily: OomuTokens.fontFamily,
                        fontFamilyFallback: OomuTokens.fontFallback,
                        fontSize: OomuTokens.fs11,
                        fontWeight: OomuTokens.w600,
                        color: isSelected ? OomuTokens.surface : OomuTokens.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

