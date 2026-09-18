import io
import re

with io.open('lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# First, extract the first part of the file up to "const Text('주요 기능'"
idx = text.find("const Text('주요 기능'")
if idx == -1:
    print("Could not find '주요 기능'")
    exit(1)

part1 = text[:idx]

# I need to construct the new bottom part.
# The user wants "동네 친구 만들기" as a new category with items inside, and separate from "우무 드라이브 메이트"
new_bottom = '''const Text('주요 기능', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _featureCard(Icons.travel_explore, '여행 모집', '지역 기반 여행 모임 만들기', const Color(0xFFFF3B30), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PartyScreen()))), 
          const SizedBox(height: 12),
          _featureCard(Icons.task_alt, '미션 & 하트시그널', '현장 인증 미션 및 최종 선택', Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignalHouseIntroScreen()))),
          const SizedBox(height: 32),
          
          const Text('동네 친구부터 만들기 👫', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _featureCard(Icons.directions_walk, '동네 산책', '가볍게 걷는 산책 메이트', const Color(0xFFF19E39), () {}),
          const SizedBox(height: 12),
          _featureCard(Icons.restaurant, '밥친구', '혼밥 말고 같이 밥 먹기', const Color(0xFFE76F51), () {}),
          const SizedBox(height: 12),
          _featureCard(Icons.menu_book, '카공', '조용히 카페에서 같이 공부/일', const Color(0xFF2A9D8F), () {}),
          const SizedBox(height: 12),
          _featureCard(Icons.directions_run, '러닝', '동네 한 바퀴 러닝 메이트', const Color(0xFF264653), () {}),
          const SizedBox(height: 12),
          _featureCard(Icons.flash_on, '급벙', '지금 당장 만날 동네 친구', const Color(0xFF6A4C93), () {}),
          const SizedBox(height: 32),

          const Text('우무 드라이브 메이트', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // 우무 드라이브 메이트 바로가기 배너 추가
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OOMUHomeScreen())),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF3A674F), Color(0xFF2D5A43)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: const Color(0xFF3A674F).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
              ),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), child: const Icon(Icons.directions_car, color: Colors.white, size: 28)),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('동네 드라이브 OOMU 🚙', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 4),
                        Text('우리 동네 이웃과 함께하는 드라이브 여행', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ]
                    )
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white)
                ]
              )
            )
          ),
          const SizedBox(height: 40)
        ]
      )
    );
  }

  Widget _userCard(BuildContext ctx, String name, String sub, String img) => GestureDetector(onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => ProfileDetailScreen(name: name, age: '24', region: '서울', imageUrl: '', intro: '안녕하세요!', mannerTemp: 36.5))), child: Container(width: 160, margin: const EdgeInsets.only(right: 16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover)), child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(0.8)], begin: Alignment.topCenter, end: Alignment.bottomCenter)), padding: const EdgeInsets.all(16), child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(height: 4), Row(children: [const Icon(Icons.location_on, color: Colors.white70, size: 12), const SizedBox(width: 4), Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500))])]))));

  Widget _featureCard(IconData icon, String title, String sub, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]), child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(sub, style: TextStyle(color: Colors.grey.shade600, fontSize: 14))])), const Icon(Icons.chevron_right, color: Colors.grey)])),
  );
}
'''

new_text = part1 + new_bottom

with io.open('lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(new_text)
