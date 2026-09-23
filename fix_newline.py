import io

with io.open('lib/screens/soso_car_detail_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('class OOMUDetailScreen extends StatefulWidget {\\n  final Map<String, dynamic>? meetup;', 'class OOMUDetailScreen extends StatefulWidget {\n  final Map<String, dynamic>? meetup;')

with io.open('lib/screens/soso_car_detail_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
