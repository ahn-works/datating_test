import '../services/kakao_map_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'soso_car_host_step3_screen.dart';

class OOMUHostStep2Screen extends StatefulWidget {
  final String meetingAddr;
  final double? meetingLat;
  final double? meetingLng;
  final String destAddr;
  final double? destLat;
  final double? destLng;
  final DateTime? depDate;
  final TimeOfDay? depTime;
  final DateTime? retDate;
  final TimeOfDay? retTime;
  final int seats;

  const OOMUHostStep2Screen({
    super.key,
    required this.meetingAddr,
    this.meetingLat,
    this.meetingLng,
    required this.destAddr,
    this.destLat,
    this.destLng,
    this.depDate,
    this.depTime,
    this.retDate,
    this.retTime,
    required this.seats,
  });

  @override
  State<OOMUHostStep2Screen> createState() => _OOMUHostStep2ScreenState();
}

class _OOMUHostStep2ScreenState extends State<OOMUHostStep2Screen> {
  final Color darkGreen = const Color(0xFF1B4D3E);
  final Color badgeGreen = const Color(0xFFA5D6A7);
  final Color terracotta = const Color(0xFFC04020);
  final Color surfaceContainer = const Color(0xFFF9F9F7);
  final Color background = const Color(0xFFFBF9F6);

  List<Map<String, dynamic>> _timelineItems = [];
  
  @override
  void initState() {
    super.initState();
    String depTimeStr = widget.depTime != null ? "${widget.depTime!.hour.toString().padLeft(2, '0')}:${widget.depTime!.minute.toString().padLeft(2, '0')}" : '시간 미정';
    _timelineItems = [
      {
        'type': 'departure',
        'time': depTimeStr,
        'title': widget.meetingAddr,
        'desc': '호스트 차량 대기 및 탑승자 랑데부',
        'lat': widget.meetingLat ?? 37.5638, // default seoul
        'lng': widget.meetingLng ?? 126.9037,
      },
      {
        'type': 'drive',
        'desc': '목적지로 이동 중',
      },
      {
        'type': 'destination',
        'time': '도착',
        'title': widget.destAddr,
        'desc': '목적지 도착 및 일정',
        'lat': widget.destLat ?? 37.8813, // default chuncheon
        'lng': widget.destLng ?? 127.7300,
      },
      {
        'type': 'drive',
        'desc': '귀가 주행',
      },
      {
        'type': 'return',
        'time': '복귀',
        'title': '출발지로 복귀 및 해산',
        'desc': '1/N 모임 실비 분담 완료',
        'lat': widget.meetingLat ?? 37.5638,
        'lng': widget.meetingLng ?? 126.9037,
      }
    ];
  }
  
  static const List<Map<String, String>> _koreanPoiDatabase = [
    {'place_name': '가평휴게소 (춘천방향)', 'address_name': '경기 가평군 설악면 미원리 1-1', 'category_group_name': '휴게소', 'x': '127.4988', 'y': '37.7126'},
    {'place_name': '덕평자연휴게소', 'address_name': '경기 이천시 마장면 덕이로154번길 287-76', 'category_group_name': '휴게소', 'x': '127.3688', 'y': '37.2173'},
    {'place_name': '행담도휴게소', 'address_name': '충남 당진시 신평면 서해안고속도로 275', 'category_group_name': '휴게소', 'x': '126.8174', 'y': '36.9442'},
    {'place_name': '망향휴게소 (부산방향)', 'address_name': '충남 천안시 서북구 입장면 망향로 501', 'category_group_name': '휴게소', 'x': '127.1852', 'y': '36.8624'},
    {'place_name': '안성맞춤휴게소', 'address_name': '경기 안성시 평택제천고속도로 42', 'category_group_name': '휴게소', 'x': '127.3195', 'y': '37.0392'},
    {'place_name': '스타벅스 더북한강R점', 'address_name': '경기 남양주시 화도읍 북한강로 1098', 'category_group_name': '카페', 'x': '127.3481', 'y': '37.6493'},
    {'place_name': '스타벅스 더양평DTR점', 'address_name': '경기 양평군 양평읍 양근로 76', 'category_group_name': '카페', 'x': '127.4812', 'y': '37.4921'},
    {'place_name': '스타벅스 홍대입구역사거리점', 'address_name': '서울 마포구 양화로 165', 'category_group_name': '카페', 'x': '126.9238', 'y': '37.5568'},
    {'place_name': '성수동 블루보틀 카페', 'address_name': '서울 성동구 아차산로 7', 'category_group_name': '카페', 'x': '127.0456', 'y': '37.5478'},
    {'place_name': '동대문엽기떡볶이 홍대점', 'address_name': '서울 마포구 어울마당로 112', 'category_group_name': '맛집', 'x': '126.9228', 'y': '37.5545'},
    {'place_name': '하이디라오 홍대점', 'address_name': '서울 마포구 양화로 176', 'category_group_name': '맛집', 'x': '126.9255', 'y': '37.5574'},
    {'place_name': '여수 학동 낭만식당', 'address_name': '전남 여수시 시청동1길 15', 'category_group_name': '맛집', 'x': '127.6605', 'y': '34.7620'},
    {'place_name': '여수 학동 감성 오션뷰 카페', 'address_name': '전남 여수시 시청서1길 23', 'category_group_name': '카페', 'x': '127.6622', 'y': '34.7604'},
  ];

  Future<void> _searchAndAddRestStop() async {
    TextEditingController searchController = TextEditingController();
    List<dynamic> searchResults = List.from(_koreanPoiDatabase);
    bool isSearching = false;

    Future<void> executeSearch(String query, StateSetter setModalState) async {
      final clean = query.trim();
      if (clean.isEmpty) {
        setModalState(() {
          searchResults = List.from(_koreanPoiDatabase);
          isSearching = false;
        });
        return;
      }
      setModalState(() => isSearching = true);

      List<Map<String, dynamic>> results = [];

      // 1. 카카오맵 공식 키워드 장소 검색 (Single Source of Truth)
      try {
        final places = await KakaoMapService.searchKeyword(clean, size: 10);
        for (var p in places) {
          results.add({
            'place_name': p.name,
            'address_name': p.roadAddress.isNotEmpty ? p.roadAddress : p.address,
            'category_group_name': p.category,
            'x': p.lng.toString(),
            'y': p.lat.toString(),
            'place_url': p.placeUrl,
          });
        }
      } catch (e) {
        debugPrint('[HostStep2] Kakao search error: $e');
      }

      // 3. Curated Database matches
      final lower = clean.toLowerCase();
      final matchedPoi = _koreanPoiDatabase.where((p) =>
        p['place_name']!.toLowerCase().contains(lower) ||
        p['address_name']!.toLowerCase().contains(lower)
      ).toList();
      for (var p in matchedPoi) {
        if (!results.any((r) => r['place_name'] == p['place_name'])) {
          results.add(Map<String, dynamic>.from(p));
        }
      }

      // 4. Direct Entry fallback
      if (!results.any((r) => r['place_name'] == clean)) {
        results.insert(0, {
          'place_name': clean,
          'address_name': '직접 입력한 장소',
          'category_group_name': '직접입력',
          'x': '126.9780',
          'y': '37.5665',
        });
      }

      setModalState(() {
        searchResults = results;
        isSearching = false;
      });
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(ctx).size.height * 0.8,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('경유 쉼표 추가', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchController,
                    onSubmitted: (q) => executeSearch(q, setModalState),
                    decoration: InputDecoration(
                      hintText: '카페, 휴게소, 명소 검색 (예: 가평휴게소, 스타벅스)',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => executeSearch(searchController.text, setModalState),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  isSearching ? const Center(child: CircularProgressIndicator()) :
                  Expanded(
                    child: ListView.separated(
                      itemCount: searchResults.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, index) {
                        final item = searchResults[index];
                        final isCustom = item['category_group_name'] == '직접입력';
                        return ListTile(
                          leading: Icon(
                            isCustom ? Icons.add_location_alt_rounded : Icons.place_rounded,
                            color: isCustom ? const Color(0xFFFF5E36) : const Color(0xFF767676),
                          ),
                          title: Text(
                            item['place_name'].toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCustom ? const Color(0xFFFF5E36) : null,
                            ),
                          ),
                          subtitle: Text(item['address_name'].toString()),
                          onTap: () {
                            setState(() {
                              int destIdx = _timelineItems.indexWhere((e) => e['type'] == 'destination');
                              _timelineItems.insert(destIdx - 1, {
                                'type': 'rest',
                                'label': '쉼표',
                                'category': item['category_group_name']?.toString() ?? '장소',
                                'time': '경유',
                                'title': item['place_name'].toString(),
                                'desc': item['address_name'].toString(),
                                'lat': double.tryParse(item['y'].toString()) ?? 0.0,
                                'lng': double.tryParse(item['x'].toString()) ?? 0.0,
                              });
                              _timelineItems.insert(destIdx, {
                                'type': 'drive',
                                'desc': '이동',
                              });
                            });
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
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
            _buildStep1Summary(),
            _buildTimelineSection(),
            _buildAddRestStopButton(),
            _buildThemeTags(),
            _buildSafetyBanner(),
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
                        const Text('STEP 2', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.black87)),
                        Text(' / 3', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade400)),
                      ],
                    ),
                    Text('일정 상세 & 쉼표 등록', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
              ),
              Stack(
                children: [
                  Container(width: double.infinity, height: 3, color: Colors.grey.shade200),
                  FractionallySizedBox(
                    widthFactor: 0.6666666666666666,
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
              Icon(Icons.eco_outlined, color: terracotta, size: 16),
              const SizedBox(width: 4),
              Text('느긋한 여정 설계', style: TextStyle(color: terracotta, fontWeight: FontWeight.w800, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          const Text("여유로운 드라이브를 위한\n'일정 쉼표(쉼터·스팟)'를\n등록해주세요 ☕", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, height: 1.3, letterSpacing: -0.5, color: Colors.black)),
          const SizedBox(height: 16),
          const Text("동네 이웃과의 드라이브은 쫓기는 관광이 아닌, 1~2곳의\n여유로운 스팟과 숨은 쉼표 중심의 힐링 로드트립을 지향해요.", style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.5, letterSpacing: -0.3)),
        ],
      ),
    );
  }

  Widget _buildStep1Summary() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withOpacity(0.04)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: badgeGreen, borderRadius: BorderRadius.circular(12)), child: Text('1단계 요약', style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold, fontSize: 10))),
                  const SizedBox(width: 8),
                  const Text('출발지 ➡ 도착지', style: TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              ),
              const Row(
                children: [
                  Icon(Icons.edit, size: 12, color: Colors.black54),
                  SizedBox(width: 2),
                  Text('수정', style: TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Text('${widget.meetingAddr.split(' ').first} ➡ ${widget.destAddr.split(' ').first}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.black54),
              const SizedBox(width: 4),
              const Expanded(child: Text('10월 28일 (토)\n09:30', style: TextStyle(fontSize: 11, color: Colors.black87, height: 1.4))),
              Container(width: 1, height: 20, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 8)),
              const Expanded(child: Text('당일 복귀', style: TextStyle(fontSize: 11, color: Colors.black87, height: 1.4))),
              Container(width: 1, height: 20, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 8)),
              const Expanded(child: Text('3인 모집', style: TextStyle(fontSize: 11, color: Colors.black87, height: 1.4, fontWeight: FontWeight.bold))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
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
                  Icon(Icons.timeline, size: 18),
                  SizedBox(width: 8),
                  Text('타임라인 및 코스 스팟', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const Text('드래그 순서 변경', style: TextStyle(fontSize: 11, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 24),
          ..._timelineItems.map((item) {
            if (item['type'] == 'drive') return _buildDriveConnector(item['desc']);
            if (item['type'] == 'departure') return _buildTimelineItem(item, Icons.directions_car_outlined, darkGreen, '출발');
            if (item['type'] == 'destination') return _buildTimelineItem(item, Icons.camera_alt_outlined, darkGreen, '목적지');
            if (item['type'] == 'return') return _buildTimelineItem(item, Icons.home_outlined, Colors.black87, '복귀');
            if (item['type'] == 'rest') return _buildRestStopItem(item);
            return const SizedBox();
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDriveConnector(String desc) {
    return Row(
      children: [
        Container(
          width: 32,
          alignment: Alignment.center,
          child: Container(width: 2, height: 40, color: badgeGreen),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(Icons.navigation_outlined, size: 12, color: Colors.black54),
              const SizedBox(width: 4),
              Text(desc, style: const TextStyle(fontSize: 11, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> item, IconData icon, Color badgeColor, String badgeText) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
          child: Icon(icon, size: 16, color: Colors.black87),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(10)), child: Text(badgeText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 8),
                  Text(item['time'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                  const Spacer(),
                  const Icon(Icons.drag_indicator, size: 16, color: Colors.black26),
                ],
              ),
              const SizedBox(height: 6),
              Text(item['title'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(item['desc'], style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildRestStopItem(Map<String, dynamic> item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: const Color(0xFFFDECE8), shape: BoxShape.circle, border: Border.all(color: terracotta.withOpacity(0.3))),
          child: Icon(Icons.local_cafe_outlined, size: 14, color: terracotta),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFFDECE8), borderRadius: BorderRadius.circular(10), border: Border.all(color: terracotta.withOpacity(0.3))), child: Row(children: [Icon(Icons.coffee, size: 10, color: terracotta), const SizedBox(width: 4), Text(item['label'] + ' ' + item['category'], style: TextStyle(color: terracotta, fontSize: 10, fontWeight: FontWeight.bold))])),
                  const SizedBox(width: 8),
                  Text(item['time'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                  if (item['duration'] != null) ...[
                    const SizedBox(width: 4),
                    Text('(${item['duration']})', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                  const Spacer(),
                  const Icon(Icons.drag_indicator, size: 16, color: Colors.black26),
                ],
              ),
              const SizedBox(height: 6),
              Text(item['title'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(item['desc'], style: const TextStyle(fontSize: 12, color: Colors.black54)),
              if (item['tag'] != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black.withOpacity(0.04)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 12, offset: const Offset(0, 4))]),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.card_giftcard, size: 12, color: terracotta),
                      const SizedBox(width: 4),
                      Text(item['tag'], style: const TextStyle(fontSize: 10, color: Colors.black87)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(20)),
                    child: const Text('스팟 수정', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFFDECE8), borderRadius: BorderRadius.circular(20)),
                    child: Text('삭제', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: terracotta)),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildAddRestStopButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: _searchAndAddRestStop,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, size: 18),
              SizedBox(width: 8),
              Text('경유 쉼표 추가 (휴게소, 맛집, 카페 등)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeTags() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('호스트들이 자주 찾는 쉼표 테마:', style: TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildThemeTag('☕ 뷰 좋은 리버뷰 카페'),
                const SizedBox(width: 8),
                _buildThemeTag('🌲 숲길 산책로 쉼터'),
                const SizedBox(width: 8),
                _buildThemeTag('🥨 로컬 빵집/간식'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildThemeTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black.withOpacity(0.04)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 12, offset: const Offset(0, 4))], borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildSafetyBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: darkGreen, shape: BoxShape.circle),
            child: const Icon(Icons.favorite, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("우무(OOMU)의 '안전 쉼표' 원칙", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                SizedBox(height: 6),
                Text("2시간 이상 연속 운전 시 드라이버 피로 경감을 위해 최소 20분 이상의 쉼표 등록을 권장합니다. 탑승자 전원이 충분히 여유를 누릴 수 있도록 코스를 구성해주세요.", style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.4)),
              ],
            ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
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
                    child: const Text('이전 (1단계)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: Colors.black87)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 7,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => OOMUHostStep3Screen(
                        timelineItems: _timelineItems,
                        depDate: widget.depDate,
                        retDate: widget.retDate,
                        seats: widget.seats,
                      )));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreen,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('다음 단계 (최종 확인 & 등록)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: Colors.white)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Step 3에서 참가자 신청 승인 방식 및 1/N 정산 룰을 최종 점검합니다.', style: TextStyle(fontSize: 11, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
