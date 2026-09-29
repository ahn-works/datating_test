import io

with io.open('lib/screens/soso_car_detail_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

new_logic = """  bool _isFavorite = false;
  bool _hasCompletedProfile = false;

  void _showApplyToast() {
    if (!_hasCompletedProfile) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) => Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(color: Colors.black.withOpacity(0.4)),
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.only(top: 8, left: 24, right: 24, bottom: 40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFEBEBEF), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 32),
                    const Icon(Icons.assignment_ind, size: 64, color: Color(0xFFF19E39)),
                    const SizedBox(height: 16),
                    const Text('프로필 완성이 필요해요!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF111111))),
                    const SizedBox(height: 12),
                    const Text('이 프리미엄 모임에 참여하려면 MBTI와 취미 태그 3개가 필요합니다. 1분 만에 완성해 보세요.', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Color(0xFF767676), height: 1.5)),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF19E39), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _hasCompletedProfile = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('프로필 완성 완료! 이제 참여 신청을 해주세요.')));
                          // 자동으로 다음 단계(기존 신청서) 열어줌
                          Future.delayed(const Duration(milliseconds: 300), () => _showApplyToast());
                        },
                        child: const Text('프로필 완성하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }
"""

content = content.replace("  bool _isFavorite = false;\n\n  void _showApplyToast() {", new_logic)

with io.open('lib/screens/soso_car_detail_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
