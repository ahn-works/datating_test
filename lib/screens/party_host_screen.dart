import 'package:flutter/material.dart';
class PartyHostScreen extends StatefulWidget { const PartyHostScreen({super.key}); @override State<PartyHostScreen> createState() => _PartyHostScreenState(); }
class _PartyHostScreenState extends State<PartyHostScreen> {
  String _region = '목포'; final _regions = ['광주', '목포', '순천', '여수', '전주', '강원도'];
  DateTime? _selectedDate = DateTime.now();

  @override Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.white, appBar: AppBar(title: const Text('여행 방 만들기', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)), body: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('여행 지역', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), const SizedBox(height: 12),
    Wrap(spacing: 8, runSpacing: 8, children: _regions.map((r) => ChoiceChip(label: Text(r), selected: _region == r, onSelected: (_) => setState(() => _region = r), selectedColor: const Color(0xFFFF3B30), labelStyle: TextStyle(color: _region == r ? Colors.white : Colors.black, fontWeight: FontWeight.bold))).toList()), const SizedBox(height: 32),
    const Text('여행 일정 (출발일)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), const SizedBox(height: 12),
    Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(16)), child: Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFFFF3B30), onPrimary: Colors.white, onSurface: Colors.black)), child: CalendarDatePicker(initialDate: _selectedDate!, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)), onDateChanged: (date) => setState(() => _selectedDate = date)))), const Spacer(),
    ElevatedButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('여행 방이 성공적으로 개설되었습니다!'))); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('방 만들기 완료', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
  ])));
}
