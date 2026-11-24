import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/global_data.dart';
import '../utils/meetup_member_helper.dart';

/// Persisted requests only. Permission denial is surfaced; there is no simulated
/// approval or local-success fallback. Server rules must enforce the same roles.
class MeetupApplicationService {
  // Enable only after deployed Firestore rules and real request/approval tests
  // have been verified. Local UI work must not expose an unverified write path.
  static const enabled = bool.fromEnvironment('OOMU_ENABLE_APPLICATIONS', defaultValue: true);
  static int capacity(Map<String, dynamic> data) =>
      MeetupMemberHelper.parseCapacity(data);

  static int attendance(Map<String, dynamic> data) =>
      MeetupMemberHelper.parseAttendance(data);

  static String hostUid(Map<String, dynamic> data) =>
      (data['hostUid'] ?? data['hostId'] ?? '').toString();

  static Future<void> request(String meetupId, String message,
      {required bool withFriend}) async {
    if (!enabled) throw StateError('아직 참여 신청을 받을 수 없어요.');
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('로그인 후 참여 신청해 주세요.');
    final db = FirebaseFirestore.instance;
    final meetup = db.collection('meetups').doc(meetupId);
    final request = meetup.collection('applications').doc(user.uid);
    String targetHostUid = '';
    String meetupTitle = '';
    await db.runTransaction((tx) async {
      final snapshot = await tx.get(meetup);
      if (!snapshot.exists) {
        throw StateError('이 모임은 신청할 수 없어요. 모임 정보를 새로 확인해 주세요.');
      }
      final data = snapshot.data()!;
      targetHostUid = hostUid(data);
      meetupTitle = (data['title'] ?? '').toString();
      if (targetHostUid.isEmpty) {
        throw StateError('모임장 계정 정보를 확인할 수 없어 신청을 중단했어요.');
      }
      if (targetHostUid == user.uid) throw StateError('내가 개설한 모임에는 신청할 수 없어요.');
      final previous = await tx.get(request);
      if (previous.data()?['status'] == 'approved' ||
          previous.data()?['status'] == 'pending') {
        throw StateError('이미 신청한 모임이에요. 기존 신청 상태를 확인해 주세요.');
      }
      final seats = withFriend ? 2 : 1;
      if (capacity(data) <= 0 || attendance(data) + seats > capacity(data)) {
        throw StateError('참여 가능한 자리가 부족해요.');
      }
      final applicantNick = globalData.userNickname.value.trim().isNotEmpty
          ? globalData.userNickname.value.trim()
          : (user.displayName?.trim().isNotEmpty == true
              ? user.displayName!.trim()
              : '동네 이웃');
      final applicantAvatar = globalData.userAvatar.value.trim();
      tx.set(request, {
        'userId': user.uid,
        'nickname': applicantNick,
        if (applicantAvatar.isNotEmpty) 'avatarUrl': applicantAvatar,
        'message': message.trim(),
        'partySize': seats,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    if (targetHostUid.isNotEmpty) {
      try {
        await db.collection('notifications').add({
          'userId': targetHostUid,
          'type': 'meetup_request',
          'title': '새로운 모임 참여 신청이 도착했어요',
          'body': meetupTitle.isNotEmpty
              ? '[$meetupTitle] 모임에 참여 신청이 들어왔어요.'
              : '모임에 새로운 참여 신청이 있어요.',
          'meetupId': meetupId,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {}
    }
  }

  static Future<void> decide(String meetupId, String applicantUid,
      {required bool approve}) async {
    if (!enabled) throw StateError('아직 참여 신청을 받을 수 없어요.');
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('로그인 상태를 확인해 주세요.');
    final db = FirebaseFirestore.instance;
    final meetup = db.collection('meetups').doc(meetupId);
    final request = meetup.collection('applications').doc(applicantUid);
    String meetupTitle = '';
    await db.runTransaction((tx) async {
      final meeting = await tx.get(meetup);
      final application = await tx.get(request);
      final data = meeting.data();
      if (data == null || hostUid(data) != user.uid) {
        throw StateError('모임장만 신청을 처리할 수 있어요.');
      }
      meetupTitle = (data['title'] ?? '').toString();
      if (application.data()?['status'] != 'pending') {
        throw StateError('이미 처리된 신청이에요.');
      }
      if (approve) {
        final appData = application.data() ?? const <String, dynamic>{};
        final seats = (appData['partySize'] as num?)?.toInt() ?? 1;
        final next = attendance(data) + seats;
        if (capacity(data) <= 0 || next > capacity(data)) {
          throw StateError('모임 정원을 초과해 승인할 수 없어요.');
        }
        final applicantNick = (appData['nickname'] ?? '새 멤버').toString().trim();
        final applicantAvatar = (appData['avatarUrl'] ?? '').toString().trim();
        final rawMembers = data['members'];
        final updates = <String, dynamic>{
          'participantIds': FieldValue.arrayUnion([applicantUid]),
          if (applicantNick.isNotEmpty)
            'memberNames': FieldValue.arrayUnion([applicantNick]),
          if (applicantAvatar.isNotEmpty)
            'memberAvatars': FieldValue.arrayUnion([applicantAvatar]),
        };
        if (rawMembers is List) {
          updates['members'] = FieldValue.arrayUnion([applicantUid]);
        } else {
          updates['members'] = '$next/${capacity(data)}';
        }
        tx.update(meetup, updates);
        tx.set(db.collection('chatRooms').doc(meetupId), {
          'id': meetupId,
          'meetupId': meetupId,
          'title': (data['title'] ?? '').toString(),
          'location': (data['location'] ?? '').toString(),
          'date': (data['date'] ?? '').toString(),
          'hostUid': user.uid,
          'isGroup': true,
          'members': next,
          'lastMessage': '🎉 $applicantNick님이 모임장 승인으로 단톡방에 합류했어요!',
          'lastMessageTime': '방금',
          'time': '방금',
          'participants': FieldValue.arrayUnion([user.uid, applicantUid]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      tx.update(request, {
        'status': approve ? 'approved' : 'rejected',
        'reviewedAt': FieldValue.serverTimestamp()
      });
    });

    if (applicantUid.isNotEmpty) {
      try {
        await db.collection('notifications').add({
          'userId': applicantUid,
          'type': 'meetup_decision',
          'title': approve ? '모임 신청이 승인됐어요' : '모임 신청이 처리되었어요',
          'body': approve
              ? (meetupTitle.isNotEmpty
                  ? '[$meetupTitle] 모임 참여가 승인되었어요! 채팅방을 확인해 보세요.'
                  : '모임 참여가 승인되었어요!')
              : (meetupTitle.isNotEmpty
                  ? '[$meetupTitle] 모임 참여 신청이 아쉽게도 승인되지 않았어요.'
                  : '신청이 승인되지 않았어요.'),
          'meetupId': meetupId,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {}
    }
  }
}
