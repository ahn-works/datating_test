import 'dart:async';
import 'package:flutter/material.dart';

import '../services/chat_repository.dart';
import '../ui/oomu_avatar.dart';
import '../ui/oomu_empty_state.dart';
import '../ui/oomu_tokens.dart';
import 'oomu_chat_room_screen.dart';
import 'oomu_home_screen.dart';

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
          padding: const EdgeInsets.all(OomuTokens.s20),
          child: OomuEmptyState(
            icon: Icons.chat_bubble_outline_rounded,
            title: title,
            subtitle: body,
            buttonLabel: retry ? '다시 불러오기' : '동네 모임 둘러보기',
            onButtonPressed: retry ? () => setState(_bind) : _explore,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OomuTokens.background,
      appBar: AppBar(
        backgroundColor: OomuTokens.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: !widget.isEmbedded,
        titleSpacing: OomuTokens.s20,
        title: const Text(
          '채팅',
          style: TextStyle(
            fontSize: OomuTokens.fs22,
            fontWeight: OomuTokens.w700,
            letterSpacing: -0.4,
            color: OomuTokens.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: OomuTokens.s16),
            child: InkWell(
              borderRadius: BorderRadius.circular(OomuTokens.rPill),
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
                    color: OomuTokens.surfaceMuted,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _searching ? Icons.close_rounded : Icons.search_rounded,
                    size: 19,
                    color: OomuTokens.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              OomuTokens.s20,
              OomuTokens.s8,
              OomuTokens.s20,
              OomuTokens.s12,
            ),
            child: _searching
                ? Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: OomuTokens.s12),
                    decoration: BoxDecoration(
                      color: OomuTokens.surface,
                      borderRadius: BorderRadius.circular(OomuTokens.rPill),
                      border: Border.all(color: OomuTokens.coral),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: OomuTokens.coral,
                        ),
                        const SizedBox(width: OomuTokens.s8),
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            onChanged: (value) =>
                                setState(() => _search = value.trim()),
                            style: const TextStyle(
                              fontSize: OomuTokens.fs14,
                              color: OomuTokens.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              hintText: '채팅방 · 이웃 검색',
                              hintStyle: TextStyle(
                                fontSize: OomuTokens.fs14,
                                color: OomuTokens.textMuted,
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
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: OomuTokens.s12),
                      decoration: BoxDecoration(
                        color: OomuTokens.surface,
                        borderRadius: BorderRadius.circular(OomuTokens.rPill),
                        border: Border.all(color: OomuTokens.border),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: OomuTokens.textMuted,
                          ),
                          SizedBox(width: OomuTokens.s8),
                          Text(
                            '채팅방 · 이웃 검색',
                            style: TextStyle(
                              fontSize: OomuTokens.fs14,
                              color: OomuTokens.textMuted,
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
                          child: CircularProgressIndicator(color: OomuTokens.coral),
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
                        padding: const EdgeInsets.only(bottom: OomuTokens.s24),
                        children: [
                          // 다가오는 모임 카드 (정돈된 단일 스타일)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              OomuTokens.s20,
                              0,
                              OomuTokens.s20,
                              OomuTokens.s12,
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(OomuTokens.r16),
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
                                padding: const EdgeInsets.all(OomuTokens.s16),
                                decoration: BoxDecoration(
                                  color: OomuTokens.surfaceMuted,
                                  borderRadius: BorderRadius.circular(OomuTokens.r16),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: OomuTokens.surfaceMuted,
                                        borderRadius:
                                            BorderRadius.circular(OomuTokens.r12),
                                      ),
                                      child: const Icon(
                                        Icons.groups_rounded,
                                        color: OomuTokens.coral,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: OomuTokens.s12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '다가오는 모임 · 실시간 모임톡',
                                            style: TextStyle(
                                              fontSize: OomuTokens.fs14,
                                              fontWeight: OomuTokens.w700,
                                              color: OomuTokens.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '$firstTitle · 멤버 $firstMembers명',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: OomuTokens.fs12,
                                              color: OomuTokens.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: OomuTokens.textMuted,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // 전체 대화 레이블
                          const Padding(
                            padding: EdgeInsets.fromLTRB(
                              OomuTokens.s20,
                              OomuTokens.s8,
                              OomuTokens.s20,
                              OomuTokens.s8,
                            ),
                            child: Text(
                              '전체 대화',
                              style: TextStyle(
                                fontSize: OomuTokens.fs12,
                                fontWeight: OomuTokens.w700,
                                color: OomuTokens.textSecondary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),

                          // 대화방 목록
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: OomuTokens.s20,
                                  vertical: OomuTokens.s12,
                                ),
                                decoration: const BoxDecoration(
                                  color: OomuTokens.surface,
                                  border: Border(
                                    bottom: BorderSide(color: OomuTokens.border),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // 48x48 원형 썸네일
                                    OomuAvatar(
                                      imageUrl: avatarPath,
                                      name: title,
                                      radius: 24,
                                    ),
                                    const SizedBox(width: OomuTokens.s12),

                                    // 대화방 제목 + 인원 + 미리보기
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
                                                    fontSize: OomuTokens.fs16,
                                                    fontWeight: OomuTokens.w600,
                                                    color: OomuTokens.textPrimary,
                                                  ),
                                                ),
                                              ),
                                              if (memberCount > 0) ...[
                                                const SizedBox(width: OomuTokens.s4),
                                                Text(
                                                  '$memberCount',
                                                  style: const TextStyle(
                                                    fontSize: OomuTokens.fs12,
                                                    fontWeight: OomuTokens.w600,
                                                    color: OomuTokens.textMuted,
                                                  ),
                                                ),
                                              ],
                                              const Spacer(),
                                              Text(
                                                timeText,
                                                style: const TextStyle(
                                                  fontSize: OomuTokens.fs12,
                                                  color: OomuTokens.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
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
                                                    fontSize: OomuTokens.fs14,
                                                    color: OomuTokens.textSecondary,
                                                  ),
                                                ),
                                              ),
                                              if (unreadCount > 0) ...[
                                                const SizedBox(width: OomuTokens.s8),
                                                Container(
                                                  constraints:
                                                      const BoxConstraints(
                                                    minWidth: 20,
                                                  ),
                                                  height: 20,
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 6),
                                                  decoration: BoxDecoration(
                                                    color: OomuTokens.coral,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            OomuTokens.rPill),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    '$unreadCount',
                                                    style: const TextStyle(
                                                      fontSize: OomuTokens.fs11,
                                                      fontWeight:
                                                          OomuTokens.w700,
                                                      color: OomuTokens.surface,
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
