import 'package:flutter/material.dart';
import '../utils/oomu_ui_helpers.dart';
import 'bouncy_tap.dart';

/// OOMU 표준 스프링 바텀시트 (Emil Kowalski 모션 & Impeccable 터치 타깃 가이드)
class OomuSpringSheet {
  OomuSpringSheet._();

  /// 부드러운 스프링 물리 기반 모달 바텀시트 호출
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
    double maxHeightFraction = 0.88,
  }) {
    OomuHaptics.selection();
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * maxHeightFraction,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 24,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. 드래그 핸들바 (Drag Handle)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),

                // 2. 헤더 (타이틀 & 48dp 닫기 버튼)
                if (title != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: OomuUiHelpers.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        BouncyTap(
                          onTap: () => Navigator.pop(ctx),
                          scaleDown: 0.9,
                          child: Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.close_rounded,
                              size: 22,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                ],

                // 3. 본문 콘텐츠
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
                    child: builder(ctx),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
