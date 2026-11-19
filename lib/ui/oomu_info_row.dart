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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 15, color: OomuTokens.coral),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 38,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: OomuTokens.fontFamily,
                fontFamilyFallback: OomuTokens.fontFallback,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: OomuTokens.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: OomuTokens.fontFamily,
                fontFamilyFallback: OomuTokens.fontFallback,
                fontSize: 14,
                fontWeight: FontWeight.w600,
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

