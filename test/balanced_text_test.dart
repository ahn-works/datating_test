import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot10_app/widgets/balanced_text.dart';

void main() {
  const samples = [
    '오늘 저녁 연트럴파크 강아지 산책 같이 하실 분 계신가요?',
    '🚗 [드라이브] 데이트 이동할 때 더 좋은 방식은?',
    '망원동 소금빵 맛집 오픈런 투어',
    '주말 아침 망원 한강공원 가벼운 5km 런닝 크루 🏃',
    '동네 러닝 크루 모집 🏃‍♀️',
    '🇰🇷 한강 야간 러닝',
    '한강',
    '',
  ];

  test('표시용 변환 후 제어문자만 제거하면 원문과 정확히 같다(원문 보존)', () {
    for (final s in samples) {
      expect(BalancedText.restore(BalancedText.display(s)), s, reason: s);
    }
  });

  test('이모지(서로게이트 페어·ZWJ·국기) 시퀀스가 그대로 유지된다', () {
    expect(BalancedText.display('동네 러닝 크루 모집 🏃‍♀️').contains('🏃‍♀️'), isTrue);
    expect(BalancedText.display('🇰🇷 한강 야간 러닝').contains('🇰🇷'), isTrue);
    expect(BalancedText.display('🚗 [드라이브] 데이트').contains('🚗'), isTrue);
    // 이모지 앞뒤에 U+2060이 끼어들지 않는다.
    final shown = BalancedText.display('주말 러닝 크루 🏃');
    expect(shown.endsWith('🏃'), isTrue);
    expect(shown.contains('\u2060🏃'), isFalse);
  });

  test('한글 어절 내부에는 줄바꿈 방지, 마지막 두 단어는 NBSP로 묶인다', () {
    final shown = BalancedText.display('망원동 소금빵 맛집 오픈런 투어');
    expect(shown.contains('하\u2060실'), isFalse);
    expect(shown.contains('오\u2060픈\u2060런\u00A0투\u2060어'), isTrue);
    expect(shown.contains('망\u2060원\u2060동 소'), isTrue);
  });

  test('한 단어·빈 문자열은 안전하게 처리된다', () {
    expect(BalancedText.display(''), '');
    expect(BalancedText.restore(BalancedText.display('한강')), '한강');
  });

  testWidgets('좁은 폭·글자 1.0/1.3/2.0배에서 오버플로우 없이 렌더링된다', (tester) async {
    for (final scale in [1.0, 1.3, 2.0]) {
      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: const Scaffold(
            body: SizedBox(
              width: 160,
              child: BalancedText(
                  '오늘 저녁 연트럴파크 강아지 산책 같이 하실 분 계신가요? 🐕',
                  style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ));
      expect(tester.takeException(), isNull, reason: 'scale $scale');
    }
  });
}
