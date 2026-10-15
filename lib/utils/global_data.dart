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
