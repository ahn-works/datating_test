import 'package:flutter/material.dart';
import '../utils/global_data.dart';
import '../utils/app_image.dart';
import 'soso_car_detail_screen.dart';

class SavedMeetupsScreen extends StatefulWidget {
  const SavedMeetupsScreen({super.key});

  @override
  State<SavedMeetupsScreen> createState() => _SavedMeetupsScreenState();
}

class _SavedMeetupsScreenState extends State<SavedMeetupsScreen> {
  final Color textPrimary = const Color(0xFF111111);
  final Color textSecondary = const Color(0xFF767676);
  final Color surfaceColor = const Color(0xFFF5F5F7);
  final Color accentColor = const Color(0xFFFF5E36);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('내가 찜한 모임 ❤️', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: globalData.savedMeetups,
        builder: (context, savedList, _) {
          if (savedList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: const Color(0xFFC7C7CC)),
                  const SizedBox(height: 16),
                  Text('아직 찜한 모임이 없어요', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary)),
                  const SizedBox(height: 8),
                  Text('마음에 드는 취향 모임의 하트를 눌러 보관해보세요!', style: TextStyle(fontSize: 14, color: textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('모임 둘러보기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: savedList.length,
            itemBuilder: (context, index) {
              final item = savedList[index];
              return Dismissible(
                key: Key(item['id'] ?? item['title'] ?? index.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline, color: Colors.white),
                      SizedBox(width: 4),
                      Text('찜 해제', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                onDismissed: (_) {
                  globalData.toggleFavorite(item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('💔 [${item['title']}] 찜 목록에서 삭제되었습니다')),
                  );
                },
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => OOMUDetailScreen(meetup: item)));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEBEBEF)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 14, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: Image(
                              image: appImg(item['imageUrl'] ?? 'assets/images/cover_cafe.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(6)),
                                      child: Text(item['category'] ?? '모임', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textSecondary)),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                                      onPressed: () {
                                        globalData.toggleFavorite(item);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item['title'] ?? '',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_rounded, size: 15, color: const Color(0xFFFF5E36)),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(item['location'] ?? '', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: textSecondary), overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
