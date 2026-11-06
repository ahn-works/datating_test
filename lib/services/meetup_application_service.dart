import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Persisted requests only. Permission denial is surfaced; there is no simulated
/// approval or local-success fallback. Server rules must enforce the same roles.
class MeetupApplicationService {
  // Enable only after deployed Firestore rules and real request/approval tests
  // have been verified. Local UI work must not expose an unverified write path.
  static const enabled = bool.fromEnvironment('OOMU_ENABLE_APPLICATIONS', defaultValue: true);
  static int capacity(Map<String, dynamic> data) {
    final explicit = data['maxMembers'];
    if (explicit is num) return explicit.toInt();
    final members = (data['members'] ?? '').toString().split('/');
    return int.tryParse(members.length == 2 ? members.last : '') ?? 0;
  }

  static int attendance(Map<String, dynamic> data) {
    final parts = (data['members'] ?? '').toString().split('/');
    return int.tryParse(parts.first) ??
        (data['participantIds'] as List?)?.length ??
        0;
  }

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
    await db.runTransaction((tx) async {
      final snapshot = await tx.get(meetup);
      if (!snapshot.exists) {
        throw StateError('이 모임은 신청할 수 없어요. 모임 정보를 새로 확인해 주세요.');
      }
      final data = snapshot.data()!;
      if (hostUid(data).isEmpty) {
        throw StateError('모임장 계정 정보를 확인할 수 없어 신청을 중단했어요.');
      }
      if (hostUid(data) == user.uid) throw StateError('내가 개설한 모임에는 신청할 수 없어요.');
      final previous = await tx.get(request);
      if (previous.data()?['status'] == 'approved' ||
          previous.data()?['status'] == 'pending') {
        throw StateError('이미 신청한 모임이에요. 기존 신청 상태를 확인해 주세요.');
      }
      final seats = withFriend ? 2 : 1;
      if (capacity(data) <= 0 || attendance(data) + seats > capacity(data)) {
        throw StateError('참여 가능한 자리가 부족해요.');
      }
      tx.set(request, {
        'userId': user.uid,
        'message': message.trim(),
        'partySize': seats,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  static Future<void> decide(String meetupId, String applicantUid,
      {required bool approve}) async {
    if (!enabled) throw StateError('아직 참여 신청을 받을 수 없어요.');
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('로그인 상태를 확인해 주세요.');
    final db = FirebaseFirestore.instance;
    final meetup = db.collection('meetups').doc(meetupId);
    final request = meetup.collection('applications').doc(applicantUid);
    await db.runTransaction((tx) async {
      final meeting = await tx.get(meetup);
      final application = await tx.get(request);
      final data = meeting.data();
      if (data == null || hostUid(data) != user.uid) {
        throw StateError('모임장만 신청을 처리할 수 있어요.');
      }
      if (application.data()?['status'] != 'pending') {
        throw StateError('이미 처리된 신청이에요.');
      }
      if (approve) {
        final seats = (application.data()?['partySize'] as num?)?.toInt() ?? 1;
        final next = attendance(data) + seats;
        if (capacity(data) <= 0 || next > capacity(data)) {
          throw StateError('모임 정원을 초과해 승인할 수 없어요.');
        }
        tx.update(meetup, {
          'participantIds': FieldValue.arrayUnion([applicantUid]),
          'members': '$next/${capacity(data)}'
        });
        tx.set(db.collection('chatRooms').doc(meetupId), {
          'id': meetupId,
          'meetupId': meetupId,
          'title': (data['title'] ?? '').toString(),
          'hostUid': user.uid,
          'isGroup': true,
          'members': next,
          'participants': FieldValue.arrayUnion([user.uid, applicantUid]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      tx.update(request, {
        'status': approve ? 'approved' : 'rejected',
        'reviewedAt': FieldValue.serverTimestamp()
      });
    });
  }
}
