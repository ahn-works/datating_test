import 'package:flutter/material.dart';
import '../utils/app_image.dart';
import 'soso_car_host_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final Color textPrimary = const Color(0xFF221B1D);
    final Color textSecondary = const Color(0xFF635559);
    final Color surfaceColor = const Color(0xFFFAF6F7);
    final Color coralAccent = const Color(0xFFF25767);

    final title = event['title']?.toString() ?? '문화 & 트렌드 이벤트';
    final location = event['location']?.toString() ?? event['venue']?.toString() ?? '서울 일대';
    final category = event['category']?.toString() ?? '문화 & 엔터';
    final tag = event['tag']?.toString() ?? '🔥 실시간 트렌드';
    final poster = event['poster']?.toString() ?? '';
    final period = event['period']?.toString() ?? '상시 운영';
    final vibe = event['vibe']?.toString() ?? '놀줄아는';

    return Scaffold(
      backgroundColor: surfaceColor,
      body: CustomScrollView(
        slivers: [
          // Collapsible Image App Bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.4),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.4),
                  child: IconButton(
                    icon: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('이벤트 링크가 복사되었습니다!')),
                      );
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: appImg(poster.isNotEmpty ? poster : 'assets/images/cover_food.jpg'),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/cover_wine.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: coralAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Event Details Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFEFE4E6)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: coralAccent.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.place_rounded, color: coralAccent, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('공연/행사 장소', style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(location, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPrimary)),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('🗺️ $location 지도 및 길찾기로 연결합니다.')),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: coralAccent),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text('지도보기', style: TextStyle(fontSize: 11, color: coralAccent, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const Divider(height: 20, color: Color(0xFFF3EAEB)),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEEF2FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF6366F1), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('일정 / 공연 기간', style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(period, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPrimary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20, color: Color(0xFFF3EAEB)),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF0FDFA),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.category_rounded, color: Color(0xFF0D9488), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('카테고리 & 무드', style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text('$category · #$vibe', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPrimary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Event Introduction
                  Text('이벤트 소개 & 동행 팁', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPrimary)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEFE4E6)),
                    ),
                    child: Text(
                      'KOPIS(공연예술통합전산망) 및 트렌드 AI 큐레이션으로 선별된 핫 이벤트입니다.\n\n'
                      '혼자 가기 아쉬웠거나 취향이 맞는 동네 친구들과 함께 가고 싶다면, 아래 버튼으로 동행 번개 모임을 열어보세요! '
                      '티켓 예매 전후로 커피나 식사를 함께할 메이트를 빠르게 모을 수 있습니다.',
                      style: TextStyle(fontSize: 13.5, height: 1.6, color: textSecondary),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OOMUHostScreen(
                            initialTitle: '$title 동행 팟',
                            initialLocation: location,
                            initialMainCategory: category,
                            initialCoverImageUrl: poster,
                            initialVibe: vibe,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 18, color: Colors.white),
                    label: const Text(
                      '이 이벤트로 모임 만들기',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: coralAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
