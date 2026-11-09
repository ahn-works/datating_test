import 'dart:async';
import 'package:flutter/material.dart';
import '../services/chat_repository.dart';
import '../utils/app_image.dart';
import 'soso_car_chat_screen.dart';
import 'soso_car_home_screen.dart';

class ChatScreen extends StatefulWidget {
  final bool isEmbedded;
  final VoidCallback? onExplore;
  final ChatRepository? repository;
  const ChatScreen({
    super.key,
    this.isEmbedded = false,
    this.onExplore,
    this.repository,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // store_assets/OOMU 앱 UI 디자인.html (#chatlist) 컬러 토큰
  static const Color _bgCream = Color(0xFFFFF9F2);
  static const Color _textEspresso = Color(0xFF2B2118);
  static const Color _textMuted = Color(0xFF7D6F5E);
  static const Color _textFaint = Color(0xFFA99A87);
  static const Color _surfaceSearch = Color(0xFFF5EFE3);
  static const Color _borderWarm = Color(0xFFF3EADC);
  static const Color _primaryCoral = Color(0xFFFF5C39);
  static const Color _onlineTeal = Color(0xFF2FA98C);

  late final ChatRepository _repo;
  StreamSubscription<String?>? _session;
  Stream<List<ChatData>>? _rooms;
  String? _uid;
  int _generation = 0;
  String _search = '';
  bool _searching = false;

  static const List<String> _fallbackAvatars = [
    'assets/images/초연.png',
    'assets/images/지안.png',
    'assets/images/시연.png',
    'assets/images/민지.png',
    'assets/images/정재.png',
  ];

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? const FirestoreChatRepository();
    _bind();
    _session = _repo.sessionChanges.listen((_) {
      if (mounted) setState(_bind);
    });
  }

  void _bind() {
    _uid = _repo.currentUid;
    _generation++;
    _rooms = _uid == null ? null : _repo.rooms(_uid!);
  }

  @override
  void dispose() {
    _session?.cancel();
    super.dispose();
  }

  void _explore() {
    if (widget.onExplore != null) {
      widget.onExplore!();
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OOMUHomeScreen()),
    );
  }

  Widget _notice(String title, String body, {bool retry = false}) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFF0E6D4)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A3014).withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFECE5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 26,
                    color: _primaryCoral,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w800,
                    color: _textEspresso,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: _textMuted,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryCoral,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: retry ? () => setState(_bind) : _explore,
                    child: Text(
                      retry ? '다시 불러오기' : '동네 모임 둘러보기',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgCream,
      appBar: AppBar(
        backgroundColor: _bgCream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: !widget.isEmbedded,
        titleSpacing: 20,
        title: const Text(
          '채팅',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: _textEspresso,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => setState(() {
                _searching = !_searching;
                _search = '';
              }),
              child: Tooltip(
                message: _searching ? '검색 닫기' : '대화방 검색',
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: _surfaceSearch,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _searching ? Icons.close_rounded : Icons.search_rounded,
                    size: 19,
                    color: _textEspresso,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // .chat-search (store_assets/OOMU 앱 UI 디자인.html #chatlist 1:1 재현)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: _searching
                ? Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: _surfaceSearch,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: _primaryCoral.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: _primaryCoral,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            onChanged: (value) =>
                                setState(() => _search = value.trim()),
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: _textEspresso,
                            ),
                            decoration: const InputDecoration(
                              hintText: '채팅방 · 이웃 검색',
                              hintStyle: TextStyle(
                                fontSize: 13.5,
                                color: _textFaint,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: () => setState(() => _searching = true),
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: _surfaceSearch,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 17,
                            color: _textFaint,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '채팅방 · 이웃 검색',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: _textFaint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          Expanded(
            child: _uid == null
                ? _notice(
                    '로그인 후 대화를 이어가세요',
                    '참여가 확인된 모임의 대화방이\n여기에 표시돼요.',
                  )
                : StreamBuilder<List<ChatData>>(
                    key: ValueKey(_generation),
                    stream: _rooms,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return _notice(
                          '대화방을 불러오지 못했어요',
                          '연결 상태와 대화방 접근 권한을 확인한 뒤 다시 시도해 주세요.',
                          retry: true,
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(color: _primaryCoral),
                        );
                      }
                      final rooms = snapshot.data!
                          .where((r) =>
                              isChatParticipant(r, _uid) &&
                              (r['title'] ?? '').toString().contains(_search))
                          .toList();
                      if (rooms.isEmpty) {
                        return _notice(
                          _search.isEmpty ? '참여 중인 대화방이 없어요' : '검색 결과가 없어요',
                          _search.isEmpty
                              ? '모임 참여가 확인되면 대화를 시작할 수 있어요.'
                              : '다른 대화방 이름으로 검색해 주세요.',
                        );
                      }

                      final firstRoom = rooms.first;
                      final firstTitle =
                          (firstRoom['title'] ?? '우리 동네 모임').toString();
                      final firstMembers = chatParticipantIds(firstRoom).length;
                      final firstId = (firstRoom['id'] ?? '').toString();

                      return ListView(
                        padding: const EdgeInsets.only(bottom: 24),
                        children: [
                          // .meet-banner (다가오는 모임 코랄 그라데이션 배너)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: firstId.isEmpty
                                  ? null
                                  : () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => OOMUChatScreen(
                                            title: firstTitle,
                                            memberCount: firstMembers,
                                            chatRoomId: firstId,
                                            repository: _repo,
                                          ),
                                        ),
                                      ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF7A55),
                                      Color(0xFFFF5C39),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          _primaryCoral.withValues(alpha: 0.25),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.22),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: const Icon(
                                        Icons.wine_bar_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '다가오는 모임 · 실시간 모임톡',
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '$firstTitle · 멤버 $firstMembers명',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white
                                                  .withValues(alpha: 0.90),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // .list-label ("전체 대화")
                          const Padding(
                            padding: EdgeInsets.fromLTRB(22, 4, 22, 6),
                            child: Text(
                              '전체 대화',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: _textMuted,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),

                          // .chat-row 목록
                          ...List.generate(rooms.length, (index) {
                            final room = rooms[index];
                            final id = (room['id'] ?? '').toString();
                            final title =
                                (room['title'] ?? '모임 대화방').toString();
                            final preview =
                                (room['lastMessage'] ?? '').toString();
                            final memberCount =
                                chatParticipantIds(room).length;
                            final avatarPath = (room['avatarUrl'] ??
                                    room['coverImage'] ??
                                    _fallbackAvatars[
                                        index % _fallbackAvatars.length])
                                .toString();
                            final timeText =
                                (room['lastTime'] ?? '방금').toString();
                            final unreadCount =
                                int.tryParse('${room['unreadCount'] ?? 0}') ??
                                    0;

                            return InkWell(
                              onTap: id.isEmpty
                                  ? null
                                  : () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => OOMUChatScreen(
                                            title: title,
                                            memberCount: memberCount,
                                            chatRoomId: id,
                                            repository: _repo,
                                          ),
                                        ),
                                      ),
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: _borderWarm),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // 52x52 아바타 + 초록 온라인 상태 점
                                    SizedBox(
                                      width: 52,
                                      height: 52,
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 52,
                                            height: 52,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFFFE3D8),
                                              shape: BoxShape.circle,
                                            ),
                                            child: ClipOval(
                                              child: Image(
                                                image: appImg(avatarPath),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 1,
                                            bottom: 1,
                                            child: Container(
                                              width: 13,
                                              height: 13,
                                              decoration: BoxDecoration(
                                                color: _onlineTeal,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: _bgCream,
                                                  width: 2.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // 대화방 제목 + 인원 태그 + 미리보기
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  title,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: _textEspresso,
                                                  ),
                                                ),
                                              ),
                                              if (memberCount > 0) ...[
                                                const SizedBox(width: 5),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 6,
                                                    vertical: 1.5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFF3E9D8),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: Text(
                                                    '$memberCount',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: _textMuted,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              const SizedBox(width: 8),
                                              Text(
                                                timeText,
                                                style: const TextStyle(
                                                  fontSize: 11.5,
                                                  color: _textFaint,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  preview.isEmpty
                                                      ? '아직 대화가 없어요 · 첫 인사를 건네보세요'
                                                      : preview,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 13.5,
                                                    color: _textMuted,
                                                  ),
                                                ),
                                              ),
                                              if (unreadCount > 0) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  constraints:
                                                      const BoxConstraints(
                                                    minWidth: 20,
                                                  ),
                                                  height: 20,
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 6),
                                                  decoration: BoxDecoration(
                                                    color: _primaryCoral,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            999),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    '$unreadCount',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
