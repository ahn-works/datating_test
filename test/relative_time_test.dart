import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oomu_app/utils/firestore_time.dart';

void main() {
  final now = DateTime(2026, 11, 27, 18, 0, 0);

  group('formatRelativeTime', () {
    test('1분 미만과 미래 시각은 방금 전', () {
      expect(formatRelativeTime(now.subtract(const Duration(seconds: 30)), now: now), '방금 전');
      expect(formatRelativeTime(now.add(const Duration(minutes: 5)), now: now), '방금 전');
    });

    test('분·시간·일 단위', () {
      expect(formatRelativeTime(now.subtract(const Duration(minutes: 7)), now: now), '7분 전');
      expect(formatRelativeTime(now.subtract(const Duration(hours: 3)), now: now), '3시간 전');
      expect(formatRelativeTime(now.subtract(const Duration(days: 2)), now: now), '2일 전');
    });

    test('7일 이상은 월·일', () {
      expect(formatRelativeTime(DateTime(2026, 11, 3, 9), now: now), '11월 3일');
    });

    test('Timestamp 와 ISO 문자열도 해석', () {
      final ts = Timestamp.fromDate(now.subtract(const Duration(minutes: 15)));
      expect(formatRelativeTime(ts, now: now), '15분 전');
      expect(
        formatRelativeTime(now.subtract(const Duration(hours: 1)).toIso8601String(), now: now),
        '1시간 전',
      );
    });

    test('해석할 수 없으면 빈 문자열', () {
      expect(formatRelativeTime(null, now: now), '');
      expect(formatRelativeTime('방금 전', now: now), '');
    });
  });

  group('resolvePostTimeLabel', () {
    test('createdAt 이 있으면 저장된 time 글자("방금 전")보다 우선', () {
      final post = {
        'time': '방금 전',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
      };
      expect(resolvePostTimeLabel(post, now: now), '3일 전');
    });

    test('createdAt 이 없으면 저장된 time 글자를 그대로 사용', () {
      expect(resolvePostTimeLabel({'time': '10분 전'}, now: now), '10분 전');
    });

    test('둘 다 없으면 빈 문자열', () {
      expect(resolvePostTimeLabel(<String, dynamic>{}, now: now), '');
      expect(resolvePostTimeLabel(null, now: now), '');
    });
  });
}
