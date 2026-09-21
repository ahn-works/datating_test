import 'package:flutter/material.dart';

class OOMUHostScreen extends StatefulWidget {
  const OOMUHostScreen({super.key});

  @override
  State<OOMUHostScreen> createState() => _OOMUHostScreenState();
}

class _OOMUHostScreenState extends State<OOMUHostScreen> {
  final Color darkGreen = const Color(0xFF14422D);
  String _transportMethod = '각자 이동';
  bool _isFemaleOnly = false;
  String _selectedCategory = '';

  final List<Map<String, dynamic>> _categories = [
    {'icon': '🎤', 'name': '코노/노래'},
    {'icon': '🍻', 'name': '술/맛집'},
    {'icon': '☕', 'name': '카페/수다'},
    {'icon': '✈️', 'name': '여행/드라이브'},
    {'icon': '🎳', 'name': '액티비티'},
    {'icon': '📚', 'name': '독서/스터디'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('새로운 동네 모임 열기', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('어떤 취향의 찐친을 찾고 있나요?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.3)),
          const SizedBox(height: 32),
          
          const Text('모임 카테고리', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _categories.map((cat) {
              bool isSelected = _selectedCategory == cat['name'];
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat['name']),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? darkGreen : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? darkGreen : Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(cat['icon'], style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        cat['name'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          _buildTextField('모임 제목', '예: 불금엔 역시 코노! 스트레스 풀 분'),
          const SizedBox(height: 24),
          
          _buildTextField('만날 장소', '예: 홍대입구역 9번 출구 앞'),
          const SizedBox(height: 24),
          
          _buildTextField('일시', '예: 이번주 토요일 오후 2시'),
          const SizedBox(height: 32),

          const Text('이동 방법 (선택)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTransportOption('각자 이동'),
              const SizedBox(width: 12),
              _buildTransportOption('내 차로 카풀'),
            ],
          ),
          if (_transportMethod == '내 차로 카풀') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFFBF9F6), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('여성 전용 카풀 설정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 4),
                      Text('안전을 위해 여성 멤버만 탑승하도록 제한합니다.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  Switch(
                    value: _isFemaleOnly,
                    activeColor: darkGreen,
                    onChanged: (val) => setState(() => _isFemaleOnly = val),
                  )
                ],
              ),
            )
          ],
          
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('모임 등록하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            filled: true,
            fillColor: const Color(0xFFFBF9F6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildTransportOption(String title) {
    bool isSelected = _transportMethod == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _transportMethod = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? darkGreen : Colors.white,
            border: Border.all(color: isSelected ? darkGreen : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
