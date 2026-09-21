import re

with open('lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()
    
# Count brackets
print("Open {:", text.count('{'), "Close }:", text.count('}'))
print("Open [:", text.count('['), "Close ]:", text.count(']'))
print("Open (:", text.count('('), "Close ):", text.count(')'))
