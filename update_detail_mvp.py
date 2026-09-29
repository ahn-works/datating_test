import io
import re

with io.open('lib/screens/soso_car_detail_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the "참여 신청하기" button logic with a BottomSheet for applying
old_button_logic = """                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('참여가 완료되었습니다!')));
                        Navigator.push(context, MaterialPageRoute(builder: (_) => OOMUChatScreen(title: (widget.meetup != null ? widget.meetup!['title'] : '마라탕 & 탕후루 팟'), memberCount: 4)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('참여 신청하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),"""

new_button_logic = """                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: _isApplying 
                      ? ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC7C7CC),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('승인 대기 중', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        )
                      : ElevatedButton(
                          onPressed: () => _showApplicationBottomSheet(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('참여 신청하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                  ),"""

content = content.replace(old_button_logic, new_button_logic)

# Add `bool _isApplying = false;` to the state class
content = content.replace("class _OOMUDetailScreenState extends State<OOMUDetailScreen> {", "class _OOMUDetailScreenState extends State<OOMUDetailScreen> {\n  bool _isApplying = false;\n  final TextEditingController _applyMsgController = TextEditingController();")

# Add `_showApplicationBottomSheet` method
bottom_sheet_method = """  void _showApplicationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('참여 신청 메시지', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary)),
                    IconButton(icon: Icon(Icons.close, color: textSecondary), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('모임장에게 간단한 자기소개나 인사말을 남겨주세요!', style: TextStyle(fontSize: 14, color: textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16)),
                  child: TextField(
                    controller: _applyMsgController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: '예) 안녕하세요! 마라탕 엄청 좋아합니다. 잘 부탁드려요!',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx); // Close sheet
                      setState(() { _isApplying = true; });
                      
                      // Mock successful approval after 3 seconds
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('참여 신청을 보냈습니다. 방장의 승인을 기다려주세요.')));
                      Future.delayed(const Duration(seconds: 3), () {
                        if (!mounted) return;
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: const Text('🎉 승인 완료!'),
                            content: const Text('방장님이 참여를 승인했습니다.\\n채팅방으로 이동할까요?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: Text('닫기', style: TextStyle(color: textSecondary))),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OOMUChatScreen(title: (widget.meetup != null ? widget.meetup!['title'] : '마라탕 & 탕후루 팟'), memberCount: 4)));
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: accentColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                child: const Text('채팅방 이동', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          )
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('메시지 보내기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {"""

content = content.replace("  @override\n  Widget build(BuildContext context) {", bottom_sheet_method)

with io.open('lib/screens/soso_car_detail_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
