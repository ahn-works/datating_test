import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'my_page_sub_screens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('설정', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          _section('계정 및 안전 (UGC 보호)'),
          _tile(
            context,
            '차단 사용자 관리',
            Icons.block,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BlockManageScreen())),
          ),
          _tile(
            context,
            '신고 접수 및 처리 내역',
            Icons.flag_outlined,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportHistoryScreen())),
          ),
          _section('알림'),
          _tile(context, '푸시 알림', Icons.notifications_none),
          _tile(context, '마케팅 정보 수신', Icons.email_outlined),
          _section('고객 지원 및 가이드'),
          _tile(
            context,
            '공지사항',
            Icons.campaign_outlined,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NoticeScreen())),
          ),
          _tile(
            context,
            '고객센터 & 커뮤니티 가이드라인',
            Icons.headset_mic_outlined,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerCenterScreen())),
          ),
          _tile(context, '이용약관 및 개인정보 처리방침', Icons.description_outlined),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('로그아웃', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  static Widget _section(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
      );

  static Widget _tile(BuildContext context, String t, IconData icon, {VoidCallback? onTap}) => ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: onTap,
      );
}
