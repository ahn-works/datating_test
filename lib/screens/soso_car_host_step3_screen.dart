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
  final Color darkGreen = const Color(0xFF1B4D3E);
  final Color badgeGreen = const Color(0xFFA5D6A7);
  final Color terracotta = const Color(0xFFC04020);
  final Color surfaceContainer = const Color(0xFFF9F9F7);
  final Color background = const Color(0xFFFBF9F6);

  int _selectedApprovalMethod = 0; // 0: 수락제, 1: 선착순
  bool _isConsentChecked = true;
  
  bool _isLoadingRoute = true;
  int _totalDistanceMeter = 0;
  int _tollFare = 0;
  int _fuelCost = 0;
  int _totalCost = 0;
  int _costPerPerson = 0;

  @override
  void initState() {
    super.initState();
    _calculateRoute();
  }

  Future<void> _calculateRoute() async {
    try {
      final originItem = widget.timelineItems.firstWhere((e) => e['type'] == 'departure');
      final destItem = widget.timelineItems.firstWhere((e) => e['type'] == 'destination');
      final waypoints = widget.timelineItems.where((e) => e['type'] == 'rest').toList();

      String origin = '${originItem['lng']},${originItem['lat']}';
      String destination = '${destItem['lng']},${destItem['lat']}';
      String waypointsStr = waypoints.map((w) => '${w['lng']},${w['lat']}').join('|');

      String url = 'https://apis-navi.kakaomobility.com/v1/directions?origin=$origin&destination=$destination';
      if (waypointsStr.isNotEmpty) {
        url += '&waypoints=$waypointsStr';
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
            _totalDistanceMeter = summary['distance'];
            _tollFare = summary['fare']['toll'];
            
            // Calculate fuel cost: (Distance km / 13 km/L) * 1700 KRW/L
            double distanceKm = _totalDistanceMeter / 1000.0;
            // * 2 for round trip (왕복)
            distanceKm = distanceKm * 2;
            _tollFare = _tollFare * 2;
            
            _fuelCost = ((distanceKm / 13.0) * 1700).round();
            _totalCost = _fuelCost + _tollFare;
            _costPerPerson = (_totalCost / widget.seats).round();
            _isLoadingRoute = false;
          });
        }
      }
    } catch (e) {
      print(e);
      setState(() => _isLoadingRoute = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildPreviewCard(),
            _buildExpenseSection(),
            _buildApprovalMethodSection(),
            _buildEtiquetteSection(),
            _buildConsentSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildBottomButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
      title: const Text('Chat Room', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
      actions: [
        IconButton(icon: const Icon(Icons.share, color: Colors.black87), onPressed: () {}),
        IconButton(icon: const Icon(Icons.more_vert, color: Colors.black87), onPressed: () {}),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('STEP 3', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.black87)),
                        Text(' / 3', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade400)),
                      ],
                    ),
                    Text('최종 확인 & 등록', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
              ),
              Stack(
                children: [
                  Container(width: double.infinity, height: 3, color: Colors.grey.shade200),
                  FractionallySizedBox(
                    widthFactor: 1.0,
                    child: Container(height: 3, color: const Color(0xFF1B4D3E)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rocket_launch_outlined, color: terracotta, size: 16),
              const SizedBox(width: 4),
              Text('출발 전 마지막 단계예요', style: TextStyle(color: terracotta, fontWeight: FontWeight.w800, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          const Text("이웃들과 함께 떠날 준비가\n거의 끝났어요! 🎉", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, height: 1.3, letterSpacing: -0.5, color: Colors.black)),
          const SizedBox(height: 16),
          const Text("작성하신 여정과 정산 룰, 동승 승인 방식을 꼼꼼히 확인하고\n모임을 열어보세요.", style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.5, letterSpacing: -0.3)),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)), child: const Text('☁️ 당일 드라이브 힐링', style: TextStyle(fontSize: 10, color: Colors.black87))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: badgeGreen, borderRadius: BorderRadius.circular(12)), child: Text('● 모집 예정', style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold, fontSize: 10))),
            ],
          ),
          const SizedBox(height: 12),
          const Text('강원 춘천 소양강 스카이워크 & 감자밭 쉼표 로드트립 🍃', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, height: 1.3)),
          const SizedBox(height: 12),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network('https://picsum.photos/600/300?random=10', height: 120, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                bottom: 8, left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                  child: const Row(children: [Icon(Icons.location_on, color: Colors.white, size: 12), SizedBox(width: 4), Text('총 이동거리 약 205km', style: TextStyle(color: Colors.white, fontSize: 10))]),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=11')),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('호스트 민우', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 6),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: badgeGreen, borderRadius: BorderRadius.circular(10)), child: Text('마포구 연남동', style: TextStyle(color: darkGreen, fontSize: 9, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('AI 무사고 안심 드라이버 🛡️', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('매너온도', style: TextStyle(color: Colors.black54, fontSize: 10)),
                  Text('42.5°C 🔥', style: TextStyle(color: terracotta, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              )
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: Colors.black12)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.black54),
              const SizedBox(width: 8),
              const Expanded(child: Text('2024년 10월 28일 (토) 09:30 ~ 18:00 (당일 복귀)', style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.group_outlined, size: 14, color: Colors.black54),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
                    children: [
                      TextSpan(text: '모집 인원 '),
                      TextSpan(text: '총 4명', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' (호스트 1명 + 동승 이웃 3명)'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.share, size: 14, color: Colors.black54),
                    SizedBox(width: 4),
                    Text('상세 경유 일정', style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildRouteItem('마포구청역 1번 출구', '(09:30 집결 및 인사)', darkGreen, true),
                _buildRouteItem('가평휴게소 춘천방향', '(맛남샌드 & 커피 쉼표)', Colors.orange, true),
                _buildRouteItem('춘천 소양강 스카이워크', '(호수 산책 & 포토)', Colors.orange, true),
                _buildRouteItem('통나무집 닭갈비 & 감자밭 카페', '(점심 & 수다)', Colors.orange, true),
                _buildRouteItem('마포구청역 복귀', '(18:00 도착 및 해산)', terracotta, false),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRouteItem(String title, String desc, Color color, bool hasLine) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            if (hasLine) Container(width: 2, height: 16, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(vertical: 2)),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(width: 4),
                Expanded(child: Text(desc, style: const TextStyle(fontSize: 10, color: Colors.black54))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.receipt_long, size: 18),
                  SizedBox(width: 8),
                  Text('1/N 예상 실비 정산', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: badgeGreen, borderRadius: BorderRadius.circular(12)), child: Text('여객자동차운수사업법 준수', style: TextStyle(color: darkGreen, fontSize: 9, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline, size: 16, color: Colors.black87),
                    SizedBox(width: 8),
                    Expanded(child: Text('소소카는 순수 주행 실비(유류비+통행료)만 균등 분담합니다.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, height: 1.4))),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: Colors.black12)),
                                _isLoadingRoute ? const Center(child: CircularProgressIndicator()) : Column(
                  children: [
                    _buildCostRow('예상 유류비 (왕복 km, 13km/L)', '약 원'),
                    const SizedBox(height: 8),
                    _buildCostRow('고속도로 통행료 (하이패스 왕복)', '약 원'),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: Colors.black12)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('총 예상 이동 실비', style: TextStyle(fontSize: 13, color: Colors.black54)),
                        Text('원', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: darkGreen, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('인 탑승 완료 시 1인당 분담금', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                              const SizedBox(height: 2),
                              const Text('호스트 포함 1/N 자동 정산', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                            ],
                          ),
                          Text('약  원', style: TextStyle(color: badgeGreen, fontSize: 18, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ],
                ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Colors.black54),
                    SizedBox(width: 6),
                    Expanded(child: Text('여행 종료 후 실제 하이패스 결제 내역과 최종 유류비 영수증을 인증하여 1원 단위까지 투명하게 정산됩니다.', style: TextStyle(fontSize: 10, color: Colors.black54, height: 1.4))),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCostRow(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 11, color: Colors.black54))),
        Text(amount, style: const TextStyle(fontSize: 11, color: Colors.black87)),
      ],
    );
  }

  Widget _buildApprovalMethodSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_add_alt_1_outlined, size: 18),
              SizedBox(width: 8),
              Text('동승 신청 승인 방식', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('어떤 방식으로 함께할 이웃을 맞이할지 선택해주세요.', style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 16),
          _buildApprovalOption(
            0,
            '꼼꼼 호스트 수락제',
            '추천 👍',
            '신청한 이웃의 매너온도, 이전 동행 후기, 대화 및 음악 취향을 꼼꼼히 확인한 후 호스트가 직접 승인해요.',
          ),
          const SizedBox(height: 12),
          _buildApprovalOption(
            1,
            '바로 확정 (선착순)',
            null,
            '별도의 승인 과정 없이 빈 좌석이 다 찰 때까지 신청 즉시 자동으로 동행이 확정돼요.',
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalOption(int index, String title, String? badge, String desc) {
    bool isSelected = _selectedApprovalMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedApprovalMethod = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : surfaceContainer,
          border: Border.all(color: isSelected ? darkGreen : Colors.transparent, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [BoxShadow(color: darkGreen.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: isSelected ? darkGreen : Colors.black26, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isSelected ? Colors.black87 : Colors.black54)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(10)), child: Text(badge, style: const TextStyle(fontSize: 9, color: Colors.deepOrange, fontWeight: FontWeight.bold))),
                      ],
                      const Spacer(),
                      if (isSelected) const Icon(Icons.check_circle, size: 16, color: Colors.black87)
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(desc, style: const TextStyle(fontSize: 11, color: Colors.black54, height: 1.4)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEtiquetteSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.handshake_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('동행 에티켓 & 차량 이용 규칙', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const Text('5개 설정 완료', style: TextStyle(fontSize: 11, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              _buildEtiquetteChip('🚭 전좌석 절대 금연 (전자담배 포함)'),
              _buildEtiquetteChip('☕ 흘리지 않는 텀블러 음료만 허용'),
              _buildEtiquetteChip('🎵 드라이브 선곡은 번갈아가며'),
              _buildEtiquetteChip('⏰ 랑데뷰 집결 5분 전 도착 엄수'),
              _buildEtiquetteChip('🐾 반려동물 불가 (소형 캐리어 협의)'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.check, size: 14, color: Colors.black54),
                  SizedBox(width: 4),
                  Text('참여 신청 시 이웃들에게 위 규칙 동의를 필수로 받습니다.', style: TextStyle(fontSize: 10, color: Colors.black54)),
                ],
              ),
              const Text('규칙 변경', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87, decoration: TextDecoration.underline)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEtiquetteChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(fontSize: 11, color: Colors.black87)),
    );
  }

  Widget _buildConsentSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => setState(() => _isConsentChecked = !_isConsentChecked),
                child: Icon(_isConsentChecked ? Icons.check_box : Icons.check_box_outline_blank, color: _isConsentChecked ? terracotta : Colors.black26, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 11, color: Colors.black87, height: 1.4),
                    children: [
                      TextSpan(text: '[필수] ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC04020))),
                      TextSpan(text: '안전 운전 및 탑승자 배려 수칙을 준수하며, 상업적 유상운송 목적이 아닌 순수한 이웃 카풀 동행임을 확인하고 서약합니다.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.notifications_active_outlined, size: 16, color: Colors.black54),
              const SizedBox(width: 14),
              const Expanded(child: Text('등록 완료 즉시 마포구·서대문구 인근 이웃들의 탐색 피드에 노출되며, 민우 님을 찜한 단골 이웃들에게 우선 출발 알림이 전송됩니다.', style: TextStyle(fontSize: 10, color: Colors.black54, height: 1.4))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      color: background,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('이전 (2단계)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: Colors.black87)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 7,
              child: ElevatedButton(
                onPressed: _isConsentChecked ? () {
                  // Navigate to Home or show success dialog
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const SosoCarHomeScreen()), (route) => false);
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isConsentChecked ? darkGreen : Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.rocket_launch, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text('여행 모임 등록 완료하기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
