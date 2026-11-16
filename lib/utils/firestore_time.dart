import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore 시간 필드(Timestamp, DateTime, ISO-8601 String, int/num epoch ms)를
/// 안전하게 epoch milliseconds(int)로 변환합니다.
/// 어떤 비정상적인 입력(null, 타입 혼용, 파싱 불가 문자열 등)에도 예외를 던지지 않고 0을 반환합니다.
int parseFirestoreEpochMillis(dynamic value) {
  if (value == null) return 0;
  if (value is Timestamp) {
    return value.millisecondsSinceEpoch;
  }
  if (value is DateTime) {
    return value.millisecondsSinceEpoch;
  }
  if (value is int) {
    if (value > 0 && value < 10000000000) {
      // 10자리(초 단위 epoch)일 경우 밀리초로 보정
      return value * 1000;
    }
    return value;
  }
  if (value is num) {
    final intVal = value.toInt();
    if (intVal > 0 && intVal < 10000000000) {
      return intVal * 1000;
    }
    return intVal;
  }
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 0;
    final dt = DateTime.tryParse(trimmed);
    if (dt != null) {
      return dt.millisecondsSinceEpoch;
    }
    final intParsed = int.tryParse(trimmed);
    if (intParsed != null) {
      if (intParsed > 0 && intParsed < 10000000000) {
        return intParsed * 1000;
      }
      return intParsed;
    }
  }
  return 0;
}

/// Firestore 시간 필드를 안전하게 DateTime으로 파싱합니다.
DateTime? parseFirestoreDateTime(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final dt = DateTime.tryParse(trimmed);
    if (dt != null) return dt;
    final intParsed = int.tryParse(trimmed);
    if (intParsed != null) {
      final ms = intParsed > 0 && intParsed < 10000000000
          ? intParsed * 1000
          : intParsed;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    return null;
  }
  if (value is int) {
    final ms = value > 0 && value < 10000000000 ? value * 1000 : value;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }
  if (value is num) {
    final intVal = value.toInt();
    final ms = intVal > 0 && intVal < 10000000000 ? intVal * 1000 : intVal;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }
  return null;
}

/// Firestore 시간 필드 간의 정렬 comparator.
/// [descending]이 true(기본값)이면 최신순(내림차순), false이면 과거순(오름차순)으로 정렬합니다.
/// Timestamp, DateTime, ISO-8601 String, int가 혼합되어 있어도 절대 예외를 던지지 않습니다.
int compareFirestoreTimes(dynamic a, dynamic b, {bool descending = true}) {
  final msA = parseFirestoreEpochMillis(a);
  final msB = parseFirestoreEpochMillis(b);
  return descending ? msB.compareTo(msA) : msA.compareTo(msB);
}

