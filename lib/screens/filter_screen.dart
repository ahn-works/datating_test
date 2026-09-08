
import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});
  @override State<FilterScreen> createState() => _FilterScreenState();
}
class _FilterScreenState extends State<FilterScreen> {
  RangeValues _age = const RangeValues(20, 35);
  String _gender = '전체';
  final _regions = ['광주', '목포', '순천', '여수', '전주', '강원도'];
  List<String> _selRegions = [];
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(title: const Text('필터', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      const Text('나이대', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      RangeSlider(values: _age, min: 18, max: 50, divisions: 32, activeColor: const Color(0xFFFF3B30), labels: RangeLabels(_age.start.round().toString(), _age.end.round().toString()), onChanged: (v) => setState(() => _age = v)),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_age.start.round().toString() + '세'), Text(_age.end.round().toString() + '세')]),
      const SizedBox(height: 24),
      const Text('성별', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      Row(children: ['전체', '남성', '여성'].map((g) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(g), selected: _gender == g, onSelected: (_) => setState(() => _gender = g), selectedColor: const Color(0xFFFF3B30), labelStyle: TextStyle(color: _gender == g ? Colors.white : Colors.black, fontWeight: FontWeight.bold)))).toList()),
      const SizedBox(height: 24),
      const Text('여행 지역', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: _regions.map((r) => FilterChip(label: Text(r), selected: _selRegions.contains(r), onSelected: (v) => setState(() => v ? _selRegions.add(r) : _selRegions.remove(r)), selectedColor: const Color(0xFFFF3B30), labelStyle: TextStyle(color: _selRegions.contains(r) ? Colors.white : Colors.black))).toList()),
      const SizedBox(height: 48),
      ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.black, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('필터 적용', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
    ]),
  );
}
