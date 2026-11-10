import 'package:flutter/material.dart';

import 'oomu_tokens.dart';

/// OOMU 공통 앱바 컴포넌트
/// - 배경 #FFFFFF, 1px #EAECF0 하단 구분선
/// - 타이틀 18dp / w700
/// - 모든 아이콘 액션 48x48dp 터치 영역 보장
class OomuAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBottomBorder;
  final VoidCallback? onBack;

  const OomuAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showBottomBorder = true,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    Widget? leadingWidget = leading;
    if (leadingWidget == null && Navigator.canPop(context)) {
      leadingWidget = ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: OomuTokens.touchTarget,
          minHeight: OomuTokens.touchTarget,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: OomuTokens.textPrimary,
          onPressed: onBack ?? () => Navigator.maybePop(context),
        ),
      );
    }

    return AppBar(
      backgroundColor: OomuTokens.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: leadingWidget,
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: OomuTokens.fontFamily,
          fontFamilyFallback: OomuTokens.fontFallback,
          fontSize: OomuTokens.fs18,
          fontWeight: OomuTokens.w700,
          color: OomuTokens.textPrimary,
        ),
      ),
      actions: actions,
      bottom: showBottomBorder
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: OomuTokens.border,
                height: 1,
              ),
            )
          : null,
    );
  }
}

