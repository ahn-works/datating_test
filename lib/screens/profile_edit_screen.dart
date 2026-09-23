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
  
  final List<String> _availableHobbies = ['맛집탐방', '러닝', '코노', '보드게임', '전시회', '드라이브', '카공', '혼술', '산책'];
  List<String> _selectedHobbies = [];
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
        _selectedHobbies = List<String>.from(data['hobbies'] ?? ['맛집탐방', '코노']);
      } else {
        _nicknameController.text = '매운맛킬러';
        _locationController.text = '마포구 연남동';
        _selectedHobbies = ['맛집탐방', '코노'];
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nicknameController.text.trim().isEmpty) return;
    
    setState(() { _isSaving = true; });
    try {
      await FirebaseFirestore.instance.collection('users').doc('test_user_1').set({
        'nickname': _nicknameController.text.trim(),
        'location': _locationController.text.trim(),
        'hobbies': _selectedHobbies,
        'manner': 41.2, // hardcoded for now
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      if (mounted) {
        Navigator.pop(context, true); // true indicates a refresh is needed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 성공적으로 업데이트되었습니다.')),
        );
      }
    } catch (e) {
      debugPrint("Error saving profile: $e");
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
        iconTheme: IconThemeData(color: textPrimary),
        title: Text('프로필 수정', style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
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
                          image: const DecorationImage(
                            image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&q=80'),
                            fit: BoxFit.cover,
                          ),
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
                
                Text('닉네임', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textSecondary)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nicknameController,
                  style: TextStyle(fontSize: 16, color: textPrimary, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    fillColor: surfaceColor,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: accentColor, width: 2)),
                  ),
                ),
                const SizedBox(height: 24),

                Text('동네 위치', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textSecondary)),
                const SizedBox(height: 8),
                TextField(
                  controller: _locationController,
                  style: TextStyle(fontSize: 16, color: textPrimary, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    fillColor: surfaceColor,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: accentColor, width: 2)),
                  ),
                ),
                const SizedBox(height: 32),

                Text('나의 관심사 / 취향', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textSecondary)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8, runSpacing: 12,
                  children: _availableHobbies.map((hobby) {
                    final isSelected = _selectedHobbies.contains(hobby);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedHobbies.remove(hobby);
                          } else {
                            _selectedHobbies.add(hobby);
                          }
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
                        child: Text(hobby, style: TextStyle(
                          color: isSelected ? Colors.white : textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14
                        )),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 60),
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
