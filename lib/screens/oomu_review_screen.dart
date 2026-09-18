import 'package:flutter/material.dart';

class OOMUReviewScreen extends StatefulWidget {
  final bool isDriveMode;

  const OOMUReviewScreen({super.key, this.isDriveMode = true});

  @override
  State<OOMUReviewScreen> createState() => _OOMUReviewScreenState();
}

class _OOMUReviewScreenState extends State<OOMUReviewScreen> {
  final Color darkGreen = const Color(0xFF1B4D3E);
  final Color background = const Color(0xFFF9FAFB);
  int _selectedRating = 4; // 0 to 4

  final List<String> _driveGoodPoints = [
    '안전하고 부드러운 운전',
    '약속 시간을 칼같이 지켜요',
    '차 안이 쾌적하고 깨끗해요',
    '선곡 센스가 최고예요 🎵',
    '배려심 넘치는 편안한 대화',
    '길을 정말 잘 알아요',
  ];

  final List<String> _hostGoodPoints = [
    '모임을 편안하게 이끌어줘요',
    '약속 시간을 칼같이 지켜요',
    '장소 선정이 탁월해요',
    '분위기를 잘 띄워요 ✨',
    '배려심 넘치는 편안한 대화',
    '참여자들을 골고루 챙겨줘요',
  ];

  final Set<int> _selectedPoints = {0, 1, 2, 3}; // Mock selections

  @override
  Widget build(BuildContext context) {
    List<String> goodPoints = widget.isDriveMode ? _driveGoodPoints : _hostGoodPoints;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: Text(widget.isDriveMode ? 'Driver Review' : 'Host Review', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, color: Colors.black87), onPressed: (){}),
          IconButton(icon: Icon(Icons.account_circle, color: darkGreen), onPressed: (){}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            _buildTripInfo(),
            const SizedBox(height: 16),
            _buildHostFeedback(goodPoints),
            const SizedBox(height: 16),
            _buildThankYouNote(),
            const SizedBox(height: 16),
            _buildFellowPassengers(),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: _buildBottomButton(),
    );
  }

  Widget _buildTripInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: darkGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text(widget.isDriveMode ? '드라이브 완료' : '모임 완료', style: TextStyle(color: darkGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    const Text('10월 28일', style: TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(widget.isDriveMode ? '강화도 동막해변 일몰 드라이브' : '연남동 핫플 카페 투어', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                const Text('이웃들과 나눈 소중한 여정, 따뜻한 마음을 전해주세요', style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.network('https://images.unsplash.com/photo-1526761122248-c31c93f8b2b9?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80', width: 60, height: 60, fit: BoxFit.cover),
          )
        ],
      ),
    );
  }

  Widget _buildHostFeedback(List<String> goodPoints) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_outlined, size: 16, color: Colors.black87),
              const SizedBox(width: 6),
              Text(widget.isDriveMode ? '동승 호스트 피드백' : '모임 방장 피드백', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                child: Text(widget.isDriveMode ? '운전자' : '방장', style: const TextStyle(fontSize: 10, color: Colors.black54)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const CircleAvatar(radius: 24, backgroundImage: NetworkImage('https://picsum.photos/100?random=1')),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('달리는 민우', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: Color(0xFF1B4D3E), size: 12),
                        const SizedBox(width: 2),
                        const Text('3년차 주민', style: TextStyle(color: Color(0xFF1B4D3E), fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if(widget.isDriveMode) ...[
                      const SizedBox(height: 4),
                      const Text('🚙 볼보 XC40 [스노우 화이트]', style: TextStyle(fontSize: 11, color: Colors.black54)),
                    ]
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('38.5°C 🌡️', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC04020), fontSize: 14)),
                  const Text('현재 매너온도', style: TextStyle(fontSize: 10, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Container(
                    width: 60, height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(2)),
                    child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: 0.6, child: Container(decoration: BoxDecoration(color: const Color(0xFFC04020), borderRadius: BorderRadius.circular(2)))),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 24),
          Text(widget.isDriveMode ? '민우님과의 드라이브는 어떠셨나요?' : '민우님과의 모임은 어떠셨나요?', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('이웃의 여정을 더 안전하고 따스하게 만드는 평가입니다', style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRatingEmoji(0, '☹️', '별로예요'),
              _buildRatingEmoji(1, '🙁', '아쉬워요'),
              _buildRatingEmoji(2, '😐', '보통이에요'),
              _buildRatingEmoji(3, '😊', '좋았어요'),
              _buildRatingEmoji(4, '🌟', '최고였어요!'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department, color: Color(0xFFC04020), size: 16),
                const SizedBox(width: 8),
                Column(
                  children: [
                    const Text('민우님의 매너 온도가 +0.5°C 올라갑니다!', style: TextStyle(color: Color(0xFFC04020), fontSize: 12, fontWeight: FontWeight.bold)),
                    const Text('동네 이웃들의 소중한 안전 지표로 반영돼요', style: TextStyle(color: Colors.black54, fontSize: 10)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text('어떤 점이 특히 좋았나요?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              const Spacer(),
              const Text('복수 선택 가능', style: TextStyle(fontSize: 11, color: Color(0xFF1B4D3E))),
            ],
          ),
          const SizedBox(height: 6),
          const Text('민우님 프로필의 대표 뱃지로 전시됩니다', style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: List.generate(goodPoints.length, (index) => _buildPointChip(index, goodPoints[index])),
          )
        ],
      ),
    );
  }

  Widget _buildRatingEmoji(int index, String emoji, String label) {
    bool isSelected = _selectedRating == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedRating = index),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? (index == 4 ? const Color(0xFFE8F5E9) : Colors.yellow.shade100) : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.black87 : Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildPointChip(int index, String text) {
    bool isSelected = _selectedPoints.contains(index);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) _selectedPoints.remove(index);
          else _selectedPoints.add(index);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          border: Border.all(color: isSelected ? const Color(0xFF81C784) : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? Icons.check_circle : Icons.add_circle_outline, color: isSelected ? darkGreen : Colors.black38, size: 14),
            const SizedBox(width: 4),
            Text(text, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? darkGreen : Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildThankYouNote() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_border, color: Color(0xFFC04020), size: 18),
              const SizedBox(width: 6),
              const Text('감사 한마디 남기기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              const Text('선택 사항', style: TextStyle(fontSize: 10, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 8),
          Text(widget.isDriveMode ? '민우 드라이버님에게 따스한 여정 인사를 건네보세요.' : '민우 방장님에게 따스한 모임 후기를 건네보세요.', style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('일몰 시간 딱 맞춰서 안전하게 데려다주시고 플레이리스트도 너무 좋았습니다! 덕분에 지친 주말 제대로 힐링했어요 ㅎㅎ 감사합니다!', style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black87)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.lock_outline, size: 12, color: Colors.black54),
                    const SizedBox(width: 4),
                    const Text('상대방에게 친절 알림으로 발송됩니다', style: TextStyle(fontSize: 10, color: Colors.black54)),
                    const Spacer(),
                    const Text('68/200', style: TextStyle(fontSize: 10, color: Colors.black38)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFellowPassengers() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_outline, size: 18, color: Colors.black87),
              const SizedBox(width: 6),
              const Text('함께 한 동행 이웃들', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              const Text('참여자 간편 평가', style: TextStyle(fontSize: 10, color: Color(0xFF1B4D3E))),
            ],
          ),
          const SizedBox(height: 8),
          const Text('함께 웃고 대화 나눈 이웃들에게도 인사를 남겨보세요', style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 16),
          _buildFellowCard('서연', '37.2°C', '송도 3동', ['👍 매너가 너무 좋아요', '🕒 시간 약속 굿!', '💬 배려하는 대화']),
          const SizedBox(height: 12),
          _buildFellowCard('준호', '36.9°C', '송도 1동', ['👍 매너가 너무 좋아요', '😄 분위기 메이커']),
        ],
      ),
    );
  }

  Widget _buildFellowCard(String name, String temp, String loc, List<String> badges) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://picsum.photos/100?random=3')),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('님', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(temp, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFFC04020))),
                    ],
                  ),
                  Text(loc, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.sentiment_satisfied, color: Colors.black54, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: badges.map((b) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
              child: Text(b, style: const TextStyle(fontSize: 10, color: Color(0xFF1B4D3E))),
            )).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: background),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 12, color: Colors.black54),
                SizedBox(width: 4),
                Text('작성해주신 진심어린 피드백은 익명으로 안전하게 정산 및 기록됩니다', style: TextStyle(fontSize: 10, color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                label: const Text('소중한 평가 전달하기 (+0.5°C 반영)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
