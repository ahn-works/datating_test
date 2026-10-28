import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:spot10_app/screens/community_post_detail_screen.dart';
import 'package:spot10_app/screens/my_page_screen.dart';
import 'package:spot10_app/screens/profile_edit_screen.dart';
import 'package:spot10_app/screens/soso_car_detail_screen.dart';
import 'package:spot10_app/screens/soso_car_home_screen.dart';
import 'package:spot10_app/screens/user_profile_screen.dart';
import 'package:spot10_app/services/kakao_map_service.dart';
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
}
