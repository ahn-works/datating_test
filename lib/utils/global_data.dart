import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GlobalData {
  static final GlobalData _instance = GlobalData._internal();
  factory GlobalData() => _instance;
  GlobalData._internal();

  final ValueNotifier<double> temperature = ValueNotifier<double>(41.2); 
  final ValueNotifier<double> rating = ValueNotifier<double>(4.8);
  final ValueNotifier<int> reviewCount = ValueNotifier<int>(24);
  final ValueNotifier<List<Map<String, dynamic>>> recentReviews = ValueNotifier<List<Map<String, dynamic>>>([]);


  // 3인 유저 페르소나 및 동네 데이터 (김민서: 서교동, 이준호: 성수동, 박지연: 연남동)
  static final List<Map<String, dynamic>> exampleUsers = [
    {
      'id': 'user_minseo',
      'name': '김민서',
      'nickname': '김민서',
      'location': '마포구 서교동',
      'avatar': 'assets/images/kr_female_1.jpg',
      'manner': 43.5,
      'bio': '서교동 골목 카페와 에그타르트 투어 진심러 🍰 조용하고 감성 있는 공간을 좋아해요.',
      'interests': ['디저트투어', '보드게임', '전시회', '소셜다이닝'],
    },
    {
      'id': 'user_junho',
      'name': '이준호',
      'nickname': '이준호',
      'location': '성동구 성수동',
      'avatar': 'assets/images/kr_male_1.jpg',
      'manner': 44.0,
      'bio': '성수동 서울숲 야간 러닝과 팝업스토어 탐방을 즐깁니다 🏃 편하게 모여요!',
      'interests': ['서울숲러닝', '팝업스토어', 'LP청음', '야간산책'],
    },
    {
      'id': 'user_jiyeon',
      'name': '박지연',
      'nickname': '박지연',
      'location': '마포구 연남동',
      'avatar': 'assets/images/kr_female_2.jpg',
      'manner': 42.8,
      'bio': '연남동 경의선 숲길 산책과 두쫀쿠 오픈런 메이트 환영해요 🥐 맛집 뿌시기 팟!',
      'interests': ['두바이쿠키', '카페투어', '내추럴와인', '맛집웨이팅'],
    },
  ];

  // 사용자 프로필 및 위치
  final ValueNotifier<String> userAvatar = ValueNotifier<String>('assets/images/kr_female_1.jpg');
  final ValueNotifier<String> userLocation = ValueNotifier<String>('마포구 서교동');
  final ValueNotifier<String> userNickname = ValueNotifier<String>('매운맛킬러');

  // 내가 찜한 모임
  final ValueNotifier<List<Map<String, dynamic>>> savedMeetups = ValueNotifier<List<Map<String, dynamic>>>([
    {
      'id': 'saved_01',
      'title': '성수동 감성 카페 & 디저트 투어 ☕',
      'mainCategory': '일상 & 푸드',
      'category': '카페 & 디저트',
      'location': '성동구 성수동 카페거리',
      'date': '이번주 일요일 14:00',
      'imageUrl': 'assets/images/cover_cafe.jpg',
      'members': '2/4',
      'manner': 38.5,
      'host': '성수동힙스터',
      'hostAvatar': 'assets/images/kr_female_2.jpg',
      'isFemaleOnly': false,
    },
    {
      'id': 'saved_02',
      'title': '연남동 내추럴 와인바 소셜 다이닝 🍷',
      'mainCategory': '일상 & 푸드',
      'category': '동네 술 한잔',
      'location': '마포구 연남동 미로길',
      'date': '금요일 저녁 7:30',
      'imageUrl': 'assets/images/cover_wine.jpg',
      'members': '3/4',
      'manner': 42.0,
      'host': '와인앤모어',
      'hostAvatar': 'assets/images/kr_male_1.jpg',
      'isFemaleOnly': false,
    }
  ]);

  // 알림 설정 상태
  final ValueNotifier<Map<String, bool>> notificationSettings = ValueNotifier<Map<String, bool>>({
    'joinApproval': true,
    'newChat': true,
    'secretMatch': true,
    'bombTimer': true,
    'marketing': false,
  });

  // UGC 차단 사용자 목록 (앱스토어 Guideline 1.2 대응)
  final ValueNotifier<List<String>> blockedUsers = ValueNotifier<List<String>>([
    '불량회원99',
  ]);

  // 신고 및 숨김 처리된 콘텐츠 ID 목록
  final ValueNotifier<List<String>> hiddenPostIds = ValueNotifier<List<String>>([]);

  // 내가 접수한 신고 내역
  final ValueNotifier<List<Map<String, dynamic>>> reportHistory = ValueNotifier<List<Map<String, dynamic>>>([
    {
      'id': 'rep_init_01',
      'targetType': '사용자',
      'targetUser': '불량회원99',
      'reason': '스팸 및 불법 광고 홍보',
      'status': '조치 완료 (이용 정지)',
      'date': '2026. 10. 15',
    },
  ]);

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

      // Firestore 비동기 저장
      try {
        FirebaseFirestore.instance.collection('users').doc('test_user_1').set({
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

      // Firestore 비동기 삭제
      try {
        FirebaseFirestore.instance.collection('users').doc('test_user_1').set({
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
    // 1. 숨김 콘텐츠에 즉시 추가하여 로컬에서 바로 보이지 않게 처리
    if (targetId.isNotEmpty) {
      final hidden = List<String>.from(hiddenPostIds.value);
      if (!hidden.contains(targetId)) {
        hidden.add(targetId);
        hiddenPostIds.value = hidden;
      }
    }

    // 2. 신고 내역 목록에 추가
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

    // 3. Firestore reports 컬렉션에 실시간 저장 (운영진 검토 파이프라인)
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
    return savedMeetups.value.any((m) => m['id'] == id);
  }

  void toggleFavorite(Map<String, dynamic> meetup) {
    final list = List<Map<String, dynamic>>.from(savedMeetups.value);
    final id = meetup['id'] ?? meetup['title'];
    final index = list.indexWhere((m) => (m['id'] ?? m['title']) == id);
    if (index >= 0) {
      list.removeAt(index);
    } else {
      list.insert(0, Map<String, dynamic>.from(meetup));
    }
    savedMeetups.value = list;

    // Firestore 비동기 동기화
    try {
      FirebaseFirestore.instance.collection('users').doc('test_user_1').set({
        'savedMeetupCount': list.length,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  void updateAvatar(String newAvatar) {
    userAvatar.value = newAvatar;
    try {
      FirebaseFirestore.instance.collection('users').doc('test_user_1').set({
        'avatarUrl': newAvatar,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  void updateLocation(String newLocation) {
    userLocation.value = newLocation;
    try {
      FirebaseFirestore.instance.collection('users').doc('test_user_1').set({
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
    currentReviews.insert(0, {'rating': newRating, 'text': text, 'time': '방금 전'});
    recentReviews.value = currentReviews;
  }
}

final globalData = GlobalData();
