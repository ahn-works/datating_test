import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot10_app/ui/ui.dart';

void main() {
  group('🎨 OOMU 공통 컴포넌트 48dp 최소 터치 영역 테스트', () {
    testWidgets('OomuButton이 48dp 이상의 터치 크기를 만족한다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildOomuTheme(),
          home: Scaffold(
            body: Column(
              children: [
                OomuButton(
                  label: 'Primary',
                  onPressed: () {},
                  fullWidth: false,
                ),
                OomuButton.secondary(
                  label: 'Secondary',
                  onPressed: () {},
                  fullWidth: false,
                ),
                OomuButton.text(
                  label: 'Text',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      final buttonFinders = find.byType(OomuButton);
      expect(buttonFinders, findsNWidgets(3));

      for (int i = 0; i < 3; i++) {
        final size = tester.getSize(buttonFinders.at(i));
        expect(size.width, greaterThanOrEqualTo(48.0));
        expect(size.height, greaterThanOrEqualTo(48.0));
      }
    });

    testWidgets('OomuChip이 시각적 36dp 높이이면서 48dp 터치 타깃을 만족한다', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildOomuTheme(),
          home: Scaffold(
            body: Center(
              child: OomuChip(
                label: '오늘 번개',
                isSelected: false,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      final chipFinder = find.byType(OomuChip);
      expect(chipFinder, findsOneWidget);

      final size = tester.getSize(chipFinder);
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));

      await tester.tap(chipFinder);
      expect(tapped, isTrue);
    });
  });

  group('📐 360px 좁은 폭 및 글자 1.0 / 1.3 / 2.0배 오버플로우 전수 검증', () {
    for (final scale in [1.0, 1.3, 2.0]) {
      testWidgets('OomuComponentGallery 360px 폭 textScale=$scale 에서 오버플로우 없음',
          (tester) async {
        tester.view.physicalSize = Size(360 * tester.view.devicePixelRatio, 1200 * tester.view.devicePixelRatio);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            theme: buildOomuTheme(),
            home: MediaQuery(
              data: const MediaQueryData().copyWith(
                size: const Size(360, 1200),
                textScaler: TextScaler.linear(scale),
              ),
              child: const OomuComponentGallery(),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
        expect(find.text('OOMU UI 컴포넌트 갤러리'), findsOneWidget);
      });

      testWidgets('OomuMeetupCard (Block/List) 360px 폭 textScale=$scale 에서 오버플로우 없음',
          (tester) async {
        tester.view.physicalSize = Size(360 * tester.view.devicePixelRatio, 800 * tester.view.devicePixelRatio);
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            theme: buildOomuTheme(),
            home: Scaffold(
              body: MediaQuery(
                data: const MediaQueryData().copyWith(
                  size: const Size(360, 800),
                  textScaler: TextScaler.linear(scale),
                ),
                child: ListView(
                  children: const [
                    OomuMeetupCard(
                      title: '매우 긴 제목의 동네 소셜 다이닝 모임 테스트 두 줄 말줄임 확인용 텍스트입니다',
                      date: '오늘 저녁 7시 30분 긴 일정 표기',
                      location: '전남 여수시 화장동 무선지구 상가 맛집골목 2층',
                      hostName: '아주긴호스트닉네임테스트',
                      members: '4/4',
                      statusBadge: '모집 마감 임박',
                      infoBadge: '도보 120m',
                    ),
                    SizedBox(height: 12),
                    OomuMeetupCard.list(
                      title: '매우 긴 제목의 리스트형 모임 카드 텍스트 오버플로우 방어 검증',
                      date: '매주 토요일 오전 10시',
                      location: '서울 성동구 서울숲 야외무대',
                      hostName: '성수러너_길동',
                      members: '5/10',
                      statusBadge: '러닝·운동',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
      });
    }
  });
}
