import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_image.dart';
import '../utils/global_data.dart';
import '../widgets/ugc_action_sheets.dart';
import 'soso_car_host_screen.dart';
import 'user_profile_screen.dart';

class CommunityPostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  const CommunityPostDetailScreen({super.key, required this.post});

  @override
  State<CommunityPostDetailScreen> createState() => _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState extends State<CommunityPostDetailScreen> {
  final Color textPrimary = const Color(0xFF221B1D);
  final Color textSecondary = const Color(0xFF635559);
  final Color surfaceColor = const Color(0xFFFAF6F7);
  final Color coralAccent = const Color(0xFFF25767);

  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late bool _isLiked;
  late int _likeCount;

  late List<Map<String, dynamic>> _comments;

  static final List<Map<String, dynamic>> _initialDummyComments = [
    {
      'id': 'comm_01',
      'author': '공연러버',
      'authorAvatar': 'assets/images/kr_female_2.jpg',
      'content': '저도 1차 티켓팅 성공해서 갑니다! 후기 보니까 8열 시야 진짜 기대되네요 ㅎㅎ',
      'time': '10분 전',
      'likes': 3,
      'likedUserIds': ['dummy_u1', 'dummy_u2', 'dummy_u3'],
    },
    {
      'id': 'comm_02',
      'author': '성수동산책러',
      'authorAvatar': 'assets/images/kr_male_1.jpg',
      'content': '혹시 캐스팅 누구 회차로 예매하셨나요? 이번 시즌 전원 레전드라 고민되네요!',
      'time': '25분 전',
      'likes': 2,
      'likedUserIds': ['dummy_u4', 'dummy_u5'],
    },
    {
      'id': 'comm_03',
      'author': '달콤빵순이',
      'authorAvatar': 'assets/images/kr_female_3.jpg',
      'content': '공연 끝나고 근처 감성 카페에서 극 얘기 나누는 모임 열어주시면 무조건 참석할게요!',
      'time': '1시간 전',
      'likes': 5,
      'likedUserIds': ['dummy_u1', 'dummy_u2', 'dummy_u6', 'dummy_u7', 'dummy_u8'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post['isLiked'] ?? false;
    _likeCount = widget.post['likes'] ?? 0;

    _comments = List<Map<String, dynamic>>.from(_initialDummyComments);
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final myNick = globalData.userNickname.value.isNotEmpty ? globalData.userNickname.value : '우리동네민우';
    final myAvatar = globalData.userAvatar.value.isNotEmpty ? globalData.userAvatar.value : 'assets/images/kr_male_1.jpg';
    final postId = widget.post['id']?.toString() ?? 'post_01';

    final newComm = {
      'author': myNick,
      'authorAvatar': myAvatar,
      'content': text,
      'time': '방금 전',
      'likes': 0,
      'likedUserIds': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    };

    setState(() {
      _comments.add(newComm);
      widget.post['comments'] = _comments.length;
    });

    _commentController.clear();
    FocusScope.of(context).unfocus();

    try {
      // 1. Ensure the parent post doc exists in Firestore
      await FirebaseFirestore.instance.collection('community_posts').doc(postId).set({
        'id': postId,
        'title': widget.post['title'] ?? '동네 소식',
        'content': widget.post['content'] ?? '',
        'author': widget.post['author'] ?? '동네주민',
        'authorAvatar': widget.post['authorAvatar'] ?? myAvatar,
        'location': widget.post['location'] ?? '마포구 서교동',
        'category': widget.post['category'] ?? '동네 토크',
        'tag': widget.post['tag'] ?? '일상',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. If this post's comments subcollection is empty, seed initial dummy comments
      final existingDocs = await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(postId)
          .collection('comments')
          .limit(1)
          .get();

      if (existingDocs.docs.isEmpty) {
        for (var c in _initialDummyComments) {
          await FirebaseFirestore.instance
              .collection('community_posts')
              .doc(postId)
              .collection('comments')
              .add({
            'author': c['author'],
            'authorAvatar': c['authorAvatar'],
            'content': c['content'],
            'time': c['time'],
            'likes': c['likes'] ?? 0,
            'likedUserIds': c['likedUserIds'] ?? <String>[],
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // 3. Add the new comment
      await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(postId)
          .collection('comments')
          .add(newComm);

      // 4. Update the total comments count
      final countSnap = await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(postId)
          .collection('comments')
          .count()
          .get();
      final totalComments = countSnap.count ?? _comments.length;

      await FirebaseFirestore.instance.collection('community_posts').doc(postId).set({
        'comments': totalComments,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          widget.post['comments'] = totalComments;
        });
      }
    } catch (e) {
      debugPrint('Firestore add comment error: $e');
    }

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

      final postId = widget.post['id']?.toString();
      if (postId != null && postId.isNotEmpty) {
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

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final author = post['author'] ?? '동네주민';
    final location = post['location'] ?? '마포구 서교동';
    final time = post['time'] ?? '방금 전';
    final manner = post['manner'] ?? 42.0;
    final tag = post['tag'];
    final category = post['category'] ?? '동네 토크';
    final title = post['title'] ?? '';
    final content = post['content'] ?? '';
    final image = post['image'];

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          category,
          style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: textPrimary),
            onPressed: () {
              UgcActionSheets.showContentOptions(
                context: context,
                contentType: '게시글',
                contentId: post['id'] ?? title,
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
            child: ListView(
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
                                    userAvatar: post['authorAvatar'],
                                    userLocation: location,
                                    userManner: manner is num ? (manner as num).toDouble() : 37.0,
                                  ),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: appImg(post['authorAvatar'] ?? 'assets/images/kr_female_1.jpg'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => UserProfileScreen(
                                              userName: author,
                                              userAvatar: post['authorAvatar'],
                                              userLocation: location,
                                              userManner: manner is num ? (manner as num).toDouble() : 37.0,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        author,
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPrimary),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF0F2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '$manner°C',
                                        style: TextStyle(color: coralAccent, fontSize: 10.5, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$location · $time',
                                  style: TextStyle(fontSize: 11.5, color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                          if (tag != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3EAEB),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '#$tag',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: coralAccent),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Title
                      if (title.isNotEmpty) ...[
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Body Text
                      Text(
                        content,
                        style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.55,
                          color: Color(0xFF2B2B2B),
                        ),
                      ),

                      // Attached Photo
                      if (image != null && (image as String).isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 340),
                            child: SizedBox(
                              width: double.infinity,
                              child: Image(
                                image: appImg(image),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 160,
                                  color: const Color(0xFFF2F2F5),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),

                      // Interaction Row
                      Row(
                        children: [
                          InkWell(
                            onTap: _toggleLike,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              child: Row(
                                children: [
                                  Icon(
                                    _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    size: 19,
                                    color: _isLiked ? const Color(0xFFFF3B30) : textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '좋아요 $_likeCount',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: _isLiked ? const Color(0xFFFF3B30) : textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Row(
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded, size: 18, color: textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                '댓글 ${_comments.length}',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: textSecondary),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Share
                          IconButton(
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

                // Comments StreamBuilder from Firestore
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('community_posts')
                      .doc(widget.post['id']?.toString() ?? 'post_01')
                      .collection('comments')
                      .orderBy('createdAt', descending: false)
                      .snapshots(),
                  builder: (context, commentSnap) {
                    List<Map<String, dynamic>> displayComments = [];
                    if (commentSnap.hasData && commentSnap.data!.docs.isNotEmpty) {
                      displayComments = commentSnap.data!.docs.map((d) {
                        final data = Map<String, dynamic>.from(d.data() as Map<String, dynamic>);
                        data['id'] = d.id;
                        final likedUsers = List<dynamic>.from(data['likedUserIds'] ?? []);
                        final currentUid = globalData.activeUserId;
                        data['isLiked'] = likedUsers.contains(currentUid) || likedUsers.contains('user_me_01');
                        data['likes'] = likedUsers.isNotEmpty ? likedUsers.length : (data['likes'] ?? 0);
                        return data;
                      }).toList();
                    } else {
                      displayComments = List<Map<String, dynamic>>.from(_comments);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Comments Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                          child: Row(
                            children: [
                              Text(
                                '댓글 ${displayComments.length}',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPrimary),
                              ),
                              const SizedBox(width: 6),
                              Text('실시간 동네 주민 토크', style: TextStyle(fontSize: 11.5, color: textSecondary)),
                            ],
                          ),
                        ),

                        // Comments List
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayComments.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3EAEB)),
                          itemBuilder: (context, index) {
                            final comm = displayComments[index];
                            final isCommLiked = comm['isLiked'] ?? false;
                            final commLikes = comm['likes'] ?? 0;
                            final commId = comm['id']?.toString();
                            final postId = widget.post['id']?.toString() ?? 'post_01';

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
                                            userName: comm['author'] ?? '이웃',
                                            userAvatar: comm['authorAvatar'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundImage: appImg(comm['authorAvatar'] ?? 'assets/images/kr_female_1.jpg'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => UserProfileScreen(
                                                      userName: comm['author'] ?? '이웃',
                                                      userAvatar: comm['authorAvatar'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                comm['author'] ?? '이웃',
                                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: textPrimary),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              comm['time'] ?? '방금',
                                              style: TextStyle(fontSize: 10.5, color: textSecondary),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          comm['content'] ?? '',
                                          style: const TextStyle(fontSize: 13, height: 1.35, color: Color(0xFF333333)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Comment like button with Firestore sync
                                  InkWell(
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

                                      if (commId != null && postId.isNotEmpty) {
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
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Column(
                                        children: [
                                          Icon(
                                            isCommLiked ? Icons.favorite : Icons.favorite_border,
                                            size: 14,
                                            color: isCommLiked ? const Color(0xFFFF3B30) : textSecondary,
                                          ),
                                          if (commLikes > 0)
                                            Text(
                                              '$commLikes',
                                              style: TextStyle(fontSize: 10, color: textSecondary),
                                            ),
                                        ],
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
                  },
                ),
              ],
            ),
          ),

          // Comment Input Field at Bottom
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
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFEFE4E6)),
                      ),
                      child: TextField(
                        controller: _commentController,
                        style: TextStyle(fontSize: 13.5, color: textPrimary),
                        decoration: InputDecoration(
                          hintText: '이웃들과 나눌 따뜻한 댓글을 입력하세요...',
                          hintStyle: TextStyle(color: textSecondary, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _addComment(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _addComment,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: coralAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
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
