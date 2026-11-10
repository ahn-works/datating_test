import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../ui/oomu_avatar.dart';
import '../ui/oomu_empty_state.dart';
import '../ui/oomu_tag.dart';
import '../ui/oomu_tokens.dart';
import '../utils/app_image.dart';
import '../utils/global_data.dart';
import '../utils/oomu_ui_helpers.dart';
import '../widgets/balanced_heading.dart';
import '../widgets/bouncy_tap.dart';
import '../widgets/ugc_action_sheets.dart';
import 'user_profile_screen.dart';

class CommunityPostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  const CommunityPostDetailScreen({super.key, required this.post});

  @override
  State<CommunityPostDetailScreen> createState() =>
      _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState extends State<CommunityPostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late bool _isLiked;
  late int _likeCount;
  late List<Map<String, dynamic>> _comments;
  bool _isSubmittingComment = false;

  String? get _postId {
    final raw = widget.post['id']?.toString().trim();
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  bool get _canUseFirestore {
    try {
      return Firebase.apps.isNotEmpty && _postId != null;
    } catch (_) {
      return false;
    }
  }

  void _initPostState() {
    _isLiked = widget.post['isLiked'] == true;
    _likeCount = (widget.post['likes'] is num)
        ? (widget.post['likes'] as num).toInt()
        : 0;
    final rawList = widget.post['commentList'];
    if (rawList is List) {
      _comments = rawList
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } else {
      _comments = <Map<String, dynamic>>[];
    }
    try {
      widget.post['commentList'] = _comments;
      widget.post['comments'] = _comments.length;
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _initPostState();
  }

  @override
  void didUpdateWidget(covariant CommunityPostDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post != widget.post ||
        oldWidget.post['id'] != widget.post['id']) {
      _isSubmittingComment = false;
      _commentController.clear();
      _initPostState();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    if (_isSubmittingComment) return;
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSubmittingComment = true;
    });

    final myNick = globalData.userNickname.value.isNotEmpty
        ? globalData.userNickname.value
        : '이웃';
    final myAvatar = globalData.userAvatar.value.isNotEmpty
        ? globalData.userAvatar.value
        : 'assets/images/지훈.png';
    final postId = _postId;

    final newComm = <String, dynamic>{
      'id': 'local_${DateTime.now().microsecondsSinceEpoch}',
      'author': myNick,
      'authorAvatar': myAvatar,
      'content': text,
      'time': '방금 전',
      'likes': 0,
      'isLiked': false,
      'likedUserIds': <String>[],
    };

    if (!_canUseFirestore || postId == null) {
      setState(() => _isSubmittingComment = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('실제 게시글에서 댓글을 작성할 수 있어요.')),
      );
      return;
    }
    try {
      final db = FirebaseFirestore.instance;
      final authorUid = FirebaseAuth.instance.currentUser?.uid ??
          (globalData.activeUserId.isNotEmpty
              ? globalData.activeUserId
              : 'user_${DateTime.now().millisecondsSinceEpoch}');
      final postRef = db.collection('community_posts').doc(postId);
      final commentRef = postRef.collection('comments').doc();

      await postRef.set({
        'id': postId,
        'title': widget.post['title'] ?? '',
        'content': widget.post['content'] ?? '',
        'author': widget.post['author'] ?? '',
        'authorAvatar': widget.post['authorAvatar'] ?? '',
        'location': widget.post['location'] ?? '',
        'category': widget.post['category'] ?? '',
        'tag': widget.post['tag'] ?? '',
        'time': widget.post['time'] ?? '방금 전',
        'comments': FieldValue.increment(1),
        'likes': widget.post['likes'] ?? 0,
        'likedUserIds': widget.post['likedUserIds'] ?? <String>[],
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await commentRef.set({
        'authorId': authorUid,
        'author': myNick,
        'authorAvatar': myAvatar,
        'content': text,
        'time': '방금 전',
        'likes': 0,
        'likedUserIds': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      newComm['id'] = commentRef.id;
      _commentController.clear();
      FocusScope.of(context).unfocus();
      setState(() {
        if (!_comments.any((comment) => comment['id'] == commentRef.id)) {
          _comments.add(newComm);
        }
        widget.post['commentList'] = _comments;
        widget.post['comments'] = _comments.length;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmittingComment = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('댓글을 저장하지 못했어요. 입력한 내용은 남겨두었어요. 다시 시도해 주세요.'),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _isSubmittingComment = false;
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('댓글이 등록되었습니다.')),
    );
  }

  void _toggleLike() {
    setState(() {
      final myUserId = FirebaseAuth.instance.currentUser?.uid ??
          (globalData.activeUserId.isNotEmpty
              ? globalData.activeUserId
              : 'user_me');
      List<dynamic> likedUsers =
          List<dynamic>.from(widget.post['likedUserIds'] ?? []);
      if (_isLiked) {
        likedUsers.remove(myUserId);
        likedUsers.remove('user_me_01');
      } else {
        if (!likedUsers.contains(myUserId)) {
          likedUsers.add(myUserId);
        }
      }
      _isLiked = !_isLiked;
      _likeCount = likedUsers.length;
      widget.post['likedUserIds'] = likedUsers;
      widget.post['likes'] = _likeCount;
      widget.post['isLiked'] = _isLiked;

      final postId = _postId;
      if (_canUseFirestore && postId != null) {
        try {
          FirebaseFirestore.instance
              .collection('community_posts')
              .doc(postId)
              .set({
            'likedUserIds': likedUsers,
            'likes': _likeCount,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (_) {}
      }
    });
  }

  List<Map<String, dynamic>> _resolveDisplayComments(
      AsyncSnapshot<QuerySnapshot>? commentSnap) {
    if (commentSnap != null &&
        commentSnap.hasData &&
        commentSnap.data!.docs.isNotEmpty) {
      final docs = commentSnap.data!.docs.map((d) {
        final data =
            Map<String, dynamic>.from(d.data() as Map<String, dynamic>);
        data['id'] = d.id;
        final likedUsers = List<dynamic>.from(data['likedUserIds'] ?? []);
        final currentUid = globalData.activeUserId;
        data['isLiked'] = likedUsers.contains(currentUid) ||
            likedUsers.contains('user_me_01');
        data['likes'] =
            likedUsers.isNotEmpty ? likedUsers.length : (data['likes'] ?? 0);
        return data;
      }).toList();

      docs.sort((a, b) {
        final aTime = a['createdAt'];
        final bTime = b['createdAt'];
        DateTime? dtA, dtB;
        if (aTime is Timestamp) {
          dtA = aTime.toDate();
        } else if (aTime is String) {
          dtA = DateTime.tryParse(aTime);
        }
        if (bTime is Timestamp) {
          dtB = bTime.toDate();
        } else if (bTime is String) {
          dtB = DateTime.tryParse(bTime);
        }
        if (dtA != null && dtB != null) {
          return dtA.compareTo(dtB);
        }
        return 0;
      });

      try {
        widget.post['comments'] = docs.length;
      } catch (_) {}
      return docs;
    }
    try {
      widget.post['comments'] = _comments.length;
    } catch (_) {}
    return List<Map<String, dynamic>>.from(_comments);
  }

  Widget _buildBodyContent(List<Map<String, dynamic>> displayComments) {
    final post = widget.post;
    final author = (post['author'] ?? '동네주민').toString();
    final isAuthorMe = author == globalData.userNickname.value ||
        (post['authorId'] != null && post['authorId'] == globalData.activeUserId);
    final effectiveAuthorAvatar = (isAuthorMe && globalData.userAvatar.value.isNotEmpty)
        ? globalData.userAvatar.value
        : ((post['authorAvatar'] != null && post['authorAvatar'].toString().isNotEmpty)
            ? post['authorAvatar'].toString()
            : '');
    final location = (post['location'] ?? '마포구 서교동').toString();
    final time = (post['time'] ?? '방금 전').toString();
    final double? authorManner = OomuUiHelpers.parseMannerTemp(post);
    final tag = post['tag'];
    final title = (post['title'] ?? '').toString();
    final content = (post['content'] ?? '').toString();
    final image = post['image'];
    final postId = _postId;

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: OomuTokens.s24),
      children: [
        // Main Post Content Card
        Container(
          color: OomuTokens.surface,
          padding: const EdgeInsets.fromLTRB(
            OomuTokens.s20,
            OomuTokens.s16,
            OomuTokens.s20,
            OomuTokens.s20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author Row
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserProfileScreen(
                            userName: author,
                            userAvatar: effectiveAuthorAvatar,
                            userLocation: location,
                            userManner: authorManner,
                          ),
                        ),
                      );
                    },
                    child: OomuAvatar(
                      imageUrl: effectiveAuthorAvatar,
                      name: author,
                      radius: 20,
                    ),
                  ),
                  const SizedBox(width: OomuTokens.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => UserProfileScreen(
                                        userName: author,
                                        userAvatar:
                                            post['authorAvatar']?.toString(),
                                        userLocation: location,
                                        userManner: authorManner,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  author,
                                  style: const TextStyle(
                                    fontSize: OomuTokens.fs14,
                                    fontWeight: OomuTokens.w700,
                                    color: OomuTokens.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            if (authorManner != null) ...[
                              const SizedBox(width: OomuTokens.s8),
                              OomuTag(
                                label: OomuUiHelpers.formatMannerTemp(authorManner),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$location · $time',
                          style: const TextStyle(
                            fontSize: OomuTokens.fs12,
                            color: OomuTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (tag != null)
                    OomuTag(
                      label: '#$tag',
                    ),
                ],
              ),

              const SizedBox(height: OomuTokens.s16),

              // Title
              if (title.isNotEmpty) ...[
                BalancedHeading(
                  OomuUiHelpers.formatTitle(title, fallback: ''),
                  style: const TextStyle(
                    fontSize: OomuTokens.fs18,
                    fontWeight: OomuTokens.w700,
                    color: OomuTokens.textPrimary,
                    height: 1.35,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: OomuTokens.s12),
              ],

              // Body Text
              Text(
                content,
                style: const TextStyle(
                  fontSize: OomuTokens.fs14,
                  fontWeight: OomuTokens.w400,
                  height: 1.65,
                  color: OomuTokens.textBody,
                  letterSpacing: -0.15,
                ),
              ),

              // Attached Photo
              if (image != null && image.toString().isNotEmpty) ...[
                const SizedBox(height: OomuTokens.s16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(OomuTokens.r16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 340),
                    child: SizedBox(
                      width: double.infinity,
                      child: Image(
                        image: appImg(image.toString()),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 160,
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

              const SizedBox(height: OomuTokens.s16),

              // Interaction Row
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: OomuTokens.s12,
                      runSpacing: 4,
                      children: [
                        Tooltip(
                          message: '게시글 좋아요',
                          child: BouncyTap(
                            scaleDown: 0.90,
                            onHaptic: OomuHaptics.light,
                            onTap: _toggleLike,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 48,
                                minHeight: 48,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: OomuTokens.s12,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isLiked
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      size: 19,
                                      color: _isLiked
                                          ? OomuTokens.coral
                                          : OomuTokens.textSecondary,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '좋아요 $_likeCount',
                                      style: TextStyle(
                                        fontSize: OomuTokens.fs12,
                                        fontWeight: OomuTokens.w700,
                                        color: _isLiked
                                            ? OomuTokens.coral
                                            : OomuTokens.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 48),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 18,
                                color: OomuTokens.textSecondary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '댓글 ${displayComments.length}',
                                style: const TextStyle(
                                  fontSize: OomuTokens.fs12,
                                  fontWeight: OomuTokens.w700,
                                  color: OomuTokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: '게시글 공유',
                    icon: const Icon(
                      Icons.share_outlined,
                      size: 19,
                      color: OomuTokens.textSecondary,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('게시글 링크가 클립보드에 복사되었습니다!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: OomuTokens.s8),

        // Comments Header (정돈된 '댓글 N' 단일 표기)
        Padding(
          padding: const EdgeInsets.fromLTRB(
            OomuTokens.s20,
            OomuTokens.s16,
            OomuTokens.s20,
            OomuTokens.s12,
          ),
          child: Text(
            '댓글 ${displayComments.length}',
            style: const TextStyle(
              fontSize: OomuTokens.fs14,
              fontWeight: OomuTokens.w700,
              color: OomuTokens.textPrimary,
            ),
          ),
        ),

        // Comments Empty State or List
        if (displayComments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: OomuTokens.s20,
              vertical: OomuTokens.s16,
            ),
            child: OomuEmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: '첫 댓글을 남겨보세요',
              subtitle: '동네 이웃과 따뜻한 대화를 시작해 보세요 💬',
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayComments.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: OomuTokens.border),
            itemBuilder: (context, index) {
              final comm = displayComments[index];
              final isCommLiked = comm['isLiked'] == true;
              final commLikes =
                  (comm['likes'] is num) ? (comm['likes'] as num).toInt() : 0;
              final commId = comm['id']?.toString();

              final commAuthor = (comm['author'] ?? '이웃').toString();
              final isCommMe = commAuthor == globalData.userNickname.value ||
                  (comm['authorId'] != null &&
                      comm['authorId'] == globalData.activeUserId);
              final effectiveCommAvatar = (isCommMe &&
                      globalData.userAvatar.value.isNotEmpty)
                  ? globalData.userAvatar.value
                  : ((comm['authorAvatar'] != null &&
                          comm['authorAvatar'].toString().isNotEmpty)
                      ? comm['authorAvatar'].toString()
                      : '');

              return Container(
                color: OomuTokens.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: OomuTokens.s20,
                  vertical: OomuTokens.s12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfileScreen(
                              userName: commAuthor,
                              userAvatar: effectiveCommAvatar,
                            ),
                          ),
                        );
                      },
                      child: OomuAvatar(
                        imageUrl: effectiveCommAvatar,
                        name: commAuthor,
                        radius: 16,
                      ),
                    ),
                    const SizedBox(width: OomuTokens.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => UserProfileScreen(
                                          userName: (comm['author'] ?? '이웃')
                                              .toString(),
                                          userAvatar:
                                              comm['authorAvatar']?.toString(),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    (comm['author'] ?? '이웃').toString(),
                                    style: const TextStyle(
                                      fontSize: OomuTokens.fs12,
                                      fontWeight: OomuTokens.w700,
                                      color: OomuTokens.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: OomuTokens.s4),
                              Text(
                                (comm['time'] ?? '방금').toString(),
                                style: const TextStyle(
                                  fontSize: OomuTokens.fs11,
                                  color: OomuTokens.textSecondary,
                                ),
                              ),
                              if ((comm['authorId']?.toString() ==
                                          globalData.activeUserId &&
                                      globalData.activeUserId.isNotEmpty) ||
                                  (comm['author']?.toString() ==
                                          globalData.userNickname.value &&
                                      globalData.userNickname.value.isNotEmpty)) ...[
                                const Spacer(),
                                GestureDetector(
                                  onTap: () async {
                                    final messenger = ScaffoldMessenger.of(context);
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (dCtx) => AlertDialog(
                                        title: const Text('댓글을 삭제할까요?'),
                                        content: const Text(
                                            '삭제된 댓글은 복구할 수 없습니다.'),
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
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true && mounted) {
                                      final cId = comm['id']?.toString();
                                      if (_canUseFirestore &&
                                          cId != null &&
                                          !cId.startsWith('local_') &&
                                          postId != null) {
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection('community_posts')
                                              .doc(postId)
                                              .collection('comments')
                                              .doc(cId)
                                              .delete();
                                          await FirebaseFirestore.instance
                                              .collection('community_posts')
                                              .doc(postId)
                                              .update({
                                            'comments':
                                                FieldValue.increment(-1)
                                          });
                                        } catch (_) {}
                                      }
                                      setState(() {
                                        _comments.removeWhere(
                                            (item) => item['id'] == cId);
                                        widget.post['commentList'] = _comments;
                                        widget.post['comments'] =
                                            _comments.length;
                                      });
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text('댓글이 삭제되었습니다.'),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4),
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: OomuTokens.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (comm['content'] ?? comm['text'] ?? '').toString(),
                            style: const TextStyle(
                              fontSize: OomuTokens.fs14,
                              height: 1.45,
                              color: OomuTokens.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Comment like button
                    Tooltip(
                      message: '댓글 좋아요',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(OomuTokens.r12),
                        onTap: () async {
                          final myId = FirebaseAuth.instance.currentUser?.uid ??
                              (globalData.activeUserId.isNotEmpty
                                  ? globalData.activeUserId
                                  : 'user_me');
                          List<dynamic> likedUsers =
                              List<dynamic>.from(comm['likedUserIds'] ?? []);
                          bool currentlyLiked = likedUsers.contains(myId) ||
                              likedUsers.contains('user_me_01');
                          if (currentlyLiked) {
                            likedUsers.remove(myId);
                            likedUsers.remove('user_me_01');
                          } else {
                            likedUsers.add(myId);
                          }
                          setState(() {
                            comm['isLiked'] = !currentlyLiked;
                            comm['likes'] = likedUsers.length;
                            comm['likedUserIds'] = likedUsers;
                          });

                          if (_canUseFirestore &&
                              commId != null &&
                              !commId.startsWith('local_') &&
                              postId != null) {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('community_posts')
                                  .doc(postId)
                                  .collection('comments')
                                  .doc(commId)
                                  .set({
                                'likedUserIds': likedUsers,
                                'likes': likedUsers.length,
                              }, SetOptions(merge: true));
                            } catch (_) {}
                          }
                        },
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isCommLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 17,
                                color: isCommLiked
                                    ? OomuTokens.coral
                                    : OomuTokens.textSecondary,
                              ),
                              if (commLikes > 0) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '$commLikes',
                                  style: const TextStyle(
                                    fontSize: OomuTokens.fs12,
                                    fontWeight: OomuTokens.w600,
                                    color: OomuTokens.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final author = (post['author'] ?? '동네주민').toString();
    final category = (post['category'] ?? '동네 토크').toString();
    final title = (post['title'] ?? '').toString();
    final postId = _postId;

    return Scaffold(
      backgroundColor: OomuTokens.background,
      appBar: AppBar(
        backgroundColor: OomuTokens.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: '뒤로가기',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: OomuTokens.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          category,
          style: const TextStyle(
            color: OomuTokens.textPrimary,
            fontSize: OomuTokens.fs16,
            fontWeight: OomuTokens.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: '게시글 더보기',
            icon: const Icon(
              Icons.more_vert,
              color: OomuTokens.textPrimary,
            ),
            onPressed: () {
              final myUid = globalData.activeUserId;
              final myNick = globalData.userNickname.value;
              final postAuthor = (post['author'] ?? '').toString();
              final postAuthorId = (post['authorId'] ?? '').toString();
              final isMyPost = (myUid.isNotEmpty && postAuthorId == myUid) ||
                  (myNick.isNotEmpty && postAuthor == myNick);

              if (isMyPost) {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (bCtx) => Container(
                    decoration: const BoxDecoration(
                      color: OomuTokens.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(OomuTokens.r24),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: OomuTokens.s20,
                      horizontal: OomuTokens.s16,
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: OomuTokens.border,
                              borderRadius: BorderRadius.circular(OomuTokens.r8),
                            ),
                          ),
                          const SizedBox(height: OomuTokens.s16),
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                            title: const Text(
                              '게시글 삭제하기',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: const Text(
                              '이 게시글과 모든 댓글을 완전히 삭제합니다',
                              style: TextStyle(
                                fontSize: OomuTokens.fs12,
                                color: OomuTokens.textMuted,
                              ),
                            ),
                            onTap: () async {
                              final navigator = Navigator.of(context);
                              final messenger = ScaffoldMessenger.of(context);
                              Navigator.pop(bCtx);
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (dCtx) => AlertDialog(
                                  title: const Text('게시글을 삭제할까요?'),
                                  content: const Text(
                                      '삭제된 게시글은 다시 복구할 수 없습니다.'),
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
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true && mounted) {
                                if (_canUseFirestore && postId != null) {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('community_posts')
                                        .doc(postId)
                                        .delete();
                                  } catch (_) {}
                                }
                                navigator.pop({'deleted': true, 'id': postId});
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('게시글이 삭제되었습니다.'),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                UgcActionSheets.showContentOptions(
                  context: context,
                  contentType: '게시글',
                  contentId: (post['id'] ?? title).toString(),
                  author: author,
                  onContentHidden: () => Navigator.pop(context),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: (_canUseFirestore && postId != null)
                ? StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('community_posts')
                        .doc(postId)
                        .collection('comments')
                        .snapshots(),
                    builder: (context, commentSnap) {
                      final displayComments =
                          _resolveDisplayComments(commentSnap);
                      return _buildBodyContent(displayComments);
                    },
                  )
                : _buildBodyContent(_resolveDisplayComments(null)),
          ),

          // Comment Input Field at Bottom (전송 버튼 48x48dp 터치 영역 보장)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: OomuTokens.s16,
              vertical: OomuTokens.s8,
            ),
            decoration: const BoxDecoration(
              color: OomuTokens.surface,
              border: Border(
                top: BorderSide(color: OomuTokens.border),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(
                        horizontal: OomuTokens.s12,
                      ),
                      decoration: BoxDecoration(
                        color: OomuTokens.surfaceMuted,
                        borderRadius: BorderRadius.circular(OomuTokens.r12),
                        border: Border.all(color: OomuTokens.border),
                      ),
                      child: Center(
                        child: TextField(
                          controller: _commentController,
                          style: const TextStyle(
                            fontSize: OomuTokens.fs14,
                            color: OomuTokens.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            hintText: '이웃들과 나눌 따뜻한 댓글을 입력하세요...',
                            hintStyle: TextStyle(
                              color: OomuTokens.textMuted,
                              fontSize: OomuTokens.fs14,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (_) => _addComment(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: OomuTokens.s8),
                  Tooltip(
                    message: '댓글 전송',
                    child: BouncyTap(
                      scaleDown: 0.88,
                      onHaptic: OomuHaptics.medium,
                      onTap: _isSubmittingComment ? null : _addComment,
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: _isSubmittingComment
                                ? OomuTokens.coral.withValues(alpha: 0.6)
                                : OomuTokens.coral,
                            borderRadius: BorderRadius.circular(OomuTokens.r12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.send_rounded,
                              color: OomuTokens.surface,
                              size: 19,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
