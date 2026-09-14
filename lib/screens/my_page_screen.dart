import 'package:flutter/material.dart';
import 'edit_profile_screen.dart'; import 'settings_screen.dart'; import 'soso_wallet_screen.dart'; import 'fake_call_screen.dart'; import 'secret_memo_screen.dart';
import 'my_page_sub_screens.dart';

class MyPageScreen extends StatelessWidget { 
  const MyPageScreen({super.key}); 
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white, 
    appBar: AppBar(title: const Text('마이페이지', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0), 
    body: ListView(
      padding: const EdgeInsets.all(24), 
      children: [
        Row(
          children: [
            const CircleAvatar(radius: 40, backgroundColor: Color(0xFFFF3B30), child: Icon(Icons.person, size: 40, color: Colors.white)), 
            const SizedBox(width: 20), 
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  const Text('위피멤버 (ENFP)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), 
                  const SizedBox(height: 4), 
                  const Text('서울 강남구 · 26세', style: TextStyle(color: Colors.grey)), 
                  const SizedBox(height: 8), 
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())), 
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)), child: const Text('프로필 수정', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))
                  )
                ]
              )
            )
          ]
        ), 
        const SizedBox(height: 40), 
        const Text('내 활동', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
        const SizedBox(height: 16), 
        _menu(context, Icons.account_balance_wallet, '소소카 정산 지갑', const SosoWalletScreen(), color: const Color(0xFFFF3B30)), 
        _menu(context, Icons.lock, '비밀 메모', const SecretMemoScreen()), 
        _menu(context, Icons.phone_in_talk, '안심콜 귀가 (가짜 전화)', const FakeCallScreen(), color: Colors.green), 
        _menu(context, Icons.block, '차단 관리', const BlockManageScreen()), 
        _menu(context, Icons.report, '신고 내역', const ReportHistoryScreen()), 
        const SizedBox(height: 24), 
        const Text('고객 지원', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
        const SizedBox(height: 16), 
        _menu(context, Icons.campaign, '공지사항', const NoticeScreen()), 
        _menu(context, Icons.headset_mic, '고객센터', const CustomerCenterScreen()), 
        _menu(context, Icons.settings, '환경설정', const SettingsScreen())
      ]
    )
  );
  
  Widget _menu(BuildContext ctx, IconData icon, String title, Widget page, {Color color = Colors.black87}) => ListTile(
    contentPadding: EdgeInsets.zero, 
    leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)), 
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), 
    trailing: const Icon(Icons.chevron_right, color: Colors.grey), 
    onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => page))
  );
}