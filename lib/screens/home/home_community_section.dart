import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../ui/oomu_avatar.dart';
import '../../ui/oomu_empty_state.dart';
import '../../ui/oomu_tag.dart';
import '../../ui/oomu_tokens.dart';
import '../../utils/app_image.dart';
import '../../utils/global_data.dart';
import '../../utils/oomu_ui_helpers.dart';
import '../../widgets/bouncy_tap.dart';
import '../../widgets/ugc_action_sheets.dart';
import '../community_post_create_screen.dart';
import '../community_post_detail_screen.dart';
import '../user_profile_screen.dart';

/// 홈 화면 커뮤니티 대시보드 (탭 1) 섹션 컴포넌트
class HomeCommunitySection extends StatefulWidget {
  final String currentLocation;
  final List<Map<String, dynamic>> initialPosts;

  const HomeCommunitySection({
    super.key,
    required this.currentLocation,
    required this.initialPosts,
  });

  @override
  State<HomeCommunitySection> createState() => _HomeCommunitySectionState();
}

class _HomeCommunitySectionState extends State<HomeCommunitySection> {
  String _categoryFilter = '전체';
  String? _keywordFilter;
  late List<Map<String, dynamic>> _posts;

  static const List<String> _topics = [
    '전체',
    '일상·수다',
    '공연·핫플',
    '맛집·카페',
    '동네질문',
  ];

  @override
  void initState() {
    super.initState();
    _posts = List<Map<String, dynamic>>.from(widget.initialPosts);
  }

  int _calculateLocationRelevance(String loc) {
    if (loc.isEmpty) return 0;
    final dong = widget.currentLocation.split(' ').last;
    if (loc.contains(dong)) return 3;
    final gu = widget.currentLocation.split(' ').first;
    if (loc.contains(gu)) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firebase.apps.isNotEmpty
          ? FirebaseFirestore.instance.collection('community_posts').snapshots()
          : null,
      builder: (context, snapshot) {
        final Map<String, Map<String, dynamic>> postMap = {};

        for (final p in _posts) {
          final cloned = Map<String, dynamic>.from(p);
          final pid = cloned['id']?.toString() ?? '';
          if (cloned['commentList'] is List) {
            cloned['comments'] = (cloned['commentList'] as List).length;
          }
          postMap[pid] = cloned;
        }

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          for (final doc in snapshot.data!.docs) {
            final data =
                Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
            final pid = doc.id;
            data['id'] = pid;
            for (final key in [
              'title',
              'content',
              'author',
              'location',
              'category',
              'tag',
              'time'
            ]) {
              data[key] = data[key]?.toString() ?? '';
            }
            for (final key in ['comments', 'likes']) {
              data[key] = int.tryParse(data[key]?.toString() ?? '') ?? 0;
            }

            final likedUsers = data['likedUserIds'] is List
                ? List<dynamic>.from(data['likedUserIds'])
                : <dynamic>[];
            final currentUid = globalData.activeUserId;
            data['isLiked'] =
                currentUid.isNotEmpty && likedUsers.contains(currentUid);
            data['likes'] = likedUsers.isNotEmpty
                ? likedUsers.length
                : (data['likes'] ?? 0);

            if (postMap.containsKey(pid)) {
              postMap[pid]!.addAll(data);
            } else {
              postMap[pid] = data;
            }
          }
        }

        final allPosts = postMap.values.toList();
        allPosts.sort((a, b) {
          final scoreA =
              _calculateLocationRelevance(a['location']?.toString() ?? '');
          final scoreB =
              _calculateLocationRelevance(b['location']?.toString() ?? '');
          if (scoreA != scoreB) {
            return scoreB.compareTo(scoreA);
          }
          final aTime = a['createdAt'];
          final bTime = b['createdAt'];
          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime);
          }
          return 0;
        });

        final blocked = globalData.blockedUsers.value;
        final hiddenPosts = globalData.hiddenPostIds.value;

        final filteredPosts = allPosts.where((post) {
          final author = post['author'] ?? '';
          final postId = post['id'] ?? post['title'] ?? '';
          if (blocked.contains(author)) return false;
          if (hiddenPosts.contains(postId)) return false;

          if (_categoryFilter != '전체') {
            final cat = post['category']?.toString() ?? '';
            if (_categoryFilter == '일상·수다' &&
                cat != '동네 토크' &&
                cat != '일상' &&
                !cat.contains('수다')) {
              return false;
            }
            if (_categoryFilter == '공연·핫플' &&
                cat != '공연/전시' &&
                cat != '공연' &&
                !cat.contains('핫플')) {
              return false;
            }
            if (_categoryFilter == '맛집·카페' &&
                cat != '맛집/카페' &&
                cat != '맛집' &&
                !cat.contains('카페')) {
              return false;
            }
            if (_categoryFilter == '동네질문' &&
                cat != '질문/추천' &&
                cat != '질문' &&
                !cat.contains('질문')) {
              return false;
            }
          }

          if (_keywordFilter != null &&
              post['tag'] != _keywordFilter!.replaceAll('#', '')) {
            return false;
          }
          return true;
        }).toList();

        final dong = widget.currentLocation.split(' ').last;

        return ListView(
          padding: const EdgeInsets.only(bottom: 60),
          children: [
            // 1. 심플 원터치 글쓰기 바
            Container(
              margin: const EdgeInsets.fromLTRB(
                OomuTokens.spacingLg,
                OomuTokens.spacingMd,
                OomuTokens.spacingLg,
                OomuTokens.spacingSm,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: OomuTokens.spacingMd,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: OomuTokens.surfaceMuted,
                borderRadius: BorderRadius.circular(OomuTokens.radiusCardSm),
              ),
              child: InkWell(
                onTap: () async {
                  final newPost = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommunityPostCreateScreen(
                        currentLocation: widget.currentLocation,
                      ),
                    ),
                  );
                  if (newPost != null && mounted) {
                    setState(() {
                      _posts.insert(0, newPost);
                    });
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('이야기가 동네 커뮤니티에 등록되었습니다!'),
                        ),
                      );
                    }
                  }
                },
                child: Row(
                  children: [
                    ValueListenableBuilder<String>(
                      valueListenable: globalData.userAvatar,
                      builder: (_, avatarUrl, __) => OomuAvatar.small(
                        imageUrl: avatarUrl,
                      ),
                    ),
                    const SizedBox(width: OomuTokens.spacingSm),
                    Expanded(
                      child: Text(
                        '$dong의 일상과 소식을 나눠보세요',
                        style: const TextStyle(
                          color: OomuTokens.textSecondary,
                          fontSize: OomuTokens.fontSm,
                          fontFamily: OomuTokens.fontFamily,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: OomuTokens.spacingSm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: OomuTokens.spacingSm,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: OomuTokens.coral,
                        borderRadius:
                            BorderRadius.circular(OomuTokens.radiusCardSm),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_outlined,
                              size: 13, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            '글쓰기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: OomuTokens.fontXs,
                              fontWeight: OomuTokens.weightBold,
                              fontFamily: OomuTokens.fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. 밑줄 탭 (선택된 글자만 진하게 + 얇은 밑줄, 한 줄)
            Container(
              height: 44,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: OomuTokens.border, width: 1),
                ),
              ),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: OomuTokens.spacingLg,
                ),
                itemCount: _topics.length,
                separatorBuilder: (_, __) => const SizedBox(width: 22),
                itemBuilder: (context, idx) {
                  final topic = _topics[idx];
                  final isSelected = _categoryFilter == topic;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _categoryFilter = topic),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected
                                ? OomuTokens.textPrimary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        topic,
                        style: TextStyle(
                          fontSize: OomuTokens.fs15,
                          fontWeight:
                              isSelected ? OomuTokens.w700 : FontWeight.w500,
                          color: isSelected
                              ? OomuTokens.textPrimary
                              : OomuTokens.textMuted,
                          fontFamily: OomuTokens.fontFamily,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: OomuTokens.spacingXs),

            // 3. 게시글 목록
            if (filteredPosts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(OomuTokens.spacingXl),
                child: OomuEmptyState(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: '등록된 동네 이야기가 없어요',
                  subtitle: '첫 번째 이야기를 직접 나눠보세요!',
                  buttonLabel: '이야기 쓰기',
                  onButtonPressed: () async {
                    final newPost = await Navigator.push<Map<String, dynamic>>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommunityPostCreateScreen(
                          currentLocation: widget.currentLocation,
                        ),
                      ),
                    );
                    if (newPost != null && mounted) {
                      setState(() {
                        _posts.insert(0, newPost);
                      });
                    }
                  },
                ),
              )
            else
              ...filteredPosts.map((post) => _buildCommunityCard(post)),
          ],
        );
      },
    );
  }

  /// 커뮤니티 글 한 줄 (카드 박스 없이 1px 구분선 + 오른쪽 작은 썸네일)
  Widget _buildCommunityCard(Map<String, dynamic> post) {
    final authorName = (post['author'] ?? '동네주민').toString();
    final authorAvatar = post['authorAvatar']?.toString();
    final authorManner = OomuUiHelpers.parseMannerTemp(post);
    final isLiked = post['isLiked'] == true;
    final likes = (post['likes'] ?? 0) as int;
    final comments = (post['comments'] ?? 0) as int;
    final tag = (post['tag'] ?? '').toString();
    final title = (post['title'] ?? '').toString();
    final image = (post['image'] ?? '').toString();
    final meta = [post['location'], post['time']]
        .map((e) => (e ?? '').toString().trim())
        .where((e) => e.isNotEmpty)
        .join(' · ');

    const metaStyle = TextStyle(
      fontSize: OomuTokens.fs13,
      color: OomuTokens.textMuted,
      fontFamily: OomuTokens.fontFamily,
      height: 1.5,
    );

    return BouncyTap(
      scaleDown: 0.98,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommunityPostDetailScreen(post: post),
          ),
        ).then((res) {
          if (mounted) {
            if (res is Map && res['deleted'] == true) {
              setState(() {
                _posts
                    .removeWhere((p) => (p['id'] ?? p['title']) == res['id']);
              });
            } else {
              setState(() {});
            }
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: OomuTokens.spacingLg,
          vertical: 18,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: OomuTokens.border, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 말머리(회색 라벨 하나) + 더보기
                  Row(
                    children: [
                      if (tag.isNotEmpty) OomuTag(label: '#$tag'),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          UgcActionSheets.showContentOptions(
                            context: context,
                            contentType: '게시글',
                            contentId: post['id'] ??
                                post['title'] ??
                                'post_${post['author']}',
                            author: authorName,
                            onContentHidden: () => setState(() {}),
                          );
                        },
                        borderRadius: BorderRadius.circular(OomuTokens.r16),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.more_horiz,
                            size: 20,
                            color: OomuTokens.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 제목
                  if (title.isNotEmpty) ...[
                    const SizedBox(height: OomuTokens.spacingXs),
                    Text(
                      OomuUiHelpers.formatTitle(title),
                      style: const TextStyle(
                        fontSize: OomuTokens.fs17,
                        fontWeight: OomuTokens.w600,
                        color: OomuTokens.textPrimary,
                        fontFamily: OomuTokens.fontFamily,
                        height: 1.4,
                        letterSpacing: -0.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // 본문
                  const SizedBox(height: OomuTokens.spacingXs),
                  Text(
                    post['content'] ?? '',
                    style: const TextStyle(
                      fontSize: OomuTokens.fs14,
                      fontWeight: OomuTokens.weightRegular,
                      color: OomuTokens.textBody,
                      fontFamily: OomuTokens.fontFamily,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: OomuTokens.spacingMd - 4),

                  // 작성자 · 장소 · 시간 + 좋아요/댓글
                  Row(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserProfileScreen(
                                userName: authorName,
                                userAvatar: authorAvatar,
                                userLocation: post['location']?.toString(),
                                userManner: authorManner,
                              ),
                            ),
                          );
                        },
                        child: OomuAvatar(
                          imageUrl: authorAvatar,
                          name: authorName,
                          radius: 10,
                        ),
                      ),
                      const SizedBox(width: OomuTokens.spacingSm),
                      Expanded(
                        child: Text(
                          [
                            authorName,
                            if (authorManner != null)
                              OomuUiHelpers.formatMannerTemp(authorManner),
                            if (meta.isNotEmpty) meta,
                          ].join(' · '),
                          style: metaStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            final myUserId = globalData.activeUserId;
                            List<dynamic> likedUsers =
                                List<dynamic>.from(post['likedUserIds'] ?? []);
                            bool currentlyLiked =
                                likedUsers.contains(myUserId) ||
                                    likedUsers.contains('user_me_01');
                            if (currentlyLiked) {
                              likedUsers.remove(myUserId);
                              likedUsers.remove('user_me_01');
                            } else {
                              likedUsers.add(myUserId);
                            }
                            post['likedUserIds'] = likedUsers;
                            post['likes'] = likedUsers.length;
                            post['isLiked'] = !currentlyLiked;

                            final postId = post['id']?.toString();
                            if (postId != null && postId.isNotEmpty) {
                              try {
                                FirebaseFirestore.instance
                                    .collection('community_posts')
                                    .doc(postId)
                                    .set({
                                  'likedUserIds': likedUsers,
                                  'likes': likedUsers.length,
                                  'updatedAt': FieldValue.serverTimestamp(),
                                }, SetOptions(merge: true));
                              } catch (_) {}
                            }
                          });
                        },
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 36,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                isLiked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 16,
                                color: isLiked
                                    ? OomuTokens.coral
                                    : OomuTokens.textMuted,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '$likes',
                                style: metaStyle.copyWith(
                                  color: isLiked
                                      ? OomuTokens.coralText
                                      : OomuTokens.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CommunityPostDetailScreen(post: post),
                            ),
                          ).then((_) {
                            if (mounted) setState(() {});
                          });
                        },
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 36,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 15,
                                color: OomuTokens.textMuted,
                              ),
                              const SizedBox(width: 3),
                              Text('$comments', style: metaStyle),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 첨부 사진: 오른쪽 작은 썸네일
            if (image.isNotEmpty) ...[
              const SizedBox(width: OomuTokens.spacingMd - 2),
              Padding(
                padding: const EdgeInsets.only(top: OomuTokens.spacingLg + 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(OomuTokens.radiusCardSm),
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: Image(
                      image: appImg(post['image']),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: OomuTokens.surfaceMuted,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: OomuTokens.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}