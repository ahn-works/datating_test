
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final Color textPrimary = const Color(0xFF111111);
  final Color textSecondary = const Color(0xFF767676);
  final Color surfaceColor = const Color(0xFFF5F5F7);
  final Color accentColor = const Color(0xFFF19E39);

  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _mbtiController = TextEditingController();
  
    final List<String> _availableHobbies = ['맛집탐방', '러닝', '전시회', '와인', '드라이브', '캠핑', '보드게임', '방탈출', '뮤지컬', '카페투어'];
  final List<String> _availableCloseFriendPersonalities = [
    '또라이', '장난꾸러기', '화끈함', '분위기 메이커', '조용히 챙겨주는', '팩폭러', '리액션 봇', '순둥이', 
    '텐션 폭발', '어색함 제로', '은은한 광기', '다정다감', '츤데레', '허당', '고민 상담소', '선넘는 장난', '솔직함 100%'
  ];
  final List<String> _availableValues = [
    '신중한', '예의바른', '대화가 잘 통하는', '책임감 있는', '배려심 깊은', '자기계발', '긍정적인', '솔직함', 
    '도전적인', '여유로운', '약속을 잘 지키는', '감사할 줄 아는', '유머러스한', '독립적인', '가족적인', 
    '성실한', '편견 없는', '공감 능력이 뛰어난', '도덕적인', '신뢰할 수 있는'
  ];
  List<String> _selectedHobbies = [];
  
  final List<String> _availablePersonalities = ['리액션 요정', '친화력 갑', '긍정적', '경청하는 편', '텐션 높음', '차분함', '유머러스함'];
  List<String> _selectedPersonalities = [];
  
  final List<String> _availableDrinking = ['알쓰', '가볍게 한잔', '분위기 메이커', '술자리 매니아', '비음주'];
  List<String> _selectedDrinking = [];

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc('test_user_1').get();
      if (doc.exists) {
        final data = doc.data()!;
        _nicknameController.text = data['nickname'] ?? '매운맛킬러';
        _locationController.text = data['location'] ?? '마포구 연남동';
        _bioController.text = data['bio'] ?? '새로운 사람 만나는 걸 좋아해요! 잘 부탁드립니다 😊';
        _jobController.text = data['job'] ?? 'IT/개발';
        _mbtiController.text = data['mbti'] ?? 'ENFP';
        _selectedHobbies = List<String>.from(data['hobbies'] ?? ['맛집탐방', '코노']);
        _selectedPersonalities = List<String>.from(data['personalities'] ?? ['리액션 요정', '친화력 갑']);
        _selectedDrinking = List<String>.from(data['drinking'] ?? ['가볍게 한잔']);
      } else {
        _nicknameController.text = '매운맛킬러';
        _locationController.text = '마포구 연남동';
        _bioController.text = '새로운 사람 만나는 걸 좋아해요! 잘 부탁드립니다 😊';
        _jobController.text = 'IT/개발';
        _mbtiController.text = 'ENFP';
        _selectedHobbies = ['맛집탐방', '코노'];
        _selectedPersonalities = ['리액션 요정', '친화력 갑'];
        _selectedDrinking = ['가볍게 한잔'];
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _saveProfile() async {
    if (_nicknameController.text.trim().isEmpty) return;
    
    setState(() { _isSaving = true; });
    try {
      await FirebaseFirestore.instance.collection('users').doc('test_user_1').set({
        'nickname': _nicknameController.text.trim(),
        'location': _locationController.text.trim(),
        'bio': _bioController.text.trim(),
        'job': _jobController.text.trim(),
        'mbti': _mbtiController.text.trim(),
        'hobbies': _selectedHobbies,
        'personalities': _selectedPersonalities,
        'drinking': _selectedDrinking,
        'manner': 41.2, 
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      if (mounted) {
        Navigator.pop(context, true); 
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('프로필이 성공적으로 업데이트되었습니다.')));
      }
    } catch (e) {
      debugPrint("Error saving profile: $e");
    } finally {
      if (mounted) setState(() { _isSaving = false; });
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, String hint = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textSecondary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(fontSize: 16, color: textPrimary, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: const Color(0xFFC7C7CC), fontSize: 15, fontWeight: FontWeight.normal),
            fillColor: surfaceColor,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: accentColor, width: 2)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildChipSection(String title, List<String> available, List<String> selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textSecondary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 12,
          children: available.map((item) {
            final isSelected = selected.contains(item);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) selected.remove(item);
                  else selected.add(item);
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? accentColor : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? accentColor : const Color(0xFFEBEBEF)),
                  boxShadow: isSelected ? [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : [],
                ),
                child: Text(item, style: TextStyle(
                  color: isSelected ? Colors.white : textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14
                )),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        title: Text('프로필 상세 수정', style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: accentColor))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          shape: BoxShape.circle,
                          image: const DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&q=80'), fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: textPrimary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                _buildTextField('닉네임', _nicknameController),
                _buildTextField('동네 위치', _locationController),
                
                Row(
                  children: [
                    Expanded(child: _buildTextField('직무/직업', _jobController, hint: '예: IT/개발')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('MBTI', _mbtiController, hint: '예: ENFP')),
                  ],
                ),
                
                _buildTextField('한줄 소개', _bioController, maxLines: 2, hint: '나를 표현할 수 있는 한줄 소개를 적어주세요!'),
                
                _buildChipSection('성격 태그', _availablePersonalities, _selectedPersonalities),
                _buildChipSection('음주 성향', _availableDrinking, _selectedDrinking),
                _buildChipSection('나의 관심사 / 취향', _availableHobbies, _selectedHobbies),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isSaving 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('저장하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}
