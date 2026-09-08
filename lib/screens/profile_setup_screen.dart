
import 'package:flutter/material.dart';
import '../main.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});
  @override State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}
class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _name = TextEditingController();
  String _gender = '남성';
  String _region = '광주';
  final _regions = ['광주', '목포', '순천', '여수', '전주', '강원도'];
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(title: const Text('프로필 설정', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0),
    body: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('닉네임', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 8),
      TextField(controller: _name, decoration: InputDecoration(hintText: '닉네임을 입력하세요', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14))),
      const SizedBox(height: 24),
      const Text('성별', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 8),
      Row(children: ['남성', '여성'].map((g) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 8), child: OutlinedButton(
        onPressed: () => setState(() => _gender = g),
        style: OutlinedButton.styleFrom(side: BorderSide(color: _gender == g ? const Color(0xFFFF3B30) : Colors.grey.shade300, width: _gender == g ? 2 : 1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
        child: Text(g, style: TextStyle(color: _gender == g ? const Color(0xFFFF3B30) : Colors.grey, fontWeight: FontWeight.bold)),
      )))).toList()),
      const SizedBox(height: 24),
      const Text('거주 지역', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: _regions.map((r) => ChoiceChip(
        label: Text(r), selected: _region == r,
        onSelected: (_) => setState(() => _region = r),
        selectedColor: const Color(0xFFFF3B30), labelStyle: TextStyle(color: _region == r ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
      )).toList()),
      const Spacer(),
      ElevatedButton(
        onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainNavigation()), (_) => false),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.black, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: const Text('시작하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    ])),
  );
}
