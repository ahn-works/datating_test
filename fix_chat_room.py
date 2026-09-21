import io
import re

with io.open('lib/screens/party_chat_preview_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = re.sub(r'const\s+ChatRoomScreen\([^)]*\)', 'const OOMUChatScreen()', text)

with io.open('lib/screens/party_chat_preview_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print('Fixed party_chat_preview_screen.dart')
