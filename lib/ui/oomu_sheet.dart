import 'package:flutter/material.dart';

import 'oomu_tokens.dart';

/// OOMU 공통 바텀시트 컨테이너
/// - 상단 모서리 24dp
/// - 상단 드래그 핸들 (40x4dp)
/// - 최대 폭 480dp 중앙 정렬 보장
class OomuSheet extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final bool showHandle;

  const OomuSheet({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.trailing,
    this.showHandle = true,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (ctx) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: OomuTokens.appFrameMaxWidth),
          child: builder(ctx),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OomuTokens.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(OomuTokens.r24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHandle) ...[
              const SizedBox(height: OomuTokens.s12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: OomuTokens.border,
                    borderRadius: BorderRadius.circular(OomuTokens.rPill),
                  ),
                ),
              ),
              const SizedBox(height: OomuTokens.s8),
            ],
            if (title != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  OomuTokens.pagePadding,
                  OomuTokens.s8,
                  OomuTokens.pagePadding,
                  OomuTokens.s12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title!,
                            style: const TextStyle(
                              fontFamily: OomuTokens.fontFamily,
                              fontFamilyFallback: OomuTokens.fontFallback,
                              fontSize: OomuTokens.fs18,
                              fontWeight: OomuTokens.w700,
                              color: OomuTokens.textPrimary,
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
                    if (trailing != null) trailing!,
                  ],
                ),
              ),
              const Divider(color: OomuTokens.border, height: 1, thickness: 1),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

