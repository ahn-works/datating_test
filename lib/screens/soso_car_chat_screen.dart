
// ===========================================================================
// 동적 컴포넌트: 리뷰 공유 카드
// ===========================================================================
class InteractiveReviewCard extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMe;

  const InteractiveReviewCard({super.key, required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final int rating = msg['rating'] ?? 5;
    final String text = msg['text'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=33')),
          if (!isMe) const SizedBox(width: 8),
          if (isMe) Text(msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (isMe) const SizedBox(width: 4),
          
          Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.rate_review, color: Colors.orange, size: 16)),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('✨ 모임 후기가 도착했어요!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: List.generate(5, (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 20,
                  )),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(8)),
                  child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
                ),
              ],
            ),
          ),

          if (!isMe) const SizedBox(width: 4),
          if (!isMe) Text(msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
        ],
      ),
    );
  }
}
