import io
import re

with io.open('pubspec.yaml', 'r', encoding='utf-8') as f:
    content = f.read()

if 'url_launcher:' not in content:
    content = content.replace('  http: any', '  http: any\n  url_launcher: any')

with io.open('pubspec.yaml', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
