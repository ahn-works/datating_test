import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PartyHostScreen extends StatefulWidget {
  const PartyHostScreen({super.key});

  @override
  State<PartyHostScreen> createState() => _PartyHostScreenState();
}

class _PartyHostScreenState extends State<PartyHostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
  String _selectedCategory = '⚡ 오늘 번개';
  final List<String> _categories = [
    '⚡ 오늘 번개',
    '☕ 취향 아지트',
    '🏃‍♂️ 라이프 메이트',
    '🚗 드라이브',
    '🏕️ 동성 캠핑'
  ];

  String _region = '서울 성수/건대';
  final List<String> _regions = [
    '서울 성수/건대',
    '서울 홍대/연남',
    '서울 강남/잠실',
    '서울 종로/을지로',
    '경기 판교/분당',
    '경기 수원/인계',
    '강원 양양/강릉'
  ];

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 30);
  int _maxMembers = 4;
  bool _agreeEscrow = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    HapticFeedback.lightImpact();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6B4A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    HapticFeedback.lightImpact();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6B4A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모임 제목을 입력해주세요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_agreeEscrow) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('1/N 안심 정산 및 클린 모임 원칙에 동의해주세요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('새 모임이 성공적으로 개설되었습니다!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F7), // OOMU 오트밀 로즈 크림
      appBar: AppBar(
        title: const Text(
          '새 모임 만들기',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 카테고리 선택
            _buildSectionCard(
              title: '모임 카테고리',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((c) {
                  final isSel = _selectedCategory == c;
                  return ChoiceChip(
                    label: Text(c),
                    selected: isSel,
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategory = c);
                    },
                    selectedColor: const Color(0xFFFF6B4A),
                    backgroundColor: const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : const Color(0xFF334155),
                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: isSel ? const Color(0xFFFF6B4A) : Colors.transparent),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 2. 모임 제목 & 소개
            _buildSectionCard(
              title: '모임 제목 및 소개',
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: '예: 이번 주말 성수 에스프레소 바 투어 ☕️',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFFF6B4A), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descController,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), height: 1.5),
                    decoration: InputDecoration(
                      hintText: '어떤 사람들과 어떤 분위기로 만나는지 자유롭게 적어주세요. (취향, 준비물, 약속 매너 등)',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFFF6B4A), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. 지역 및 활동 장소
            _buildSectionCard(
              title: '활동 동네 / 지역',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _regions.map((r) {
                  final isSel = _region == r;
                  return ChoiceChip(
                    label: Text(r),
                    selected: isSel,
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      setState(() => _region = r);
                    },
                    selectedColor: const Color(0xFF0F172A),
                    backgroundColor: const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : const Color(0xFF334155),
                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: isSel ? const Color(0xFF0F172A) : Colors.transparent),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 4. 모임 일시 및 시간
            _buildSectionCard(
              title: '모임 날짜 및 시간',
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month_rounded, size: 18, color: Color(0xFFFF6B4A)),
                      label: Text(
                        '${_selectedDate.month}월 ${_selectedDate.day}일',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFFFF6B4A)),
                      label: Text(
                        '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. 모집 인원 정원
            _buildSectionCard(
              title: '모집 정원 (호스트 포함)',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('함께할 최대 인원', style: TextStyle(fontSize: 14, color: Color(0xFF475569))),
                  Row(
                    children: [
                      IconButton(
                        tooltip: '모집 정원 감소',
                        onPressed: _maxMembers > 2
                            ? () {
                                HapticFeedback.selectionClick();
                                setState(() => _maxMembers--);
                              }
                            : null,
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                        color: const Color(0xFFFF6B4A),
                      ),
                      Container(
                        constraints: const BoxConstraints(minWidth: 54),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$_maxMembers명',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: '모집 정원 증가',
                        onPressed: _maxMembers < 8
                            ? () {
                                HapticFeedback.selectionClick();
                                setState(() => _maxMembers++);
                              }
                            : null,
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        color: const Color(0xFFFF6B4A),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 6. 1/N 안심 정산 원칙 동의 (Escrow Split Billing)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4EB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFE0D0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreeEscrow,
                    activeColor: const Color(0xFFFF6B4A),
                    onChanged: (v) => setState(() => _agreeEscrow = v ?? false),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1/N 투명 안심 정산 원칙 준수',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'OOMU는 사설 계좌 입금이나 과도한 사전 참가비를 금지합니다. 모임 당일 실제 발생한 비용만 참석자들과 투명하게 N분의 1 정산합니다.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 하단 고정 생성 버튼
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            )
          ],
          border: const Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1.0)),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B4A),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : const Text(
                    '모임 개설 완료하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEFF1F5), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
