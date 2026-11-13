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
    userPhone.value = '';
    isPhoneVerified.value = false;
    temperature.value = 0.0;
    rating.value = 0.0;
    reviewCount.value = 0;
    recentReviews.value = [];
    savedMeetups.value = [];
    blockedUsers.value = [];
    hiddenPostIds.value = [];
    reportHistory.value = [];
  }

  void applyProfileData(Map<String, dynamic>? data) {
    if (data == null) return;
    final loc = (data['location'] as String?)?.trim();
    if (loc != null && loc.isNotEmpty) {
      userLocation.value = loc;
    }
    final nick = (data['nickname'] as String?)?.trim();
    if (nick != null && nick.isNotEmpty) {
      userNickname.value = nick;
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
    final rawTemp = data['mannerTemp'] ?? data['manner'] ?? data['temperature'];
    if (rawTemp is num && rawTemp.toDouble() > 0) {
      temperature.value = rawTemp.toDouble();
    } else if (rawTemp is String) {
      final parsed = double.tryParse(rawTemp);
      if (parsed != null && parsed > 0) {
        temperature.value = parsed;
      }
    }
    if (data['savedMeetups'] is List) {
      savedMeetups.value = (data['savedMeetups'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data['blockedUsers'] is List) {
      blockedUsers.value = (data['blockedUsers'] as List)
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
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
      final rawIds = data?['savedMeetupIds'];
      if (rawIds is List && rawIds.isNotEmpty) {
        final ids = rawIds
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .take(30)
            .toList();
        final List<Map<String, dynamic>> loadedMeetups = [];
        for (final mId in ids) {
          try {
            final mDoc = await FirebaseFirestore.instance
                .collection('meetups')
                .doc(mId)
                .get();
            if (mDoc.exists && mDoc.data() != null) {
              loadedMeetups.add({...mDoc.data()!, 'id': mDoc.id});
            } else {
              loadedMeetups.add({'id': mId, 'title': '찜한 모임'});
            }
          } catch (_) {
            loadedMeetups.add({'id': mId, 'title': '찜한 모임'});
          }
        }
        if (isActiveSession(requestSession, uid) &&
            requestGeneration == _syncGeneration) {
          savedMeetups.value = loadedMeetups;
        }
      }
    } catch (e) {
      debugPrint('[GlobalData] syncUserProfileFromFirestore error: $e');
    }
  }

  // 사용자 프로필 및 위치 (미설정 상태: 빈 문자열)
  final ValueNotifier<String> userAvatar = ValueNotifier<String>('');
  final ValueNotifier<String> userLocation = ValueNotifier<String>('');
  final ValueNotifier<String> userNickname = ValueNotifier<String>('');
  final ValueNotifier<String> userPhone = ValueNotifier<String>('');
  final ValueNotifier<bool> isPhoneVerified = ValueNotifier<bool>(false);

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

  // UGC 차단 사용자 목록 (사용자별 상태)
  final ValueNotifier<List<String>> blockedUsers =
      ValueNotifier<List<String>>([]);

  // 신고 및 숨김 처리된 콘텐츠 ID 목록 (사용자별 상태)
  final ValueNotifier<List<String>> hiddenPostIds =
      ValueNotifier<List<String>>([]);

  // 내가 접수한 신고 내역 (사용자별 상태)
  final ValueNotifier<List<Map<String, dynamic>>> reportHistory =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  bool isUserBlocked(String? nickname) {
    if (nickname == null || nickname.isEmpty) return false;
    return blockedUsers.value.contains(nickname);
  }

  void blockUser(String nickname, {String? reason}) {
    if (nickname.isEmpty) return;
    final current = List<String>.from(blockedUsers.value);
    if (!current.contains(nickname)) {
      current.add(nickname);
      blockedUsers.value = current;

      try {
        FirebaseFirestore.instance.collection('users').doc(activeUserId).set({
          'blockedUsers': FieldValue.arrayUnion([nickname]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('[GlobalData] Firestore blockUser sync error: $e');
      }
    }
  }

  void unblockUser(String nickname) {
    final current = List<String>.from(blockedUsers.value);
    if (current.contains(nickname)) {
      current.remove(nickname);
      blockedUsers.value = current;

      try {
        FirebaseFirestore.instance.collection('users').doc(activeUserId).set({
          'blockedUsers': FieldValue.arrayRemove([nickname]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('[GlobalData] Firestore unblockUser sync error: $e');
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
      'createdAt': DateTime.now().toIso8601String(),
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

  void updateAvatar(String newAvatar) {
    userAvatar.value = newAvatar;
    try {
      FirebaseFirestore.instance.collection('users').doc(activeUserId).set({
        'avatarUrl': newAvatar,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  void updateLocation(String newLocation) {
    userLocation.value = newLocation;
    try {
      FirebaseFirestore.instance.collection('users').doc(activeUserId).set({
        'location': newLocation,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
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
