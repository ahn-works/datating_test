import 'package:flutter/material.dart';
import "oomu_review_screen.dart";

class OOMUChatScreen extends StatefulWidget {
  const OOMUChatScreen({super.key});

  @override
  State<OOMUChatScreen> createState() => _OOMUChatScreenState();
}

class _OOMUChatScreenState extends State<OOMUChatScreen> {
  final Color darkGreen = const Color(0xFF1B4D3E);
  final Color background = const Color(0xFFF9FAFB);
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: const Text('Chat Room', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.rate_review_outlined, color: Colors.black87), onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const OOMUReviewScreen(isDriveMode: true))); }),
          IconButton(icon: const Icon(Icons.share_outlined, color: Colors.black87), onPressed: (){}),
        ],
      ),
      body: Column(
        children: [
          _buildTripHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                _buildDateBadge(),
                const SizedBox(height: 16),
                _buildSystemMessage('📍 달리는 민우 님이 집결지에 도착했습니다...'),
                const SizedBox(height: 24),
                _buildOtherMessage(
                  name: '민우',
                  tag: '드라이버',
                  isDriver: true,
                  time: '13:52',
                  text: '안녕하세요! 흰색 볼보 비상등 켜두고 대기 중입니다 편히 오세요 ㅎㅎ 🚗✨',
                ),
                const SizedBox(height: 16),
                _buildOtherMessage(
                  name: '서연',
                  tag: '연남동 이웃',
                  isDriver: false,
                  time: '13:54',
                  text: '지금 3번 출구 계단 올라가고 있어요! 3분 내 도착합니다 🏃‍♀️💨',
                ),
                const SizedBox(height: 16),
                _buildMyMessage(
                  time: '13:55',
                  text: '저도 횡단보도 건너는 중이에요! 곧 뵙겠습니다 ☕',
                ),
                const SizedBox(height: 32),
                _buildPhotoShareMessage(),
              ],
            ),
          ),
          _buildBottomInput(),
        ],
      ),
    );
  }

  Widget _buildTripHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFF5A5F).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Text('D-Day 오늘', style: TextStyle(color: Color(0xFFFF5A5F), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              const Expanded(child: Text('강화도 동막해변 일몰 드...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFFF5A5F), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              const Text('4명 참여중', style: TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.near_me_outlined, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              const Text('집결 중', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const Text(' · 홍대입구역...', style: TextStyle(color: Colors.black54, fontSize: 12)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
                child: const Row(
                  children: [
                    Icon(Icons.map_outlined, size: 14, color: Colors.black87),
                    SizedBox(width: 4),
                    Text('경로 안내', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDateBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
        child: const Text('2024년 10월 19일 토요일', style: TextStyle(fontSize: 11, color: Colors.black54)),
      ),
    );
  }

  Widget _buildSystemMessage(String text) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ),
    );
  }

  Widget _buildOtherMessage({required String name, required String tag, required bool isDriver, required String time, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: const NetworkImage('https://picsum.photos/100?random=2'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: isDriver ? const Color(0xFFE8F3EE) : Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                    child: Text(tag, style: TextStyle(fontSize: 10, color: isDriver ? darkGreen : Colors.black54, fontWeight: isDriver ? FontWeight.bold : FontWeight.normal)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                      ),
                      child: Text(text, style: const TextStyle(fontSize: 14, height: 1.4)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(time, style: const TextStyle(fontSize: 10, color: Colors.black38)),
                ],
              )
            ],
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildMyMessage({required String time, required String text}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(width: 60),
        Text(time, style: const TextStyle(fontSize: 10, color: Colors.black38)),
        const SizedBox(width: 6),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: darkGreen,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomLeft: Radius.circular(16)),
            ),
            child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.4)),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoShareMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.camera_alt, color: Color(0xFFFF5A5F), size: 16),
              const SizedBox(width: 6),
              const Text('동막해변 일몰 순간 공유', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              const Text('18:40', style: TextStyle(fontSize: 10, color: Colors.black38)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network('https://images.unsplash.com/photo-1526761122248-c31c93f8b2b9?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80', height: 180, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          const Text('"오늘 날씨 정말 최고였어요! 다들 조심히 들어가세요 🧡"', style: TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildBottomInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
              child: IconButton(icon: const Icon(Icons.add, color: Colors.black54), onPressed: (){}),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(hintText: '이웃들과 대화를 나눠보세요...', border: InputBorder.none, hintStyle: TextStyle(fontSize: 14, color: Colors.black38)),
                      ),
                    ),
                    const Icon(Icons.sentiment_satisfied_alt, color: Colors.black38),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(color: darkGreen, shape: BoxShape.circle),
              child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 18), onPressed: (){}),
            ),
          ],
        ),
      ),
    );
  }
}
