import 'package:flutter/material.dart';

import 'oomu_tokens.dart';

/// OOMU 정보 행 컴포넌트 (일시, 장소, 인원, 비용 등)
/// - 아이콘(보조색) + 라벨(보조색) + 값(본문/제목색)
class OomuInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const OomuInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OomuTokens.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: OomuTokens.textSecondary),
          const SizedBox(width: OomuTokens.s8),
          SizedBox(
            width: 44,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: OomuTokens.fontFamily,
                fontFamilyFallback: OomuTokens.fontFallback,
                fontSize: OomuTokens.fs14,
                fontWeight: OomuTokens.w400,
                color: OomuTokens.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: OomuTokens.s8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: OomuTokens.fontFamily,
                fontFamilyFallback: OomuTokens.fontFallback,
                fontSize: OomuTokens.fs14,
                fontWeight: OomuTokens.w600,
                color: OomuTokens.textPrimary,
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: OomuTokens.s8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

