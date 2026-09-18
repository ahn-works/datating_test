import io

with io.open('lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Remove '동네 커플' card
text = text.replace(
    "_featureCard(Icons.people, '동네 커플', '남성/여성 성비 확인 후 참여', Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalCoupleScreen()))), \n          const SizedBox(height: 12),",
    ""
)

# 2. Add '동네 친구 만들기' shortcut below '동네 드라이브 OOMU' banner
# Find the end of the green banner
green_banner = '''Text('우리 동네 이웃과 함께하는 드라이브 여행', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ]
                    )
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white)
                ]
              )
            )
          ),'''

new_banner = '''
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OOMUHomeScreen())),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFF19E39).withOpacity(0.3)),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: const Color(0xFFF19E39).withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]
              ),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF19E39).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.people_alt, color: Color(0xFFF19E39), size: 28)),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('동네 친구 만들기 👫', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 4),
                        Text('동네 산책, 밥친구, 카공, 러닝 등', style: TextStyle(color: Colors.black54, fontSize: 13)),
                      ]
                    )
                  ),
                  const Icon(Icons.chevron_right, color: Colors.black26)
                ]
              )
            )
          ),'''

text = text.replace(green_banner, green_banner + new_banner)

with io.open('lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)