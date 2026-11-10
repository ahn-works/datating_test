import 'package:flutter/material.dart';

import 'oomu_tokens.dart';

enum OomuButtonVariant {
  primary,
  secondary,
  text,
}

enum OomuButtonSize {
  medium, // 52dp
  small, // 48dp
}

/// OOMU 공통 버튼 컴포넌트
/// - primary: #F25767 단색 배경 + 흰색 텍스트
/// - secondary: #FFFFFF 배경 + 1px #EAECF0 테두리 + #191F28 텍스트
/// - text: 투명 배경 + #6B7684 또는 #D9384A 텍스트
/// - 항상 48x48dp 이상의 터치 영역 보장
class OomuButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final OomuButtonVariant variant;
  final OomuButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const OomuButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = OomuButtonVariant.primary,
    this.size = OomuButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  const OomuButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = OomuButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  }) : variant = OomuButtonVariant.secondary;

  const OomuButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = OomuButtonSize.small,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  }) : variant = OomuButtonVariant.text;

  @override
  Widget build(BuildContext context) {
    final height = size == OomuButtonSize.medium
        ? OomuTokens.buttonHeight
        : OomuTokens.buttonHeightSmall;

    Color bg;
    Color fg;
    Border? border;

    switch (variant) {
      case OomuButtonVariant.primary:
        bg = onPressed == null
            ? OomuTokens.surfaceMuted
            : OomuTokens.coral;
        fg = onPressed == null
            ? OomuTokens.textMuted
            : OomuTokens.surface;
        border = null;
        break;
      case OomuButtonVariant.secondary:
        bg = OomuTokens.surface;
        fg = onPressed == null
            ? OomuTokens.textMuted
            : OomuTokens.textPrimary;
        border = Border.all(
          color: OomuTokens.border,
          width: 1,
        );
        break;
      case OomuButtonVariant.text:
        bg = Colors.transparent;
        fg = onPressed == null
            ? OomuTokens.textMuted
            : OomuTokens.textSecondary;
        border = null;
        break;
    }

    Widget content;
    if (isLoading) {
      content = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(fg),
        ),
      );
    } else {
      final textWidget = Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: OomuTokens.fontFamily,
          fontFamilyFallback: OomuTokens.fontFallback,
          fontSize: OomuTokens.fs16,
          fontWeight: OomuTokens.w700,
          color: fg,
        ),
      );

      if (icon != null) {
        content = Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: OomuTokens.s8),
            Flexible(child: textWidget),
          ],
        );
      } else {
        content = textWidget;
      }
    }

    Widget button = Container(
      height: height,
      constraints: const BoxConstraints(
        minWidth: OomuTokens.touchTarget,
        minHeight: OomuTokens.touchTarget,
      ),
      padding: const EdgeInsets.symmetric(horizontal: OomuTokens.s16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(OomuTokens.r12),
        border: border,
      ),
      alignment: Alignment.center,
      child: content,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: OomuTokens.touchTarget,
        minHeight: OomuTokens.touchTarget,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (isLoading || onPressed == null) ? null : onPressed,
          borderRadius: BorderRadius.circular(OomuTokens.r12),
          child: fullWidth ? SizedBox(width: double.infinity, child: button) : button,
        ),
      ),
    );
  }
}
