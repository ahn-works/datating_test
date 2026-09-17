import io
import re

with io.open('lib/screens/soso_car_host_screen.dart', 'r', encoding='utf-8') as f:
    host = f.read()

old_box = '''                Expanded(
                  child: TextField(
                    controller: _destController,
                    decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 16),'''

new_box = '''                Expanded(
                  child: TextField(
                    controller: _destController,
                    decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    try {
                      Kpostal? result = await Navigator.push(context, MaterialPageRoute(builder: (_) => KpostalView()));
                      if (result != null) {
                        setState(() {
                          _destController.text = result.address;
                        });
                      }
                    } catch (e) {
                      print("Kpostal error: \\$e");
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.keyboard_arrow_down, color: Colors.black87, size: 20),
                  ),
                ),'''

host = host.replace(old_box, new_box)

with io.open('lib/screens/soso_car_host_screen.dart', 'w', encoding='utf-8') as f:
    f.write(host)