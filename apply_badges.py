import io

with io.open('lib/screens/user_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

badges_ui = """                  const SizedBox(height: 24),
                  
                  // 3. 신뢰 배지 (게미피케이션)
                  Text('획득한 신뢰 배지', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)), child: const Text('⏰ 약속 시간 칼입장', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFFFFF4E6), borderRadius: BorderRadius.circular(12)), child: const Text('🥳 분위기 메이커', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFF19E39)))),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)), child: const Text('🚗 친절한 드라이버', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green))),
                    ],
                  ),"""

# Find where to inject
target = "                  const SizedBox(height: 32),"
if target in content:
    content = content.replace(target, badges_ui + "\n" + target, 1)

with io.open('lib/screens/user_profile_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
