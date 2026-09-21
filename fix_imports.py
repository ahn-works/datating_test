import io

# 1. home_screen.dart
with io.open('lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()
text = text.replace("import 'signal_house_intro_screen.dart';", "")
with io.open('lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)

# 2. home_sub_screens.dart
with io.open('lib/screens/home_sub_screens.dart', 'r', encoding='utf-8') as f:
    text = f.read()
# Replace profile_detail_screen with driver_profile_modal
text = text.replace("import 'profile_detail_screen.dart';", "import 'driver_profile_modal.dart';")
text = text.replace(
    "Navigator.push(ctx, MaterialPageRoute(builder: (_) => ProfileDetailScreen(name: name, age: '24', region: '서울', imageUrl: '', intro: '안녕하세요!', mannerTemp: 36.5)))",
    "showDriverProfileModal(ctx)"
)
with io.open('lib/screens/home_sub_screens.dart', 'w', encoding='utf-8') as f:
    f.write(text)

# 3. party_chat_preview_screen.dart
with io.open('lib/screens/party_chat_preview_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()
# Replace chat_room_screen with soso_car_chat_screen
text = text.replace("import 'chat_room_screen.dart';", "import 'soso_car_chat_screen.dart';")
text = text.replace(
    "Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatRoomScreen(roomName: '여행 크루 채팅방')))",
    "Navigator.push(context, MaterialPageRoute(builder: (_) => const OOMUChatScreen()))"
)
with io.open('lib/screens/party_chat_preview_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("Fixed broken imports.")
