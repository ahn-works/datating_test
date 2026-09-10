import 'package:flutter/material.dart';

class SimpleListScreen extends StatelessWidget {
  final String title; final List<String> items;
  const SimpleListScreen({super.key, required this.title, required this.items});
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.white, appBar: AppBar(title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)), body: ListView.separated(padding: const EdgeInsets.all(16), itemCount: items.length, separatorBuilder: (_,__) => const Divider(), itemBuilder: (_, i) => ListTile(title: Text(items[i]), trailing: const Icon(Icons.chevron_right, color: Colors.grey))));
}

class BlockManageScreen extends StatelessWidget {
  const BlockManageScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.white, appBar: AppBar(title: const Text('차단 관리', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)), body: ListView(padding: const EdgeInsets.all(16), children: [ListTile(leading: const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)), title: const Text('비매너유저1'), trailing: OutlinedButton(onPressed: (){}, child: const Text('차단 해제')))]));
}

class ReportHistoryScreen extends StatelessWidget {
  const ReportHistoryScreen({super.key});
  @override Widget build(BuildContext context) => const SimpleListScreen(title: '신고 내역', items: ['[처리완료] 욕설 및 비방 유저 신고', '[접수됨] 노쇼 유저 신고']);
}

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});
  @override Widget build(BuildContext context) => const SimpleListScreen(title: '공지사항', items: ['[안내] 가을 맞이 동네 커플 매칭 이벤트', '[업데이트] 여행 모임 기능 개편 안내 v2.0', '[필독] 안전한 만남을 위한 커뮤니티 가이드']);
}

class CustomerCenterScreen extends StatelessWidget {
  const CustomerCenterScreen({super.key});
  @override Widget build(BuildContext context) => const SimpleListScreen(title: '고객센터', items: ['자주 묻는 질문 (FAQ)', '1:1 문의하기', '이용 약관', '개인정보 처리방침']);
}
