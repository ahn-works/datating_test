import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:oomu_app/widgets/balanced_text.dart';
import 'package:oomu_app/utils/profile_policy.dart';
import 'package:oomu_app/utils/oomu_ui_helpers.dart';
import 'package:oomu_app/utils/global_data.dart';
import 'package:oomu_app/services/meetup_application_service.dart';
import 'package:oomu_app/services/discovery_api_service.dart';
import 'package:oomu_app/services/chat_repository.dart';
import 'package:oomu_app/widgets/meetup_card_footer.dart';
import 'package:oomu_app/widgets/oomu_discovery_lifestyle_hub.dart';
import 'package:oomu_app/screens/event_detail_screen.dart';
import 'package:oomu_app/screens/oomu_detail_screen.dart';
import 'package:oomu_app/screens/user_profile_screen.dart';
import 'package:oomu_app/screens/community_post_detail_screen.dart';
import 'package:oomu_app/screens/home/home_meetup_section.dart';
import 'package:oomu_app/screens/chat/chat_system_cards.dart';
import 'package:oomu_app/screens/login_screen.dart';
import 'package:oomu_app/widgets/balanced_heading.dart';
import 'package:flutter/rendering.dart';
import 'package:oomu_app/screens/oomu_host_screen.dart';
import 'package:oomu_app/utils/event_meetup_category.dart';

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
      await tester.tap(find.textContaining('모임 열기'));
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
            child: const LoginScreen(initialStage: 2),
          )));
      await tester.pump();
      expect(find.text('로그인'), findsOneWidget);
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
        expect(find.text('3/4명'), findsOneWidget);
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
      expect(find.textContaining('모임 열기'), findsOneWidget);
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
      // 모임 소개는 BalancedText.display(어절 줄바꿈용 보이지 않는 문자)로 그려지므로 원문으로 되돌려 찾는다.
      final introFinder = find.byWidgetPredicate((w) =>
          w is Text &&
          BalancedText.restore(w.data ?? '').contains('아직 모임 소개'));
      await tester.scrollUntilVisible(introFinder, 200,
          scrollable: find.byType(Scrollable).first);
      expect(introFinder, findsOneWidget);
      expect(find.textContaining('매운 음식'), findsNothing);
      expect(find.text('여수빵순이'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.binding.setSurfaceSize(null);
    });
  });

  testWidgets(
      'Stage 3 (5): UID block in UserProfileScreen propagates across profile, post, and meetup even if nickname changes',
      (tester) async {
    globalData.resetSession();
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(MaterialApp(
        theme: OomuUiHelpers.buildTheme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UserProfileScreen(
                        userId: 'uid_target_b',
                        userName: '이전닉네임B',
                      ),
                    ),
                  );
                },
                child: const Text('프로필 열기'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('프로필 열기'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('이 사용자 차단 및 매칭 제외'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('차단하기'));
      await tester.pumpAndSettle();

      expect(globalData.blockedUids.value, contains('uid_target_b'));
      expect(globalData.blockedUsers.value, contains('이전닉네임B'));

      // Even if user B changes nickname to '바뀐닉네임B', UID block catches profile, post, and meetup
      await tester.pumpWidget(MaterialApp(
        theme: OomuUiHelpers.buildTheme(),
        home: const UserProfileScreen(
          userId: 'uid_target_b',
          userName: '바뀐닉네임B',
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('차단된 사용자의 프로필입니다.'), findsOneWidget);

      await tester.pumpWidget(MaterialApp(
        theme: OomuUiHelpers.buildTheme(),
        home: const CommunityPostDetailScreen(post: {
          'id': 'post_b_1',
          'authorId': 'uid_target_b',
          'author': '바뀐닉네임B',
          'title': '차단된 글 제목',
          'content': '차단된 글 본문',
        }),
      ));
      await tester.pumpAndSettle();
      expect(find.text('차단된 사용자의 게시글입니다.'), findsOneWidget);

      await tester.pumpWidget(MaterialApp(
        theme: OomuUiHelpers.buildTheme(),
        home: const OOMUDetailScreen(meetup: {
          'id': 'meetup_b_1',
          'hostUid': 'uid_target_b',
          'host': '바뀐닉네임B',
          'title': '차단된 모임 제목',
          'members': '1/4',
        }),
      ));
      await tester.pumpAndSettle();
      expect(find.text('차단한 사용자의 모임입니다.'), findsOneWidget);
    });
  });

  test(
      'Stage 3 (6): Discovery weather parallel fetch tolerates partial failure without dropping available data',
      () async {
    // 1) Meteo succeeds, Air quality fails (500)
    final partialMeteoClient = MockClient((req) async {
      if (req.url.host.contains('air-quality-api')) {
        return http.Response('Server Error', 500);
      }
      return http.Response(
        jsonEncode({
          'current': {'temperature_2m': 19.4, 'weather_code': 0}
        }),
        200,
      );
    });
    final res1 = await DiscoveryApiService.instance.fetchWeatherAndRecipes(
      '전남 여수시 화장동',
      client: partialMeteoClient,
    );
    expect(res1.hasWeather, isTrue);
    expect(res1.tempC, 19.4);
    expect(res1.weatherCondition, '맑음');
    expect(res1.airQualityLabel, '확인불가');

    // 2) Meteo fails (exception), Air quality succeeds
    final partialAirClient = MockClient((req) async {
      if (!req.url.host.contains('air-quality-api')) {
        throw Exception('Timeout');
      }
      return http.Response(
        jsonEncode({
          'current': {'pm10': 92}
        }),
        200,
      );
    });
    final res2 = await DiscoveryApiService.instance.fetchWeatherAndRecipes(
      '전남 여수시 화장동',
      client: partialAirClient,
    );
    expect(res2.hasWeather, isTrue);
    expect(res2.pm10, 92);
    expect(res2.airQualityLabel, '나쁨');

    // 3) Both fail
    final failClient = MockClient((_) async => http.Response('Error', 503));
    final res3 = await DiscoveryApiService.instance.fetchWeatherAndRecipes(
      '전남 여수시 화장동',
      client: failClient,
    );
    expect(res3.hasWeather, isFalse);
    expect(res3.moodHeadline, '날씨 정보를 불러올 수 없어요');
  });

  testWidgets(
      'Stage 3 (7): Home region filter strictly excludes other regions and fake discounts show empty state',
      (tester) async {
    expect(
        OomuUiHelpers.matchesRegionFilter('전남 여수시 화장동', '전남 여수시 학동'), isTrue);
    expect(
        OomuUiHelpers.matchesRegionFilter('전남 여수시 화장동', '서울 마포구 서교동'), isFalse);
    expect(
        OomuUiHelpers.matchesRegionFilter('서울 마포구 서교동', '전남 여수시 화장동'), isFalse);

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(MaterialApp(
        theme: OomuUiHelpers.buildTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: HomeMeetupSection(
              currentLocation: '전남 여수시 화장동',
              selectedCategoryIndex: 0,
              selectedSubCategory: '전체',
              isListView: true,
              isLoading: false,
              showAllMeetups: true,
              meetups: const [
                {
                  'id': 'yeosu_1',
                  'title': '여수 화장동 소금빵 모임',
                  'location': '전남 여수시 화장동',
                  'host': '여수호스트',
                  'members': '2/4',
                },
                {
                  'id': 'seoul_1',
                  'title': '서울 홍대 방탈출 모임',
                  'location': '서울 마포구 서교동',
                  'host': '서울호스트',
                  'members': '2/4',
                },
              ],
              onToggleView: (_) {},
              onToggleShowAll: () {},
              onMeetupTap: (_) {},
              onResetFilters: () {},
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(find.text('여수 화장동 소금빵 모임'), findsOneWidget);
      expect(find.text('서울 홍대 방탈출 모임'), findsNothing);

      // Discount tab (category 2) shows empty state when no real discounts exist
      await tester.pumpWidget(MaterialApp(
        theme: OomuUiHelpers.buildTheme(),
        home: const Scaffold(
          body: SingleChildScrollView(
            child: OomuDiscoveryLifestyleHub(
              currentLocation: '전남 여수시 화장동',
              initialCategoryIndex: 2,
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(find.text('등록된 정보가 아직 없어요'), findsOneWidget);
      expect(find.textContaining('타임세일'), findsNothing);
    });
  });

  testWidgets(
      'Stage 3 (3) & Stage 4 CI: Non-participant seed messages are hidden, SafeReturnCard uses actual sender, and design token check fails on violation',
      (tester) async {
    expect(
      isLegacyChatSeed(
        {
          'id': 'msg_txt_01',
          'text': '안녕하세요! 다들 마라탕 좋아하시죠?',
          'senderId': 'non_participant_seed',
        },
        participantIds: {'uid_host', 'uid_member'},
      ),
      isTrue,
    );
    expect(
      isLegacyChatSeed(
        {
          'id': 'real_msg_1',
          'text': '반갑습니다!',
          'senderId': 'uid_member',
        },
        participantIds: {'uid_host', 'uid_member'},
      ),
      isFalse,
    );

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(MaterialApp(
        theme: OomuUiHelpers.buildTheme(),
        home: const Scaffold(
          body: InteractiveSafeReturnCard(
            msg: {
              'sender': '성산러너_지훈',
              'title': '안심 귀가 완료',
              'desc': '무사히 도착했습니다!',
            },
            isMe: false,
            chatRoomId: 'room_1',
          ),
        ),
      ));
      await tester.pump();
      expect(find.text('안심 귀가 완료'), findsOneWidget);
      expect(find.text('민지'), findsNothing);
    });

    // Verify check_design_tokens.py --compare exits non-zero when baseline is exceeded
    final tmpDir = Directory.systemTemp.createTempSync('token_test_');
    final strictBaseline = File('${tmpDir.path}/strict_baseline.json');
    strictBaseline.writeAsStringSync(jsonEncode({
      'total': {
        'color_kinds': 0,
        'color_count': 0,
        'font_kinds': 0,
        'font_count': 0,
        'radius_kinds': 0,
        'radius_count': 0,
      }
    }));
    final proc = Process.runSync(
      'python',
      [
        'scripts/check_design_tokens.py',
        '--compare',
        '--baseline',
        strictBaseline.path,
      ],
    );
    tmpDir.deleteSync(recursive: true);
    expect(proc.exitCode, isNonZero);
  });
}
