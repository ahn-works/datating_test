import 'package:flutter/material.dart';
import "soso_car_chat_screen.dart";

class OOMUDetailScreen extends StatefulWidget {
  const OOMUDetailScreen({super.key});

  @override
  State<OOMUDetailScreen> createState() => _OOMUDetailScreenState();
}

class _OOMUDetailScreenState extends State<OOMUDetailScreen> {
  final Color textPrimary = const Color(0xFF111111);
  final Color textSecondary = const Color(0xFF767676);
  final Color surfaceColor = const Color(0xFFF5F5F7);
  final Color accentColor = const Color(0xFF007AFF);
  final Color destructiveColor = const Color(0xFFFF3B30);
  
  bool _isFavorite = false;

  void _showApplyToast() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Stack(
        children: [
          // Glassmorphism Backdrop
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 8, left: 24, right: 24, bottom: 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFEBEBEF), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 32),
                  const Icon(Icons.check_circle, color: Color(0xFF111111), size: 64),
                  const SizedBox(height: 24),
                  Text('참여 신청 완료!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary)),
                  const SizedBox(height: 12),
                  Text('호스트가 수락하면 단톡방 초대가 완료됩니다.\n미리 채팅방에 입장하시겠어요?', textAlign: TextAlign.center, style: TextStyle(color: textSecondary, height: 1.5, fontSize: 15)),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: textPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const OOMUChatScreen(title: '주말 엽떡+마라탕 조지실 분', memberCount: 3)));
                      },
                      child: const Text('채팅방 입장하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    )
                  )
                ]
              )
            ),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? destructiveColor : Colors.white, size: 20),
                    onPressed: () => setState(() => _isFavorite = !_isFavorite),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&q=80',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.4), Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -32, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  // Title Area
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(8)),
                              child: Text('술/맛집', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: destructiveColor, borderRadius: BorderRadius.circular(8)),
                              child: const Text('여성 전용', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '주말 엽떡+마라탕\n조지실 분 구해요!',
                          style: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.w800, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Host Profile Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFEBEBEF)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=47'),
                            backgroundColor: surfaceColor,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('매운맛킬러', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.verified, color: accentColor, size: 14),
                                    const SizedBox(width: 4),
                                    Text('AI 실명인증 완료', style: TextStyle(color: textSecondary, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: textSecondary, size: 20),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Info Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('모임 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                        const SizedBox(height: 24),
                        _buildInfoRow(Icons.calendar_today_outlined, '일시', '이번주 토요일 오후 6시'),
                        const SizedBox(height: 20),
                        _buildInfoRow(Icons.location_on_outlined, '장소', '홍대입구역 9번 출구 앞'),
                        const SizedBox(height: 20),
                        _buildInfoRow(Icons.directions_subway_outlined, '방법', '각자 대중교통 이동'),
                        const SizedBox(height: 20),
                        _buildInfoRow(Icons.payments_outlined, '비용', '약 1.5만원 (N빵)'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('이런 분을 찾아요', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                        const SizedBox(height: 16),
                        Text(
                          "스트레스 팍팍 받는 주말엔 역시 매운 거 아니겠습니까? 🔥\n\n엽기떡볶이 오리지널맛에 마라탕 4단계 팍팍 추가해서 같이 땀흘리면서 드실 여성 찐친 구합니다!\n\n맵찔이는 정중히 사양합니다..ㅎㅎ 다 먹고 근처 예쁜 카페 가서 커피도 마셔요!",
                          style: TextStyle(fontSize: 15, height: 1.6, color: textPrimary),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  // Members (Overlap UI)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('참여 멤버', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                            Text('2 / 4명', style: TextStyle(fontSize: 14, color: accentColor, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _buildMemberAvatar('https://i.pravatar.cc/150?img=47', true),
                            Transform.translate(offset: const Offset(-12, 0), child: _buildMemberAvatar('https://i.pravatar.cc/150?img=9', false)),
                            Transform.translate(
                              offset: const Offset(-24, 0),
                              child: Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFEBEBEF), style: BorderStyle.solid, width: 2)),
                                child: Icon(Icons.add, color: textSecondary, size: 20),
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(-36, 0),
                              child: Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFEBEBEF), style: BorderStyle.solid, width: 2)),
                                child: Icon(Icons.add, color: textSecondary, size: 20),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -10))],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _showApplyToast,
            style: ElevatedButton.styleFrom(
              backgroundColor: textPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('참여 신청하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: textSecondary, size: 22),
        const SizedBox(width: 16),
        SizedBox(width: 60, child: Text(title, style: TextStyle(color: textSecondary, fontSize: 15))),
        Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textPrimary))),
      ],
    );
  }

  Widget _buildMemberAvatar(String url, bool isHost) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: CircleAvatar(radius: 24, backgroundImage: NetworkImage(url)),
        ),
        if (isHost)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: textPrimary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
              child: const Icon(Icons.star, color: Colors.white, size: 10),
            ),
          )
      ],
    );
  }
}
