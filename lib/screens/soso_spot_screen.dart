import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_image.dart';
import 'chat_screen.dart';

class SoSoSpotScreen extends StatefulWidget {
  const SoSoSpotScreen({super.key});

  @override
  State<SoSoSpotScreen> createState() => _SoSoSpotScreenState();
}

class _SoSoSpotScreenState extends State<SoSoSpotScreen> {
  final Color textPrimary = const Color(0xFF111111);
  final Color textSecondary = const Color(0xFF767676);
  final Color surfaceColor = const Color(0xFFF5F5F7);
  final Color coralAccent = const Color(0xFFFF5E36);
  final Color orangeAccent = const Color(0xFFFF8A3D);

  int _selectedFilterIndex = 0;
  final List<String> _filters = ['전체 스팟', '⚡ 10분 이내', '☕ 카페 & 디저트', '🍻 동네 술 한잔', '🏃 야외 액티비티'];

  late Timer _ticker;
  int _secondsRemaining = 840; // 14 mins

  final List<Map<String, dynamic>> _spots = [
    {
      'id': 'spot_01',
      'title': '홍대입구역 9번 출구 인생네컷 & 와플 🧇',
      'location': '마포구 홍대입구역 9번 출구 앞',
      'distance': '180m',
      'timeLeft': '8분 남음',
      'category': '카페 & 디저트',
      'members': '2/4',
      'host': '달콤한와플',
      'hostAvatar': 'assets/images/kr_female_2.jpg',
      'manner': 42.1,
      'tags': ['10분컷', '즉시합류', '인생네컷', '디저트'],
      'image': 'assets/images/cover_cafe.jpg',
      'isJoined': false,
    },
    {
      'id': 'spot_02',
      'title': '연남동 연트럴파크 돗자리 캔맥주 급구 🍺',
      'location': '마포구 경의선숲길 잔디광장',
      'distance': '350m',
      'timeLeft': '12분 남음',
      'category': '동네 술 한잔',
      'members': '3/4',
      'host': '연트럴피플',
      'hostAvatar': 'assets/images/kr_male_2.jpg',
      'manner': 39.4,
      'tags': ['돗자리구비', '노상맥주', '소셜다이닝'],
      'image': 'assets/images/cover_wine.jpg',
      'isJoined': false,
    },
    {
      'id': 'spot_03',
      'title': '성수동 서울숲 잔디마당 플랫화이트 번개 ☕',
      'location': '성동구 서울숲 메인 출구',
      'distance': '520m',
      'timeLeft': '15분 남음',
      'category': '카페 & 디저트',
      'members': '1/3',
      'host': '성수동힙스터',
      'hostAvatar': 'assets/images/kr_female_3.jpg',
      'manner': 43.0,
      'tags': ['에스프레소', '서울숲', '감성스팟'],
      'image': 'assets/images/cover_cafe.jpg',
      'isJoined': false,
    },
    {
      'id': 'spot_04',
      'title': '망원 한강공원 야경 산책 & 라면 먹방 🏃',
      'location': '마포구 망원 한강공원 편의점 앞',
      'distance': '750m',
      'timeLeft': '22분 남음',
      'category': '야외 액티비티',
      'members': '2/4',
      'host': '망원라이더',
      'hostAvatar': 'assets/images/kr_male_1.jpg',
      'manner': 41.5,
      'tags': ['한강라면', '야외 액티비티', '힐링'],
      'image': 'assets/images/cover_running.jpg',
      'isJoined': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  String _formatTimer(int totalSecs) {
    int m = totalSecs ~/ 60;
    int s = totalSecs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _showJoinModal(Map<String, dynamic> spot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFE5E5EA), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFF5E36), Color(0xFFFF8A3D)]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('⚡ 소소스팟 즉시 합류', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const Spacer(),
                  Text('거리 ${spot['distance']}', style: TextStyle(color: orangeAccent, fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                spot['title'],
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: textPrimary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: orangeAccent),
                  const SizedBox(width: 4),
                  Expanded(child: Text(spot['location'], style: TextStyle(fontSize: 13, color: textSecondary))),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: appImg(spot['hostAvatar']),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${spot['host']} (호스트)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                        const SizedBox(height: 2),
                        Text('매너온도 ${spot['manner']}°C • 현재 ${spot['members']} 참여', style: TextStyle(fontSize: 12, color: textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: coralAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      spot['isJoined'] = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎉 [${spot['title']}] 스팟에 즉시 합류했습니다! 채팅방으로 이동합니다.'),
                        backgroundColor: coralAccent,
                      ),
                    );
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
                  },
                  child: const Text(
                    '지금 바로 참여하기 (채팅방 입장)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateSpotModal() {
    final titleCtrl = TextEditingController();
    final locationCtrl = TextEditingController(text: '홍대입구역 9번 출구 앞');
    int targetMinutes = 15;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(color: const Color(0xFFE5E5EA), borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 18),
                Text('⚡ 소소스팟 번개 개설하기', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary)),
                const SizedBox(height: 6),
                Text('지금 주변 10~30분 이내에 만날 즉석 모임을 만들어보세요.', style: TextStyle(fontSize: 13, color: textSecondary)),
                const SizedBox(height: 20),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: '스팟 모임 제목',
                    hintText: '예) 15분 뒤 연트럴파크 벤치 커피 한잔!',
                    filled: true,
                    fillColor: surfaceColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationCtrl,
                  decoration: InputDecoration(
                    labelText: '만날 장소',
                    filled: true,
                    fillColor: surfaceColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                Text('모임 집결 시간', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
                const SizedBox(height: 8),
                Row(
                  children: [10, 15, 20, 30].map((mins) {
                    final isSel = targetMinutes == mins;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => targetMinutes = mins),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel ? coralAccent : surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$mins분 후',
                            style: TextStyle(
                              color: isSel ? Colors.white : textPrimary,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: coralAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      final title = titleCtrl.text.trim().isEmpty ? '홍대 즉석 번개 스팟 ⚡' : titleCtrl.text.trim();
                      setState(() {
                        _spots.insert(0, {
                          'id': 'spot_${DateTime.now().millisecondsSinceEpoch}',
                          'title': title,
                          'location': locationCtrl.text,
                          'distance': '내 위치 (0m)',
                          'timeLeft': '$targetMinutes분 남음',
                          'category': '번개/스팟',
                          'members': '1/4',
                          'host': '매운맛킬러',
                          'hostAvatar': 'assets/images/kr_female_1.jpg',
                          'manner': 41.2,
                          'tags': ['방금개설', '실시간', '소소스팟'],
                          'image': 'assets/images/cover_food.jpg',
                          'isJoined': true,
                        });
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('⚡ [$title] 소소스팟이 개설되었습니다!'), backgroundColor: coralAccent),
                      );
                    },
                    child: const Text('스팟 즉시 개설하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF5E36), Color(0xFFFF8A3D)]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('⚡ LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
            ),
            const SizedBox(width: 8),
            Text('소소스팟 (SoSo Spot)', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location, color: orangeAccent),
            tooltip: '주변 스팟 새로고침',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📍 내 주변 1km 실시간 스팟을 새로고침했습니다')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1F1F24), Color(0xFF2E2E38)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: Color(0xFF34C759), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          const Text('실시간 번개 활성화', style: TextStyle(color: Color(0xFF34C759), fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Text('다음 자동 갱신 ${_formatTimer(_secondsRemaining)}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '지금 내 주변 10분 컷 핫플\n실시간으로 즉시 합류해보세요!',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, height: 1.3),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _showCreateSpotModal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFF5E36), Color(0xFFFF8A3D)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('스팟 개설', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter bar
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final isSel = _selectedFilterIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilterIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF1F1F24) : surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSel ? const Color(0xFF1F1F24) : const Color(0xFFE5E5EA)),
                    ),
                    child: Text(
                      _filters[index],
                      style: TextStyle(
                        color: isSel ? Colors.white : const Color(0xFF1F1F24),
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Spots List
          Expanded(
            child: Builder(
              builder: (context) {
                final filtered = _spots.where((spot) {
                  if (_selectedFilterIndex == 0) return true;
                  if (_selectedFilterIndex == 1) {
                    final left = spot['timeLeft']?.toString() ?? '';
                    final mins = int.tryParse(RegExp(r'\d+').firstMatch(left)?.group(0) ?? '99') ?? 99;
                    return mins <= 10;
                  }
                  final filterClean = _filters[_selectedFilterIndex].replaceAll(RegExp(r'[^가-힣a-zA-Z0-9 &]'), '').trim();
                  final cat = spot['category']?.toString() ?? '';
                  return cat.contains(filterClean) || filterClean.contains(cat);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: textSecondary.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        Text('해당 카테고리의 진행 중인 스팟이 없습니다.', style: TextStyle(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final spot = filtered[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEBEBEF)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 14, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFFFF0EB), borderRadius: BorderRadius.circular(6)),
                              child: Text(spot['timeLeft'], style: TextStyle(color: coralAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(6)),
                              child: Text(spot['category'], style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600, fontSize: 11)),
                            ),
                            const Spacer(),
                            Text(spot['distance'], style: TextStyle(color: orangeAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          spot['title'],
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: textSecondary),
                            const SizedBox(width: 4),
                            Expanded(child: Text(spot['location'], style: TextStyle(fontSize: 12, color: textSecondary))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: (spot['tags'] as List<String>).map((t) => Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(6)),
                            child: Text('#$t', style: const TextStyle(fontSize: 11, color: Color(0xFF555555), fontWeight: FontWeight.w600)),
                          )).toList(),
                        ),
                        const SizedBox(height: 14),
                        Divider(height: 1, color: surfaceColor),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundImage: appImg(spot['hostAvatar']),
                            ),
                            const SizedBox(width: 8),
                            Text(spot['host'], style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary)),
                            const SizedBox(width: 6),
                            Text('${spot['manner']}°C', style: TextStyle(fontSize: 12, color: orangeAccent, fontWeight: FontWeight.w700)),
                            const Spacer(),
                            Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(6)),
                              child: Text('${spot['members']} 참여', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textPrimary)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: spot['isJoined'] == true ? const Color(0xFF34C759) : coralAccent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              onPressed: () {
                                if (spot['isJoined'] == true) {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
                                } else {
                                  _showJoinModal(spot);
                                }
                              },
                              child: Text(
                                spot['isJoined'] == true ? '참여중 (채팅)' : '즉시 합류',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: coralAccent,
        elevation: 6,
        icon: const Icon(Icons.bolt, color: Colors.white),
        label: const Text('번개 스팟 열기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: _showCreateSpotModal,
      ),
    );
  }
}
