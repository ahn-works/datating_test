import io

with io.open('lib/screens/soso_car_host_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Replace the specific syntax error
old_str = "title: const Center(child: Text('🎉 모임 개설 완료!', style: TextStyle(fontWeight: FontWeight.w800)))),"
new_str = "title: const Center(child: Text('🎉 모임 개설 완료!', style: TextStyle(fontWeight: FontWeight.w800))),"

text = text.replace(old_str, new_str)

with io.open('lib/screens/soso_car_host_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
