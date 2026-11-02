import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:spot10_app/screens/community_post_detail_screen.dart';
import 'package:spot10_app/screens/my_page_screen.dart';
import 'package:spot10_app/screens/profile_edit_screen.dart';
import 'package:spot10_app/screens/soso_car_detail_screen.dart';
import 'package:spot10_app/screens/soso_car_home_screen.dart';
import 'package:spot10_app/screens/user_profile_screen.dart';
import 'package:spot10_app/services/auth_service.dart';
import 'package:spot10_app/services/kakao_map_service.dart';
import 'package:spot10_app/utils/global_data.dart';
import 'package:spot10_app/utils/oomu_ui_helpers.dart';

void main() {
  const emojiTestCases = <String>[
    '카탄 한판 🎲',
    '커피 ☕🥯',
    '한강 러닝 🏃♀️',
    '함께해요 👩🏽🤝👩🏻',
    '가족 👨👩👧👦',
    '대한민국 🇰🇷',
  ];

  group('[2] 제목 이모지 깨짐 방지 검증', () {
    test('OomuUiHelpers.formatTitle이 서로게이트 페어·ZWJ·국기 이모지를 쪼개지 않는다', () {
      for (final raw in emojiTestCases) {
        final formatted = OomuUiHelpers.formatTitle(raw);
        expect(formatted, equals(raw));
        expect(formatted.contains('\u2060'), isFalse);
        expect(formatted.contains('\uFFFD'), isFalse);
        expect(formatted.runes.toList(), equals(raw.runes.toList()));
      }
    });

    testWidgets('상세·커뮤니티 화면에서 6종 복합 이모지 제목이 깨짐 없이 렌더링된다', (tester) async {
      await mockNetworkImagesFor(() async {
        for (final emojiTitle in emojiTestCases) {
          await tester.pumpWidget(
            MaterialApp(
              theme: OomuUiHelpers.buildTheme(),
              home: OOMUDetailScreen(
                meetup: {
                  'title': emojiTitle,
                  'category': '보드게임/방탈출',
                  'host': '성수동힙스터',
                  'manner': 41.2,
                  'location': '성수역 3번 출구 레드버튼',
                  'lat': 37.5445,
                  'lng': 127.0560,
                  'imageUrl': 'https://example.invalid/sample.png',
                },
              ),
            ),
          );
          await tester.pump();
          expect(find.text(emojiTitle), findsWidgets);
          expect(find.textContaining('\uFFFD'), findsNothing);
          expect(tester.takeException(), isNull);

          await tester.pumpWidget(
            MaterialApp(
              theme: OomuUiHelpers.buildTheme(),
              home: CommunityPostDetailScreen(
                post: {
                  'id': 'emoji_test_post',
                  'category': '동네질문',
                  'title': emojiTitle,
                  'content': '본문 이모지 테스트 $emojiTitle',
                  'author': '민서 (연남동)',
                  'time': '방금 전',
                  'likes': 1,
                  'comments': 0,
                  'commentList': const <Map<String, dynamic>>[],
                },
              ),
            ),
          );
          await tester.pump();
          expect(find.text(emojiTitle), findsOneWidget);
          expect(find.textContaining('\uFFFD'), findsNothing);
          expect(tester.takeException(), isNull);
        }
      });
    });
  });

  group('[3] 장소·지도·거리 불일치 수정 검증', () {
    test('KakaoMapService.resolveVerifiedPlace는 검증된 장소만 좌표를 반환하고 미확인 장소는 null을 반환한다', () async {
      final seongsu = await KakaoMapService.resolveVerifiedPlace('성수역 3번 출구 레드버튼');
      expect(seongsu, isNotNull);
      expect(seongsu!.lat, closeTo(37.5445, 0.01));
      expect(seongsu.lng, closeTo(127.0560, 0.01));

      final unknown = await KakaoMapService.resolveVerifiedPlace('알수없는비밀장소XYZ_999');
      expect(unknown, isNull);
    });

    testWidgets('미확인 장소 모임 상세는 가짜 홍대 지도/도보 5분 대신 위치 미확인 안내와 거리 확인 불가를 표시한다', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: OomuUiHelpers.buildTheme(),
            home: const OOMUDetailScreen(
              meetup: {
                'title': '미확인 장소 테스트 모임',
                'category': '카페/수다',
                'host': '테스트호스트',
                'location': '알수없는비밀장소XYZ_999',
                'imageUrl': 'https://example.invalid/sample.png',
              },
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('정확한 위치를 확인할 수 없어요'), findsOneWidget);
        expect(find.textContaining('거리 확인 불가'), findsOneWidget);
        expect(find.textContaining('내 위치에서 도보 5분'), findsNothing);
        expect(tester.takeException(), isNull);
      });
    });
  });

  group('[4] 호스트 매너온도 단일화 검증', () {
    test('OomuUiHelpers.parseMannerTemp는 manner/mannerTemp의 num·String·null을 일관되게 처리한다', () {
      expect(OomuUiHelpers.parseMannerTemp({'manner': 41.2}), closeTo(41.2, 0.001));
      expect(OomuUiHelpers.parseMannerTemp({'mannerTemp': '39.4'}), closeTo(39.4, 0.001));
      expect(OomuUiHelpers.parseMannerTemp({'manner': 'invalid'}), isNull);
      expect(OomuUiHelpers.parseMannerTemp(<String, dynamic>{}), isNull);
      expect(OomuUiHelpers.formatMannerTemp(null), equals('정보 없음'));
      expect(OomuUiHelpers.formatMannerTemp(null, shortEmpty: false), equals('매너온도 정보 없음'));
    });

    testWidgets('상세 호스트 카드와 프로필 화면이 동일한 매너온도(41.2°C 및 정보 없음)를 표시한다', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: OomuUiHelpers.buildTheme(),
            home: const OOMUDetailScreen(
              meetup: {
                'title': '매너온도 41.2 검증 모임',
                'category': '보드게임/방탈출',
                'host': '성수동힙스터',
                'manner': 41.2,
                'location': '성수역 3번 출구',
                'lat': 37.5445,
                'lng': 127.0560,
                'imageUrl': 'https://example.invalid/sample.png',
              },
            ),
          ),
        );
        await tester.pump();
        expect(find.text('41.2°C'), findsOneWidget);
        expect(find.text('36.5°C'), findsNothing);

        await tester.pumpWidget(
          MaterialApp(
            theme: OomuUiHelpers.buildTheme(),
            home: const OOMUDetailScreen(
              meetup: {
                'title': '매너온도 미입력 검증 모임',
                'category': '보드게임/방탈출',
                'host': '신규호스트',
                'location': '성수역 3번 출구',
                'lat': 37.5445,
                'lng': 127.0560,
                'imageUrl': 'https://example.invalid/sample.png',
              },
            ),
          ),
        );
        await tester.pump();
        expect(find.text('매너온도 정보 없음'), findsOneWidget);
        expect(find.text('36.5°C'), findsNothing);

        await tester.pumpWidget(
          MaterialApp(
            theme: OomuUiHelpers.buildTheme(),
            home: const UserProfileScreen(
              userName: '신규호스트',
              userLocation: '성동구 성수동',
              userManner: null,
            ),
          ),
        );
        await tester.pump();
        expect(find.text('매너온도 정보 없음'), findsOneWidget);
      });
    });
  });

  group('[5] 커뮤니티 댓글 내용·개수·저장 상태 분리 검증', () {
    testWidgets('서로 다른 게시글 A/B가 댓글을 공유하지 않고, 빈 댓글 게시글은 첫 댓글 안내만 표시한다', (tester) async {
      await mockNetworkImagesFor(() async {
        final postA = <String, dynamic>{
          'id': 'post_minseo_01',
          'category': '맛집/카페',
          'title': '연남동 평일 저녁에 조용히 책 읽기 좋은 카페 있을까요?',
          'content': '퇴근하고 1~2시간 정도 노트북이나 책 볼 만한 아늑한 개인 카페 추천 부탁드려요!',
          'author': '민서 (연남동)',
          'time': '12분 전',
          'likes': 5,
          'comments': 2,
          'commentList': <Map<String, dynamic>>[
            {
              'id': 'c_minseo_1',
              'author': '연희동책방지기',
              'avatar': 'https://example.invalid/a1.png',
              'content': '연남동 끝자락 조용해요!',
              'time': '8분 전',
              'likes': 2,
              'isLiked': false,
            },
            {
              'id': 'c_minseo_2',
              'author': '홍대산책러',
              'avatar': 'https://example.invalid/a2.png',
              'content': '경의선숲길 골목 안쪽 카페 추천합니다.',
              'time': '4분 전',
              'likes': 1,
              'isLiked': false,
            },
          ],
        };

        final postB = <String, dynamic>{
          'id': 'post_junho_02',
          'category': '취미/운동',
          'title': '이번 주 토요일 오전 망원한강공원 러닝 크루 구해요 🏃‍♀️',
          'content': '5km 천천히 630 페이스로 뛰고 망원시장에서 간단한 브런치 먹으려고 합니다.',
          'author': '준호 (망원동)',
          'time': '45분 전',
          'likes': 14,
          'comments': 0,
          'commentList': <Map<String, dynamic>>[],
        };

        // 1. 게시글 B (댓글 0개): 상단 통계('댓글 0')와 댓글 헤더('댓글 0')가 모두 일치하고 첫 댓글 안내만 표시
        await tester.pumpWidget(
          MaterialApp(
            theme: OomuUiHelpers.buildTheme(),
            home: CommunityPostDetailScreen(post: postB),
          ),
        );
        await tester.pump();

        expect(find.text('댓글 0'), findsNWidgets(2));
        expect(find.text('첫 댓글을 남겨보세요'), findsOneWidget);
        expect(find.textContaining('프랑켄슈타인'), findsNothing);
        expect(find.textContaining('도솔산성'), findsNothing);

        // 2. 게시글 B에 새 댓글 작성 시 상단/헤더/목록 수가 모두 1로 일치하고 postA에는 영향 없음
        await tester.enterText(find.byType(TextField), '저도 토요일 러닝 참여하고 싶어요!');
        await tester.tap(find.byTooltip('댓글 전송'));
        await tester.pumpAndSettle();

        expect(find.text('댓글 1'), findsNWidgets(2));
        expect(find.text('저도 토요일 러닝 참여하고 싶어요!'), findsOneWidget);
        expect(postA['comments'], equals(2));

        // 3. 게시글 A 렌더링 시 본래 2개 댓글만 표시
        await tester.pumpWidget(
          MaterialApp(
            theme: OomuUiHelpers.buildTheme(),
            home: CommunityPostDetailScreen(post: postA),
          ),
        );
        await tester.pump();

        expect(find.text('댓글 2'), findsNWidgets(2));
        expect(find.text('연남동 끝자락 조용해요!'), findsOneWidget);
        expect(find.text('저도 토요일 러닝 참여하고 싶어요!'), findsNothing);
      });
    });
  });

  group('[6] MY 프로필 보기/수정 분리 및 터치 타깃 48dp 검증', () {
    testWidgets('MY 화면의 내 프로필 보기와 프로필 수정이 각각 다른 화면으로 이동하고 터치 영역이 48dp 이상이다', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: OomuUiHelpers.buildTheme(),
            home: const MyPageScreen(),
          ),
        );
        await tester.pump();

        final viewBtnFinder = find.byTooltip('내 프로필 보기');
        final editBtnFinder = find.byTooltip('내 프로필 수정');
        final tagEditFinder = find.byTooltip('성향 및 라이프스타일 수정');

        expect(viewBtnFinder, findsOneWidget);
        expect(editBtnFinder, findsOneWidget);
        expect(tester.getSize(viewBtnFinder).height, greaterThanOrEqualTo(48.0));
        expect(tester.getSize(editBtnFinder).height, greaterThanOrEqualTo(48.0));

        await tester.scrollUntilVisible(
          tagEditFinder,
          200.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(tagEditFinder, findsOneWidget);
        expect(tester.getSize(tagEditFinder).width, greaterThanOrEqualTo(48.0));
        expect(tester.getSize(tagEditFinder).height, greaterThanOrEqualTo(48.0));

        await tester.scrollUntilVisible(
          viewBtnFinder,
          -200.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        await tester.tap(viewBtnFinder);
        await tester.pumpAndSettle();
        expect(find.byType(UserProfileScreen), findsOneWidget);

        Navigator.of(tester.element(find.byType(UserProfileScreen))).pop();
        await tester.pumpAndSettle();

        await tester.tap(editBtnFinder);
        await tester.pumpAndSettle();
        expect(find.byType(ProfileEditScreen), findsOneWidget);
      });
    });

    testWidgets('모임 상세·커뮤니티 주요 조작 버튼이 모두 최소 48x48dp를 충족한다', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: OomuUiHelpers.buildTheme(),
            home: const OOMUDetailScreen(
              meetup: {
                'title': '터치 타깃 검증 모임',
                'category': '보드게임/방탈출',
                'host': '성수동힙스터',
                'manner': 41.2,
                'location': '성수역 3번 출구',
                'lat': 37.5445,
                'lng': 127.0560,
                'praiseTags': <String>[],
                'imageUrl': 'https://example.invalid/sample.png',
              },
            ),
          ),
        );
        await tester.pump();

        // 데이터에 praiseTags가 비어있으면 하드코딩 칭찬 태그가 노출되지 않음
        expect(find.text('⏰ 시간 약속을 잘 지켜요'), findsNothing);
        expect(find.text('호스트'), findsWidgets);

        final applyBtn = find.widgetWithText(ElevatedButton, '참여 신청하기');
        expect(tester.getSize(applyBtn).height, greaterThanOrEqualTo(48.0));

        await tester.pumpWidget(
          MaterialApp(
            theme: OomuUiHelpers.buildTheme(),
            home: const CommunityPostDetailScreen(
              post: {
                'id': 'touch_test_post',
                'category': '맛집/카페',
                'title': '터치 영역 테스트 게시글',
                'content': '본문입니다.',
                'author': '민서 (연남동)',
                'time': '12분 전',
                'likes': 5,
                'comments': 1,
                'commentList': <Map<String, dynamic>>[
                  {
                    'id': 'c1',
                    'author': '연희동책방지기',
                    'avatar': 'https://example.invalid/a1.png',
                    'content': '댓글입니다.',
                    'time': '8분 전',
                    'likes': 2,
                    'isLiked': false,
                  },
                ],
              },
            ),
          ),
        );
        await tester.pump();

        final postLikeSize = tester.getSize(find.byTooltip('게시글 좋아요'));
        final commentLikeSize = tester.getSize(find.byTooltip('댓글 좋아요'));
        final sendBtnSize = tester.getSize(find.byTooltip('댓글 전송'));

        expect(postLikeSize.width, greaterThanOrEqualTo(48.0));
        expect(postLikeSize.height, greaterThanOrEqualTo(48.0));
        expect(commentLikeSize.width, greaterThanOrEqualTo(48.0));
        expect(commentLikeSize.height, greaterThanOrEqualTo(48.0));
        expect(sendBtnSize.width, greaterThanOrEqualTo(48.0));
        expect(sendBtnSize.height, greaterThanOrEqualTo(48.0));
      });
    });
  });

  group('[8] 화면 크기(360/390/430) 및 글자 확대(1.0/1.3/2.0) 오버플로우 0건 검증', () {
    const viewports = <Size>[
      Size(360, 800),
      Size(390, 844),
      Size(430, 932),
    ];
    const scales = <double>[1.0, 1.3, 2.0];

    testWidgets('4대 핵심 화면이 360/390/430px 및 글자 크기 1.0/1.3/2.0에서 RenderFlex overflow 없이 렌더링된다', (tester) async {
      await mockNetworkImagesFor(() async {
        for (final size in viewports) {
          for (final scale in scales) {
            Widget wrapWithViewport(Widget child) {
              return MediaQuery(
                data: MediaQueryData(
                  size: size,
                  textScaler: TextScaler.linear(scale),
                ),
                child: MaterialApp(
                  theme: OomuUiHelpers.buildTheme(),
                  home: child,
                ),
              );
            }

            await tester.binding.setSurfaceSize(size);

            // 1. 모임 상세
            await tester.pumpWidget(
              wrapWithViewport(
                const OOMUDetailScreen(
                  meetup: {
                    'title': '성수동 전략 보드게임 카탄 & 스플렌더 한 판 하실 분 🎲',
                    'category': '보드게임/방탈출',
                    'host': '성수동힙스터긴닉네임테스트용',
                    'manner': 41.2,
                    'location': '성수역 3번 출구 도보 3분 보드게임카페 레드버튼',
                    'lat': 37.5445,
                    'lng': 127.0560,
                    'cost': '음료 각자 결제',
                    'imageUrl': 'https://example.invalid/sample.png',
                  },
                ),
              ),
            );
            await tester.pump();
            final err1 = tester.takeException(); if (err1 != null) fail('Detail overflow at $size scale $scale:\n${(err1 as dynamic).toStringDeep()}');

            // 2. 홈 화면
            await tester.pumpWidget(wrapWithViewport(const OOMUHomeScreen()));
            await tester.pump();
            final err2 = tester.takeException(); if (err2 != null) fail('Home overflow at $size scale $scale:\n${(err2 as dynamic).toStringDeep()}');

            // 3. MY 화면
            await tester.pumpWidget(wrapWithViewport(const MyPageScreen()));
            await tester.pump();
            final err3 = tester.takeException(); if (err3 != null) fail('MY overflow at $size scale $scale:\n${(err3 as dynamic).toStringDeep()}');

            // 4. 커뮤니티 상세
            await tester.pumpWidget(
              wrapWithViewport(
                const CommunityPostDetailScreen(
                  post: {
                    'id': 'scale_test_post',
                    'category': '맛집/카페',
                    'title': '연남동 평일 저녁에 조용히 책 읽기 좋은 카페 있을까요? ☕🥯',
                    'content': '퇴근하고 1~2시간 정도 노트북이나 책 볼 만한 아늑한 개인 카페 추천 부탁드려요!',
                    'author': '민서긴닉네임테스트 (마포구 연남동)',
                    'time': '12분 전',
                    'likes': 5,
                    'comments': 0,
                    'commentList': <Map<String, dynamic>>[],
                  },
                ),
              ),
            );
            await tester.pump();
            final err4 = tester.takeException(); if (err4 != null) fail('Community overflow at $size scale $scale:\n${(err4 as dynamic).toStringDeep()}');
          }
        }
        await tester.binding.setSurfaceSize(null);
      });
    });
  });

  group('[9] 긴 제목·이모지·글자 확대에서 원문 데이터 보존 및 실제 표시 검증', () {
    testWidgets('긴 이모지 제목이 글자 확대(1.0/1.3/2.0) 시 원문 데이터를 변형하지 않고 표시된다', (tester) async {
      await mockNetworkImagesFor(() async {
        const longEmojiTitles = <String>[
          '주말 여수 화장동 수제 소금빵 & 감성 베이커리 카페 오픈런 🥐',
          '화장동 성산공원 호수 둘레길 저녁 5km 런닝 크루 🏃‍♀️',
          '🍷 불금 여수 웅천 오션뷰 2:2 와인 & 타파스 미팅 (20대 중후반)',
        ];
        for (final originalTitle in longEmojiTitles) {
          final mapData = <String, dynamic>{
            'title': originalTitle,
            'category': '카페/디저트',
            'host': '여수빵순이',
            'manner': 42.5,
            'location': '전남 여수시 화장동 선소상가 카페거리',
            'lat': 34.7604,
            'lng': 127.6622,
            'imageUrl': 'https://example.invalid/sample.png',
          };

          for (final scale in const <double>[1.0, 1.3, 2.0]) {
            await tester.binding.setSurfaceSize(const Size(360, 800));
            await tester.pumpWidget(
              MediaQuery(
                data: MediaQueryData(
                  size: const Size(360, 800),
                  textScaler: TextScaler.linear(scale),
                ),
                child: MaterialApp(
                  theme: OomuUiHelpers.buildTheme(),
                  home: OOMUDetailScreen(meetup: mapData),
                ),
              ),
            );
            await tester.pump();

            // 원문 Map 데이터와 화면 표시 문자열 모두 제어문자(\u2060, \u00A0) 삽입 없이 보존됨
            expect(mapData['title'], equals(originalTitle));
            expect(OomuUiHelpers.formatTitle(originalTitle), equals(originalTitle));
            expect(find.text(originalTitle), findsWidgets);
            expect(find.textContaining('\uFFFD'), findsNothing);
            expect(tester.takeException(), isNull);
          }
        }
        await tester.binding.setSurfaceSize(null);
      });
    });
  });

  group('[10] 계정 전환 시 사용자별 상태 초기화 및 AuthService 지연 응답 차단 검증', () {
    test('계정 A의 찜·차단·숨김·신고·리뷰·온도·프로필 등 모든 사용자별 상태가 B 전환·게스트 전환·로그아웃 시 잔류하지 않고 미설정 상태로 초기화된다', () async {
      final completerB = Completer<Map<String, dynamic>?>();
      globalData.debugProfileFetcher = (uid) {
        if (uid == 'user_B') return completerB.future;
        return Future.value(null);
      };

      try {
        // 1. 계정 A 상태 및 앱 공통 알림 설정 채우기
        globalData.switchUser('user_A', triggerFirestoreSync: false);
        globalData.userNickname.value = '부산유저A';
        globalData.userLocation.value = '부산 해운대구 우동';
        globalData.userAvatar.value = 'assets/images/kr_male_1.jpg';
        globalData.temperature.value = 44.2;
        globalData.rating.value = 4.9;
        globalData.reviewCount.value = 15;
        globalData.recentReviews.value = [
          {'rating': 5.0, 'text': '좋았어요', 'time': '방금 전'}
        ];
        globalData.savedMeetups.value = [
          {'id': 'meetup_A_1', 'title': 'A가 찜한 해운대 러닝 모임'}
        ];
        globalData.blockedUsers.value = ['차단유저A'];
        globalData.hiddenPostIds.value = ['post_hidden_A'];
        globalData.reportHistory.value = [
          {'id': 'rep_A_1', 'targetUser': '차단유저A'}
        ];
        globalData.notificationSettings.value = {
          ...globalData.notificationSettings.value,
          'marketing': true,
        };

        expect(globalData.isFavorite('meetup_A_1'), isTrue);
        expect(globalData.isUserBlocked('차단유저A'), isTrue);

        // 2. 계정 A -> B 전환 (프로필 응답 도착 전 대기 상태)
        globalData.switchUser('user_B');

        // A의 사용자별 상태가 하나도 남지 않고, 특정 인물('매운맛킬러' 등)로 채워지지 않은 미설정 상태여야 함
        expect(globalData.currentUserId.value, equals('user_B'));
        expect(globalData.userNickname.value, isEmpty);
        expect(globalData.userLocation.value, isEmpty);
        expect(globalData.userAvatar.value, isEmpty);
        expect(globalData.temperature.value, equals(0.0));
        expect(globalData.rating.value, equals(0.0));
        expect(globalData.reviewCount.value, equals(0));
        expect(globalData.recentReviews.value, isEmpty);
        expect(globalData.savedMeetups.value, isEmpty);
        expect(globalData.isFavorite('meetup_A_1'), isFalse);
        expect(globalData.blockedUsers.value, isEmpty);
        expect(globalData.isUserBlocked('차단유저A'), isFalse);
        expect(globalData.hiddenPostIds.value, isEmpty);
        expect(globalData.reportHistory.value, isEmpty);
        // 앱 공통 알림 설정은 유지됨
        expect(globalData.notificationSettings.value['marketing'], isTrue);

        // 3. B 프로필 응답 도착 (일부 필드만 있는 경우 없는 필드는 미설정 유지)
        completerB.complete({
          'location': '여수시 화장동',
          'nickname': '여수이웃B',
        });
        await Future<void>.delayed(Duration.zero);
        expect(globalData.userLocation.value, equals('여수시 화장동'));
        expect(globalData.userNickname.value, equals('여수이웃B'));
        expect(globalData.userAvatar.value, isEmpty);
        expect(globalData.temperature.value, equals(0.0));
        expect(globalData.savedMeetups.value, isEmpty);

        // 4. B에서 찜 추가 후 게스트 전환 시 B의 상태가 남지 않아야 함
        globalData.toggleFavorite({'id': 'meetup_B_1', 'title': 'B가 찜한 여수 모임'});
        expect(globalData.isFavorite('meetup_B_1'), isTrue);

        await authService.signInAsGuest();
        expect(globalData.currentUserId.value, equals('guest'));
        expect(globalData.userNickname.value, isEmpty);
        expect(globalData.userLocation.value, isEmpty);
        expect(globalData.userAvatar.value, isEmpty);
        expect(globalData.savedMeetups.value, isEmpty);
        expect(globalData.isFavorite('meetup_B_1'), isFalse);

        // 5. 게스트에서 찜 추가 후 로그아웃 시 모든 사용자별 상태가 초기화되어야 함
        globalData.toggleFavorite({'id': 'meetup_guest_1', 'title': '게스트 찜 모임'});
        await authService.signOut();
        expect(globalData.currentUserId.value, isEmpty);
        expect(globalData.savedMeetups.value, isEmpty);
        expect(globalData.notificationSettings.value['marketing'], isTrue);
      } finally {
        globalData.debugProfileFetcher = null;
        globalData.resetSession();
      }
    });

    test('① A 요청 대기 -> B 로그인 -> A 응답 도착 시 이전 A 응답이 B 세션을 덮어쓰지 못한다', () async {
      final completerA = Completer<Map<String, dynamic>?>();
      final completerB = Completer<Map<String, dynamic>?>();
      String? currentAuthUid = 'user_A';

      authService.debugCurrentUidGetter = () => currentAuthUid;
      authService.debugUserDocFetcher = (uid) {
        if (uid == 'user_A') return completerA.future;
        if (uid == 'user_B') return completerB.future;
        return Future.value(null);
      };

      try {
        // 1. A 로그인 요청 시작 (응답 대기 중)
        final futureA = authService.syncUserSessionProfile('user_A');
        expect(globalData.currentUserId.value, equals('user_A'));

        // 2. A 응답 도착 전 B 로그인 및 B 응답 먼저 도착
        currentAuthUid = 'user_B';
        final futureB = authService.syncUserSessionProfile('user_B');
        completerB.complete({
          'location': '여수시 화장동',
          'nickname': '여수이웃B',
          'photoUrl': 'assets/images/kr_female_2.jpg',
          'mannerTemp': 40.5,
        });
        await futureB;

        expect(globalData.currentUserId.value, equals('user_B'));
        expect(globalData.userLocation.value, equals('여수시 화장동'));
        expect(globalData.userNickname.value, equals('여수이웃B'));

        // 3. 뒤늦게 A 응답 도착 -> B 상태를 덮어쓰지 않아야 함
        completerA.complete({
          'location': '부산 해운대구 우동',
          'nickname': '해운대유저A',
          'photoUrl': 'assets/images/kr_male_1.jpg',
          'mannerTemp': 38.0,
        });
        await futureA;

        expect(globalData.currentUserId.value, equals('user_B'));
        expect(globalData.userLocation.value, equals('여수시 화장동'));
        expect(globalData.userNickname.value, equals('여수이웃B'));
        expect(globalData.userAvatar.value, equals('assets/images/kr_female_2.jpg'));
        expect(globalData.temperature.value, closeTo(40.5, 0.001));
      } finally {
        authService.debugCurrentUidGetter = null;
        authService.debugUserDocFetcher = null;
        globalData.resetSession();
      }
    });

    test('② A 요청 대기 -> 로그아웃 -> A 응답 도착 시(UID가 null일 때) 이전 A 응답이 통과하지 못한다', () async {
      final completerSyncA = Completer<Map<String, dynamic>?>();
      final completerCompleteCheckA = Completer<Map<String, dynamic>?>();
      String? currentAuthUid = 'user_A';
      int callCount = 0;

      authService.debugCurrentUidGetter = () => currentAuthUid;
      authService.debugUserDocFetcher = (uid) {
        callCount++;
        if (callCount == 1) return completerSyncA.future;
        return completerCompleteCheckA.future;
      };

      try {
        // 1. A 프로필 동기화 및 완료 검사 요청 시작 (응답 대기 중)
        final syncFuture = authService.syncUserSessionProfile('user_A');
        final completeFuture = authService.isUserProfileComplete('user_A');

        // 2. 응답이 오기 전에 로그아웃 (currentAuthUid = null)
        currentAuthUid = null;
        await authService.signOut();
        expect(globalData.currentUserId.value, isEmpty);
        expect(globalData.userNickname.value, isEmpty);
        expect(globalData.userLocation.value, isEmpty);

        // 3. 로그아웃 상태에서 뒤늦게 A 응답들이 도착 -> 차단되어 미설정 상태 유지
        completerSyncA.complete({
          'location': '부산 해운대구 우동',
          'nickname': '해운대유저A',
          'photoUrl': 'assets/images/kr_male_1.jpg',
        });
        completerCompleteCheckA.complete({
          'location': '부산 해운대구 우동',
          'nickname': '해운대유저A',
          'photoUrl': 'assets/images/kr_male_1.jpg',
          'isProfileComplete': true,
        });

        await syncFuture;
        final isCompleteResult = await completeFuture;

        expect(isCompleteResult, isFalse);
        expect(globalData.currentUserId.value, isEmpty);
        expect(globalData.userLocation.value, isEmpty);
        expect(globalData.userNickname.value, isEmpty);
        expect(globalData.userAvatar.value, isEmpty);
      } finally {
        authService.debugCurrentUidGetter = null;
        authService.debugUserDocFetcher = null;
        globalData.resetSession();
      }
    });

    test('③ A 요청 대기 -> 로그아웃 -> A 재로그인 -> 이전 A 응답 도착 시 이전 세션 응답이 새 A 세션을 덮어쓰지 못한다', () async {
      final completerOldSessionA = Completer<Map<String, dynamic>?>();
      final completerNewSessionA = Completer<Map<String, dynamic>?>();
      String? currentAuthUid = 'user_A';
      int requestOrder = 0;

      authService.debugCurrentUidGetter = () => currentAuthUid;
      authService.debugUserDocFetcher = (uid) {
        requestOrder++;
        if (requestOrder == 1) return completerOldSessionA.future;
        return completerNewSessionA.future;
      };

      try {
        // 1. 첫 번째 A 세션 요청 시작 (응답 지연)
        final oldSessionFuture = authService.syncUserSessionProfile('user_A');

        // 2. 로그아웃
        currentAuthUid = null;
        await authService.signOut();
        expect(globalData.currentUserId.value, isEmpty);

        // 3. 동일 계정(user_A)으로 재로그인 및 새 세션 응답 도착
        currentAuthUid = 'user_A';
        final newSessionFuture = authService.syncUserSessionProfile('user_A');
        completerNewSessionA.complete({
          'location': '여수시 학동',
          'nickname': '새세션유저A',
          'photoUrl': 'assets/images/kr_female_3.jpg',
          'mannerTemp': 43.0,
        });
        await newSessionFuture;

        expect(globalData.currentUserId.value, equals('user_A'));
        expect(globalData.userLocation.value, equals('여수시 학동'));
        expect(globalData.userNickname.value, equals('새세션유저A'));
        expect(globalData.temperature.value, closeTo(43.0, 0.001));

        // 4. 로그아웃 이전 세션(첫 번째 A 세션)의 지연 응답이 뒤늦게 도착 -> UID가 같아도 세션 세대가 다르므로 차단됨
        completerOldSessionA.complete({
          'location': '구세션과거동네',
          'nickname': '구세션과거닉네임',
          'photoUrl': 'assets/images/kr_male_1.jpg',
          'mannerTemp': 36.5,
        });
        await oldSessionFuture;

        expect(globalData.currentUserId.value, equals('user_A'));
        expect(globalData.userLocation.value, equals('여수시 학동'));
        expect(globalData.userNickname.value, equals('새세션유저A'));
        expect(globalData.userAvatar.value, equals('assets/images/kr_female_3.jpg'));
        expect(globalData.temperature.value, closeTo(43.0, 0.001));
      } finally {
        authService.debugCurrentUidGetter = null;
        authService.debugUserDocFetcher = null;
        globalData.resetSession();
      }
    });

    testWidgets('미설정 상태에서 MY 화면이 특정 인물(매운맛킬러 등) 대신 미설정 안내(닉네임 미설정·동네 미설정·정보 없음)를 표시한다', (tester) async {
      await mockNetworkImagesFor(() async {
        globalData.resetSession();
        await tester.pumpWidget(
          MaterialApp(
            theme: OomuUiHelpers.buildTheme(),
            home: const MyPageScreen(),
          ),
        );
        await tester.pump();

        expect(find.text('닉네임 미설정'), findsOneWidget);
        expect(find.text('동네 미설정'), findsOneWidget);
        expect(find.text('정보 없음'), findsOneWidget);
        expect(find.text('매운맛킬러'), findsNothing);
        expect(find.text('37.5°C'), findsNothing);
        expect(find.text('41.2°C'), findsNothing);
        expect(tester.takeException(), isNull);
      });
    });
  });
}
