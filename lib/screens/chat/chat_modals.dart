import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/ai_service.dart';
import '../../services/kakao_map_service.dart';
import '../../ui/oomu_button.dart';
import '../../ui/oomu_tokens.dart';
import '../../utils/app_image.dart';
import '../../widgets/bouncy_tap.dart';

class ChatModals {
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
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    String location = '';
    int maxMembers = 4;

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
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.calendar_month, color: OomuTokens.coral),
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
                      const SizedBox(height: OomuTokens.s20),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('날짜 선택',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: OomuTokens.textPrimary)),
                        subtitle: Text(
                          selectedDate != null
                              ? '${selectedDate!.year}년 ${selectedDate!.month}월 ${selectedDate!.day}일'
                              : '터치하여 날짜를 선택하세요',
                          style: const TextStyle(
                              fontSize: OomuTokens.fs12,
                              color: OomuTokens.textSecondary),
                        ),
                        trailing: const Icon(Icons.edit_calendar,
                            color: OomuTokens.coral),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) setState(() => selectedDate = date);
                        },
                      ),
                      const Divider(color: OomuTokens.border),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('시간 선택',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: OomuTokens.textPrimary)),
                        subtitle: Text(
                          selectedTime != null
                              ? selectedTime!.format(context)
                              : '터치하여 시간을 선택하세요',
                          style: const TextStyle(
                              fontSize: OomuTokens.fs12,
                              color: OomuTokens.textSecondary),
                        ),
                        trailing: const Icon(Icons.access_time,
                            color: OomuTokens.coral),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) setState(() => selectedTime = time);
                        },
                      ),
                      const Divider(color: OomuTokens.border),
                      TextField(
                        onChanged: (val) => location = val,
                        style: const TextStyle(
                            fontSize: OomuTokens.fs14,
                            color: OomuTokens.textPrimary),
                        decoration: InputDecoration(
                          labelText: '모임 장소 (예: 스타벅스 여수점)',
                          labelStyle: const TextStyle(
                              fontSize: OomuTokens.fs14,
                              color: OomuTokens.textSecondary),
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
                        ),
                      ),
                      const SizedBox(height: OomuTokens.s16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('모임 인원',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: OomuTokens.fs16,
                                  color: OomuTokens.textPrimary)),
                          DropdownButton<int>(
                            value: maxMembers,
                            underline: const SizedBox.shrink(),
                            dropdownColor: OomuTokens.surface,
                            items: [2, 3, 4, 5, 6, 7, 8]
                                .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text('$e명',
                                        style: const TextStyle(
                                            color: OomuTokens.textPrimary))))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => maxMembers = val);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: OomuTokens.s20),
                      OomuButton(
                        label: '일정 공유 및 투표 시작',
                        onPressed: () {
                          if (selectedDate == null ||
                              selectedTime == null ||
                              location.trim().isEmpty) {
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
                            'location': location,
                            'maxMembers': maxMembers,
                          });
                        },
                      ),
                    ],
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
    List<Map<String, dynamic>> searchResults = [];
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            Future<void> performSearch(String query) async {
              if (query.trim().isEmpty) return;
              setState(() {
                isLoading = true;
                searchResults = [];
              });

              try {
                final places =
                    await KakaoMapService.searchKeyword(query, size: 10);
                setState(() {
                  searchResults = places.map((item) {
                    return {
                      'name': item.name,
                      'category': item.category.isNotEmpty
                          ? item.category
                          : (selectedCategory == '전체'
                              ? '모임장소'
                              : selectedCategory),
                      'address': item.roadAddress.isNotEmpty
                          ? item.roadAddress
                          : item.address,
                      'lat': item.lat,
                      'lng': item.lng,
                    };
                  }).toList();
                });
              } catch (_) {
              } finally {
                setState(() => isLoading = false);
              }
            }

            return Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                height: MediaQuery.of(ctx).size.height * 0.7,
                padding: const EdgeInsets.only(
                    top: OomuTokens.s24,
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
                    const Row(
                      children: [
                        Icon(Icons.travel_explore, color: OomuTokens.coral),
                        SizedBox(width: OomuTokens.s8),
                        Text(
                          '실시간 장소 검색 (전국)',
                          style: TextStyle(
                            fontSize: OomuTokens.fs18,
                            fontWeight: FontWeight.w700,
                            color: OomuTokens.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: OomuTokens.s16),
                    TextField(
                      onSubmitted: (val) {
                        searchQuery = val;
                        performSearch(val);
                      },
                      style: const TextStyle(
                          fontSize: OomuTokens.fs14,
                          color: OomuTokens.textPrimary),
                      decoration: InputDecoration(
                        hintText: '장소 이름 또는 지역 검색 (예: 여수 카페)',
                        hintStyle: const TextStyle(
                            fontSize: OomuTokens.fs14,
                            color: OomuTokens.textMuted),
                        prefixIcon: const Icon(Icons.search,
                            color: OomuTokens.textSecondary),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send_rounded,
                              color: OomuTokens.coral),
                          onPressed: () => performSearch(searchQuery),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: OomuTokens.s16,
                            vertical: OomuTokens.s8),
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
                      onChanged: (val) => searchQuery = val,
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
                                  setState(() => selectedCategory = category);
                                }
                              },
                              selectedColor: OomuTokens.surfaceMuted,
                              backgroundColor: OomuTokens.surface,
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
                                    ? OomuTokens.coral
                                    : OomuTokens.textSecondary,
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
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: OomuTokens.coral))
                          : searchResults.isEmpty
                              ? const Center(
                                  child: Text('장소 이름이나 지역을 검색해보세요.',
                                      style: TextStyle(
                                          fontSize: OomuTokens.fs14,
                                          color: OomuTokens.textMuted)))
                              : ListView.builder(
                                  itemCount: searchResults.length,
                                  itemBuilder: (context, index) {
                                    final place = searchResults[index];
                                    return ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                          vertical: OomuTokens.s4),
                                      leading: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: OomuTokens.surfaceMuted,
                                            borderRadius: BorderRadius.circular(
                                                OomuTokens.r8)),
                                        child: const Icon(Icons.place,
                                            color: OomuTokens.coral),
                                      ),
                                      title: Text(place['name'],
                                          style: const TextStyle(
                                              fontSize: OomuTokens.fs14,
                                              fontWeight: FontWeight.w700,
                                              color: OomuTokens.textPrimary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      subtitle: Text(
                                          '${place['category']} • ${place['address']}',
                                          style: const TextStyle(
                                              fontSize: OomuTokens.fs12,
                                              color: OomuTokens.textSecondary),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                      trailing: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              OomuTokens.surfaceMuted,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      OomuTokens.r8)),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          onCreated({
                                            'type': 'hotspot',
                                            'title': '☕ 우리 동네 핫플 추천!',
                                            'name': place['name'],
                                            'category': place['category'],
                                            'address': place['address'],
                                            'lat': place['lat'],
                                            'lng': place['lng'],
                                          });
                                        },
                                        child: const Text('공유',
                                            style: TextStyle(
                                                color: OomuTokens.coral,
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
                    List<Map<String, dynamic>> stickers = [];
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      final rawList = data?['stickers'] as List<dynamic>? ?? [];
                      stickers = rawList
                          .map((e) => Map<String, dynamic>.from(e as Map))
                          .toList();
                    }
                    if (stickers.isEmpty) {
                      return const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: OomuTokens.coral,
                          ),
                        ),
                      );
                    }
                    return GridView.builder(
                      controller: scrollController,
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

                        return BouncyTap(
                          scaleDown: 0.92,
                          onTap: () {
                            Navigator.pop(ctx);
                            onCreated({
                              'type': 'sticker',
                              'imageUrl': rawUrl,
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
                                    child: appNetImage(rawUrl,
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

