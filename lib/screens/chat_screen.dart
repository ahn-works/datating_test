import 'dart:async';
import 'package:flutter/material.dart';
import '../services/chat_repository.dart';
import '../utils/oomu_ui_helpers.dart';
import 'soso_car_chat_screen.dart';
import 'soso_car_home_screen.dart';

class ChatScreen extends StatefulWidget {
  final bool isEmbedded;
  final VoidCallback? onExplore;
  final ChatRepository? repository;
  const ChatScreen(
      {super.key, this.isEmbedded = false, this.onExplore, this.repository});
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
        context, MaterialPageRoute(builder: (_) => const OOMUHomeScreen()));
  }

  Widget _notice(String title, String body, {bool retry = false}) => Center(
      child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.chat_bubble_outline_rounded,
                size: 40, color: OomuUiHelpers.textSecondary),
            const SizedBox(height: 20),
            Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(body,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: OomuUiHelpers.textSecondary)),
            const SizedBox(height: 24),
            OutlinedButton(
                onPressed: retry ? () => setState(_bind) : _explore,
                child: Text(retry ? '다시 불러오기' : '동네 모임 둘러보기')),
          ])));
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFFAF6F7),
        appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: Color(0xFFF0E4E6)),
            ),
            automaticallyImplyLeading: !widget.isEmbedded,
            title: const Text('채팅',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF191F28))),
            actions: [
              IconButton(
                  tooltip: _searching ? '검색 닫기' : '대화방 검색',
                  icon: Icon(_searching ? Icons.close : Icons.search,
                      color: const Color(0xFF4E5968)),
                  onPressed: () => setState(() {
                        _searching = !_searching;
                        _search = '';
                      })),
            ]),
        body: Column(children: [
          if (_searching)
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                child: TextField(
                  autofocus: true,
                  onChanged: (value) => setState(() => _search = value.trim()),
                  decoration: InputDecoration(
                    hintText: '대화방 이름 검색',
                    hintStyle: const TextStyle(color: Color(0xFFA0A7B1)),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFFF25767)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Color(0xFFF0E4E6), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Color(0xFFF0E4E6), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Color(0xFFF25767), width: 1.5),
                    ),
                  ),
                )),
          Expanded(
              child: _uid == null
                  ? _notice('로그인 후 대화를 이어가세요', '참여가 확인된 모임의 대화방이 여기에 표시돼요.')
                  : StreamBuilder<List<ChatData>>(
                      key: ValueKey(_generation),
                      stream: _rooms,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return _notice('대화방을 불러오지 못했어요',
                              '연결 상태와 대화방 접근 권한을 확인한 뒤 다시 시도해 주세요.',
                              retry: true);
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
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
                                  : '다른 대화방 이름으로 검색해 주세요.');
                        }
                        return ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: rooms.length,
                            separatorBuilder: (_, __) => const Divider(
                                indent: 20,
                                endIndent: 20,
                                height: 1,
                                color: Color(0xFFF0E4E6)),
                            itemBuilder: (context, index) {
                              final room = rooms[index];
                              final id = (room['id'] ?? '').toString();
                              final title =
                                  (room['title'] ?? '모임 대화방').toString();
                              final preview =
                                  (room['lastMessage'] ?? '').toString();
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFF0F2),
                                        Color(0xFFFFE4E8)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFFCE7E9),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFF25767)
                                            .withValues(alpha: 0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.forum_rounded,
                                        color: OomuUiHelpers.brandCoral,
                                        size: 22),
                                  ),
                                ),
                                title: Text(title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF191F28))),
                                subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                        preview.isEmpty
                                            ? '아직 대화가 없어요 · 인사를 건네보세요'
                                            : preview,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 13.5,
                                            color: Color(0xFF6B7684)))),
                                trailing: const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Color(0xFFB0B8C1),
                                    size: 20),
                                onTap: id.isEmpty
                                    ? null
                                    : () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => OOMUChatScreen(
                                                title: title,
                                                memberCount:
                                                    chatParticipantIds(room)
                                                        .length,
                                                chatRoomId: id,
                                                repository: _repo))),
                              );
                            });
                      })),
        ]),
      );
}
