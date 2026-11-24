import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GlobalData {
  static final GlobalData _instance = GlobalData._internal();
  factory GlobalData() => _instance;
  GlobalData._internal();

  // 사용자별 활동 지표 (미설정 초기값: 0.0 / 0 / 빈 리스트)
  final ValueNotifier<double> temperature = ValueNotifier<double>(0.0);
  final ValueNotifier<double> rating = ValueNotifier<double>(0.0);
  final ValueNotifier<int> reviewCount = ValueNotifier<int>(0);
  final ValueNotifier<List<Map<String, dynamic>>> recentReviews =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  // 현재 활성 사용자 ID (미로그인/초기화 시 빈 문자열)
  final ValueNotifier<String> currentUserId = ValueNotifier<String>('');
  String get activeUserId => currentUserId.value;
  bool get isGuest => activeUserId.trim().isEmpty || activeUserId.trim() == 'guest';

  // 프로필 설정 건너뛰기 플래그 (온보딩 도중 '홈으로 이동' 선택 시 홈으로 직행)
  final ValueNotifier<bool> isProfileSetupSkipped = ValueNotifier<bool>(false);
  bool get skipProfileSetup => isProfileSetupSkipped.value;
  void setSkipProfileSetup(bool skip) {
    isProfileSetupSkipped.value = skip;
  }

  // 세션 세대 카운터 (로그아웃 후 동일 계정 재로그인 시에도 이전 세션 비동기 응답을 차단)
  int _sessionGeneration = 0;
  int get sessionGeneration => _sessionGeneration;

  // 비동기 프로필 응답 레이스 컨디션 차단용 세대 카운터 및 테스트용 주입 훅
  int _syncGeneration = 0;
  Future<Map<String, dynamic>?> Function(String uid)? debugProfileFetcher;

  bool isActiveSession(int sessionGen, String uid) {
    return uid.isNotEmpty &&
        uid != 'guest' &&
        _sessionGeneration == sessionGen &&
        currentUserId.value == uid;
  }

  void switchUser(String uid, {bool triggerFirestoreSync = true}) {
    final normalized = uid.trim();
    if (normalized.isEmpty) {
      resetSession();
      return;
    }
    if (normalized == 'guest') {
      resetSession();
      currentUserId.value = 'guest';
      return;
    }
    if (currentUserId.value == normalized) return;
    // 계정 전환 즉시 이전 계정의 모든 사용자별 상태를 미설정으로 초기화하고 이전 세션 응답 무효화
    resetSession();
    currentUserId.value = normalized;
    if (triggerFirestoreSync) {
      syncUserProfileFromFirestore(normalized);
    }
  }

  void resetSession() {
    _sessionGeneration++;
    _syncGeneration++;
    currentUserId.value = '';
    userAvatar.value = '';
    userLocation.value = '';
    userNickname.value = '';
    userRole.value = 'user';
    userName.value = '';
    userAge.value = 0;
    userGender.value = '';
    userBio.value = '';
    userJob.value = '';
    userMbti.value = '';
    userSmoking.value = '';
    userPet.value = '';
    userHobbies.value = [];
    userPersonalities.value = [];
    userDrinking.value = [];
    userPhotos.value = [];
    userPhone.value = '';
    isPhoneVerified.value = false;
    temperature.value = 0.0;
    rating.value = 0.0;
    reviewCount.value = 0;
    joinedMeetupsCount.value = 0;
    myPostsCount.value = 0;
    recentReviews.value = [];
    savedMeetups.value = [];
    blockedUsers.value = [];
    blockedUids.value = [];
    blockedAcquaintancePhones.value = [];
    hiddenPostIds.value = [];
    reportHistory.value = [];
    isProfileSetupSkipped.value = false;
  }

  static List<String> _parseList(dynamic v) {
    if (v is List) {
      return v
          .map((e) => e?.toString().trim() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (v is String && v.trim().isNotEmpty) {
      return [v.trim()];
    }
    return <String>[];
  }

  void applyProfileData(Map<String, dynamic>? data) {
    if (data == null) return;
    final loc = (data['location'] ?? data['address'])?.toString().trim();
    if (loc != null && loc.isNotEmpty) {
      userLocation.value = loc;
    }
    final nick = (data['nickname'] as String?)?.trim();
    if (nick != null && nick.isNotEmpty) {
      userNickname.value = nick;
    }
    final r = data['role']?.toString().trim();
    if (r != null && r.isNotEmpty) {
      userRole.value = r;
    }
    final nm = (data['name'] as String?)?.trim();
    if (nm != null && nm.isNotEmpty) {
      userName.value = nm;
    }
    final rawAge = data['age'];
    if (rawAge is int && rawAge > 0) {
      userAge.value = rawAge;
    } else if (rawAge != null) {
      final parsedAge = int.tryParse(rawAge.toString().trim());
      if (parsedAge != null && parsedAge > 0) {
        userAge.value = parsedAge;
      }
    }
    final g = data['gender']?.toString().trim();
    if (g != null && g.isNotEmpty) {
      userGender.value = g;
    }
    final b = data['bio']?.toString().trim();
    if (b != null && b.isNotEmpty) {
      userBio.value = b;
    }
    final j = data['job']?.toString().trim();
    if (j != null && j.isNotEmpty) {
      userJob.value = j;
    }
    final m = data['mbti']?.toString().trim();
    if (m != null && m.isNotEmpty) {
      userMbti.value = m;
    }
    final sm = data['smoking']?.toString().trim();
    if (sm != null && sm.isNotEmpty) {
      userSmoking.value = sm;
    }
    final pt = data['pet']?.toString().trim();
    if (pt != null && pt.isNotEmpty) {
      userPet.value = pt;
    }
    final hobbies = _parseList(data['hobbies'] ?? data['interests']);
    if (hobbies.isNotEmpty) {
      userHobbies.value = hobbies;
    }
    final personalities = _parseList(data['personalities']);
    if (personalities.isNotEmpty) {
      userPersonalities.value = personalities;
    }
    final drinking = _parseList(data['drinking']);
    if (drinking.isNotEmpty) {
      userDrinking.value = drinking;
    }
    final avatar = (data['photoUrl'] ??
            data['profileImage'] ??
            data['avatarUrl'] ??
            data['authorAvatar'])
        ?.toString()
        .trim();
    if (avatar != null && avatar.isNotEmpty) {
      userAvatar.value = avatar;
    }
    final photos = _parseList(data['photoUrls']);
    if (photos.isNotEmpty) {
      userPhotos.value = photos;
    } else if (avatar != null && avatar.isNotEmpty) {
      userPhotos.value = [avatar];
    }
    final rawTemp = data['mannerTemp'] ?? data['manner'] ?? data['temperature'];
    if (rawTemp is num && rawTemp.toDouble() > 0) {
      temperature.value = rawTemp.toDouble();
    } else if (rawTemp is String) {
      final parsed = double.tryParse(rawTemp);
      if (parsed != null && parsed > 0) {
        temperature.value = parsed;
      }
    }
    if (data['reviewCount'] is num) {
      reviewCount.value = (data['reviewCount'] as num).toInt();
    } else if (data['reviewsCount'] is num) {
      reviewCount.value = (data['reviewsCount'] as num).toInt();
    } else if (data['reviews'] is List) {
      reviewCount.value = (data['reviews'] as List).length;
    }
    if (data['joinedMeetupsCount'] is num) {
      joinedMeetupsCount.value = (data['joinedMeetupsCount'] as num).toInt();
    } else if (data['joinedMeetupIds'] is List) {
      joinedMeetupsCount.value = (data['joinedMeetupIds'] as List).length;
    } else if (data['tripCount'] is num) {
      joinedMeetupsCount.value = (data['tripCount'] as num).toInt();
    }
    if (data['myPostsCount'] is num) {
      myPostsCount.value = (data['myPostsCount'] as num).toInt();
    } else if (data['postCount'] is num) {
      myPostsCount.value = (data['postCount'] as num).toInt();
    }
    if (data['savedMeetups'] is List && (data['savedMeetups'] as List).isNotEmpty) {
      savedMeetups.value = (data['savedMeetups'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .where((m) => (m['title'] ?? '').toString() != '찜한 모임')
          .toList();
    } else if (data['savedMeetupIds'] is List && (data['savedMeetupIds'] as List).isNotEmpty) {
      savedMeetups.value = (data['savedMeetupIds'] as List)
          .map((id) => <String, dynamic>{'id': id.toString(), '_pending': true})
          .toList();
    }
    if (data['blockedUsers'] is List) {
      blockedUsers.value = (data['blockedUsers'] as List)
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (data['blockedUids'] is List) {
      blockedUids.value = (data['blockedUids'] as List)
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (data['blockedPhones'] is List) {
      blockedAcquaintancePhones.value = (data['blockedPhones'] as List)
          .whereType<Map>()
          .map((e) => <String, String>{
                'name': (e['name'] ?? '지인').toString(),
                'phone': (e['phone'] ?? '').toString(),
              })
          .where((m) => m['phone']!.isNotEmpty)
          .toList();
    }
    final phone = (data['phone'] ?? data['phoneNumber'] ?? data['contactPhone'])
        ?.toString()
        .trim();
    if (phone != null && phone.isNotEmpty) {
      userPhone.value = phone;
    }
    if (data['isPhoneVerified'] is bool) {
      isPhoneVerified.value = data['isPhoneVerified'] as bool;
    } else if (data['isVerified'] is bool) {
      isPhoneVerified.value = data['isVerified'] as bool;
    }
  }

  Future<void> syncUserProfileFromFirestore(String uid) async {
    if (uid.isEmpty || uid == 'guest') return;
    final int requestSession = _sessionGeneration;
    final int requestGeneration = ++_syncGeneration;
    try {
      Map<String, dynamic>? data;
      if (debugProfileFetcher != null) {
        data = await debugProfileFetcher!(uid);
      } else {
        if (Firebase.apps.isEmpty) return;
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        data = doc.data();
      }
      // 대기 중 로그아웃되었거나 다른 계정/새 세션으로 전환된 경우 이전 비동기 응답을 즉시 폐기
      if (!isActiveSession(requestSession, uid) ||
          requestGeneration != _syncGeneration) {
        return;
      }
      applyProfileData(data);
      if (debugProfileFetcher == null && Firebase.apps.isNotEmpty) {
        try {
          final stateDoc = await FirebaseFirestore.instance
              .collection('user_states')
              .doc(uid)
              .get();
          if (isActiveSession(requestSession, uid) &&
              requestGeneration == _syncGeneration &&
              stateDoc.exists) {
            final stateData = stateDoc.data();
            if (stateData?['blockedPhones'] is List) {
              blockedAcquaintancePhones.value =
                  (stateData!['blockedPhones'] as List)
                      .whereType<Map>()
                      .map((e) => <String, String>{
                            'name': (e['name'] ?? '지인').toString(),
                            'phone': (e['phone'] ?? '').toString(),
                          })
                      .where((m) => m['phone']!.isNotEmpty)
                      .toList();
            }
          }
        } catch (_) {}
      }
      final rawIds = data?['savedMeetupIds'];
      if (rawIds is List && rawIds.isNotEmpty) {
        final ids = rawIds
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .take(30)
            .toList();
        await _resolveSavedMeetupDocs(
          uid: uid,
          ids: ids,
          requestSession: requestSession,
          requestGeneration: requestGeneration,
        );
      }
    } catch (e) {
      debugPrint('[GlobalData] syncUserProfileFromFirestore error: $e');
    }
  }

  Future<void> refreshSavedMeetups({bool retried = false}) async {
    final uid = activeUserId.trim();
    if (!_canSyncUserDoc) return;
    final int requestSession = _sessionGeneration;
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!isActiveSession(requestSession, uid)) return;
      final rawIds = userDoc.data()?['savedMeetupIds'];
      final ids = (rawIds is List)
          ? rawIds
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .take(30)
              .toList()
          : savedMeetups.value
              .map((m) => (m['id'] ?? '').toString())
              .where((id) => id.isNotEmpty)
              .toList();
      if (ids.isEmpty) {
        savedMeetups.value = [];
        return;
      }
      await _resolveSavedMeetupDocs(
        uid: uid,
        ids: ids,
        requestSession: requestSession,
      );
      if (!retried &&
          savedMeetups.value.any((m) => m['_pending'] == true)) {
        await refreshSavedMeetups(retried: true);
      }
    } catch (e) {
      debugPrint('[GlobalData] refreshSavedMeetups error: $e');
    }
  }

  Future<void> _resolveSavedMeetupDocs({
    required String uid,
    required List<String> ids,
    required int requestSession,
    int? requestGeneration,
  }) async {
    final List<Map<String, dynamic>> loadedMeetups = [];
    final List<String> orphanIds = [];
    for (final mId in ids) {
      try {
        final mDoc = await FirebaseFirestore.instance
            .collection('meetups')
            .doc(mId)
            .get();
        if (mDoc.exists && mDoc.data() != null) {
          loadedMeetups.add({...mDoc.data()!, 'id': mDoc.id});
        } else {
          orphanIds.add(mId);
        }
      } catch (_) {
        loadedMeetups.add({'id': mId, '_pending': true});
      }
    }
    if (!isActiveSession(requestSession, uid)) return;
    if (requestGeneration != null && requestGeneration != _syncGeneration) {
      return;
    }
    savedMeetups.value = loadedMeetups;
    if (orphanIds.isNotEmpty && _canSyncUserDoc) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'savedMeetupIds': FieldValue.arrayRemove(orphanIds),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  // 사용자 프로필 및 위치 (미설정 상태: 빈 문자열 / 0 / 빈 리스트)
  final ValueNotifier<String> userAvatar = ValueNotifier<String>('');
  final ValueNotifier<String> userLocation = ValueNotifier<String>('');
  final ValueNotifier<String> userNickname = ValueNotifier<String>('');
  final ValueNotifier<String> userRole = ValueNotifier<String>('user');
  final ValueNotifier<String> userName = ValueNotifier<String>('');
  final ValueNotifier<int> userAge = ValueNotifier<int>(0);
  final ValueNotifier<String> userGender = ValueNotifier<String>('');
  final ValueNotifier<String> userBio = ValueNotifier<String>('');
  final ValueNotifier<String> userJob = ValueNotifier<String>('');
  final ValueNotifier<String> userMbti = ValueNotifier<String>('');
  final ValueNotifier<String> userSmoking = ValueNotifier<String>('');
  final ValueNotifier<String> userPet = ValueNotifier<String>('');
  final ValueNotifier<List<String>> userHobbies = ValueNotifier<List<String>>([]);
  final ValueNotifier<List<String>> userPersonalities = ValueNotifier<List<String>>([]);
  final ValueNotifier<List<String>> userDrinking = ValueNotifier<List<String>>([]);
  final ValueNotifier<List<String>> userPhotos = ValueNotifier<List<String>>([]);
  final ValueNotifier<String> userPhone = ValueNotifier<String>('');
  final ValueNotifier<bool> isPhoneVerified = ValueNotifier<bool>(false);
  final ValueNotifier<int> joinedMeetupsCount = ValueNotifier<int>(0);
  final ValueNotifier<int> myPostsCount = ValueNotifier<int>(0);

  // 내가 찜한 모임 (사용자별 상태)
  final ValueNotifier<List<Map<String, dynamic>>> savedMeetups =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  // 알림 설정 상태 (앱 공통 설정 - 계정 전환 시 유지)
  final ValueNotifier<Map<String, bool>> notificationSettings =
      ValueNotifier<Map<String, bool>>({
    'joinApproval': true,
    'newChat': true,
    'secretMatch': true,
    'bombTimer': true,
    'marketing': false,
  });

  // UGC 차단 사용자 목록 (사용자별 상태 - 닉네임 기반)
  final ValueNotifier<List<String>> blockedUsers =
      ValueNotifier<List<String>>([]);

  // UGC 차단 사용자 목록 (사용자별 상태 - UID 기반 SSOT)
  final ValueNotifier<List<String>> blockedUids =
      ValueNotifier<List<String>>([]);

  // 연락처 지인 차단 목록 (사용자별 상태 - 이름 + 전화번호 해시/정규화)
  final ValueNotifier<List<Map<String, String>>> blockedAcquaintancePhones =
      ValueNotifier<List<Map<String, String>>>([]);

  static String normalizePhoneDigits(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('82') && digits.length >= 11) {
      return '0${digits.substring(2)}';
    }
    return digits;
  }

  bool isPhoneBlocked(String? rawPhone) {
    if (rawPhone == null || rawPhone.trim().isEmpty) return false;
    final clean = normalizePhoneDigits(rawPhone);
    if (clean.isEmpty) return false;
    return blockedAcquaintancePhones.value
        .any((item) => normalizePhoneDigits(item['phone'] ?? '') == clean);
  }

  void addBlockedAcquaintancePhone({
    required String name,
    required String phone,
  }) {
    final cleanPhone = normalizePhoneDigits(phone);
    if (cleanPhone.length < 10) return;
    final cleanName = name.trim().isEmpty ? '연락처 지인' : name.trim();
    final current =
        List<Map<String, String>>.from(blockedAcquaintancePhones.value);
    if (current.any((e) => normalizePhoneDigits(e['phone'] ?? '') == cleanPhone)) {
      return;
    }
    current.insert(0, {'name': cleanName, 'phone': cleanPhone});
    blockedAcquaintancePhones.value = current;
    _syncBlockedPhonesToFirestore(current);
  }

  int addBulkBlockedAcquaintancePhones(List<Map<String, String>> items) {
    final current =
        List<Map<String, String>>.from(blockedAcquaintancePhones.value);
    int added = 0;
    for (final item in items) {
      final cleanPhone = normalizePhoneDigits(item['phone'] ?? '');
      if (cleanPhone.length < 10) continue;
      if (current.any((e) => normalizePhoneDigits(e['phone'] ?? '') == cleanPhone)) {
        continue;
      }
      final cleanName = (item['name'] ?? '').trim().isEmpty
          ? '연락처 지인'
          : item['name']!.trim();
      current.add({'name': cleanName, 'phone': cleanPhone});
      added++;
    }
    if (added > 0) {
      blockedAcquaintancePhones.value = current;
      _syncBlockedPhonesToFirestore(current);
    }
    return added;
  }

  void removeBlockedAcquaintancePhone(String phone) {
    final cleanPhone = normalizePhoneDigits(phone);
    final current =
        List<Map<String, String>>.from(blockedAcquaintancePhones.value);
    current.removeWhere(
        (e) => normalizePhoneDigits(e['phone'] ?? '') == cleanPhone);
    blockedAcquaintancePhones.value = current;
    _syncBlockedPhonesToFirestore(current);
  }

  void _syncBlockedPhonesToFirestore(List<Map<String, String>> list) {
    if (!_canSyncUserDoc) return;
    try {
      FirebaseFirestore.instance
          .collection('user_states')
          .doc(activeUserId)
          .set({
        'blockedPhones': list,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[GlobalData] _syncBlockedPhonesToFirestore error: $e');
    }
  }

  // 신고 및 숨김 처리된 콘텐츠 ID 목록 (사용자별 상태)
  final ValueNotifier<List<String>> hiddenPostIds =
      ValueNotifier<List<String>>([]);

  // 내가 접수한 신고 내역 (사용자별 상태)
  final ValueNotifier<List<Map<String, dynamic>>> reportHistory =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  bool isUserBlocked(String? nickname, {String? uid}) {
    if (uid != null && uid.isNotEmpty && blockedUids.value.contains(uid)) {
      return true;
    }
    if (nickname == null || nickname.isEmpty) return false;
    return blockedUsers.value.contains(nickname);
  }

  bool isUidBlocked(String? uid) {
    if (uid == null || uid.isEmpty) return false;
    return blockedUids.value.contains(uid);
  }

  bool isTargetBlocked({String? uid, String? nickname}) {
    if (uid != null && uid.isNotEmpty && blockedUids.value.contains(uid)) {
      return true;
    }
    if (nickname != null && nickname.isNotEmpty && blockedUsers.value.contains(nickname)) {
      return true;
    }
    return false;
  }

  bool get _canSyncUserDoc {
    final uid = activeUserId.trim();
    return uid.isNotEmpty && uid != 'guest' && Firebase.apps.isNotEmpty;
  }

  void blockUid(String uid, {String? reason}) {
    final cleanUid = uid.trim();
    if (cleanUid.isEmpty || cleanUid == 'guest') return;
    final current = List<String>.from(blockedUids.value);
    if (!current.contains(cleanUid)) {
      current.add(cleanUid);
      blockedUids.value = current;

      if (_canSyncUserDoc) {
        try {
          FirebaseFirestore.instance.collection('users').doc(activeUserId).set({
            'blockedUids': FieldValue.arrayUnion([cleanUid]),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint('[GlobalData] Firestore blockUid sync error: $e');
        }
      }
    }
  }

  void unblockUid(String uid) {
    final cleanUid = uid.trim();
    final current = List<String>.from(blockedUids.value);
    if (current.contains(cleanUid)) {
      current.remove(cleanUid);
      blockedUids.value = current;

      if (_canSyncUserDoc) {
        try {
          FirebaseFirestore.instance.collection('users').doc(activeUserId).set({
            'blockedUids': FieldValue.arrayRemove([cleanUid]),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint('[GlobalData] Firestore unblockUid sync error: $e');
        }
      }
    }
  }

  void blockUser(String nickname, {String? reason}) {
    final cleanNick = nickname.trim();
    if (cleanNick.isEmpty) return;
    final current = List<String>.from(blockedUsers.value);
    if (!current.contains(cleanNick)) {
      current.add(cleanNick);
      blockedUsers.value = current;

      if (_canSyncUserDoc) {
        try {
          FirebaseFirestore.instance.collection('users').doc(activeUserId).set({
            'blockedUsers': FieldValue.arrayUnion([cleanNick]),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint('[GlobalData] Firestore blockUser sync error: $e');
        }
      }
    }
  }

  void unblockUser(String nickname) {
    final cleanNick = nickname.trim();
    final current = List<String>.from(blockedUsers.value);
    if (current.contains(cleanNick)) {
      current.remove(cleanNick);
      blockedUsers.value = current;

      if (_canSyncUserDoc) {
        try {
          FirebaseFirestore.instance.collection('users').doc(activeUserId).set({
            'blockedUsers': FieldValue.arrayRemove([cleanNick]),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint('[GlobalData] Firestore unblockUser sync error: $e');
        }
      }
    }
  }

  Future<void> submitReport({
    required String targetType,
    required String targetId,
    required String targetUser,
    required String reason,
    String? detail,
  }) async {
    if (targetId.isNotEmpty) {
      final hidden = List<String>.from(hiddenPostIds.value);
      if (!hidden.contains(targetId)) {
        hidden.add(targetId);
        hiddenPostIds.value = hidden;
      }
    }

    final history = List<Map<String, dynamic>>.from(reportHistory.value);
    final reportEntry = {
      'id': 'rep_${DateTime.now().millisecondsSinceEpoch}',
      'targetType': targetType,
      'targetId': targetId,
      'targetUser': targetUser,
      'reason': reason,
      'detail': detail ?? '',
      'status': '접수됨 (24시간 내 검토)',
      'date': '방금 전',
      'createdAt': Timestamp.now(),
    };
    history.insert(0, reportEntry);
    reportHistory.value = history;

    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'targetType': targetType,
        'targetId': targetId,
        'targetUser': targetUser,
        'reporterUser': userNickname.value,
        'reason': reason,
        'detail': detail ?? '',
        'status': 'pending_review',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[GlobalData] Firestore submitReport error: $e');
    }
  }

  bool isFavorite(String? id) {
    if (id == null) return false;
    return savedMeetups.value
        .any((m) => (m['id'] ?? m['title'])?.toString() == id);
  }

  void toggleFavorite(Map<String, dynamic> meetup) {
    final list = List<Map<String, dynamic>>.from(savedMeetups.value);
    final id = (meetup['id'] ?? meetup['title'])?.toString();
    if (id == null || id.isEmpty) return;
    final index =
        list.indexWhere((m) => (m['id'] ?? m['title'])?.toString() == id);
    final bool isAdding = index < 0;
    if (!isAdding) {
      list.removeAt(index);
    } else {
      list.insert(0, Map<String, dynamic>.from(meetup));
    }
    savedMeetups.value = list;

    if (_canSyncUserDoc) {
      try {
        FirebaseFirestore.instance.collection('users').doc(activeUserId).set({
          'savedMeetupCount': list.length,
          'savedMeetupIds': isAdding
              ? FieldValue.arrayUnion([id])
              : FieldValue.arrayRemove([id]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  void updateAvatar(String newAvatar) {
    userAvatar.value = newAvatar;
    if (_canSyncUserDoc) {
      try {
        FirebaseFirestore.instance.collection('users').doc(activeUserId).set({
          'avatarUrl': newAvatar,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  void updateLocation(String newLocation) {
    userLocation.value = newLocation;
    if (_canSyncUserDoc) {
      try {
        FirebaseFirestore.instance.collection('users').doc(activeUserId).set({
          'location': newLocation,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  void toggleNotification(String key) {
    final map = Map<String, bool>.from(notificationSettings.value);
    map[key] = !(map[key] ?? false);
    notificationSettings.value = map;
  }

  void submitReview(double newRating, String text) {
    double currentTotal = rating.value * reviewCount.value;
    currentTotal += newRating;
    reviewCount.value += 1;
    rating.value = currentTotal / reviewCount.value;

    if (newRating >= 4.0) {
      temperature.value += (newRating - 3.0) * 0.5;
    } else if (newRating <= 3.0) {
      temperature.value -= (4.0 - newRating) * 0.5;
    }

    if (temperature.value > 99.0) temperature.value = 99.0;
    if (temperature.value < 0.0) temperature.value = 0.0;

    final currentReviews = List<Map<String, dynamic>>.from(recentReviews.value);
    currentReviews
        .insert(0, {'rating': newRating, 'text': text, 'time': '방금 전'});
    recentReviews.value = currentReviews;
  }
}

final globalData = GlobalData();
