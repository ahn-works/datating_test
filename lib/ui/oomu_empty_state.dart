import 'package:flutter/material.dart';

import 'oomu_button.dart';
import 'oomu_tokens.dart';

/// OOMU 공통 빈 상태 및 오류 컴포넌트
/// - "아이콘 + 한 줄 + 버튼 1개" 규칙 준수
class OomuEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  const OomuEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonLabel,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: OomuTokens.pagePadding,
        vertical: OomuTokens.s32,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 44,
              color: OomuTokens.textMuted,
            ),
            const SizedBox(height: OomuTokens.s12),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: OomuTokens.fontFamily,
                fontFamilyFallback: OomuTokens.fontFallback,
                fontSize: OomuTokens.fs16,
                fontWeight: OomuTokens.w700,
                color: OomuTokens.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: OomuTokens.s4),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: OomuTokens.fontFamily,
                  fontFamilyFallback: OomuTokens.fontFallback,
                  fontSize: OomuTokens.fs12,
                  fontWeight: OomuTokens.w400,
                  color: OomuTokens.textSecondary,
                ),
              ),
            ],
            if (buttonLabel != null && onButtonPressed != null) ...[
              const SizedBox(height: OomuTokens.s16),
              OomuButton.secondary(
                label: buttonLabel!,
                onPressed: onButtonPressed,
                size: OomuButtonSize.small,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

