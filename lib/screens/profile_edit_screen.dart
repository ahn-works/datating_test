import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/global_data.dart';
import '../services/r2_storage_service.dart';

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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _mbtiController = TextEditingController();
  
  String _gender = '여성';
  String _role = 'user';
  String _avatarUrl = 'assets/images/kr_female_1.jpg';
  
  final List<String> _availableHobbies = ['맛집탐방', '러닝', '전시회', '와인', '드라이브', '캠핑', '보드게임', '방탈출', '뮤지컬', '카페투어'];
  List<String> _selectedHobbies = [];
  
  final List<String> _availablePersonalities = ['리액션 요정', '친화력 갑', '긍정적', '경청하는 편', '텐션 높음', '차분함', '유머러스함'];
  List<String> _selectedPersonalities = [];
  
  final List<String> _availableDrinking = ['알쓰', '가볍게 한잔', '분위기 메이커', '술자리 매니아', '비음주'];
  List<String> _selectedDrinking = [];

  bool _isLoading = true;
  bool _isSaving = false;

  List<String> _parseSafeList(dynamic value, List<String> defaultValue) {
    if (value == null) return defaultValue;
    if (value is List) {
      return value.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return [value.trim()];
    }
    return defaultValue;
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(globalData.activeUserId).get();
      if (doc.exists) {
        final data = doc.data()!;
        _nicknameController.text = data['nickname'] ?? (globalData.activeUserId == 'admin_user' ? '오오무 운영팀' : '매운맛킬러');
        _nameController.text = data['name'] ?? (globalData.activeUserId == 'admin_user' ? '총괄관리자' : '김민우');
        _ageController.text = (data['age'] ?? (globalData.activeUserId == 'admin_user' ? 29 : 27)).toString();
        _gender = data['gender'] ?? (globalData.activeUserId == 'admin_user' ? '여성' : '남성');
        _role = data['role'] ?? (globalData.activeUserId == 'admin_user' ? 'admin' : 'user');
        _locationController.text = data['location'] ?? '서울 마포구 연남동';
        _bioController.text = data['bio'] ?? '새로운 사람 만나는 걸 좋아해요! 잘 부탁드립니다 😊';
        _jobController.text = data['job'] ?? 'IT/개발';
        _mbtiController.text = data['mbti'] ?? 'ENFP';
        _selectedHobbies = _parseSafeList(data['hobbies'], ['맛집탐방', '보드게임']);
        _selectedPersonalities = _parseSafeList(data['personalities'], ['리액션 요정', '친화력 갑']);
        _selectedDrinking = _parseSafeList(data['drinking'], ['가볍게 한잔']);
        _avatarUrl = (data['photoUrl'] ?? data['avatarUrl'] ?? 'assets/images/kr_female_1.jpg').toString();
      } else {
        _nicknameController.text = '오오무 운영팀';
        _nameController.text = '총괄관리자';
        _ageController.text = '29';
        _gender = '여성';
        _role = 'admin';
        _locationController.text = '서울 마포구 연남동';
        _bioController.text = '건전하고 따뜻한 동네 모임 문화를 만들어가는 오오무 공식 계정입니다 🌿';
        _jobController.text = '서비스 기획/운영';
        _mbtiController.text = 'ENFJ';
        _selectedHobbies = ['맛집탐방', '보드게임'];
        _selectedPersonalities = ['리액션 요정', '친화력 갑'];
        _selectedDrinking = ['가볍게 한잔'];
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _saveProfile() async {
    if (_nicknameController.text.trim().isEmpty) return;
    
    setState(() { _isSaving = true; });
    try {
      final int parsedAge = int.tryParse(_ageController.text.trim()) ?? 28;
      await FirebaseFirestore.instance.collection('users').doc(globalData.activeUserId).set({
        'nickname': _nicknameController.text.trim(),
        'name': _nameController.text.trim(),
        'age': parsedAge,
        'gender': _gender,
        'role': _role,
        'photoUrl': _avatarUrl,
        'avatarUrl': _avatarUrl,
        'location': _locationController.text.trim(),
        'bio': _bioController.text.trim(),
        'job': _jobController.text.trim(),
        'mbti': _mbtiController.text.trim(),
        'hobbies': _selectedHobbies,
        'personalities': _selectedPersonalities,
        'drinking': _selectedDrinking,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      globalData.userNickname.value = _nicknameController.text.trim();
      globalData.userLocation.value = _locationController.text.trim();
      
      if (mounted) {
        Navigator.pop(context, true); 
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✨ 프로필이 성공적으로 업데이트되었습니다.')));
      }
    } catch (e) {
      debugPrint("Error saving profile: $e");
    } finally {
      if (mounted) setState(() { _isSaving = false; });
    }
  }

  bool _isUploadingPhoto = false;

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (file == null) return;

      setState(() => _isUploadingPhoto = true);
      final bytes = await file.readAsBytes();
      String uploadedUrl = '';
      try {
        uploadedUrl = await r2Storage.uploadImageBytes(
          bytes: bytes,
          fileName: file.name,
          category: R2UploadCategory.profile,
        );
      } catch (e) {
        debugPrint('[R2 Storage] Upload fallback: $e');
        uploadedUrl = file.path;
      }

      final finalAvatar = uploadedUrl.isNotEmpty ? uploadedUrl : file.path;
      setState(() {
        _avatarUrl = finalAvatar;
        _isUploadingPhoto = false;
      });
      globalData.updateAvatar(finalAvatar);

      // Immediately sync to active user doc
      await FirebaseFirestore.instance.collection('users').doc(globalData.activeUserId).set({
        'photoUrl': finalAvatar,
        'avatarUrl': finalAvatar,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(source == ImageSource.camera
                ? '📸 카메라로 촬영한 새 프로필 사진이 설정되었습니다!'
                : '🖼️ 갤러리에서 선택한 새 프로필 사진이 설정되었습니다!'),
            backgroundColor: const Color(0xFFF38020),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사진 업로드 실패: $e')),
        );
      }
    }
  }

  void _showAvatarPickerModal(BuildContext context) {
    final presetAvatars = [
      'assets/images/kr_female_1.jpg',
      'assets/images/kr_female_2.jpg',
      'assets/images/kr_female_3.jpg',
      'assets/images/kr_male_1.jpg',
      'assets/images/kr_male_2.jpg',
      'assets/images/kr_male_3.jpg',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: const Color(0xFFE5E5EA), borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('프로필 사진 변경', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickAndUploadPhoto(ImageSource.camera);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5F0),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFF5E36).withOpacity(0.3)),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.photo_camera_rounded, color: Color(0xFFFF5E36), size: 28),
                              SizedBox(height: 8),
                              Text('사진 찍기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickAndUploadPhoto(ImageSource.gallery);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7EE),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF38020).withOpacity(0.3)),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.photo_library_rounded, color: Color(0xFFF38020), size: 28),
                              SizedBox(height: 8),
                              Text('앨범에서 선택', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('기본 캐릭터 아바타', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF767676))),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: presetAvatars.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, idx) {
                      final pAvatar = presetAvatars[idx];
                      final isSelected = _avatarUrl == pAvatar;
                      return GestureDetector(
                        onTap: () async {
                          Navigator.pop(ctx);
                          setState(() => _avatarUrl = pAvatar);
                          globalData.updateAvatar(pAvatar);
                          await FirebaseFirestore.instance.collection('users').doc(globalData.activeUserId).set({
                            'photoUrl': pAvatar,
                            'avatarUrl': pAvatar,
                            'updatedAt': FieldValue.serverTimestamp(),
                          }, SetOptions(merge: true));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('✨ 프로필 캐릭터가 설정되었습니다.')),
                            );
                          }
                        },
                        child: Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFF5E36) : const Color(0xFFE5E5EA),
                              width: isSelected ? 3 : 1.5,
                            ),
                            image: DecorationImage(image: AssetImage(pAvatar), fit: BoxFit.cover),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  ImageProvider _getAvatarProvider(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return NetworkImage(url);
    }
    return AssetImage(url);
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, String hint = '', TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textSecondary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
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
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('성별', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textSecondary)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _gender = '여성'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _gender == '여성' ? const Color(0xFFF25767) : surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _gender == '여성' ? const Color(0xFFF25767) : const Color(0xFFEBEBEF)),
                  ),
                  child: Center(
                    child: Text(
                      '👩 여성',
                      style: TextStyle(
                        color: _gender == '여성' ? Colors.white : textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _gender = '남성'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _gender == '남성' ? const Color(0xFF4A90E2) : surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _gender == '남성' ? const Color(0xFF4A90E2) : const Color(0xFFEBEBEF)),
                  ),
                  child: Center(
                    child: Text(
                      '👨 남성',
                      style: TextStyle(
                        color: _gender == '남성' ? Colors.white : textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
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
        const SizedBox(height: 28),
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
                  child: GestureDetector(
                    onTap: _isUploadingPhoto ? null : () => _showAvatarPickerModal(context),
                    child: Stack(
                      children: [
                        Container(
                          width: 104, height: 104,
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE5E5EA), width: 2),
                            image: DecorationImage(image: _getAvatarProvider(_avatarUrl), fit: BoxFit.cover),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: _isUploadingPhoto
                              ? Container(
                                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                                  child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                        if (_role == 'admin')
                          Positioned(
                            top: 0, right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFFF19E39), Color(0xFFF25767)]),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('👑 Admin', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text('사진을 탭하여 변경', style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 32),
                
                _buildTextField('닉네임 (활동명)', _nicknameController, hint: '예: 오오무 운영팀 또는 닉네임'),
                
                Row(
                  children: [
                    Expanded(child: _buildTextField('이름 (실명)', _nameController, hint: '예: 홍길동')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('나이', _ageController, hint: '예: 29', keyboardType: TextInputType.number)),
                  ],
                ),
                
                _buildGenderSelector(),
                _buildTextField('활동 동네 / 지역', _locationController, hint: '예: 서울 마포구 연남동'),
                
                Row(
                  children: [
                    Expanded(child: _buildTextField('직무/직업', _jobController, hint: '예: IT/개발')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('MBTI', _mbtiController, hint: '예: ENFJ')),
                  ],
                ),
                
                _buildTextField('한줄 소개', _bioController, maxLines: 2, hint: '나를 표현할 수 있는 한줄 소개를 적어주세요!'),
                
                _buildChipSection('성격 태그', _availablePersonalities, _selectedPersonalities),
                _buildChipSection('음주 성향', _availableDrinking, _selectedDrinking),
                _buildChipSection('나의 관심사 / 취향', _availableHobbies, _selectedHobbies),
                
                const SizedBox(height: 30),
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