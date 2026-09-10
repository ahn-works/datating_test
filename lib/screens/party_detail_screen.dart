import 'package:flutter/material.dart';
import 'party_application_screen.dart';

class PartyDetailScreen extends StatelessWidget { const PartyDetailScreen({super.key});
  void _showMap(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (_) => Container(height: MediaQuery.of(context).size.height * 0.7, padding: const EdgeInsets.all(24), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('미팅 장소 안내', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 16), Expanded(child: Container(decoration: BoxDecoration(color: const Color(0xFFF4F1EA), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)), child: Stack(children: [Positioned.fill(child: CustomPaint(painter: MapGridPainterDetail())), const Center(child: Icon(Icons.location_on, color: Color(0xFFFF3B30), size: 48)), Positioned(bottom: 16, left: 16, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]), child: const Text('구글 지도 API 연동 위치', style: TextStyle(fontWeight: FontWeight.bold))))]))), const SizedBox(height: 16), ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.black, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('닫기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))])));
  }
  void _showCalendar(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), contentPadding: const EdgeInsets.all(16), content: SizedBox(width: double.maxFinite, height: 350, child: CalendarDatePicker(initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)), onDateChanged: (d){}))));
  }
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.white, appBar: AppBar(title: const Text('모집 상세', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)), body: ListView(padding: const EdgeInsets.all(24), children: [
    ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network('https://picsum.photos/600/300?random=8', height: 200, fit: BoxFit.cover)), const SizedBox(height: 24),
    const Text('제주도 풀빌라 2:2 남녀 짝맞춰서 가실분!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 16),
    InkWell(onTap: () => _showCalendar(context), child: _row(Icons.calendar_month, '26.09.10 - 26.09.12 (2일)  👉 터치하여 날짜 확인', color: Colors.blue)), const SizedBox(height: 12),
    InkWell(onTap: () => _showMap(context), child: _row(Icons.location_on, '제주 애월읍 풀빌라  👉 터치하여 지도 보기', color: Colors.blue)), const SizedBox(height: 12),
    _row(Icons.people, '남 1/여 2 (남자 1명 급구!)', color: const Color(0xFFFF3B30)), const SizedBox(height: 24),
    const Text('모임 소개', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 8),
    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)), child: const Text('제주도로 2박 3일 힐링 여행 가실 2030 남녀 구합니다!\n현재 여자 2명, 남자 1명 확정되었고 남자 1명만 더 오시면 출발합니다.\n차량 렌트 완료했고 럭셔리 풀빌라 예약해뒀어요. 소개팅 겸 재밌게 놀아요!', style: TextStyle(height: 1.5))), const SizedBox(height: 24),
    const Text('비용 안내', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 8), _costRow('여행 참가비 (숙소+렌트)', '150,000원'), _costRow('노쇼 보증금(참석 시 환불)', '50,000원', red: true), const SizedBox(height: 32),
    ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PartyApplicationScreen())), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('설문 작성 및 참가 신청', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))]));
  static Widget _row(IconData icon, String text, {Color color = Colors.black87}) => Row(children: [Icon(icon, size: 20, color: color), const SizedBox(width: 8), Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold))]);
  static Widget _costRow(String l, String p, {bool red = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(color: Colors.black87)), Text(p, style: TextStyle(fontWeight: FontWeight.bold, color: red ? const Color(0xFFFF3B30) : Colors.black))]));
}
class MapGridPainterDetail extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF4F1EA); canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    final roadPaint = Paint()..color = Colors.white..strokeWidth = 12..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height*0.2), Offset(size.width, size.height*0.5), roadPaint);
    canvas.drawLine(Offset(size.width*0.3, 0), Offset(size.width*0.6, size.height), roadPaint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
