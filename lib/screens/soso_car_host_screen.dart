import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'soso_car_chat_screen.dart';

class OOMUHostScreen extends StatefulWidget {
  const OOMUHostScreen({super.key});

  @override
  State<OOMUHostScreen> createState() => _OOMUHostScreenState();
}

class _OOMUHostScreenState extends State<OOMUHostScreen> {
  final Color textPrimary = const Color(0xFF111111);
  final Color textSecondary = const Color(0xFF767676);
  final Color surfaceColor = const Color(0xFFF5F5F7);
  final Color accentColor = const Color(0xFF007AFF);
  final Color destructiveColor = const Color(0xFFFF3B30);

  String _transportMethod = '각자 이동';
  bool _isFemaleOnly = false;
  String _selectedCategory = '';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();


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
        title: Text('새로운 모임 열기', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('어떤 취향의 찐친을 찾고 있나요?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textPrimary, height: 1.3)),
          const SizedBox(height: 40),
          
          Text('모임 카테고리', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textSecondary)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              bool isSelected = _selectedCategory == cat['name'];
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat['name']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? textPrimary : Colors.transparent, width: isSelected ? 2 : 0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cat['icon'], style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 8),
                      Text(cat['name'], style: TextStyle(color: textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 13)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),

          _buildTextField('모임 제목', '예: 불금엔 역시 코노! 스트레스 풀 분', _titleController),
          const SizedBox(height: 32),
          _buildTextField('만날 장소', '예: 홍대입구역 9번 출구 앞', _locationController),
          const SizedBox(height: 32),
          _buildTextField('일시', '예: 이번주 토요일 오후 2시', _dateController),
          const SizedBox(height: 40),

          Text('이동 방법 (선택)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textSecondary)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                _buildTransportOption('각자 이동'),
                _buildTransportOption('내 차로 카풀'),
              ],
            ),
          ),
          
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: _transportMethod == '내 차로 카풀' ? Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('여성 전용 카풀 설정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary)),
                      const SizedBox(height: 4),
                      Text('안전을 위해 여성 멤버만 탑승하도록 제한합니다.', style: TextStyle(fontSize: 13, color: textSecondary)),
                    ],
                  ),
                  CupertinoSwitch(
                    value: _isFemaleOnly,
                    activeColor: accentColor,
                    onChanged: (val) => setState(() => _isFemaleOnly = val),
                  )
                ],
              ),
            ) : const SizedBox.shrink(),
          ),
          
          const SizedBox(height: 60),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty || _selectedCategory.isEmpty) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('카테고리와 제목을 입력해주세요!')));
                   return;
                }
                
                // Firestore에 데이터 쓰기!
                await FirebaseFirestore.instance.collection('meetups').add({
                  'title': _titleController.text,
                  'category': _selectedCategory,
                  'location': _locationController.text.isEmpty ? '위치 미정' : _locationController.text,
                  'date': _dateController.text.isEmpty ? '시간 미정' : _dateController.text,
                  'host': '매운맛킬러', // Dummy User
                  'manner': 41.2,
                  'price': 'N빵',
                  'members': '1/4',
                  'isFemaleOnly': _isFemaleOnly,
                  'transport': _transportMethod,
                  'imageUrl': 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&q=80', // Dummy Image
                  'createdAt': FieldValue.serverTimestamp()
                });

                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    contentPadding: const EdgeInsets.all(24),
                    title: const Center(child: Text('🎉 모임 개설 완료!', style: TextStyle(fontWeight: FontWeight.w800))),
                    content: const Text('취향 저격 찐친 모임이 만들어졌습니다!\n참여자들이 기다리는 채팅방으로 이동할까요?', textAlign: TextAlign.center, style: TextStyle(height: 1.5)),
                    actions: [
                      Row(
                        children: [
                          Expanded(child: TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: const Text('닫기', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)))),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: textPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              onPressed: () {
                                Navigator.pop(ctx); // close dialog
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OOMUChatScreen(title: '새로 개설한 모임', memberCount: 1)));
                              },
                              child: const Text('이동하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      )
                    ]
                  )
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: textPrimary,
                elevation: 0,
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

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textSecondary)),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: const Color(0xFFAEAEC2), fontSize: 15),
            filled: true,
            fillColor: surfaceColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: textPrimary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))] : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? textPrimary : textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
