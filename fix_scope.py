import io
import re

with io.open('lib/screens/my_page_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("List<String> hobbies = ['맛집탐방', '코노'];", "List<String> hobbies = ['맛집탐방', '코노'];\n          List<String> closeFriendPersonalities = [];\n          List<String> values = [];")

load_block_old = "if (data['drinking'] != null) drinking = List<String>.from(data['drinking']);"
load_block_new = "if (data['drinking'] != null) drinking = List<String>.from(data['drinking']);\n            if (data['closeFriendPersonalities'] != null) closeFriendPersonalities = List<String>.from(data['closeFriendPersonalities']);\n            if (data['values'] != null) values = List<String>.from(data['values']);"
content = content.replace(load_block_old, load_block_new)

content = content.replace("data['closeFriendPersonalities'] != null && (data['closeFriendPersonalities'] as List).isNotEmpty", "closeFriendPersonalities.isNotEmpty")
content = content.replace("(data['closeFriendPersonalities'] as List)", "closeFriendPersonalities")

content = content.replace("data['values'] != null && (data['values'] as List).isNotEmpty", "values.isNotEmpty")
content = content.replace("(data['values'] as List)", "values")

with io.open('lib/screens/my_page_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
