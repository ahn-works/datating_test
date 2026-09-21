import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});
  @override State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final Color textPrimary = const Color(0xFF111111);
  final Color textSecondary = const Color(0xFF767676);
  final Color surfaceColor = const Color(0xFFF5F5F7);
  final Color accentColor = const Color(0xFF007AFF);

  RangeValues _age = const RangeValues(20, 35);
  String _gender = '제한 없음';
  final _categories = ['코노/노래', '술/맛집', '카페/수다', '여행/드라이브', '액티비티', '독서/스터디', '보드게임'];
  List<String> _selCategories = [];

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      title: Text('상세 필터', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 18)), 
      backgroundColor: Colors.white, 
      elevation: 0, 
      iconTheme: IconThemeData(color: textPrimary),
      actions: [
        TextButton(onPressed: () { setState(() { _age = const RangeValues(20, 35); _gender = '제한 없음'; _selCategories.clear(); }); }, child: Text('초기화', style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600)))
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(24), 
      children: [
        Text('나이대', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: textPrimary)),
        const SizedBox(height: 16),
        RangeSlider(
          values: _age, min: 18, max: 50, divisions: 32, 
          activeColor: textPrimary, inactiveColor: surfaceColor,
          onChanged: (v) => setState(() => _age = v)
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Text('${_age.start.round()}세', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700)), 
            Text('${_age.end.round()}세', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700))
          ]
        ),
        const SizedBox(height: 40),
        
        Text('성별', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: textPrimary)),
        const SizedBox(height: 16),
        Row(
          children: ['제한 없음', '여성만', '남성만'].map((g) {
            bool isSel = _gender == g;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _gender = g),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSel ? textPrimary : surfaceColor,
                    borderRadius: BorderRadius.circular(12)
                  ),
                  alignment: Alignment.center,
                  child: Text(g, style: TextStyle(color: isSel ? Colors.white : textSecondary, fontWeight: isSel ? FontWeight.bold : FontWeight.w600, fontSize: 14)),
                )
              )
            );
          }).toList()
        ),
        const SizedBox(height: 40),

        Text('관심 카테고리', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: textPrimary)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8, runSpacing: 12, 
          children: _categories.map((c) {
            bool isSel = _selCategories.contains(c);
            return GestureDetector(
              onTap: () => setState(() => isSel ? _selCategories.remove(c) : _selCategories.add(c)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSel ? Colors.white : surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSel ? textPrimary : Colors.transparent)
                ),
                child: Text(c, style: TextStyle(color: isSel ? textPrimary : textSecondary, fontWeight: isSel ? FontWeight.w700 : FontWeight.w600, fontSize: 14)),
              )
            );
          }).toList()
        ),
        
        const SizedBox(height: 60),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context), 
            style: ElevatedButton.styleFrom(
              backgroundColor: textPrimary, 
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
            ), 
            child: const Text('필터 적용하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
          ),
        ),
      ]
    ),
  );
}
