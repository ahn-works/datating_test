import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('기본 정보 입력', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('스팟10에서 사용할\n프로필을 완성해주세요.', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.4)),
            const SizedBox(height: 32),
            _buildLabel('닉네임'),
            _buildTextField('사용할 닉네임을 입력하세요'),
            const SizedBox(height: 24),
            _buildLabel('나이 (출생년도)'),
            _buildTextField('예: 1998', keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            _buildLabel('성별'),
            Row(
              children: [
                Expanded(child: _buildGenderButton('남성', true)),
                const SizedBox(width: 12),
                Expanded(child: _buildGenderButton('여성', false)),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OnboardingScreen())),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A65), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('다음 (취향 태그 선택)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)));
  Widget _buildTextField(String hint, {TextInputType? keyboardType}) => TextField(keyboardType: keyboardType, decoration: InputDecoration(hintText: hint, filled: true, fillColor: const Color(0xFFF9F9F9), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)));
  Widget _buildGenderButton(String text, bool isSelected) => OutlinedButton(onPressed: (){}, style: OutlinedButton.styleFrom(backgroundColor: isSelected ? const Color(0xFFFFF0EC) : Colors.white, side: BorderSide(color: isSelected ? const Color(0xFFFF8A65) : Colors.grey.shade300), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(text, style: TextStyle(color: isSelected ? const Color(0xFFFF8A65) : Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)));
}
