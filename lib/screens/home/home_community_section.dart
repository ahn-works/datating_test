import '../../services/community_like_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../ui/oomu_avatar.dart';
import '../../ui/oomu_chip.dart';
import '../../ui/oomu_empty_state.dart';
import '../../ui/oomu_skeleton.dart';
import '../../ui/oomu_tag.dart';
import '../../ui/oomu_tokens.dart';
import '../../utils/app_image.dart';
import '../../utils/firestore_time.dart';
import '../../utils/global_data.dart';
import '../../utils/oomu_ui_helpers.dart';
import '../../widgets/balanced_text.dart';
import '../../widgets/bouncy_tap.dart';
import '../../widgets/balanced_heading.dart';
import '../../widgets/ugc_action_sheets.dart';
import '../community_post_create_screen.dart';
import '../community_post_detail_screen.dart';
import '../login_screen.dart';
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
    return OomuUiHelpers.calculateLocationRelevanceScore(
        widget.currentLocation, loc);
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
          return compareFirestoreTimes(a['createdAt'], b['createdAt']);
        });

        final hiddenPosts = globalData.hiddenPostIds.value;

        final filteredPosts = allPosts.where((post) {
          final author = (post['author'] ?? '').toString();
          final authorUid = (post['authorId'] ??
                  post['authorUid'] ??
                  post['userId'] ??
                  post['uid'] ??
                  '')
              .toString();
          final postId = (post['id'] ?? '').toString().trim();
          if (postId.isEmpty) return false;
          if (globalData.isTargetBlocked(uid: authorUid, nickname: author)) {
            return false;
          }
          if (hiddenPosts.contains(postId)) return false;
          final postLoc = (post['location'] ?? '').toString();
          if (!OomuUiHelpers.matchesRegionFilter(
              widget.currentLocation, postLoc)) {
            return false;
          }

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

        // 첫 데이터가 오기 전에는 빈 화면 대신 스켈레톤을 보여준다(빈 상태가 잠깐 뜨던 문제).
        final bool isLoadingPosts = Firebase.apps.isNotEmpty &&
            !snapshot.hasData &&
            !snapshot.hasError;

        final dong = widget.currentLocation.split(' ').last;

        return ListView(
          padding: const EdgeInsets.only(bottom: 60),
          children: [
            // 1. 심플 원터치 글쓰기 바 (13년차 시니어 디자이너 표준: 화이트 표면 + 1px 초미세 보더)
            Container(
              margin: const EdgeInsets.fromLTRB(
                OomuTokens.spacingLg,
                OomuTokens.spacingMd,
                OomuTokens.spacingLg,
                OomuTokens.spacingSm,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: OomuTokens.spacingMd,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () async {
                  if (globalData.activeUserId == 'guest') {
                    showDialog(
                      context: context,
                      builder: (dCtx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(OomuTokens.r16)),
                        title: const Text('로그인이 필요한 서비스입니다',
                            style: TextStyle(
                                fontSize: OomuTokens.fs16,
                                fontWeight: FontWeight.bold)),
                        content: const Text(
                          '동네 이웃들과 자유롭게 이야기를 나누고 글을 작성하려면 먼저 로그인해 주세요.',
                          style: TextStyle(fontSize: OomuTokens.fs13),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dCtx),
                            child: const Text('둘러보기',
                                style:
                                    TextStyle(color: OomuTokens.textSecondary)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: OomuTokens.coral,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(OomuTokens.r8)),
                            ),
                            onPressed: () {
                              Navigator.pop(dCtx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                              );
                            },
                            child: const Text('로그인하기',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

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
                          color: Color(0xFF8E8E93),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Pretendard',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: OomuTokens.spacingSm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: OomuTokens.coral,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_rounded,
                              size: 13, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            '글쓰기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. 카테고리 칩 바 (13년차 시니어 디자이너 표준: OomuChip 36dp pill 체계로 전역 통일)
            Padding(
              padding: const EdgeInsets.only(
                top: 4,
                bottom: OomuTokens.spacingSm,
              ),
              child: SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: OomuTokens.spacingLg,
                  ),
                  itemCount: _topics.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final topic = _topics[idx];
                    final isSelected = _categoryFilter == topic;
                    return Center(
                      child: OomuChip(
                        label: topic,
                        isSelected: isSelected,
                        onTap: () => setState(() => _categoryFilter = topic),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: OomuTokens.spacingXs),

            // 3. 게시글 목록
            if (filteredPosts.isEmpty && isLoadingPosts)
              const _CommunityListSkeleton()
            else if (filteredPosts.isEmpty)
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
            const Padding(
              padding: OomuInsets.listBottomWithTabs,
            ),
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
    final postId = (post['id'] ?? '').toString();
    final tag = (post['tag'] ?? '').toString();
    final title = (post['title'] ?? '').toString();
    final image = (post['image'] ?? '').toString();
    // 좁은 화면에서 시간이 잘리지 않게 목록에는 동 이름만(예: '전남 여수시 화장동' → '화장동')
    final shortLocation =
        (post['location'] ?? '').toString().trim().split(' ').last;
    final meta = [shortLocation, resolvePostTimeLabel(post)]
        .map((e) => e.trim())
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
                _posts.removeWhere((p) => (p['id'] ?? p['title']) == res['id']);
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
                          final postId = (post['id'] ?? '').toString().trim();
                          if (postId.isEmpty) return;
                          final postAuthorUid = (post['authorId'] ??
                                  post['authorUid'] ??
                                  post['userId'] ??
                                  post['uid'] ??
                                  '')
                              .toString()
                              .trim();
                          final isMine = postAuthorUid.isNotEmpty &&
                              postAuthorUid == globalData.activeUserId;
                          if (isMine) {
                            UgcActionSheets.showOwnContentOptions(
                              context: context,
                              contentId: postId,
                              onEdit: () async {
                                final updated =
                                    await Navigator.push<Map<String, dynamic>>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CommunityPostCreateScreen(
                                      currentLocation: widget.currentLocation,
                                      initialPost: post,
                                    ),
                                  ),
                                );
                                if (updated != null && mounted) {
                                  setState(() {
                                    final idx = _posts
                                        .indexWhere((p) => p['id'] == postId);
                                    if (idx >= 0) _posts[idx] = updated;
                                  });
                                }
                              },
                              onDelete: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (dCtx) => AlertDialog(
                                    title: const Text('게시글 삭제'),
                                    content: const Text(
                                        '이 게시글을 삭제하시겠습니까?\n삭제된 글은 복구할 수 없습니다.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(dCtx, false),
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(dCtx, true),
                                        child: const Text(
                                          '삭제',
                                          style: TextStyle(
                                              color: OomuTokens.error,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm != true || !mounted) return;
                                final messenger = ScaffoldMessenger.of(context);
                                if (Firebase.apps.isNotEmpty) {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('community_posts')
                                        .doc(postId)
                                        .delete();
                                    try {
                                      if (postAuthorUid.isNotEmpty &&
                                          postAuthorUid != 'guest') {
                                        final uRef = FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(postAuthorUid);
                                        await FirebaseFirestore.instance
                                            .runTransaction((tx) async {
                                          final snap = await tx.get(uRef);
                                          final cur =
                                              (snap.data()?['myPostsCount']
                                                          as num?)
                                                      ?.toInt() ??
                                                  0;
                                          tx.set(
                                            uRef,
                                            {
                                              'myPostsCount':
                                                  cur > 0 ? cur - 1 : 0,
                                              'updatedAt':
                                                  FieldValue.serverTimestamp(),
                                            },
                                            SetOptions(merge: true),
                                          );
                                        });
                                        globalData.myPostsCount.value =
                                            (globalData.myPostsCount.value - 1)
                                                .clamp(0, 999999)
                                                .toInt();
                                      }
                                    } catch (cntErr) {
                                      debugPrint(
                                          '[HomeCommunitySection] myPostsCount decrement error: $cntErr');
                                    }
                                  } catch (e) {
                                    debugPrint(
                                        '[HomeCommunitySection] delete error: $e');
                                    messenger.showSnackBar(
                                      const SnackBar(
                                          content: Text('게시글을 삭제하지 못했어요.')),
                                    );
                                    return;
                                  }
                                }
                                if (mounted) {
                                  setState(() {
                                    _posts
                                        .removeWhere((p) => p['id'] == postId);
                                  });
                                  messenger.showSnackBar(
                                    const SnackBar(
                                        content: Text('게시글이 삭제되었습니다.')),
                                  );
                                }
                              },
                            );
                          } else {
                            UgcActionSheets.showContentOptions(
                              context: context,
                              contentType: '게시글',
                              contentId: postId,
                              author: authorName,
                              authorId: postAuthorUid.isNotEmpty
                                  ? postAuthorUid
                                  : null,
                              onContentHidden: () => setState(() {}),
                            );
                          }
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
                    // 단어 중간 줄바꿈 방지: 어절 경계로 줄을 맞춘다.
                    BalancedHeading(
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
                  // 미리보기 본문도 어절 단위 줄바꿈("장/미원이" 방지, 표시 전용)
                  Text(
                    BalancedText.display((post['content'] ?? '').toString()),
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
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              authorName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: OomuTokens.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 6),
                            if (authorManner != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0F1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(0xFFFFD4D8),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.thermostat_rounded,
                                        size: 11, color: OomuTokens.coral),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${authorManner.toStringAsFixed(1)}°C',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: OomuTokens.coral,
                                        fontFamily: 'Pretendard',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (meta.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  meta,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF8E8E93),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Pretendard',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          try {
                            await setCommunityLike(postId, !isLiked);
                          } catch (_) {
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('좋아요를 저장하지 못했어요.')));
                          }
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
                              if (Firebase.apps.isNotEmpty && postId.isNotEmpty)
                                StreamBuilder<
                                    QuerySnapshot<Map<String, dynamic>>>(
                                  // 목록 순서가 바뀌어도 다른 글의 댓글 수를 잠깐 물려받지 않게 글마다 고유 키.
                                  key: ValueKey('comment-count-$postId'),
                                  stream: FirebaseFirestore.instance
                                      .collection('community_posts')
                                      .doc(postId)
                                      .collection('comments')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    // 실제 댓글 수가 오기 전에는 오래된 숫자(초기 목록·저장값)를
                                    // 잠깐 보여줬다가 바뀌는 문제가 있어 빈칸으로 둔다.
                                    // 조회가 실패했을 때만 아래 대체 값을 쓴다.
                                    if (!snapshot.hasData && !snapshot.hasError) {
                                      return const SizedBox(width: 8);
                                    }
                                    final count = snapshot.hasData
                                        ? snapshot.data!.docs.where((doc) {
                                            final data = doc.data();
                                            return !globalData.isTargetBlocked(
                                              uid: (data['authorId'] ??
                                                      data['authorUid'] ??
                                                      data['userId'] ??
                                                      '')
                                                  .toString(),
                                              nickname: (data['author'] ?? '')
                                                  .toString(),
                                            );
                                          }).length
                                        : post['commentList'] is List
                                            ? (post['commentList'] as List)
                                                .whereType<Map>()
                                                .where((raw) =>
                                                    !globalData.isTargetBlocked(
                                                      uid: (raw['authorId'] ??
                                                              raw['authorUid'] ??
                                                              raw['userId'] ??
                                                              '')
                                                          .toString(),
                                                      nickname:
                                                          (raw['author'] ?? '')
                                                              .toString(),
                                                    ))
                                                .length
                                            : comments;
                                    return Text('$count', style: metaStyle);
                                  },
                                )
                              else
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

/// 커뮤니티 목록 로딩 스켈레톤 (태그·제목·본문 2줄·메타 줄, 3개)
class _CommunityListSkeleton extends StatelessWidget {
  const _CommunityListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OomuTokens.s20),
      child: Column(
        children: List.generate(3, (_) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: OomuTokens.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OomuSkeleton(width: 56, height: 20, radius: 6),
                SizedBox(height: OomuTokens.s12),
                OomuSkeleton(width: 240, height: 18),
                SizedBox(height: OomuTokens.s8),
                OomuSkeleton(height: 14),
                SizedBox(height: OomuTokens.s4),
                OomuSkeleton(width: 200, height: 14),
                SizedBox(height: OomuTokens.s12),
                OomuSkeleton(width: 160, height: 14),
              ],
            ),
          );
        }),
      ),
    );
  }
}
