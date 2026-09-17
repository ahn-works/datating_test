import io

with io.open('lib/screens/soso_car_host_screen.dart', 'r', encoding='utf-8') as f:
    code = f.read()

if "import 'package:kpostal/kpostal.dart';" not in code:
    code = code.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:kpostal/kpostal.dart';")

old_dest = '''                Expanded(
                  child: TextField(
                    controller: _destController,
                    decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                const Icon(Icons.search, color: Colors.black54, size: 16),'''

new_dest = '''                Expanded(
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
                      print("Kpostal error: \\\");
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.search, color: Colors.black87, size: 20),
                  ),
                ),'''

code = code.replace(old_dest, new_dest)

with io.open('lib/screens/soso_car_host_screen.dart', 'w', encoding='utf-8') as f:
    f.write(code)