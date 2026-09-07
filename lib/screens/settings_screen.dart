import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('설정', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionContainer([
            _buildSwitchTile('푸시 알림 켜기', true),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            _buildSwitchTile('마케팅 정보 수신 동의', false),
          ]),
          const SizedBox(height: 16),
          _buildSectionContainer([
            _buildListTile('차단된 유저 관리'),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            _buildListTile('고객센터 및 신고 내역'),
          ]),
          const SizedBox(height: 16),
          _buildSectionContainer([
            _buildListTile('로그아웃', textColor: Colors.red),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            _buildListTile('회원 탈퇴', textColor: Colors.red),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(List<Widget> children) {
    return Container(color: Colors.white, child: Column(children: children));
  }

  Widget _buildSwitchTile(String title, bool value) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      value: value,
      onChanged: (val) {},
      activeColor: const Color(0xFFFF8A65),
    );
  }

  Widget _buildListTile(String title, {Color textColor = Colors.black87}) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 16, color: textColor)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }
}
