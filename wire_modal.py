import io

# 1. Update home_screen.dart
with io.open('lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("import 'profile_detail_screen.dart';", "import 'driver_profile_modal.dart';")
text = text.replace(
    "Navigator.push(ctx, MaterialPageRoute(builder: (_) => ProfileDetailScreen(name: name, age: '24', region: '서울', imageUrl: '', intro: '안녕하세요!', mannerTemp: 36.5)))",
    "showDriverProfileModal(ctx)"
)

with io.open('lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)

# 2. Update edit_profile_screen.dart
edit_code = '''import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('프로필 수정', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('완료', style: TextStyle(color: Color(0xFF14422D), fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                  width: 104, height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                  ),
                  child: const Icon(Icons.person, size: 60, color: Colors.grey),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _field('닉네임', '햇살가득 지우'),
          const SizedBox(height: 16),
          _field('자기소개', '안전하고 기분 좋은 동네 드라이브를 지향합니다 🚗✨ 주말엔 주로 강화도, 파주 쪽 다녀요!', maxLines: 3),
          const SizedBox(height: 32),
          const Text('내 차량 및 운전 정보', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _field('차종', '예: 현대 아이오닉 5'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _field('운전 경력', '예: 5년')),
              const SizedBox(width: 16),
              Expanded(child: _field('무사고 기간', '예: 6년 연속')),
            ],
          ),
          const SizedBox(height: 16),
          const Text('※ 복잡한 차량 인증 서류 업로드 없이 간단하게 경력과 차량 정보를 입력해주세요.', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  static Widget _field(String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFFBF9F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
'''
with io.open('lib/screens/edit_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(edit_code)

