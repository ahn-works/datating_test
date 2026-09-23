import io

with io.open('lib/screens/profile_edit_screen.dart', 'r', encoding='utf-8') as f:
    edit_screen = f.read()

# We need to add fields for bio, mbti, job, personality, drinking
# Let's completely rewrite profile_edit_screen.dart to have rich fields!
new_edit_code = """
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
  
  final List<String> _availableHobbies = ['맛집탐방', '러닝', '코노', '보드게임', '전시회', '드라이브', '카공', '혼술', '산책'];
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
"""
with io.open('lib/screens/profile_edit_screen.dart', 'w', encoding='utf-8') as f:
    f.write(new_edit_code)

# Let's also completely rewrite my_page_screen.dart to render these rich fields beautifully!
new_my_page_code = """
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'soso_car_home_screen.dart';
import 'soso_car_host_screen.dart';
import 'chat_screen.dart';
import 'oomu_my_trips_screen.dart';
import 'profile_edit_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color textPrimary = const Color(0xFF111111);
    final Color textSecondary = const Color(0xFF767676);
    final Color surfaceColor = const Color(0xFFF5F5F7);
    final Color accentColor = const Color(0xFFF19E39);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('마이페이지', style: TextStyle(color: accentColor, fontSize: 24, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: accentColor),
            tooltip: '프로필 수정',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen()));
            }
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc('test_user_1').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: accentColor));
          }
          
          String nickname = '매운맛킬러';
          String location = '마포구 연남동';
          String bio = '새로운 사람 만나는 걸 좋아해요! 잘 부탁드립니다 😊';
          String jobAndMbti = 'IT/개발 • ENFP';
          double manner = 41.2;
          List<String> hobbies = ['맛집탐방', '코노'];
          List<String> personalities = ['리액션 요정', '친화력 갑'];
          List<String> drinking = ['가볍게 한잔'];
          
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            nickname = data['nickname'] ?? nickname;
            location = data['location'] ?? location;
            bio = data['bio'] ?? bio;
            final job = data['job'] ?? 'IT/개발';
            final mbti = data['mbti'] ?? 'ENFP';
            jobAndMbti = '$job • $mbti';
            manner = (data['manner'] ?? manner).toDouble();
            if (data['hobbies'] != null) hobbies = List<String>.from(data['hobbies']);
            if (data['personalities'] != null) personalities = List<String>.from(data['personalities']);
            if (data['drinking'] != null) drinking = List<String>.from(data['drinking']);
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // User Profile Card (Rich Style)
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen()));
                },
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFEBEBEF)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 72, height: 72,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&q=80'), fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(nickname, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary)),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFC7C7CC)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(jobAndMbti, style: TextStyle(color: accentColor, fontSize: 14, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(location, style: TextStyle(color: textSecondary, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16)),
                        child: Text('"$bio"', style: TextStyle(fontSize: 14, color: textSecondary, fontStyle: FontStyle.italic)),
                      ),
                      const SizedBox(height: 24),
                      Container(height: 1, color: const Color(0xFFEBEBEF)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('나의 매너 온도', style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary, fontSize: 14)),
                          Row(
                            children: [
                              Text('${manner}°C', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: accentColor)),
                              const SizedBox(width: 4),
                              Icon(Icons.thermostat, color: accentColor, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Lifestyle Tags
              Text('성향 및 라이프스타일', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
              const SizedBox(height: 16),
              _buildInfoRow('성격', personalities, surfaceColor, textPrimary),
              const SizedBox(height: 12),
              _buildInfoRow('음주', drinking, surfaceColor, textPrimary),
              const SizedBox(height: 32),
              
              if (hobbies.isNotEmpty) ...[
                Text('나의 관심사 / 취향', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: hobbies.map((hobby) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEBEBEF))),
                    child: Text(hobby, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                  )).toList(),
                ),
                const SizedBox(height: 40),
              ],
              
              Text('나의 활동 배지', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    _buildBadge('👑', '파티 마스터', '모임 개설 10회', textPrimary),
                    _buildBadge('🗣️', '핵인싸', '모임 참여 20회', textPrimary),
                    _buildBadge('💖', '매너왕', '매너 온도 40도+', textPrimary),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),

              Text('설정 및 관리', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: accentColor)),
              const SizedBox(height: 16),
              _buildMenuItem(Icons.favorite_border, '내가 찜한 모임', textPrimary),
              _buildMenuItem(Icons.history, '참여/개설 내역', textPrimary),
              _buildMenuItem(Icons.notifications_outlined, '알림 설정', textPrimary),
              _buildMenuItem(Icons.support_agent, '고객 센터', textPrimary),
              
              const SizedBox(height: 40),
            ],
          );
        }
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildInfoRow(String title, List<String> tags, Color surfaceColor, Color textPrimary) {
    if (tags.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 60, child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF767676), height: 1.5))),
        Expanded(
          child: Wrap(
            spacing: 8, runSpacing: 8,
            children: tags.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(8)),
              child: Text(t, style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String emoji, String title, String subtitle, Color textPrimary) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: textPrimary)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF767676))),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: textPrimary, size: 24),
          const SizedBox(width: 16),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFC7C7CC)),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF111111),
      unselectedItemColor: const Color(0xFFC7C7CC),
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      elevation: 20,
      backgroundColor: Colors.white,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_,__,___) => const OOMUHomeScreen(), transitionDuration: Duration.zero));
        } else if (index == 1) { 
          Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => const OOMUHostScreen(), transitionDuration: Duration.zero)); 
        } else if (index == 2) {
          Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_,__,___) => const OOMUMyTripsScreen(), transitionDuration: Duration.zero));
        }
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined, size: 26), activeIcon: Icon(Icons.explore, size: 26), label: '탐색'),
        const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 26), activeIcon: Icon(Icons.add_circle, size: 26), label: '만들기'),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.chat_bubble_outline, size: 24),
              Positioned(right: -6, top: -6, child: Container(padding: const EdgeInsets.all(5), decoration: const BoxDecoration(color: Color(0xFFFF3B30), shape: BoxShape.circle), child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
            ],
          ),
          activeIcon: const Icon(Icons.chat_bubble, size: 24),
          label: '내 모임',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 26), activeIcon: Icon(Icons.person, size: 26), label: 'MY'),
      ],
    );
  }
}
"""
with io.open('lib/screens/my_page_screen.dart', 'w', encoding='utf-8') as f:
    f.write(new_my_page_code)
print("Updated profile_edit_screen.dart and my_page_screen.dart")
