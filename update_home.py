import io

with io.open('lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

start_str = "const Text('동네 친구부터 만들기 👫'"
end_str = "const Text('우무 드라이브 메이트'"

start_idx = text.find(start_str)
end_idx = text.find(end_str)

if start_idx != -1 and end_idx != -1:
    new_section = '''const Text('동네 친구부터 만들기 👫', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalFriendsScreen())),
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
                        Text('우리 동네 친구 모임 보기', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 4),
                        Text('동네 산책, 밥친구, 카공, 러닝 등', style: TextStyle(color: Colors.black54, fontSize: 13)),
                      ]
                    )
                  ),
                  const Icon(Icons.chevron_right, color: Colors.black26)
                ]
              )
            )
          ),
          const SizedBox(height: 32),

          '''
    new_text = text[:start_idx] + new_section + text[end_idx:]
    with io.open('lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
        f.write(new_text)
    print('home_screen.dart updated successfully!')
else:
    print('Could not find sections in home_screen.dart')