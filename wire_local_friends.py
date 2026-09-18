import io

with io.open('lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Make sure local_friends_screen.dart is imported
if "import 'local_friends_screen.dart';" not in text:
    text = text.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'local_friends_screen.dart';")

# Wire the onTap for the feature cards.
text = text.replace(
    "_featureCard(Icons.directions_walk, '동네 산책', '가볍게 걷는 산책 메이트', const Color(0xFFF19E39), () {})",
    "_featureCard(Icons.directions_walk, '동네 산책', '가볍게 걷는 산책 메이트', const Color(0xFFF19E39), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalFriendsScreen())))"
)
text = text.replace(
    "_featureCard(Icons.restaurant, '밥친구', '혼밥 말고 같이 밥 먹기', const Color(0xFFE76F51), () {})",
    "_featureCard(Icons.restaurant, '밥친구', '혼밥 말고 같이 밥 먹기', const Color(0xFFE76F51), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalFriendsScreen())))"
)
text = text.replace(
    "_featureCard(Icons.menu_book, '카공', '조용히 카페에서 같이 공부/일', const Color(0xFF2A9D8F), () {})",
    "_featureCard(Icons.menu_book, '카공', '조용히 카페에서 같이 공부/일', const Color(0xFF2A9D8F), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalFriendsScreen())))"
)
text = text.replace(
    "_featureCard(Icons.directions_run, '러닝', '동네 한 바퀴 러닝 메이트', const Color(0xFF264653), () {})",
    "_featureCard(Icons.directions_run, '러닝', '동네 한 바퀴 러닝 메이트', const Color(0xFF264653), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalFriendsScreen())))"
)
text = text.replace(
    "_featureCard(Icons.flash_on, '급벙', '지금 당장 만날 동네 친구', const Color(0xFF6A4C93), () {})",
    "_featureCard(Icons.flash_on, '급벙', '지금 당장 만날 동네 친구', const Color(0xFF6A4C93), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalFriendsScreen())))"
)

with io.open('lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
