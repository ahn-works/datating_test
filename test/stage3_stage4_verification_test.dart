import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:oomu_app/screens/chat/chat_system_cards.dart';
import 'package:oomu_app/screens/my_page_screen.dart';
import 'package:oomu_app/screens/oomu_home_screen.dart';
import 'package:oomu_app/screens/user_profile_screen.dart';
import 'package:oomu_app/services/chat_repository.dart';
import 'package:oomu_app/services/discovery_api_service.dart';
import 'package:oomu_app/ui/oomu_avatar.dart';
import 'package:oomu_app/utils/global_data.dart';
import 'package:oomu_app/utils/meetup_member_helper.dart';
import 'package:oomu_app/utils/oomu_ui_helpers.dart';
import 'package:oomu_app/widgets/oomu_discovery_lifestyle_hub.dart';

void main() {
  setUp(() {
    globalData.resetSession();
  });

  group('Stage 3 & Stage 4 Comprehensive Verification Tests', () {
    test('3-1 & 3-7. Strict region filter excludes unrelated regions and unknown region from 우리동네', () {
      const userLoc = '전남 여수시 화장동';

      // Exact dong match -> 3
      expect(
        OomuUiHelpers.calculateLocationRelevanceScore(userLoc, '여수시 화장동 카페거리'),
        3,
      );
      expect(
        OomuUiHelpers.matchesRegionFilter(userLoc, '여수시 화장동 카페거리'),
        isTrue,
      );

      // Same city (여수시) match -> 2
      expect(
        OomuUiHelpers.calculateLocationRelevanceScore(userLoc, '전남 여수시 학동'),
        2,
      );
      expect(
        OomuUiHelpers.matchesRegionFilter(userLoc, '전남 여수시 학동'),
        isTrue,
      );

      // Unrelated city (성수, 망원, 홍대) -> 0 & excluded
      for (final otherLoc in ['성수동 연무장길', '마포구 망원동', '홍대입구역 3번출구']) {
        expect(
          OomuUiHelpers.calculateLocationRelevanceScore(userLoc, otherLoc),
          0,
        );
        expect(
          OomuUiHelpers.matchesRegionFilter(userLoc, otherLoc),
          isFalse,
        );
      }

      // Unknown location ('지역 미확인') -> 0 & excluded
      expect(
        OomuUiHelpers.calculateLocationRelevanceScore(userLoc, '지역 미확인'),
        0,
      );
      expect(
        OomuUiHelpers.matchesRegionFilter(userLoc, '지역 미확인'),
        isFalse,
      );
    });

    test('3-2. MeetupMemberHelper.formatMembersLabel never exposes raw UID arrays', () {
      final listDoc = {
        'members': ['uid_host_1', 'uid_guest_2', 'uid_guest_3'],
        'maxMembers': 6,
      };
      expect(MeetupMemberHelper.formatMembersLabel(listDoc), '3/6');
      expect(MeetupMemberHelper.formatMembersLabel(listDoc).contains('uid_'), isFalse);

      final stringDoc = {
        'members': '2/5',
      };
      expect(MeetupMemberHelper.formatMembersLabel(stringDoc), '2/5');
    });

    test('3-3. ChatRepository.isLegacyChatSeed filters seeded messages and non-participants', () {
      final participants = {'uid_alice', 'uid_bob'};

      // Seed message marker
      expect(
        isLegacyChatSeed(
          {'text': '안녕하세요', 'isSeed': true, 'senderId': 'uid_alice'},
          participantIds: participants,
        ),
        isTrue,
      );

      // Non-participant senderId
      expect(
        isLegacyChatSeed(
          {'text': '실제 대화입니다', 'senderId': 'uid_stranger'},
          participantIds: participants,
        ),
        isTrue,
      );

      // Valid participant message
      expect(
        isLegacyChatSeed(
          {'text': '오늘 7시에 봬요!', 'senderId': 'uid_alice'},
          participantIds: participants,
        ),
        isFalse,
      );
    });

    testWidgets('3-3. Chat system interactive cards render dynamic sender name instead of hardcoded 민지', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  InteractiveScheduleCard(
                    msg: {
                      'sender': '여수러닝호스트',
                      'title': '거북선공원 야간 러닝',
                      'date': '이번 주 금요일 20:00',
                      'location': '여수시 학동 거북선공원',
                    },
                    isMe: false,
                    chatRoomId: 'room_1',
                  ),
                  InteractiveProfileExchangeCard(
                    msg: {
                      'sender': '여수러닝호스트',
                      'title': '프로필 교환 요청',
                    },
                    isMe: false,
                    chatRoomId: 'room_1',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final avatars = tester.widgetList<OomuAvatar>(find.byType(OomuAvatar)).toList();
      expect(avatars.length, 2);
      expect(avatars.every((a) => a.name == '여수러닝호스트'), isTrue);
      expect(find.textContaining('민지'), findsNothing);
      expect(find.textContaining('우리동네민우'), findsNothing);
    });

    test('3-6. DiscoveryApiService.fetchWeatherAndRecipes handles partial API failure gracefully', () async {
      final mockClient = MockClient((request) async {
        if (request.url.host.contains('air-quality-api')) {
          return http.Response('Internal Server Error', 500);
        }
        return http.Response(
          jsonEncode({
            'current': {
              'temperature_2m': 21.4,
              'weather_code': 0,
            },
          }),
          200,
        );
      });

      final weather = await DiscoveryApiService.instance.fetchWeatherAndRecipes(
        '여수시 화장동',
        client: mockClient,
      );

      expect(weather.hasWeather, isTrue);
      expect(weather.tempC, closeTo(21.4, 0.1));
      expect(weather.airQualityLabel, '확인불가');
    });

    testWidgets('3-5. UserProfileScreen blocks by UID and displays blocked state', (tester) async {
      globalData.blockUid('blocked_uid_999');
      expect(globalData.isUidBlocked('blocked_uid_999'), isTrue);

      await tester.pumpWidget(
        const MaterialApp(
          home: UserProfileScreen(
            userId: 'blocked_uid_999',
            userName: '차단대상유저',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('차단된 사용자의 프로필입니다.'), findsOneWidget);
    });

    testWidgets('3-7 & 4-1. OOMUHomeScreen and OomuDiscoveryLifestyleHub contain 0 hardcoded fake community posts or discounts', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OOMUHomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Community tab (커뮤니티)
      await tester.tap(find.text('커뮤니티').last);
      await tester.pumpAndSettle();

      // Verify empty state is shown instead of 18 dummy posts
      expect(find.text('등록된 동네 이야기가 없어요'), findsOneWidget);
      expect(find.textContaining('선소대교 야간 러닝 같이 하실 분'), findsNothing);

      // Verify OomuDiscoveryLifestyleHub shows honest empty state for discounts when none exist
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OomuDiscoveryLifestyleHub(
                currentLocation: '여수시 화장동',
                initialCategoryIndex: 2, // 할인·이벤트
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('등록된 정보가 아직 없어요'), findsOneWidget);
      expect(find.textContaining('전 메뉴 20% 타임할인'), findsNothing);
    });

    testWidgets('4-1. MyPageScreen removes redundant 성향 및 라이프스타일 row (only in ProfileEdit & Preview)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MyPageScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 마이페이지 메인 본문에서는 중복 태그 제거됨 (Comment 18 반영)
      expect(find.text('성향 및 라이프스타일'), findsNothing);
      expect(find.byTooltip('성향 및 라이프스타일 수정'), findsNothing);
    });
  });
}
