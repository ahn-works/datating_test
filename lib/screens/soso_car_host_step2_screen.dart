import 'package:flutter/material.dart';
import 'soso_car_host_step3_screen.dart';

class SosoCarHostStep2Screen extends StatefulWidget {
  const SosoCarHostStep2Screen({super.key});

  @override
  State<SosoCarHostStep2Screen> createState() => _SosoCarHostStep2ScreenState();
}

class _SosoCarHostStep2ScreenState extends State<SosoCarHostStep2Screen> {
  final Color darkGreen = const Color(0xFF1B4D3E);
  final Color badgeGreen = const Color(0xFFA5D6A7);
  final Color terracotta = const Color(0xFFC04020);
  final Color surfaceContainer = const Color(0xFFF9F9F7);
  final Color background = const Color(0xFFFBF9F6);

  List<Map<String, dynamic>> _timelineItems = [
    {
      'type': 'departure',
      'time': '09:30',
      'title': '마포구청역 1번 출구 지상 버스베이',
      'desc': '호스트 차량 대기 및 탑승자 3인 랑데부',
    },
    {
      'type': 'drive',
      'desc': '약 1시간 15분 주행 (72km)',
    },
    {
      'type': 'rest',
      'label': '쉼표 1',
      'category': '휴게소/전망',
      'time': '10:45 ~ 11:15',
      'duration': '30분 휴식',
      'title': '가평휴게소 춘천방향 (맛남샌드 & 커피타임)',
      'desc': '호스트가 추천하는 브레이크 타임! 화장실 이용 및 따뜻한 커피 한 잔 ☕',
      'tag': '가평 잣도넛 & 호두과자 나누기',
    },
    {
      'type': 'drive',
      'desc': '약 40분 주행 (38km)',
    },
    {
      'type': 'destination',
      'time': '12:00 ~ 14:00',
      'title': '춘천 소양강 스카이워크 & 호반 드라이브',
      'desc': '호수 위 투명 유리 산책로 걷기 및 탁 트인 전경 사진 촬영 📸',
    },
    {
      'type': 'drive',
      'desc': '약 15분 이동 (7.5km)',
    },
    {
      'type': 'rest',
      'label': '쉼표 2',
      'category': '맛집/카페',
      'time': '14:20 ~ 16:30',
      'title': '춘천 통나무집 닭갈비 ➡ 카페 감자밭',
      'desc': '이웃 추천 숯불닭갈비 1/N 식사 후 시그니처 감자빵과 야외 가든 산책',
    },
    {
      'type': 'drive',
      'desc': '약 1시간 30분 귀가 주행 (88km)',
    },
    {
      'type': 'return',
      'time': '16:30 출발 ➡ 18:00 도착',
      'title': '마포구청역 복귀 및 안전 귀가 인사',
      'desc': '하차 후 모바일 앱으로 1/N 실비 자동 정산 및 매너 평가 완료',
    }
  ];

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
          const Text("동네 이웃과의 카풀은 쫓기는 관광이 아닌, 1~2곳의\n여유로운 스팟과 숨은 쉼표 중심의 힐링 로드트립을 지향해요.", style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.5, letterSpacing: -0.3)),
        ],
      ),
    );
  }

  Widget _buildStep1Summary() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
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
          const Text('마포구청역 1번 출구 ➡ 강원 춘천시 ...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                  decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
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
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 18),
            SizedBox(width: 8),
            Text('경유 쉼표 추가 (휴게소, 전망대, 카페, 맛집)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
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
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(20)),
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
                Text("소소카의 '안전 쉼표' 원칙", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
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
                    child: const Text('이전 (1단계)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 7,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SosoCarHostStep3Screen()));
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
                        Text('다음 단계 (최종 확인 & 등록)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
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
