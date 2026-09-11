import 'package:flutter/material.dart';
import '../main.dart';
import 'auth_pass_screen.dart';

class ProfileSetupScreen extends StatefulWidget { const ProfileSetupScreen({super.key}); @override State<ProfileSetupScreen> createState() => _ProfileSetupScreenState(); }
class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final bool _isPassVerified = false;
  final String _name = '김위피'; final String _gender = '남성'; final String _age = '25세';

  @override Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.white, appBar: AppBar(title: const Text('프로필 설정', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)), body: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('신뢰할 수 있는 만남을 위해\n본인 인증을 진행해주세요', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.4)), const SizedBox(height: 32),
    GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthPassScreen())), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: _isPassVerified ? Colors.green : Colors.grey.shade300), borderRadius: BorderRadius.circular(12), color: _isPassVerified ? Colors.green.withOpacity(0.05) : Colors.white), child: Row(children: [Icon(Icons.verified_user, color: _isPassVerified ? Colors.green : Colors.grey), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('PASS 인증 (필수)', style: TextStyle(fontWeight: FontWeight.bold, color: _isPassVerified ? Colors.green : Colors.black87)), if (_isPassVerified) Text(' |  | ', style: const TextStyle(fontSize: 12, color: Colors.green))])), if (!_isPassVerified) Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFF3B30), borderRadius: BorderRadius.circular(8)), child: const Text('인증하기', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))]))), const Spacer(),
    ElevatedButton(onPressed: () {
      if(!_isPassVerified) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PASS 본인 인증을 먼저 진행해주세요.'))); return; }
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainTabScreen()), (_) => false);
    }, style: ElevatedButton.styleFrom(backgroundColor: _isPassVerified ? const Color(0xFFFF3B30) : Colors.grey, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('위피 시작하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))
  ])));
}
