import 'package:flutter/material.dart';

import 'oomu_tokens.dart';

/// OOMU 스켈레톤(회색 블록 로딩) 컴포넌트
class OomuSkeleton extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const OomuSkeleton({
    super.key,
    this.width,
    required this.height,
    this.radius = OomuTokens.r8,
  });

  const OomuSkeleton.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        radius = OomuTokens.rPill;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: OomuTokens.surfaceMuted,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// 모임 카드 형태의 스켈레톤 (테두리 없는 사진형 카드와 동일한 구조)
class OomuMeetupCardSkeleton extends StatelessWidget {
  const OomuMeetupCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: OomuSkeleton(
            height: double.infinity,
            radius: OomuTokens.radiusCard,
          ),
        ),
        SizedBox(height: OomuTokens.s12),
        OomuSkeleton(height: 13, width: 120),
        SizedBox(height: OomuTokens.s8),
        OomuSkeleton(height: 18, width: 220),
        SizedBox(height: OomuTokens.s8),
        OomuSkeleton(height: 13, width: 150),
        SizedBox(height: OomuTokens.s12),
        Row(
          children: [
            OomuSkeleton.circle(size: 22),
            SizedBox(width: OomuTokens.s8),
            OomuSkeleton(height: 13, width: 80),
          ],
        ),
      ],
    );
  }
}
