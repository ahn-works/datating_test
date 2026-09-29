import io

with io.open('lib/screens/my_page_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

banner_ui = """                      // Freemium Banner
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF333333), Color(0xFF111111)],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('OOMU Plus', style: TextStyle(color: Color(0xFFF19E39), fontWeight: FontWeight.w900, fontSize: 18, fontStyle: FontStyle.italic)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFFF19E39).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                  child: const Text('무료 체험하기', style: TextStyle(color: Color(0xFFF19E39), fontSize: 12, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text('시크릿 프로필 열람 및 프리미엄 필터로\n나와 딱 맞는 사람을 더 빠르게 찾아보세요.', style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
                          ],
                        ),
                      ),
"""

target = "                      Row(\n                        mainAxisAlignment: MainAxisAlignment.spaceBetween,"
if target in content:
    content = content.replace(target, banner_ui + target, 1)

with io.open('lib/screens/my_page_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
