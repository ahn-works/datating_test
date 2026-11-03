import '../widgets/related_meetups.dart';
import '../widgets/balanced_heading.dart';
import '../utils/event_meetup_category.dart';
import '../utils/oomu_ui_helpers.dart';
import 'package:flutter/services.dart';
import '../services/kakao_map_service.dart';
import 'package:flutter/material.dart';
import '../utils/app_image.dart';
import 'soso_car_host_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    const Color textPrimary = OomuUiHelpers.textPrimary;
    const Color textSecondary = OomuUiHelpers.textSecondary;
    const Color surfaceColor = OomuUiHelpers.backgroundNeutral;
    const Color coralAccent = Color(0xFFF25767);

    final title = event['title']?.toString() ?? '문화 & 트렌드 이벤트';
    final location = event['location']?.toString() ?? event['venue']?.toString() ?? '';
    final category = event['category']?.toString() ?? '동네 장소';
    final meetupCategory = eventMeetupCategory(category);
    final poster = event['poster']?.toString() ?? '';
    final rawPeriod = event['period']?.toString().trim();
    final period = rawPeriod == null || rawPeriod.isEmpty || rawPeriod == '상시 운영' ? '운영 일정 확인 필요' : rawPeriod;
    final vibe = event['vibe']?.toString().trim() ?? '';

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
                backgroundColor: Colors.black.withValues(alpha: 0.4),
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
                  backgroundColor: Colors.black.withValues(alpha: 0.4),
                  child: IconButton(
                    icon: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: '$title\n$location\n$period'));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('장소 정보를 복사했어요.')),
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
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
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
                  Text(category, style: const TextStyle(fontSize: 13, color: textSecondary)),
                  const SizedBox(height: 8),
                  BalancedHeading(title, style: const TextStyle(fontSize: 22, height: 1.4, fontWeight: FontWeight.w700, color: textPrimary)),
                  const SizedBox(height: 24),
                  // Quick Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: OomuUiHelpers.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
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
                                color: coralAccent.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.place_rounded, color: coralAccent, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('장소', style: const TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(location.isEmpty ? '정확한 장소 확인 필요' : location, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPrimary)),
                                ],
                              ),
                            ),

                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(width: double.infinity, child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48), foregroundColor: textPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: location.isEmpty ? null : () => KakaoMapService.launchDirections(location),
                          icon: const Icon(Icons.directions_outlined, size: 20), label: const Text('지도에서 길찾기'),
                        )),
                        const Divider(height: 20, color: Color(0xFFEAECF0)),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEEF2FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF6B7684), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('방문 일정', style: const TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(period, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPrimary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20, color: Color(0xFFEAECF0)),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF0FDFA),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.category_rounded, color: Color(0xFF6B7684), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('카테고리 & 무드', style: const TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(vibe.isEmpty ? category : '$category · $vibe', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPrimary)),
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
                  Text('어떤 곳인가요?', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPrimary)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: OomuUiHelpers.borderSubtle),
                    ),
                    child: Text(
                      (event['description'] ?? event['intro'])?.toString().trim().isNotEmpty == true
                          ? (event['description'] ?? event['intro']).toString()
                          : '아직 자세한 소개가 없어요. 방문 전 운영 시간과 예약 여부를 확인해 주세요.',
                      style: const TextStyle(fontSize: 13.5, height: 1.6, color: textSecondary),
                    ),
                  ),

                  const SizedBox(height: 28),
                  RelatedMeetups(eventId: event['id']?.toString() ?? '$title|$location'),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
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
                            sourceEventId: event['id']?.toString() ?? '$title|$location',
                            sourceEventTitle: title,
                            initialMainCategory: meetupCategory?.main,
                            initialSubCategory: meetupCategory?.sub,
                            initialTitle: '$title 함께 가요',
                            initialLocation: location,
                            initialCoverImageUrl: poster,
                            initialVibe: vibe,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 18, color: Colors.white),
                    label: const Text(
                      '이곳에 같이 갈 모임 열기',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
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
