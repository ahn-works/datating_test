import io
import re

with io.open('lib/screens/home_sub_screens.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Replace all occurrences of Navigator.push(... => ProfileDetailScreen(...)) with showDriverProfileModal(context)
text = re.sub(
    r'Navigator\.push\([^,]+,\s*MaterialPageRoute\(builder:\s*\([^)]*\)\s*=>\s*ProfileDetailScreen\([^)]*\)\)\)',
    r'showDriverProfileModal(context)',
    text
)
# Wait, context might be named differently (e.g. ctx). Let's capture it.
text = re.sub(
    r'Navigator\.push\(([^,]+),\s*MaterialPageRoute\(builder:\s*\([^)]*\)\s*=>\s*ProfileDetailScreen\([^)]*\)\)\)',
    r'showDriverProfileModal(\1)',
    text
)


with io.open('lib/screens/home_sub_screens.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("Fixed home_sub_screens.dart")
