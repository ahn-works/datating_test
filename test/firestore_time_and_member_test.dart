import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot10_app/screens/my_page_screen.dart';
import 'package:spot10_app/screens/profile_edit_screen.dart';
import 'package:spot10_app/screens/settings_screen.dart';
import 'package:spot10_app/screens/user_profile_screen.dart';
import 'package:spot10_app/services/auth_service.dart';
import 'package:spot10_app/services/meetup_application_service.dart';
import 'package:spot10_app/services/r2_storage_service.dart';
import 'package:spot10_app/utils/app_image.dart';
import 'package:spot10_app/utils/firestore_time.dart';
import 'package:spot10_app/utils/global_data.dart';
import 'package:spot10_app/utils/meetup_member_helper.dart';
import 'package:spot10_app/utils/oomu_ui_helpers.dart';

void main() {
  group('1. Firestore 시간 필드 혼용(Timestamp/DateTime/ISO String/int) 정렬 검증', () {
    // 실DB에서 확인된 형태의 픽스처
    final docIso1 = {
      'id': 'seed_seed_cafe_seongsu_1114',
      'title': '성수동 카페 투어',
      'createdAt': '2026-11-13T16:56:39Z',
    };
    final docIso2 = {
      'id': 'seed_seed_boardgame_gangnam_1114',
      'title': '강남 보드게임 파티',
      'createdAt': '2026-11-13T17:00:00Z',
    };
    final docIso3 = {
      'id': 'meetup_test_1794442447',
      'title': '여수 학동 맛집',
      'createdAt': '2026-11-13T15:30:00Z',
    };
    final docTimestamp = {
      'id': 'meetup_ts_recent',
      'title': '최신 모임 (Timestamp)',
      'createdAt': Timestamp.fromDate(DateTime.utc(2026, 11, 14, 12, 0, 0)),
    };
    final docDateTime = {
      'id': 'meetup_dt_mid',
      'title': '중간 모임 (DateTime)',
      'createdAt': DateTime.utc(2026, 11, 14, 0, 0, 0),
    };
    final docEpochMs = {
      'id': 'meetup_epoch_old',
      'title': '과거 모임 (Epoch ms)',
      'createdAt': 1794400000000,
    };
    final docNull = {
      'id': 'meetup_no_time',
      'title': '시간 정보 누락 모임',
      'createdAt': null,
    };

    test('Timestamp, DateTime, ISO-8601 String, int, null이 혼합된 목록이 예외 없이 결정적으로 최신순 정렬된다', () {
      final list = [
        docNull,
        docIso1,
        docTimestamp,
        docEpochMs,
        docIso3,
        docDateTime,
        docIso2,
      ];

      // 어떤 입력에도 TypeError나 Exception이 발생하지 않아야 함
      expect(() {
        list.sort((a, b) => compareFirestoreTimes(a['createdAt'], b['createdAt']));
      }, returnsNormally);

      // 최신순(내림차순) 정렬 검증
      final sortedIds = list.map((d) => d['id']).toList();
      expect(sortedIds.first, equals('meetup_ts_recent')); // 11-14 12:00
      expect(sortedIds[1], equals('meetup_dt_mid')); // 11-14 00:00
      expect(sortedIds[2], equals('seed_seed_boardgame_gangnam_1114')); // 11-13 17:00
      expect(sortedIds[3], equals('seed_seed_cafe_seongsu_1114')); // 11-13 16:56:39
      expect(sortedIds[4], equals('meetup_test_1794442447')); // 11-13 15:30
      expect(sortedIds.last, equals('meetup_no_time')); // null -> 0
    });

    test('parseFirestoreDateTime이 각 타입을 올바른 DateTime 객체로 변환한다', () {
      final dtIso = parseFirestoreDateTime('2026-11-13T16:56:39Z');
      expect(dtIso, isNotNull);
      expect(dtIso!.year, equals(2026));
      expect(dtIso.month, equals(11));
      expect(dtIso.day, equals(13));

      final dtTs = parseFirestoreDateTime(Timestamp.fromDate(DateTime.utc(2026, 11, 14)));
      expect(dtTs, isNotNull);
      expect(dtTs!.year, equals(2026));

      final dtEpoch = parseFirestoreDateTime(1794400000000);
      expect(dtEpoch, isNotNull);

      expect(parseFirestoreDateTime(null), isNull);
      expect(parseFirestoreDateTime(''), isNull);
      expect(parseFirestoreDateTime('invalid_string'), isNull);
    });
  });

  group('2. 모임 members 실DB 타입 혼용(List<UID> / String / 누락) 정규화 검증', () {
    // 실DB 픽스처
    final docListMembers = {
      'id': 'seed_seed_cafe_seongsu_1114',
      'title': '성수동 카페 투어',
      'members': ['bot_yeosu_food', 'user_sample_02'], // List<UID>
      'maxMembers': 4,
    };
    final docListNoCapacity = {
      'id': 'meetup_list_no_cap',
      'members': ['bot_01', 'bot_02', 'bot_03'],
    };
    final docStringMembers = {
      'id': 'meetup_test_1794442447',
      'members': '2/4',
    };
    final docCapacityFallback = {
      'id': 'meetup_cap_fallback',
      'members': null,
      'capacity': 6,
    };
    final docMaxPartFallback = {
      'id': 'meetup_max_part',
      'members': null,
      'maxParticipants': 8,
    };

    test('formatMembersLabel이 members가 List여도 내부 UID 배열을 노출하지 않고 X/Y로 변환한다', () {
      final label1 = MeetupMemberHelper.formatMembersLabel(docListMembers);
      expect(label1, equals('2/4'));
      expect(label1.contains('bot_yeosu_food'), isFalse);
      expect(label1.contains('['), isFalse);

      final label2 = MeetupMemberHelper.formatMembersLabel(docListNoCapacity);
      expect(label2, equals('3/4'));

      final label3 = MeetupMemberHelper.formatMembersLabel(docStringMembers);
      expect(label3, equals('2/4'));

      final labelNull = MeetupMemberHelper.formatMembersLabel(null);
      expect(labelNull, equals('2/4'));
    });

    test('parseCapacity가 maxMembers -> capacity -> maxParticipants -> members(Y) -> 기본값 4 순으로 정원을 계산한다', () {
      expect(MeetupMemberHelper.parseCapacity(docListMembers), equals(4)); // maxMembers: 4
      expect(MeetupMemberHelper.parseCapacity(docCapacityFallback), equals(6)); // capacity: 6
      expect(MeetupMemberHelper.parseCapacity(docMaxPartFallback), equals(8)); // maxParticipants: 8
      expect(MeetupMemberHelper.parseCapacity(docStringMembers), equals(4)); // members: '2/4'
      expect(MeetupMemberHelper.parseCapacity(docListNoCapacity), equals(4)); // fallback 4
    });

    test('parseAttendance가 members List 길이, participantIds, 또는 members 문자열(X)을 올바르게 읽는다', () {
      expect(MeetupMemberHelper.parseAttendance(docListMembers), equals(2));
      expect(MeetupMemberHelper.parseAttendance(docListNoCapacity), equals(3));
      expect(MeetupMemberHelper.parseAttendance(docStringMembers), equals(2));

      final docWithPartIds = {
        'participantIds': ['u1', 'u2', 'u3', 'u4'],
        'members': '1/4',
      };
      // participantIds가 우선
      expect(MeetupMemberHelper.parseAttendance(docWithPartIds), equals(4));
    });

    test('MeetupApplicationService.capacity 및 attendance가 List 문서에서도 0이 아닌 유효한 값을 반환한다', () {
      // 이전에 List 문서에서 split('/') 실패로 0이 반환되어 신청이 거부되던 결함 검증
      final cap = MeetupApplicationService.capacity(docListMembers);
      final att = MeetupApplicationService.attendance(docListMembers);
      expect(cap, equals(4));
      expect(att, equals(2));
      expect(cap > 0, isTrue);
      expect(att <= cap, isTrue);
    });

    test('잔여석 계산(calcRemainingSeats)이 List 및 String 타입 문서 모두에서 올바르게 계산된다', () {
      expect(MeetupMemberHelper.calcRemainingSeats(docListMembers), equals('2자리 남음'));
      expect(MeetupMemberHelper.calcRemainingSeats(docListNoCapacity), equals('1자리 남음'));

      final fullMeetup = {
        'members': ['u1', 'u2', 'u3', 'u4'],
        'maxMembers': 4,
      };
      expect(MeetupMemberHelper.calcRemainingSeats(fullMeetup), equals('모집 마감'));
    });
  });

  group('3. 프로필 4화면(MY · 프로필 수정 · 미리보기 · 설정) 단일 진실 공급원(SSOT) 및 가짜 기본값 배제 검증', () {
    testWidgets('게스트(미설정) 진입 시 4화면이 서로 다른 온도(39.8/36.5/42.0)나 가짜 후기(23개)·본인인증 완료를 표시하지 않고 일관된 미설정 상태를 보여준다', (tester) async {
      await authService.signInAsGuest();

      // 1. MY (MyPageScreen)
      await tester.pumpWidget(MaterialApp(
        key: const ValueKey('app_my'),
        theme: OomuUiHelpers.buildTheme(),
        home: const MyPageScreen(),
      ));
      await tester.pump();
      expect(find.text('닉네임 미설정'), findsOneWidget);
      expect(find.text('동네 미설정'), findsOneWidget);
      expect(find.text('본인인증 미완료'), findsOneWidget);
      expect(find.text('정보 없음'), findsOneWidget);
      expect(find.text('아직 받은 후기가 없어요'), findsOneWidget);
      expect(find.text('39.8°C'), findsNothing);
      expect(find.text('재참여 희망 96% · 받은 후기 23개'), findsNothing);
      expect(find.text('본인인증 완료'), findsNothing);

      // 2. 프로필 수정 (ProfileEditScreen) -> 미리보기 (UserProfileScreen)
      await tester.pumpWidget(MaterialApp(
        key: const ValueKey('app_edit'),
        theme: OomuUiHelpers.buildTheme(),
        home: const ProfileEditScreen(),
      ));
      await tester.pumpAndSettle();
      expect(find.text('우리동네_초연'), findsNothing);
      expect(find.text('프리랜서 디자이너'), findsNothing);

      await tester.tap(find.text('미리보기'));
      await tester.pumpAndSettle();
      expect(find.byType(UserProfileScreen), findsOneWidget);
      expect(find.text('닉네임 미설정'), findsOneWidget);
      expect(find.text('매너온도 정보 없음'), findsOneWidget);
      expect(find.text('36.5°C'), findsNothing);
      expect(find.text('🍻 가볍게 한잔'), findsNothing);
      expect(find.text('🐶 반려동물 있음'), findsNothing);
      expect(find.text('✨ 리액션 요정'), findsNothing);

      // 3. 설정 (SettingsScreen)
      await tester.pumpWidget(MaterialApp(
        key: const ValueKey('app_settings'),
        theme: OomuUiHelpers.buildTheme(),
        home: const SettingsScreen(),
      ));
      await tester.pump();
      expect(find.text('닉네임 미설정'), findsOneWidget);
      expect(find.text('정보 없음'), findsOneWidget);
      expect(find.text('동네 미설정 · 본인인증 미완료'), findsOneWidget);
      expect(find.text('42.0°C'), findsNothing);
      expect(find.textContaining('본인인증 완료'), findsNothing);

      globalData.resetSession();
    });
  });

  group('4. [0단계] app_image.dart Base64 및 R2 covers/<ts>_파일명 실사진 해소 검증', () {
    test('data:image Base64 Data URL이 NetworkImage가 아닌 MemoryImage로 디코딩된다', () {
      const tinyPngBase64 =
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';
      final provider = appImg(tinyPngBase64);
      expect(provider, isA<MemoryImage>());
    });

    test('covers/<ts>_파일명(run 포함 포함)이 스톡 에셋으로 치환되지 않고 R2 NetworkImage로 해소된다', () {
      final prevBase = r2Storage.publicBaseUrl;
      r2Storage.publicBaseUrl = 'https://cdn.oomu.app';
      try {
        final userCover = appImg('covers/1794800000_my_run_club.jpg');
        expect(userCover, isA<NetworkImage>());
        expect(
          (userCover as NetworkImage).url,
          'https://cdn.oomu.app/covers/1794800000_my_run_club.jpg',
        );

        final bundledCover = appImg('covers/cover_cafe.jpg');
        expect(bundledCover, isA<AssetImage>());
        expect(
          (bundledCover as AssetImage).assetName,
          'assets/images/cover_cafe.jpg',
        );
      } finally {
        r2Storage.publicBaseUrl = prevBase;
      }
    });
  });
}

