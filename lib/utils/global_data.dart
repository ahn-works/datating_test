import 'package:flutter/foundation.dart';

class GlobalData {
  static final GlobalData _instance = GlobalData._internal();
  factory GlobalData() => _instance;
  GlobalData._internal();

  final ValueNotifier<double> temperature = ValueNotifier<double>(41.2); 
  final ValueNotifier<double> rating = ValueNotifier<double>(4.8);
  final ValueNotifier<int> reviewCount = ValueNotifier<int>(24);
  final ValueNotifier<List<Map<String, dynamic>>> recentReviews = ValueNotifier<List<Map<String, dynamic>>>([]);

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
