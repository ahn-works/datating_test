import 'package:flutter/material.dart';

/// OOMU 공식 브랜드 로고 위젯
/// 4번 첨부 이미지의 이중 버블 심볼(오버랩 서클 + 화이트 샤인 도트)과
/// OOMU 영문 워드마크 및 '우무' 한글 서브타이틀을 정밀 렌더링합니다.
enum OomuLogoStyle {
  /// 좌측 심볼 + 우측 'OOMU' & '우무' (가로형)
  horizontal,

  /// 상단 심볼 + 하단 'OOMU' & '우무' (세로 정렬형)
  stacked,

  /// 이중 버블 심볼 마크만 단독 렌더링
  symbolOnly,
}

class OomuLogo extends StatelessWidget {
  final double size;
  final OomuLogoStyle style;
  final Color? color;
  final bool showKoreanSubtitle;

  const OomuLogo({
    super.key,
    this.size = 48.0,
    this.style = OomuLogoStyle.horizontal,
    this.color,
    this.showKoreanSubtitle = true,
  });

  static const Color defaultCoral = Color(0xFFF25767);

  @override
  Widget build(BuildContext context) {
    final coral = color ?? defaultCoral;

    switch (style) {
      case OomuLogoStyle.symbolOnly:
        return _buildSymbol(size, coral);

      case OomuLogoStyle.stacked:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildSymbol(size * 1.1, coral),
            const SizedBox(height: 12),
            Text(
              'OOMU',
              style: TextStyle(
                fontSize: size * 0.55,
                fontWeight: FontWeight.w900,
                color: coral,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
            if (showKoreanSubtitle) ...[
              const SizedBox(height: 4),
              Text(
                '우무',
                style: TextStyle(
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w700,
                  color: coral.withValues(alpha: 0.9),
                  letterSpacing: 3.0,
                  height: 1.0,
                ),
              ),
            ],
          ],
        );

      case OomuLogoStyle.horizontal:
        // 고화질 공식 로고 에셋 이미지 시도 (로드 실패 시 벡터 심볼+타이포 폴백)
        return SizedBox(
          height: size,
          child: Image.asset(
            'assets/images/oomu_logo_clean.png',
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildSymbol(size * 0.9, coral),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OOMU',
                      style: TextStyle(
                        fontSize: size * 0.52,
                        fontWeight: FontWeight.w900,
                        color: coral,
                        letterSpacing: -0.5,
                        height: 1.05,
                      ),
                    ),
                    if (showKoreanSubtitle)
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0, top: 2.0),
                        child: Text(
                          '우무',
                          style: TextStyle(
                            fontSize: size * 0.24,
                            fontWeight: FontWeight.w700,
                            color: coral.withValues(alpha: 0.85),
                            letterSpacing: 2.5,
                            height: 1.0,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildSymbol(double dimension, Color coral) {
    return SizedBox(
      width: dimension,
      height: dimension,
      child: CustomPaint(
        size: Size(dimension, dimension),
        painter: _OomuBubbleSymbolPainter(color: coral),
      ),
    );
  }
}

/// OOMU 공식 이중 버블 심볼 벡터 페인터 (좌상단 원 + 우하단 원 + 교집합 화이트 렌즈 + 화이트 샤인 홀)
class _OomuBubbleSymbolPainter extends CustomPainter {
  final Color color;

  _OomuBubbleSymbolPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    final whitePaint = Paint()
      ..color = Colors.white
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // 1. 좌상단 원
    final r1 = w * 0.28;
    final c1 = Offset(w * 0.35, h * 0.35);
    final path1 = Path()..addOval(Rect.fromCircle(center: c1, radius: r1));

    // 2. 우하단 원
    final r2 = w * 0.31;
    final c2 = Offset(w * 0.63, h * 0.63);
    final path2 = Path()..addOval(Rect.fromCircle(center: c2, radius: r2));

    // 3. 두 원의 교집합 (화이트 렌즈 형태로 음각)
    final intersection = Path.combine(PathOperation.intersect, path1, path2);

    // 4. 우하단 원 내부의 화이트 아이/샤인 도트
    final rEye = w * 0.08;
    final cEye = Offset(w * 0.74, h * 0.74);

    // 드로잉 순서: 두 원 -> 교집합 화이트 -> 샤인 도트 화이트
    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(intersection, whitePaint);
    canvas.drawCircle(cEye, rEye, whitePaint);
  }

  @override
  bool shouldRepaint(covariant _OomuBubbleSymbolPainter oldDelegate) =>
      oldDelegate.color != color;
}
