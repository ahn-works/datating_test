import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'wallet_history_screen.dart';
import 'settings_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('마이페이지', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Profile Header
          Row(
            children: [
              CircleAvatar(radius: 40, backgroundColor: Colors.grey[300], child: const Icon(Icons.person, size: 40, color: Colors.white)),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('안심향 님', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('spot10_user@gmail.com', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Manner Temp
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('나의 매너 온도', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('36.8°', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF8A65), fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: 0.6, backgroundColor: Colors.grey[200], color: const Color(0xFFFF8A65), minHeight: 8, borderRadius: BorderRadius.circular(4)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Menus
          _buildMenuTile(Icons.person_outline, '프로필 및 취향 수정', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
          }),
          _buildMenuTile(Icons.account_balance_wallet_outlined, '결제 내역 및 보증금 지갑', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const WalletHistoryScreen()));
          }),
          _buildMenuTile(Icons.verified_user_outlined, '인증 센터 (직장/학교)', onTap: (){}),
          _buildMenuTile(Icons.settings_outlined, '설정 및 고객 센터', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, {required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
