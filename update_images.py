import io

# 1. Update soso_car_home_screen.dart
with io.open('lib/screens/soso_car_home_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Replace images
text = text.replace('https://images.unsplash.com/photo-1583314782006-25f0cb175b16?w=500&q=80', 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=500&q=80')
text = text.replace('https://images.unsplash.com/photo-1497215842964-222b430dc094?w=500&q=80', 'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=500&q=80')
text = text.replace('https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=500&q=80', 'https://images.unsplash.com/photo-1523301343968-6a6ebf63c672?w=500&q=80')

with io.open('lib/screens/soso_car_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)

# 2. Update soso_car_detail_screen.dart
with io.open('lib/screens/soso_car_detail_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Replace image
text = text.replace('https://images.unsplash.com/photo-1583314782006-25f0cb175b16?w=800&q=80', 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&q=80')

with io.open('lib/screens/soso_car_detail_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("Images replaced")
