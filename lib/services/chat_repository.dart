import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../utils/global_data.dart';

typedef ChatData = Map<String, dynamic>;

// Only the exact records written by the old automatic demo seeder are hidden.
// Real messages (including matching text from an identified sender) are retained.
bool isLegacyChatSeed(ChatData data) {
  if ((data['senderId'] ?? '').toString().isNotEmpty) return false;
  const fields = <String, (String, String)>{
    'msg_txt_01': ('text', '안녕하세요! 다들 마라탕 좋아하시죠?'),
    'msg_txt_02': ('text', '완전완전 좋아합니다ㅎㅎ 잘 부탁드려요!'),
    'msg_txt_03': ('text', '그럼 이번주 토요일 6시에 홍대에서 봬요!'),
    'msg_sys_02': ('text', '우리동네민우님이 참여 승인되어 합류했습니다! 🎉'),
    'msg_sched_01': ('title', '이번 주 토요일 첫 정기 모임'),
    'msg_poll_01': ('title', '저녁 식사 후 2차 장소 투표 🍻'),
    'msg_settle_01': ('title', '1차 마라탕 & 꿔바로우 1/N 정산'),
    'msg_safe_01': ('title', '🏠 안전 귀가 알림'),
    'msg_profile_01': ('title', '🤝 명함/프로필 교환 요청'),
    'msg_secret_01': ('title', '💖 시크릿 애프터 1:1 호감 매칭'),
  };
  final id = data['id'];
  if (id == 'msg_sys_01') {
    return data['type'] == 'system' &&
        (data['text'] ?? '').toString().endsWith(' 모임 대화방이 개설되었습니다. 🎉');
  }
  final signature = fields[id];
  return signature != null && data[signature.$1] == signature.$2;
}

List<String> chatParticipantIds(ChatData? room) {
  final ids = (room?['participants'] is List ? room!['participants'] as List : const [])
      .whereType<String>()
      .where((id) => id.isNotEmpty)
      .toSet();
  final hostUid = room?['hostUid']?.toString();
  if (hostUid != null && hostUid.isNotEmpty) {
    ids.add(hostUid);
  }
  return ids.toList();
}

bool isChatParticipant(ChatData? room, String? uid) =>
    uid != null &&
    uid.isNotEmpty &&
    (chatParticipantIds(room).contains(uid) || room?['hostUid'] == uid) &&
    !(room?['leftUserIds'] is List &&
        (room!['leftUserIds'] as List).contains(uid));

ChatData presentChatMessage(ChatData raw, String? uid) {
  final stamp = raw['timestamp'];
  final date = stamp is Timestamp
      ? stamp.toDate().toLocal()
      : DateTime.tryParse((raw['createdAt'] ?? '').toString())?.toLocal();
  return {
    ...raw,
    // A shared isMe flag or nickname cannot identify the viewing user.
    'isMe': uid != null && uid.isNotEmpty && raw['senderId'] == uid,
    'time': date == null
        ? ''
        : '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
  };
}

abstract class ChatRepository {
  String? get currentUid;
  Stream<String?> get sessionChanges;
  Stream<List<ChatData>> rooms(String uid);
  Stream<ChatData?> room(String id);
  Stream<List<ChatData>> messages(String id);
  Future<void> send(String id, ChatData message);
  Future<void> updateMessage(String roomId, String messageId, ChatData changes);
  Future<void> deleteMessage(String roomId, String messageId);
  Future<void> leave(String roomId);
}

class FirestoreChatRepository implements ChatRepository {
  const FirestoreChatRepository();
  @override
  String? get currentUid {
    final globalUid = globalData.currentUserId.value.trim();
    if (globalUid.isNotEmpty && globalUid != 'guest') return globalUid;
    if (Firebase.apps.isEmpty) return null;
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    if (authUid != null && authUid.isNotEmpty) return authUid;
    return null;
  }

  @override
  Stream<String?> get sessionChanges => Firebase.apps.isEmpty
      ? const Stream.empty()
      : FirebaseAuth.instance.authStateChanges().map((u) => u?.uid);
  @override
  Stream<List<ChatData>> rooms(String uid) => FirebaseFirestore.instance
          .collection('chatRooms')
          .where('participants', arrayContains: uid)
          .snapshots()
          .map((snap) {
        final result = snap.docs
            .map((d) => {...d.data(), 'id': d.id})
            .where((d) => isChatParticipant(d, uid))
            .toList();
        result.sort((a, b) {
          final at = a['updatedAt'], bt = b['updatedAt'];
          return (bt is Timestamp ? bt.millisecondsSinceEpoch : 0)
              .compareTo(at is Timestamp ? at.millisecondsSinceEpoch : 0);
        });
        return result;
      });
  @override
  Stream<ChatData?> room(String id) => FirebaseFirestore.instance
      .collection('chatRooms')
      .doc(id)
      .snapshots()
      .map((d) => d.data());
  @override
  Stream<List<ChatData>> messages(String id) => FirebaseFirestore.instance
      .collection('chatRooms')
      .doc(id)
      .collection('messages')
      .orderBy('timestamp')
      .snapshots()
      .map((s) => s.docs
          .map((d) => {...d.data(), 'id': d.id})
          .where((d) => !isLegacyChatSeed(d))
          .toList());

  String _requireUid() {
    final uid = currentUid;
    if (uid == null) throw StateError('로그인이 필요해요.');
    return uid;
  }

  @override
  Future<void> send(String id, ChatData message) async {
    final uid = _requireUid();
    final session = globalData.sessionGeneration;
    final db = FirebaseFirestore.instance;
    final ref = db.collection('chatRooms').doc(id);
    final messageRef = ref.collection('messages').doc();
    await db.runTransaction((tx) async {
      final snapshot = await tx.get(ref);
      if (currentUid != uid ||
          session != globalData.sessionGeneration ||
          !isChatParticipant(snapshot.data(), uid)) {
        throw StateError('참여가 확인된 대화방에서만 보낼 수 있어요.');
      }
      final payload = Map<String, dynamic>.from(message)..remove('isMe');
      tx.set(messageRef, {
        ...payload,
        'senderId': uid,
        'timestamp': FieldValue.serverTimestamp()
      });
      final currentParticipants = (snapshot.data()?['participants'] is List)
          ? List<String>.from((snapshot.data()!['participants'] as List).whereType<String>())
          : <String>[];
      final needsParticipantSync = !currentParticipants.contains(uid);
      tx.update(ref, {
        'lastMessage':
            (message['text'] ?? message['title'] ?? '새 메시지').toString(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (needsParticipantSync) 'participants': FieldValue.arrayUnion([uid]),
      });
    });
  }

  @override
  Future<void> updateMessage(
      String roomId, String messageId, ChatData changes) async {
    final uid = _requireUid();
    final session = globalData.sessionGeneration;
    final db = FirebaseFirestore.instance;
    final roomRef = db.collection('chatRooms').doc(roomId);
    await db.runTransaction((tx) async {
      final snapshot = await tx.get(roomRef);
      if (currentUid != uid ||
          session != globalData.sessionGeneration ||
          !isChatParticipant(snapshot.data(), uid)) {
        throw StateError('참여 확인이 필요해요.');
      }
      tx.update(roomRef.collection('messages').doc(messageId), changes);
    });
  }

  @override
  Future<void> leave(String roomId) async {
    final uid = _requireUid();
    final session = globalData.sessionGeneration;
    final db = FirebaseFirestore.instance;
    final ref = db.collection('chatRooms').doc(roomId);
    await db.runTransaction((tx) async {
      final snapshot = await tx.get(ref);
      if (currentUid != uid ||
          session != globalData.sessionGeneration ||
          !isChatParticipant(snapshot.data(), uid)) {
        throw StateError('참여 확인이 필요해요.');
      }
      tx.update(ref, {
        'participants': FieldValue.arrayRemove([uid]),
        'leftUserIds': FieldValue.arrayUnion([uid])
      });
      tx.set(
          db.collection('user_states').doc(uid),
          {
            'leftRoomIds': FieldValue.arrayUnion([roomId])
          },
          SetOptions(merge: true));
    });
  }

  @override
  Future<void> deleteMessage(String roomId, String messageId) async {
    final uid = _requireUid();
    final db = FirebaseFirestore.instance;
    final msgRef = db.collection('chatRooms').doc(roomId).collection('messages').doc(messageId);
    final snap = await msgRef.get();
    if (snap.exists) {
      final senderId = snap.data()?['senderId'];
      if (senderId != null && senderId != uid) {
        throw StateError('내가 작성한 메시지만 삭제할 수 있어요.');
      }
      await msgRef.delete();
    }
  }
}
