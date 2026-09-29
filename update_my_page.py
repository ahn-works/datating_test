import io
import re

with io.open('lib/screens/my_page_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the hobbies block with hobbies + new tags
pattern = r"if \(hobbies\.isNotEmpty\) \.\.\.\[.*?const SizedBox\(height: 40\),\s*\],"
replacement = """if (hobbies.isNotEmpty) ...[
                Text('나의 관심사 / 취향', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: hobbies.map((hobby) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEBEBEF))),
                    child: Text(hobby, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                  )).toList(),
                ),
                const SizedBox(height: 32),
              ],
              
              if (data['closeFriendPersonalities'] != null && (data['closeFriendPersonalities'] as List).isNotEmpty) ...[
                Text('찐친이랑 있을 때 내 성격 🤪', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: (data['closeFriendPersonalities'] as List).map((p) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEBEBEF))),
                    child: Text(p.toString(), style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                  )).toList(),
                ),
                const SizedBox(height: 32),
              ],
              
              if (data['values'] != null && (data['values'] as List).isNotEmpty) ...[
                Text('내가 중요하게 생각하는 가치관 💎', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: (data['values'] as List).map((v) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEBEBEF))),
                    child: Text(v.toString(), style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                  )).toList(),
                ),
                const SizedBox(height: 40),
              ],"""

content = re.sub(pattern, replacement, content, flags=re.DOTALL)

with io.open('lib/screens/my_page_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
