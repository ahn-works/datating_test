
import 'package:flutter/material.dart';

class PartyHostScreen extends StatefulWidget {
  const PartyHostScreen({super.key});
  @override State<PartyHostScreen> createState() => _PartyHostScreenState();
}
class _PartyHostScreenState extends State<PartyHostScreen> {
  String _region = '목포';
  String _type = '당일치기';
  final _regions = ['광주', '목폼', '순천', '여수', '전주', '강원도'];
  final _types = ['당일치기', '1박 2일'];
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(title: const Text('여행 방 만들기', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
    body: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('여행 지역', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: _regions.map((r) => ChoiceChip(label: Text(r), selected: _region == r, onSelected: (_) => setState(() => _region = r), selectedColor: const Color(0xFFFF3B30), labelStyle: TextStyle(color: _region == r ? Colors.white : Colors.black, fontWeight: FontWeight.bold))).toList()),
      const SizedBox(height: 24),
      const Text('일정 유형', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 8),
      Row(children: _types.map((t) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(t), selected: _type == t, onSelected: (_) => setState(() => _type = t), selectedColor: const Color(0xFFFF3B30), labelStyle: TextStyle(color: _type == t ? Colors.white : Colors.black, fontWeight: FontWeight.bold)))).toList()),
      const Spacer(),
      ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('방 만들기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
    ])),
  );
}
