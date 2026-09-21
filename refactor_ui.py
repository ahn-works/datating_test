import io
import os
import glob

# Files to update
files = [
    'lib/screens/soso_car_home_screen.dart',
    'lib/screens/soso_car_detail_screen.dart',
    'lib/screens/soso_car_host_screen.dart',
    'lib/screens/my_page_screen.dart',
    'lib/screens/chat_screen.dart',
    'lib/screens/soso_car_chat_screen.dart'
]

for filepath in files:
    if not os.path.exists(filepath):
        continue
    
    with io.open(filepath, 'r', encoding='utf-8') as f:
        text = f.read()

    # 1. Colors
    text = text.replace('Color(0xFF14422D)', 'Color(0xFF1A1A1A)') # Black instead of dark green
    text = text.replace('darkGreen', 'primaryColor')
    text = text.replace('Color(0xFFFBF9F6)', 'Color(0xFFF5F5F7)') # Crisp light grey instead of creamy
    text = text.replace('Color(0xFFBCEECF)', 'Color(0xFFF0F0F0)') # Soft grey badge instead of green
    text = text.replace('badgeGreen', 'badgeGrey')
    text = text.replace('Color(0xFFA33D23)', 'Color(0xFFFF3B30)') # Apple red instead of terracotta
    text = text.replace('Color(0xFF1B4D3E)', 'Color(0xFF1A1A1A)') # Catch other green variants
    text = text.replace('Color(0xFFE8ECEF)', 'Color(0xFFF5F5F7)') 

    # 2. Typography & Shadows tweaks
    # We can tone down the shadows
    text = text.replace('blurRadius: 20', 'blurRadius: 30')
    text = text.replace('Colors.black.withOpacity(0.1)', 'Colors.black.withOpacity(0.04)')
    text = text.replace('Colors.black12', 'Colors.black.withOpacity(0.04)')
    text = text.replace('Colors.black.withOpacity(0.05)', 'Colors.black.withOpacity(0.03)')
    
    # 3. Specific UI polish
    if 'soso_car_home_screen.dart' in filepath:
        # Airbnb style categories (remove borders, make them flatter)
        text = text.replace('border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade300)', 'border: isSelected ? null : Border.all(color: Colors.grey.shade200)')
        text = text.replace('borderRadius: BorderRadius.circular(20)', 'borderRadius: BorderRadius.circular(30)')
        text = text.replace('borderRadius: BorderRadius.circular(24)', 'borderRadius: BorderRadius.circular(30)')
        # Cards
        text = text.replace('borderRadius: const BorderRadius.vertical(top: Radius.circular(20))', 'borderRadius: const BorderRadius.vertical(top: Radius.circular(30))')

    if 'soso_car_detail_screen.dart' in filepath:
        # Make the bottom bar cleaner
        text = text.replace('borderRadius: BorderRadius.circular(16)', 'borderRadius: BorderRadius.circular(30)')
        
    with io.open(filepath, 'w', encoding='utf-8') as f:
        f.write(text)

print("UI Refactored to MZ aesthetic (Sleek Black & White)")
