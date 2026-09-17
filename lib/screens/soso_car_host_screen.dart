import 'package:flutter/material.dart';
import 'package:kpostal/kpostal.dart';

class SosoCarHostScreen extends StatefulWidget {
  const SosoCarHostScreen({super.key});

  @override
  State<SosoCarHostScreen> createState() => _SosoCarHostScreenState();
}

class _SosoCarHostScreenState extends State<SosoCarHostScreen> {
  final TextEditingController _meetingController = TextEditingController(text: '마포구청역 1번출구');
  DateTime? _depDate;
  TimeOfDay? _depTime;
  DateTime? _retDate;
  TimeOfDay? _retTime;
  
  String _formatDate(DateTime? d, String fallback) {
    if (d == null) return fallback;
    return "${d.month}월 ${d.day}일";
  }
  String _formatTime(TimeOfDay? t, String fallback) {
    if (t == null) return fallback;
    final ap = t.hour < 12 ? '오전' : '오후';
    final h = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
    final m = t.minute.toString().padLeft(2, '0');
    return "${ap} ${h}:${m}";
  }

  final Color darkGreen = const Color(0xFF1B4D3E);
  final Color badgeGreen = const Color(0xFFA5D6A7);
  final Color terracotta = const Color(0xFFC04020);
  final Color surfaceContainer = const Color(0xFFF9F9F7);
  final Color background = const Color(0xFFFBF9F6);

  int _seats = 3;
  
  bool _isNonSmoking = true;
  bool _isPetFriendly = true;
  bool _hasTrunkSpace = true;

  final List<String> _allTags = [
    '#잔잔한수다', '#음악감상 🎵', '#카페투어 ☕', 
    '#맛있는식사 🥘', '#사진동행 📸', '#사색즐김 🌿'
  ];
  final Set<String> _selectedTags = {'#잔잔한수다', '#음악감상 🎵', '#카페투어 ☕', '#맛있는식사 🥘'};

  final TextEditingController _titleController = TextEditingController(text: '춘천 소양강 드라이브 & 닭갈비 투어 🍁');
  final TextEditingController _destController = TextEditingController(text: '강원 춘천시 소양강 스카이워크');

  void _submitForm() {
    // Return structured data back to Home Screen
    Navigator.pop(context, {
      'title': _titleController.text,
      'location': _destController.text.replaceAll('강원 춘천시 ', ''),
      'tags': _selectedTags.toList(),
      'driverName': '달리는 민우', // Placeholder for current user
      'price': '9,000',
      'image': 'https://picsum.photos/600/300?random=50',
      'badge': '여유자리',
      'time': '이번 주말',
    });
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
            _buildProgressBar(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('어떤 드라이브를\n함께 떠나볼까요?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.3)),
                  const SizedBox(height: 8),
                  const Text('동네 이웃과 소소하고 여유로운 로드트립을 열어보세요.', style: TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('여행 제목', trailing: '최대 30자'),
                  _buildTextField(_titleController, false),
                  const SizedBox(height: 32),

                  _buildSectionTitle('출발 및 목적지', trailing: '왕복 여정', icon: Icons.explore_outlined),
                  _buildLocationBox(),
                  const SizedBox(height: 32),

                  _buildSeatSection(),
                  const SizedBox(height: 32),

                  _buildCarSection(),
                  const SizedBox(height: 32),

                  _buildTagSection(),
                  const SizedBox(height: 32),

                  _buildCostSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomButton(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: background,
      elevation: 0,
      leadingWidth: 100,
      leading: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.directions_car, color: darkGreen, size: 20),
          const SizedBox(width: 4),
          const Text('소소카', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('마포구 연남동', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
            SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: Colors.black87, size: 14),
          ],
        ),
      ),
      centerTitle: false,
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black87), onPressed: (){}),
            Positioned(top: 12, right: 12, child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)))
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(radius: 14, backgroundColor: darkGreen, child: const Icon(Icons.emoji_people, color: Colors.white, size: 16)),
        )
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: badgeGreen.withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
                    child: Text('Step 1 / 3', style: TextStyle(color: darkGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  const Text('기본 여행 정보', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
              const Text('33% 완료', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
            ],
          ),
        ),
        Stack(
          children: [
            Container(height: 2, width: double.infinity, color: Colors.grey.shade200),
            FractionallySizedBox(
              widthFactor: 0.33,
              child: Container(height: 2, color: darkGreen),
            )
          ],
        )
      ],
    );
  }

  Widget _buildSectionTitle(String title, {String? trailing, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: Colors.black87), const SizedBox(width: 8)],
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          if (trailing != null) Text(trailing, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, bool hasSearchIcon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          suffixIcon: hasSearchIcon ? const Icon(Icons.search, color: Colors.black54) : null,
        ),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildLocationBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('출발 집결 장소', style: TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: darkGreen, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                const Expanded(child: Text('마포구청역 1번 출구 지상 버스베이', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                const Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('목적지 (도착 장소)', style: TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFC04020), shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _destController,
                    decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    try {
                      Kpostal? result = await Navigator.push(context, MaterialPageRoute(builder: (_) => KpostalView()));
                      if (result != null) {
                        setState(() {
                          _destController.text = result.address;
                        });
                      }
                    } catch (e) {
                      print("Kpostal error: \$e");
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.search, color: Colors.black87, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(8)),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('출발 일시', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                              if (d != null) {
                                final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                if (t != null) setState(() { _depDate = d; _depTime = t; });
                              }
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_formatDate(_depDate, '출발 날짜 선택'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text(_formatTime(_depTime, '시간 선택'), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                ],
                              ),
                            ),
                          ),
                          Icon(Icons.calendar_today, size: 16, color: Colors.black54)
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('복귀 예정', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('당일 복귀', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC04020))),
                              const Text('오후 18:00', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                          const Icon(Icons.access_time, size: 16, color: Colors.black54)
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSeatSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('모집 인원 설정', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('드라이버 본인을 제외한 탑승 이웃', style: TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              ),
              Container(
                decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed: () => setState(() { if(_seats > 1) _seats--; }),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                    Text('', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16, color: Colors.white),
                      style: IconButton.styleFrom(backgroundColor: darkGreen),
                      onPressed: () => setState(() { if(_seats < 3) _seats++; }),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSeatIcon('드라이버 (나)', Icons.airline_seat_recline_extra, true, true),
                _buildSeatIcon('보조석', Icons.looks_one, _seats >= 1, false),
                _buildSeatIcon('뒷좌석 좌', Icons.looks_two, _seats >= 2, false),
                _buildSeatIcon('뒷좌석 우', Icons.looks_3, _seats >= 3, false),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: terracotta.withOpacity(0.05), border: Border.all(color: terracotta.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: terracotta, size: 16),
                const SizedBox(width: 8),
                const Expanded(child: Text('쾌적한 이동과 어색함 없는 대화를 위해 최대 3~4인 소규모 동승으로만 운영됩니다.', style: TextStyle(fontSize: 11, color: Colors.black87, height: 1.4))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSeatIcon(String label, IconData icon, bool isActive, bool isDriver) {
    return Column(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: isActive ? (isDriver ? badgeGreen.withOpacity(0.5) : darkGreen) : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isActive ? (isDriver ? darkGreen : Colors.white) : Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.black87 : Colors.grey)),
      ],
    );
  }

  Widget _buildCarSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('운행 차량 정보', trailing: '기본 등록차량', icon: Icons.directions_car_outlined),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                  child: const Icon(Icons.directions_car, color: Colors.black87),
                ),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                        children: [
                          Text('기아 EV6 Long Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(width: 6),
                          Container(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Color(0xFFA5D6A7), borderRadius: BorderRadius.all(Radius.circular(10))), child: Text('전기차', style: TextStyle(fontSize: 9, color: Color(0xFF1B4D3E), fontWeight: FontWeight.bold))),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text('마포구 인증 차량 · 쾌적한 실내 청소됨', style: TextStyle(fontSize: 11, color: Colors.black54)),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('탑승 배려 및 편의 옵션', style: TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 8),
          _buildCheckbox(Icons.smoke_free, '쾌적한 완전 금연 차량', _isNonSmoking, (val) => setState(() => _isNonSmoking = val!)),
          _buildCheckbox(Icons.pets, '소형 반려동물 케이지 동반 가능', _isPetFriendly, (val) => setState(() => _isPetFriendly = val!)),
          _buildCheckbox(Icons.luggage, '트렁크 짐 보관 여유 (백팩 / 피크닉 바구니)', _hasTrunkSpace, (val) => setState(() => _hasTrunkSpace = val!)),
        ],
      ),
    );
  }

  Widget _buildCheckbox(IconData icon, String title, bool value, Function(bool?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(8)),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        title: Row(
          children: [
            Icon(icon, size: 16, color: value ? terracotta : Colors.black54),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
          ],
        ),
        activeColor: darkGreen,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  Widget _buildTagSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('드라이브 분위기 취향 태그', trailing: '복수 선택', icon: Icons.local_offer_outlined),
          const Text('어떤 분위기로 함께 이동하고 싶나요? 탑승 이웃 매칭에 반영됩니다.', style: TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _allTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return GestureDetector(
                onTap: () => setState(() {
                  if (isSelected) _selectedTags.remove(tag);
                  else _selectedTags.add(tag);
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? darkGreen : Colors.white,
                    border: Border.all(color: isSelected ? darkGreen : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tag, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                      if (isSelected) const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.check, color: Colors.white, size: 14)),
                    ],
                  ),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildCostSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
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
                  Text('예상 정산 금액 산출', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(12)), child: const Text('자동 1/N 정산', style: TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 16),
          _buildCostRow('예상 전기차 충전비 (왕복 210km)', '18,500원'),
          const SizedBox(height: 8),
          _buildCostRow('고속도로 통행료 (서울-춘천 왕복)', '13,600원'),
          const SizedBox(height: 8),
          _buildCostRow('소양강 공영주차장 예상비', '4,000원'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: Colors.black12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('1인 예상 정산금', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                  SizedBox(height: 4),
                  Text('총 36,100원 ÷ 4명(드라이버 포함)', style: TextStyle(fontSize: 10, color: Colors.black54)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('약 9,000원', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: terracotta)),
                  const SizedBox(height: 4),
                  const Text('이동 완료 후 앱 내 간편결제', style: TextStyle(fontSize: 10, color: Colors.black54)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          const Text('* 소소카는 순수 실비(유류비/통행료)만을 동승자에게 나눕니다. 운전자의 영리 목적 수수료는 포함되지 않습니다.', style: TextStyle(fontSize: 10, color: Colors.grey, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildCostRow(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        Text(amount, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      color: background,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('다음 단계 (일정 상세 & 쉼표 등록)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security, size: 12, color: Colors.grey),
                SizedBox(width: 4),
                Text('이웃 친화&매너 드라이버 안심 등록 중', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 1, // "모집하기" tab
      type: BottomNavigationBarType.fixed,
      selectedItemColor: darkGreen,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: '탐색'),
        const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: '모집하기'),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.chat_bubble_outline),
              Positioned(
                right: -4, top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Color(0xFFB53D25), shape: BoxShape.circle),
                  child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
          label: '동행채팅',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.directions_car_outlined), activeIcon: Icon(Icons.directions_car), label: '내여행'),
      ],
    );
  }
}
