
import 'package:flutter/material.dart';

class ProfileDetailScreen extends StatelessWidget {
  final String name, age, region, imageUrl, intro;
  final double mannerTemp;
  const ProfileDetailScreen({super.key, required this.name, required this.age, required this.region, required this.imageUrl, required this.intro, required this.mannerTemp});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: CustomScrollView(slivers: [
      SliverAppBar(expandedHeight: 340, pinned: true, backgroundColor: Colors.white,
        flexibleSpace: FlexibleSpaceBar(background: Container(color: Colors.grey.shade200, child: const Icon(Icons.person, size: 120, color: Colors.grey))),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(age + '세', style: const TextStyle(fontSize: 20, color: Colors.grey)),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(20)), child: Text('♥ ' + mannerTemp.toString() + '°', style: const TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold))),
        ]),
        Text('한주 사는 곳: ' + region, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 16),
        const Text('자기소개', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Text(intro, style: const TextStyle(color: Colors.black87, height: 1.6)),
        const SizedBox(height: 40),
        ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('여행 모임 함께하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
      ]))),
    ]),
  );
}
