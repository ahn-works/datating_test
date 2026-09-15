import 'package:flutter/material.dart';

class SosoCarChatScreen extends StatelessWidget {
  const SosoCarChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('강화도 조개구이 팟 (3/4)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(Icons.menu, color: Colors.black), onPressed: (){})
        ],
      ),
      body: Column(
        children: [
          // 실시간 픽업 위치 공유 배너
          Container(
            color: const Color(0xFFE2F0D9),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF2E4F28)),
                const SizedBox(width: 8),
                Expanded(child: const Text('현재 민우님(호스트)이 마포구청역으로 이동 중입니다.', style: TextStyle(color: Color(0xFF2E4F28), fontWeight: FontWeight.bold, fontSize: 13))),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Center(child: Text('2024년 10월 28일 토요일', style: TextStyle(color: Colors.grey, fontSize: 12))),
                const SizedBox(height: 16),
                _buildMessage(text: '안녕하세요! 토요일 3시 마포구청역 2번 출구에서 뵐게요!', isMe: false, sender: '달리는 민우'),
                _buildMessage(text: '네 확인했습니다! 짐이 조금 있는데 트렁크 가능할까요?', isMe: true),
                _buildMessage(text: '네 트렁크 비워두었습니다 ㅎㅎ', isMe: false, sender: '달리는 민우'),
                
                const SizedBox(height: 24),
                // 정산 위젯
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFC04020))),
                  child: Column(
                    children: [
                      const Text('🚙 주유비·통행료 1/N 정산 요청', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('총 금액 (3명)', style: TextStyle(color: Colors.grey)),
                          const Text('36,000원', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('나의 정산 금액', style: TextStyle(color: Color(0xFFC04020), fontWeight: FontWeight.bold)),
                          const Text('12,000원', style: TextStyle(color: Color(0xFFC04020), fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (){},
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC04020), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          child: const Text('간편 송금하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          
          // 채팅 입력창
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.add_circle_outline, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                    child: const Text('메시지를 입력하세요', style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.send, color: Color(0xFF2E4F28)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMessage({required String text, required bool isMe, String? sender}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            const CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=11')),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe && sender != null) Padding(padding: const EdgeInsets.only(bottom: 4, left: 4), child: Text(sender, style: const TextStyle(fontSize: 12, color: Colors.grey))),
              Container(
                constraints: const BoxConstraints(maxWidth: 240),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFF2E4F28) : Colors.white,
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                    topLeft: !isMe ? const Radius.circular(0) : const Radius.circular(16),
                  ),
                  border: isMe ? null : Border.all(color: Colors.grey.shade300),
                ),
                child: Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
