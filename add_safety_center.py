import io
import re

# ==========================================
# 1. Update User Profile Screen
# ==========================================
with io.open('lib/screens/user_profile_screen.dart', 'r', encoding='utf-8') as f:
    profile_content = f.read()

# Add methods inside the StatelessWidget
methods = """
  void _showReportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.report_problem_outlined, color: Colors.redAccent),
                title: const Text('이 사용자 신고하기', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showReportReasonDialog(context, '사용자');
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.redAccent),
                title: const Text('이 사용자 차단 및 매칭 제외', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showBlockConfirmDialog(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );
  }

  void _showReportReasonDialog(BuildContext context, String targetType) {
    final reasons = ['불쾌한 언어 사용', '스팸 및 광고', '부적절한 프로필/사진', '노쇼 (약속 미이행)', '안전 위협 및 기타'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$targetType 신고 사유 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reasons.map((r) => ListTile(
            title: Text(r),
            onTap: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('운영진에게 신고 접수되었습니다. 빠른 시일 내에 검토 후 조치됩니다.')));
            },
          )).toList(),
        ),
      )
    );
  }

  void _showBlockConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('사용자 차단'),
        content: const Text('이 사용자를 차단하시겠습니까?\\n더 이상 동네 모임과 채팅에서 서로 노출되지 않으며 매칭에서 제외됩니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('차단 및 매칭 제외 처리가 완료되었습니다.')));
              Navigator.pop(context); 
            }, 
            child: const Text('차단하기', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
          ),
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {"""

profile_content = profile_content.replace("  @override\n  Widget build(BuildContext context) {", methods)

# Add the 3-dots icon to the profile SliverAppBar
appbar_actions = """
            actions: [
              Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                  onPressed: () => _showReportBottomSheet(context),
                )
              )
            ],
            flexibleSpace: FlexibleSpaceBar("""

profile_content = profile_content.replace("            flexibleSpace: FlexibleSpaceBar(", appbar_actions)

with io.open('lib/screens/user_profile_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(profile_content)

# ==========================================
# 2. Update Meetup Detail Screen
# ==========================================
with io.open('lib/screens/soso_car_detail_screen.dart', 'r', encoding='utf-8') as f:
    detail_content = f.read()

detail_methods = """  void _showMeetupReportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.report_problem_outlined, color: Colors.redAccent),
                title: const Text('이 모임 신고하기', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showReportReasonDialog(context, '모임');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );
  }

  void _showReportReasonDialog(BuildContext context, String targetType) {
    final reasons = ['부적절한 모임 목적', '스팸 및 홍보성 모임', '위험 및 불법적인 내용', '기타 사유'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$targetType 신고 사유 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reasons.map((r) => ListTile(
            title: Text(r),
            onTap: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('해당 모임이 운영진에게 신고되었습니다. 24시간 내 검토됩니다.')));
            },
          )).toList(),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {"""

detail_content = detail_content.replace("  @override\n  Widget build(BuildContext context) {", detail_methods)

# Add the 3-dots icon to detail screen
old_actions = """              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? destructiveColor : Colors.white, size: 20),
                      onPressed: () => setState(() => _isFavorite = !_isFavorite),
                    )
                  )
                ),
              ],"""

new_actions = """              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? destructiveColor : Colors.white, size: 20),
                      onPressed: () => setState(() => _isFavorite = !_isFavorite),
                    )
                  )
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                      onPressed: () => _showMeetupReportBottomSheet(context),
                    )
                  )
                ),
              ],"""

detail_content = detail_content.replace(old_actions, new_actions)

with io.open('lib/screens/soso_car_detail_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(detail_content)
