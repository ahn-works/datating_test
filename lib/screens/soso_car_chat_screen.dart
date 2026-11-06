import 'dart:async';
import '../services/kakao_map_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../utils/app_image.dart';
import '../utils/global_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../services/r2_storage_service.dart';
import '../widgets/ugc_action_sheets.dart';
import '../services/ai_service.dart';
import '../services/chat_repository.dart';
import '../utils/oomu_ui_helpers.dart';
import 'package:firebase_core/firebase_core.dart';

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
  final Color textPrimary = OomuUiHelpers.textPrimary;
  final Color textSecondary = OomuUiHelpers.textSecondary;
  final Color surfaceColor = OomuUiHelpers.backgroundNeutral;
  final Color accentColor = OomuUiHelpers.brandCoral;

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
      if (generation == _generation)
        _showFailure('메시지를 보내지 못했어요. 입력한 내용을 확인하고 다시 시도해 주세요.');
      return false;
    } finally {
      if (mounted && generation == _generation)
        setState(() => _sending = false);
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
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _sendImageAction() async {
    Navigator.pop(context);

    Future<void> pickAndUpload(ImageSource source) async {
      Navigator.pop(context);
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
            category: R2UploadCategory.chatPhoto);
        if (downloadUrl.isEmpty || !mounted) return;
        await _addMessage(
            {'type': 'image', 'imageUrl': downloadUrl, 'title': '사진을 보냈어요'});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사진 업로드 실패: $e')),
        );
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('사진 공유',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => pickAndUpload(ImageSource.camera),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5F0),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0xFFFF5E36)
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.photo_camera_rounded,
                                color: Color(0xFFFF5E36), size: 24),
                            const SizedBox(height: 6),
                            const Text('사진 찍기',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('카메라 촬영',
                                style: TextStyle(
                                    fontSize: 11, color: textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => pickAndUpload(ImageSource.gallery),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7EE),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0xFFF38020)
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.photo_library_rounded,
                                color: Color(0xFFF38020), size: 24),
                            const SizedBox(height: 6),
                            const Text('사진 불러오기',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('갤러리/앨범',
                                style: TextStyle(
                                    fontSize: 11, color: textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendLocationAction() async {
    Navigator.pop(context);
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
        'mapUrl': kakaoMapUrl
      });
    } catch (e) {
      _showFailure('현재 위치를 확인하지 못했어요. 위치는 전송하지 않았어요.');
    }
  }

  // ===========================================================================
  // [동적 작동] 일정 생성 폼 (BottomSheet)
  // ===========================================================================
  void _showScheduleCreatorBottomSheet() {
    Navigator.pop(context);

    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    String location = '';
    int maxMembers = 4;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.calendar_month, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('상세 일정 제안하기',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Date Picker
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('날짜 선택',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(selectedDate != null
                          ? '${selectedDate!.year}년 ${selectedDate!.month}월 ${selectedDate!.day}일'
                          : '터치하여 날짜를 선택하세요'),
                      trailing:
                          const Icon(Icons.edit_calendar, color: Colors.blue),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) setState(() => selectedDate = date);
                      },
                    ),
                    const Divider(),

                    // Time Picker
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('시간 선택',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(selectedTime != null
                          ? selectedTime!.format(context)
                          : '터치하여 시간을 선택하세요'),
                      trailing:
                          const Icon(Icons.access_time, color: Colors.blue),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) setState(() => selectedTime = time);
                      },
                    ),
                    const Divider(),

                    // Location
                    TextField(
                      onChanged: (val) => location = val,
                      decoration: InputDecoration(
                        labelText: '모임 장소 (예: 스타벅스 여수점)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F7),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Max Members
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('모임 인원',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        DropdownButton<int>(
                          value: maxMembers,
                          items: [2, 3, 4, 5, 6, 7, 8]
                              .map((e) => DropdownMenuItem(
                                  value: e, child: Text('$e명')))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => maxMembers = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        onPressed: () {
                          if (selectedDate == null ||
                              selectedTime == null ||
                              location.trim().isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                    content: Text('날짜, 시간, 장소를 모두 입력해주세요.')));
                            return;
                          }
                          Navigator.pop(ctx);
                          _addMessage({
                            'type': 'schedule',
                            'title': '새로운 일정이 제안되었습니다!',
                            'date':
                                '${selectedDate!.month}월 ${selectedDate!.day}일',
                            'timeStr': selectedTime!.format(ctx),
                            'location': location,
                            'maxMembers': maxMembers,
                          });
                        },
                        child: const Text('일정 공유 및 투표 시작',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  // ===========================================================================
  // [동적 작동] 투표 생성 폼 (BottomSheet)
  // ===========================================================================
  void _showPollCreatorBottomSheet() {
    Navigator.pop(context);
    final TextEditingController titleCtrl = TextEditingController();
    final TextEditingController opt1Ctrl = TextEditingController();
    final TextEditingController opt2Ctrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.how_to_vote, color: Colors.purple),
                    SizedBox(width: 8),
                    Text('투표 만들기',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                        labelText: '투표 주제',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 16),
                TextField(
                    controller: opt1Ctrl,
                    decoration: InputDecoration(
                        labelText: '옵션 1',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 12),
                TextField(
                    controller: opt2Ctrl,
                    decoration: InputDecoration(
                        labelText: '옵션 2',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      if (titleCtrl.text.isEmpty ||
                          opt1Ctrl.text.isEmpty ||
                          opt2Ctrl.text.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(content: Text('모든 항목을 입력해주세요.')));
                        return;
                      }
                      Navigator.pop(ctx);
                      _addMessage({
                        'type': 'poll',
                        'title': '📊 ${titleCtrl.text}',
                        'opt1': opt1Ctrl.text,
                        'opt2': opt2Ctrl.text
                      });
                    },
                    child: const Text('투표 등록',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // [동적 작동] 핫플 검색 폼 (BottomSheet)
  // ===========================================================================

  void _showSafeReturnBottomSheet() {
    Navigator.pop(context);
    _addMessage({
      'type': 'safe_return',
      'title': '🏠 안전 귀가 알림',
      'desc': '방금 집에 무사히 도착했습니다! 다들 푹 쉬세요.'
    });
  }

  void _showProfileExchangeBottomSheet() {
    Navigator.pop(context);
    _addMessage({
      'type': 'profile_exchange',
      'title': '🤝 명함/프로필 교환 요청',
      'desc': '서로의 상세 프로필과 소셜 정보를 확인해볼까요?',
      'acceptedMembers': <String>[],
      'status': 'pending',
    });
  }

  void _showSecretAfterBottomSheet() {
    Navigator.pop(context);
    _addMessage({
      'type': 'secret_after',
      'title': '💖 시크릿 애프터 1:1 호감 매칭',
      'desc': '모임 종료 후 비공개 호감 매칭이 오픈되었습니다! 마음에 드는 멤버를 선택해 보세요.',
      'secretChoices': <String>[],
    });
  }

  void _showHotspotSearchBottomSheet() {
    Navigator.pop(context);

    String searchQuery = '';
    String selectedCategory = '전체';
    List<Map<String, dynamic>> searchResults = [];
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          Future<void> performSearch(String query) async {
            if (query.trim().isEmpty) return;
            setState(() {
              isLoading = true;
              searchResults = [];
            });

            try {
              // 카카오 공식 장소 검색 (KakaoMapService)
              final places =
                  await KakaoMapService.searchKeyword(query, size: 10);
              if (mounted) {
                setState(() {
                  searchResults = places.map((item) {
                    return {
                      'name': item.name,
                      'category': item.category.isNotEmpty
                          ? item.category
                          : (selectedCategory == '전체'
                              ? '모임장소'
                              : selectedCategory),
                      'address': item.roadAddress.isNotEmpty
                          ? item.roadAddress
                          : item.address,
                      'lat': item.lat,
                      'lng': item.lng,
                    };
                  }).toList();
                });
              }
            } catch (e) {
              print('Search error: $e');
            } finally {
              setState(() {
                isLoading = false;
              });
            }
          }

          return Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              height: MediaQuery.of(ctx).size.height * 0.7,
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.travel_explore, color: Colors.brown),
                      SizedBox(width: 8),
                      Text('실시간 장소 검색 (전국)',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold))
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onSubmitted: (val) {
                      searchQuery = val;
                      performSearch(val);
                    },
                    decoration: InputDecoration(
                      hintText: '장소 이름 또는 지역 검색 (예: 여수 카페)',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: Colors.brown),
                        onPressed: () => performSearch(searchQuery),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) => searchQuery = val,
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['전체', '관광지', '카페', '술집', '빵집'].map((category) {
                        final isSelected = selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected)
                                setState(() => selectedCategory = category);
                            },
                            selectedColor: Colors.brown.withValues(alpha: 0.2),
                            labelStyle: TextStyle(
                                color:
                                    isSelected ? Colors.brown : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  Expanded(
                    child: isLoading
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Colors.brown))
                        : searchResults.isEmpty
                            ? const Center(child: Text('장소 이름이나 지역을 검색해보세요.'))
                            : ListView.builder(
                                itemCount: searchResults.length,
                                itemBuilder: (context, index) {
                                  final place = searchResults[index];
                                  return ListTile(
                                    contentPadding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: Colors.brown
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: const Icon(Icons.place,
                                          color: Colors.brown),
                                    ),
                                    title: Text(place['name'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    subtitle: Text(
                                        '${place['category']} • ${place['address']}',
                                        style: const TextStyle(fontSize: 12),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    trailing: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.brown,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8))),
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        _addMessage({
                                          'type': 'hotspot',
                                          'title': '☕ 우리 동네 핫플 추천!',
                                          'name': place['name'],
                                          'category': place['category'],
                                          'address': place['address'],
                                          'lat': place['lat'],
                                          'lng': place['lng'],
                                        });
                                      },
                                      child: const Text('공유',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12)),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // ===========================================================================
  // [동적 작동] 모임 후기 별점 폼
  // ===========================================================================
  void _showReviewBottomSheet() {
    Navigator.pop(context);

    int selectedStars = 5;
    TextEditingController textCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.rate_review, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('모임 후기 남기기',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold))
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                      '이번 모임은 어떠셨나요? 별점과 솔직한 후기를 남겨주세요.\n작성하신 별점은 상대방의 매너 온도에 즉시 반영됩니다.',
                      style: TextStyle(
                          color: Colors.grey, fontSize: 13, height: 1.4)),
                  const SizedBox(height: 24),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () =>
                              setState(() => selectedStars = index + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              index < selectedStars
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.orange,
                              size: 44,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: textCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: '즐거운 모임이었나요? 후기를 자유롭게 적어주세요.',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
                        if (textCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('후기 내용을 입력해주세요.')));
                          return;
                        }
                        Navigator.pop(ctx);

                        // 글로벌 상태 업데이트 (매너 온도 및 평점 즉시 반영!)
                        globalData.submitReview(
                            selectedStars.toDouble(), textCtrl.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('후기가 프로필에 반영되었습니다!')));

                        _addMessage({
                          'type': 'review',
                          'rating': selectedStars,
                          'text': textCtrl.text,
                        });
                      },
                      child: const Text('후기 공유하기',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showAttachmentMenu() {
    if (!_canSend || _readFailed) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding:
            const EdgeInsets.only(top: 14, left: 20, right: 20, bottom: 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.dashboard_customize_rounded,
                        size: 18, color: Color(0xFFF25767)),
                    SizedBox(width: 6),
                    Text(
                      '모임 도구 및 공유',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF191F28),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 16,
                  runSpacing: 20,
                  alignment: WrapAlignment.start,
                  children: [
                    _buildAttachmentIcon(Icons.photo_library_rounded, '사진/앨범',
                        const Color(0xFF10B981),
                        onTap: _sendImageAction),
                    _buildAttachmentIcon(Icons.location_on_rounded, '위치 공유',
                        const Color(0xFFEF4444),
                        onTap: _sendLocationAction),
                    _buildAttachmentIcon(Icons.local_cafe_rounded, '동네 핫플',
                        const Color(0xFFD97706),
                        onTap: _showHotspotSearchBottomSheet),
                    _buildAttachmentIcon(Icons.event_available_rounded, '일정 제안',
                        const Color(0xFF3B82F6),
                        onTap: _showScheduleCreatorBottomSheet),
                    _buildAttachmentIcon(Icons.how_to_vote_rounded, '투표 만들기',
                        const Color(0xFF8B5CF6),
                        onTap: _showPollCreatorBottomSheet),
                    _buildAttachmentIcon(Icons.nightlife_rounded, '안심 귀가',
                        const Color(0xFFF43F5E),
                        onTap: _showSafeReturnBottomSheet),
                    _buildAttachmentIcon(Icons.auto_awesome_rounded, 'AI 대화주제',
                        const Color(0xFF6366F1), onTap: () {
                      Navigator.pop(ctx);
                      _showAiTopicsBottomSheet();
                    }),
                    _buildAttachmentIcon(
                        Icons.badge_outlined, '프로필 교환', const Color(0xFF0D9488),
                        onTap: _showProfileExchangeBottomSheet),
                    _buildAttachmentIcon(Icons.favorite_rounded, '시크릿 애프터',
                        const Color(0xFFEC4899),
                        onTap: _showSecretAfterBottomSheet),
                    _buildAttachmentIcon(Icons.rate_review_rounded, '모임 후기',
                        const Color(0xFFF59E0B),
                        onTap: _showReviewBottomSheet),
                  ],
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    '선택한 도구 카드가 대화방 멤버들에게 실시간으로 공유돼요.',
                    style: TextStyle(color: Color(0xFF8C94A0), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentIcon(IconData icon, String label, Color color,
      {VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap ??
          () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('$label 기능이 준비중입니다.')));
          },
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333D4B),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatNotice(String title, String description, {bool retry = false}) =>
      Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.forum_outlined, size: 36, color: textSecondary),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textPrimary)),
            const SizedBox(height: 8),
            Text(description,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 15, height: 1.5, color: textSecondary)),
            if (retry)
              TextButton(
                  onPressed: () => setState(_bindRoom),
                  child: const Text('다시 불러오기')),
          ]),
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
            content = const Center(child: CircularProgressIndicator());
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
                  if (snapshot.hasError)
                    return _chatNotice(
                        '대화를 불러오지 못했어요', '연결 상태를 확인한 뒤 다시 시도해 주세요.',
                        retry: true);
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  return _buildMessageList(snapshot.data!);
                });
          }
          return Scaffold(
            backgroundColor: const Color(0xFFFAF6F7),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: Color(0xFFF0E4E6)),
              ),
              toolbarHeight:
                  MediaQuery.textScalerOf(context).scale(16) > 22 ? 112 : 80,
              leading: IconButton(
                  tooltip: '뒤로',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.maybePop(context)),
              title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((_roomData?['title'] ?? widget.title).toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    if (_canSend)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFFCD3D9), width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF25767),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '$memberCount명 참여 중',
                              style: const TextStyle(
                                color: Color(0xFFD9384A),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ]),
              actions: [
                IconButton(
                    tooltip: '대화방 정보',
                    icon: const Icon(Icons.more_horiz_rounded),
                    onPressed: _canSend ? _showChatRoomSafetyDrawer : null)
              ],
            ),
            body: Column(children: [
              if (_canSend &&
                  (_roomData?['location'] ?? '').toString().isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(0xFFFCE7E9), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF25767).withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.place_rounded,
                            size: 14, color: Color(0xFFF25767)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          [_roomData?['date'], _roomData?['location']]
                              .whereType<String>()
                              .where((s) => s.isNotEmpty)
                              .join(' · '),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4E5968),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(child: content),
              if (_canSend) _buildMessageInput(),
            ]),
          );
        },
      );
  Widget _buildMessageList(List<Map<String, dynamic>> source) {
    final list = source
        .where((m) => !isLegacyChatSeed(m))
        .map((m) => presentChatMessage(m, _uid))
        .toList();
    if (list.isEmpty)
      return _chatNotice(
          '아직 나눈 대화가 없어요', '첫 인사를 남겨보세요.\n일정이나 투표는 + 버튼에서 직접 추가할 수 있어요.');
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: list.length,
        itemBuilder: (_, index) => _buildDynamicMessage(list[index]));
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
    if (type == 'settlement') return const SizedBox.shrink(); // 1/N 정산 카드 삭제
    if (type == 'image') return _buildImageMessage(data);
    if (type == 'location') return _buildLocationMessage(data);

    if (type == 'schedule')
      return InteractiveScheduleCard(
          msg: data,
          isMe: isMe,
          chatRoomId: widget.chatRoomId,
          onUpdate: updateThisMessage);
    if (type == 'poll')
      return InteractivePollCard(
          msg: data,
          isMe: isMe,
          chatRoomId: widget.chatRoomId,
          onUpdate: updateThisMessage);

    if (type == 'hotspot') return InteractiveHotspotCard(msg: data, isMe: isMe);
    if (type == 'review') return InteractiveReviewCard(msg: data, isMe: isMe);

    if (type == 'safe_return')
      return InteractiveSafeReturnCard(
          msg: data,
          isMe: isMe,
          chatRoomId: widget.chatRoomId,
          onUpdate: updateThisMessage);
    if (type == 'profile_exchange')
      return InteractiveProfileExchangeCard(
          msg: data,
          isMe: isMe,
          chatRoomId: widget.chatRoomId,
          onUpdate: updateThisMessage);
    if (type == 'secret_after')
      return InteractiveSecretAfterMatchCard(
          msg: data,
          isMe: isMe,
          chatRoomId: widget.chatRoomId,
          onUpdate: updateThisMessage);
    if (['carpool'].contains(type)) {
      return _buildInteractiveCardMessage(data);
    }
    return _buildTextMessage(data);
  }

  Widget _buildInteractiveCardMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true;
    IconData icon = Icons.info;
    Color iconColor = accentColor;

    switch (msg['type']) {
      case 'review':
        icon = Icons.rate_review;
        iconColor = Colors.orange;
        break;
      case 'hotspot':
        icon = Icons.local_cafe;
        iconColor = Colors.brown;
        break;
      case 'carpool':
        icon = Icons.directions_car;
        iconColor = Colors.indigo;
        break;
      case 'safe_return':
        icon = Icons.contact_emergency;
        iconColor = Colors.pink;
        break;
      case 'profile_exchange':
        icon = Icons.badge;
        iconColor = Colors.teal;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(),
          if (!isMe) const SizedBox(width: 8),
          if (isMe)
            Text(msg['time'] ?? '',
                style: TextStyle(fontSize: 10, color: textSecondary)),
          if (isMe) const SizedBox(width: 4),
          Container(
            width: 240,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: iconColor.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                    color: iconColor.withValues(alpha: 0.05), blurRadius: 10)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle),
                        child: Icon(icon, color: iconColor, size: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(msg['title'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(msg['desc'] ?? '',
                    style: TextStyle(
                        fontSize: 13, color: textSecondary, height: 1.4)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${msg['title']}에 반응했습니다!')));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: iconColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: const Text('반응하기',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          if (!isMe) const SizedBox(width: 4),
          if (!isMe)
            Text(msg['time'] ?? '',
                style: TextStyle(fontSize: 10, color: textSecondary)),
        ],
      ),
    );
  }

  Widget _buildImageMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true;
    final rawUrl = (msg['imageUrl'] ?? '').toString();
    final imageUrl = r2Storage.getPublicViewUrl(rawUrl);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(),
          if (!isMe) const SizedBox(width: 8),
          if (isMe)
            Text(msg['time'] ?? '방금',
                style: TextStyle(fontSize: 10, color: textSecondary)),
          if (isMe) const SizedBox(width: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
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
          if (!isMe) const SizedBox(width: 4),
          if (!isMe)
            Text(msg['time'] ?? '방금',
                style: TextStyle(fontSize: 10, color: textSecondary)),
        ],
      ),
    );
  }

  Widget _buildLocationMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true;
    final mapUrl = msg['mapUrl'] ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(),
          if (!isMe) const SizedBox(width: 8),
          if (isMe)
            Text(msg['time'] ?? '',
                style: TextStyle(fontSize: 10, color: textSecondary)),
          if (isMe) const SizedBox(width: 4),
          GestureDetector(
            onTap: () async {
              if (mapUrl.isNotEmpty) {
                final Uri url = Uri.parse(mapUrl);
                if (!await launchUrl(url))
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('지도를 열 수 없습니다.')));
              }
            },
            child: Container(
              width: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: accentColor, size: 20),
                      const SizedBox(width: 4),
                      const Text('현재 위치 공유',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 90,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBE6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFFEE500), width: 1.2),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE500),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2)),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on,
                                size: 14, color: Color(0xFF191919)),
                            SizedBox(width: 4),
                            Text('카카오맵에서 위치 보기',
                                style: TextStyle(
                                    color: Color(0xFF191919),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isMe) const SizedBox(width: 4),
          if (!isMe)
            Text(msg['time'] ?? '',
                style: TextStyle(fontSize: 10, color: textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20)),
          child: Text(text,
              style: TextStyle(
                  fontSize: 12, color: textPrimary.withValues(alpha: 0.8))),
        ),
      ),
    );
  }

  Widget _buildBlockedMessagePlaceholder(String sender) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5EA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.block, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '차단된 사용자($sender)의 메시지입니다.',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
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
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                '차단 해제',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChatRoomSafetyDrawer() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        builder: (ctx) => SafeArea(
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((_roomData?['title'] ?? widget.title).toString(),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text('${chatParticipantIds(_roomData).length}명 참여 중',
                            style: TextStyle(color: textSecondary)),
                        const SizedBox(height: 16),
                        const Text('메시지를 길게 누르면 복사하거나 신고·차단할 수 있어요.',
                            style: TextStyle(fontSize: 15, height: 1.5)),
                        const SizedBox(height: 16),
                        ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.exit_to_app),
                            title: const Text('대화방 나가기'),
                            subtitle: const Text('대화방에서 나가도 모임 신청은 취소되지 않아요.'),
                            onTap: () async {
                              Navigator.pop(ctx);
                              final leave = await showDialog<bool>(
                                  context: context,
                                  builder: (dialog) => AlertDialog(
                                          title: const Text('대화방에서 나갈까요?'),
                                          content: const Text(
                                              '다시 참여하려면 모임장의 대화방 연결이 필요해요.'),
                                          actions: [
                                            TextButton(
                                                onPressed: () => Navigator.pop(
                                                    dialog, false),
                                                child: const Text('취소')),
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(dialog, true),
                                                child: const Text('나가기'))
                                          ]));
                              if (leave != true || !mounted) return;
                              try {
                                await _repo.leave(widget.chatRoomId);
                                if (mounted) Navigator.pop(context);
                              } catch (_) {
                                _showFailure('대화방에서 나가지 못했어요. 다시 시도해 주세요.');
                              }
                            }),
                      ])),
            ));
  }

  void _showMessageActionSheet(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true;
    final text = msg['text'] ?? '';
    final sender = (msg['sender'] ?? '상대방').toString();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.copy, color: Colors.black87),
                  title: const Text('메시지 내용 복사',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('📋 메시지가 클립보드에 복사되었습니다.')),
                    );
                  },
                ),
                if (isMe) ...[
                  ListTile(
                    leading:
                        const Icon(Icons.delete_outline, color: Colors.red),
                    title: const Text('메시지 삭제',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w600)),
                    subtitle: const Text('이 메시지를 대화방에서 완전히 삭제합니다',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dCtx) => AlertDialog(
                          title: const Text('메시지를 삭제할까요?'),
                          content:
                              const Text('삭제된 메시지는 대화방 참여자 모두에게 더 이상 보이지 않아요.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dCtx, false),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(dCtx, true),
                              child: const Text('삭제',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && mounted) {
                        final msgId = (msg['id'] ?? '').toString();
                        if (msgId.isNotEmpty) {
                          try {
                            await _repo.deleteMessage(widget.chatRoomId, msgId);
                          } catch (_) {}
                        }
                        if (mounted) setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('메시지가 삭제되었습니다.')),
                        );
                      }
                    },
                  ),
                ],
                if (!isMe) ...[
                  ListTile(
                    leading: const Icon(Icons.flag_outlined, color: Colors.red),
                    title: const Text('이 메시지 신고하기',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w600)),
                    subtitle: const Text('부적절한 언어, 스팸, 혐오 표현 등',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    onTap: () {
                      Navigator.pop(ctx);
                      UgcActionSheets.showReportDialog(
                        context: context,
                        targetType: '채팅 메시지',
                        targetId: msg['id'] ??
                            'msg_${DateTime.now().millisecondsSinceEpoch}',
                        targetUser: sender,
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.block, color: Colors.deepOrange),
                    title: Text('$sender님 차단하기',
                        style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w600)),
                    subtitle: const Text('이 사용자의 모든 메시지가 즉시 가려집니다',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    onTap: () {
                      Navigator.pop(ctx);
                      UgcActionSheets.showBlockConfirmDialog(
                        context: context,
                        userName: sender,
                        onUserBlocked: () => setState(() {}),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true;
    final sender = (msg['sender'] ?? '이웃').toString();
    final senderAvatar =
        (msg['avatar'] ?? msg['senderAvatar'] ?? '').toString();
    final timeStr = (msg['time'] ?? '').toString();

    final bubbleRadius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          );

    final bubbleDecoration = isMe
        ? BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF25767), Color(0xFFFF6978)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: bubbleRadius,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF25767).withValues(alpha: 0.28),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          )
        : BoxDecoration(
            color: Colors.white,
            borderRadius: bubbleRadius,
            border: Border.all(color: const Color(0xFFF0E4E6), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF25767).withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          );
    final textColor = isMe ? Colors.white : const Color(0xFF191F28);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            _buildAvatar(avatarUrl: senderAvatar, name: sender),
            const SizedBox(width: 8),
          ],
          if (isMe && timeStr.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                timeStr,
                style: const TextStyle(fontSize: 11, color: Color(0xFF8C94A0)),
              ),
            ),
            const SizedBox(width: 6),
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
                      padding: const EdgeInsets.only(bottom: 5, left: 2),
                      child: Text(
                        sender,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE14D5D),
                        ),
                      ),
                    ),
                  GestureDetector(
                    onLongPress: () => _showMessageActionSheet(msg),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 11),
                      decoration: bubbleDecoration,
                      child: Text(
                        (msg['text'] ?? '').toString(),
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.45,
                          fontWeight: isMe ? FontWeight.w500 : FontWeight.w400,
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
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                timeStr,
                style: const TextStyle(fontSize: 11, color: Color(0xFF8C94A0)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar({String? avatarUrl, String? name}) {
    final avatar = (avatarUrl != null && avatarUrl.isNotEmpty)
        ? avatarUrl
        : 'assets/images/민지.png';
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFCD3D9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF25767).withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 17,
        backgroundColor: const Color(0xFFFFF0F2),
        backgroundImage: appImg(avatar),
      ),
    );
  }

  Widget _buildMessageInput() => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFF0E4E6), width: 1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 2, right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFCD3D9), width: 1),
                ),
                child: IconButton(
                  tooltip: '도구함 열기',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 40, minHeight: 40),
                  onPressed: _sending ? null : _showAttachmentMenu,
                  icon: const Icon(Icons.add_rounded,
                      color: Color(0xFFF25767), size: 24),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  style:
                      const TextStyle(fontSize: 14.5, color: Color(0xFF191F28)),
                  decoration: InputDecoration(
                    hintText: '메시지를 입력하세요...',
                    hintStyle:
                        const TextStyle(fontSize: 14, color: Color(0xFFA0A7B1)),
                    filled: true,
                    fillColor: const Color(0xFFFAF7F8),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 11),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide:
                          const BorderSide(color: Color(0xFFF0E4E6), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide:
                          const BorderSide(color: Color(0xFFF0E4E6), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(
                          color: Color(0xFFF25767), width: 1.5),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 2, left: 8),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF25767), Color(0xFFFF6978)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF25767).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  tooltip: '메시지 전송',
                  padding: EdgeInsets.zero,
                  onPressed: _sending ? null : _sendMessage,
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.arrow_upward_rounded,
                          color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),
      );

  void _showAiTopicsBottomSheet() {
    final topics = oomuAi.generateIcebreakerTopics(
        meetingTitle: widget.title, seedOffset: 0);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('편하게 꺼내볼 이야기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('질문을 고르면 입력창에 담겨요. 내용을 확인한 뒤 직접 보내세요.',
                  style: TextStyle(
                      fontSize: 15, height: 1.5, color: textSecondary)),
              const SizedBox(height: 16),
              FutureBuilder<List<Map<String, String>>>(
                  future: topics,
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return const Text('추천 질문을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.');
                    if (!snapshot.hasData)
                      return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()));
                    return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: snapshot.data!
                            .where((t) => (t['question'] ?? '').isNotEmpty)
                            .map((topic) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(topic['question']!,
                                      style: const TextStyle(
                                          fontSize: 15, height: 1.5)),
                                  trailing: const Icon(Icons.add),
                                  onTap: () {
                                    _controller.text = topic['question']!;
                                    Navigator.pop(ctx);
                                  },
                                ))
                            .toList());
                  }),
            ]),
      )),
    );
  }

  Widget _buildAiSpotSummaryCard(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true;
    final spotName = msg['spotName'] ?? '소소스팟';
    final summary = msg['summary'] ?? '';
    final parkingTip = msg['parkingTip'] ?? '';
    final popularMenu = msg['popularMenu'] ?? '';
    final vibe = msg['vibe'] ?? '';
    final List<dynamic> tags = msg['tags'] ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(name: msg['sender']),
          if (!isMe) const SizedBox(width: 8),
          if (isMe)
            Text(msg['time'] ?? '',
                style: TextStyle(fontSize: 10, color: textSecondary)),
          if (isMe) const SizedBox(width: 4),
          Container(
            width: 275,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.35),
                  width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome,
                          color: Color(0xFF0D9488), size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'AI 1분 맛집 · 스팟 브리핑',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCFBF1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'AI 요약',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F766E)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Spot Name
                Text(
                  spotName,
                  style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),

                // Briefing text
                Text(
                  summary,
                  style: const TextStyle(
                      fontSize: 12.5, height: 1.4, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 10),

                // Details container
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDFA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCCFBF1)),
                  ),
                  child: Column(
                    children: [
                      if (popularMenu.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🍽️ ', style: TextStyle(fontSize: 11)),
                            const Text('대표메뉴: ',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF134E4A))),
                            Expanded(
                              child: Text(popularMenu,
                                  style: const TextStyle(
                                      fontSize: 11, color: Color(0xFF134E4A))),
                            ),
                          ],
                        ),
                      if (parkingTip.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🚗 ', style: TextStyle(fontSize: 11)),
                            const Text('주차꿀팁: ',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF134E4A))),
                            Expanded(
                              child: Text(parkingTip,
                                  style: const TextStyle(
                                      fontSize: 11, color: Color(0xFF134E4A))),
                            ),
                          ],
                        ),
                      ],
                      if (vibe.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('✨ ', style: TextStyle(fontSize: 11)),
                            const Text('분위기: ',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF134E4A))),
                            Expanded(
                              child: Text(vibe,
                                  style: const TextStyle(
                                      fontSize: 11, color: Color(0xFF134E4A))),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: tags
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                t.toString(),
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w600),
                              ),
                            ))
                        .toList(),
                  ),
                ],

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () => KakaoMapService.launchDirections(spotName),
                    icon: const Icon(Icons.directions_rounded,
                        size: 14, color: Color(0xFF191919)),
                    label: const Text('카카오 길찾기 연동',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF191919))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEE500),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isMe) const SizedBox(width: 4),
          if (!isMe)
            Text(msg['time'] ?? '',
                style: TextStyle(fontSize: 10, color: textSecondary)),
        ],
      ),
    );
  }
}

// ===========================================================================
// 동적 컴포넌트: 일정 참석 투표 카드
// ===========================================================================
class InteractiveScheduleCard extends StatefulWidget {
  final Map<String, dynamic> msg;
  final bool isMe;
  final String chatRoomId;
  final Function(Map<String, dynamic> delta)? onUpdate;

  const InteractiveScheduleCard({
    super.key,
    required this.msg,
    required this.isMe,
    required this.chatRoomId,
    this.onUpdate,
  });

  @override
  State<InteractiveScheduleCard> createState() =>
      _InteractiveScheduleCardState();
}

class _InteractiveScheduleCardState extends State<InteractiveScheduleCard> {
  @override
  Widget build(BuildContext context) {
    final currentNick = globalData.userNickname.value.isNotEmpty
        ? globalData.userNickname.value
        : '우리동네민우';
    final int maxMembers = widget.msg['maxMembers'] ?? 4;
    final List<String> attendees = List<String>.from(
        widget.msg['attendees'] ?? [widget.msg['sender'] ?? '우리동네민우']);
    final bool isAttending = attendees.contains(currentNick);
    final int attendCount = attendees.length;
    final bool isFull = attendCount >= maxMembers && !isAttending;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe)
            const CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/images/민지.png')),
          if (!widget.isMe) const SizedBox(width: 8),
          if (widget.isMe)
            Text(widget.msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (widget.isMe) const SizedBox(width: 4),
          Container(
            width: 270,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.35), width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.12),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.calendar_month,
                          color: Colors.blue, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.msg['title'] ?? '새로운 일정 제안',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (attendCount >= maxMembers)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6)),
                        child: const Text('마감됨',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      Row(children: [
                        const Icon(Icons.event, size: 14, color: Colors.blue),
                        const SizedBox(width: 6),
                        const Text('날짜: ',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(widget.msg['date'] ?? '-',
                            style: const TextStyle(fontSize: 12)),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.access_time,
                            size: 14, color: Colors.blue),
                        const SizedBox(width: 6),
                        const Text('시간: ',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(widget.msg['timeStr'] ?? widget.msg['time'] ?? '-',
                            style: const TextStyle(fontSize: 12)),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.place, size: 14, color: Colors.blue),
                        const SizedBox(width: 6),
                        const Text('장소: ',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(widget.msg['location'] ?? '-',
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.group, size: 14, color: Color(0xFF767676)),
                        SizedBox(width: 4),
                        Text('참석 확정 현황',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF767676))),
                      ],
                    ),
                    Text('$attendCount / $maxMembers 명',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (attendCount / maxMembers).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                        attendCount >= maxMembers ? Colors.green : Colors.blue),
                    minHeight: 6,
                  ),
                ),
                if (attendees.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: attendees
                        .map((name) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text('✓ $name',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600)),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isFull) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('모집 인원이 마감되었습니다!')));
                        return;
                      }
                      final newAttendees = List<String>.from(attendees);
                      if (isAttending) {
                        newAttendees.remove(currentNick);
                      } else {
                        newAttendees.add(currentNick);
                      }
                      if (widget.onUpdate != null) {
                        widget.onUpdate!({'attendees': newAttendees});
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(!isAttending
                                ? '👍 모임 참석이 확정되었습니다!'
                                : '일정 참석을 취소했습니다.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAttending
                          ? const Color(0xFFF0F0F0)
                          : (isFull ? Colors.grey[300] : Colors.blue),
                      foregroundColor:
                          isAttending ? Colors.black87 : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      isAttending
                          ? '참석 취소하기'
                          : (isFull ? '모집 마감' : '👍 저도 참석할게요!'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!widget.isMe) const SizedBox(width: 4),
          if (!widget.isMe)
            Text(widget.msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
        ],
      ),
    );
  }
}

// ===========================================================================
// 동적 컴포넌트: 안건 투표 카드
// ===========================================================================
class InteractivePollCard extends StatefulWidget {
  final Map<String, dynamic> msg;
  final bool isMe;
  final String chatRoomId;
  final Function(Map<String, dynamic> delta)? onUpdate;

  const InteractivePollCard({
    super.key,
    required this.msg,
    required this.isMe,
    required this.chatRoomId,
    this.onUpdate,
  });

  @override
  State<InteractivePollCard> createState() => _InteractivePollCardState();
}

class _InteractivePollCardState extends State<InteractivePollCard> {
  @override
  Widget build(BuildContext context) {
    final currentNick = globalData.userNickname.value.isNotEmpty
        ? globalData.userNickname.value
        : '우리동네민우';
    final voters = widget.msg['voters'] != null
        ? Map<String, dynamic>.from(widget.msg['voters'])
        : <String, dynamic>{};
    final int? selectedOption = voters[currentNick] as int?;

    final int opt1Count = voters.values.where((v) => v == 1).length;
    final int opt2Count = voters.values.where((v) => v == 2).length;
    final int totalVotes = opt1Count + opt2Count;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe)
            const CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/images/민지.png')),
          if (!widget.isMe) const SizedBox(width: 8),
          if (widget.isMe)
            Text(widget.msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (widget.isMe) const SizedBox(width: 4),
          Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: Colors.purple.withValues(alpha: 0.35), width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.12),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.how_to_vote,
                          color: Colors.purple, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.msg['title'] ?? '투표',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('실시간 실명 투표',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text('총 $totalVotes명 참여',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildPollOption(1, widget.msg['opt1'] ?? '옵션 1', opt1Count,
                    totalVotes, selectedOption == 1, currentNick, voters),
                const SizedBox(height: 8),
                _buildPollOption(2, widget.msg['opt2'] ?? '옵션 2', opt2Count,
                    totalVotes, selectedOption == 2, currentNick, voters),
              ],
            ),
          ),
          if (!widget.isMe) const SizedBox(width: 4),
          if (!widget.isMe)
            Text(widget.msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
        ],
      ),
    );
  }

  Widget _buildPollOption(
      int optionIndex,
      String text,
      int count,
      int totalVotes,
      bool isSelected,
      String currentNick,
      Map<String, dynamic> voters) {
    final double percent = totalVotes > 0 ? (count / totalVotes) : 0.0;

    return GestureDetector(
      onTap: () {
        final newVoters = Map<String, dynamic>.from(voters);
        if (isSelected) {
          newVoters.remove(currentNick);
        } else {
          newVoters[currentNick] = optionIndex;
        }
        if (widget.onUpdate != null) {
          widget.onUpdate!({'voters': newVoters});
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.purple.withValues(alpha: 0.08)
              : const Color(0xFFF7F7F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isSelected
                  ? Colors.purple
                  : Colors.grey.withValues(alpha: 0.2),
              width: isSelected ? 1.5 : 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 16,
                          color: isSelected ? Colors.purple : Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? Colors.purple
                                : const Color(0xFF222222),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Text('$count명',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.purple : Colors.grey[700])),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(isSelected
                    ? Colors.purple
                    : Colors.purple.withValues(alpha: 0.5)),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 동적 컴포넌트: 1/N 더치페이 정산 카드
// ===========================================================================
class InteractiveHotspotCard extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMe;

  const InteractiveHotspotCard(
      {super.key, required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final String name = msg['name'] ?? '핫플 이름';
    final String address = msg['address'] ?? '주소 정보 없음';
    final double? lat = (msg['lat'] as num?)?.toDouble();
    final double? lng = (msg['lng'] as num?)?.toDouble();

    // 실제 카카오맵 링크 생성 (이름과 좌표 포함)
    final String kakaoMapUrl = (lat != null && lng != null)
        ? KakaoMapService.getKakaoMapPinUrl(name, lat, lng)
        : KakaoMapService.getKakaoSearchUrl('$name $address');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            const CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/images/민지.png')),
          if (!isMe) const SizedBox(width: 8),
          if (isMe)
            Text(msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (isMe) const SizedBox(width: 4),
          Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.brown.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                    color: Colors.brown.withValues(alpha: 0.05), blurRadius: 10)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: Colors.brown.withValues(alpha: 0.1),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.local_cafe,
                            color: Colors.brown, size: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(msg['title'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87)),
                const SizedBox(height: 4),
                Text(address,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF767676))),
                const SizedBox(height: 12),

                // 미니 지도 썸네일
                GestureDetector(
                  onTap: () async {
                    final Uri url = Uri.parse(kakaoMapUrl);
                    if (!await launchUrl(url))
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('지도를 열 수 없습니다.')));
                  },
                  child: Container(
                    height: 90,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBE6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFFEE500), width: 1.2),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE500),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2)),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on,
                                size: 14, color: Color(0xFF191919)),
                            SizedBox(width: 4),
                            Text('카카오맵에서 위치 보기',
                                style: TextStyle(
                                    color: Color(0xFF191919),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isMe) const SizedBox(width: 4),
          if (!isMe)
            Text(msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
        ],
      ),
    );
  }
}

// ===========================================================================
// 동적 컴포넌트: 리뷰 공유 카드
// ===========================================================================
class InteractiveReviewCard extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMe;

  const InteractiveReviewCard(
      {super.key, required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final int rating = msg['rating'] ?? 5;
    final String text = msg['text'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            const CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/images/민지.png')),
          if (!isMe) const SizedBox(width: 8),
          if (isMe)
            Text(msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (isMe) const SizedBox(width: 4),
          Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.05),
                    blurRadius: 10)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.rate_review,
                            color: Colors.orange, size: 16)),
                    const SizedBox(width: 8),
                    const Expanded(
                        child: Text('✨ 모임 후기가 도착했어요!',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: List.generate(
                      5,
                      (index) => Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.orange,
                            size: 20,
                          )),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(text,
                      style: const TextStyle(
                          fontSize: 14, color: Colors.black87, height: 1.4)),
                ),
              ],
            ),
          ),
          if (!isMe) const SizedBox(width: 4),
          if (!isMe)
            Text(msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
        ],
      ),
    );
  }
}

// ===========================================================================
// 동적 컴포넌트: 안전 귀가 (Safe Return)
// ===========================================================================
class InteractiveSafeReturnCard extends StatefulWidget {
  final Map<String, dynamic> msg;
  final bool isMe;
  final String chatRoomId;
  final Function(Map<String, dynamic> delta)? onUpdate;

  const InteractiveSafeReturnCard({
    super.key,
    required this.msg,
    required this.isMe,
    required this.chatRoomId,
    this.onUpdate,
  });

  @override
  State<InteractiveSafeReturnCard> createState() =>
      _InteractiveSafeReturnCardState();
}

class _InteractiveSafeReturnCardState extends State<InteractiveSafeReturnCard> {
  @override
  Widget build(BuildContext context) {
    final currentNick = globalData.userNickname.value.isNotEmpty
        ? globalData.userNickname.value
        : '우리동네민우';
    final List<String> cheers = List<String>.from(widget.msg['cheers'] ?? []);
    final bool isLiked = cheers.contains(currentNick);
    final int likes = cheers.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe)
            const CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/images/민지.png')),
          if (!widget.isMe) const SizedBox(width: 8),
          if (widget.isMe)
            Text(widget.msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (widget.isMe) const SizedBox(width: 4),
          Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F5),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: Colors.pink.withValues(alpha: 0.35), width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: Colors.pink.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.pink.withValues(alpha: 0.15),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.nightlight_round,
                          color: Colors.pink, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.msg['title'] ?? '🏠 안전 귀가 알림',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.pink),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.msg['desc'] ?? '방금 집에 무사히 도착했습니다! 다들 조심히 들어가세요.',
                  style: const TextStyle(
                      fontSize: 13, height: 1.4, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () {
                    final newCheers = List<String>.from(cheers);
                    if (isLiked) {
                      newCheers.remove(currentNick);
                    } else {
                      newCheers.add(currentNick);
                    }
                    if (widget.onUpdate != null) {
                      widget.onUpdate!({'cheers': newCheers});
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(!isLiked
                            ? '💖 무사 귀가를 축하해 주셨습니다!'
                            : '안심 반응을 취소했습니다.'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isLiked ? Colors.pink : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.pink),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite,
                            color: isLiked ? Colors.white : Colors.pink,
                            size: 16),
                        const SizedBox(width: 6),
                        Text('다행이에요! $likes',
                            style: TextStyle(
                                color: isLiked ? Colors.white : Colors.pink,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!widget.isMe) const SizedBox(width: 4),
          if (!widget.isMe)
            Text(widget.msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
        ],
      ),
    );
  }
}

// ===========================================================================
// 동적 컴포넌트: 프로필 교환 (Profile Exchange)
// ===========================================================================
class InteractiveProfileExchangeCard extends StatefulWidget {
  final Map<String, dynamic> msg;
  final bool isMe;
  final String chatRoomId;
  final Function(Map<String, dynamic> delta)? onUpdate;

  const InteractiveProfileExchangeCard({
    super.key,
    required this.msg,
    required this.isMe,
    required this.chatRoomId,
    this.onUpdate,
  });

  @override
  State<InteractiveProfileExchangeCard> createState() =>
      _InteractiveProfileExchangeCardState();
}

class _InteractiveProfileExchangeCardState
    extends State<InteractiveProfileExchangeCard> {
  void _showProfileModal(String nickname) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundImage: AssetImage('assets/images/민지.png'),
              ),
              const SizedBox(height: 12),
              Text(nickname,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('인증된 이웃 · 매너온도 41.2℃ 🔥',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.teal,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12)),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified_user, color: Colors.teal, size: 16),
                        SizedBox(width: 6),
                        Text('OOMU 본인 인증 및 매너 검증 완료',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text('관심사: 맛집 탐방, 주말 러닝, 로컬 아지트 탐험',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF555555))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('닫기',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentNick = globalData.userNickname.value.isNotEmpty
        ? globalData.userNickname.value
        : '이웃';
    final List<String> acceptedMembers =
        List<String>.from(widget.msg['acceptedMembers'] ?? []);
    final bool isAccepted =
        acceptedMembers.isNotEmpty || widget.msg['status'] == 'accepted';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe)
            const CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/images/민지.png')),
          if (!widget.isMe) const SizedBox(width: 8),
          if (widget.isMe)
            Text(widget.msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (widget.isMe) const SizedBox(width: 4),
          Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)]),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.teal.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.badge, color: Colors.teal, size: 26)),
                const SizedBox(height: 10),
                Text(widget.msg['title'] ?? '명함/프로필 교환',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.teal)),
                const SizedBox(height: 6),
                Text(widget.msg['desc'] ?? '서로의 상세 프로필과 소셜 정보를 확인해볼까요?',
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black87)),
                const SizedBox(height: 14),
                if (isAccepted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showProfileModal(widget.msg['sender'] ?? '상대방'),
                      icon: const Icon(Icons.person,
                          size: 16, color: Colors.white),
                      label: const Text('교환 완료 · 프로필 보기 🤝',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                    ),
                  )
                else if (!widget.isMe)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final newAccepted = List<String>.from(acceptedMembers)
                          ..add(currentNick);
                        if (widget.onUpdate != null) {
                          widget.onUpdate!({
                            'acceptedMembers': newAccepted,
                            'status': 'accepted'
                          });
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('🎉 프로필 교환을 수락했습니다! 상세 프로필이 공개됩니다.')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Text('수락하기 🤝',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Center(
                        child: Text('상대방의 수락을 대기중입니다...',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.teal,
                                fontWeight: FontWeight.bold))),
                  ),
              ],
            ),
          ),
          if (!widget.isMe) const SizedBox(width: 4),
          if (!widget.isMe)
            Text(widget.msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
        ],
      ),
    );
  }
}

// ===========================================================================
// 동적 컴포넌트: 시크릿 애프터 1:1 호감 매칭 (Secret After Match)
// ===========================================================================
class InteractiveSecretAfterMatchCard extends StatefulWidget {
  final Map<String, dynamic> msg;
  final bool isMe;
  final String? chatRoomId;
  final Function(Map<String, dynamic> delta)? onUpdate;

  const InteractiveSecretAfterMatchCard({
    super.key,
    required this.msg,
    required this.isMe,
    this.chatRoomId,
    this.onUpdate,
  });

  @override
  State<InteractiveSecretAfterMatchCard> createState() =>
      _InteractiveSecretAfterMatchCardState();
}

class _InteractiveSecretAfterMatchCardState
    extends State<InteractiveSecretAfterMatchCard> {
  final List<Map<String, String>> _candidates = [
    {'name': '민지', 'tag': '여수 신기동 · 카페/베이킹', 'avatar': 'assets/images/민지.png'},
    {'name': '지훈', 'tag': '여수 웅천동 · 한강 러닝', 'avatar': 'assets/images/지훈.png'},
    {'name': '지연', 'tag': '여수 여서동 · 와인/다이닝', 'avatar': 'assets/images/지연.png'},
  ];

  final Set<String> _selectedMembers = {};
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    final choices = widget.msg['secretChoices'];
    if (choices is List) {
      _selectedMembers.addAll(choices.map((e) => e.toString()));
      if (_selectedMembers.isNotEmpty) {
        _isSubmitted = true;
      }
    }
  }

  void _toggleMember(String name) {
    if (_isSubmitted) return;
    setState(() {
      if (_selectedMembers.contains(name)) {
        _selectedMembers.remove(name);
      } else {
        if (_selectedMembers.length >= 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('시크릿 애프터 호감은 최대 2명까지만 선택할 수 있습니다.')),
          );
          return;
        }
        _selectedMembers.add(name);
      }
    });
  }

  void _submitSecretAfter() {
    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('호감을 표시할 멤버를 1명 이상 선택해 주세요!')),
      );
      return;
    }

    setState(() {
      _isSubmitted = true;
    });

    if (widget.onUpdate != null) {
      widget.onUpdate!({
        'secretChoices': _selectedMembers.toList(),
        'submittedAt': DateTime.now().toIso8601String(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '💌 ${_selectedMembers.join(", ")}님에게 비공개 호감이 전달되었습니다! (0% 노출 보장)'),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }

  void _simulateMutualMatch() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.pinkAccent),
            SizedBox(width: 8),
            Text('💖 시크릿 매칭 성사!',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage: AssetImage('assets/images/민지.png'),
            ),
            SizedBox(height: 12),
            Text(
              '민지님도 당신에게 호감을 표시했습니다! 💕',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '두 분만의 1:1 소개팅 단독 대화방이 생성되었습니다.\n자연스럽게 대화를 이어가 보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('💬 1:1 시크릿 소개팅 대화방으로 이동합니다!'),
                    backgroundColor: Colors.pinkAccent,
                  ),
                );
              },
              child: const Text('1:1 소개팅 대화방 열기 💬',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF0F5), Color(0xFFFFE4E1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.pinkAccent.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.pinkAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '시크릿 애프터 1:1 호감 매칭',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC2185B)),
                        ),
                        Text(
                          '상호 선택 시에만 1:1 대화방 개설 (거절 부담 0%)',
                          style:
                              TextStyle(fontSize: 11, color: Color(0xFF880E4F)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                '오늘 모임에서 대화가 가장 잘 통했던 멤버 1~2명을 선택하세요.',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333)),
              ),
              const SizedBox(height: 12),
              Column(
                children: _candidates.map((cand) {
                  final isSelected = _selectedMembers.contains(cand['name']);
                  return GestureDetector(
                    onTap: () => _toggleMember(cand['name']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? Colors.pinkAccent
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                    color: Colors.pinkAccent
                                        .withValues(alpha: 0.2),
                                    blurRadius: 8)
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: appImg(cand['avatar']!),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cand['name']!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                                Text(
                                  cand['tag']!,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isSelected ? Icons.favorite : Icons.favorite_border,
                            color: isSelected ? Colors.pinkAccent : Colors.grey,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              if (!_isSubmitted)
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _submitSecretAfter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      '비공개 호감 전달하기 (${_selectedMembers.length}명 선택)',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                )
              else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, size: 16, color: Colors.pinkAccent),
                      SizedBox(width: 6),
                      Text(
                        '💌 비공개 호감 전송 완료! (상대방 응답 대기 중)',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.pinkAccent,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: _simulateMutualMatch,
                    icon: const Icon(Icons.flash_on,
                        size: 16, color: Colors.purple),
                    label: const Text(
                      '🧪 상호 매칭 성사 시뮬레이션 테스트',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
