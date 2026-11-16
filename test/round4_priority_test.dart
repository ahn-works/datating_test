import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot10_app/screens/profile_setup_screen.dart';
import 'package:spot10_app/screens/user_profile_screen.dart';
import 'package:spot10_app/screens/oomu_home_screen.dart';
import 'package:spot10_app/utils/global_data.dart';
import 'package:spot10_app/constants/profile_options.dart';

void main() {
  setUp(() {
    globalData.resetSession();
  });

  group('Round 4 Priority Tasks Verification', () {
    testWidgets('1. ProfileSetupScreen step 1 provides "나중에 하기" escape route and dialog, tapping "홈으로 이동" navigates to OOMUHomeScreen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileSetupScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify "나중에 하기" button exists in step 1 top nav bar
      expect(find.text('나중에 하기'), findsOneWidget);

      // Tap "나중에 하기"
      await tester.tap(find.text('나중에 하기'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('프로필 등록을 건너뛰시겠어요?'), findsOneWidget);
      expect(find.text('계속 작성하기'), findsOneWidget);
      expect(find.text('홈으로 이동'), findsOneWidget);

      // Tap "홈으로 이동"
      await tester.tap(find.text('홈으로 이동'));
      await tester.pumpAndSettle();

      // Verify navigation to OOMUHomeScreen and exit from ProfileSetupScreen
      expect(find.byType(ProfileSetupScreen), findsNothing);
      expect(find.byType(OOMUHomeScreen), findsOneWidget);
      expect(globalData.skipProfileSetup, isTrue);
    });

    testWidgets('2. ProfileSetupScreen back button on step 1 triggers exit confirmation instead of being trapped', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileSetupScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap back button on step 1
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      // Verify exit confirmation dialog appears
      expect(find.text('프로필 등록을 건너뛰시겠어요?'), findsOneWidget);
    });

    testWidgets('3. UserProfileScreen renders 2-column key-value rows with honest labels and answers', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UserProfileScreen(
            userName: '초연',
            userAge: '29',
            userGender: '여성',
            userJob: '플루터 개발자',
            userMbti: 'ENFJ',
            userDrinking: ['가볍게 한잔'],
            userSmoking: '비흡연',
            userPet: '강아지',
            userPersonalities: ['친화력 갑', '긍정 에너지'],
            userHobbies: ['러닝', '카페투어'],
            userBio: '안녕하세요! 동네 이웃들과 친해지고 싶어요.',
            isSelf: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify question labels in left column
      expect(find.text('💼 직무/직업'), findsOneWidget);
      expect(find.text('🎂 나이'), findsOneWidget);
      expect(find.text('👤 성별'), findsOneWidget);
      expect(find.text('🎨 MBTI'), findsOneWidget);
      expect(find.text('🍻 음주 성향'), findsOneWidget);
      expect(find.text('🚭 흡연 여부'), findsOneWidget);
      expect(find.text('🐶 반려동물'), findsOneWidget);

      // Verify answer values in right column
      expect(find.text('플루터 개발자'), findsNWidgets(2)); // Hero header + key-value row
      expect(find.text('29세'), findsNWidgets(2)); // Hero header + key-value row
      expect(find.text('여성'), findsOneWidget);
      expect(find.text('ENFJ'), findsOneWidget);
      expect(find.text('가볍게 한잔'), findsOneWidget);
      expect(find.text('비흡연'), findsOneWidget);
      expect(find.text('강아지'), findsOneWidget);
    });

    testWidgets('4. UserProfileScreen shows "미설정" when fields are empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UserProfileScreen(
            userName: '새친구',
            isSelf: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // All unentered fields should honestly display '미설정'
      expect(find.text(ProfileOptions.unsetValue), findsNWidgets(7));
    });
  });
}
