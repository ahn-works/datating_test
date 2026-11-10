import 'package:flutter/material.dart';

import 'oomu_tokens.dart';

/// OOMU 원형 아바타 컴포넌트
/// - 사진이 없거나 로드 실패 시 이니셜 원(중립 회색)으로 안전하게 대체
class OomuAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;

  const OomuAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 18,
  });

  const OomuAvatar.small({
    super.key,
    this.imageUrl,
    this.name,
  }) : radius = 14;

  const OomuAvatar.large({
    super.key,
    this.imageUrl,
    this.name,
  }) : radius = 24;

  String get _initial {
    final clean = (name ?? '').trim();
    if (clean.isEmpty) return 'U';
    return clean.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;
    final url = imageUrl?.trim() ?? '';

    Widget fallback = Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: OomuTokens.surfaceMuted,
        shape: BoxShape.circle,
        border: Border.all(color: OomuTokens.border, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        _initial,
        style: TextStyle(
          fontFamily: OomuTokens.fontFamily,
          fontFamilyFallback: OomuTokens.fontFallback,
          fontSize: radius * 0.9,
          fontWeight: OomuTokens.w700,
          color: OomuTokens.textSecondary,
        ),
      ),
    );

    if (url.isEmpty) {
      return fallback;
    }

    final isNetwork = url.startsWith('http://') || url.startsWith('https://');

    return ClipOval(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: isNetwork
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
              )
            : Image.asset(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}

