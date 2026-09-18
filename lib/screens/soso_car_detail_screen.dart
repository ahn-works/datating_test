import 'package:flutter/material.dart';

class OOMUDetailScreen extends StatefulWidget {
  const OOMUDetailScreen({super.key});

  @override
  State<OOMUDetailScreen> createState() => _OOMUDetailScreenState();
}

class _OOMUDetailScreenState extends State<OOMUDetailScreen> {
  final Color darkGreen = const Color(0xFF1B4D3E);
  final Color badgeGreen = const Color(0xFFA5D6A7);
  final Color terracotta = const Color(0xFFC04020);
  final Color surfaceContainer = const Color(0xFFF9F9F7);
  
  bool _isFavorite = false;

  void _showApplyToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            const Expanded(child: Text('민우님에게 동승 신청 메시지를 보냈어요! 🚗')),
          ],
        ),
        backgroundColor: darkGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                _buildSeatStatus(),
                _buildDivider(),
                _buildDriverInfo(),
                _buildDivider(),
                _buildTimeline(),
                _buildDivider(),
                
                _buildDivider(),
                _buildFellowPassengers(),
                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          )
        ],
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? terracotta : Colors.white),
          onPressed: () => setState(() => _isFavorite = !_isFavorite),
        ),
        IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: (){}),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network('https://picsum.photos/800/600?random=111', fit: BoxFit.cover),
            Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black54, Colors.transparent, Colors.black87]))),
            Positioned(
              bottom: 20, left: 20, right: 20,
              child: _buildHeaderInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: badgeGreen, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(Icons.nature_people, color: darkGreen, size: 14),
                  const SizedBox(width: 4),
                  Text('당일치기 힐링', style: TextStyle(color: darkGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: terracotta, borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.local_fire_department, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('마감 임박', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('강화도 동막해변 일몰 보고 대하구이 먹고 올 분! 🦐', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.3, color: Colors.white)),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
            const SizedBox(width: 8),
            const Text('이번 주 토요일 (10월 28일)', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(width: 12),
            Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            const Text('오후 2:00 출발', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        )
      ],
    );
  }

  Widget _buildSeatStatus() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('탑승 현황', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: terracotta.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.timer, color: terracotta, size: 14),
                    const SizedBox(width: 4),
                    Text('마지막 1석 남음!', style: TextStyle(color: terracotta, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildSeatItem('드라이버', '민우', Icons.airline_seat_recline_extra, true, true),
              _buildSeatItem('보조석', '서연', Icons.airline_seat_recline_normal, true, false),
              _buildSeatItem('뒷좌석 L', '준호', Icons.airline_seat_recline_normal, true, false),
              _buildSeatItem('뒷좌석 R', '비어있음', Icons.airline_seat_recline_normal, false, false),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSeatItem(String position, String name, IconData icon, bool isOccupied, bool isDriver) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isOccupied ? (isDriver ? darkGreen : badgeGreen.withOpacity(0.3)) : surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isOccupied ? (isDriver ? Colors.white : darkGreen) : Colors.grey, size: 24),
          ),
          const SizedBox(height: 8),
          Text(position, style: const TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 2),
          Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isOccupied ? Colors.black87 : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDriverInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('호스트', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          Row(
            children: [
              const CircleAvatar(radius: 28, backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=11')),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('달리는 민우', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        Icon(Icons.verified, color: darkGreen, size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('마포구 연남동 3년차 주민', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('38.5°C ', style: TextStyle(color: terracotta, fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(width: 8),
                        Icon(Icons.thermostat, color: terracotta, size: 14),
                        const Text('따뜻한 친구 18회', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(16)),
            child: const Text('“주말마다 근교 드라이브 다니는 걸 좋아해요. 인디음악 좋아하시는 분이면 차 안에서 더 즐거울 것 같아요! 편하게 이야기 나누며 다녀와요 🌿”', style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87, fontStyle: FontStyle.italic)),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3.5,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _buildCarSpec(Icons.directions_car, '볼보 XC40 (화이트)'),
              _buildCarSpec(Icons.smoke_free, '비흡연 안심 차량'),
              _buildCarSpec(Icons.luggage, '트렁크 백팩 4개 수납'),
              _buildCarSpec(Icons.music_note, '어쿠스틱 & 인디 BGM'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCarSpec(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.black54, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87))),
      ],
    );
  }

  Widget _buildTimeline() {
    final timelineData = [
      {'time': '14:00', 'title': '홍대입구역 3번 출구 집결', 'desc': '연남동 공용주차장 부근 픽업 후 강화도로 출발'},
      {'time': '15:30', 'title': '조양방직 레트로 카페', 'desc': '빈티지 방직공장 리모델링 카페에서 커피 & 담소'},
      {'time': '17:40', 'title': '동막해변 일몰 산책 🌅', 'desc': '서해안 갯벌 위 노을 보며 인생샷 남기기'},
      {'time': '19:00', 'title': '대하구이 & 칼국수 저녁 🍤', 'desc': '해변 인근 맛집에서 통통한 제철 왕새우 소금구이'},
      {'time': '21:30', 'title': '홍대입구역 복귀 및 해산', 'desc': '홍대입구역 하차 후 안전 귀가'},
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('여행 타임라인', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              Text('총 소요 예상 7시간 30분', style: TextStyle(fontSize: 12, color: darkGreen, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          ...List.generate(timelineData.length, (index) {
            final item = timelineData[index];
            final isLast = index == timelineData.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: darkGreen, shape: BoxShape.circle)),
                    if (!isLast) Container(width: 2, height: 75, color: badgeGreen),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(item['time']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(item['title']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 48),
                        child: Text(item['desc']!, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                      ),
                      if (!isLast) const SizedBox(height: 24),
                    ],
                  ),
                )
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCostSplit() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: Colors.black87),
              const SizedBox(width: 8),
              const Text('투명 1/N 정산 안내', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)), child: const Text('소수점 올림 없음', style: TextStyle(fontSize: 11, color: Colors.black54))),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _buildCostRow('예상 왕복 주유비 (약 130km)', '45,000원', false),
                const SizedBox(height: 12),
                _buildCostRow('왕복 고속도로 통행료', '11,000원', false),
                const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: Colors.black12)),
                _buildCostRow('예상 총 모임 회비', '56,000원', true),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: badgeGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('4인 탑승 시 1인당 예상 분담금', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('식비/카페는 현장 개별 결제', style: TextStyle(fontSize: 11, color: Colors.black54)),
                        ],
                      ),
                      Text('14,000원', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: darkGreen)),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCostRow(String title, String amount, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: isTotal ? 15 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: Colors.black87)),
        Text(amount, style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _buildFellowPassengers() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('함께하는 동네 이웃', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              Row(
                children: [
                  const Text('3명', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: terracotta, borderRadius: BorderRadius.circular(12)), child: const Text('1자리 남음', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          _buildPassengerItem('민우', 'https://i.pravatar.cc/100?img=11', '운전자', '연남동 · "안전운전 책임질게요!"', null),
          _buildPassengerItem('서연', 'https://i.pravatar.cc/100?img=5', '풍경 사진 찍는 걸 좋아해요 📷', '망원동', '37.2°C'),
          _buildPassengerItem('준호', 'https://i.pravatar.cc/100?img=8', '로컬 맛집 탐방가 🍤', '서교동', '36.9°C'),
          
          // Empty Seat
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: terracotta.withOpacity(0.5), style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(16),
              color: terracotta.withOpacity(0.05),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: terracotta)),
                  child: Icon(Icons.person_add, color: terracotta),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('마지막 한 자리의 주인공! ✨', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: terracotta)),
                      const SizedBox(height: 4),
                      const Text('당신과 함께 떠나기를 기다리고 있어요', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
                  child: const Text('대기 중', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPassengerItem(String name, String img, String desc, String location, String? temp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundImage: NetworkImage(img)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(location, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(fontSize: 13, color: name == '민우' ? darkGreen : Colors.black87, fontWeight: name == '민우' ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          ),
          if (temp != null) Text(temp, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: SafeArea(
        child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.chat, size: 18), label: const Text('참여 신청하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: darkGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
      ),
    );
  }
