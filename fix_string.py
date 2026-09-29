import io

with io.open('lib/screens/soso_car_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("Text('우리 동네\n취향 모임'", "Text('우리 동네\\n취향 모임'")

with io.open('lib/screens/soso_car_home_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
