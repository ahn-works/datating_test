import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'soso_car_home_screen.dart';
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
  final Color accentColor = const Color(0xFFF19E39);
  final Color destructiveColor = const Color(0xFFFF3B30);

  String _selectedCategory = '맛집/카페';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  String _memberCount = '2~4명';
  String _genderLimit = '성별 무관';
  String _ageLimit = '20대~30대';

  final List<Map<String, dynamic>> _categories = [
    {'name': '맛집/카페', 'icon': Icons.restaurant},
    {'name': '술/친목', 'icon': Icons.local_bar},
    {'name': '문화/전시', 'icon': Icons.palette},
    {'name': '러닝/운동', 'icon': Icons.directions_run},
    {'name': '드라이브', 'icon': Icons.directions_car},
    {'name': '스터디', 'icon': Icons.menu_book},
  ];

  bool _isSaving = false;

  void _showBottomSheetPicker(String title, List<String> options, String currentValue, Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFEBEBEF), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary)),
              const SizedBox(height: 16),
              ...options.map((opt) {
                final isSelected = opt == currentValue;
                return ListTile(
                  title: Text(opt, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? accentColor : textPrimary)),
                  trailing: isSelected ? Icon(Icons.check_circle, color: accentColor) : null,
                  onTap: () {
                    onSelected(opt);
                    Navigator.pop(ctx);
                  },
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );
  }

  Future<void> _submitMeetup() async {
    if (_titleController.text.trim().isEmpty || _descController.text.trim().isEmpty || _locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('필수 정보를 모두 입력해주세요.')));
      return;
    }

    setState(() { _isSaving = true; });

    try {
      await FirebaseFirestore.instance.collection('meetups').add({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'location': _locationController.text.trim(),
        'category': _selectedCategory,
        'memberCount': _memberCount,
        'genderLimit': _genderLimit,
        'ageLimit': _ageLimit,
        'host': '매운맛킬러', // Mock User
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.celebration, color: Color(0xFFF19E39), size: 64),
                  const SizedBox(height: 24),
                  Text('모임이 개설되었습니다!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary)),
                  const SizedBox(height: 12),
                  Text('새로운 사람들과의 만남을 기대해보세요.', textAlign: TextAlign.center, style: TextStyle(color: textSecondary, fontSize: 14)),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: accentColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
                        Navigator.pop(ctx); // close dialog
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OOMUChatScreen(title: '새로 개설한 모임', memberCount: 1)));
                      },
                      child: const Text('채팅방으로 이동', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() { _isSaving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('새로운 모임 열기', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
        leading: IconButton(
          icon: Icon(Icons.close, color: textPrimary),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OOMUHomeScreen())),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cover Image Upload (Dummy UI)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1528605248644-14dd04022da1?w=800&q=80'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_a_photo, color: Colors.white, size: 32),
                    SizedBox(height: 8),
                    Text('커버 사진 등록', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 2. Category Selection (Horizontal Scroll Cards)
            Text('어떤 모임인가요?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat['name'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat['name']),
                    child: Container(
                      width: 88,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? accentColor.withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? accentColor : const Color(0xFFEBEBEF), width: isSelected ? 2 : 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(cat['icon'], color: isSelected ? accentColor : textSecondary, size: 32),
                          const SizedBox(height: 8),
                          Text(cat['name'], style: TextStyle(color: isSelected ? accentColor : textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),

            // 3. Meetup Info
            Text('모임의 기본 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
            const SizedBox(height: 16),
            _buildTextField('모임 제목', _titleController, '예) 연남동에서 커피 한잔 하실 분!'),
            _buildTextField('모임 장소', _locationController, '예) 마포구 연남동 (또는 구체적인 카페명)'),
            _buildTextField('상세 소개', _descController, '어떤 사람들과 어떤 시간을 보내고 싶은지 자세히 적어주세요.', maxLines: 4),
            
            const SizedBox(height: 40),

            // 4. Conditions (Toss/Social App Style Settings)
            Text('참여 조건 설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
            const SizedBox(height: 16),
            _buildSettingRow('참여 인원', _memberCount, () {
              _showBottomSheetPicker('참여 인원', ['2명 (1:1)', '2~4명', '3~6명', '인원 제한 없음'], _memberCount, (val) => setState(() => _memberCount = val));
            }),
            _buildSettingRow('성별 제한', _genderLimit, () {
              _showBottomSheetPicker('성별 제한', ['성별 무관', '여성만', '남성만'], _genderLimit, (val) => setState(() => _genderLimit = val));
            }),
            _buildSettingRow('연령대', _ageLimit, () {
              _showBottomSheetPicker('연령대', ['연령 무관', '20대만', '30대만', '20대~30대', '30대~40대'], _ageLimit, (val) => setState(() => _ageLimit = val));
            }),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _submitMeetup,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isSaving 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('새로운 모임 열기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textSecondary)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFC7C7CC), fontSize: 15, fontWeight: FontWeight.normal),
              fillColor: surfaceColor,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: accentColor, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String title, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
            Row(
              children: [
                Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: accentColor)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: textSecondary, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
