import '../services/kakao_map_service.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/app_image.dart';
import '../utils/global_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../services/r2_storage_service.dart';
import '../widgets/ugc_action_sheets.dart';
import '../services/ai_service.dart';
/// 대화방 메시지 메모리/로컬 영구 캐시 저장소 (뒤로가기 후 재입장 시에도 메시지 및 사진 100% 보존)
class OOMUChatStore extends ChangeNotifier {
  static final OOMUChatStore _instance = OOMUChatStore._internal();
  factory OOMUChatStore() => _instance;

  final Map<String, List<Map<String, dynamic>>> _messagesByRoom = {};
  final Map<String, Map<String, dynamic>> _roomMetadata = {};
  final Set<String> _leftRoomIds = {};
  bool _persistenceInitialized = false;

  OOMUChatStore._internal() {
    _initPersistence();
  }

  void _initPersistence() {
    if (_persistenceInitialized) return;
    _persistenceInitialized = true;
    try {
      final myUid = globalData.activeUserId;
      void loadFromDoc(String docId) {
        FirebaseFirestore.instance
            .collection('user_states')
            .doc(docId)
            .get()
            .then((snap) {
          if (snap.exists && snap.data() != null) {
            final data = snap.data()!;
            if (data['leftRoomIds'] is List) {
              final List<dynamic> list = data['leftRoomIds'];
              for (var id in list) {
                final str = id.toString();
                _leftRoomIds.add(str);
                _leftRoomIds.add(canonicalRoomId(str));
              }
              notifyListeners();
            }
          }
        }).catchError((_) {});
      }
      loadFromDoc(myUid);
      if (myUid != 'user_me_01') loadFromDoc('user_me_01');

      void listenToDoc(String docId) {
        FirebaseFirestore.instance
            .collection('user_states')
            .doc(docId)
            .snapshots()
            .listen((snap) {
          if (snap.exists && snap.data() != null) {
            final data = snap.data()!;
            if (data['leftRoomIds'] is List) {
              final List<dynamic> list = data['leftRoomIds'];
              for (var id in list) {
                final str = id.toString();
                _leftRoomIds.add(str);
                _leftRoomIds.add(canonicalRoomId(str));
              }
              notifyListeners();
            }
          }
        }, onError: (_) {});
      }
      listenToDoc(myUid);
      if (myUid != 'user_me_01') listenToDoc('user_me_01');
    } catch (_) {}
  }

  bool isRoomLeft(String roomId) {
    _initPersistence();
    final cId = canonicalRoomId(roomId);
    return _leftRoomIds.contains(cId) || _leftRoomIds.contains(roomId);
  }

  Future<void> leaveRoom(String roomId) async {
    final cId = canonicalRoomId(roomId);
    _leftRoomIds.add(cId);
    _leftRoomIds.add(roomId);

    final list = _messagesByRoom[cId];
    if (list != null) {
      list.add({
        'id': 'msg_sys_left_${DateTime.now().millisecondsSinceEpoch}',
        'type': 'system',
        'text': '대화방을 나갔습니다.',
        'time': '방금',
      });
    }
    notifyListeners();

    try {
      final myUid = globalData.activeUserId;
      // 1. Persist to current user's state in Firestore
      await FirebaseFirestore.instance.collection('user_states').doc(myUid).set({
        'leftRoomIds': FieldValue.arrayUnion([cId, roomId]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (myUid != 'user_me_01') {
        await FirebaseFirestore.instance.collection('user_states').doc('user_me_01').set({
          'leftRoomIds': FieldValue.arrayUnion([cId, roomId]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // 2. Mark user in chatRooms collection
      await FirebaseFirestore.instance.collection('chatRooms').doc(cId).set({
        'leftUserIds': FieldValue.arrayUnion([myUid, 'user_me_01']),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 3. If it is a meetup in meetups collection, update participants
      final meetupDoc = await FirebaseFirestore.instance.collection('meetups').doc(cId).get();
      if (meetupDoc.exists) {
        await FirebaseFirestore.instance.collection('meetups').doc(cId).update({
          'participants': FieldValue.arrayRemove([myUid, 'user_me_01']),
        });
      }
    } catch (e) {
      debugPrint('Firestore leaveRoom persist error: $e');
    }
  }

  Future<void> rejoinRoom(String roomId) async {
    final cId = canonicalRoomId(roomId);
    _leftRoomIds.remove(cId);
    _leftRoomIds.remove(roomId);
    notifyListeners();

    try {
      final myUid = globalData.activeUserId;
      await FirebaseFirestore.instance.collection('user_states').doc(myUid).set({
        'leftRoomIds': FieldValue.arrayRemove([cId, roomId]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (myUid != 'user_me_01') {
        await FirebaseFirestore.instance.collection('user_states').doc('user_me_01').set({
          'leftRoomIds': FieldValue.arrayRemove([cId, roomId]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await FirebaseFirestore.instance.collection('chatRooms').doc(cId).set({
        'leftUserIds': FieldValue.arrayRemove([myUid, 'user_me_01']),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore rejoinRoom error: $e');
    }
  }

  /// 더미 모임 ID와 채팅방 ID 간의 양방향 정규화 매퍼
  String canonicalRoomId(String id) {
    if (id == 'dummy_meetup_01' || id == 'meetup_chat_room_01') return 'room_mala_01';
    if (id == 'dummy_meetup_02') return 'room_cafe_02';
    if (id == 'dummy_meetup_03') return 'room_wine_03';
    return id;
  }

  List<Map<String, dynamic>> getRoomMessages(String roomId, String title) {
    final cId = canonicalRoomId(roomId);
    if (!_messagesByRoom.containsKey(cId)) {
      _messagesByRoom[cId] = [
        {'id': 'msg_sys_01', 'type': 'system', 'text': '$title 모임 대화방이 개설되었습니다. 🎉', 'time': '오후 2:20'},
        {'id': 'msg_sys_02', 'type': 'system', 'text': '우리동네민우님이 참여 승인되어 합류했습니다! 🎉', 'time': '오후 2:25'},
        {'id': 'msg_txt_01', 'type': 'text', 'sender': '매운맛킬러', 'text': '안녕하세요! 다들 마라탕 좋아하시죠?', 'isMe': false, 'time': '오후 2:30'},
        {'id': 'msg_txt_02', 'type': 'text', 'sender': '우리동네민우', 'text': '완전완전 좋아합니다ㅎㅎ 잘 부탁드려요!', 'isMe': true, 'time': '오후 2:32'},
        {'id': 'msg_txt_03', 'type': 'text', 'sender': '매운맛킬러', 'text': '그럼 이번주 토요일 6시에 홍대에서 봬요!', 'isMe': false, 'time': '오후 2:35'},
        {
          'id': 'msg_sched_01',
          'type': 'schedule',
          'sender': '매운맛킬러',
          'title': '이번 주 토요일 첫 정기 모임',
          'date': '10월 24일 (토)',
          'timeStr': '오후 6:00',
          'location': '홍대입구역 9번 출구 앞 서교동 마라토끼',
          'maxMembers': 4,
          'attendees': ['매운맛킬러', '우리동네민우'],
          'isMe': false,
          'time': '오후 2:38'
        },
        {
          'id': 'msg_poll_01',
          'type': 'poll',
          'sender': '매운맛킬러',
          'title': '저녁 식사 후 2차 장소 투표 🍻',
          'opt1': '분위기 좋은 성수 루프탑 펍',
          'opt2': '조용하고 감성적인 디저트 카페',
          'voters': {'매운맛킬러': 1},
          'isMe': false,
          'time': '오후 2:40'
        },
        {
          'id': 'msg_settle_01',
          'type': 'settlement',
          'sender': '매운맛킬러',
          'title': '1차 마라탕 & 꿔바로우 1/N 정산',
          'total': 68000,
          'perPerson': 17000,
          'totalMembers': 4,
          'accountBank': '카카오뱅크 3333-01-2345678 (예금주: 모임장)',
          'paidMembers': ['매운맛킬러'],
          'isMe': false,
          'time': '오후 7:15'
        },
        {
          'id': 'msg_safe_01',
          'type': 'safe_return',
          'sender': '매운맛킬러',
          'title': '🏠 안전 귀가 알림',
          'desc': '다들 오늘 너무 반가웠어요! 방금 집에 무사히 도착했습니다.',
          'cheers': ['우리동네민우'],
          'isMe': false,
          'time': '오후 10:15'
        },
        {
          'id': 'msg_profile_01',
          'type': 'profile_exchange',
          'sender': '매운맛킬러',
          'title': '🤝 명함/프로필 교환 요청',
          'desc': '서로의 상세 프로필과 소셜 정보를 확인해볼까요?',
          'acceptedMembers': [],
          'status': 'pending',
          'isMe': false,
          'time': '오후 10:20'
        },
        {
          'id': 'msg_secret_01',
          'type': 'secret_after',
          'sender': '매운맛킬러',
          'title': '💖 시크릿 애프터 1:1 호감 매칭',
          'desc': '오늘 모임은 어떠셨나요? 마음이 통했던 멤버 1~2명을 비공개로 선택해 보세요.',
          'isMe': false,
          'time': '오후 10:30'
        },
      ];
    }
    return _messagesByRoom[cId]!;
  }

  void addMessage(String roomId, Map<String, dynamic> msg, {String? roomTitle}) {
    final cId = canonicalRoomId(roomId);
    final list = _messagesByRoom.putIfAbsent(cId, () => []);
    list.add(msg);

    final lastText = formatLastMessage(msg);
    _roomMetadata[cId] = {
      'id': cId,
      'title': roomTitle,
      'lastMessage': lastText,
      'time': msg['time'] ?? '방금',
      'updatedAt': DateTime.now(),
    };

    notifyListeners();
  }

  void updateMessage(String roomId, String messageId, Map<String, dynamic> delta) {
    final cId = canonicalRoomId(roomId);
    final list = _messagesByRoom[cId];
    if (list != null) {
      final idx = list.indexWhere((m) => m['id'] == messageId);
      if (idx >= 0) {
        list[idx] = {...list[idx], ...delta};
        notifyListeners();
      }
    }
  }

  String formatLastMessage(Map<String, dynamic> msg) {
    if (msg['type'] == 'image') return '📸 사진을 보냈습니다';
    if (msg['type'] == 'location') return '📍 현재 위치를 공유했습니다';
    if (msg['type'] == 'schedule') return '📅 상세 일정을 제안했습니다';
    if (msg['type'] == 'poll') return '📊 투표를 등록했습니다';
    if (msg['type'] == 'settlement') return '💰 1/N 정산을 요청했습니다';
    if (msg['type'] == 'safe_return') return '🏠 안심 귀가 알림이 도착했습니다';
    if (msg['type'] == 'profile_exchange') return '🤝 프로필 교환을 요청했습니다';
    if (msg['type'] == 'secret_after') return '💖 시크릿 애프터 호감 매칭이 오픈되었습니다';
    if (msg['type'] == 'hotspot') return '☕ 핫플 정보를 공유했습니다';
    if (msg['type'] == 'review') return '⭐ 모임 후기를 남겼습니다';
    return (msg['text'] ?? '').toString();
  }

  String getLastMessageText(String roomId) {
    final cId = canonicalRoomId(roomId);
    if (_roomMetadata.containsKey(cId) && _roomMetadata[cId]!['lastMessage'] != null) {
      final text = _roomMetadata[cId]!['lastMessage'].toString();
      if (text.isNotEmpty) return text;
    }
    final list = _messagesByRoom[cId];
    if (list == null || list.isEmpty) return '';
    return formatLastMessage(list.last);
  }

  String getLastMessageTime(String roomId, String defaultTime) {
    final cId = canonicalRoomId(roomId);
    if (_roomMetadata.containsKey(cId) && _roomMetadata[cId]!['time'] != null) {
      return _roomMetadata[cId]!['time'].toString();
    }
    final list = _messagesByRoom[cId];
    if (list != null && list.isNotEmpty) {
      return (list.last['time'] ?? defaultTime).toString();
    }
    return defaultTime;
  }

  DateTime? getRoomUpdatedAt(String roomId) {
    final cId = canonicalRoomId(roomId);
    if (_roomMetadata.containsKey(cId) && _roomMetadata[cId]!['updatedAt'] != null) {
      return _roomMetadata[cId]!['updatedAt'] as DateTime;
    }
    return null;
  }
}

final oomuChatStore = OOMUChatStore();

class OOMUChatScreen extends StatefulWidget {
  final String title;
  final int memberCount;
  final String chatRoomId; 

  const OOMUChatScreen({
    super.key, 
    required this.title, 
    required this.memberCount,
    this.chatRoomId = 'test_room_01', 
  });

  @override
  State<OOMUChatScreen> createState() => _OOMUChatScreenState();
}

class _OOMUChatScreenState extends State<OOMUChatScreen> {
  final Color textPrimary = const Color(0xFF111111);
  final Color textSecondary = const Color(0xFF767676);
  final Color surfaceColor = const Color(0xFFF5F5F7);
  final Color accentColor = const Color(0xFFF19E39);
  
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Stream<QuerySnapshot>? _firebaseMessageStream;
  late List<Map<String, dynamic>> _messages;

  // AI 소셜 인텔리전스 어시스턴트 상태
  bool _showAiIcebreakerBanner = true;
  bool _isLoadingAiTopics = false;
  List<Map<String, String>> _aiTopics = [];

  Future<void> _loadAiTopics({int offset = 0}) async {
    setState(() => _isLoadingAiTopics = true);
    try {
      final topics = await oomuAi.generateIcebreakerTopics(
        meetingTitle: widget.title,
        seedOffset: offset,
      );
      if (mounted) {
        setState(() {
          _aiTopics = topics;
          _isLoadingAiTopics = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingAiTopics = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAiTopics();
    final cId = oomuChatStore.canonicalRoomId(widget.chatRoomId);
    _messages = List<Map<String, dynamic>>.from(
      oomuChatStore.getRoomMessages(cId, widget.title)
    );
    try {
      _firebaseMessageStream = FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(cId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots();
      _seedInitialMessageIfEmpty();
    } catch (e) {
      _firebaseMessageStream = null;
    }
  }

  Future<void> _seedInitialMessageIfEmpty() async {
    try {
      final cId = oomuChatStore.canonicalRoomId(widget.chatRoomId);
      final msgColl = FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(cId)
          .collection('messages');
      final snap = await msgColl.limit(1).get();
      if (snap.docs.isEmpty) {
        final initialList = oomuChatStore.getRoomMessages(cId, widget.title);
        for (final item in initialList) {
          final id = item['id'] ?? 'seed_${DateTime.now().millisecondsSinceEpoch}';
          await msgColl.doc(id).set({
            ...item,
            'id': id,
            'createdAt': DateTime.now().toIso8601String(),
            'timestamp': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {
      debugPrint('Firestore seed message note: $e');
    }
  }

  void _addMessage(Map<String, dynamic> msgData) {
    final cId = oomuChatStore.canonicalRoomId(widget.chatRoomId);
    final currentNick = globalData.userNickname.value.isNotEmpty ? globalData.userNickname.value : '우리동네민우';
    final msgId = msgData['id'] ?? 'msg_${DateTime.now().millisecondsSinceEpoch}';
    final newMsg = {
      ...msgData,
      'id': msgId,
      'time': '방금',
      'isMe': true,
      'sender': currentNick,
    };
    setState(() {
      oomuChatStore.addMessage(cId, newMsg, roomTitle: widget.title);
      _messages = List<Map<String, dynamic>>.from(
        oomuChatStore.getRoomMessages(cId, widget.title)
      );
    });
    _scrollToBottom();
    
    try {
      final roomDoc = FirebaseFirestore.instance.collection('chatRooms').doc(cId);
      final lastPreview = oomuChatStore.formatLastMessage(newMsg);

      // 1. 부모 채팅방 메타데이터 업데이트 (채팅 목록의 최근 메시지 및 최신순 정렬에 직결)
      roomDoc.set({
        'id': cId,
        'title': widget.title,
        'lastMessage': lastPreview,
        'time': '방금',
        'members': widget.memberCount,
        'isGroup': widget.memberCount > 2,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. 메시지 서브컬렉션에 메시지 저장 (deterministic document ID)
      roomDoc.collection('messages').doc(msgId).set({
        ...newMsg,
        'createdAt': DateTime.now().toIso8601String(),
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firebase chat update error: $e');
    }
  }

  Future<void> _updateMessageData(String messageId, Map<String, dynamic> delta) async {
    final cId = oomuChatStore.canonicalRoomId(widget.chatRoomId);
    
    // 1. In-memory update via oomuChatStore & local state immediately
    oomuChatStore.updateMessage(cId, messageId, delta);
    if (mounted) {
      setState(() {
        final idx = _messages.indexWhere((m) => m['id'] == messageId);
        if (idx >= 0) {
          _messages[idx] = {..._messages[idx], ...delta};
        }
      });
    }

    // 2. Persist to Firestore
    try {
      final docRef = FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(cId)
          .collection('messages')
          .doc(messageId);
      await docRef.set(delta, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[Firestore Chat] _updateMessageData note: $e');
    }
  }

  void _sendMessage({String? customText}) {
    final textToSend = (customText ?? _controller.text).trim();
    if (textToSend.isEmpty) return;
    _addMessage({'type': 'text', 'text': textToSend});
    if (customText == null) {
      _controller.clear();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
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
            const SnackBar(content: Text('⚠️ 사진 파일(JPG, PNG, WEBP 등)만 전송할 수 있습니다.')),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('☁️ Cloudflare R2로 사진을 업로드하고 있습니다...'),
            duration: Duration(seconds: 2),
          ),
        );

        final bytes = await image.readAsBytes();
        String downloadUrl = '';
        try {
          downloadUrl = await r2Storage.uploadImageBytes(
            bytes: bytes,
            fileName: image.name,
            category: R2UploadCategory.chatPhoto,
          );
        } catch (e) {
          debugPrint('[R2 Chat Image] Upload fallback: $e');
          downloadUrl = image.path;
        }

        final finalUrl = downloadUrl.isNotEmpty ? downloadUrl : image.path;
        _addMessage({'type': 'image', 'imageUrl': finalUrl});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사진 업로드 실패: $e')),
        );
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('대화방 사진 공유 (Cloudflare R2)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
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
                          border: Border.all(color: const Color(0xFFFF5E36).withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.photo_camera_rounded, color: Color(0xFFFF5E36), size: 24),
                            const SizedBox(height: 6),
                            const Text('사진 찍기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('카메라 촬영', style: TextStyle(fontSize: 11, color: textSecondary)),
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
                          border: Border.all(color: const Color(0xFFF38020).withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.photo_library_rounded, color: Color(0xFFF38020), size: 24),
                            const SizedBox(height: 6),
                            const Text('사진 불러오기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('갤러리/앨범', style: TextStyle(fontSize: 11, color: textSecondary)),
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('위치 권한이 거부되었습니다.')));
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('현재 위치를 빠르게 가져오는 중입니다...')));
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
      final String kakaoMapUrl = 'https://map.kakao.com/link/map/내_현재_위치,${position.latitude},${position.longitude}';
      
      _addMessage({'type': 'location', 'latitude': position.latitude, 'longitude': position.longitude, 'mapUrl': kakaoMapUrl});
    } catch (e) {
      _addMessage({'type': 'location', 'mapUrl': 'https://map.kakao.com/'});
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
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
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
                          Text('상세 일정 제안하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Date Picker
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('날짜 선택', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(selectedDate != null ? '${selectedDate!.year}년 ${selectedDate!.month}월 ${selectedDate!.day}일' : '터치하여 날짜를 선택하세요'),
                        trailing: const Icon(Icons.edit_calendar, color: Colors.blue),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) setState(() => selectedDate = date);
                        },
                      ),
                      const Divider(),
                      
                      // Time Picker
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('시간 선택', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(selectedTime != null ? selectedTime!.format(context) : '터치하여 시간을 선택하세요'),
                        trailing: const Icon(Icons.access_time, color: Colors.blue),
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
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Max Members
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('모임 인원', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          DropdownButton<int>(
                            value: maxMembers,
                            items: [2,3,4,5,6,7,8].map((e) => DropdownMenuItem(value: e, child: Text('$e명'))).toList(),
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
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: () {
                            if (selectedDate == null || selectedTime == null || location.trim().isEmpty) {
                              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('날짜, 시간, 장소를 모두 입력해주세요.')));
                              return;
                            }
                            Navigator.pop(ctx);
                            _addMessage({
                              'type': 'schedule',
                              'title': '새로운 일정이 제안되었습니다!',
                              'date': '${selectedDate!.month}월 ${selectedDate!.day}일',
                              'timeStr': selectedTime!.format(ctx),
                              'location': location,
                              'maxMembers': maxMembers,
                            });
                          },
                          child: const Text('일정 공유 및 투표 시작', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        );
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
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [Icon(Icons.how_to_vote, color: Colors.purple), SizedBox(width: 8), Text('투표 만들기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))],
                ),
                const SizedBox(height: 24),
                TextField(controller: titleCtrl, decoration: InputDecoration(labelText: '투표 주제', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 16),
                TextField(controller: opt1Ctrl, decoration: InputDecoration(labelText: '옵션 1', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 12),
                TextField(controller: opt2Ctrl, decoration: InputDecoration(labelText: '옵션 2', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      if (titleCtrl.text.isEmpty || opt1Ctrl.text.isEmpty || opt2Ctrl.text.isEmpty) {
                         ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('모든 항목을 입력해주세요.')));
                         return;
                      }
                      Navigator.pop(ctx);
                      _addMessage({'type': 'poll', 'title': '📊 ${titleCtrl.text}', 'opt1': opt1Ctrl.text, 'opt2': opt2Ctrl.text});
                    },
                    child: const Text('투표 등록', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      'desc': '서로의 상세 프로필을 확인해볼까요?'
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
                final places = await KakaoMapService.searchKeyword(query, size: 10);
                if (mounted) {
                  setState(() {
                    searchResults = places.map((item) {
                      return {
                        'name': item.name,
                        'category': item.category.isNotEmpty ? item.category : (selectedCategory == '전체' ? '모임장소' : selectedCategory),
                        'address': item.roadAddress.isNotEmpty ? item.roadAddress : item.address,
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
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                height: MediaQuery.of(ctx).size.height * 0.7,
                padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [Icon(Icons.travel_explore, color: Colors.brown), SizedBox(width: 8), Text('실시간 장소 검색 (전국)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))],
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                                if(selected) setState(() => selectedCategory = category);
                              },
                              selectedColor: Colors.brown.withOpacity(0.2),
                              labelStyle: TextStyle(color: isSelected ? Colors.brown : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    Expanded(
                      child: isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.brown))
                        : searchResults.isEmpty 
                          ? const Center(child: Text('장소 이름이나 지역을 검색해보세요.'))
                          : ListView.builder(
                              itemCount: searchResults.length,
                              itemBuilder: (context, index) {
                                final place = searchResults[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                                  leading: Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(color: Colors.brown.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.place, color: Colors.brown),
                                  ),
                                  title: Text(place['name'], style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  subtitle: Text('${place['category']} • ${place['address']}', style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  trailing: ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
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
                                    child: const Text('공유', style: TextStyle(color: Colors.white, fontSize: 12)),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
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
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [Icon(Icons.rate_review, color: Colors.orange), SizedBox(width: 8), Text('모임 후기 남기기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))],
                    ),
                    const SizedBox(height: 8),
                    const Text('이번 모임은 어떠셨나요? 별점과 솔직한 후기를 남겨주세요.\n작성하신 별점은 상대방의 매너 온도에 즉시 반영됩니다.', style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
                    const SizedBox(height: 24),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () => setState(() => selectedStars = index + 1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                index < selectedStars ? Icons.star : Icons.star_border,
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () {
                          if (textCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('후기 내용을 입력해주세요.')));
                            return;
                          }
                          Navigator.pop(ctx);
                          
                          // 글로벌 상태 업데이트 (매너 온도 및 평점 즉시 반영!)
                          globalData.submitReview(selectedStars.toDouble(), textCtrl.text);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('후기가 프로필에 반영되었습니다!')));
                          
                          _addMessage({
                            'type': 'review',
                            'rating': selectedStars,
                            'text': textCtrl.text,
                          });
                        },
                        child: const Text('후기 공유하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  void _showSettlementCreatorBottomSheet() {
    Navigator.pop(context);
    final TextEditingController titleCtrl = TextEditingController(text: '1차 모임 식비 정산');
    final TextEditingController totalCtrl = TextEditingController();
    final TextEditingController bankCtrl = TextEditingController(text: '카카오뱅크 3333-01-2345678 (예금주: 모임장)');
    int memberCount = widget.memberCount > 0 ? widget.memberCount : 4;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          int parsedTotal = int.tryParse(totalCtrl.text.replaceAll(',', '').replaceAll('원', '').trim()) ?? 0;
          int perPerson = memberCount > 0 && parsedTotal > 0 ? (parsedTotal / memberCount).ceil() : 0;
          final formattedPerPerson = perPerson.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(24),
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFFF19E39).withOpacity(0.15), shape: BoxShape.circle),
                            child: const Icon(Icons.payments, color: Color(0xFFF19E39), size: 22),
                          ),
                          const SizedBox(width: 10),
                          const Text('1/N 더치페이 정산 요청', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleCtrl,
                        decoration: InputDecoration(
                          labelText: '정산 항목 / 모임 내용',
                          hintText: '예: 1차 마라탕 & 꿔바로우',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: totalCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (val) => setModalState(() {}),
                        decoration: InputDecoration(
                          labelText: '총 지출 금액 (원)',
                          hintText: '예: 68000',
                          suffixText: '원',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: bankCtrl,
                        decoration: InputDecoration(
                          labelText: '입금 계좌번호 (은행 + 계좌번호 + 예금주)',
                          hintText: '예: 카카오뱅크 3333-01-2345678 (홍길동)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7EE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF19E39).withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('정산 인원 ($memberCount명 1/N)', style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
                                Text('${memberCount}명', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('1인당 보낼 금액', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                Text(
                                  '${formattedPerPerson}원',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFF19E39)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF19E39),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            if (titleCtrl.text.trim().isEmpty || parsedTotal <= 0) {
                              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('정산 내용과 총 금액을 입력해주세요.')));
                              return;
                            }
                            Navigator.pop(ctx);
                            final currentNick = globalData.userNickname.value.isNotEmpty ? globalData.userNickname.value : '우리동네민우';
                            _addMessage({
                              'type': 'settlement',
                              'title': titleCtrl.text.trim(),
                              'total': parsedTotal,
                              'perPerson': perPerson,
                              'accountBank': bankCtrl.text.trim(),
                              'totalMembers': memberCount,
                              'paidMembers': [currentNick],
                            });
                          },
                          child: const Text('1/N 정산 요청 등록', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Wrap(
            spacing: 24,
            runSpacing: 32,
            alignment: WrapAlignment.start,
            children: [
              _buildAttachmentIcon(Icons.image, '사진', Colors.green, onTap: _sendImageAction),
              _buildAttachmentIcon(Icons.location_on, '현재 위치', Colors.redAccent, onTap: _sendLocationAction),
              _buildAttachmentIcon(Icons.rate_review, '모임후기', Colors.orange, onTap: _showReviewBottomSheet),
              _buildAttachmentIcon(Icons.calendar_month, '일정', Colors.blue, onTap: _showScheduleCreatorBottomSheet),
              _buildAttachmentIcon(Icons.how_to_vote, '투표', Colors.purple, onTap: _showPollCreatorBottomSheet),
              _buildAttachmentIcon(Icons.payments, '더치페이', const Color(0xFFF19E39), onTap: _showSettlementCreatorBottomSheet), 
              _buildAttachmentIcon(Icons.local_cafe, '핫플 공유', Colors.brown, onTap: _showHotspotSearchBottomSheet),
              _buildAttachmentIcon(Icons.directions_car, '동행/드라이브', Colors.indigo, onTap: () {
                Navigator.pop(ctx);
                _addMessage({'type': 'carpool', 'title': '🚗 오늘 저녁 드라이브 가실 분?', 'desc': '목적지: 북악스카이웨이'});
              }),
              _buildAttachmentIcon(Icons.contact_emergency, '안전귀가', Colors.pink, onTap: _showSafeReturnBottomSheet),
              _buildAttachmentIcon(Icons.badge, '프로필 교환', Colors.teal, onTap: _showProfileExchangeBottomSheet),
              _buildAttachmentIcon(Icons.favorite_rounded, '시크릿 애프터', Colors.pinkAccent, onTap: () {
                Navigator.pop(ctx);
                _addMessage({
                  'type': 'secret_after',
                  'title': '💖 시크릿 애프터 1:1 호감 매칭',
                  'desc': '모임 종료 후 비공개 호감 매칭이 오픈되었습니다! 마음에 드는 멤버를 선택해 보세요.',
                });
              }),
              _buildAttachmentIcon(Icons.auto_awesome, 'AI 대화추천', const Color(0xFF6366F1), onTap: () {
                Navigator.pop(ctx);
                _showAiTopicsBottomSheet();
              }),
              _buildAttachmentIcon(Icons.summarize_rounded, '1분 맛집요약', const Color(0xFF0D9488), onTap: () {
                Navigator.pop(ctx);
                _sendAiSpotSummaryAction();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentIcon(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label 기능이 준비중입니다.')));
      },
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${widget.memberCount}명 참여중', style: TextStyle(color: textSecondary, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.menu, color: textPrimary), onPressed: _showChatRoomSafetyDrawer),
        ],
      ),
      body: Column(
        children: [
          FixedPromiseHeader(
            chatRoomId: widget.chatRoomId,
            currentUserName: globalData.userNickname.value,
          ),
          if (_showAiIcebreakerBanner) _buildAiIcebreakerBanner(),
          Expanded(
            child: _firebaseMessageStream == null
                ? _buildMessageList(_messages) 
                : StreamBuilder<QuerySnapshot>(
                    stream: _firebaseMessageStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        final docs = snapshot.data!.docs;
                        final currentNick = globalData.userNickname.value;
                        final firestoreMsgs = docs.map((d) {
                          final data = Map<String, dynamic>.from(d.data() as Map<String, dynamic>);
                          data['id'] = d.id;
                          if (data['sender'] == currentNick || data['sender'] == '우리동네민우' || data['isMe'] == true) {
                            data['isMe'] = true;
                          }
                          return data;
                        }).toList();
                        return _buildMessageList(firestoreMsgs);
                      }
                      return _buildMessageList(_messages);
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<Map<String, dynamic>> list) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final msg = list[index];
        return _buildDynamicMessage(msg);
      },
    );
  }

  Widget _buildDynamicMessage(Map<String, dynamic> data) {
    final type = data['type'] ?? 'text';
    final msgId = (data['id'] ?? '').toString();
    final isMe = data['isMe'] == true || data['sender'] == globalData.userNickname.value || data['sender'] == '우리동네민우';
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
    if (type == 'settlement') return InteractiveSettlementCard(msg: data, isMe: isMe, chatRoomId: widget.chatRoomId, onUpdate: updateThisMessage);
    if (type == 'image') return _buildImageMessage(data);
    if (type == 'location') return _buildLocationMessage(data);
    
    if (type == 'schedule') return InteractiveScheduleCard(msg: data, isMe: isMe, chatRoomId: widget.chatRoomId, onUpdate: updateThisMessage);
    if (type == 'poll') return InteractivePollCard(msg: data, isMe: isMe, chatRoomId: widget.chatRoomId, onUpdate: updateThisMessage);
    
    if (type == 'hotspot') return InteractiveHotspotCard(msg: data, isMe: isMe);
    if (type == 'review') return InteractiveReviewCard(msg: data, isMe: isMe);
    
    if (type == 'safe_return') return InteractiveSafeReturnCard(msg: data, isMe: isMe, chatRoomId: widget.chatRoomId, onUpdate: updateThisMessage);
    if (type == 'profile_exchange') return InteractiveProfileExchangeCard(msg: data, isMe: isMe, chatRoomId: widget.chatRoomId, onUpdate: updateThisMessage);
    if (type == 'secret_after') return InteractiveSecretAfterMatchCard(msg: data, isMe: isMe, chatRoomId: widget.chatRoomId, onUpdate: updateThisMessage);
    if (['carpool'].contains(type)) {
      return _buildInteractiveCardMessage(data);
    }
    return _buildTextMessage(data);
  }

  Widget _buildInteractiveCardMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true;
    IconData icon = Icons.info;
    Color iconColor = accentColor;

    switch(msg['type']) {
      case 'review': icon = Icons.rate_review; iconColor = Colors.orange; break;
      case 'hotspot': icon = Icons.local_cafe; iconColor = Colors.brown; break;
      case 'carpool': icon = Icons.directions_car; iconColor = Colors.indigo; break;
      case 'safe_return': icon = Icons.contact_emergency; iconColor = Colors.pink; break;
      case 'profile_exchange': icon = Icons.badge; iconColor = Colors.teal; break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(),
          if (!isMe) const SizedBox(width: 8),
          if (isMe) Text(msg['time'] ?? '', style: TextStyle(fontSize: 10, color: textSecondary)),
          if (isMe) const SizedBox(width: 4),
          
          Container(
            width: 240,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: iconColor.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: iconColor.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 16)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(msg['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(msg['desc'] ?? '', style: TextStyle(fontSize: 13, color: textSecondary, height: 1.4)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${msg['title']}에 반응했습니다!')));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: iconColor, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('반응하기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),

          if (!isMe) const SizedBox(width: 4),
          if (!isMe) Text(msg['time'] ?? '', style: TextStyle(fontSize: 10, color: textSecondary)),
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
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(),
          if (!isMe) const SizedBox(width: 8),
          if (isMe) Text(msg['time'] ?? '방금', style: TextStyle(fontSize: 10, color: textSecondary)),
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
          if (!isMe) Text(msg['time'] ?? '방금', style: TextStyle(fontSize: 10, color: textSecondary)),
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
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(),
          if (!isMe) const SizedBox(width: 8),
          if (isMe) Text(msg['time'] ?? '', style: TextStyle(fontSize: 10, color: textSecondary)),
          if (isMe) const SizedBox(width: 4),
          GestureDetector(
            onTap: () async {
              if (mapUrl.isNotEmpty) {
                final Uri url = Uri.parse(mapUrl);
                if (!await launchUrl(url)) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('지도를 열 수 없습니다.')));
              }
            },
            child: Container(
              width: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: accentColor, size: 20),
                      const SizedBox(width: 4),
                      const Text('현재 위치 공유', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 90, width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBE6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFEE500), width: 1.2),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE500),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on, size: 14, color: Color(0xFF191919)),
                            SizedBox(width: 4),
                            Text('카카오맵에서 위치 보기', style: TextStyle(color: Color(0xFF191919), fontSize: 12, fontWeight: FontWeight.w800)),
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
          if (!isMe) Text(msg['time'] ?? '', style: TextStyle(fontSize: 10, color: textSecondary)),
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
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(text, style: TextStyle(fontSize: 12, color: textPrimary.withOpacity(0.8))),
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
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChatRoomSafetyDrawer() {
    final participants = [
      {'name': '우리동네민우', 'avatar': 'assets/images/kr_male_1.jpg', 'role': '방장', 'manner': '42.5°C'},
      {'name': '매운맛킬러', 'avatar': 'assets/images/kr_female_1.jpg', 'role': '참여자', 'manner': '41.2°C'},
      {'name': '러닝조아', 'avatar': 'assets/images/kr_female_3.jpg', 'role': '참여자', 'manner': '39.8°C'},
      {'name': '카페탐방러', 'avatar': 'assets/images/kr_male_2.jpg', 'role': '참여자', 'manner': '40.5°C'},
    ];
    final currentNick = globalData.userNickname.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.72,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Row(
                            children: [
                              Icon(Icons.shield_outlined, size: 14, color: Colors.teal),
                              SizedBox(width: 4),
                              Text('24시간 AI & 운영진 실시간 보호 중', style: TextStyle(fontSize: 12, color: Colors.teal, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                ),
                const Divider(),
                
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('대화 참여자 (${participants.length}명)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const Text('불쾌한 상대는 차단/신고하세요', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                
                Expanded(
                  child: ListView.builder(
                    itemCount: participants.length,
                    itemBuilder: (context, index) {
                      final p = participants[index];
                      final name = p['name']!;
                      final isMe = name == currentNick || (name == '우리동네민우' && currentNick.isEmpty);
                      final isBlocked = globalData.isUserBlocked(name);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: appImg(p['avatar']!),
                        ),
                        title: Row(
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            if (isMe)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                child: const Text('나', style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                              ),
                            const Spacer(),
                            Text(p['manner']!, style: const TextStyle(fontSize: 12, color: Colors.deepOrange, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        subtitle: Text(p['role']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        trailing: isMe
                            ? null
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () {
                                      if (isBlocked) {
                                        globalData.unblockUser(name);
                                        setSheetState(() {});
                                        setState(() {});
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('🎉 $name님의 차단이 해제되었습니다.')),
                                        );
                                      } else {
                                        UgcActionSheets.showBlockConfirmDialog(
                                          context: context,
                                          userName: name,
                                          onUserBlocked: () {
                                            setSheetState(() {});
                                            setState(() {});
                                          },
                                        );
                                      }
                                    },
                                    child: Text(
                                      isBlocked ? '차단 해제' : '차단',
                                      style: TextStyle(
                                        color: isBlocked ? Colors.grey : Colors.redAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(Icons.flag_outlined, size: 18, color: Colors.grey),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      UgcActionSheets.showReportDialog(
                                        context: context,
                                        targetType: '사용자',
                                        targetId: 'chat_user_$name',
                                        targetUser: name,
                                      );
                                    },
                                  ),
                                ],
                              ),
                      );
                    },
                  ),
                ),
                
                const Divider(height: 1),
                
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.report_problem_outlined, size: 16, color: Colors.red),
                          label: const Text('대화방 신고', style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            UgcActionSheets.showReportDialog(
                              context: context,
                              targetType: '채팅방',
                              targetId: widget.chatRoomId,
                              targetUser: '모임 대화방',
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.exit_to_app, size: 16, color: Colors.white),
                          label: const Text('대화방 나가기', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE11D48),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (dialogCtx) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: const Row(
                                  children: [
                                    Icon(Icons.exit_to_app, color: Color(0xFFE11D48)),
                                    SizedBox(width: 8),
                                    Text('대화방 나가기', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                                  ],
                                ),
                                content: Text(
                                  '\'${widget.title}\' 대화방을 나가시겠습니까?\n\n대화방을 나가면 채팅 목록에서 삭제되며 대화 내용과 참여 내역이 모두 초기화됩니다.',
                                  style: const TextStyle(fontSize: 14, color: Color(0xFF635559), height: 1.5),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogCtx),
                                    child: const Text('취소', style: TextStyle(color: Color(0xFF767676), fontWeight: FontWeight.w600)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE11D48),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 0,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(dialogCtx);
                                      Navigator.pop(ctx);
                                      oomuChatStore.leaveRoom(widget.chatRoomId);
                                      Navigator.pop(context, true);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('\'${widget.title}\' 대화방을 나갔습니다.'),
                                          backgroundColor: const Color(0xFF221B1D),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    child: const Text('나가기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMessageActionSheet(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true;
    final text = msg['text'] ?? '';
    final sender = (msg['sender'] ?? '상대방').toString();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.black87),
                title: const Text('메시지 내용 복사', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('📋 메시지가 클립보드에 복사되었습니다.')),
                  );
                },
              ),
              if (!isMe) ...[
                ListTile(
                  leading: const Icon(Icons.flag_outlined, color: Colors.red),
                  title: const Text('이 메시지 신고하기', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                  subtitle: const Text('부적절한 언어, 스팸, 혐오 표현 등', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  onTap: () {
                    Navigator.pop(ctx);
                    UgcActionSheets.showReportDialog(
                      context: context,
                      targetType: '채팅 메시지',
                      targetId: msg['id'] ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
                      targetUser: sender,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block, color: Colors.deepOrange),
                  title: Text('$sender님 차단하기', style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w600)),
                  subtitle: const Text('이 사용자의 모든 메시지가 즉시 가려집니다', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
    );
  }

  Widget _buildTextMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] == true;
    final sender = (msg['sender'] ?? '상대방').toString();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(name: sender),
          if (!isMe) const SizedBox(width: 8),
          if (isMe) Text(msg['time'] ?? '', style: TextStyle(fontSize: 10, color: textSecondary)),
          if (isMe) const SizedBox(width: 4),
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageActionSheet(msg),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isMe ? accentColor : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                    bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Text(msg['text'] ?? '', style: TextStyle(color: isMe ? Colors.white : textPrimary, fontSize: 15, height: 1.4)),
              ),
            ),
          ),
          if (!isMe) const SizedBox(width: 4),
          if (!isMe) Text(msg['time'] ?? '', style: TextStyle(fontSize: 10, color: textSecondary)),
        ],
      ),
    );
  }

  Widget _buildAvatar({String? name}) {
    return GestureDetector(
      onTap: () {
        if (name != null && name != globalData.userNickname.value && name != '우리동네민우') {
          UgcActionSheets.showUserOptions(
            context: context,
            userName: name,
            onUserBlocked: () => setState(() {}),
          );
        }
      },
      child: const CircleAvatar(radius: 16, backgroundImage: AssetImage('assets/images/kr_female_1.jpg')),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            GestureDetector(
              onTap: _showAttachmentMenu,
              child: Container(width: 40, height: 40, decoration: BoxDecoration(color: surfaceColor, shape: BoxShape.circle), child: Icon(Icons.add, color: textSecondary)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24)),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: '메시지 보내기', hintStyle: TextStyle(color: textSecondary, fontSize: 15), border: InputBorder.none),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(width: 40, height: 40, decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle), child: const Icon(Icons.send, color: Colors.white, size: 20)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiIcebreakerBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFFDF4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC7D2FE), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Top Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, color: Color(0xFF6366F1), size: 14),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'AI 대화 어시스턴트 · 오늘의 추천 토픽',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4338CA),
                    ),
                  ),
                ),
                if (_isLoadingAiTopics)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6366F1)),
                  )
                else
                  InkWell(
                    onTap: () => _loadAiTopics(offset: DateTime.now().millisecond),
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF6366F1)),
                    ),
                  ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => setState(() => _showAiIcebreakerBanner = false),
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),

          // 3 Topic Questions
          if (_aiTopics.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _aiTopics.map((topic) {
                    final badge = topic['badge'] ?? '💡 대화주제';
                    final question = topic['question'] ?? '';
                    final reason = topic['reason'] ?? '';

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _sendMessage(customText: question);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('💡 "$badge" 질문을 대화창에 보냈습니다!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 240),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE0E7FF)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      badge,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4F46E5),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.touch_app_rounded, size: 11, color: Color(0xFF818CF8)),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  question,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                    height: 1.25,
                                  ),
                                ),
                                if (reason.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    reason,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Quick Action Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _sendAiSpotSummaryAction,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_rounded, size: 13, color: Color(0xFF0D9488)),
                          SizedBox(width: 4),
                          Text(
                            '📍 맛집 1분 요약 공유',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => _loadAiTopics(offset: DateTime.now().millisecond),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh_rounded, size: 13, color: Color(0xFF6366F1)),
                          SizedBox(width: 4),
                          Text(
                            '🔄 다른 주제 추천',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4338CA)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAiTopicsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome, color: Color(0xFF6366F1), size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI 대화 아이스브레이킹 추천',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '원하는 질문을 누르면 대화창에 즉시 전송됩니다',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._aiTopics.map((topic) {
                      final badge = topic['badge'] ?? '💡 대화주제';
                      final question = topic['question'] ?? '';
                      final reason = topic['reason'] ?? '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          title: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  badge,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  question,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                if (reason.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    '🎯 의도: $reason',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          trailing: const Icon(Icons.send_rounded, color: Color(0xFF6366F1), size: 20),
                          onTap: () {
                            Navigator.pop(ctx);
                            _sendMessage(customText: question);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('💡 "$badge" 질문을 대화창에 전송했습니다!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await _loadAiTopics(offset: DateTime.now().millisecond);
                          setModalState(() {});
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF6366F1)),
                        label: const Text(
                          '새로운 질문 추천받기',
                          style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF6366F1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _sendAiSpotSummaryAction() {
    String spot = widget.title;
    if (spot.contains('성수') || spot.contains('맛집') || spot.contains('다이닝')) {
      spot = '성수 소소스팟 비스트로';
    } else if (spot.contains('카페') || spot.contains('커피')) {
      spot = '성수 아틀리에 카페';
    } else if (spot.contains('러닝') || spot.contains('한강')) {
      spot = '뚝섬 한강공원 러닝코스';
    } else if (spot.contains('콘서트') || spot.contains('공연')) {
      spot = '올림픽공원 KSPO DOME';
    } else {
      spot = '성수 소소스팟 핫플레이스';
    }

    final summary = oomuAi.getSpotDetailedSummary(spot);

    _addMessage({
      'type': 'ai_spot_summary',
      'title': '📍 AI 1분 스팟/맛집 브리핑',
      'spotName': summary['spotName'] ?? spot,
      'summary': summary['summary'] ?? '',
      'parkingTip': summary['parkingTip'] ?? '',
      'popularMenu': summary['popularMenu'] ?? '',
      'vibe': summary['vibe'] ?? '',
      'tags': summary['tags'] ?? ['#인기스팟', '#소소플레이스'],
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📍 AI 1분 맛집 요약 카드가 채팅방에 공유되었습니다!'),
        duration: Duration(seconds: 2),
      ),
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
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(name: msg['sender']),
          if (!isMe) const SizedBox(width: 8),
          if (isMe) Text(msg['time'] ?? '', style: TextStyle(fontSize: 10, color: textSecondary)),
          if (isMe) const SizedBox(width: 4),

          Container(
            width: 275,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.35), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D9488).withOpacity(0.08),
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
                        color: const Color(0xFF0D9488).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome, color: Color(0xFF0D9488), size: 16),
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
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCFBF1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'AI 요약',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Spot Name
                Text(
                  spotName,
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),

                // Briefing text
                Text(
                  summary,
                  style: const TextStyle(fontSize: 12.5, height: 1.4, color: Color(0xFF334155)),
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
                            const Text('대표메뉴: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF134E4A))),
                            Expanded(
                              child: Text(popularMenu, style: const TextStyle(fontSize: 11, color: Color(0xFF134E4A))),
                            ),
                          ],
                        ),
                      if (parkingTip.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🚗 ', style: TextStyle(fontSize: 11)),
                            const Text('주차꿀팁: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF134E4A))),
                            Expanded(
                              child: Text(parkingTip, style: const TextStyle(fontSize: 11, color: Color(0xFF134E4A))),
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
                            const Text('분위기: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF134E4A))),
                            Expanded(
                              child: Text(vibe, style: const TextStyle(fontSize: 11, color: Color(0xFF134E4A))),
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
                    children: tags.map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        t.toString(),
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                      ),
                    )).toList(),
                  ),
                ],

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('🗺️ $spotName 지도 및 길찾기로 연결합니다.')),
                      );
                    },
                    icon: const Icon(Icons.map_rounded, size: 14, color: Colors.white),
                    label: const Text('지도 · 길찾기 연동', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (!isMe) const SizedBox(width: 4),
          if (!isMe) Text(msg['time'] ?? '', style: TextStyle(fontSize: 10, color: textSecondary)),
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
  State<InteractiveScheduleCard> createState() => _InteractiveScheduleCardState();
}

class _InteractiveScheduleCardState extends State<InteractiveScheduleCard> {
  @override
  Widget build(BuildContext context) {
    final currentNick = globalData.userNickname.value.isNotEmpty ? globalData.userNickname.value : '우리동네민우';
    final int maxMembers = widget.msg['maxMembers'] ?? 4;
    final List<String> attendees = List<String>.from(widget.msg['attendees'] ?? [widget.msg['sender'] ?? '우리동네민우']);
    final bool isAttending = attendees.contains(currentNick);
    final int attendCount = attendees.length;
    final bool isFull = attendCount >= maxMembers && !isAttending;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe) const CircleAvatar(radius: 16, backgroundImage: AssetImage('assets/images/kr_female_1.jpg')),
          if (!widget.isMe) const SizedBox(width: 8),
          if (widget.isMe) Text(widget.msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (widget.isMe) const SizedBox(width: 4),

          Container(
            width: 270,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.blue.withOpacity(0.35), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.12), shape: BoxShape.circle),
                      child: const Icon(Icons.calendar_month, color: Colors.blue, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.msg['title'] ?? '새로운 일정 제안',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (attendCount >= maxMembers)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)),
                        child: const Text('마감됨', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      Row(children: [
                        const Icon(Icons.event, size: 14, color: Colors.blue),
                        const SizedBox(width: 6),
                        const Text('날짜: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(widget.msg['date'] ?? '-', style: const TextStyle(fontSize: 12)),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.blue),
                        const SizedBox(width: 6),
                        const Text('시간: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(widget.msg['timeStr'] ?? widget.msg['time'] ?? '-', style: const TextStyle(fontSize: 12)),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.place, size: 14, color: Colors.blue),
                        const SizedBox(width: 6),
                        const Text('장소: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(widget.msg['location'] ?? '-', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
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
                        Text('참석 확정 현황', style: TextStyle(fontSize: 12, color: Color(0xFF767676))),
                      ],
                    ),
                    Text('$attendCount / $maxMembers 명', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (attendCount / maxMembers).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(attendCount >= maxMembers ? Colors.green : Colors.blue),
                    minHeight: 6,
                  ),
                ),
                if (attendees.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: attendees.map((name) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
                      child: Text('✓ $name', style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.w600)),
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isFull) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('모집 인원이 마감되었습니다!')));
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
                        SnackBar(content: Text(!isAttending ? '👍 모임 참석이 확정되었습니다!' : '일정 참석을 취소했습니다.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAttending ? const Color(0xFFF0F0F0) : (isFull ? Colors.grey[300] : Colors.blue),
                      foregroundColor: isAttending ? Colors.black87 : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      isAttending ? '참석 취소하기' : (isFull ? '모집 마감' : '👍 저도 참석할게요!'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (!widget.isMe) const SizedBox(width: 4),
          if (!widget.isMe) Text(widget.msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
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
    final currentNick = globalData.userNickname.value.isNotEmpty ? globalData.userNickname.value : '우리동네민우';
    final voters = widget.msg['voters'] != null ? Map<String, dynamic>.from(widget.msg['voters']) : <String, dynamic>{};
    final int? selectedOption = voters[currentNick] as int?;
    
    final int opt1Count = voters.values.where((v) => v == 1).length;
    final int opt2Count = voters.values.where((v) => v == 2).length;
    final int totalVotes = opt1Count + opt2Count;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe) const CircleAvatar(radius: 16, backgroundImage: AssetImage('assets/images/kr_female_1.jpg')),
          if (!widget.isMe) const SizedBox(width: 8),
          if (widget.isMe) Text(widget.msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (widget.isMe) const SizedBox(width: 4),

          Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.purple.withOpacity(0.35), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.purple.withOpacity(0.12), shape: BoxShape.circle),
                      child: const Icon(Icons.how_to_vote, color: Colors.purple, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.msg['title'] ?? '투표',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('실시간 실명 투표', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text('총 $totalVotes명 참여', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildPollOption(1, widget.msg['opt1'] ?? '옵션 1', opt1Count, totalVotes, selectedOption == 1, currentNick, voters),
                const SizedBox(height: 8),
                _buildPollOption(2, widget.msg['opt2'] ?? '옵션 2', opt2Count, totalVotes, selectedOption == 2, currentNick, voters),
              ],
            ),
          ),

          if (!widget.isMe) const SizedBox(width: 4),
          if (!widget.isMe) Text(widget.msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
        ],
      ),
    );
  }

  Widget _buildPollOption(int optionIndex, String text, int count, int totalVotes, bool isSelected, String currentNick, Map<String, dynamic> voters) {
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
          color: isSelected ? Colors.purple.withOpacity(0.08) : const Color(0xFFF7F7F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.purple : Colors.grey.withOpacity(0.2), width: isSelected ? 1.5 : 1.0),
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
                      Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, size: 16, color: isSelected ? Colors.purple : Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.purple : const Color(0xFF222222),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Text('$count명', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.purple : Colors.grey[700])),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(isSelected ? Colors.purple : Colors.purple.withOpacity(0.5)),
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
class InteractiveSettlementCard extends StatefulWidget {
  final Map<String, dynamic> msg;
  final bool isMe;
  final String chatRoomId;
  final Function(Map<String, dynamic> delta)? onUpdate;

  const InteractiveSettlementCard({
    super.key,
    required this.msg,
    required this.isMe,
    required this.chatRoomId,
    this.onUpdate,
  });

  @override
  State<InteractiveSettlementCard> createState() => _InteractiveSettlementCardState();
}

class _InteractiveSettlementCardState extends State<InteractiveSettlementCard> {
  String _formatAmount(dynamic val) {
    final num numVal = num.tryParse(val.toString().replaceAll(',', '').replaceAll('원', '')) ?? 0;
    return numVal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    final currentNick = globalData.userNickname.value.isNotEmpty ? globalData.userNickname.value : '우리동네민우';
    final List<String> paidMembers = List<String>.from(widget.msg['paidMembers'] ?? [widget.msg['sender'] ?? '우리동네민우']);
    final bool hasPaid = paidMembers.contains(currentNick);
    final int totalMembers = widget.msg['totalMembers'] ?? 4;
    final int paidCount = paidMembers.length;
    final String accountBank = widget.msg['accountBank'] ?? '카카오뱅크 3333-01-2345678 (예금주: 모임장)';

    final formattedTotal = _formatAmount(widget.msg['total'] ?? 0);
    final formattedPerPerson = _formatAmount(widget.msg['perPerson'] ?? 0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe) const CircleAvatar(radius: 16, backgroundImage: AssetImage('assets/images/kr_female_1.jpg')),
          if (!widget.isMe) const SizedBox(width: 8),
          if (widget.isMe) Text(widget.msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (widget.isMe) const SizedBox(width: 4),

          Container(
            width: 270,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF19E39).withOpacity(0.35), width: 1.5),
              boxShadow: [BoxShadow(color: const Color(0xFFF19E39).withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Color(0xFFFFEFE5), shape: BoxShape.circle),
                      child: const Icon(Icons.payments, color: Color(0xFFF19E39), size: 18),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('1/N 더치페이 정산 요청', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(widget.msg['title'] ?? '모임 정산', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('총 지출 금액', style: TextStyle(fontSize: 13, color: Color(0xFF767676))),
                    Text('$formattedTotal원', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('내가 보낼 금액', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('$formattedPerPerson원', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFFF19E39))),
                  ],
                ),
                const SizedBox(height: 10),
                // 입금 계좌 영역 (터치 시 클립보드 복사)
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: accountBank));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('💳 입금 계좌번호가 복사되었습니다! 카카오페이/토스에서 붙여넣기 하세요.')),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFFF8F8FA), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance, size: 14, color: Color(0xFF767676)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(accountBank, style: const TextStyle(fontSize: 11, color: Color(0xFF555555)), overflow: TextOverflow.ellipsis),
                        ),
                        const Icon(Icons.copy, size: 12, color: Color(0xFF999999)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 실시간 송금 완료 현황 프로그레스 바
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('실시간 입금 현황', style: TextStyle(fontSize: 11, color: Color(0xFF767676))),
                    Text('$paidCount / $totalMembers명 완료', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF19E39))),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: (paidCount / totalMembers).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF19E39)),
                    minHeight: 5,
                  ),
                ),
                if (paidMembers.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('완료: ${paidMembers.join(", ")}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {
                      final newPaid = List<String>.from(paidMembers);
                      if (hasPaid) {
                        newPaid.remove(currentNick);
                      } else {
                        newPaid.add(currentNick);
                      }
                      if (widget.onUpdate != null) {
                        widget.onUpdate!({'paidMembers': newPaid});
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(!hasPaid ? '🎉 $formattedPerPerson원 송금 완료로 처리되었습니다!' : '송금 완료 상태를 취소했습니다.'),
                          backgroundColor: !hasPaid ? const Color(0xFFF19E39) : Colors.black87,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasPaid ? const Color(0xFFE8F5E9) : const Color(0xFFF19E39),
                      foregroundColor: hasPaid ? const Color(0xFF2E7D32) : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: hasPaid ? const BorderSide(color: Color(0xFF81C784)) : BorderSide.none,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(hasPaid ? Icons.check_circle : Icons.send_rounded, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          hasPaid ? '송금 완료됨 (확인 완료) ✓' : '1/N 정산 송금 완료하기',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (!widget.isMe) const SizedBox(width: 4),
          if (!widget.isMe) Text(widget.msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
        ],
      ),
    );
  }
}

// ===========================================================================
// 동적 컴포넌트: 핫플 공유 카드
// ===========================================================================
class InteractiveHotspotCard extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMe;

  const InteractiveHotspotCard({super.key, required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final String name = msg['name'] ?? '핫플 이름';
    final String address = msg['address'] ?? '주소 정보 없음';
    final double lat = msg['lat'] ?? 37.5665;
    final double lng = msg['lng'] ?? 126.9780;
    
    // 실제 카카오맵 링크 생성 (이름과 좌표 포함)
    final String kakaoMapUrl = 'https://map.kakao.com/link/map/$name,$lat,$lng';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const CircleAvatar(radius: 16, backgroundImage: AssetImage('assets/images/kr_female_1.jpg')),
          if (!isMe) const SizedBox(width: 8),
          if (isMe) Text(msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: const Color(0xFF767676))),
          if (isMe) const SizedBox(width: 4),
          
          Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.brown.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: Colors.brown.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.brown.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.local_cafe, color: Colors.brown, size: 16)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(msg['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(address, style: const TextStyle(fontSize: 12, color: const Color(0xFF767676))),
                const SizedBox(height: 12),
                
                // 미니 지도 썸네일
                GestureDetector(
                  onTap: () async {
                    final Uri url = Uri.parse(kakaoMapUrl);
                    if (!await launchUrl(url)) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('지도를 열 수 없습니다.')));
                  },
                  child: Container(
                    height: 90, width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBE6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFEE500), width: 1.2),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE500),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on, size: 14, color: Color(0xFF191919)),
                            SizedBox(width: 4),
                            Text('카카오맵에서 위치 보기', style: TextStyle(color: Color(0xFF191919), fontSize: 12, fontWeight: FontWeight.w800)),
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
          if (!isMe) Text(msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: const Color(0xFF767676))),
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

  const InteractiveReviewCard({super.key, required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final int rating = msg['rating'] ?? 5;
    final String text = msg['text'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const CircleAvatar(radius: 16, backgroundImage: AssetImage('assets/images/kr_female_1.jpg')),
          if (!isMe) const SizedBox(width: 8),
          if (isMe) Text(msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (isMe) const SizedBox(width: 4),
          
          Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.rate_review, color: Colors.orange, size: 16)),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('✨ 모임 후기가 도착했어요!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: List.generate(5, (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 20,
                  )),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(8)),
                  child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
                ),
              ],
            ),
          ),

          if (!isMe) const SizedBox(width: 4),
          if (!isMe) Text(msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
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
  State<InteractiveSafeReturnCard> createState() => _InteractiveSafeReturnCardState();
}

class _InteractiveSafeReturnCardState extends State<InteractiveSafeReturnCard> {
  @override
  Widget build(BuildContext context) {
    final currentNick = globalData.userNickname.value.isNotEmpty ? globalData.userNickname.value : '우리동네민우';
    final List<String> cheers = List<String>.from(widget.msg['cheers'] ?? []);
    final bool isLiked = cheers.contains(currentNick);
    final int likes = cheers.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe) const CircleAvatar(radius: 16, backgroundImage: AssetImage('assets/images/kr_female_1.jpg')),
          if (!widget.isMe) const SizedBox(width: 8),
          if (widget.isMe) Text(widget.msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (widget.isMe) const SizedBox(width: 4),

          Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F5),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.pink.withOpacity(0.35), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.pink.withOpacity(0.15), shape: BoxShape.circle),
                      child: const Icon(Icons.nightlight_round, color: Colors.pink, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.msg['title'] ?? '🏠 안전 귀가 알림',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.pink),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.msg['desc'] ?? '방금 집에 무사히 도착했습니다! 다들 조심히 들어가세요.',
                  style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF333333)),
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
                        content: Text(!isLiked ? '💖 무사 귀가를 축하해 주셨습니다!' : '안심 반응을 취소했습니다.'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isLiked ? Colors.pink : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.pink),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite, color: isLiked ? Colors.white : Colors.pink, size: 16),
                        const SizedBox(width: 6),
                        Text('다행이에요! $likes', style: TextStyle(color: isLiked ? Colors.white : Colors.pink, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (!widget.isMe) const SizedBox(width: 4),
          if (!widget.isMe) Text(widget.msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
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
  State<InteractiveProfileExchangeCard> createState() => _InteractiveProfileExchangeCardState();
}

class _InteractiveProfileExchangeCardState extends State<InteractiveProfileExchangeCard> {
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
                backgroundImage: AssetImage('assets/images/kr_female_1.jpg'),
              ),
              const SizedBox(height: 12),
              Text(nickname, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('인증된 직장인 · 매너온도 41.2℃ 🔥', style: TextStyle(fontSize: 13, color: Colors.teal, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12)),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified_user, color: Colors.teal, size: 16),
                        SizedBox(width: 6),
                        Text('OOMU 본인 인증 및 매너 검증 완료', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text('관심사: 맛집 탐방, 주말 한강 러닝, 소셜 와인 다이닝', style: TextStyle(fontSize: 12, color: Color(0xFF555555))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('닫기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final currentNick = globalData.userNickname.value.isNotEmpty ? globalData.userNickname.value : '우리동네민우';
    final List<String> acceptedMembers = List<String>.from(widget.msg['acceptedMembers'] ?? []);
    final bool isAccepted = acceptedMembers.isNotEmpty || widget.msg['status'] == 'accepted';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe) const CircleAvatar(radius: 16, backgroundImage: AssetImage('assets/images/kr_female_1.jpg')),
          if (!widget.isMe) const SizedBox(width: 8),
          if (widget.isMe) Text(widget.msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (widget.isMe) const SizedBox(width: 4),

          Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)]),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(radius: 22, backgroundColor: Colors.white, child: Icon(Icons.badge, color: Colors.teal, size: 26)),
                const SizedBox(height: 10),
                Text(widget.msg['title'] ?? '명함/프로필 교환', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.teal)),
                const SizedBox(height: 6),
                Text(widget.msg['desc'] ?? '서로의 상세 프로필과 소셜 정보를 확인해볼까요?', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                const SizedBox(height: 14),
                if (isAccepted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showProfileModal(widget.msg['sender'] ?? '상대방'),
                      icon: const Icon(Icons.person, size: 16, color: Colors.white),
                      label: const Text('교환 완료 · 프로필 보기 🤝', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  )
                else if (!widget.isMe)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final newAccepted = List<String>.from(acceptedMembers)..add(currentNick);
                        if (widget.onUpdate != null) {
                          widget.onUpdate!({'acceptedMembers': newAccepted, 'status': 'accepted'});
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🎉 프로필 교환을 수락했습니다! 상세 프로필이 공개됩니다.')),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('수락하기 🤝', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
                    child: const Center(child: Text('상대방의 수락을 대기중입니다...', style: TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.bold))),
                  ),
              ],
            ),
          ),

          if (!widget.isMe) const SizedBox(width: 4),
          if (!widget.isMe) Text(widget.msg['time'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
        ],
      ),
    );
  }
}


// ===========================================================================
// [동적 컴포넌트 1] 📍 상단 고정 약속 카드 & 7일 시한폭탄 타이머 (FixedPromiseHeader)
// ===========================================================================
class FixedPromiseHeader extends StatefulWidget {
  final String? chatRoomId;
  final String? currentUserName;

  const FixedPromiseHeader({
    super.key,
    this.chatRoomId,
    this.currentUserName,
  });

  @override
  State<FixedPromiseHeader> createState() => _FixedPromiseHeaderState();
}

class _FixedPromiseHeaderState extends State<FixedPromiseHeader> {
  bool _isExpanded = true;
  bool _isArrived = false; // 장소 도착 여부 Y/N
  int _arrivedCount = 2;   // 현재 도착 완료 인원 (2/4명)
  final int _totalMembers = 4;
  Stream<DocumentSnapshot>? _roomStream;
  
  // 약속 정보
  final String _meetingTime = '2026. 10. 18 (일) 오후 6:00';
  final String _locationName = '홍대입구역 9번 출구 앞 (서교동 마라토끼)';
  final String _kakaoMapUrl = 'https://map.kakao.com/link/map/홍대입구역 9번출구,37.5568,126.9242';
  final String _naverMapUrl = 'https://map.naver.com/v5/search/홍대입구역 9번출구';

  @override
  void initState() {
    super.initState();
    if (widget.chatRoomId != null) {
      try {
        final cId = oomuChatStore.canonicalRoomId(widget.chatRoomId!);
        _roomStream = FirebaseFirestore.instance.collection('chatRooms').doc(cId).snapshots();
      } catch (e) {
        debugPrint('[FixedPromiseHeader] Firestore stream init skipped/fallback: $e');
      }
    }
  }

  void _showMapOptionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFFF19E39)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _locationName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '원하시는 지도 앱으로 이동하여 길찾기 또는 위치를 확인하세요.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFFEE500), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.map, color: Colors.black87),
              ),
              title: const Text('카카오맵으로 열기', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () async {
                Navigator.pop(ctx);
                final uri = Uri.parse(_kakaoMapUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('카카오맵을 열 수 없습니다.')));
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF03C75A), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.navigation, color: Colors.white),
              ),
              title: const Text('네이버지도로 열기', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () async {
                Navigator.pop(ctx);
                final uri = Uri.parse(_naverMapUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('네이버지도를 열 수 없습니다.')));
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.copy, color: Colors.black87),
              ),
              title: const Text('장소 주소 복사하기', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(ctx);
                Clipboard.setData(ClipboardData(text: _locationName));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('📍 장소 주소가 클립보드에 복사되었습니다!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareSchedule() {
    final text = '📅 [OOMU 약속 확정]\n일시: $_meetingTime\n장소: $_locationName\n함께 만나요!';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📅 약속 일정이 클립보드에 복사되었습니다! 카카오톡이나 캘린더에 공유하세요.'),
        backgroundColor: Color(0xFFF19E39),
      ),
    );
  }

  void _toggleArrival(bool currentIsArrived, int currentCount) async {
    final nextState = !currentIsArrived;
    setState(() {
      _isArrived = nextState;
      _arrivedCount = nextState ? (currentCount + 1) : (currentCount > 0 ? currentCount - 1 : 0);
    });

    final cId = widget.chatRoomId != null ? oomuChatStore.canonicalRoomId(widget.chatRoomId!) : null;
    final userName = (widget.currentUserName != null && widget.currentUserName!.isNotEmpty)
        ? widget.currentUserName!
        : (globalData.userNickname.value.isNotEmpty ? globalData.userNickname.value : '우리동네민우');

    if (cId != null) {
      try {
        final docRef = FirebaseFirestore.instance.collection('chatRooms').doc(cId);
        if (nextState) {
          await docRef.set({
            'arrivedMembers': FieldValue.arrayUnion([userName]),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } else {
          await docRef.set({
            'arrivedMembers': FieldValue.arrayRemove([userName]),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } catch (e) {
        debugPrint('[FixedPromiseHeader] Firestore toggle arrival error: $e');
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(nextState ? '🎉 도착 완료로 변경되었습니다! (현재 $_arrivedCount/$_totalMembers명 도착)' : '📍 도착 상태를 [이동 중]으로 변경했습니다.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_roomStream != null) {
      return StreamBuilder<DocumentSnapshot>(
        stream: _roomStream,
        builder: (context, snapshot) {
          int displayCount = _arrivedCount;
          bool displayIsArrived = _isArrived;
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            if (data != null && data['arrivedMembers'] is List) {
              final arrivedList = List<String>.from(data['arrivedMembers']);
              final userName = (widget.currentUserName != null && widget.currentUserName!.isNotEmpty)
                  ? widget.currentUserName!
                  : (globalData.userNickname.value.isNotEmpty ? globalData.userNickname.value : '우리동네민우');
              displayIsArrived = arrivedList.contains(userName);
              displayCount = arrivedList.length;
            }
          }
          return _buildCard(displayIsArrived, displayCount);
        },
      );
    }
    return _buildCard(_isArrived, _arrivedCount);
  }

  Widget _buildCard(bool isArrived, int arrivedCount) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF19E39).withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF19E39).withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 바: D-Day & 7일 시한폭탄 타이머 배지 & 접기 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF19E39).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.timer_outlined, color: Color(0xFFF19E39), size: 18),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '약속 확정!',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111111)),
                    ),
                    const SizedBox(width: 8),
                    // 7일 시한폭탄 타이머 뱃지
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECE0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.local_fire_department, color: Color(0xFFE65100), size: 12),
                          SizedBox(width: 2),
                          Text(
                            'D-2 (47시간 남음)',
                            style: TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey),
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          if (_isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 일정 확인 & 공유 행
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Color(0xFF767676)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _meetingTime,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF222222)),
                        ),
                      ),
                      InkWell(
                        onTap: _shareSchedule,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.share, size: 12, color: Color(0xFF555555)),
                              SizedBox(width: 4),
                              Text('일정 공유', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF555555))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 장소 보기 행
                  Row(
                    children: [
                      const Icon(Icons.place, size: 14, color: Color(0xFF767676)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _locationName,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF222222)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      InkWell(
                        onTap: _showMapOptionsModal,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.map, size: 12, color: Color(0xFF2E7D32)),
                              SizedBox(width: 4),
                              Text('장소 보기', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 장소 도착 여부 Y/N 인터랙션 영역
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isArrived ? Icons.check_circle : Icons.directions_walk,
                              color: isArrived ? Colors.green : Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('현장 도착 여부', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                Text(
                                  '현재 $arrivedCount/$_totalMembers명 도착',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: arrivedCount >= _totalMembers ? Colors.green : const Color(0xFF333333),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // 도착 상태 Y/N 토글 스위치 버튼
                        ElevatedButton(
                          onPressed: () => _toggleArrival(isArrived, arrivedCount),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isArrived ? Colors.green : Colors.white,
                            foregroundColor: isArrived ? Colors.white : const Color(0xFF555555),
                            elevation: 0,
                            side: BorderSide(color: isArrived ? Colors.green : const Color(0xFFCCCCCC)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            isArrived ? '도착 완료! (Y)' : '아직 이동 중 (N)',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ===========================================================================
// [동적 컴포넌트 2] 💖 시크릿 애프터 1:1 호감 매칭 카드 (InteractiveSecretAfterMatchCard)
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
  State<InteractiveSecretAfterMatchCard> createState() => _InteractiveSecretAfterMatchCardState();
}

class _InteractiveSecretAfterMatchCardState extends State<InteractiveSecretAfterMatchCard> {
  // 모임 참가자 목록 (상대방)
  final List<Map<String, String>> _candidates = [
    {'name': '매운맛킬러', 'tag': '🦊 여우 · 마라탕 러버', 'avatar': 'assets/images/kr_male_1.jpg'},
    {'name': '러닝조아', 'tag': '🐰 토끼 · 주말 한강 러닝', 'avatar': 'assets/images/kr_female_3.jpg'},
    {'name': '카페탐방러', 'tag': '🐱 고양이 · 성수동 카페 덕후', 'avatar': 'assets/images/kr_male_2.jpg'},
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
        content: Text('💌 ${_selectedMembers.join(", ")}님에게 비공개 호감이 전달되었습니다! (0% 노출 보장)'),
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
            Text('💖 시크릿 매칭 성사!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundImage: AssetImage('assets/images/kr_male_1.jpg'),
            ),
            const SizedBox(height: 12),
            const Text(
              '매운맛킬러님도 당신에게 호감을 표시했습니다! 💕',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              child: const Text('1:1 소개팅 대화방 열기 💬', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            border: Border.all(color: Colors.pinkAccent.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.pinkAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '시크릿 애프터 1:1 호감 매칭',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFC2185B)),
                        ),
                        Text(
                          '상호 선택 시에만 1:1 대화방 개설 (거절 부담 0%)',
                          style: TextStyle(fontSize: 11, color: Color(0xFF880E4F)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              const Text(
                '오늘 모임에서 대화가 가장 잘 통했던 멤버 1~2명을 선택하세요.',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
              ),
              const SizedBox(height: 12),

              // 후보 멤버 칩 리스트
              Column(
                children: _candidates.map((cand) {
                  final isSelected = _selectedMembers.contains(cand['name']);
                  return GestureDetector(
                    onTap: () => _toggleMember(cand['name']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? Colors.pinkAccent : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: Colors.pinkAccent.withOpacity(0.2), blurRadius: 8)]
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
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  cand['tag']!,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
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

              // 하단 버튼
              if (!_isSubmitted)
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _submitSecretAfter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      '비공개 호감 전달하기 (${_selectedMembers.length}명 선택)',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                )
              else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, size: 16, color: Colors.pinkAccent),
                      SizedBox(width: 6),
                      Text(
                        '💌 비공개 호감 전송 완료! (상대방 응답 대기 중)',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // 테스트/체험용 시뮬레이션 버튼
                Center(
                  child: TextButton.icon(
                    onPressed: _simulateMutualMatch,
                    icon: const Icon(Icons.flash_on, size: 16, color: Colors.purple),
                    label: const Text(
                      '🧪 상호 매칭 성사 시뮬레이션 테스트',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple),
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
