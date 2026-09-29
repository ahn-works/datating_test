import io
import re

with io.open('lib/screens/user_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

pattern = r"Container\(\s*padding: const EdgeInsets\.symmetric\(horizontal: 8, vertical: 4\),\s*decoration: BoxDecoration\(color: accentColor, borderRadius: BorderRadius\.circular\(6\)\),\s*child: const Row\(\s*children: \[\s*Icon\(Icons\.verified, color: Colors\.white, size: 12\),\s*SizedBox\(width: 4\),\s*Text\('본명인증', style: TextStyle\(color: Colors\.white, fontSize: 11, fontWeight: FontWeight\.bold\)\),\s*\],\s*\),\s*\)"

replacement = """Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(6)),
                              child: const Row(
                                children: [
                                  Icon(Icons.verified, color: Colors.white, size: 12),
                                  SizedBox(width: 4),
                                  Text('본명인증', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFF4A90E2), borderRadius: BorderRadius.circular(6)),
                              child: const Row(
                                children: [
                                  Icon(Icons.work, color: Colors.white, size: 12),
                                  SizedBox(width: 4),
                                  Text('N사 재직', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFF34C759), borderRadius: BorderRadius.circular(6)),
                              child: const Row(
                                children: [
                                  Icon(Icons.school, color: Colors.white, size: 12),
                                  SizedBox(width: 4),
                                  Text('홍대졸업', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )"""

content = re.sub(pattern, replacement, content, flags=re.DOTALL)

with io.open('lib/screens/user_profile_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
