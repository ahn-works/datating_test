import 'dart:async';
import '../services/community_like_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../ui/oomu_avatar.dart';
import '../ui/oomu_empty_state.dart';
import '../ui/oomu_tag.dart';
import '../ui/oomu_tokens.dart';
import '../utils/app_image.dart';
import '../utils/firestore_time.dart';
import '../utils/global_data.dart';
import '../utils/oomu_ui_helpers.dart';
import '../widgets/balanced_heading.dart';
import '../widgets/balanced_text.dart';
import '../widgets/bouncy_tap.dart';
import '../widgets/ugc_action_sheets.dart';
import 'chat/chat_modals.dart';
import 'user_profile_screen.dart';

class CommunityPostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  final Future<void> Function(
      bool nextLiked, int nextCount, List<String> nextIds)? debugLikeWriter;

  const CommunityPostDetailScreen({
    super.key,
    required this.post,
    this.debugLikeWriter,
  });

  @override
  State<CommunityPostDetailScreen> createState() =>
      _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState extends State<CommunityPostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late bool _isLiked;
  late int _likeCount;
  bool _savingLike = false;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _postChanges;
  late List<Map<String, dynamic>> _comments;
  bool _isSubmittingComment = false;
  Map<String, dynamic>? _fetchedPost;
  bool _isLoadingDoc = false;
  bool _isNotFound = false;

  Map<String, dynamic> get _effectivePost => _fetchedPost ?? widget.post;

  String? get _postId {
    final raw = _effectivePost['id']?.toString().trim();
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
    final p = _effectivePost;
    final ids = p['likedUserIds'];
    _isLiked = Firebase.apps.isNotEmpty && ids is List
        ? ids.contains(FirebaseAuth.instance.currentUser?.uid)
        : p['isLiked'] == true;
    _likeCount = (p['likes'] is num) ? (p['likes'] as num).toInt() : 0;
    final rawList = p['commentList'];
    if (rawList is List) {
      _comments = rawList
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } else {
      _comments = <Map<String, dynamic>>[];
    }
    _syncPostComments();
  }

  void _syncPostComments([int? count]) {
    try {
      _effectivePost['commentList'] = _comments;
      _effectivePost['comments'] = count ?? _comments.length;
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    final p = widget.post;
    final pid = p['id']?.toString().trim() ?? p['docId']?.toString().trim();
    final bool hasContent = p['title'] != null || p['content'] != null;

    if (pid != null && pid.isNotEmpty && (Firebase.apps.isNotEmpty || !hasContent)) {
      _fetchPost(pid);
    } else {
      _initPostState();
    }
  }

  void _fetchPost(String docId) {
    _postChanges?.cancel();
    _isLoadingDoc = true;
    _isNotFound = false;
    void unavailable() {
      if (mounted) setState(() { _isLoadingDoc = false; _isNotFound = true; });
    }
    if (Firebase.apps.isEmpty) { unavailable(); return; }
    _postChanges = FirebaseFirestore.instance.collection('community_posts').doc(docId).snapshots().listen((doc) {
      if (!mounted) return;
      final data = doc.data();
      if (data == null) { unavailable(); return; }
      setState(() {
        _fetchedPost = {...data, 'id': doc.id};
        _isLoadingDoc = false;
        _isNotFound = false;
        _initPostState();
      });
    }, onError: (Object e) { debugPrint('게시글 조회 실패: $e'); unavailable(); });
  }

  @override
  void didUpdateWidget(covariant CommunityPostDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post != widget.post ||
        oldWidget.post['id'] != widget.post['id']) {
      _postChanges?.cancel();
      _isSubmittingComment = false;
      _commentController.clear();
      final p = widget.post;
      final pid = p['id']?.toString().trim() ?? p['docId']?.toString().trim();
      final bool hasContent = p['title'] != null || p['content'] != null;
      if (pid != null && pid.isNotEmpty && (Firebase.apps.isNotEmpty || !hasContent)) {
        _fetchPost(pid);
      } else {
        _fetchedPost = null;
        _isLoadingDoc = false;
        _isNotFound = false;
        _initPostState();
      }
    }
  }

  @override
  void dispose() {
    _postChanges?.cancel();
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    if (_isSubmittingComment) return;
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글 내용을 입력해 주세요.')),
      );
      return;
    }

    setState(() {
      _isSubmittingComment = true;
    });

    final myNick = globalData.userNickname.value.isNotEmpty
        ? globalData.userNickname.value
        : '이웃';
    final myAvatar = globalData.userAvatar.value;
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
      final authorUid = FirebaseAuth.instance.currentUser?.uid;
      if (authorUid == null) throw StateError('로그인 후 댓글을 남겨주세요.');
      final postRef = db.collection('community_posts').doc(postId);
      final commentRef = postRef.collection('comments').doc();
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
        _syncPostComments();
      });
    } catch (e) {
      debugPrint('[CommunityPostDetailScreen] comment save error: $e');
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

  Future<void> _addCommentWithSticker(Map<String, dynamic> sticker) async {
    final stickerUrl = (sticker['imageUrl'] ?? '').toString();
    final title = (sticker['title'] ?? '움짤').toString();
    if (stickerUrl.isEmpty) return;

    final myNick = globalData.userNickname.value.isNotEmpty
        ? globalData.userNickname.value
        : '이웃';
    final myAvatar = globalData.userAvatar.value;
    final postId = _postId;

    final newComm = <String, dynamic>{
      'id': 'local_${DateTime.now().microsecondsSinceEpoch}',
      'author': myNick,
      'authorAvatar': myAvatar,
      'content': '$title 움짤',
      'imageUrl': stickerUrl,
      'time': '방금 전',
      'likes': 0,
      'isLiked': false,
      'likedUserIds': <String>[],
    };

    if (!_canUseFirestore || postId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('실제 게시글에서 댓글을 작성할 수 있어요.')));
      return;
    }

    try {
      final db = FirebaseFirestore.instance;
      final authorUid = FirebaseAuth.instance.currentUser?.uid;
      if (authorUid == null) throw StateError('로그인 후 댓글을 남겨주세요.');
      final postRef = db.collection('community_posts').doc(postId);
      final commentRef = postRef.collection('comments').doc();

      await commentRef.set({
        'authorId': authorUid,
        'author': myNick,
        'authorAvatar': myAvatar,
        'content': '$title 움짤',
        'imageUrl': stickerUrl,
        'time': '방금 전',
        'likes': 0,
        'likedUserIds': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      newComm['id'] = commentRef.id;
      setState(() {
        _comments.add(newComm);
        _syncPostComments();
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
        const SnackBar(content: Text('움짤 스티커 댓글이 등록되었습니다!')),
      );
    } catch (e) {
      debugPrint('[CommunityPostDetailScreen] sticker comment error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('스티커 댓글을 저장하지 못했어요.')),
        );
      }
    }
  }

  Future<void> _toggleLike() async {
    if (_savingLike) return;
    if (widget.debugLikeWriter == null && !_canUseFirestore) return;
    _savingLike = true;
    final prevLiked = _isLiked;
    final prevCount = _likeCount;
    final prevLikedUsers = (_effectivePost['likedUserIds'] is List)
        ? (_effectivePost['likedUserIds'] as List)
            .map((e) => e.toString())
            .toList()
        : <String>[];

    final myUserId = (Firebase.apps.isNotEmpty
            ? FirebaseAuth.instance.currentUser?.uid
            : null) ??
        (globalData.activeUserId.isNotEmpty
            ? globalData.activeUserId
            : 'user_me');

    final nextLiked = !prevLiked;
    final nextCount =
        nextLiked ? (prevCount + 1) : (prevCount > 0 ? prevCount - 1 : 0);
    final nextLikedUsers = List<String>.from(prevLikedUsers);
    if (nextLiked) {
      if (!nextLikedUsers.contains(myUserId)) {
        nextLikedUsers.add(myUserId);
      }
    } else {
      nextLikedUsers.remove(myUserId);
      nextLikedUsers.remove('user_me_01');
    }

    setState(() {
      _isLiked = nextLiked;
      _likeCount = nextCount;
      _effectivePost['likedUserIds'] = nextLikedUsers;
      _effectivePost['likes'] = nextCount;
      _effectivePost['isLiked'] = nextLiked;
    });

    try {
      if (widget.debugLikeWriter != null) {
        await widget.debugLikeWriter!(nextLiked, nextCount, nextLikedUsers);
        return;
      }
      final postId = _postId;
      if (_canUseFirestore && postId != null) {
        final ids = await setCommunityLike(postId, nextLiked);
        if (mounted && _postId == postId) setState(() {
          _likeCount = ids.length;
          _effectivePost['likedUserIds'] = ids;
          _effectivePost['likes'] = ids.length;
        });
      }
    } catch (e) {
      debugPrint('[CommunityPostDetailScreen] toggleLike error: $e');
      if (!mounted) return;
      setState(() {
        _isLiked = prevLiked;
        _likeCount = prevCount;
        _effectivePost['likedUserIds'] = prevLikedUsers;
        _effectivePost['likes'] = prevCount;
        _effectivePost['isLiked'] = prevLiked;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('좋아요를 저장하지 못했어요')),
      );
    } finally {
      _savingLike = false;
    }
  }

  String _formatRelativeTime(dynamic timeVal) {
    final dt = parseFirestoreDateTime(timeVal);
    if (dt == null) return '';

    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.isNegative) return '방금 전';
    if (diff.inSeconds < 60) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${dt.month}월 ${dt.day}일';
  }

  List<Map<String, dynamic>> _resolveDisplayComments(
      AsyncSnapshot<QuerySnapshot>? commentSnap) {
    if (commentSnap != null &&
        commentSnap.hasData) {
      final authUid = FirebaseAuth.instance.currentUser?.uid;
      final activeUid = globalData.activeUserId;

      final docs = commentSnap.data!.docs.map((d) {
        final data =
            Map<String, dynamic>.from(d.data() as Map<String, dynamic>);
        data['id'] = d.id;
        final likedUsers = List<dynamic>.from(data['likedUserIds'] ?? []);
        final bool isLiked =
            (authUid != null && likedUsers.contains(authUid)) ||
                (activeUid.isNotEmpty && likedUsers.contains(activeUid));
        data['isLiked'] = isLiked;
        data['likes'] =
            likedUsers.isNotEmpty ? likedUsers.length : (data['likes'] ?? 0);
        data['time'] = _formatRelativeTime(data['createdAt']);
        return data;
      }).toList();

      docs.sort((a, b) => compareFirestoreTimes(a['createdAt'], b['createdAt'],
          descending: false));

      final filteredDocs = docs.where((comment) {
        final author = (comment['author'] ?? '').toString();
        final authorUid = (comment['authorId'] ??
                comment['authorUid'] ??
                comment['userId'] ??
                comment['uid'] ??
                '')
            .toString();
        return !globalData.isTargetBlocked(uid: authorUid, nickname: author);
      }).toList();

      _syncPostComments(filteredDocs.length);
      return filteredDocs;
    }
    final filteredLocal = _comments.where((comment) {
      final author = (comment['author'] ?? '').toString();
      final authorUid = (comment['authorId'] ??
              comment['authorUid'] ??
              comment['userId'] ??
              comment['uid'] ??
              '')
          .toString();
      return !globalData.isTargetBlocked(uid: authorUid, nickname: author);
    }).toList();
    _syncPostComments(filteredLocal.length);
    return filteredLocal;
  }

  Widget _buildBodyContent(List<Map<String, dynamic>> displayComments) {
    final post = _effectivePost;
    final author = (post['author'] ?? '동네주민').toString();
    final isAuthorMe = author == globalData.userNickname.value ||
        (post['authorId'] != null &&
            post['authorId'] == globalData.activeUserId);
    final effectiveAuthorAvatar =
        (isAuthorMe && globalData.userAvatar.value.isNotEmpty)
            ? globalData.userAvatar.value
            : ((post['authorAvatar'] != null &&
                    post['authorAvatar'].toString().isNotEmpty)
                ? post['authorAvatar'].toString()
                : '');
    final location = (post['location'] ?? '').toString().trim();
    final rawTime = (post['time'] ?? '').toString().trim();
    // 저장된 'time' 글자("방금 전")는 시간이 지나도 바뀌지 않으므로 작성 시각을 먼저 쓴다.
    final createdAtTime = _formatRelativeTime(post['createdAt']);
    final time = createdAtTime.isNotEmpty ? createdAtTime : rawTime;
    final metaLine =
        [location, time].where((v) => v.trim().isNotEmpty).join(' · ');
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
                            userId: (post['authorId'] ??
                                    post['authorUid'] ??
                                    post['userId'] ??
                                    '')
                                .toString(),
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
                                        userId: (post['authorId'] ??
                                                post['authorUid'] ??
                                                post['userId'] ??
                                                '')
                                            .toString(),
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
                                label: OomuUiHelpers.formatMannerTemp(
                                    authorManner),
                              ),
                            ],
                          ],
                        ),
                        if (metaLine.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            metaLine,
                            style: const TextStyle(
                              fontSize: OomuTokens.fs12,
                              color: OomuTokens.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (tag != null && tag.toString().trim().isNotEmpty)
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

              // Body Text (어절 단위 줄바꿈: 표시 전용, 원문 불변)
              Text(
                BalancedText.display(content),
                style: const TextStyle(
                  fontSize: OomuTokens.fs14,
                  fontWeight: OomuTokens.w400,
                  height: 1.65,
                  color: OomuTokens.textBody,
                  letterSpacing: -0.15,
                ),
              ),

              // Attached Photo
              if (image != null && image.toString().trim().isNotEmpty) ...[
                const SizedBox(height: OomuTokens.s16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(OomuTokens.r16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 340),
                    child: SizedBox(
                      width: double.infinity,
                      child: appNetImage(
                        image.toString().trim(),
                        fit: BoxFit.cover,
                        fallback: '',
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
              subtitle: '동네 이웃과 대화를 시작해 보세요',
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
              final effectiveCommAvatar =
                  (isCommMe && globalData.userAvatar.value.isNotEmpty)
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
                              userId: (comm['authorId'] ??
                                      comm['authorUid'] ??
                                      comm['userId'] ??
                                      '')
                                  .toString(),
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
                                          userId: (comm['authorId'] ??
                                                  comm['authorUid'] ??
                                                  comm['userId'] ??
                                                  '')
                                              .toString(),
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
                                      globalData
                                          .userNickname.value.isNotEmpty)) ...[
                                const Spacer(),
                                GestureDetector(
                                  onTap: () async {
                                    final messenger =
                                        ScaffoldMessenger.of(context);
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (dCtx) => AlertDialog(
                                        title: const Text('댓글을 삭제할까요?'),
                                        content:
                                            const Text('삭제된 댓글은 복구할 수 없습니다.'),
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
                                        } catch (e) {
                                          debugPrint(
                                              '[CommunityPostDetailScreen] comment delete error: $e');
                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text('댓글을 삭제하지 못했어요.'),
                                            ),
                                          );
                                          return;
                                        }
                                      }
                                      setState(() {
                                        _comments.removeWhere(
                                            (item) => item['id'] == cId);
                                        _syncPostComments();
                                      });
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text('댓글이 삭제되었습니다.'),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4),
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
                          if ((comm['imageUrl'] ?? comm['stickerUrl']) !=
                                  null &&
                              (comm['imageUrl'] ?? comm['stickerUrl'])
                                  .toString()
                                  .isNotEmpty) ...[
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(OomuTokens.r12),
                              child: Container(
                                color: OomuTokens.surfaceMuted,
                                padding: const EdgeInsets.all(4),
                                child: appNetImage(
                                  (comm['imageUrl'] ?? comm['stickerUrl'])
                                      .toString(),
                                  width: 130,
                                  height: 130,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Comment like button
                    Tooltip(
                      message: '댓글 좋아요',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(OomuTokens.r12),
                        onTap: () async {
                          if (!_canUseFirestore || commId == null || postId == null) return;
                          try {
                            await setCommunityLike(postId, !isCommLiked, commentId: commId);
                          } catch (_) {
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('댓글 좋아요를 저장하지 못했어요.')));
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
    if (_isLoadingDoc) {
      return Scaffold(
        backgroundColor: OomuTokens.background,
        appBar: AppBar(
          backgroundColor: OomuTokens.surface,
          elevation: 0,
          leading: IconButton(
            tooltip: '뒤로가기',
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: OomuTokens.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('동네 이야기',
              style: TextStyle(
                  color: OomuTokens.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: OomuTokens.coral),
        ),
      );
    }

    if (_isNotFound) {
      return Scaffold(
        backgroundColor: OomuTokens.background,
        appBar: AppBar(
          backgroundColor: OomuTokens.surface,
          elevation: 0,
          leading: IconButton(
            tooltip: '뒤로가기',
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: OomuTokens.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('동네 이야기',
              style: TextStyle(
                  color: OomuTokens.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.article_outlined,
                  size: 64,
                  color: OomuTokens.textSecondary.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              const Text(
                '게시글을 찾을 수 없어요',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: OomuTokens.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                '삭제되었거나 존재하지 않는 게시글입니다.',
                style: TextStyle(fontSize: 14, color: OomuTokens.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final post = _effectivePost;
    final author = (post['author'] ?? '동네주민').toString();
    final authorUid = (post['authorId'] ??
            post['authorUid'] ??
            post['userId'] ??
            post['uid'] ??
            '')
        .toString();
    if (globalData.isTargetBlocked(uid: authorUid, nickname: author)) {
      return Scaffold(
        backgroundColor: OomuTokens.background,
        appBar: AppBar(
          backgroundColor: OomuTokens.surface,
          elevation: 0,
          leading: IconButton(
            tooltip: '뒤로가기',
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: OomuTokens.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('동네 이야기',
              style: TextStyle(
                  color: OomuTokens.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block_rounded,
                  size: 64, color: Colors.redAccent.withValues(alpha: 0.7)),
              const SizedBox(height: 16),
              const Text(
                '차단된 사용자의 게시글입니다.',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: OomuTokens.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                '차단 관리 메뉴에서 언제든지 차단을 해제할 수 있습니다.',
                style: TextStyle(fontSize: 14, color: OomuTokens.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

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
                              borderRadius:
                                  BorderRadius.circular(OomuTokens.r8),
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
                                  content:
                                      const Text('삭제된 게시글은 다시 복구할 수 없습니다.'),
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
                                    try {
                                      final authorUid =
                                          (_effectivePost['authorId'] ??
                                                  globalData.activeUserId)
                                              .toString();
                                      if (authorUid.isNotEmpty &&
                                          authorUid != 'guest') {
                                        final uRef = FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(authorUid);
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
                                          '[CommunityPostDetailScreen] myPostsCount decrement error: $cntErr');
                                    }
                                  } catch (e) {
                                    debugPrint(
                                        '[CommunityPostDetailScreen] post delete error: $e');
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('게시글을 삭제하지 못했어요.'),
                                      ),
                                    );
                                    return;
                                  }
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
                  authorId: authorUid.isNotEmpty ? authorUid : null,
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
                    message: '인기 움짤 스티커 첨부',
                    child: BouncyTap(
                      scaleDown: 0.88,
                      onHaptic: OomuHaptics.light,
                      onTap: () {
                        ChatModals.showStickerPicker(context,
                            onCreated: (sticker) {
                          _addCommentWithSticker(sticker);
                        });
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: OomuTokens.surfaceMuted,
                          borderRadius: BorderRadius.circular(OomuTokens.r12),
                          border: Border.all(color: OomuTokens.border),
                        ),
                        child: const Center(
                          // 반짝이(AI티) 대신 움짤 버튼 의미 그대로의 GIF 아이콘, 중립색
                          child: Icon(
                            Icons.gif_box_outlined,
                            color: OomuTokens.textSecondary,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: OomuTokens.s8),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _commentController,
                    builder: (context, val, _) {
                      final hasText = val.text.trim().isNotEmpty;
                      return Tooltip(
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
                                color: hasText
                                    ? OomuTokens.coral
                                    : OomuTokens.coral.withValues(alpha: 0.4),
                                borderRadius:
                                    BorderRadius.circular(OomuTokens.r12),
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
                      );
                    },
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
