import io
import re

with io.open('lib/screens/soso_car_detail_screen.dart', 'r', encoding='utf-8') as f:
    detail = f.read()

detail = detail.replace('\r\n', '\n')

old_regex = r"child:\s*Row\(\s*children:\s*\[\s*CircleAvatar\([\s\S]*?Icon\(Icons\.chevron_right, color: textSecondary, size: 20\),\s*\]\,\s*\),"

new_code = """child: GestureDetector(
                        onTap: () {
                          final hostName = (widget.meetup != null ? widget.meetup!['host'] : '매운맛킬러').toString();
                          Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen(userName: hostName)));
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500&q=80'),
                              backgroundColor: surfaceColor,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text((widget.meetup != null ? widget.meetup!['host'] : '매운맛킬러'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text('매너온도 42.5°C', style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      Icon(Icons.verified, color: accentColor, size: 14),
                                      const SizedBox(width: 4),
                                      Text('AI 본명인증', style: TextStyle(color: textSecondary, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: textSecondary, size: 20),
                          ],
                        ),
                      ),"""

detail = re.sub(old_regex, new_code, detail)

if "GestureDetector" not in detail:
    print("WARNING: Replacement failed!")

with io.open('lib/screens/soso_car_detail_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(detail)