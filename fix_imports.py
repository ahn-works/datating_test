import io

for filepath in ['lib/screens/soso_car_home_screen.dart', 'lib/screens/oomu_my_trips_screen.dart']:
    with io.open(filepath, 'r', encoding='utf-8') as f:
        text = f.read()

    if "import 'chat_screen.dart';" not in text:
        text = text.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'chat_screen.dart';\nimport 'soso_car_chat_screen.dart';\nimport 'soso_car_host_screen.dart';")
    
    with io.open(filepath, 'w', encoding='utf-8') as f:
        f.write(text)
