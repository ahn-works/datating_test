import io

with io.open('pubspec.yaml', 'r', encoding='utf-8') as f:
    content = f.read()

deps = """  image_picker: any
  firebase_storage: any
  geolocator: any
"""

if 'image_picker:' not in content:
    content = content.replace("  latlong2: any", "  latlong2: any\n" + deps)

with io.open('pubspec.yaml', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
