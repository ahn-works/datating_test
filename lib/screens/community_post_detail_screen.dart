import 'user_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/app_image.dart';
import '../utils/global_data.dart';
import '../widgets/ugc_action_sheets.dart';
import 'soso_car_host_screen.dart';

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

  @override
  void initState() {
    super.initState();
    final String myUserId = globalData.userNickname.value.isNotEmpty ? globalData.userNickname.value : 'test_user_1';
    final List<String> likedUsers = List<String>.from(widget.post['likedUserIds'] ?? []);
    _isLiked = likedUsers.contains(myUserId) || (widget.post['isLiked'] ?? false);
    _likeCount = likedUsers.isNotEmpty ? likedUsers.length : (widget.post['likes'] ?? 0);

    _comments = [
      {
        'id': 'comm_01',
        'author': '이준호',
        'authorAvatar': 'assets/images/kr_male_1.jpg',
        'content': '성수동에서도 맛집 찾고 있었는데 서교동 가면 꼭 들러봐야겠네요!',
        'time': '10분 전',
        'likes': 2,
        'isLiked': false,
      },
      {
        'id': 'comm_02',
        'author': '박지연',
        'authorAvatar': 'assets/images/kr_female_2.jpg',
        'content': '저 이번 주말에 시간 되는데 같이 디저트 뿌시러 가실 분!',
        'time': '25분 전',
        'likes': 3,
        'isLiked': false,
      },
    ];

    final String postId = widget.post['id']?.toString() ?? widget.post['title']?.toString() ?? 'post_default';
    try {
      FirebaseFirestore.instance
          .collection('community_posts')
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: false)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty && mounted) {
          setState(() {
            _comments = snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'author': data['author'] ?? '이웃',
                'authorAvatar': data['authorAvatar'] ?? 'assets/images/kr_female_1.jpg',
                'content': data['content'] ?? '',
                'time': data['time'] ?? '방금',
                'likes': data['likes'] ?? 0,
                'isLiked': false,
              };
            }).toList();
            widget.post['comments'] = _comments.length;
          });
        }
      });
    } catch (_) {}
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final myNick = globalData.userNickname.value.isNotEmpty ? globalData.userNickname.value : '우리동네민우';
    final myAvatar = globalData.userAvatar.value.isNotEmpty ? globalData.userAvatar.value : 'assets/images/kr_female_1.jpg';
    final myLocation = globalData.userLocation.value.isNotEmpty ? globalData.userLocation.value : '마포구 서교동';

    final newComment = {
      'id': 'comm_${DateTime.now().millisecondsSinceEpoch}',
      'author': myNick,
      'authorAvatar': myAvatar,
      'content': text,
      'location': myLocation,
      'time': '방금 전',
      'likes': 0,
      'isLiked': false,
      'createdAt': FieldValue.serverTimestamp(),
    };

    setState(() {
      _comments.add(newComment);
      widget.post['comments'] = _comments.length;
    });

    final String postId = widget.post['id']?.toString() ?? widget.post['title']?.toString() ?? 'post_default';
    try {
      final postRef = FirebaseFirestore.instance.collection('community_posts').doc(postId);
      postRef.collection('comments').add(newComment);
      postRef.update({'comments': FieldValue.increment(1)});
    } catch (e) {
      debugPrint('[PostDetail] Firestore comment error: $e');
    }

    _commentController.clear();
    FocusScope.of(context).unfocus();

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
    final String myUserId = globalData.userNickname.value.isNotEmpty ? globalData.userNickname.value : 'test_user_1';
    final List<String> likedUsers = List<String>.from(widget.post['likedUserIds'] ?? []);
    final bool currentlyLiked = likedUsers.contains(myUserId);

    if (currentlyLiked) {
      likedUsers.remove(myUserId);
    } else {
      likedUsers.add(myUserId);
    }

    final int newCount = likedUsers.length;
    setState(() {
      _isLiked = !currentlyLiked;
      _likeCount = newCount;
      widget.post['likedUserIds'] = likedUsers;
      widget.post['isLiked'] = !currentlyLiked;
      widget.post['likes'] = newCount;
    });

    final String postId = widget.post['id']?.toString() ?? widget.post['title']?.toString() ?? 'post_default';
    try {
      final docRef = FirebaseFirestore.instance.collection('community_posts').doc(postId);
      docRef.update({
        'likedUserIds': currentlyLiked
            ? FieldValue.arrayRemove([myUserId])
            : FieldValue.arrayUnion([myUserId]),
        'likes': newCount,
      });
    } catch (e) {
      debugPrint('[PostDetail] Firestore like error: $e');
    }
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
    final related = post['relatedMeetup'] as Map<String, dynamic>?;

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
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen(userName: author))),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: appImg(post['authorAvatar'] ?? 'assets/images/kr_female_1.jpg'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen(userName: author))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        author,
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPrimary),
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

                      // Related Meetup CTA Card
                      if (related != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFF8C6CD)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: coralAccent.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.bolt, color: coralAccent, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '이 이야기와 연관된 모임 만들기',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: coralAccent),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      related['title'] ?? '동네 모임 같이 가실 분!',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OOMUHostScreen(
                                        initialTitle: related['title'],
                                        initialLocation: related['location'] ?? location,
                                        initialMainCategory: related['category'] ?? category,
                                        initialCoverImageUrl: related['poster'],
                                        initialVibe: '놀줄아는',
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: coralAccent,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('모임 개설', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Comments Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        '댓글 ${_comments.length}',
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
                  itemCount: _comments.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3EAEB)),
                  itemBuilder: (context, index) {
                    final comm = _comments[index];
                    final isCommLiked = comm['isLiked'] ?? false;
                    final commLikes = comm['likes'] ?? 0;

                    return Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: appImg(comm['authorAvatar'] ?? 'assets/images/kr_female_1.jpg'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      comm['author'] ?? '이웃',
                                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: textPrimary),
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
                          // Comment like button
                          InkWell(
                            onTap: () {
                              setState(() {
                                comm['isLiked'] = !isCommLiked;
                                comm['likes'] = commLikes + (!isCommLiked ? 1 : -1);
                              });
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
                                  if (comm['likes'] > 0)
                                    Text(
                                      '${comm['likes']}',
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
