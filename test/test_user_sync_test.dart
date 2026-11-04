import 'package:flutter_test/flutter_test.dart';
import 'package:spot10_app/utils/global_data.dart';
import 'package:spot10_app/services/auth_service.dart';
import 'package:spot10_app/services/chat_repository.dart';

void main() {
  group('3대 테스트 유저 및 봇 계정 동기화 검증', () {
    setUp(() {
      globalData.resetSession();
      authService.debugUserDocFetcher = null;
    });

    test('1. test_user_01(민지 25세 여 망원동) 프로필 데이터 적용 검증', () {
      final minjiData = {
        'uid': 'test_user_01',
        'nickname': '망원치즈_민지',
        'age': 25,
        'gender': '여성',
        'location': '서울 마포구 망원동',
        'mannerTemp': 41.2,
        'photoUrl': 'profiles/test_user_01.jpg',
        'role': 'user',
        'isBot': false,
      };

      globalData.switchUser('test_user_01', triggerFirestoreSync: false);
      globalData.applyProfileData(minjiData);

      expect(globalData.currentUserId.value, 'test_user_01');
      expect(globalData.userNickname.value, '망원치즈_민지');
      expect(globalData.userLocation.value, '서울 마포구 망원동');
      expect(globalData.userAvatar.value, 'profiles/test_user_01.jpg');
      expect(globalData.temperature.value, 41.2);
    });

    test('2. test_user_02(도현 28세 남 연남동) 프로필 데이터 적용 검증', () {
      final dohyunData = {
        'uid': 'test_user_02',
        'nickname': '연남러너_도현',
        'age': 28,
        'gender': '남성',
        'location': '서울 마포구 연남동',
        'mannerTemp': 43.5,
        'photoUrl': 'profiles/test_user_02.jpg',
        'role': 'user',
        'isBot': false,
      };

      globalData.switchUser('test_user_02', triggerFirestoreSync: false);
      globalData.applyProfileData(dohyunData);

      expect(globalData.currentUserId.value, 'test_user_02');
      expect(globalData.userNickname.value, '연남러너_도현');
      expect(globalData.userLocation.value, '서울 마포구 연남동');
      expect(globalData.userAvatar.value, 'profiles/test_user_02.jpg');
      expect(globalData.temperature.value, 43.5);
    });

    test('3. test_user_03(서연 31세 여 성수동) 프로필 데이터 적용 검증', () {
      final seoyeonData = {
        'uid': 'test_user_03',
        'nickname': '성수와인_서연',
        'age': 31,
        'gender': '여성',
        'location': '서울 성동구 성수동',
        'mannerTemp': 44.0,
        'photoUrl': 'profiles/test_user_03.jpg',
        'role': 'user',
        'isBot': false,
      };

      globalData.switchUser('test_user_03', triggerFirestoreSync: false);
      globalData.applyProfileData(seoyeonData);

      expect(globalData.currentUserId.value, 'test_user_03');
      expect(globalData.userNickname.value, '성수와인_서연');
      expect(globalData.userLocation.value, '서울 성동구 성수동');
      expect(globalData.userAvatar.value, 'profiles/test_user_03.jpg');
      expect(globalData.temperature.value, 44.0);
    });

    test('4. authService.syncUserSessionProfile을 통한 비동기 세션 전환 검증', () async {
      authService.debugUserDocFetcher = (uid) async {
        if (uid == 'test_user_01') {
          return {
            'nickname': '망원치즈_민지',
            'location': '서울 마포구 망원동',
            'mannerTemp': 41.2,
          };
        }
        return null;
      };

      await authService.syncUserSessionProfile('test_user_01');

      expect(globalData.currentUserId.value, 'test_user_01');
      expect(globalData.userNickname.value, '망원치즈_민지');
      expect(globalData.userLocation.value, '서울 마포구 망원동');
      expect(globalData.temperature.value, 41.2);
    });

    test('5. FirestoreChatRepository가 활성 테스트 유저 세션 UID를 인식한다', () {
      globalData.switchUser('test_user_02', triggerFirestoreSync: false);
      const repo = FirestoreChatRepository();
      expect(repo.currentUid, 'test_user_02');
    });

    test('6. 대화방 메시지 presentChatMessage가 현재 사용자에게 올바른 isMe를 부여한다', () {
      final msgFromDohyun = {
        'id': 'msg_01',
        'senderId': 'test_user_02',
        'sender': '연남러너_도현',
        'text': '안녕하세요!',
        'createdAt': '2026-11-04T12:00:00.000',
      };

      final presentedForDohyun = presentChatMessage(msgFromDohyun, 'test_user_02');
      expect(presentedForDohyun['isMe'], isTrue);

      final presentedForMinji = presentChatMessage(msgFromDohyun, 'test_user_01');
      expect(presentedForMinji['isMe'], isFalse);
    });
  });
}
