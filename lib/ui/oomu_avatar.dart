import 'package:flutter/material.dart';

import '../utils/app_image.dart';
import 'oomu_tokens.dart';

/// OOMU 원형 아바타 컴포넌트
/// - 사진이 없거나 로드 실패 시 이니셜 원(중립 회색)으로 안전하게 대체
/// - Cloudflare R2 스토리지(profiles/...), 네트워크(http/https), 로컬 에셋(assets/...) 완벽 자동 연동
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

  String? _resolveFallbackAsset() {
    final clean = (name ?? '').trim();
    if (clean.contains('초연')) return 'assets/images/초연.png';
    if (clean.contains('민지')) return 'assets/images/민지.png';
    if (clean.contains('주아')) return 'assets/images/주아.png';
    if (clean.contains('시연')) return 'assets/images/시연.png';
    if (clean.contains('지안')) return 'assets/images/지안.png';
    if (clean.contains('지연')) return 'assets/images/지연.png';
    if (clean.contains('지훈')) return 'assets/images/지훈.png';
    if (clean.contains('정재')) return 'assets/images/정재.png';
    return null;
  }

  Widget _buildInitialCircle(double diameter) {
    return Container(
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
  }

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;
    final url = imageUrl?.trim() ?? '';
    final fallbackAsset = _resolveFallbackAsset();

    Widget fallback = fallbackAsset != null
        ? ClipOval(
            child: SizedBox(
              width: diameter,
              height: diameter,
              child: Image.asset(
                fallbackAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildInitialCircle(diameter),
              ),
            ),
          )
        : _buildInitialCircle(diameter);

    if (url.isEmpty) {
      return fallback;
    }

    return ClipOval(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: Image(
          image: appImg(url, fallback: fallbackAsset ?? 'assets/images/민지.png'),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback,
        ),
      ),
    );
  }
}

