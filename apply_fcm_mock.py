import io
import re

with io.open('lib/screens/soso_car_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add notification icon
new_actions = """        actions: [
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('🔔 FCM 알림: [방장] 참여 승인이 완료되었습니다!'),
                backgroundColor: Color(0xFFF19E39),
                duration: Duration(seconds: 3),
              ));
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              width: 40, height: 40,
              decoration: const BoxDecoration(color: Color(0xFFF5F5F7), shape: BoxShape.circle),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.notifications_outlined, color: Color(0xFF111111), size: 22),
                  Positioned(
                    top: 10, right: 10,
                    child: CircleAvatar(radius: 3.5, backgroundColor: Colors.redAccent),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen())),
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              width: 40, height: 40,
              decoration: const BoxDecoration(color: Color(0xFFF5F5F7), shape: BoxShape.circle),
              child: Icon(Icons.tune, color: textPrimary, size: 20),
            ),
          )
        ],"""

# Find old actions array
pattern = r"actions:\s*\[\s*GestureDetector\(\s*onTap:\s*\(\)\s*=>\s*Navigator\.push[^\]]+\],"
content = re.sub(pattern, new_actions, content, flags=re.DOTALL)

with io.open('lib/screens/soso_car_home_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
