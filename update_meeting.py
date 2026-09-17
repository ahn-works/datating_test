import io

with io.open('lib/screens/soso_car_host_screen.dart', 'r', encoding='utf-8') as f:
    host = f.read()

state_vars = '''class _SosoCarHostScreenState extends State<SosoCarHostScreen> {
  final TextEditingController _meetingController = TextEditingController(text: '마포구청역 1번출구');'''

if "TextEditingController _meetingController" not in host:
    host = host.replace('class _SosoCarHostScreenState extends State<SosoCarHostScreen> {', state_vars)

old_meeting = '''                  const Expanded(child: Text('마포구청역 1번출구 지상 버스베이', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 16),'''

new_meeting = '''                Expanded(
                  child: TextField(
                    controller: _meetingController,
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
                          _meetingController.text = result.address;
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

host = host.replace(old_meeting, new_meeting)

with io.open('lib/screens/soso_car_host_screen.dart', 'w', encoding='utf-8') as f:
    f.write(host)