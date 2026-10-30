import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_image.dart';
import '../utils/global_data.dart';
import '../utils/oomu_ui_helpers.dart';
import '../widgets/ugc_action_sheets.dart';
import 'user_profile_screen.dart';
import '../widgets/bouncy_tap.dart';

class CommunityPostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  const CommunityPostDetailScreen({super.key, required this.post});

  @override
  State<CommunityPostDetailScreen> createState() => _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState extends State<CommunityPostDetailScreen> {
  final Color textPrimary = OomuUiHelpers.textPrimary;
  final Color textSecondary = OomuUiHelpers.textSecondary;
  final Color surfaceColor = OomuUiHelpers.backgroundNeutral;
  final Color coralAccent = OomuUiHelpers.brandCoral;

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
    _likeCount = (widget.post['likes'] is num) ? (widget.post['likes'] as num).toInt() : 0;
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
    if (oldWidget.post != widget.post || oldWidget.post['id'] != widget.post['id']) {
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

    final myNick = globalData.userNickname.value.isNotEmpty ? globalData.userNickname.value : '우리동네민우';
    final myAvatar = globalData.userAvatar.value.isNotEmpty ? globalData.userAvatar.value : 'assets/images/kr_male_1.jpg';
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

    _commentController.clear();
    FocusScope.of(context).unfocus();

    setState(() {
      _comments.add(newComm);
      widget.post['commentList'] = _comments;
      widget.post['comments'] = _comments.length;
    });

    if (_canUseFirestore && postId != null) {
      try {
        final firestorePayload = <String, dynamic>{
          'author': myNick,
          'authorAvatar': myAvatar,
          'content': text,
          'time': '방금 전',
          'likes': 0,
          'likedUserIds': <String>[],
          'createdAt': FieldValue.serverTimestamp(),
        };

        final docRef = await FirebaseFirestore.instance
            .collection('community_posts')
            .doc(postId)
            .collection('comments')
            .add(firestorePayload)
            .timeout(const Duration(seconds: 4));

        newComm['id'] = docRef.id;

        final countSnap = await FirebaseFirestore.instance
            .collection('community_posts')
            .doc(postId)
            .collection('comments')
            .count()
            .get()
            .timeout(const Duration(seconds: 4));
        final totalComments = countSnap.count ?? _comments.length;

        // 원본 게시글의 제목·작성자·지역 등 다른 필드를 임의 기본값으로 덮어쓰지 않고 댓글 수만 갱신
        await FirebaseFirestore.instance
            .collection('community_posts')
            .doc(postId)
            .set({
          'comments': totalComments,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)).timeout(const Duration(seconds: 4));

        if (mounted) {
          setState(() {
            widget.post['comments'] = totalComments;
          });
        }
      } catch (e) {
        debugPrint('Firestore add comment fallback to local state: $e');
      }
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
      final myUserId = globalData.activeUserId;
      List<dynamic> likedUsers = List<dynamic>.from(widget.post['likedUserIds'] ?? []);
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

  List<Map<String, dynamic>> _resolveDisplayComments(AsyncSnapshot<QuerySnapshot>? commentSnap) {
    if (commentSnap != null && commentSnap.hasData && commentSnap.data!.docs.isNotEmpty) {
      final docs = commentSnap.data!.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data() as Map<String, dynamic>);
        data['id'] = d.id;
        final likedUsers = List<dynamic>.from(data['likedUserIds'] ?? []);
        final currentUid = globalData.activeUserId;
        data['isLiked'] = likedUsers.contains(currentUid) || likedUsers.contains('user_me_01');
        data['likes'] = likedUsers.isNotEmpty ? likedUsers.length : (data['likes'] ?? 0);
        return data;
      }).toList();
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
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Main Post Content Card
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                            userAvatar: post['authorAvatar']?.toString(),
                            userLocation: location,
                            userManner: authorManner,
                          ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: appImg((post['authorAvatar'] ?? 'assets/images/kr_female_1.jpg').toString()),
                    ),
                  ),
                  const SizedBox(width: 10),
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
                                        userAvatar: post['authorAvatar']?.toString(),
                                        userLocation: location,
                                        userManner: authorManner,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  author,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: OomuUiHelpers.mannerTempBgColor(authorManner),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  OomuUiHelpers.formatMannerTemp(authorManner),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: OomuUiHelpers.mannerTempColor(authorManner),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$location · $time',
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (tag != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFC83243)),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Title (이모지 안전한 줄바꿈 & 선명한 타이포그래피 계층)
              if (title.isNotEmpty) ...[
                Text(
                  OomuUiHelpers.formatTitle(title, fallback: ''),
                  style: const TextStyle(
                    fontSize: 18.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF19181B),
                    height: 1.35,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Body Text (가독성 높은 차콜 그레이 & 쾌적한 줄간격)
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  height: 1.65,
                  color: Color(0xFF4A4446),
                  letterSpacing: -0.15,
                ),
              ),

              // Attached Photo
              if (image != null && image.toString().isNotEmpty) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 340),
                    child: SizedBox(
                      width: double.infinity,
                      child: Image(
                        image: appImg(image.toString()),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 160,
                          color: const Color(0xFFF3EAEB),
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Interaction Row (상단 댓글 수와 하단 댓글 수 단일 상태 연동 & 48x48dp 터치 영역)
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Tooltip(
                          message: '게시글 좋아요',
                          child: BouncyTap(
                            scaleDown: 0.90,
                            onHaptic: OomuHaptics.light,
                            onTap: _toggleLike,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      size: 19,
                                      color: _isLiked ? coralAccent : textSecondary,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '좋아요 $_likeCount',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: _isLiked ? coralAccent : textSecondary,
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
                              Icon(Icons.chat_bubble_outline_rounded, size: 18, color: textSecondary),
                              const SizedBox(width: 5),
                              Text(
                                '댓글 ${displayComments.length}',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: '게시글 공유',
                    icon: Icon(Icons.share_outlined, size: 19, color: textSecondary),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('게시글 링크가 클립보드에 복사되었습니다!')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Comments Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Row(
            children: [
              Text(
                '댓글 ${displayComments.length}',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: textPrimary),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '실시간 동네 주민 토크',
                  style: TextStyle(fontSize: 12, color: textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Comments Empty State or List
        if (displayComments.isEmpty)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.chat_bubble_outline_rounded, size: 28, color: textSecondary.withOpacity(0.5)),
                const SizedBox(height: 8),
                Text(
                  '첫 댓글을 남겨보세요',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '동네 이웃과 따뜻한 대화를 시작해 보세요 💬',
                  style: TextStyle(fontSize: 12.5, color: textSecondary),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayComments.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3EAEB)),
            itemBuilder: (context, index) {
              final comm = displayComments[index];
              final isCommLiked = comm['isLiked'] == true;
              final commLikes = (comm['likes'] is num) ? (comm['likes'] as num).toInt() : 0;
              final commId = comm['id']?.toString();

              return Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfileScreen(
                              userName: (comm['author'] ?? '이웃').toString(),
                              userAvatar: comm['authorAvatar']?.toString(),
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 16,
                        backgroundImage: appImg((comm['authorAvatar'] ?? 'assets/images/kr_female_1.jpg').toString()),
                      ),
                    ),
                    const SizedBox(width: 10),
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
                                          userName: (comm['author'] ?? '이웃').toString(),
                                          userAvatar: comm['authorAvatar']?.toString(),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    (comm['author'] ?? '이웃').toString(),
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                (comm['time'] ?? '방금').toString(),
                                style: TextStyle(fontSize: 12, color: textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (comm['content'] ?? comm['text'] ?? '').toString(),
                            style: TextStyle(fontSize: 14, height: 1.45, color: textPrimary),
                          ),
                        ],
                      ),
                    ),
                    // Comment like button (최소 48x48dp 터치 영역 보장)
                    Tooltip(
                      message: '댓글 좋아요',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          final myId = globalData.activeUserId;
                          List<dynamic> likedUsers = List<dynamic>.from(comm['likedUserIds'] ?? []);
                          bool currentlyLiked = likedUsers.contains(myId) || likedUsers.contains('user_me_01');
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

                          if (_canUseFirestore && commId != null && !commId.startsWith('local_') && postId != null) {
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
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isCommLiked ? Icons.favorite : Icons.favorite_border,
                                size: 17,
                                color: isCommLiked ? coralAccent : textSecondary,
                              ),
                              if (commLikes > 0) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '$commLikes',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
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
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: '뒤로가기',
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          category,
          style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: '게시글 더보기',
            icon: Icon(Icons.more_vert, color: textPrimary),
            onPressed: () {
              UgcActionSheets.showContentOptions(
                context: context,
                contentType: '게시글',
                contentId: (post['id'] ?? title).toString(),
                author: author,
                onContentHidden: () => Navigator.pop(context),
              );
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
                        .orderBy('createdAt', descending: false)
                        .snapshots(),
                    builder: (context, commentSnap) {
                      final displayComments = _resolveDisplayComments(commentSnap);
                      return _buildBodyContent(displayComments);
                    },
                  )
                : _buildBodyContent(_resolveDisplayComments(null)),
          ),

          // Comment Input Field at Bottom (전송 버튼 48x48dp 터치 영역 보장)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFEFE4E6)),
                      ),
                      child: TextField(
                        controller: _commentController,
                        style: TextStyle(fontSize: 14, color: textPrimary),
                        decoration: InputDecoration(
                          hintText: '이웃들과 나눌 따뜻한 댓글을 입력하세요...',
                          hintStyle: TextStyle(color: textSecondary, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: (_) => _addComment(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                            color: _isSubmittingComment ? coralAccent.withOpacity(0.6) : coralAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.send_rounded, color: Colors.white, size: 19),
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
