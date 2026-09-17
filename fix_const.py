import io
import re

with io.open('lib/screens/soso_car_host_screen.dart', 'r', encoding='utf-8') as f:
    host = f.read()

host = host.replace('const Expanded(\n                    child: Column(\n                      crossAxisAlignment: CrossAxisAlignment.start,\n                      children: [\n                        Row(\n                          children: [\n                            Text(', 'Expanded(\n                    child: Column(\n                      crossAxisAlignment: CrossAxisAlignment.start,\n                      children: [\n                        Row(\n                          children: [\n                            Text(')

host = host.replace('const Expanded(\n                    child: Column(', 'Expanded(\n                    child: Column(')

with io.open('lib/screens/soso_car_host_screen.dart', 'w', encoding='utf-8') as f:
    f.write(host)