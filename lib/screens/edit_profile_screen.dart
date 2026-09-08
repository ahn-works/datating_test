
import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(title: const Text('프로필 수정', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('저장', style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold)))]),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      Center(child: Stack(children: [
        const CircleAvatar(radius: 52, backgroundColor: Color(0xFFFF3B30), child: Icon(Icons.person, size: 52, color: Colors.white)),
        Positioned(bottom: 0, right: 0, child: Container(decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: const Icon(Icons.camera_alt, color: Colors.white, size: 20))),
      ])),
      const SizedBox(height: 32),
      _field('닉네임', '안시말'),
      const SizedBox(height: 16),
      _field('자기소개', '여행 좋아하는 평범한 직장인', maxLines: 3),
      const SizedBox(height: 16),
      _field('거주 지역', '광주'),
    ]),
  );
  static Widget _field(String label, String hint, {int maxLines = 1}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    const SizedBox(height: 8),
    TextField(maxLines: maxLines, decoration: InputDecoration(hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14))),
  ]);
}
