import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/ai_service.dart';
import '../../ui/oomu_button.dart';
import '../../ui/oomu_tokens.dart';
import '../../utils/app_image.dart';
import '../../utils/global_data.dart';
import '../../widgets/bouncy_tap.dart';

class ChatModals {
  static List<Map<String, dynamic>> _cachedStickers = [];

  static void preloadStickers() {
    try {
      if (Firebase.apps.isEmpty) return;
      if (_cachedStickers.isNotEmpty) return;
      FirebaseFirestore.instance
          .collection('config')
          .doc('curated_stickers')
          .get()
          .then((doc) {
        if (doc.exists) {
          final data = doc.data();
          final rawList = data?['stickers'] as List<dynamic>? ?? [];
          if (rawList.isNotEmpty) {
            _cachedStickers = rawList
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
          }
        }
      }).catchError((_) {});
    } catch (_) {}
  }

  static final List<Map<String, dynamic>> _fallbackStickers = [
    {'rank': 1, 'title': '생각 중', 'url': 'https://wsrv.nl/?url=https%3A%2F%2Fmedia4.giphy.com%2Fmedia%2F3o7TKTDnUxE0g2fSE8%2Fgiphy.gif'},
    {'rank': 2, 'title': '축하해', 'url': 'https://wsrv.nl/?url=https%3A%2F%2Fmedia1.giphy.com%2Fmedia%2Fartj92V8o75VPL7AeQ%2Fgiphy.gif'},
    {'rank': 3, 'title': '감사해요', 'url': 'https://wsrv.nl/?url=https%3A%2F%2Fmedia3.giphy.com%2Fmedia%2FosAcIG550CLR32835E%2Fgiphy.gif'},
    {'rank': 4, 'title': '하트 뿅뿅', 'url': 'https://wsrv.nl/?url=https%3A%2F%2Fmedia3.giphy.com%2Fmedia%2FM90mJvfWfd5mbUuULX%2Fgiphy.gif'},
    {'rank': 5, 'title': '따뜻한 포옹', 'url': 'https://wsrv.nl/?url=https%3A%2F%2Fmedia4.giphy.com%2Fmedia%2F3M4NpbLCTxBqU%2Fgiphy.gif'},
    {'rank': 6, 'title': '웃겨요', 'url': 'https://wsrv.nl/?url=https%3A%2F%2Fmedia2.giphy.com%2Fmedia%2F10JhviFuU2gWD6%2Fgiphy.gif'},
  ];

  static void showAttachmentMenu(
    BuildContext context, {
    required VoidCallback onSticker,
    required VoidCallback onPhoto,
    required VoidCallback onLocation,
    required VoidCallback onHotspot,
    required VoidCallback onSchedule,
    required VoidCallback onPoll,
    required VoidCallback onSafeReturn,
    required VoidCallback onAiTopics,
    required VoidCallback onProfileExchange,
    required VoidCallback onSecretAfter,
    required VoidCallback onReview,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.only(
          top: OomuTokens.s12,
          left: OomuTokens.s20,
          right: OomuTokens.s20,
          bottom: OomuTokens.s24,
        ),
        decoration: const BoxDecoration(
          color: OomuTokens.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(OomuTokens.r24)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: OomuTokens.border,
                      borderRadius: BorderRadius.circular(OomuTokens.r8),
                    ),
                  ),
                ),
                const SizedBox(height: OomuTokens.s16),
                const Row(
                  children: [
                    Icon(Icons.dashboard_customize_rounded,
                        size: 18, color: OomuTokens.coral),
                    SizedBox(width: OomuTokens.s8),
                    Text(
                      '모임 도구 및 공유',
                      style: TextStyle(
                        fontSize: OomuTokens.fs16,
                        fontWeight: FontWeight.w700,
                        color: OomuTokens.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: OomuTokens.s16),
                Wrap(
                  spacing: OomuTokens.s16,
                  runSpacing: OomuTokens.s16,
                  alignment: WrapAlignment.start,
                  children: [
                    _buildIcon(Icons.sentiment_satisfied_alt_rounded, '인기 움짤',
                        onTap: () {
                      Navigator.pop(ctx);
                      onSticker();
                    }),
                    _buildIcon(Icons.photo_library_rounded, '사진/앨범', onTap: () {
                      Navigator.pop(ctx);
                      onPhoto();
                    }),
                    _buildIcon(Icons.location_on_rounded, '위치 공유', onTap: () {
                      Navigator.pop(ctx);
                      onLocation();
                    }),
                    _buildIcon(Icons.local_cafe_rounded, '동네 핫플', onTap: () {
                      Navigator.pop(ctx);
                      onHotspot();
                    }),
                    _buildIcon(Icons.event_available_rounded, '일정 제안', onTap: () {
                      Navigator.pop(ctx);
                      onSchedule();
                    }),
                    _buildIcon(Icons.how_to_vote_rounded, '투표 만들기', onTap: () {
                      Navigator.pop(ctx);
                      onPoll();
                    }),
                    _buildIcon(Icons.nightlife_rounded, '안심 귀가', onTap: () {
                      Navigator.pop(ctx);
                      onSafeReturn();
                    }),
                    _buildIcon(Icons.auto_awesome_rounded, 'AI 대화주제', onTap: () {
                      Navigator.pop(ctx);
                      onAiTopics();
                    }),
                    _buildIcon(Icons.badge_outlined, '프로필 교환', onTap: () {
                      Navigator.pop(ctx);
                      onProfileExchange();
                    }),
                    _buildIcon(Icons.favorite_rounded, '시크릿 애프터', onTap: () {
                      Navigator.pop(ctx);
                      onSecretAfter();
                    }),
                    _buildIcon(Icons.rate_review_rounded, '모임 후기', onTap: () {
                      Navigator.pop(ctx);
                      onReview();
                    }),
                  ],
                ),
                const SizedBox(height: OomuTokens.s20),
                const Center(
                  child: Text(
                    '선택한 도구 카드가 대화방 멤버들에게 실시간으로 공유돼요.',
                    style: TextStyle(
                        color: OomuTokens.textMuted, fontSize: OomuTokens.fs12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildIcon(IconData icon, String label,
      {required VoidCallback onTap}) {
    return BouncyTap(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: OomuTokens.surfaceMuted,
                borderRadius: BorderRadius.circular(OomuTokens.r16),
              ),
              child: Icon(icon, color: OomuTokens.textPrimary, size: 24),
            ),
            const SizedBox(height: OomuTokens.s8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: OomuTokens.fs11,
                fontWeight: FontWeight.w600,
                color: OomuTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showPhotoPicker(
    BuildContext context, {
    required Future<void> Function(ImageSource source) onPick,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: OomuTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(OomuTokens.r24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: OomuTokens.s24, vertical: OomuTokens.s20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '사진 공유',
                style: TextStyle(
                  fontSize: OomuTokens.fs16,
                  fontWeight: FontWeight.w700,
                  color: OomuTokens.textPrimary,
                ),
              ),
              const SizedBox(height: OomuTokens.s16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        onPick(ImageSource.camera);
                      },
                      borderRadius: BorderRadius.circular(OomuTokens.r12),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: OomuTokens.s16),
                        decoration: BoxDecoration(
                          color: OomuTokens.surfaceMuted,
                          borderRadius: BorderRadius.circular(OomuTokens.r12),
                          border: Border.all(color: OomuTokens.border),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.photo_camera_rounded,
                                color: OomuTokens.coral, size: 24),
                            SizedBox(height: OomuTokens.s8),
                            Text('사진 찍기',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: OomuTokens.fs12,
                                    color: OomuTokens.textPrimary)),
                            Text('카메라 촬영',
                                style: TextStyle(
                                    fontSize: OomuTokens.fs11,
                                    color: OomuTokens.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: OomuTokens.s12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        onPick(ImageSource.gallery);
                      },
                      borderRadius: BorderRadius.circular(OomuTokens.r12),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: OomuTokens.s16),
                        decoration: BoxDecoration(
                          color: OomuTokens.surfaceMuted,
                          borderRadius: BorderRadius.circular(OomuTokens.r12),
                          border: Border.all(color: OomuTokens.border),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.photo_library_rounded,
                                color: OomuTokens.coral, size: 24),
                            SizedBox(height: OomuTokens.s8),
                            Text('사진 불러오기',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: OomuTokens.fs12,
                                    color: OomuTokens.textPrimary)),
                            Text('갤러리/앨범',
                                style: TextStyle(
                                    fontSize: OomuTokens.fs11,
                                    color: OomuTokens.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showScheduleCreator(
    BuildContext context, {
    required Function(Map<String, dynamic> data) onCreated,
  }) {
    DateTime? selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay? selectedTime = const TimeOfDay(hour: 19, minute: 0);
    final TextEditingController locCtrl = TextEditingController();
    int maxMembers = 4;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final now = DateTime.now();
            final tomorrow = now.add(const Duration(days: 1));
            final daysUntilSat = (DateTime.saturday - now.weekday + 7) % 7;
            final thisSat = now.add(Duration(days: daysUntilSat == 0 ? 7 : daysUntilSat));
            final thisSun = thisSat.add(const Duration(days: 1));

            final List<Map<String, dynamic>> dateChips = [
              {'label': '오늘 (${now.month}/${now.day})', 'date': now},
              {'label': '내일 (${tomorrow.month}/${tomorrow.day})', 'date': tomorrow},
              {'label': '이번주 토 (${thisSat.month}/${thisSat.day})', 'date': thisSat},
              {'label': '이번주 일 (${thisSun.month}/${thisSun.day})', 'date': thisSun},
            ];

            final List<Map<String, dynamic>> timeChips = [
              {'label': '낮 12:00', 'time': const TimeOfDay(hour: 12, minute: 0)},
              {'label': '오후 2:00', 'time': const TimeOfDay(hour: 14, minute: 0)},
              {'label': '저녁 6:30', 'time': const TimeOfDay(hour: 18, minute: 30)},
              {'label': '저녁 7:00', 'time': const TimeOfDay(hour: 19, minute: 0)},
              {'label': '저녁 8:00', 'time': const TimeOfDay(hour: 20, minute: 0)},
            ];

            return Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: const BoxDecoration(
                  color: OomuTokens.surface,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(OomuTokens.r24)),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: OomuTokens.border,
                              borderRadius: BorderRadius.circular(OomuTokens.r8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Row(
                          children: [
                            Icon(Icons.event_available_rounded, color: OomuTokens.coral, size: 22),
                            SizedBox(width: OomuTokens.s8),
                            Text(
                              '상세 일정 제안하기',
                              style: TextStyle(
                                fontSize: OomuTokens.fs18,
                                fontWeight: FontWeight.w700,
                                color: OomuTokens.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '날짜와 장소를 선택해 단톡방 이웃들에게 투표를 제안해보세요.',
                          style: TextStyle(fontSize: 12, color: OomuTokens.textSecondary),
                        ),
                        const SizedBox(height: 18),

                        // 1. 날짜 퀵 선택 칩
                        const Text(
                          '모임 날짜',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: OomuTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ...dateChips.map((chip) {
                              final d = chip['date'] as DateTime;
                              final isSelected = selectedDate != null &&
                                  selectedDate!.year == d.year &&
                                  selectedDate!.month == d.month &&
                                  selectedDate!.day == d.day;
                              return ChoiceChip(
                                label: Text(chip['label'] as String),
                                selected: isSelected,
                                onSelected: (sel) {
                                  HapticFeedback.lightImpact();
                                  if (sel) setState(() => selectedDate = d);
                                },
                                selectedColor: OomuTokens.coral,
                                backgroundColor: OomuTokens.surfaceMuted,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.white : OomuTokens.textPrimary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected ? OomuTokens.coral : OomuTokens.border,
                                  ),
                                ),
                              );
                            }),
                            ActionChip(
                              avatar: const Icon(Icons.calendar_month_outlined, size: 14, color: OomuTokens.coral),
                              label: const Text('달력에서 선택'),
                              backgroundColor: OomuTokens.surfaceMuted,
                              labelStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: OomuTokens.coral,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(color: OomuTokens.coral),
                              ),
                              onPressed: () async {
                                final d = await showDatePicker(
                                  context: ctx,
                                  initialDate: selectedDate ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: OomuTokens.coral,
                                          onPrimary: Colors.white,
                                          surface: Colors.white,
                                          onSurface: OomuTokens.textPrimary,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (d != null) setState(() => selectedDate = d);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // 2. 시간 퀵 선택 칩
                        const Text(
                          '모임 시간',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: OomuTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ...timeChips.map((chip) {
                              final t = chip['time'] as TimeOfDay;
                              final isSelected = selectedTime != null &&
                                  selectedTime!.hour == t.hour &&
                                  selectedTime!.minute == t.minute;
                              return ChoiceChip(
                                label: Text(chip['label'] as String),
                                selected: isSelected,
                                onSelected: (sel) {
                                  HapticFeedback.lightImpact();
                                  if (sel) setState(() => selectedTime = t);
                                },
                                selectedColor: OomuTokens.coral,
                                backgroundColor: OomuTokens.surfaceMuted,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.white : OomuTokens.textPrimary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected ? OomuTokens.coral : OomuTokens.border,
                                  ),
                                ),
                              );
                            }),
                            ActionChip(
                              avatar: const Icon(Icons.schedule_rounded, size: 14, color: OomuTokens.coral),
                              label: const Text('직접 입력'),
                              backgroundColor: OomuTokens.surfaceMuted,
                              labelStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: OomuTokens.coral,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(color: OomuTokens.coral),
                              ),
                              onPressed: () async {
                                final t = await showTimePicker(
                                  context: ctx,
                                  initialTime: selectedTime ?? TimeOfDay.now(),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: OomuTokens.coral,
                                          onPrimary: Colors.white,
                                          surface: Colors.white,
                                          onSurface: OomuTokens.textPrimary,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (t != null) setState(() => selectedTime = t);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // 3. 모임 장소 (검색 버튼 연동)
                        const Text(
                          '모임 장소',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: OomuTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: locCtrl,
                          style: const TextStyle(
                              fontSize: OomuTokens.fs14,
                              color: OomuTokens.textPrimary),
                          decoration: InputDecoration(
                            hintText: '장소 이름 입력 또는 오른쪽 검색 버튼 탭',
                            hintStyle: const TextStyle(fontSize: 13, color: OomuTokens.textMuted),
                            prefixIcon: const Icon(Icons.place_rounded, color: OomuTokens.coral, size: 20),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  backgroundColor: OomuTokens.coral.withValues(alpha: 0.1),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.search, size: 16, color: OomuTokens.coral),
                                label: const Text(
                                  '장소 검색',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: OomuTokens.coral,
                                  ),
                                ),
                                onPressed: () {
                                  showHotspotSearch(context, onCreated: (place) {
                                    final pName = (place['name'] ?? place['title'] ?? '').toString();
                                    final pAddr = (place['address'] ?? '').toString();
                                    final combined = pAddr.isNotEmpty ? '$pName ($pAddr)' : pName;
                                    setState(() {
                                      locCtrl.text = combined;
                                    });
                                  });
                                },
                              ),
                            ),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(OomuTokens.r12),
                                borderSide:
                                    const BorderSide(color: OomuTokens.border)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(OomuTokens.r12),
                                borderSide:
                                    const BorderSide(color: OomuTokens.border)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(OomuTokens.r12),
                                borderSide:
                                    const BorderSide(color: OomuTokens.coral)),
                            filled: true,
                            fillColor: OomuTokens.surfaceMuted,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 4. 모임 인원 (칩 스타일)
                        const Text(
                          '희망 참여 인원',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: OomuTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [2, 3, 4, 6, 8].map((c) {
                            final isSelected = maxMembers == c;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text('$c명'),
                                selected: isSelected,
                                onSelected: (sel) {
                                  HapticFeedback.lightImpact();
                                  if (sel) setState(() => maxMembers = c);
                                },
                                selectedColor: OomuTokens.coral,
                                backgroundColor: OomuTokens.surfaceMuted,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.white : OomuTokens.textPrimary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: isSelected ? OomuTokens.coral : OomuTokens.border,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // 5. 제출 버튼
                        OomuButton(
                          label: '일정 공유 및 단톡 투표 시작',
                          onPressed: () {
                            final loc = locCtrl.text.trim();
                            if (selectedDate == null ||
                                selectedTime == null ||
                                loc.isEmpty) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(
                                      content: Text('날짜, 시간, 장소를 모두 입력해주세요.')));
                              return;
                            }
                            Navigator.pop(ctx);
                            onCreated({
                              'type': 'schedule',
                              'title': '새로운 일정이 제안되었습니다!',
                              'date':
                                  '${selectedDate!.month}월 ${selectedDate!.day}일',
                              'timeStr': selectedTime!.format(ctx),
                              'location': loc,
                              'maxMembers': maxMembers,
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static void showPollCreator(
    BuildContext context, {
    required Function(Map<String, dynamic> data) onCreated,
  }) {
    final TextEditingController titleCtrl = TextEditingController();
    final TextEditingController opt1Ctrl = TextEditingController();
    final TextEditingController opt2Ctrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(OomuTokens.s24),
          decoration: const BoxDecoration(
            color: OomuTokens.surface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(OomuTokens.r24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.how_to_vote, color: OomuTokens.coral),
                    SizedBox(width: OomuTokens.s8),
                    Text(
                      '투표 만들기',
                      style: TextStyle(
                        fontSize: OomuTokens.fs18,
                        fontWeight: FontWeight.w700,
                        color: OomuTokens.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: OomuTokens.s20),
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(
                      fontSize: OomuTokens.fs14, color: OomuTokens.textPrimary),
                  decoration: InputDecoration(
                    labelText: '투표 주제',
                    labelStyle: const TextStyle(
                        fontSize: OomuTokens.fs14,
                        color: OomuTokens.textSecondary),
                    filled: true,
                    fillColor: OomuTokens.surfaceMuted,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(OomuTokens.r12),
                        borderSide: const BorderSide(color: OomuTokens.border)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(OomuTokens.r12),
                        borderSide: const BorderSide(color: OomuTokens.border)),
                  ),
                ),
                const SizedBox(height: OomuTokens.s12),
                TextField(
                  controller: opt1Ctrl,
                  style: const TextStyle(
                      fontSize: OomuTokens.fs14, color: OomuTokens.textPrimary),
                  decoration: InputDecoration(
                    labelText: '옵션 1',
                    labelStyle: const TextStyle(
                        fontSize: OomuTokens.fs14,
                        color: OomuTokens.textSecondary),
                    filled: true,
                    fillColor: OomuTokens.surfaceMuted,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(OomuTokens.r12),
                        borderSide: const BorderSide(color: OomuTokens.border)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(OomuTokens.r12),
                        borderSide: const BorderSide(color: OomuTokens.border)),
                  ),
                ),
                const SizedBox(height: OomuTokens.s12),
                TextField(
                  controller: opt2Ctrl,
                  style: const TextStyle(
                      fontSize: OomuTokens.fs14, color: OomuTokens.textPrimary),
                  decoration: InputDecoration(
                    labelText: '옵션 2',
                    labelStyle: const TextStyle(
                        fontSize: OomuTokens.fs14,
                        color: OomuTokens.textSecondary),
                    filled: true,
                    fillColor: OomuTokens.surfaceMuted,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(OomuTokens.r12),
                        borderSide: const BorderSide(color: OomuTokens.border)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(OomuTokens.r12),
                        borderSide: const BorderSide(color: OomuTokens.border)),
                  ),
                ),
                const SizedBox(height: OomuTokens.s20),
                OomuButton(
                  label: '투표 등록',
                  onPressed: () {
                    if (titleCtrl.text.isEmpty ||
                        opt1Ctrl.text.isEmpty ||
                        opt2Ctrl.text.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('모든 항목을 입력해주세요.')));
                      return;
                    }
                    Navigator.pop(ctx);
                    onCreated({
                      'type': 'poll',
                      'title': '📊 ${titleCtrl.text}',
                      'opt1': opt1Ctrl.text,
                      'opt2': opt2Ctrl.text,
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void showHotspotSearch(
    BuildContext context, {
    required Function(Map<String, dynamic> data) onCreated,
  }) {
    String searchQuery = '';
    String selectedCategory = '전체';
    final String userLoc = globalData.userLocation.value.isNotEmpty
        ? globalData.userLocation.value
        : '전남 여수시 화장동';

    final List<Map<String, dynamic>> defaultHotspots = [
      {
        'name': '성산공원 둘레길 & 호수산책로',
        'category': '관광지',
        'address': '전남 여수시 화장동 824',
        'lat': 34.7685,
        'lng': 127.6534,
        'desc': '저녁 장미원 야경과 둘레길 산책이 예쁜 여수 화장동 대표 힐링 스팟',
        'photo': 'https://images.unsplash.com/photo-1519331379826-f10be5486c6f?w=400&q=80',
      },
      {
        'name': '선소상가 골목 & 낭만 먹자골목',
        'category': '술집',
        'address': '전남 여수시 시청동2길 선소상가 일대',
        'lat': 34.7612,
        'lng': 127.6588,
        'desc': '동네 이웃들과 2:2 소셜 다이닝 & 캐주얼 하이볼 한잔하기 좋은 핫플',
        'photo': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400&q=80',
      },
      {
        'name': '무선지구 감성 베이커리 & 소금빵 카페',
        'category': '카페',
        'address': '전남 여수시 화장동 무선중앙로',
        'lat': 34.7701,
        'lng': 127.6512,
        'desc': '매일 아침 갓 구운 천연발효 소금빵과 시그니처 크림라떼 명소',
        'photo': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&q=80',
      },
      {
        'name': '웅천친수공원 해변 산책로 & 오션뷰 카페',
        'category': '관광지',
        'address': '전남 여수시 웅천동 1692',
        'lat': 34.7480,
        'lng': 127.6740,
        'desc': '푸른 남해 바다와 인공 백사장이 펼쳐진 여수 핫플레이스',
        'photo': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80',
      },
      {
        'name': '학동 선소 유적지 & 밤바다 데크길',
        'category': '관광지',
        'address': '전남 여수시 시전동 708',
        'lat': 34.7570,
        'lng': 127.6620,
        'desc': '충무공 이순신 거북선 건조지이자 조용하게 밤산책하기 좋은 사적지',
        'photo': 'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=400&q=80',
      },
      {
        'name': '화장동 수제 디저트 베이킹 팩토리',
        'category': '빵집',
        'address': '전남 여수시 화장동 성산로 11',
        'lat': 34.7690,
        'lng': 127.6540,
        'desc': '버터 풍미 가득한 휘낭시에와 에그타르트 오픈런 맛집',
        'photo': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400&q=80',
      },
      {
        'name': '신기동 LP 레코드바 & 와인클럽',
        'category': '술집',
        'address': '전남 여수시 신기남3길',
        'lat': 34.7650,
        'lng': 127.6650,
        'desc': '재즈와 감성 바이닐을 들으며 가볍게 즐기는 내추럴 와인바',
        'photo': 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=400&q=80',
      },
      {
        'name': '여수 낭만포차 거리',
        'category': '술집',
        'address': '전남 여수시 하멜로 102',
        'lat': 34.7390,
        'lng': 127.7420,
        'desc': '여수 밤바다와 돌문어삼합, 하멜등대 야경 명소',
        'photo': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400&q=80',
      },
      {
        'name': '고소동 천사벽화마을 & 오션 루프탑 카페',
        'category': '카페',
        'address': '전남 여수시 고소동 453',
        'lat': 34.7380,
        'lng': 127.7380,
        'desc': '돌산대교와 여수 앞바다가 한눈에 내려다보이는 감성 루프탑 카페',
        'photo': 'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?w=400&q=80',
      },
      {
        'name': '오동도 동백나무 숲길 & 등대 산책',
        'category': '관광지',
        'address': '전남 여수시 수정동 산1-11',
        'lat': 34.7450,
        'lng': 127.7660,
        'desc': '사계절 푸른 동백꽃 터널과 바다 바람을 맞으며 걷는 여수 1경',
        'photo': 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=400&q=80',
      },
      {
        'name': '돌산공원 & 해상 케이블카 전망대',
        'category': '관광지',
        'address': '전남 여수시 돌산읍 돌산로 3600-1',
        'lat': 34.7300,
        'lng': 127.7400,
        'desc': '여수항과 돌산대교의 황홀한 일몰과 밤 야경을 조망할 수 있는 랜드마크',
        'photo': 'https://images.unsplash.com/photo-1477959858617-67f30bc75b82?w=400&q=80',
      },
      {
        'name': '망원 한강공원 & 망리단길 카페거리',
        'category': '카페',
        'address': '서울 마포구 망원동 457',
        'lat': 37.5540,
        'lng': 126.8980,
        'desc': '노을 지는 한강 피크닉과 아기자기한 독립 카페들이 모여있는 핫플',
        'photo': 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400&q=80',
      },
      {
        'name': '성수 서울숲 아틀리에길 & 브런치 카페',
        'category': '카페',
        'address': '서울 성동구 성수동1가 685',
        'lat': 37.5440,
        'lng': 127.0420,
        'desc': '숲과 트렌디한 팝업 스토어, 감성 테라스 브런치가 있는 성수동 중심',
        'photo': 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=400&q=80',
      },
      {
        'name': '을지로 세운상가 & 힙지로 와인바 골목',
        'category': '술집',
        'address': '서울 중구 을지로3가 95',
        'lat': 37.5660,
        'lng': 126.9920,
        'desc': '레트로 감성의 인쇄 골목 속 숨겨진 루프탑과 내추럴 와인바',
        'photo': 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=400&q=80',
      },
    ];

    List<Map<String, dynamic>> searchResults = List.from(defaultHotspots);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void performSearch(String query) {
              final trimmed = query.trim().toLowerCase();
              final filtered = defaultHotspots.where((h) {
                final matchCat = selectedCategory == '전체' ||
                    h['category'] == selectedCategory;
                final name = (h['name'] ?? '').toString().toLowerCase();
                final addr = (h['address'] ?? '').toString().toLowerCase();
                final desc = (h['desc'] ?? '').toString().toLowerCase();
                final cat = (h['category'] ?? '').toString().toLowerCase();
                final matchQ = trimmed.isEmpty ||
                    name.contains(trimmed) ||
                    addr.contains(trimmed) ||
                    desc.contains(trimmed) ||
                    cat.contains(trimmed);
                return matchCat && matchQ;
              }).toList();

              setState(() {
                searchResults = filtered;
              });
            }

            return Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                height: MediaQuery.of(ctx).size.height * 0.72,
                padding: const EdgeInsets.only(
                    top: OomuTokens.s20,
                    left: OomuTokens.s20,
                    right: OomuTokens.s20),
                decoration: const BoxDecoration(
                  color: OomuTokens.surface,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(OomuTokens.r24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: OomuTokens.border,
                          borderRadius: BorderRadius.circular(OomuTokens.r8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.travel_explore_rounded, color: OomuTokens.coral, size: 22),
                        const SizedBox(width: OomuTokens.s8),
                        const Text(
                          '동네 핫플 & 모임 장소 검색',
                          style: TextStyle(
                            fontSize: OomuTokens.fs18,
                            fontWeight: FontWeight.w700,
                            color: OomuTokens.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: OomuTokens.surfaceMuted,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            userLoc.split(' ').take(2).join(' '),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: OomuTokens.coral,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: OomuTokens.s16),
                    TextField(
                      autofocus: false,
                      onChanged: (val) {
                        searchQuery = val;
                        performSearch(val);
                      },
                      onSubmitted: (val) {
                        searchQuery = val;
                        performSearch(val);
                      },
                      style: const TextStyle(
                          fontSize: OomuTokens.fs14,
                          color: OomuTokens.textPrimary),
                      decoration: InputDecoration(
                        hintText: '장소 이름, 동네, 분위기 검색 (예: 성산, 선소, 카페)',
                        hintStyle: const TextStyle(
                            fontSize: 13,
                            color: OomuTokens.textMuted),
                        prefixIcon: const Icon(Icons.search,
                            color: OomuTokens.textSecondary, size: 20),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: OomuTokens.textMuted),
                                onPressed: () {
                                  searchQuery = '';
                                  performSearch('');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: OomuTokens.s16,
                            vertical: 10),
                        filled: true,
                        fillColor: OomuTokens.surfaceMuted,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(OomuTokens.r12),
                            borderSide:
                                const BorderSide(color: OomuTokens.border)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(OomuTokens.r12),
                            borderSide:
                                const BorderSide(color: OomuTokens.border)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(OomuTokens.r12),
                            borderSide:
                                const BorderSide(color: OomuTokens.coral)),
                      ),
                    ),
                    const SizedBox(height: OomuTokens.s12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            ['전체', '관광지', '카페', '술집', '빵집'].map((category) {
                          final isSelected = selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: OomuTokens.s8),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    selectedCategory = category;
                                  });
                                  performSearch(searchQuery);
                                }
                              },
                              selectedColor: OomuTokens.coral,
                              backgroundColor: OomuTokens.surfaceMuted,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(OomuTokens.rPill),
                                side: BorderSide(
                                    color: isSelected
                                        ? OomuTokens.coral
                                        : OomuTokens.border),
                              ),
                              labelStyle: TextStyle(
                                fontSize: OomuTokens.fs12,
                                color: isSelected
                                    ? Colors.white
                                    : OomuTokens.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: OomuTokens.s8),
                    const Divider(color: OomuTokens.border),
                    Expanded(
                      child: searchResults.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_off_outlined,
                                      size: 40, color: OomuTokens.textMuted),
                                  const SizedBox(height: 8),
                                  Text(
                                    '\'$searchQuery\' 관련 등록된 핫플이 없습니다.',
                                    style: const TextStyle(
                                        fontSize: OomuTokens.fs14,
                                        color: OomuTokens.textSecondary),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: searchResults.length,
                              separatorBuilder: (_, __) => const Divider(
                                  height: 1, color: OomuTokens.border),
                              itemBuilder: (context, index) {
                                final place = searchResults[index];
                                final photo = (place['photo'] ?? '').toString();
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 4),
                                  leading: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(OomuTokens.r8),
                                    child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: photo.isNotEmpty
                                          ? appNetImage(
                                              photo,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              color: OomuTokens.surfaceMuted,
                                              child: const Icon(Icons.place,
                                                  color: OomuTokens.coral),
                                            ),
                                    ),
                                  ),
                                      title: Text(place['name'] ?? '',
                                          style: const TextStyle(
                                              fontSize: OomuTokens.fs14,
                                              fontWeight: FontWeight.w700,
                                              color: OomuTokens.textPrimary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 2),
                                          Text(
                                            '${place['category']} • ${place['address']}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: OomuTokens.textSecondary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                          if (place['desc'] != null) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              place['desc']!,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: OomuTokens.textMuted),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                          ],
                                        ],
                                      ),
                                      trailing: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: OomuTokens.coral,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          minimumSize: Size.zero,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(OomuTokens.r8)),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          onCreated({
                                            'type': 'hotspot',
                                            'title': '☕ 우리 동네 핫플 추천!',
                                            'name': place['name'],
                                            'category': place['category'],
                                            'address': place['address'],
                                            'imageUrl': place['photo'],
                                            'photo': place['photo'],
                                            'lat': place['lat'],
                                            'lng': place['lng'],
                                          });
                                        },
                                        child: const Text('공유',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: OomuTokens.fs12)),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static void showReview(
    BuildContext context, {
    required Function(Map<String, dynamic> data) onCreated,
  }) {
    int selectedStars = 5;
    final TextEditingController textCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(OomuTokens.s24),
                decoration: const BoxDecoration(
                  color: OomuTokens.surface,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(OomuTokens.r24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.rate_review, color: OomuTokens.coral),
                        SizedBox(width: OomuTokens.s8),
                        Text(
                          '모임 후기 남기기',
                          style: TextStyle(
                            fontSize: OomuTokens.fs18,
                            fontWeight: FontWeight.w700,
                            color: OomuTokens.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: OomuTokens.s8),
                    const Text(
                      '이번 모임은 어떠셨나요? 별점과 솔직한 후기를 남겨주세요.\n작성하신 별점은 상대방의 매너 온도에 즉시 반영됩니다.',
                      style: TextStyle(
                          color: OomuTokens.textSecondary,
                          fontSize: OomuTokens.fs12,
                          height: 1.4),
                    ),
                    const SizedBox(height: OomuTokens.s20),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () =>
                                setState(() => selectedStars = index + 1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: OomuTokens.s4),
                              child: Icon(
                                index < selectedStars
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: OomuTokens.coral,
                                size: 40,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: OomuTokens.s20),
                    TextField(
                      controller: textCtrl,
                      maxLines: 3,
                      style: const TextStyle(
                          fontSize: OomuTokens.fs14,
                          color: OomuTokens.textPrimary),
                      decoration: InputDecoration(
                        hintText: '이웃들과 나눈 소중한 시간은 어떠셨나요?',
                        hintStyle: const TextStyle(
                            fontSize: OomuTokens.fs14,
                            color: OomuTokens.textMuted),
                        filled: true,
                        fillColor: OomuTokens.surfaceMuted,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(OomuTokens.r12),
                            borderSide:
                                const BorderSide(color: OomuTokens.border)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(OomuTokens.r12),
                            borderSide:
                                const BorderSide(color: OomuTokens.border)),
                      ),
                    ),
                    const SizedBox(height: OomuTokens.s20),
                    OomuButton(
                      label: '후기 남기기',
                      onPressed: () {
                        if (textCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('후기 내용을 입력해주세요.')));
                          return;
                        }
                        Navigator.pop(ctx);
                        onCreated({
                          'type': 'review',
                          'title': '⭐️ 모임 참석 후기 도착!',
                          'stars': selectedStars,
                          'review': textCtrl.text.trim(),
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static void showStickerPicker(
    BuildContext context, {
    required Function(Map<String, dynamic> data) onCreated,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: OomuTokens.surface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(OomuTokens.r24)),
          ),
          padding: const EdgeInsets.only(
              top: OomuTokens.s12,
              left: OomuTokens.s16,
              right: OomuTokens.s16,
              bottom: OomuTokens.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: OomuTokens.border,
                    borderRadius: BorderRadius.circular(OomuTokens.r8),
                  ),
                ),
              ),
              const SizedBox(height: OomuTokens.s12),
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded,
                      size: 20, color: OomuTokens.coral),
                  const SizedBox(width: OomuTokens.s8),
                  const Text(
                    '🔥 실시간 인기 움짤 스티커',
                    style: TextStyle(
                      fontSize: OomuTokens.fs16,
                      fontWeight: FontWeight.w700,
                      color: OomuTokens.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: OomuTokens.s8, vertical: OomuTokens.s4),
                    decoration: BoxDecoration(
                      color: OomuTokens.surfaceMuted,
                      borderRadius: BorderRadius.circular(OomuTokens.r8),
                    ),
                    child: const Text(
                      '인기순 TOP 100',
                      style: TextStyle(
                        fontSize: OomuTokens.fs11,
                        fontWeight: FontWeight.w700,
                        color: OomuTokens.coral,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: OomuTokens.s4),
              const Text(
                '탭하면 채팅방에 바로 전송돼요 · Cloudflare R2 무제한 CDN',
                style: TextStyle(
                    fontSize: OomuTokens.fs12, color: OomuTokens.textSecondary),
              ),
              const SizedBox(height: OomuTokens.s12),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('config')
                      .doc('curated_stickers')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      final rawList = data?['stickers'] as List<dynamic>? ?? [];
                      if (rawList.isNotEmpty) {
                        _cachedStickers = rawList
                            .map((e) => Map<String, dynamic>.from(e as Map))
                            .toList();
                      }
                    }
                    final stickers = _cachedStickers.isNotEmpty
                        ? _cachedStickers
                        : _fallbackStickers;

                    return GridView.builder(
                      controller: scrollController,
                      cacheExtent: 350,
                      addRepaintBoundaries: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: OomuTokens.s8,
                        crossAxisSpacing: OomuTokens.s8,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: stickers.length,
                      itemBuilder: (context, index) {
                        final s = stickers[index];
                        final rawUrl = (s['url'] ?? '').toString();
                        final rank = s['rank'] ?? (index + 1);
                        final title = (s['title'] ?? '').toString();

                        final thumbUrl = rawUrl.contains('w=')
                            ? rawUrl
                            : (rawUrl.contains('?')
                                ? '$rawUrl&w=160&h=160&fit=contain'
                                : '$rawUrl?w=160&h=160&fit=contain');

                        return BouncyTap(
                          scaleDown: 0.92,
                          onTap: () {
                            Navigator.pop(ctx);
                            String cleanUrl = rawUrl;
                            if (cleanUrl.contains('&output=jpg')) {
                              cleanUrl = cleanUrl.replaceAll(
                                  '&output=jpg', '&output=gif&n=-1');
                            } else if (!cleanUrl.contains('&output=gif')) {
                              cleanUrl = '$cleanUrl&output=gif&n=-1';
                            }
                            cleanUrl = cleanUrl
                                .replaceAll('&w=160&h=160&fit=contain', '')
                                .replaceAll('?w=160&h=160&fit=contain', '');
                            onCreated({
                              'type': 'sticker',
                              'imageUrl': cleanUrl,
                              'title': title,
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: OomuTokens.surfaceMuted,
                              borderRadius:
                                  BorderRadius.circular(OomuTokens.r12),
                              border: Border.all(color: OomuTokens.border),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.all(OomuTokens.s4),
                                    child: appNetImage(thumbUrl,
                                        fit: BoxFit.contain),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: OomuTokens.s4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: OomuTokens.textPrimary
                                          .withValues(alpha: 0.6),
                                      borderRadius:
                                          BorderRadius.circular(OomuTokens.r8),
                                    ),
                                    child: Text(
                                      '$rank위',
                                      style: const TextStyle(
                                        color: OomuTokens.surface,
                                        fontSize: OomuTokens.fs11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showAiTopics(
    BuildContext context, {
    required String meetingTitle,
    required Function(String topic) onSelectTopic,
  }) {
    final topics = oomuAi.generateIcebreakerTopics(
        meetingTitle: meetingTitle, seedOffset: 0);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: OomuTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(OomuTokens.r24)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(OomuTokens.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '편하게 꺼내볼 이야기',
                style: TextStyle(
                  fontSize: OomuTokens.fs18,
                  fontWeight: FontWeight.w700,
                  color: OomuTokens.textPrimary,
                ),
              ),
              const SizedBox(height: OomuTokens.s8),
              const Text(
                '질문을 고르면 입력창에 담겨요. 내용을 확인한 뒤 직접 보내세요.',
                style: TextStyle(
                  fontSize: OomuTokens.fs14,
                  height: 1.5,
                  color: OomuTokens.textSecondary,
                ),
              ),
              const SizedBox(height: OomuTokens.s16),
              FutureBuilder<List<Map<String, String>>>(
                future: topics,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('추천 질문을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.',
                        style: TextStyle(
                            fontSize: OomuTokens.fs14,
                            color: OomuTokens.textMuted));
                  }
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(OomuTokens.s20),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: OomuTokens.coral)),
                    );
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: snapshot.data!
                        .where((t) => (t['question'] ?? '').isNotEmpty)
                        .map((topic) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                topic['question']!,
                                style: const TextStyle(
                                  fontSize: OomuTokens.fs14,
                                  height: 1.5,
                                  color: OomuTokens.textPrimary,
                                ),
                              ),
                              trailing: const Icon(Icons.add,
                                  color: OomuTokens.coral),
                              onTap: () {
                                onSelectTopic(topic['question']!);
                                Navigator.pop(ctx);
                              },
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showSafetyDrawer(
    BuildContext context, {
    required String title,
    required int memberCount,
    required Future<void> Function() onLeave,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: OomuTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(OomuTokens.r24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(OomuTokens.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: OomuTokens.fs18,
                  fontWeight: FontWeight.w700,
                  color: OomuTokens.textPrimary,
                ),
              ),
              const SizedBox(height: OomuTokens.s8),
              Text(
                '$memberCount명 참여 중',
                style: const TextStyle(
                  fontSize: OomuTokens.fs14,
                  color: OomuTokens.textSecondary,
                ),
              ),
              const SizedBox(height: OomuTokens.s16),
              const Text(
                '메시지를 길게 누르면 복사하거나 신고·차단할 수 있어요.',
                style: TextStyle(
                  fontSize: OomuTokens.fs14,
                  height: 1.5,
                  color: OomuTokens.textSecondary,
                ),
              ),
              const SizedBox(height: OomuTokens.s16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.exit_to_app_rounded,
                    color: OomuTokens.textPrimary),
                title: const Text('대화방 나가기',
                    style: TextStyle(
                        fontSize: OomuTokens.fs14,
                        fontWeight: FontWeight.w600,
                        color: OomuTokens.textPrimary)),
                subtitle: const Text('대화방에서 나가도 모임 신청은 취소되지 않아요.',
                    style: TextStyle(
                        fontSize: OomuTokens.fs12,
                        color: OomuTokens.textMuted)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final leave = await showDialog<bool>(
                    context: context,
                    builder: (dialog) => AlertDialog(
                      backgroundColor: OomuTokens.surface,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(OomuTokens.r16)),
                      title: const Text('대화방에서 나갈까요?',
                          style: TextStyle(
                              fontSize: OomuTokens.fs16,
                              fontWeight: FontWeight.w700,
                              color: OomuTokens.textPrimary)),
                      content: const Text('다시 참여하려면 모임장의 대화방 연결이 필요해요.',
                          style: TextStyle(
                              fontSize: OomuTokens.fs14,
                              color: OomuTokens.textSecondary)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialog, false),
                          child: const Text('취소',
                              style: TextStyle(
                                  fontSize: OomuTokens.fs14,
                                  color: OomuTokens.textSecondary)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialog, true),
                          child: const Text('나가기',
                              style: TextStyle(
                                  fontSize: OomuTokens.fs14,
                                  fontWeight: FontWeight.w700,
                                  color: OomuTokens.coral)),
                        ),
                      ],
                    ),
                  );
                  if (leave == true) {
                    await onLeave();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showMessageActionSheet(
    BuildContext context, {
    required Map<String, dynamic> msg,
    required bool isMe,
    required Future<void> Function() onDelete,
    required VoidCallback onReport,
    required VoidCallback onBlock,
  }) {
    final text = (msg['text'] ?? '').toString();
    final sender = (msg['sender'] ?? '상대방').toString();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: OomuTokens.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(OomuTokens.r24)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: OomuTokens.s20, horizontal: OomuTokens.s16),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: OomuTokens.border,
                    borderRadius: BorderRadius.circular(OomuTokens.r8),
                  ),
                ),
                const SizedBox(height: OomuTokens.s16),
                ListTile(
                  leading: const Icon(Icons.copy_rounded,
                      color: OomuTokens.textPrimary),
                  title: const Text('메시지 내용 복사',
                      style: TextStyle(
                          fontSize: OomuTokens.fs14,
                          fontWeight: FontWeight.w600,
                          color: OomuTokens.textPrimary)),
                  onTap: () {
                    Navigator.pop(ctx);
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('📋 메시지가 클립보드에 복사되었습니다.')),
                    );
                  },
                ),
                if (isMe)
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded,
                        color: OomuTokens.coral),
                    title: const Text('메시지 삭제',
                        style: TextStyle(
                            fontSize: OomuTokens.fs14,
                            color: OomuTokens.coral,
                            fontWeight: FontWeight.w600)),
                    subtitle: const Text('이 메시지를 대화방에서 완전히 삭제합니다',
                        style: TextStyle(
                            fontSize: OomuTokens.fs12,
                            color: OomuTokens.textMuted)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dCtx) => AlertDialog(
                          backgroundColor: OomuTokens.surface,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(OomuTokens.r16)),
                          title: const Text('메시지를 삭제할까요?',
                              style: TextStyle(
                                  fontSize: OomuTokens.fs16,
                                  fontWeight: FontWeight.w700,
                                  color: OomuTokens.textPrimary)),
                          content: const Text(
                              '삭제된 메시지는 대화방 참여자 모두에게 더 이상 보이지 않아요.',
                              style: TextStyle(
                                  fontSize: OomuTokens.fs14,
                                  color: OomuTokens.textSecondary)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dCtx, false),
                              child: const Text('취소',
                                  style: TextStyle(
                                      fontSize: OomuTokens.fs14,
                                      color: OomuTokens.textSecondary)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(dCtx, true),
                              child: const Text('삭제',
                                  style: TextStyle(
                                      fontSize: OomuTokens.fs14,
                                      color: OomuTokens.coral,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await onDelete();
                      }
                    },
                  ),
                if (!isMe) ...[
                  ListTile(
                    leading: const Icon(Icons.flag_outlined,
                        color: OomuTokens.textSecondary),
                    title: const Text('이 메시지 신고하기',
                        style: TextStyle(
                            fontSize: OomuTokens.fs14,
                            color: OomuTokens.textPrimary,
                            fontWeight: FontWeight.w600)),
                    subtitle: const Text('부적절한 언어, 스팸, 혐오 표현 등',
                        style: TextStyle(
                            fontSize: OomuTokens.fs12,
                            color: OomuTokens.textMuted)),
                    onTap: () {
                      Navigator.pop(ctx);
                      onReport();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.block_rounded,
                        color: OomuTokens.textSecondary),
                    title: Text('$sender님 차단하기',
                        style: const TextStyle(
                            fontSize: OomuTokens.fs14,
                            color: OomuTokens.textPrimary,
                            fontWeight: FontWeight.w600)),
                    subtitle: const Text('이 사용자의 모든 메시지가 즉시 가려집니다',
                        style: TextStyle(
                            fontSize: OomuTokens.fs12,
                            color: OomuTokens.textMuted)),
                    onTap: () {
                      Navigator.pop(ctx);
                      onBlock();
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

