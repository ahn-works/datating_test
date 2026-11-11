import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/chat_repository.dart';
import '../services/kakao_map_service.dart';
import '../services/r2_storage_service.dart';
import '../ui/oomu_avatar.dart';
import '../ui/oomu_tokens.dart';
import '../utils/app_image.dart';
import '../utils/global_data.dart';
import 'chat/chat_modals.dart';
import 'chat/chat_system_cards.dart';

// Existing trip screens use this facade. Reading it never creates messages.
class OOMUChatStore extends ChangeNotifier {
  static final OOMUChatStore _instance = OOMUChatStore._internal();
  factory OOMUChatStore() => _instance;
  final Set<String> _leftRoomIds = {};
  String _uid = '';
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;
  OOMUChatStore._internal() {
    globalData.currentUserId.addListener(syncWithCurrentUser);
  }
  void syncWithCurrentUser([String? forceUid]) {
    final uid = forceUid ?? globalData.currentUserId.value;
    if (_uid == uid) return;
    _uid = uid;
    _subscription?.cancel();
    _leftRoomIds.clear();
    if (uid.isEmpty || uid == 'guest' || Firebase.apps.isEmpty) return;
    _subscription = FirebaseFirestore.instance
        .collection('user_states')
        .doc(uid)
        .snapshots()
        .listen((snap) {
      if (_uid != uid) return;
      _leftRoomIds
        ..clear()
        ..addAll((snap.data()?['leftRoomIds'] is List
                ? snap.data()!['leftRoomIds'] as List
                : const [])
            .whereType<String>());
      notifyListeners();
    }, onError: (_) {});
  }

  String canonicalRoomId(String id) => id.trim();
  bool isRoomLeft(String id) {
    syncWithCurrentUser();
    return _leftRoomIds.contains(id);
  }

  List<Map<String, dynamic>> getRoomMessages(String id, String title) =>
      const [];
  Future<void> leaveRoom(String id) async {
    await const FirestoreChatRepository().leave(id);
    _leftRoomIds.add(id);
    notifyListeners();
  }
}

final oomuChatStore = OOMUChatStore();

class OOMUChatScreen extends StatefulWidget {
  final String title;
  final int memberCount;
  final String chatRoomId;
  final ChatRepository? repository;

  const OOMUChatScreen({
    super.key,
    required this.title,
    required this.memberCount,
    this.chatRoomId = '',
    this.repository,
  });

  @override
  State<OOMUChatScreen> createState() => _OOMUChatScreenState();
}

class _OOMUChatScreenState extends State<OOMUChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final ChatRepository _repo;
  StreamSubscription<String?>? _session;
  Stream<ChatData?>? _roomStream;
  Stream<List<ChatData>>? _messageStream;
  String? _uid;
  int _generation = 0;
  bool _canSend = false;
  bool _sending = false;
  bool _readFailed = false;
  String? _lastMessageId;
  ChatData? _roomData;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? const FirestoreChatRepository();
    _bindRoom();
    _session = _repo.sessionChanges.listen((_) {
      if (mounted) setState(_bindRoom);
    });
  }

  void _bindRoom() {
    _generation++;
    _uid = _repo.currentUid;
    _roomData = null;
    _canSend = false;
    _sending = false;
    _readFailed = false;
    _lastMessageId = null;
    _controller.clear();
    final id = widget.chatRoomId.trim();
    _roomStream = _uid == null || id.isEmpty ? null : _repo.room(id);
    _messageStream = _uid == null || id.isEmpty ? null : _repo.messages(id);
  }

  @override
  void dispose() {
    _session?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showFailure(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 92),
        content: Text(text),
      ));
    }
  }

  Future<bool> _addMessage(Map<String, dynamic> msgData) async {
    if (_sending) return false;
    if (!_canSend || _readFailed || _uid == null) {
      _showFailure('참여가 확인된 대화방에서 메시지를 보낼 수 있어요.');
      return false;
    }
    final generation = _generation;
    setState(() => _sending = true);
    try {
      await _repo.send(widget.chatRoomId.trim(), {
        ...msgData,
        'sender': globalData.userNickname.value.isEmpty
            ? '이웃'
            : globalData.userNickname.value,
        'senderAvatar': globalData.userAvatar.value,
      });
      if (!mounted || generation != _generation) return false;
      _scrollToBottom();
      return true;
    } catch (_) {
      if (generation == _generation) {
        _showFailure('메시지를 보내지 못했어요. 입력한 내용을 확인하고 다시 시도해 주세요.');
      }
      return false;
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _updateMessageData(
      String messageId, Map<String, dynamic> delta) async {
    try {
      await _repo.updateMessage(widget.chatRoomId, messageId, delta);
    } catch (_) {
      _showFailure('변경을 저장하지 못했어요. 다시 시도해 주세요.');
    }
  }

  Future<void> _sendMessage({String? customText}) async {
    final original = _controller.text;
    final text = (customText ?? original).trim();
    if (text.isEmpty) return;
    if (await _addMessage({'type': 'text', 'text': text}) &&
        mounted &&
        customText == null &&
        _controller.text == original) {
      _controller.clear();
    }
  }

  void _scrollToBottom({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (jump) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      } else {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendImageAction() async {
    ChatModals.showPhotoPicker(
      context,
      onPick: (source) async {
        try {
          final ImagePicker picker = ImagePicker();
          final XFile? image = await picker.pickImage(
            source: source,
            maxWidth: 1280,
            maxHeight: 1280,
            imageQuality: 85,
          );
          if (image == null) return;

          if (!R2StorageService.isImageFile(image.name)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('⚠️ 사진 파일(JPG, PNG, WEBP 등)만 전송할 수 있습니다.')),
            );
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('사진을 업로드하고 있어요.'),
              duration: Duration(seconds: 2),
            ),
          );

          final bytes = await image.readAsBytes();
          final downloadUrl = await r2Storage.uploadImageBytes(
            bytes: bytes,
            fileName: image.name,
            category: R2UploadCategory.chatPhoto,
          );
          if (downloadUrl.isEmpty || !mounted) return;
          await _addMessage(
              {'type': 'image', 'imageUrl': downloadUrl, 'title': '사진을 보냈어요'});
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('사진 업로드 실패: $e')),
          );
        }
      },
    );
  }

  Future<void> _sendLocationAction() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('위치 권한이 거부되었습니다.')));
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('현재 위치를 빠르게 가져오는 중입니다...')));
      Position? position;
      try {
        position = await Geolocator.getLastKnownPosition().timeout(
          const Duration(milliseconds: 400),
          onTimeout: () => null,
        );
      } catch (_) {}
      position ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(milliseconds: 1800),
      );
      final String kakaoMapUrl =
          'https://map.kakao.com/link/map/내_현재_위치,${position.latitude},${position.longitude}';

      _addMessage({
        'type': 'location',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'mapUrl': kakaoMapUrl,
      });
    } catch (_) {
      _showFailure('현재 위치를 확인하지 못했어요. 위치는 전송하지 않았어요.');
    }
  }

  void _showAttachmentMenu() {
    if (!_canSend || _readFailed) return;
    ChatModals.showAttachmentMenu(
      context,
      onSticker: () =>
          ChatModals.showStickerPicker(context, onCreated: _addMessage),
      onPhoto: _sendImageAction,
      onLocation: _sendLocationAction,
      onHotspot: () =>
          ChatModals.showHotspotSearch(context, onCreated: _addMessage),
      onSchedule: () =>
          ChatModals.showScheduleCreator(context, onCreated: _addMessage),
      onPoll: () => ChatModals.showPollCreator(context, onCreated: _addMessage),
      onSafeReturn: () => _addMessage({
        'type': 'safe_return',
        'title': '🏠 안전 귀가 알림',
        'desc': '방금 집에 무사히 도착했습니다! 다들 푹 쉬세요.',
      }),
      onAiTopics: () => ChatModals.showAiTopics(
        context,
        meetingTitle: widget.title,
        onSelectTopic: (topic) => _controller.text = topic,
      ),
      onProfileExchange: () => _addMessage({
        'type': 'profile_exchange',
        'title': '🤝 명함/프로필 교환 요청',
        'desc': '서로의 상세 프로필과 소셜 정보를 확인해볼까요?',
        'acceptedMembers': <String>[],
        'status': 'pending',
      }),
      onSecretAfter: () => _addMessage({
        'type': 'secret_after',
        'title': '💖 시크릿 애프터 1:1 호감 매칭',
        'desc': '모임 종료 후 비공개 호감 매칭이 오픈되었습니다! 마음에 드는 멤버를 선택해 보세요.',
        'secretChoices': <String>[],
      }),
      onReview: () => ChatModals.showReview(context, onCreated: _addMessage),
    );
  }

  void _showSafetyDrawer() {
    ChatModals.showSafetyDrawer(
      context,
      title: (_roomData?['title'] ?? widget.title).toString(),
      memberCount: chatParticipantIds(_roomData).length,
      onLeave: () async {
        try {
          await _repo.leave(widget.chatRoomId);
          if (mounted) Navigator.pop(context);
        } catch (_) {
          _showFailure('대화방에서 나가지 못했어요. 다시 시도해 주세요.');
        }
      },
    );
  }

  void _showMessageActionSheet(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true;
    final msgId = (msg['id'] ?? '').toString();
    final sender = (msg['sender'] ?? '상대방').toString();

    ChatModals.showMessageActionSheet(
      context,
      msg: msg,
      isMe: isMe,
      onDelete: () async {
        if (msgId.isNotEmpty) {
          try {
            await _repo.deleteMessage(widget.chatRoomId, msgId);
          } catch (_) {}
        }
        if (mounted) setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('메시지가 삭제되었습니다.')),
        );
      },
      onReport: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('신고가 접수되었습니다. 검토 후 조치됩니다.')),
        );
      },
      onBlock: () {
        globalData.blockUser(sender);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$sender님을 차단했습니다.')),
        );
      },
    );
  }

  Widget _chatNotice(String title, String description, {bool retry = false}) =>
      Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(OomuTokens.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.forum_outlined,
                  size: 36, color: OomuTokens.textSecondary),
              const SizedBox(height: OomuTokens.s16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: OomuTokens.fs18,
                  fontWeight: FontWeight.w700,
                  color: OomuTokens.textPrimary,
                ),
              ),
              const SizedBox(height: OomuTokens.s8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: OomuTokens.fs14,
                  height: 1.5,
                  color: OomuTokens.textSecondary,
                ),
              ),
              if (retry) ...[
                const SizedBox(height: OomuTokens.s12),
                TextButton(
                  onPressed: () => setState(_bindRoom),
                  child: const Text('다시 불러오기',
                      style: TextStyle(
                          color: OomuTokens.coral,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => StreamBuilder<ChatData?>(
        key: ValueKey(_generation),
        stream: _roomStream,
        builder: (context, roomSnapshot) {
          _roomData = roomSnapshot.data;
          _canSend =
              !roomSnapshot.hasError && isChatParticipant(_roomData, _uid);
          final memberCount = chatParticipantIds(_roomData).length;
          Widget content;
          if (_uid == null) {
            content =
                _chatNotice('로그인 후 대화할 수 있어요', '모임 참여가 확인되면 대화 내용을 볼 수 있어요.');
          } else if (widget.chatRoomId.trim().isEmpty) {
            content = _chatNotice('대화방을 찾을 수 없어요', '채팅 목록에서 모임을 다시 선택해 주세요.');
          } else if (roomSnapshot.hasError) {
            content = _chatNotice('대화방을 불러오지 못했어요', '연결 상태와 접근 권한을 확인해 주세요.',
                retry: true);
          } else if (roomSnapshot.connectionState == ConnectionState.waiting) {
            content = const Center(
                child: CircularProgressIndicator(color: OomuTokens.coral));
          } else if (_roomData == null) {
            content = _chatNotice('대화방을 찾을 수 없어요', '채팅 목록에서 모임을 다시 선택해 주세요.');
          } else if (!_canSend) {
            content = _chatNotice(
                '참여 확인이 필요한 대화방이에요', '모임 참여가 승인되고 대화방에 연결되면 이용할 수 있어요.');
          } else {
            content = StreamBuilder<List<ChatData>>(
              stream: _messageStream,
              builder: (context, snapshot) {
                _readFailed = snapshot.hasError;
                if (snapshot.hasError) {
                  return _chatNotice(
                      '대화를 불러오지 못했어요', '연결 상태를 확인한 뒤 다시 시도해 주세요.',
                      retry: true);
                }
                if (!snapshot.hasData) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: OomuTokens.coral));
                }
                return _buildMessageList(snapshot.data!);
              },
            );
          }

          return Scaffold(
            backgroundColor: OomuTokens.background,
            appBar: AppBar(
              backgroundColor: OomuTokens.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: OomuTokens.border),
              ),
              toolbarHeight: 64,
              leading: IconButton(
                tooltip: '뒤로',
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: OomuTokens.textPrimary),
                onPressed: () => Navigator.maybePop(context),
              ),
              titleSpacing: 0,
              title: Row(
                children: [
                  OomuAvatar(
                    imageUrl: (_roomData?['avatarUrl'] ??
                            _roomData?['coverImage'] ??
                            'assets/images/초연.png')
                        .toString(),
                    radius: 19,
                  ),
                  const SizedBox(width: OomuTokens.s8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (_roomData?['title'] ?? widget.title).toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: OomuTokens.textPrimary,
                            fontSize: OomuTokens.fs16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_canSend)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: OomuTokens.coral,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: OomuTokens.s4),
                                Flexible(
                                  child: Text(
                                    '멤버 $memberCount명 참여 중',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: OomuTokens.textSecondary,
                                      fontSize: OomuTokens.fs11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: '대화방 정보',
                  icon: const Icon(Icons.more_horiz_rounded,
                      color: OomuTokens.textPrimary),
                  onPressed: _canSend ? _showSafetyDrawer : null,
                ),
              ],
            ),
            body: Column(
              children: [
                if (_canSend &&
                    ((_roomData?['location'] ?? '').toString().isNotEmpty ||
                        (_roomData?['date'] ?? '').toString().isNotEmpty))
                  Container(
                    margin: const EdgeInsets.fromLTRB(
                        OomuTokens.s16, OomuTokens.s8, OomuTokens.s16, OomuTokens.s4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: OomuTokens.s12, vertical: OomuTokens.s8),
                    decoration: BoxDecoration(
                      color: OomuTokens.surface,
                      borderRadius: BorderRadius.circular(OomuTokens.r12),
                      border: Border.all(color: OomuTokens.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_note_rounded,
                            size: 18, color: OomuTokens.coral),
                        const SizedBox(width: OomuTokens.s8),
                        Expanded(
                          child: Text(
                            [_roomData?['date'], _roomData?['location']]
                                .whereType<String>()
                                .where((s) => s.isNotEmpty)
                                .join(' · '),
                            style: const TextStyle(
                              fontSize: OomuTokens.fs12,
                              fontWeight: FontWeight.w600,
                              color: OomuTokens.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: OomuTokens.s8, vertical: OomuTokens.s4),
                          decoration: BoxDecoration(
                            color: OomuTokens.surfaceMuted,
                            borderRadius: BorderRadius.circular(OomuTokens.rPill),
                          ),
                          child: const Text(
                            '모임 정보',
                            style: TextStyle(
                              fontSize: OomuTokens.fs11,
                              fontWeight: FontWeight.w600,
                              color: OomuTokens.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(child: content),
                if (_canSend) _buildMessageInput(),
              ],
            ),
          );
        },
      );

  Widget _buildMessageList(List<Map<String, dynamic>> source) {
    final list = source
        .where((m) => !isLegacyChatSeed(m))
        .map((m) => presentChatMessage(m, _uid))
        .toList();
    if (list.isEmpty) {
      return _chatNotice(
          '아직 나눈 대화가 없어요', '첫 인사를 남겨보세요.\n일정이나 투표는 + 버튼에서 직접 추가할 수 있어요.');
    }
    final lastId = list.last['id']?.toString();
    if (lastId != _lastMessageId) {
      final initial = _lastMessageId == null;
      final atBottom = !_scrollController.hasClients ||
          _scrollController.position.extentAfter < 100;
      _lastMessageId = lastId;
      if (initial || atBottom) _scrollToBottom(jump: initial);
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
          horizontal: OomuTokens.s16, vertical: OomuTokens.s16),
      itemCount: list.length,
      itemBuilder: (_, index) => _buildDynamicMessage(list[index]),
    );
  }

  Widget _buildDynamicMessage(Map<String, dynamic> data) {
    final type = data['type'] ?? 'text';
    final msgId = (data['id'] ?? '').toString();
    final isMe = data['isMe'] == true;
    final sender = (data['sender'] ?? '상대방').toString();

    // 차단된 사용자의 메시지는 보호 뷰(차단 안내 바)로 대체 표시
    if (!isMe && globalData.isUserBlocked(sender)) {
      return _buildBlockedMessagePlaceholder(sender);
    }

    void updateThisMessage(Map<String, dynamic> delta) {
      if (msgId.isNotEmpty) {
        _updateMessageData(msgId, delta);
      }
    }

    if (type == 'system') return _buildSystemMessage(data['text'] ?? '');
    if (type == 'ai_spot_summary') return _buildAiSpotSummaryCard(data);
    if (type == 'settlement') return const SizedBox.shrink();
    if (type == 'image') return _buildImageMessage(data);
    if (type == 'sticker') return _buildStickerMessage(data);
    if (type == 'location') return _buildLocationMessage(data);

    if (type == 'schedule') {
      return InteractiveScheduleCard(
        msg: data,
        isMe: isMe,
        chatRoomId: widget.chatRoomId,
        onUpdate: updateThisMessage,
      );
    }
    if (type == 'poll') {
      return InteractivePollCard(
        msg: data,
        isMe: isMe,
        chatRoomId: widget.chatRoomId,
        onUpdate: updateThisMessage,
      );
    }

    if (type == 'hotspot') return InteractiveHotspotCard(msg: data, isMe: isMe);
    if (type == 'review') return InteractiveReviewCard(msg: data, isMe: isMe);

    if (type == 'safe_return') {
      return InteractiveSafeReturnCard(
        msg: data,
        isMe: isMe,
        chatRoomId: widget.chatRoomId,
        onUpdate: updateThisMessage,
      );
    }
    if (type == 'profile_exchange') {
      return InteractiveProfileExchangeCard(
        msg: data,
        isMe: isMe,
        chatRoomId: widget.chatRoomId,
        onUpdate: updateThisMessage,
      );
    }
    if (type == 'secret_after') {
      return InteractiveSecretAfterMatchCard(
        msg: data,
        isMe: isMe,
        chatRoomId: widget.chatRoomId,
        onUpdate: updateThisMessage,
      );
    }
    return _buildTextMessage(data);
  }

  Widget _buildTextMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true;
    final sender = (msg['sender'] ?? '이웃').toString();
    final senderAvatar =
        (msg['avatar'] ?? msg['senderAvatar'] ?? '').toString();
    final timeStr = (msg['time'] ?? '').toString();

    final bubbleRadius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(OomuTokens.r16),
            topRight: Radius.circular(OomuTokens.r4),
            bottomLeft: Radius.circular(OomuTokens.r16),
            bottomRight: Radius.circular(OomuTokens.r16),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(OomuTokens.r4),
            topRight: Radius.circular(OomuTokens.r16),
            bottomLeft: Radius.circular(OomuTokens.r16),
            bottomRight: Radius.circular(OomuTokens.r16),
          );

    final bubbleDecoration = isMe
        ? BoxDecoration(
            color: OomuTokens.coral,
            borderRadius: bubbleRadius,
          )
        : BoxDecoration(
            color: OomuTokens.surfaceMuted,
            borderRadius: bubbleRadius,
          );
    final textColor = isMe ? OomuTokens.surface : OomuTokens.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: OomuTokens.s12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            OomuAvatar(imageUrl: senderAvatar, name: sender, radius: 16),
            const SizedBox(width: OomuTokens.s8),
          ],
          if (isMe && timeStr.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                timeStr,
                style: const TextStyle(
                  fontSize: OomuTokens.fs11,
                  color: OomuTokens.textMuted,
                ),
              ),
            ),
            const SizedBox(width: OomuTokens.s8),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.72),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4, left: 2),
                      child: Text(
                        sender,
                        style: const TextStyle(
                          fontSize: OomuTokens.fs11,
                          fontWeight: FontWeight.w600,
                          color: OomuTokens.textSecondary,
                        ),
                      ),
                    ),
                  GestureDetector(
                    onLongPress: () => _showMessageActionSheet(msg),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: OomuTokens.s12, vertical: OomuTokens.s8),
                      decoration: bubbleDecoration,
                      child: Text(
                        (msg['text'] ?? '').toString(),
                        style: TextStyle(
                          fontSize: OomuTokens.fs14,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isMe && timeStr.isNotEmpty) ...[
            const SizedBox(width: OomuTokens.s8),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                timeStr,
                style: const TextStyle(
                  fontSize: OomuTokens.fs11,
                  color: OomuTokens.textMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true;
    final sender = (msg['sender'] ?? '이웃').toString();
    final senderAvatar =
        (msg['avatar'] ?? msg['senderAvatar'] ?? '').toString();
    final rawUrl = (msg['imageUrl'] ?? '').toString();
    final imageUrl = r2Storage.getPublicViewUrl(rawUrl);

    return Padding(
      padding: const EdgeInsets.only(bottom: OomuTokens.s16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            OomuAvatar(imageUrl: senderAvatar, name: sender, radius: 16),
            const SizedBox(width: OomuTokens.s8),
          ],
          if (isMe)
            Text(msg['time'] ?? '방금',
                style: const TextStyle(
                    fontSize: OomuTokens.fs11, color: OomuTokens.textMuted)),
          if (isMe) const SizedBox(width: OomuTokens.s4),
          ClipRRect(
            borderRadius: BorderRadius.circular(OomuTokens.r16),
            child: SizedBox(
              width: 200,
              height: 200,
              child: appNetImage(
                imageUrl,
                fit: BoxFit.cover,
                width: 200,
                height: 200,
              ),
            ),
          ),
          if (!isMe) const SizedBox(width: OomuTokens.s4),
          if (!isMe)
            Text(msg['time'] ?? '방금',
                style: const TextStyle(
                    fontSize: OomuTokens.fs11, color: OomuTokens.textMuted)),
        ],
      ),
    );
  }

  Widget _buildStickerMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true;
    final sender = (msg['sender'] ?? '이웃').toString();
    final senderAvatar =
        (msg['avatar'] ?? msg['senderAvatar'] ?? '').toString();
    final rawUrl = (msg['imageUrl'] ?? '').toString();
    final imageUrl = r2Storage.getPublicViewUrl(rawUrl);

    return Padding(
      padding: const EdgeInsets.only(bottom: OomuTokens.s12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            OomuAvatar(imageUrl: senderAvatar, name: sender, radius: 16),
            const SizedBox(width: OomuTokens.s8),
          ],
          if (isMe)
            Text(msg['time'] ?? '방금',
                style: const TextStyle(
                    fontSize: OomuTokens.fs11, color: OomuTokens.textMuted)),
          if (isMe) const SizedBox(width: OomuTokens.s4),
          ClipRRect(
            borderRadius: BorderRadius.circular(OomuTokens.r16),
            child: Container(
              color: OomuTokens.surfaceMuted,
              padding: const EdgeInsets.all(OomuTokens.s4),
              child: appNetImage(
                imageUrl,
                fit: BoxFit.contain,
                width: 140,
                height: 140,
              ),
            ),
          ),
          if (!isMe) const SizedBox(width: OomuTokens.s4),
          if (!isMe)
            Text(msg['time'] ?? '방금',
                style: const TextStyle(
                    fontSize: OomuTokens.fs11, color: OomuTokens.textMuted)),
        ],
      ),
    );
  }

  Widget _buildLocationMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true;
    final sender = (msg['sender'] ?? '이웃').toString();
    final senderAvatar =
        (msg['avatar'] ?? msg['senderAvatar'] ?? '').toString();
    final mapUrl = msg['mapUrl'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: OomuTokens.s16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            OomuAvatar(imageUrl: senderAvatar, name: sender, radius: 16),
            const SizedBox(width: OomuTokens.s8),
          ],
          if (isMe)
            Text(msg['time'] ?? '',
                style: const TextStyle(
                    fontSize: OomuTokens.fs11, color: OomuTokens.textMuted)),
          if (isMe) const SizedBox(width: OomuTokens.s4),
          GestureDetector(
            onTap: () async {
              if (mapUrl.isNotEmpty) {
                final Uri url = Uri.parse(mapUrl);
                if (!await launchUrl(url)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('지도를 열 수 없습니다.')));
                }
              }
            },
            child: Container(
              width: 220,
              padding: const EdgeInsets.all(OomuTokens.s12),
              decoration: BoxDecoration(
                color: OomuTokens.surface,
                borderRadius: BorderRadius.circular(OomuTokens.r16),
                border: Border.all(color: OomuTokens.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: OomuTokens.coral, size: 20),
                      SizedBox(width: OomuTokens.s4),
                      Text('현재 위치 공유',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: OomuTokens.fs14,
                              color: OomuTokens.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: OomuTokens.s8),
                  Container(
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: OomuTokens.surfaceMuted,
                      borderRadius: BorderRadius.circular(OomuTokens.r12),
                      border: Border.all(color: OomuTokens.border),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.map_outlined,
                              size: 16, color: OomuTokens.textPrimary),
                          SizedBox(width: OomuTokens.s8),
                          Text('카카오맵 길찾기',
                              style: TextStyle(
                                  color: OomuTokens.textPrimary,
                                  fontSize: OomuTokens.fs12,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isMe) const SizedBox(width: OomuTokens.s4),
          if (!isMe)
            Text(msg['time'] ?? '',
                style: const TextStyle(
                    fontSize: OomuTokens.fs11, color: OomuTokens.textMuted)),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: OomuTokens.s16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: OomuTokens.s12, vertical: OomuTokens.s4),
          decoration: BoxDecoration(
            color: OomuTokens.surfaceMuted,
            borderRadius: BorderRadius.circular(OomuTokens.rPill),
          ),
          child: Text(text,
              style: const TextStyle(
                  fontSize: OomuTokens.fs11,
                  color: OomuTokens.textSecondary,
                  fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  Widget _buildBlockedMessagePlaceholder(String sender) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: OomuTokens.s4),
      padding: const EdgeInsets.symmetric(
          horizontal: OomuTokens.s12, vertical: OomuTokens.s8),
      decoration: BoxDecoration(
        color: OomuTokens.surfaceMuted,
        borderRadius: BorderRadius.circular(OomuTokens.r12),
        border: Border.all(color: OomuTokens.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.block, size: 14, color: OomuTokens.textMuted),
          const SizedBox(width: OomuTokens.s8),
          Expanded(
            child: Text(
              '차단된 사용자($sender)의 메시지입니다.',
              style: const TextStyle(
                  fontSize: OomuTokens.fs12, color: OomuTokens.textMuted),
            ),
          ),
          InkWell(
            onTap: () {
              globalData.unblockUser(sender);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('🎉 $sender님의 차단이 해제되었습니다.')),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: OomuTokens.s4, vertical: 2),
              child: Text(
                '차단 해제',
                style: TextStyle(
                    fontSize: OomuTokens.fs11,
                    fontWeight: FontWeight.w700,
                    color: OomuTokens.coral),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSpotSummaryCard(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true;
    final sender = (msg['sender'] ?? '이웃').toString();
    final senderAvatar =
        (msg['avatar'] ?? msg['senderAvatar'] ?? '').toString();
    final spotName = msg['spotName'] ?? '소소스팟';
    final summary = msg['summary'] ?? '';
    final parkingTip = msg['parkingTip'] ?? '';
    final popularMenu = msg['popularMenu'] ?? '';
    final vibe = msg['vibe'] ?? '';
    final List<dynamic> tags = msg['tags'] ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: OomuTokens.s16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            OomuAvatar(imageUrl: senderAvatar, name: sender, radius: 16),
            const SizedBox(width: OomuTokens.s8),
          ],
          if (isMe)
            Text(msg['time'] ?? '',
                style: const TextStyle(
                    fontSize: OomuTokens.fs11, color: OomuTokens.textMuted)),
          if (isMe) const SizedBox(width: OomuTokens.s4),
          Container(
            width: 275,
            padding: const EdgeInsets.all(OomuTokens.s16),
            decoration: BoxDecoration(
              color: OomuTokens.surface,
              borderRadius: BorderRadius.circular(OomuTokens.r16),
              border: Border.all(color: OomuTokens.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(OomuTokens.s4),
                      decoration: const BoxDecoration(
                        color: OomuTokens.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome,
                          color: OomuTokens.coral, size: 16),
                    ),
                    const SizedBox(width: OomuTokens.s8),
                    const Expanded(
                      child: Text(
                        'AI 1분 맛집 · 스팟 브리핑',
                        style: TextStyle(
                          fontSize: OomuTokens.fs12,
                          fontWeight: FontWeight.w700,
                          color: OomuTokens.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: OomuTokens.s8, vertical: 2),
                      decoration: BoxDecoration(
                        color: OomuTokens.surfaceMuted,
                        borderRadius: BorderRadius.circular(OomuTokens.r8),
                      ),
                      child: const Text(
                        'AI 요약',
                        style: TextStyle(
                            fontSize: OomuTokens.fs11,
                            fontWeight: FontWeight.w700,
                            color: OomuTokens.coral),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: OomuTokens.s12),
                Text(
                  spotName,
                  style: const TextStyle(
                      fontSize: OomuTokens.fs16,
                      fontWeight: FontWeight.w700,
                      color: OomuTokens.textPrimary),
                ),
                const SizedBox(height: OomuTokens.s4),
                Text(
                  summary,
                  style: const TextStyle(
                      fontSize: OomuTokens.fs12,
                      height: 1.4,
                      color: OomuTokens.textSecondary),
                ),
                const SizedBox(height: OomuTokens.s8),
                Container(
                  padding: const EdgeInsets.all(OomuTokens.s8),
                  decoration: BoxDecoration(
                    color: OomuTokens.surfaceMuted,
                    borderRadius: BorderRadius.circular(OomuTokens.r8),
                  ),
                  child: Column(
                    children: [
                      if (popularMenu.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('대표메뉴: ',
                                style: TextStyle(
                                    fontSize: OomuTokens.fs11,
                                    fontWeight: FontWeight.w700,
                                    color: OomuTokens.textPrimary)),
                            Expanded(
                              child: Text(popularMenu,
                                  style: const TextStyle(
                                      fontSize: OomuTokens.fs11,
                                      color: OomuTokens.textSecondary)),
                            ),
                          ],
                        ),
                      if (parkingTip.isNotEmpty) ...[
                        const SizedBox(height: OomuTokens.s4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('주차꿀팁: ',
                                style: TextStyle(
                                    fontSize: OomuTokens.fs11,
                                    fontWeight: FontWeight.w700,
                                    color: OomuTokens.textPrimary)),
                            Expanded(
                              child: Text(parkingTip,
                                  style: const TextStyle(
                                      fontSize: OomuTokens.fs11,
                                      color: OomuTokens.textSecondary)),
                            ),
                          ],
                        ),
                      ],
                      if (vibe.isNotEmpty) ...[
                        const SizedBox(height: OomuTokens.s4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('분위기: ',
                                style: TextStyle(
                                    fontSize: OomuTokens.fs11,
                                    fontWeight: FontWeight.w700,
                                    color: OomuTokens.textPrimary)),
                            Expanded(
                              child: Text(vibe,
                                  style: const TextStyle(
                                      fontSize: OomuTokens.fs11,
                                      color: OomuTokens.textSecondary)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: OomuTokens.s8),
                  Wrap(
                    spacing: OomuTokens.s4,
                    runSpacing: OomuTokens.s4,
                    children: tags
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: OomuTokens.s8, vertical: 2),
                              decoration: BoxDecoration(
                                color: OomuTokens.surfaceMuted,
                                borderRadius:
                                    BorderRadius.circular(OomuTokens.r8),
                              ),
                              child: Text(
                                t.toString(),
                                style: const TextStyle(
                                    fontSize: OomuTokens.fs11,
                                    color: OomuTokens.textSecondary,
                                    fontWeight: FontWeight.w600),
                              ),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: OomuTokens.s12),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: () => KakaoMapService.launchDirections(spotName),
                    icon: const Icon(Icons.map_outlined,
                        size: 16, color: OomuTokens.textPrimary),
                    label: const Text('카카오 길찾기',
                        style: TextStyle(
                            fontSize: OomuTokens.fs12,
                            fontWeight: FontWeight.w700,
                            color: OomuTokens.textPrimary)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OomuTokens.surfaceMuted,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(OomuTokens.r8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isMe) const SizedBox(width: OomuTokens.s4),
          if (!isMe)
            Text(msg['time'] ?? '',
                style: const TextStyle(
                    fontSize: OomuTokens.fs11, color: OomuTokens.textMuted)),
        ],
      ),
    );
  }

  Widget _buildMessageInput() => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
              OomuTokens.s12, OomuTokens.s8, OomuTokens.s12, OomuTokens.s12),
          decoration: const BoxDecoration(
            color: OomuTokens.surface,
            border: Border(top: BorderSide(color: OomuTokens.border, width: 1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 2, right: OomuTokens.s8),
                decoration: const BoxDecoration(
                  color: OomuTokens.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  tooltip: '도구함 열기',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 40, minHeight: 40),
                  onPressed: _sending ? null : _showAttachmentMenu,
                  icon: const Icon(Icons.add_rounded,
                      color: OomuTokens.textSecondary, size: 22),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(
                      fontSize: OomuTokens.fs14, color: OomuTokens.textPrimary),
                  decoration: InputDecoration(
                    hintText: '메시지 보내기…',
                    hintStyle: const TextStyle(
                        fontSize: OomuTokens.fs14, color: OomuTokens.textMuted),
                    filled: true,
                    fillColor: OomuTokens.surfaceMuted,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: OomuTokens.s16, vertical: OomuTokens.s8),
                    suffixIcon: IconButton(
                      tooltip: '인기 움짤 스티커',
                      icon: const Icon(
                        Icons.sentiment_satisfied_alt_rounded,
                        color: OomuTokens.textMuted,
                        size: 22,
                      ),
                      onPressed: _sending
                          ? null
                          : () => ChatModals.showStickerPicker(context,
                              onCreated: _addMessage),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(OomuTokens.rPill),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(OomuTokens.rPill),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(OomuTokens.rPill),
                      borderSide: const BorderSide(
                          color: OomuTokens.coral, width: 1.2),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 2, left: OomuTokens.s8),
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: OomuTokens.coral,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  tooltip: '메시지 전송',
                  padding: EdgeInsets.zero,
                  onPressed: _sending ? null : _sendMessage,
                  icon: _sending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: OomuTokens.surface))
                      : const Icon(Icons.send_rounded,
                          color: OomuTokens.surface, size: 18),
                ),
              ),
            ],
          ),
        ),
      );
}
