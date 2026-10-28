import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:spot10_app/screens/soso_car_detail_screen.dart';
import 'package:spot10_app/screens/soso_car_home_screen.dart';

const _testMeetup = <String, dynamic>{
  'title': '익명 샘플 모임',
  'category': '카페/수다',
  'host': '익명 호스트',
  'imageUrl': 'https://example.invalid/sample.png',
};

void main() {
  testWidgets(
    'OOMU 홈 화면이 Firebase 미연결 상태에서 익명 샘플 모임을 렌더링한다',
    (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(const MaterialApp(home: OOMUHomeScreen()));
        await tester.pump();

        expect(find.text('마포구 서교동'), findsOneWidget);
        expect(find.textContaining('오늘 번개'), findsWidgets);
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -1200),
        );
        await tester.pumpAndSettle();
        expect(find.text('성수동힙스터'), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    },
  );

  testWidgets('참여 신청하기 버튼 탭 시 참여 신청 메시지 폼을 연다', (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        const MaterialApp(home: OOMUDetailScreen(meetup: _testMeetup)),
      );
      await tester.pump();

      await tester.tap(find.text('참여 신청하기'));
      await tester.pumpAndSettle();

      expect(find.text('참여 신청 메시지'), findsOneWidget);
      expect(find.text('신청서 전송하기'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('모임 상세의 신고 메뉴에서 신고 사유를 표시한다', (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        const MaterialApp(home: OOMUDetailScreen(meetup: _testMeetup)),
      );
      await tester.pump();

      await tester.tap(find.byTooltip('모임 신고'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('이 모임 신고하기'));
      await tester.pumpAndSettle();

      expect(find.text('신고 사유를 선택해 주세요'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
