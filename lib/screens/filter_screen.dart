import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  double _distance = 5.0;
  RangeValues _ageRange = const RangeValues(20, 35);
  final List<String> _selectedTags = ['카페 투어'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('탐색 필터', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('거리', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${_distance.round()} km 이내', style: const TextStyle(color: Color(0xFFFF8A65), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: _distance,
              min: 1, max: 20, divisions: 19,
              activeColor: const Color(0xFFFF8A65),
              inactiveColor: Colors.grey.shade200,
              onChanged: (val) => setState(() => _distance = val),
            ),
            const SizedBox(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('나이', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${_ageRange.start.round()}세 ~ ${_ageRange.end.round()}세', style: const TextStyle(color: Color(0xFFFF8A65), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            RangeSlider(
              values: _ageRange,
              min: 20, max: 45, divisions: 25,
              activeColor: const Color(0xFFFF8A65),
              inactiveColor: Colors.grey.shade200,
              onChanged: (vals) => setState(() => _ageRange = vals),
            ),
            const SizedBox(height: 32),
            
            const Text('관심사 필터 (최대 3개)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: ['카페 투어', '와인', '러닝', '전시회', '사진', '반려동물', '영화', '드라이브']
                  .map((tag) => FilterChip(
                        label: Text(tag),
                        selected: _selectedTags.contains(tag),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              if (_selectedTags.length < 3) _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                        },
                        backgroundColor: const Color(0xFFF5F5F5),
                        selectedColor: const Color(0xFFFFF0EC),
                        checkmarkColor: const Color(0xFFFF8A65),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                      )).toList(),
            ),
            
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A65),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('적용하기', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
