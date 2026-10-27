import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/global_data.dart';
import '../utils/app_image.dart';
import 'soso_car_detail_screen.dart';
import 'empty_state_screen.dart';

class SavedMeetupsScreen extends StatefulWidget {
  const SavedMeetupsScreen({super.key});

  @override
  State<SavedMeetupsScreen> createState() => _SavedMeetupsScreenState();
}

class _SavedMeetupsScreenState extends State<SavedMeetupsScreen> {
  final Color textPrimary = const Color(0xFF0F172A);
  final Color textSecondary = const Color(0xFF64748B);
  final Color surfaceColor = const Color(0xFFFAF6F7);
  final Color accentColor = const Color(0xFFFF6B4A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '내가 찜한 모임',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: globalData.savedMeetups,
        builder: (context, savedList, _) {
          // 1. 공통 EmptyStateScreen 재사용 (Now in Android 원칙)
          if (savedList.isEmpty) {
            return EmptyStateScreen(
              icon: Icons.favorite_border_rounded,
              title: '아직 찜한 모임이 없어요',
              message: '마음에 드는 동네 아지트 모임의 하트를 눌러\n나만의 관심 모임 목록에 보관해보세요!',
              actionLabel: '인기 모임 둘러보기',
              onAction: () => Navigator.pop(context),
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            itemCount: savedList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = savedList[index];
              final title = (item['title'] ?? '모임').toString();
              final location = (item['location'] ?? item['loc'] ?? '서울/경기').toString();
              final category = (item['category'] ?? '취향 아지트').toString();
              final imageUrl = (item['imageUrl'] ?? item['img'] ?? 'assets/images/cover_cafe.jpg').toString();

              return Dismissible(
                key: Key(item['id'] ?? title + index.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
                      SizedBox(width: 6),
                      Text(
                        '찜 해제',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                onDismissed: (_) {
                  HapticFeedback.lightImpact();
                  globalData.toggleFavorite(item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('[$title] 찜 목록에서 제외되었습니다.'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFEFF1F5), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => OOMUDetailScreen(meetup: item)),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Now in Android 88x88 정방형 이미지 (Image State & Error Fallback)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: SizedBox(
                                width: 88,
                                height: 88,
                                child: Image(
                                  image: appImg(imageUrl),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFFF1F5F9),
                                    child: const Icon(
                                      Icons.image_not_supported_rounded,
                                      color: Color(0xFF94A3B8),
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // 우측 정보 컨텐츠 (Card Anatomy)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          category,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF4EB),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          '1/N 안심 정산',
                                          style: TextStyle(
                                            color: Color(0xFFFF6B4A),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),

                                      // 48dp 터치 타깃 찜 해제 하트 버튼
                                      IconButton(
                                        icon: const Icon(Icons.favorite_rounded, color: Color(0xFFFF3B30), size: 22),
                                        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          HapticFeedback.lightImpact();
                                          globalData.toggleFavorite(item);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // 제목: 2줄 말줄임 (TextOverflow.ellipsis)
                                  Text(
                                    title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      height: 1.35,
                                      color: textPrimary,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  // 위치
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF94A3B8)),
                                      const SizedBox(width: 3),
                                      Expanded(
                                        child: Text(
                                          location,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
