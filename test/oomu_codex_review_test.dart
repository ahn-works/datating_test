import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:spot10_app/utils/profile_policy.dart';
import 'package:spot10_app/utils/oomu_ui_helpers.dart';
import 'package:spot10_app/services/meetup_application_service.dart';
import 'package:spot10_app/widgets/meetup_card_footer.dart';
import 'package:spot10_app/screens/event_detail_screen.dart';
import 'package:spot10_app/screens/soso_car_detail_screen.dart';
import 'package:spot10_app/screens/login_screen.dart';
import 'package:spot10_app/widgets/balanced_heading.dart';
import 'package:flutter/rendering.dart';
import 'package:spot10_app/screens/soso_car_host_screen.dart';
import 'package:spot10_app/utils/event_meetup_category.dart';

void main() {
  test(
      'event categories map to the existing meetup taxonomy without inventing a category',
      () {
    expect(eventMeetupCategory('카페')?.sub, '카페 & 디저트');
    expect(eventMeetupCategory('전시')?.sub, '전시 & 팝업스토어');
    expect(eventMeetupCategory('뮤지컬')?.main, '문화 & 엔터');
    expect(eventMeetupCategory('알 수 없는 분류'), isNull);
  });
  testWidgets(
      'a place opens meetup creation with its title, place and correct cafe category',
      (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(MaterialApp(
          theme: OomuUiHelpers.buildTheme(),
          home: const EventDetailScreen(event: {
            'id': 'cafe_example',
            'title': '소금빵 카페',
            'location': '여수 화장동',
            'category': '카페',
          })));
      await tester.pumpAndSettle();
      await tester.tap(find.text('이곳에 같이 갈 모임 열기'));
      await tester.pumpAndSettle();
      final screen = tester.widget<OOMUHostScreen>(find.byType(OOMUHostScreen));
      expect(screen.initialTitle, '소금빵 카페 함께 가요');
      expect(screen.initialLocation, '여수 화장동');
      expect(screen.initialSubCategory, '카페 & 디저트');
      expect(screen.sourceEventId, 'cafe_example');
      expect(tester.takeException(), isNull);
    });
  });
  testWidgets(
      'two-line Korean event heading breaks at an existing word boundary',
      (tester) async {
    const title = '여수 화장동 소금빵 카페 함께 둘러보기 🥐';
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: Padding(
      padding: EdgeInsets.all(20),
      child: BalancedHeading(title,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
    ))));
    await tester.pump();
    expect(find.text(title), findsOneWidget);
    final paragraph = tester.renderObject<RenderParagraph>(find.text(title));
    final end =
        paragraph.getPositionForOffset(Offset(paragraph.size.width, 1)).offset;
    expect(
        end == title.length ||
            RegExp(r'\s').hasMatch(title[end]) ||
            RegExp(r'\s').hasMatch(title[end - 1]),
        isTrue);
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });
  testWidgets('login remains scrollable on a small screen with enlarged text',
      (tester) async {
    for (final scale in [1.0, 1.3, 2.0]) {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      await tester.pumpWidget(MaterialApp(
          theme: OomuUiHelpers.buildTheme(),
          home: MediaQuery(
            data: MediaQueryData(
                size: const Size(360, 640),
                textScaler: TextScaler.linear(scale)),
            child: const LoginScreen(),
          )));
      await tester.pump();
      expect(find.text('휴대폰 번호로 시작하기'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    await tester.binding.setSurfaceSize(null);
  });
  test(
      'default nickname/location cannot skip onboarding; explicit completion is retained',
      () {
    expect(
        hasCompletedProfile({
          'nickname': '우리동네이웃',
          'location': '서울 마포구 연남동',
          'isProfileComplete': false
        }),
        isFalse);
    expect(hasCompletedProfile({'nickname': '회원', 'location': '동네'}), isFalse);
    expect(hasCompletedProfile({'isProfileComplete': true}), isTrue);
    expect(hasCompletedProfile(null), isFalse);
  });

  test(
      'phone comparison uses one canonical number and rejects incomplete numbers',
      () {
    for (final phone in ['010-1234-5678', '+82 10 1234 5678', '1012345678']) {
      expect(normalizeKoreanMobile(phone), '+821012345678');
    }
    expect(normalizeKoreanMobile('0101234'), isNull);
    expect(normalizeKoreanMobile('0212345678'), isNull);
  });

  test('full meetup is described as closed, not almost full', () {
    expect(OomuUiHelpers.calcRemainingSeats('4/4'), '모집 마감');
    expect(MeetupApplicationService.capacity({'members': '3/4'}), 4);
    expect(MeetupApplicationService.attendance({'members': '3/4'}), 3);
  });

  testWidgets(
      'identity, temperature and attendance remain readable with enlarged text',
      (tester) async {
    for (final width in [360.0, 390.0, 430.0]) {
      for (final scale in [1.0, 1.3, 2.0]) {
        await tester.binding.setSurfaceSize(Size(width, 844));
        await tester.pumpWidget(MaterialApp(
            home: MediaQuery(
          data: MediaQueryData(
              size: Size(width, 844), textScaler: TextScaler.linear(scale)),
          child: const Scaffold(
              body: Padding(
                  padding: EdgeInsets.all(20),
                  child: MeetupCardFooter(meetup: {
                    'host': '여수빵순이',
                    'manner': 42.5,
                    'members': '3/4',
                  }))),
        )));
        await tester.pump();
        expect(find.text('여수빵순이'), findsOneWidget);
        expect(find.text('3/4명 참여'), findsOneWidget);
        expect(tester.takeException(), isNull);
        final hostText = tester.renderObject<RenderBox>(find.text('여수빵순이'));
        expect(hostText.size.width, greaterThan(0));
      }
    }
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets(
      'missing event content never claims KOPIS curation or permanent operation',
      (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(MaterialApp(
          theme: OomuUiHelpers.buildTheme(),
          home: const EventDetailScreen(event: {
            'title': '동네 소금빵 가게',
            'location': '여수 화장동',
            'category': '카페',
          })));
      await tester.pumpAndSettle();
      expect(find.text('상시 운영'), findsNothing);
      expect(find.textContaining('KOPIS'), findsNothing);
      await tester.scrollUntilVisible(find.textContaining('아직 자세한 소개'), 200,
          scrollable: find.byType(Scrollable).first);
      expect(find.textContaining('아직 자세한 소개'), findsOneWidget);
      expect(find.text('이곳에 같이 갈 모임 열기'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets(
      'regular meetup has no inferred lightning banner and no unrelated default description',
      (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(MaterialApp(
          theme: OomuUiHelpers.buildTheme(),
          home: const OOMUDetailScreen(meetup: {
            'title': '오늘 카페에 함께 가요 🥐',
            'host': '여수빵순이',
            'category': '카페',
            'members': '2/4',
            'manner': 42.5,
            'imageUrl': 'https://example.invalid/cafe.png',
          })));
      await tester.pumpAndSettle();
      expect(find.text('실시간 당일 번개'), findsNothing);
      await tester.scrollUntilVisible(find.textContaining('아직 모임 소개'), 200,
          scrollable: find.byType(Scrollable).first);
      expect(find.textContaining('아직 모임 소개'), findsOneWidget);
      expect(find.textContaining('매운 음식'), findsNothing);
      expect(find.text('여수빵순이'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.binding.setSurfaceSize(null);
    });
  });
}
