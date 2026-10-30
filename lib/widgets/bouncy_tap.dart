import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/oomu_ui_helpers.dart';

/// OOMU 공통 촉각 햅틱 피드백 시스템 (Emil Kowalski & Apple Taptic 매트릭스)
class OomuHaptics {
  OomuHaptics._();

  /// 1. 카테고리 탭, 칩 선택, 하단 네비게이션 전환 시
  static void selection() => HapticFeedback.selectionClick();

  /// 2. 일반 버튼 탭, 모임 카드 탭, 찜하기/하트
  static void light() => HapticFeedback.lightImpact();

  /// 3. 참여 신청 완료, 결제 완료, 동네 인증 성공 등 중요한 결정 시
  static void medium() => HapticFeedback.mediumImpact();

  /// 4. 차단, 신고, 경고, 삭제 등 파괴적 액션 시
  static void heavy() => HapticFeedback.heavyImpact();
}

/// 손끝에 즉각 반응하는 물리 기반 바운시 탭 위젯 (Emil Kowalski 모션 철학)
/// - 터치 다운(Down) 시 즉각 scaleDown (기본 0.97) 축소 + 햅틱
/// - 터치 업(Up/Cancel) 시 스프링 물리(Curves.easeOutCubic)로 탄력 있게 복원
class BouncyTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleDown;
  final Duration duration;
  final HitTestBehavior behavior;
  final bool enableHaptic;
  final VoidCallback? onHaptic;

  const BouncyTap({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleDown = 0.97,
    this.duration = const Duration(milliseconds: 100),
    this.behavior = HitTestBehavior.opaque,
    this.enableHaptic = true,
    this.onHaptic,
  });

  @override
  State<BouncyTap> createState() => _BouncyTapState();
}

class _BouncyTapState extends State<BouncyTap> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap == null) return;
    if (widget.enableHaptic) {
      if (widget.onHaptic != null) {
        widget.onHaptic!();
      } else {
        OomuHaptics.light();
      }
    }
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

/// 48dp 인체공학 터치 타깃 & 바운시 물리 탑재 OOMU 시그니처 버튼
class BouncyCoralButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;

  const BouncyCoralButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.height = 52.0,
    this.borderRadius = 14.0,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? OomuUiHelpers.brandCoral;
    final fg = textColor ?? Colors.white;

    return BouncyTap(
      onTap: isLoading ? null : onPressed,
      onHaptic: OomuHaptics.medium,
      scaleDown: 0.96,
      child: Container(
        height: height,
        constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: onPressed == null ? const Color(0xFFCBD5E1) : bg,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: onPressed == null
              ? null
              : [
                  BoxShadow(
                    color: bg.withOpacity(0.24),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: fg,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
