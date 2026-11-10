import 'package:flutter/material.dart';

import 'oomu_tokens.dart';

/// OOMU 섹션 헤더 컴포넌트
/// - 제목 18dp / w700
/// - 보조 설명 문구 및 우측 액션(더보기 등) 지원
class OomuSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry padding;

  const OomuSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.padding = const EdgeInsets.symmetric(horizontal: OomuTokens.pagePadding),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: OomuTokens.fontFamily,
                    fontFamilyFallback: OomuTokens.fontFallback,
                    fontSize: OomuTokens.fs18,
                    fontWeight: OomuTokens.w700,
                    color: OomuTokens.textPrimary,
                    height: 1.35,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: OomuTokens.s4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontFamily: OomuTokens.fontFamily,
                      fontFamilyFallback: OomuTokens.fontFallback,
                      fontSize: OomuTokens.fs12,
                      fontWeight: OomuTokens.w400,
                      color: OomuTokens.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: OomuTokens.s8),
            action!,
          ],
        ],
      ),
    );
  }
}

