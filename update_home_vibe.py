import io
import re

with io.open('lib/screens/soso_car_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Increase Bottom Sheet Height to accommodate the new section
content = content.replace("height: MediaQuery.of(context).size.height * 0.70,", "height: MediaQuery.of(context).size.height * 0.80,")

# 2. Inject the "지금 내 상황" (My Current Situation) section
old_title_section = """                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('우리 동네\\n취향 모임', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textPrimary, height: 1.2)),
                        Text('12개 진행 중', style: TextStyle(fontSize: 14, color: accentColor, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),"""

new_vibe_section = """                  // [NEW] 지금 내 상황 (My Current Situation)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('지금 내 상황', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary)),
                            Text('전체 보기', style: TextStyle(fontSize: 14, color: textSecondary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildVibeCard('⚡', '놀줄아는', '핫플·페스티벌', const Color(0xFFFFF4E6)),
                            const SizedBox(width: 12),
                            _buildVibeCard('☕', '소소하게', '카페·산책', const Color(0xFFF3F4F6)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildVibeCard('🍔', '메이트', '맛집·배달', const Color(0xFFFCE8E6)),
                            const SizedBox(width: 12),
                            _buildVibeCard('💖', '소개팅', '취향 기반', const Color(0xFFFCE4EC)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // [EXISTING] 우리 동네 취향 모임
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('우리 동네\\n취향 모임', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary, height: 1.2)),
                        Text('12개 진행 중', style: TextStyle(fontSize: 14, color: accentColor, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),"""

content = content.replace(old_title_section, new_vibe_section)

# 3. Add the helper method `_buildVibeCard` inside `_OOMUHomeScreenState`
vibe_card_method = """  Widget _buildVibeCard(String emoji, String title, String subtitle, Color bgColor) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title 모임을 찾아볼게요!')));
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111111))),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF767676), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {"""

content = content.replace("  @override\n  Widget build(BuildContext context) {", vibe_card_method)

with io.open('lib/screens/soso_car_home_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
