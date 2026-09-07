import 'package:flutter/material.dart';

class PartyChatPreviewScreen extends StatelessWidget {
  const PartyChatPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('파티 그룹 채팅 미리보기', style: TextStyle(color: Colors.black, fontSize: 16)), backgroundColor: Colors.white, elevation: 1, iconTheme: const IconThemeData(color: Colors.black)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSystemMessage('성수 하이볼 팟 그룹 채팅방입니다.'),
                const SizedBox(height: 16),
                _buildOtherMessage('방장', '다들 언제쯤 도착하시나요?'),
                const SizedBox(height: 12),
                _buildOtherMessage('참여자 1', '저는 7시 정각 도착 예정입니다!'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8A65), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('파티 참가 확정하고 대화 시작하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSystemMessage(String text) {
    return Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(20)), child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black54))));
  }

  Widget _buildOtherMessage(String sender, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(sender, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
          child: Text(text, style: const TextStyle(color: Colors.black87)),
        )
      ],
    );
  }
}
