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
  });
}
