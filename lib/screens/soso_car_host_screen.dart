import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'soso_car_host_step2_screen.dart';
import 'package:kpostal/kpostal.dart';

class OOMUHostScreen extends StatefulWidget {
  const OOMUHostScreen({super.key});

  @override
  State<OOMUHostScreen> createState() => _OOMUHostScreenState();
}

class _OOMUHostScreenState extends State<OOMUHostScreen> {
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
    '#잔잔한음악', '#풍경감상 위주', '#카페투어 ☕️', 
    '#맛있는식사 🍚', '#사진촬영 위주', '#이색즐길거리 🎯'
  ];
  final Set<String> _selectedTags = {'#잔잔한음악', '#풍경감상 위주', '#카페투어 ☕️', '#맛있는식사 🍚'};

  final TextEditingController _titleController = TextEditingController(text: '춘천 소양강 드라이브 & 닭갈비 투어 🚗');
  final TextEditingController _destController = TextEditingController(text: '강원 춘천시 소양강스카이워크');
  final TextEditingController _meetingController = TextEditingController(text: '마포구청역 1번출구 지상 버스베이');
  
  double? _meetingLat;
  double? _meetingLng;
  double? _destLat;
  double? _destLng;

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

  void _showDateTimePicker(bool isDeparture) {
    DateTime tempDate = DateTime.now();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext builder) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('취소', style: TextStyle(color: Colors.grey)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text('날짜 및 시간 선택', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  CupertinoButton(
                    child: const Text('완료', style: TextStyle(color: Color(0xFF1B4D3E), fontWeight: FontWeight.bold)),
                    onPressed: () {
                      setState(() {
                        if (isDeparture) {
                          _depDate = tempDate;
                          _depTime = TimeOfDay.fromDateTime(tempDate);
                        } else {
                          _retDate = tempDate;
                          _retTime = TimeOfDay.fromDateTime(tempDate);
                        }
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: DateTime.now(),
                  minimumDate: DateTime.now(),
                  maximumDate: DateTime.now().add(const Duration(days: 365)),
                  onDateTimeChanged: (DateTime newDateTime) {
                    tempDate = newDateTime;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitForm() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => OOMUHostStep2Screen(
      meetingAddr: _meetingController.text,
      meetingLat: _meetingLat,
      meetingLng: _meetingLng,
      destAddr: _destController.text,
      destLat: _destLat,
      destLng: _destLng,
      depDate: _depDate,
      depTime: _depTime,
      retDate: _retDate,
      retTime: _retTime,
      seats: _seats,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTitleSection(),
            _buildLocationSection(),
            _buildVehicleInfoSection(),
            _buildCostSection(),
            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      bottomSheet: _buildBottomButton(),
      bottomNavigationBar: _buildBottomNav(),
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
                        const Text('STEP 1', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.black87)),
                        Text(' / 3', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade400)),
                      ],
                    ),
                    Text('모임 기본 정보', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
              ),
              Stack(
                children: [
                  Container(width: double.infinity, height: 3, color: Colors.grey.shade200),
                  FractionallySizedBox(
                    widthFactor: 0.3333333333333333,
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

  Widget _buildTitleSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withOpacity(0.04)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('모집글 제목', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
          TextField(
            controller: _titleController,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.only(top: 8, bottom: 4),
              border: InputBorder.none,
            ),
          ),
          const Divider(height: 1, color: Colors.black12),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withOpacity(0.04)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('내 차', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, color: Colors.black87, size: 14),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: darkGreen, shape: BoxShape.circle)),
                    Container(width: 2, height: 40, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(vertical: 4)),
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFC04020), shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLocationBox('출발 집결 장소', _meetingController, true),
                      const SizedBox(height: 16),
                      _buildLocationBox('목적지 (도착 장소)', _destController, false),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black12),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('출발 일시', style: TextStyle(fontSize: 11, color: Colors.black54)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showDateTimePicker(true);
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
                            const Icon(Icons.calendar_today, size: 16, color: Colors.black54)
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
                            GestureDetector(
                              onTap: () {
                                _showDateTimePicker(false);
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_formatDate(_retDate, '복귀 날짜 선택'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC04020))),
                                    Text(_formatTime(_retTime, '시간 선택'), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                  ],
                                ),
                              ),
                            ),
                            const Icon(Icons.access_time, size: 16, color: Colors.black54)
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLocationBox(String label, TextEditingController controller, bool isMeeting) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
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
                        controller.text = result.address;
                        if (isMeeting) {
                          _meetingLat = result.latitude;
                          _meetingLng = result.longitude;
                        } else {
                          _destLat = result.latitude;
                          _destLng = result.longitude;
                        }
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
        )
      ],
    );
  }

  Widget _buildVehicleInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withOpacity(0.04)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.directions_car, size: 18),
                  SizedBox(width: 8),
                  Text('차량 및 탑승 정보', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                ],
              ),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(12)), child: const Text('차주 정보 연동됨', style: TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: terracotta.withOpacity(0.05), border: Border.all(color: terracotta.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      const Row(
                        children: [
                          Text('기아 EV6 Long Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(width: 6),
                          Icon(Icons.bolt, color: Colors.amber, size: 16),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('123가 4567 • 전기차 • 5인승', style: TextStyle(color: Colors.black54, fontSize: 12)),
                      const SizedBox(height: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: badgeGreen, borderRadius: BorderRadius.circular(10)), child: const Text('차주검증 완료', style: TextStyle(fontSize: 9, color: Color(0xFF1B4D3E), fontWeight: FontWeight.bold))),
                    ],
                  ),
                )
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: Colors.black12)),
          const Text('모집 인원', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSeatIcon('보조석', Icons.looks_one, _seats >= 1, false),
                _buildSeatIcon('뒷좌석 1', Icons.looks_two, _seats >= 2, false),
                _buildSeatIcon('뒷좌석 2', Icons.looks_3, _seats >= 3, false),
                _buildSeatIcon('뒷좌석 3', Icons.looks_4, _seats >= 4, true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(8)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: terracotta, size: 16),
                const SizedBox(width: 8),
                const Expanded(child: Text('쾌적한 이동과 탑승객 간 소통을 위해 최대 3~4인 규모의 탑승을 권장합니다.', style: TextStyle(fontSize: 11, color: Colors.black87, height: 1.4))),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: Colors.black12)),
          const Text('탑승객 조건', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          _buildCheckbox(Icons.smoke_free, '차량 내 완전 금연', _isNonSmoking, (val) => setState(() => _isNonSmoking = val!)),
          _buildCheckbox(Icons.pets, '소형 반려동물 케이지 동반 가능', _isPetFriendly, (val) => setState(() => _isPetFriendly = val!)),
          _buildCheckbox(Icons.luggage, '트렁크 짐 보관 가능 (백팩/기내용 캐리어)', _hasTrunkSpace, (val) => setState(() => _hasTrunkSpace = val!)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: Colors.black12)),
          const Text('드라이브 태그', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          const Text('어떤 분위기로 이동하고 싶나요? 드라이브 성향을 알려주세요.', style: TextStyle(fontSize: 11, color: Colors.black54)),
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

  Widget _buildSeatIcon(String label, IconData icon, bool isActive, bool isDisabled) {
    return GestureDetector(
      onTap: () {
        if (!isDisabled) {
          setState(() {
            if (label == '보조석') _seats = 1;
            if (label == '뒷좌석 1') _seats = 2;
            if (label == '뒷좌석 2') _seats = 3;
            if (label == '뒷좌석 3') _seats = 4;
          });
        }
      },
      child: Column(
        children: [
          Icon(icon, size: 32, color: isDisabled ? Colors.grey.shade300 : (isActive ? darkGreen : Colors.grey.shade300)),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.black87 : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCheckbox(IconData icon, String title, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, size: 16, color: value ? terracotta : Colors.black54),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: darkGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildCostSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withOpacity(0.04)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 12, offset: const Offset(0, 4))]),
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
                  Text('예상 정산 금액', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                ],
              ),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(12)), child: const Text('자동 1/N 정산', style: TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 16),
          _buildCostRow('예상 전기차 충전비 (왕복 210km)', '18,500원'),
          const SizedBox(height: 8),
          _buildCostRow('예상 통행료 (서울-춘천 왕복)', '13,600원'),
          const SizedBox(height: 8),
          _buildCostRow('공영주차장 예상 주차비', '4,000원'),
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
                  const Text('이동 완료 후 자동 간편결제', style: TextStyle(fontSize: 10, color: Colors.black54)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          const Text('* 우무(OOMU)는 순수 실비(유류비/통행료)만을 탑승객과 나누며, 운전자의 영리 목적 수수료는 포함되지 않습니다.', style: TextStyle(fontSize: 10, color: Colors.grey, height: 1.4)),
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
                    Text('다음 단계 (확인 & 등록하기)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: Colors.white)),
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
                Text('환경 친화&매너 드라이빙 약속 동의', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 1, // "만들기" tab
      type: BottomNavigationBarType.fixed,
      selectedItemColor: darkGreen,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: '탐색'),
        const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: '만들기'),
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
          label: '채팅',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.directions_car_outlined), activeIcon: Icon(Icons.directions_car), label: '내 차'),
      ],
    );
  }
}
