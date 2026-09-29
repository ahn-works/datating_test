import io
import re

with io.open('lib/screens/soso_car_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace query
content = content.replace(".collection('meetups').orderBy('createdAt', descending: true).snapshots()", ".collection('meetups').orderBy('createdAt', descending: true).limit(20).snapshots()")

with io.open('lib/screens/soso_car_home_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
