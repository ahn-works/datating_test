import io

with io.open('lib/screens/soso_car_host_screen.dart', 'r', encoding='utf-8') as f:
    code = f.read()

state_vars = '''class _SosoCarHostScreenState extends State<SosoCarHostScreen> {
  DateTime? _depDate;
  TimeOfDay? _depTime;
  DateTime? _retDate;
  TimeOfDay? _retTime;
  
  String _formatDate(DateTime? d, String fallback) {
    if (d == null) return fallback;
    return "${d.month}월 ${d.day}일";
  }
  String _formatTime(TimeOfDay? t, String fallback) {
    if (t == null) return fallback;
    final ap = t.hour < 12 ? '오전' : '오후';
    final h = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
    final m = t.minute.toString().padLeft(2, '0');
    return "${ap} ${h}:${m}";
  }
'''
if "DateTime? _depDate" not in code:
    code = code.replace('class _SosoCarHostScreenState extends State<SosoCarHostScreen> {', state_vars)

old_dep = '''                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('10월 28일 (토)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('오전 09:30', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),'''

new_dep = '''                          GestureDetector(
                            onTap: () async {
                              final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                              if (d != null) {
                                final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                if (t != null) setState(() { _depDate = d; _depTime = t; });
                              }
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_formatDate(_depDate, '출발 날짜 선택'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text(_formatTime(_depTime, '시간 선택'), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                ],
                              ),
                            ),
                          ),'''
code = code.replace(old_dep, new_dep)

old_ret = '''                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('당일 복귀', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('오후 18:00', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),'''

new_ret = '''                          GestureDetector(
                            onTap: () async {
                              final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                              if (d != null) {
                                final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                if (t != null) setState(() { _retDate = d; _retTime = t; });
                              }
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_formatDate(_retDate, '복귀 날짜 선택'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text(_formatTime(_retTime, '시간 선택'), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                ],
                              ),
                            ),
                          ),'''
code = code.replace(old_ret, new_ret)

with io.open('lib/screens/soso_car_host_screen.dart', 'w', encoding='utf-8') as f:
    f.write(code)