import io
import re

# 1. Update soso_car_home_screen.dart
with io.open('lib/screens/soso_car_home_screen.dart', 'r', encoding='utf-8') as f:
    home = f.read()

home = home.replace(
    "onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OOMUDetailScreen())),",
    "onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OOMUDetailScreen(meetup: meetup))),"
)

with io.open('lib/screens/soso_car_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(home)


# 2. Update soso_car_detail_screen.dart
with io.open('lib/screens/soso_car_detail_screen.dart', 'r', encoding='utf-8') as f:
    detail = f.read()

# Add meetup property
detail = detail.replace(
    "class OOMUDetailScreen extends StatelessWidget {",
    "class OOMUDetailScreen extends StatelessWidget {\n  final Map<String, dynamic>? meetup;"
)
detail = detail.replace(
    "const OOMUDetailScreen({super.key});",
    "const OOMUDetailScreen({super.key, this.meetup});"
)

# Use dynamic data if available
def replace_dynamic(old_val, map_key):
    global detail
    detail = detail.replace(f"'{old_val}'", f"meetup != null ? meetup!['{map_key}'] : '{old_val}'")

detail = detail.replace("'주말 엽떡+마라탕 조지실 분'", "meetup != null ? meetup!['title'] : '주말 엽떡+마라탕 조지실 분'")
detail = detail.replace("'홍대입구역 9번 출구'", "meetup != null ? meetup!['location'] : '홍대입구역 9번 출구'")
detail = detail.replace("'이번주 토요일 18:00'", "meetup != null ? meetup!['date'] : '이번주 토요일 18:00'")
detail = detail.replace("'술/맛집'", "meetup != null ? meetup!['category'] : '술/맛집'")
detail = detail.replace("'매운맛킬러'", "meetup != null ? meetup!['host'] : '매운맛킬러'")
detail = detail.replace("'N빵'", "meetup != null ? meetup!['price'] : 'N빵'")
detail = detail.replace("'각자 이동'", "meetup != null ? meetup!['transport'] : '각자 이동'")
detail = detail.replace("'2/4'", "meetup != null ? meetup!['members'] : '2/4'")

# Update imageUrl
old_img = "https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&q=80"
detail = detail.replace(
    f"NetworkImage('{old_img}')",
    f"NetworkImage(meetup != null ? meetup!['imageUrl'] : '{old_img}')"
)

# Update Chat navigation in Detail Screen
detail = detail.replace(
    "Navigator.push(context, MaterialPageRoute(builder: (_) => const OOMUChatScreen(title: '주말 엽떡+마라탕 조지실 분', memberCount: 3)));",
    "Navigator.push(context, MaterialPageRoute(builder: (_) => OOMUChatScreen(title: meetup != null ? meetup!['title'] : '주말 엽떡+마라탕 조지실 분', memberCount: 3)));"
)

with io.open('lib/screens/soso_car_detail_screen.dart', 'w', encoding='utf-8') as f:
    f.write(detail)

# 3. Update oomu_my_trips_screen.dart to also pass dynamic data to Detail Screen
with io.open('lib/screens/oomu_my_trips_screen.dart', 'r', encoding='utf-8') as f:
    trips = f.read()

# I need to wrap the container in GestureDetector to go to detail screen.
container_str = "return Container("
gesture_str = "return GestureDetector(\n          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OOMUDetailScreen(meetup: meetup))),\n          child: Container("
trips = trips.replace(container_str, gesture_str)
# Close gesture detector properly (this is tricky with regex, so I'll just do a simpler search/replace)
trips = trips.replace("            ],
          ),
        );
      },", "            ],
          ),
        ));
      },")

with io.open('lib/screens/oomu_my_trips_screen.dart', 'w', encoding='utf-8') as f:
    f.write(trips)

print("Dynamic mapping applied.")
