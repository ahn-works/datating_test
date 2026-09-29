import io

with io.open('pubspec.yaml', 'r', encoding='utf-8') as f:
    content = f.read()

if 'flutter_map:' not in content:
    content = content.replace('  url_launcher: any', '  url_launcher: any\n  flutter_map: any\n  latlong2: any')

with io.open('pubspec.yaml', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
