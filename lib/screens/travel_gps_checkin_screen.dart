import 'package:flutter/material.dart';
import 'travel_room_screen.dart';
class TravelGpsCheckinScreen extends StatefulWidget { const TravelGpsCheckinScreen({super.key}); @override State<TravelGpsCheckinScreen> createState() => _TravelGpsCheckinScreenState(); }
class _TravelGpsCheckinScreenState extends State<TravelGpsCheckinScreen> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  @override void initState() { super.initState(); _anim = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(); }
  @override void dispose() { _anim.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.white, appBar: AppBar(title: const Text('목포역 광장 미팅 포인트', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)), body: Stack(children: [
    Positioned.fill(child: CustomPaint(painter: MapGridPainter())),
    Positioned.fill(child: Center(child: AnimatedBuilder(animation: _anim, builder: (ctx, child) => Container(width: 80 + (_anim.value * 120), height: 80 + (_anim.value * 120), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.withOpacity(0.4 * (1 - _anim.value))), child: Center(child: Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue, border: Border.all(color: Colors.white, width: 3), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)]))))))),
    Positioned(right: 20, bottom: 220, child: FloatingActionButton(backgroundColor: Colors.white, onPressed: (){}, child: const Icon(Icons.my_location, color: Colors.blue))),
    Positioned(left: 0, right: 0, bottom: 0, child: Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))], borderRadius: const BorderRadius.vertical(top: Radius.circular(32))), child: SafeArea(child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.center, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.check_circle, color: Colors.green, size: 16), SizedBox(width: 4), Text('GPS 연동 완료', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12))]))]), const SizedBox(height: 16), const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.location_on, color: Color(0xFFFF3B30)), SizedBox(width: 8), Text('현재 내 위치: 목포역 광장 (정상)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]), const SizedBox(height: 24), ElevatedButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TravelRoomScreen())), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('보증금 환불 받고 단톡방 입장', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))]))))
  ]));
}
class MapGridPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF4F1EA); canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    final roadPaint = Paint()..color = Colors.white..strokeWidth = 12..style = PaintingStyle.stroke;
    final thinRoadPaint = Paint()..color = Colors.white..strokeWidth = 6..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height*0.3), Offset(size.width, size.height*0.4), roadPaint);
    canvas.drawLine(Offset(size.width*0.4, 0), Offset(size.width*0.5, size.height), roadPaint);
    canvas.drawLine(Offset(0, size.height*0.6), Offset(size.width, size.height*0.8), thinRoadPaint);
    canvas.drawLine(Offset(size.width*0.7, 0), Offset(size.width*0.8, size.height), thinRoadPaint);
    // Google mark text
    final textPainter = TextPainter(text: const TextSpan(text: 'Google Maps API 연동 준비됨', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
    textPainter.paint(canvas, Offset(20, size.height - 250));
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
