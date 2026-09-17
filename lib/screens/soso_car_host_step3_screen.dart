import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'soso_car_home_screen.dart';

class SosoCarHostStep3Screen extends StatefulWidget {
  final List<Map<String, dynamic>> timelineItems;
  final DateTime? depDate;
  final DateTime? retDate;
  final int seats;

  const SosoCarHostStep3Screen({
    super.key,
    required this.timelineItems,
    this.depDate,
    this.retDate,
    required this.seats,
  });

  @override
  State<SosoCarHostStep3Screen> createState() => _SosoCarHostStep3ScreenState();
}

class _SosoCarHostStep3ScreenState extends State<SosoCarHostStep3Screen> {
  final Color background = const Color(0xFFF9FAFB);
  final Color darkGreen = const Color(0xFF243B33);
  final Color badgeGreen = const Color(0xFFE8F3EE);
  
  bool _isLoadingRoute = true;
  int _totalDistanceMeter = 0;
  int _estimatedDues = 15000; // 정적 회비 (식비 등 공통 경비)

  @override
  void initState() {
    super.initState();
    _calculateRoute();
  }

  // 거리는 UI를 위해 계산하되, 비용(유류비/톨비) 정산 로직은 법적 문제로 완전 삭제
  Future<void> _calculateRoute() async {
    try {
      final originItem = widget.timelineItems.firstWhere((e) => e['type'] == 'departure');
      final destItem = widget.timelineItems.firstWhere((e) => e['type'] == 'destination');
      final waypoints = widget.timelineItems.where((e) => e['type'] == 'rest').toList();

      String origin = ',';
      String destination = ',';
      String waypointsStr = waypoints.map((w) => ',').join('|');

      String url = 'https://apis-navi.kakaomobility.com/v1/directions?origin=&destination=';
      if (waypointsStr.isNotEmpty) {
        url += '&waypoints=';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'KakaoAK 3f91399ac9b6731d96f6d4b9ac13c502'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final summary = data['routes'][0]['summary'];
          setState(() {
            _totalDistanceMeter = summary['distance'] as int;
            _isLoadingRoute = false;
          });
        }
      }
    } catch (e) {
      print(e);
      setState(() => _isLoadingRoute = false);
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20), onPressed: () => Navigator.pop(context)),
      title: const Text('우무 등록', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: LinearProgressIndicator(value: 1.0, backgroundColor: Colors.grey.shade100, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF243B33))),
      ),
    );
  }

  Widget _buildCostRow(String title, String amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, style: TextStyle(fontSize: 13, color: isBold ? Colors.black87 : Colors.black54, fontWeight: isBold ? FontWeight.bold : FontWeight.normal))),
        Text(amount, style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('3/3', style: TextStyle(color: Color(0xFF243B33), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  const Text('드라이브 메이트 모집 미리보기', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.3, letterSpacing: -0.5)),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withOpacity(0.04)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: badgeGreen, borderRadius: BorderRadius.circular(20)),
                              child: Text('모집중', style: TextStyle(color: darkGreen, fontSize: 10, fontWeight: FontWeight.w800)),
                            ),
                            const SizedBox(width: 8),
                            const Text('이번 주말', style: TextStyle(fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('춘천 소양강 드라이브 가요\n(이동 간 밥값, 카페 N빵해요!)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.4)),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const CircleAvatar(radius: 14, backgroundColor: Color(0xFFF0F0F0), child: Icon(Icons.person, size: 16, color: Colors.black26)),
                            const SizedBox(width: 8),
                            const Text('호스트 안심향', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                            const Spacer(),
                            const Icon(Icons.local_fire_department, size: 14, color: Color(0xFFFF5A5F)),
                            const SizedBox(width: 4),
                            const Text('37.5°C', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF5A5F))),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: Colors.black12)),
                        _isLoadingRoute ? const Center(child: CircularProgressIndicator()) : Column(
                          children: [
                            _buildCostRow('예상 모임 전체 회비', '약 원', isBold: true),
                            const SizedBox(height: 8),
                            const Text('* 식비, 카페, 공통 활동비 등 모임에 필요한 전체 경비 기준이며, 차량 이동에 대한 대가가 아닙니다.', style: TextStyle(fontSize: 10, color: Colors.black54, height: 1.4)),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: Colors.black12)),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: darkGreen, borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('인 참석 시 1인당 회비', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                                      const SizedBox(height: 2),
                                      const Text('호스트 포함 투명한 모임 N빵', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                                    ],
                                  ),
                                  Text('약  원', style: TextStyle(color: badgeGreen, fontSize: 18, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, size: 14, color: Colors.black54),
                            SizedBox(width: 6),
                            Expanded(child: Text('모임 참석 보증금(10,000원)은 노쇼 방지용이며, 현장에서 식비로 사용되거나 전액 환불됩니다.', style: TextStyle(fontSize: 10, color: Colors.black54, height: 1.4))),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SosoCarHomeScreen()), (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5A5F), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('여행 팟 모집 시작하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
