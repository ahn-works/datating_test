import 'package:flutter/material.dart';

class SosoCarHostScreen extends StatefulWidget {
  const SosoCarHostScreen({super.key});

  @override
  State<SosoCarHostScreen> createState() => _SosoCarHostScreenState();
}

class _SosoCarHostScreenState extends State<SosoCarHostScreen> {
  final TextEditingController _destController = TextEditingController();
  final TextEditingController _locController = TextEditingController();
  
  final List<String> _availableTags = ['조용한 힐링', '수다 환영', '플리 공유', '비흡연 차량', '반려동물 가능'];
  final Set<String> _selectedTags = {};

  void _submit() {
    if (_destController.text.isEmpty || _locController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('목적지와 집결 장소를 모두 입력해주세요!')));
      return;
    }
    
    // 새 모임 데이터 생성
    final newTrip = {
      'title': _destController.text,
      'location': _locController.text,
      'tags': _selectedTags.map((t) => '#').toList(),
      'driverName': '나(호스트)',
      'seats': '3/4석',
      'price': '약 10,000원',
      'image': 'https://picsum.photos/600/300?random=',
      'badge': '방금 등록',
      'time': '오늘',
    };
    
    Navigator.pop(context, newTrip);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('여행 모임 등록', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('어디로 떠나시나요?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            TextField(
              controller: _destController,
              decoration: InputDecoration(
                hintText: '예: 강화도 동막해변 일몰 팟',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            
            const Text('집결 장소 및 시간', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            TextField(
              controller: _locController,
              decoration: InputDecoration(
                hintText: '예: 마포구청역 2번 출구',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),

            const Text('내 차 정보 및 성향', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) _selectedTags.remove(tag);
                      else _selectedTags.add(tag);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2E4F28) : Colors.grey.shade100, 
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Text(tag, style: TextStyle(fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.black87)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            const Text('비용 정산 방식', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFF2E4F28)), borderRadius: BorderRadius.circular(12), color: const Color(0xFFE2F0D9).withOpacity(0.3)),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF2E4F28)),
                  SizedBox(width: 12),
                  Text('유류비 + 톨비 1/N 정산', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC04020), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('모집 시작하기', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
