import io
import re

with io.open('lib/screens/soso_car_chat_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update the Map placeholder image to a real street map tile (OpenStreetMap Seoul)
old_map_image = "NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800&q=80')"
new_map_image = "NetworkImage('https://tile.openstreetmap.org/16/55865/25398.png')"
content = content.replace(old_map_image, new_map_image)

# 2. Add the attachment menu logic
attachment_methods = """  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Wrap(
            spacing: 24,
            runSpacing: 32,
            alignment: WrapAlignment.start,
            children: [
              _buildAttachmentIcon(Icons.image, '사진보내기', Colors.green),
              _buildAttachmentIcon(Icons.location_on, '현재 위치', Colors.redAccent),
              _buildAttachmentIcon(Icons.rate_review, '모임후기', Colors.orange),
              _buildAttachmentIcon(Icons.calendar_month, '일정', Colors.blue),
              _buildAttachmentIcon(Icons.how_to_vote, '투표', Colors.purple),
              _buildAttachmentIcon(Icons.payments, '더치페이', const Color(0xFFF19E39)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentIcon(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label 기능을 실행합니다.')));
      },
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF111111)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {"""

content = content.replace("  @override\n  Widget build(BuildContext context) {", attachment_methods)

# 3. Hook up the + button
old_add_button = "IconButton(icon: const Icon(Icons.add_circle_outline, color: Color(0xFFC7C7CC)), onPressed: () {}),"
new_add_button = "IconButton(icon: const Icon(Icons.add_circle_outline, color: Color(0xFFC7C7CC)), onPressed: _showAttachmentMenu),"
content = content.replace(old_add_button, new_add_button)

with io.open('lib/screens/soso_car_chat_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
