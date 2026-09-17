import io
import re

with io.open('lib/screens/soso_car_host_screen.dart', 'r', encoding='utf-8') as f:
    host = f.read()

host = re.sub(r'const Expanded\(\s*child: Column\(\s*crossAxisAlignment: CrossAxisAlignment\.start,\s*children: \[\s*Row\(', 'Expanded(\n                    child: Column(\n                      crossAxisAlignment: CrossAxisAlignment.start,\n                      children: [\n                        Row(', host)

with io.open('lib/screens/soso_car_host_screen.dart', 'w', encoding='utf-8') as f:
    f.write(host)