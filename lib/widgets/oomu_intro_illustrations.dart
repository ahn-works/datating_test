import 'package:flutter/material.dart';

/// OOMU 앱 인트로 및 온보딩 전용 고품질 벡터 일러스트 컴포넌트
/// 'assets/images/OOMU 앱 UI 디자인.html'의 정밀 SVG 좌표 및 컬러를 1:1 재현합니다.

/// 1. OOMU 시그니처 로고 마크 (소프트 라운드 스퀘어 + 코랄/틸 오버랩 서클 + 화이트 하트)
class OomuLogoMark extends StatelessWidget {
  final double size;
  final bool showShadow;

  const OomuLogoMark({
    super.key,
    this.size = 96.0,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * (27.0 / 96.0)),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: const Color(0xFF4A3014).withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _OomuLogoMarkPainter(),
      ),
    );
  }
}

class _OomuLogoMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 96.0;
    canvas.save();
    canvas.scale(scale);

    final bgRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 96, 96),
      const Radius.circular(27),
    );

    // 배경 그래디언트 (#FFF6EC -> #FFE8D5)
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF6EC), Color(0xFFFFE8D5)],
      ).createShader(const Rect.fromLTWH(0, 0, 96, 96));
    canvas.drawRRect(bgRect, bgPaint);

    // 1. 코랄 서클 (cx=38, cy=48, r=20, #FF5C39)
    final coralPaint = Paint()..color = const Color(0xFFFF5C39);
    canvas.drawCircle(const Offset(38, 48), 20, coralPaint);

    // 2. 틸 서클 (cx=58, cy=48, r=20, #2FA98C)
    final tealPaint = Paint()..color = const Color(0xFF2FA98C);
    canvas.drawCircle(const Offset(58, 48), 20, tealPaint);

    // 3. 교차 영역 (#1D7A66, opacity 0.72)
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: const Offset(38, 48), radius: 20)));
    final overlapPaint = Paint()..color = const Color(0xFF1D7A66).withValues(alpha: 0.72);
    canvas.drawCircle(const Offset(58, 48), 20, overlapPaint);
    canvas.restore();

    // 4. 중앙 화이트 하트
    final heartPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final heartPath = _buildHeartPath(48, 54, 1.0);
    canvas.drawPath(heartPath, heartPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 2. 온보딩 슬라이드 1: 동네 숨은 장소 지도 일러스트
class OomuSlide1Map extends StatelessWidget {
  final double width;
  final double height;

  const OomuSlide1Map({
    super.key,
    this.width = 300,
    this.height = 230,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        size: Size(width, height),
        painter: _OomuSlide1Painter(),
      ),
    );
  }
}

class _OomuSlide1Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 300.0;
    canvas.save();
    canvas.scale(scale);

    final dotPaint = Paint()..color = const Color(0xFFFFD9B8);
    canvas.drawCircle(const Offset(60, 40), 4, dotPaint);
    canvas.drawCircle(const Offset(250, 30), 5, dotPaint);
    canvas.drawCircle(const Offset(270, 180), 4, dotPaint);
    canvas.drawCircle(const Offset(30, 150), 4, dotPaint);

    final sparklePaint = Paint()..color = const Color(0xFFFFC24B);
    _drawSparkleTriangle(canvas, 22, 96, 16, 18, sparklePaint);
    _drawSparkleTriangle(canvas, 268, 100, 12, 14, sparklePaint);

    // 지도 카드 베이스
    final mapRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(58, 60, 184, 140),
      const Radius.circular(18),
    );
    canvas.drawRRect(mapRect, Paint()..color = const Color(0xFFFFF3E4));

    // 도로 격자선
    final gridLinePaint = Paint()
      ..color = const Color(0xFFF3DFC4)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(58, 132), const Offset(242, 132), gridLinePaint);
    canvas.drawLine(const Offset(120, 60), const Offset(120, 200), gridLinePaint);
    canvas.drawLine(const Offset(180, 60), const Offset(180, 200), gridLinePaint);

    // 집 1 (피치 베이지)
    final house1Rect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(74, 146, 34, 26),
      const Radius.circular(6),
    );
    canvas.drawRRect(house1Rect, Paint()..color = const Color(0xFFFFD9A8));
    final roof1Paint = Paint()
      ..color = const Color(0xFFE89A4F)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final roof1 = Path()
      ..moveTo(71, 148)
      ..lineTo(91, 134)
      ..lineTo(111, 148);
    canvas.drawPath(roof1, roof1Paint);

    // 집 2 (민트 그린)
    final house2Rect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(196, 142, 30, 30),
      const Radius.circular(6),
    );
    canvas.drawRRect(house2Rect, Paint()..color = const Color(0xFFCDE8DC));
    final roof2Paint = Paint()
      ..color = const Color(0xFF2FA98C)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final roof2 = Path()
      ..moveTo(193, 144)
      ..lineTo(208, 132)
      ..lineTo(223, 144);
    canvas.drawPath(roof2, roof2Paint);

    // 핀 그림자
    final shadowPaint = Paint()..color = const Color(0xFF2B2118).withValues(alpha: 0.08);
    canvas.drawOval(const Rect.fromLTWH(150 - 26, 176 - 7, 52, 14), shadowPaint);

    // 핀 본체 (틸 #2FA98C)
    final pinPath = Path()
      ..moveTo(150, 64)
      ..cubicTo(150 - 19.9, 64, 114, 64 + 16.1, 114, 100)
      ..cubicTo(114, 125.5, 150, 160, 150, 160)
      ..cubicTo(150, 160, 186, 125.5, 186, 100)
      ..cubicTo(186, 64 + 16.1, 150 + 19.9, 64, 150, 64)
      ..close();
    canvas.drawPath(pinPath, Paint()..color = const Color(0xFF2FA98C));

    // 핀 내부 화이트 하트
    final heartPath = _buildHeartPath(150, 108, 2.0);
    canvas.drawPath(heartPath, Paint()..color = Colors.white);

    // 오른쪽 상단 8방향 반짝이
    _drawSparkleStar8(canvas, 214, 70, sparklePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 3. 온보딩 슬라이드 2: 취향 이웃 연결 일러스트
class OomuSlide2Friends extends StatelessWidget {
  final double width;
  final double height;

  const OomuSlide2Friends({
    super.key,
    this.width = 300,
    this.height = 230,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        size: Size(width, height),
        painter: _OomuSlide2Painter(),
      ),
    );
  }
}

class _OomuSlide2Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 300.0;
    canvas.save();
    canvas.scale(scale);

    // 1. 좌상단 코랄빛 말풍선
    final bubble1Rect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(30, 24, 86, 34),
      const Radius.circular(14),
    );
    canvas.drawRRect(bubble1Rect, Paint()..color = const Color(0xFFFFE7DD));
    final tail1 = Path()
      ..moveTo(46, 56)
      ..lineTo(40, 66)
      ..lineTo(54, 56)
      ..close();
    canvas.drawPath(tail1, Paint()..color = const Color(0xFFFFE7DD));

    // 2. 우상단 민트빛 말풍선
    final bubble2Rect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(186, 14, 84, 34),
      const Radius.circular(14),
    );
    canvas.drawRRect(bubble2Rect, Paint()..color = const Color(0xFFD9EEE2));
    final tail2 = Path()
      ..moveTo(254, 46)
      ..lineTo(260, 56)
      ..lineTo(246, 46)
      ..close();
    canvas.drawPath(tail2, Paint()..color = const Color(0xFFD9EEE2));

    // 3. 두 사람 그림자
    final shadowPaint = Paint()..color = const Color(0xFF2B2118).withValues(alpha: 0.07);
    canvas.drawOval(const Rect.fromLTWH(150 - 64, 196 - 8, 128, 16), shadowPaint);

    // 4. 왼쪽 친구 (코랄 #FF5C39)
    canvas.drawCircle(const Offset(118, 140), 44, Paint()..color = const Color(0xFFFF5C39));

    // 5. 오른쪽 친구 (틸 #2FA98C)
    canvas.drawCircle(const Offset(182, 140), 44, Paint()..color = const Color(0xFF2FA98C));

    // 6. 교차 오버랩
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: const Offset(118, 140), radius: 44)));
    canvas.drawCircle(
      const Offset(182, 140),
      44,
      Paint()..color = const Color(0xFF1D7A66).withValues(alpha: 0.72),
    );
    canvas.restore();

    // 7. 왼쪽 얼굴 눈 & 미소
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(102, 132), 5, eyePaint);
    canvas.drawCircle(const Offset(126, 132), 5, eyePaint);
    final smilePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final smile1 = Path()
      ..moveTo(104, 148)
      ..cubicTo(107, 152, 120, 152, 123, 148);
    canvas.drawPath(smile1, smilePaint);

    // 8. 오른쪽 얼굴 눈 & 미소
    canvas.drawCircle(const Offset(176, 132), 5, eyePaint);
    canvas.drawCircle(const Offset(200, 132), 5, eyePaint);
    final smile2 = Path()
      ..moveTo(178, 148)
      ..cubicTo(181, 152, 194, 152, 197, 148);
    canvas.drawPath(smile2, smilePaint);

    // 9. 교차 하트
    final heartPath = _buildHeartPath(150, 152, 2.1);
    canvas.drawPath(heartPath, Paint()..color = Colors.white);

    // 10. 반짝이 별
    final sparklePaint = Paint()..color = const Color(0xFFFFC24B);
    _drawSparkleStar4(canvas, 62, 92, 10, sparklePaint);
    _drawSparkleStar4(canvas, 244, 96, 9, sparklePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 4. 온보딩 슬라이드 3: 주말 모임 캘린더 & 참여자 일러스트
class OomuSlide3Meetup extends StatelessWidget {
  final double width;
  final double height;

  const OomuSlide3Meetup({
    super.key,
    this.width = 300,
    this.height = 230,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        size: Size(width, height),
        painter: _OomuSlide3Painter(),
      ),
    );
  }
}

class _OomuSlide3Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 300.0;
    canvas.save();
    canvas.scale(scale);

    // 달력 카드 화이트 베이스
    final cardRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(52, 30, 196, 152),
      const Radius.circular(20),
    );
    canvas.drawRRect(cardRRect, Paint()..color = Colors.white);

    // 상단 코랄 헤더 바
    final headerClip = Path()
      ..addRRect(cardRRect);
    canvas.save();
    canvas.clipPath(headerClip);
    canvas.drawRect(const Rect.fromLTWH(52, 30, 196, 44), Paint()..color = const Color(0xFFFF5C39));
    canvas.restore();

    // 헤더 텍스트: "이번 주말 모임"
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '이번 주말 모임',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.5,
          fontWeight: FontWeight.w700,
          fontFamily: 'Pretendard',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(150 - textPainter.width / 2, 42));

    // 스프링 링 도트 (좌우)
    canvas.drawCircle(const Offset(74, 74), 10, Paint()..color = const Color(0xFFFFE7DD));
    canvas.drawCircle(const Offset(226, 74), 10, Paint()..color = const Color(0xFFFFE7DD));

    // 금 11 칩
    final chip1 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(76, 92, 34, 46),
      const Radius.circular(10),
    );
    canvas.drawRRect(chip1, Paint()..color = const Color(0xFFFFF3E4));
    _drawCenteredText(canvas, '금', const Offset(93, 103), 11.5, const Color(0xFF9A8C7C));
    _drawCenteredText(canvas, '11', const Offset(93, 123), 14.5, const Color(0xFF2B2118), isBold: true);

    // 토 12 칩 (선택 하이라이트 - 틸 #2FA98C)
    final chip2 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(124, 88, 34, 52),
      const Radius.circular(10),
    );
    canvas.drawRRect(chip2, Paint()..color = const Color(0xFF2FA98C));
    _drawCenteredText(canvas, '토', const Offset(141, 100), 11.5, const Color(0xFFD9EEE2));
    _drawCenteredText(canvas, '12', const Offset(141, 118), 14.5, Colors.white, isBold: true);
    final tinyHeart = _buildHeartPath(141, 134, 0.9);
    canvas.drawPath(tinyHeart, Paint()..color = Colors.white);

    // 일 13 칩
    final chip3 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(172, 92, 34, 46),
      const Radius.circular(10),
    );
    canvas.drawRRect(chip3, Paint()..color = const Color(0xFFFFF3E4));
    _drawCenteredText(canvas, '일', const Offset(189, 103), 11.5, const Color(0xFF9A8C7C));
    _drawCenteredText(canvas, '13', const Offset(189, 123), 14.5, const Color(0xFF2B2118), isBold: true);

    // 하단 참여자 서클 (4명 스택)
    final avatarColors = [
      const Color(0xFFFFC24B), // 머스타드
      const Color(0xFFFF5C39), // 코랄
      const Color(0xFF2FA98C), // 틸
      const Color(0xFFFFE7DD), // 소프트 피치
    ];
    final avatarCenters = [112.0, 138.0, 164.0, 190.0];

    for (int i = 0; i < 4; i++) {
      final cx = avatarCenters[i];
      canvas.drawCircle(Offset(cx, 204), 14, Paint()..color = avatarColors[i]);
      canvas.drawCircle(Offset(cx, 203), 3.5, Paint()..color = Colors.white);
    }

    // +3 추가 참가자 원형 화살표/인디케이터
    final plusRingPaint = Paint()
      ..color = const Color(0xFF9A8C7C)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final plusRing = Path()
      ..addArc(const Rect.fromLTWH(214 - 12, 204 - 12, 24, 24), -1.2, 4.8);
    canvas.drawPath(plusRing, plusRingPaint);

    // 캡션 텍스트: "7명이 참여 중"
    final countPainter = TextPainter(
      text: const TextSpan(
        text: '7명이 참여 중',
        style: TextStyle(
          color: Color(0xFF9A8C7C),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Pretendard',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    countPainter.paint(canvas, Offset(150 - countPainter.width / 2, 226));

    canvas.restore();
  }

  void _drawCenteredText(
    Canvas canvas,
    String text,
    Offset center,
    double fontSize,
    Color color, {
    bool isBold = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          fontFamily: 'Pretendard',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================================
// 공통 벡터 헬퍼 함수
// ==========================================

/// 정밀 하트 패스 생성 (cx, cy를 하트 최하단 첨점으로 위치)
Path _buildHeartPath(double cx, double cy, double scale) {
  final path = Path();
  // SVG: M48 54c-3.8-2.4-6.1-4.4-6.1-6.9 0-2 1.6-3.6 3.4-3.6 1.1 0 2.1.5 2.7 1.4.7-.9 1.6-1.4 2.7-1.4 1.8 0 3.4 1.6 3.4 3.6 0 2.5-2.3 4.5-6.1 6.9z
  final s = scale;
  path.moveTo(cx, cy);
  path.cubicTo(cx - 3.8 * s, cy - 2.4 * s, cx - 6.1 * s, cy - 4.4 * s, cx - 6.1 * s, cy - 6.9 * s);
  path.cubicTo(cx - 6.1 * s, cy - 8.9 * s, cx - 4.5 * s, cy - 10.5 * s, cx - 2.7 * s, cy - 10.5 * s);
  path.cubicTo(cx - 1.6 * s, cy - 10.5 * s, cx - 0.6 * s, cy - 10.0 * s, cx, cy - 9.1 * s);
  path.cubicTo(cx + 0.6 * s, cy - 10.0 * s, cx + 1.6 * s, cy - 10.5 * s, cx + 2.7 * s, cy - 10.5 * s);
  path.cubicTo(cx + 4.5 * s, cy - 10.5 * s, cx + 6.1 * s, cy - 8.9 * s, cx + 6.1 * s, cy - 6.9 * s);
  path.cubicTo(cx + 6.1 * s, cy - 4.4 * s, cx + 3.8 * s, cy - 2.4 * s, cx, cy);
  path.close();
  return path;
}

void _drawSparkleTriangle(Canvas canvas, double cx, double cy, double w, double h, Paint paint) {
  final path = Path()
    ..moveTo(cx, cy - h / 2)
    ..lineTo(cx + w / 2, cy + h / 2)
    ..lineTo(cx - w / 2, cy + h / 2)
    ..close();
  canvas.drawPath(path, paint);
}

void _drawSparkleStar4(Canvas canvas, double cx, double cy, double r, Paint paint) {
  final path = Path()
    ..moveTo(cx, cy - r)
    ..quadraticBezierTo(cx, cy, cx + r, cy)
    ..quadraticBezierTo(cx, cy, cx, cy + r)
    ..quadraticBezierTo(cx, cy, cx - r, cy)
    ..quadraticBezierTo(cx, cy, cx, cy - r)
    ..close();
  canvas.drawPath(path, paint);
}

void _drawSparkleStar8(Canvas canvas, double cx, double cy, Paint paint) {
  final path = Path();
  // SVG: M214 70l3.5 8 8 3.5-8 3.5-3.5 8-3.5-8-8-3.5 8-3.5 3.5-8z
  path.moveTo(cx, cy - 8);
  path.lineTo(cx + 3.5, cy - 2);
  path.lineTo(cx + 10, cy);
  path.lineTo(cx + 3.5, cy + 2);
  path.lineTo(cx, cy + 8);
  path.lineTo(cx - 3.5, cy + 2);
  path.lineTo(cx - 10, cy);
  path.lineTo(cx - 3.5, cy - 2);
  path.close();
  canvas.drawPath(path, paint);
}
