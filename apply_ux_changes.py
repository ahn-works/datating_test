import io

with io.open('lib/screens/soso_car_chat_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace text
content = content.replace("'카풀 요청'", "'동행/드라이브'")

with io.open('lib/screens/soso_car_chat_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
