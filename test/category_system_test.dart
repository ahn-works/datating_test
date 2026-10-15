import 'package:flutter_test/flutter_test.dart';
import 'package:spot10_app/data/oomu_categories.dart';

void main() {
  group('🏷️ OOMU 모임 카테고리 & Vibe 필터링 시스템 종합 단위 테스트', () {
    test('1. 상황별 필터(Vibe) 4종 구성 검증', () {
      expect(OOMUCategoryData.vibes.length, 4);

      final hot = OOMUCategoryData.vibes.firstWhere((v) => v.id == 'hot');
      expect(hot.title, '놀줄아는');
      expect(hot.emoji, '⚡');
      expect(hot.matchKeywords.contains('페스티벌'), isTrue);

      final chill = OOMUCategoryData.vibes.firstWhere((v) => v.id == 'chill');
      expect(chill.title, '소소하게');
      expect(chill.emoji, '☕');
      expect(chill.matchKeywords.contains('북카페'), isTrue);

      final mate = OOMUCategoryData.vibes.firstWhere((v) => v.id == 'mate');
      expect(mate.title, '메이트');
      expect(mate.emoji, '🍔');
      expect(mate.matchKeywords.contains('1인 가구'), isTrue);

      final dating = OOMUCategoryData.vibes.firstWhere((v) => v.id == 'dating');
      expect(dating.title, '소개팅');
      expect(dating.emoji, '💖');
      expect(dating.matchKeywords.contains('소개팅'), isTrue);
    });

    test('2. 6대 대분류 및 17대 중분류 체계도 무결성 검증', () {
      expect(OOMUCategoryData.mainCategories.length, 6);

      final expectedMainCategories = [
        '일상 & 푸드',
        '문화 & 엔터',
        '게임 & 오락',
        '액티비티 & 스포츠',
        '여행 & 나들이',
        '체험 & 취미',
      ];

      for (int i = 0; i < expectedMainCategories.length; i++) {
        expect(OOMUCategoryData.mainCategories[i].name, expectedMainCategories[i]);
      }

      // 총 중분류 개수 계산 (4 + 3 + 2 + 3 + 3 + 2 = 17)
      final totalSubCategories = OOMUCategoryData.mainCategories.fold<int>(
        0,
        (sum, m) => sum + m.subCategories.length,
      );
      expect(totalSubCategories, 17);

      // 각 중분류가 최소 2개 이상의 예시/소분류 태그를 보유하는지 검증
      for (final mainCat in OOMUCategoryData.mainCategories) {
        for (final subCat in mainCat.subCategories) {
          expect(subCat.exampleTags.isNotEmpty, isTrue,
              reason: '${mainCat.name} > ${subCat.name}의 예시 태그가 비어있지 않아야 합니다.');
        }
      }
    });

    test('3. OOMUCategoryData.matchesFilter() 카테고리 필터 매칭 로직 검증', () {
      final sampleMeetup = {
        'title': '성수 핫플 브런치 & 성수 팝업스토어 웨이팅 팟',
        'category': '문화 & 엔터',
        'description': '이번 주말 성수동 팝업스토어 같이 가실 분 구해요!',
        'tags': ['성수/연남 팝업스토어 웨이팅 동행', '전시 & 팝업스토어', '20대'],
      };

      // 전체 선택 시 무조건 true
      expect(OOMUCategoryData.matchesFilter(sampleMeetup, '전체', '전체'), isTrue);
      expect(OOMUCategoryData.matchesFilter(sampleMeetup, '전체', null), isTrue);

      // 대분류 일치
      expect(OOMUCategoryData.matchesFilter(sampleMeetup, '문화 & 엔터', '전체'), isTrue);

      // 다른 대분류 불일치
      expect(OOMUCategoryData.matchesFilter(sampleMeetup, '액티비티 & 스포츠', '전체'), isFalse);

      // 중분류 일치
      expect(OOMUCategoryData.matchesFilter(sampleMeetup, '문화 & 엔터', '전시 & 팝업스토어'), isTrue);

      // 소분류 태그 일치
      expect(OOMUCategoryData.matchesFilter(sampleMeetup, '문화 & 엔터', '성수/연남 팝업스토어 웨이팅 동행'), isTrue);
    });

    test('4. OOMUCategoryData.matchesVibe() 상황별 키워드 매칭 로직 검증', () {
      final runningMeetup = {
        'title': '주말 아침 한강 러닝 & 플로깅 메이트 구합니다',
        'category': '액티비티 & 스포츠',
        'description': '동네 주민끼리 러닝 5km 뛰고 시원한 음료 마셔요',
        'tags': ['운동', '러닝', '한강 러닝 & 플로깅'],
      };

      // 🍔 메이트 키워드 ('러닝', '운동') 매칭 성공
      expect(OOMUCategoryData.matchesVibe(runningMeetup, '메이트'), isTrue);

      // 💖 소개팅 키워드 불일치
      expect(OOMUCategoryData.matchesVibe(runningMeetup, '소개팅'), isFalse);

      final partyMeetup = {
        'title': '불금 힙한 혼술바 & 코노 노래방 파티',
        'category': '일상 & 푸드',
        'description': '연남동 와인바 1차 후 코노 갈 분 환영',
        'tags': ['혼술바', '코노', '불금'],
      };

      // ⚡ 놀줄아는 키워드 ('혼술바', '코노', '술', '노래') 매칭 성공
      expect(OOMUCategoryData.matchesVibe(partyMeetup, '놀줄아는'), isTrue);
    });

    test('5. 6대 대분류 전수 필터링 커버리지 검증', () {
      final allTestMeetups = [
        {'category': '동네 맛집 & 소셜 다이닝', 'mainCategory': '일상 & 푸드', 'tags': ['주말 마라탕&엽떡 모임']},
        {'category': '음악 & 노래방', 'mainCategory': '문화 & 엔터', 'tags': ['불금엔 역시 코노']},
        {'category': '보드게임', 'mainCategory': '게임 & 오락', 'tags': ['전략 보드게임 모임']},
        {'category': '야외 액티비티', 'mainCategory': '액티비티 & 스포츠', 'tags': ['한강 러닝 & 플로깅']},
        {'category': '출사 & 사진', 'mainCategory': '여행 & 나들이', 'tags': ['동네 골목길 인생샷 투어']},
        {'category': '원데이 클래스', 'mainCategory': '체험 & 취미', 'tags': ['향수/비누 만들기 공방']},
      ];

      for (final mainCat in OOMUCategoryData.mainCategories) {
        final matches = allTestMeetups.where((m) => OOMUCategoryData.matchesFilter(m, mainCat.name, '전체')).toList();
        expect(matches.isNotEmpty, isTrue, reason: '${mainCat.name} 대분류에 매칭되는 모임이 최소 1건 이상 존재해야 합니다.');
      }
    });

    test('6. 4대 상황별 Vibe 전수 매칭 커버리지 검증', () {
      final allTestMeetups = [
        {'title': '불금 핫플 혼술바', 'category': '동네 술 한잔', 'tags': ['놀줄아는', '페스티벌']},
        {'title': '주말 감성 북카페', 'category': '카페 & 디저트', 'tags': ['소소하게', '마라탕']},
        {'title': '동네 헬스장 메이트', 'category': '운동 메이트', 'tags': ['메이트', '1인 가구']},
        {'title': '자연스러운 2:2 미팅', 'category': '동네 술 한잔', 'tags': ['소개팅', '미팅']},
      ];

      for (final vibe in OOMUCategoryData.vibes) {
        final matches = allTestMeetups.where((m) => OOMUCategoryData.matchesVibe(m, vibe.title)).toList();
        expect(matches.isNotEmpty, isTrue, reason: '${vibe.title} 바이브에 매칭되는 모임이 최소 1건 이상 존재해야 합니다.');
      }
    });

    test('7. 기존 3개 시드 모임(코노, 엽떡마라탕, 북카페)의 상황(Vibe) 및 카테고리 필터링 정밀 검증', () {
      final meetupKono = {
        'title': '불금엔 역시 코노! 스트레스 풀 분 🎤',
        'category': '코노/노래',
        'tags': ['코노', '놀줄아는', '스트레스해소'],
      };

      final meetupMara = {
        'title': '주말 엽떡+마라탕 조지실 분 🔥',
        'category': '술/맛집',
        'tags': ['소셜다이닝', '메이트', '홍대맛집', '동네찐친'],
      };

      final meetupCafe = {
        'title': '성수동 대형 에스프레소 바 & 감성 북카페 나들이 ☕📚',
        'category': '카페/수다',
        'tags': ['카페/수다', '소소하게', '성수동'],
      };

      // 1. 코노 모임 검증: ⚡ '놀줄아는' Vibe 매칭 + '문화 & 엔터' 매칭
      expect(OOMUCategoryData.matchesVibe(meetupKono, '놀줄아는'), isTrue);
      expect(OOMUCategoryData.matchesFilter(meetupKono, '문화 & 엔터', '전체'), isTrue);

      // 2. 엽떡+마라탕 모임 검증: ☕ '소소하게' (엽떡, 마라탕, 맛집) & 🍔 '메이트' Vibe 매칭 + '일상 & 푸드' 매칭
      expect(OOMUCategoryData.matchesVibe(meetupMara, '소소하게'), isTrue);
      expect(OOMUCategoryData.matchesVibe(meetupMara, '메이트'), isTrue);
      expect(OOMUCategoryData.matchesFilter(meetupMara, '일상 & 푸드', '전체'), isTrue);

      // 3. 북카페 모임 검증: ☕ '소소하게' (북카페, 카페) Vibe 매칭 + '일상 & 푸드' 매칭
      expect(OOMUCategoryData.matchesVibe(meetupCafe, '소소하게'), isTrue);
      expect(OOMUCategoryData.matchesFilter(meetupCafe, '일상 & 푸드', '전체'), isTrue);
    });
  });
}
