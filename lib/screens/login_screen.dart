import 'package:flutter/material.dart';
import 'auth_pass_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.location_on, size: 64, color: Color(0xFFFF8A65)),
                    SizedBox(height: 16),
                    Text('Spot10', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFFF8A65))),
                    SizedBox(height: 8),
                    Text('10분 익명 대화, 20분 뒤 진짜 만남', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              ),
              const Spacer(),
              _buildSocialButton(
                context: context,
                icon: Icons.chat_bubble,
                label: '카카오로 시작하기',
                color: const Color(0xFFFEE500),
                textColor: Colors.black87,
                targetScreen: const AuthPassScreen(),
              ),
              const SizedBox(height: 16),
              _buildSocialButton(
                context: context,
                icon: Icons.apple,
                label: 'Apple로 시작하기',
                color: Colors.black,
                textColor: Colors.white,
                targetScreen: const AuthPassScreen(),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text('가입 시 이용약관 및 개인정보 취급방침에 동의하게 됩니다.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required Widget targetScreen,
  }) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        minimumSize: const Size(double.infinity, 56),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
