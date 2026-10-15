import 'package:flutter/material.dart';

/// OOMU 상황별 필터 모델 (지금 내 상황)
class OOMUVibeFilter {
  final String id;
  final String title;
  final String emoji;
  final String subtitle;
  final List<String> matchKeywords;

  const OOMUVibeFilter({
    required this.id,
    required this.title,
    required this.emoji,
    required this.subtitle,
    required this.matchKeywords,
  });
}

/// OOMU 중분류 및 소분류/예시 모델
class OOMUSubCategory {
  final String name;
  final List<String> exampleTags;

  const OOMUSubCategory({
    required this.name,
    required this.exampleTags,
  });
}

/// OOMU 대분류 카테고리 모델
class OOMUMainCategory {
  final String id;
  final String name;
  final String icon;
  final IconData iconData;
  final List<OOMUSubCategory> subCategories;

  const OOMUMainCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.iconData,
    required this.subCategories,
  });

  /// 모든 중분류 이름 목록
  List<String> get subCategoryNames => subCategories.map((s) => s.name).toList();

  /// 모든 태그 목록 (중분류 + 소분류/예시)
  List<String> get allTags {
    final list = <String>[];
    for (final sub in subCategories) {
      list.add(sub.name);
      list.addAll(sub.exampleTags);
    }
    return list;
  }
}

/// OOMU 공식 마스터 카테고리 데이터 저장소
class OOMUCategoryData {
  /// [1] 상황별 필터 (지금 내 상황 탭)
  static const List<OOMUVibeFilter> vibes = [
    OOMUVibeFilter(
      id: 'hot',
      title: '놀줄아는',
      emoji: '⚡',
      subtitle: '핫플 탐방, 페스티벌, 클럽, 콘서트, 혼술바, 불금 코노',
      matchKeywords: [
        '놀줄아는', '핫플', '페스티벌', '클럽', '콘서트', '뮤지컬', '혼술바', '코노', '술', '와인', '파티', '공연', '노래'
      ],
    ),
    OOMUVibeFilter(
      id: 'chill',
      title: '소소하게',
      emoji: '☕',
      subtitle: '동네 소모임, 북카페, 마라탕/엽떡 맛집 탐방, 보드게임',
      matchKeywords: [
        '소소하게', '소모임', '북카페', '카페', '마라탕', '엽떡', '맛집', '보드게임', '디저트', '독서', '디저트'
      ],
    ),
    OOMUVibeFilter(
      id: 'mate',
      title: '메이트',
      emoji: '🍔',
      subtitle: '1인 가구 생활 공유 & 동성 모임 (캠핑, 헬스, 배달비 절약, 장보기)',
      matchKeywords: [
        '메이트', '1인 가구', '동성', '캠핑', '헬스', '배달비', '장보기', '소분', '운동', '러닝', '테니스'
      ],
    ),
    OOMUVibeFilter(
      id: 'dating',
      title: '소개팅',
      emoji: '💖',
      subtitle: '1:1 소개팅, 2:2 / 3:3 자연스러운 동네 미팅',
      matchKeywords: [
        '소개팅', '미팅', '2:2', '3:3', '소셜다이닝', '인연', '자만추', '취향'
      ],
    ),
  ];

  /// [2] 주제별/취향별 카테고리 체계도 (대 - 중 - 소)
  static const List<OOMUMainCategory> mainCategories = [
    // 1. 일상 & 푸드
    OOMUMainCategory(
      id: 'food',
      name: '일상 & 푸드',
      icon: '🍲',
      iconData: Icons.restaurant,
      subCategories: [
        OOMUSubCategory(
          name: '동네 맛집 & 소셜 다이닝',
          exampleTags: ['동네 핫플 메뉴 털기', '주말 마라탕&엽떡 모임', '전통시장 야시장 탐방'],
        ),
        OOMUSubCategory(
          name: '카페 & 디저트',
          exampleTags: ['북카페 겸 근교 드라이브', '동네 핫플 디저트 투어', 'LP 청음 카페'],
        ),
        OOMUSubCategory(
          name: '동네 술 한잔',
          exampleTags: ['힙한 혼술바 동행', '불금 코노 + 술 한잔', '동네 수제맥주·와인 팟'],
        ),
        OOMUSubCategory(
          name: '생활 메이트 (1인 가구)',
          exampleTags: ['배달비 절약 1/N 팟', '대형마트 대용량 장보기&소분'],
        ),
      ],
    ),

    // 2. 문화 & 엔터테인먼트
    OOMUMainCategory(
      id: 'culture',
      name: '문화 & 엔터',
      icon: '🎭',
      iconData: Icons.theater_comedy,
      subCategories: [
        OOMUSubCategory(
          name: '페스티벌 & 공연',
          exampleTags: ['뮤직 페스티벌 동행', '콘서트·뮤지컬 관람', '연극·클럽 탐방'],
        ),
        OOMUSubCategory(
          name: '전시 & 팝업스토어',
          exampleTags: ['성수/연남 팝업스토어 웨이팅 동행', '미술관·전시회 도슨트 투어'],
        ),
        OOMUSubCategory(
          name: '음악 & 노래방',
          exampleTags: ['불금엔 역시 코노', 'LP 음악 공유 & 5초 음악 릴레이'],
        ),
      ],
    ),

    // 3. 게임 & 오락
    OOMUMainCategory(
      id: 'game',
      name: '게임 & 오락',
      icon: '🎲',
      iconData: Icons.sports_esports,
      subCategories: [
        OOMUSubCategory(
          name: '보드게임',
          exampleTags: ['보드게임 카페 파티', '전략 보드게임 모임'],
        ),
        OOMUSubCategory(
          name: '공간 미션 & 방탈출',
          exampleTags: ['오프라인 방탈출 팟', '야외 AR 미션 게임 & 동네 추리 투어'],
        ),
      ],
    ),

    // 4. 액티비티 & 스포츠
    OOMUMainCategory(
      id: 'activity',
      name: '액티비티 & 스포츠',
      icon: '🏃',
      iconData: Icons.fitness_center,
      subCategories: [
        OOMUSubCategory(
          name: '실내 액티비티',
          exampleTags: ['실내 클라이밍 원데이', '볼링', '스쿼시'],
        ),
        OOMUSubCategory(
          name: '야외 액티비티',
          exampleTags: ['한강 러닝 & 플로깅', '패들보드·카약 체험', '자전거 라이딩'],
        ),
        OOMUSubCategory(
          name: '운동 메이트 (동성 추천)',
          exampleTags: ['동네 헬스장 헬스 메이트', '테니스·배드민턴 짝꿍'],
        ),
      ],
    ),

    // 5. 여행 & 나들이
    OOMUMainCategory(
      id: 'travel',
      name: '여행 & 나들이',
      icon: '✈️',
      iconData: Icons.explore,
      subCategories: [
        OOMUSubCategory(
          name: '출사 & 사진',
          exampleTags: ['지하철/버스 타고 떠나는 근교 출사', '동네 골목길 인생샷 투어'],
        ),
        OOMUSubCategory(
          name: '동성 전용 캠핑 & 야외',
          exampleTags: ['동성끼리 떠나는 글램핑·캠핑', '야외 불멍 팟'],
        ),
        OOMUSubCategory(
          name: '근교 나들이',
          exampleTags: ['근교 수목원/식물원 나들이', '주말 근교 드라이브'],
        ),
      ],
    ),

    // 6. 체험 & 취미
    OOMUMainCategory(
      id: 'hobby',
      name: '체험 & 취미',
      icon: '🎨',
      iconData: Icons.brush,
      subCategories: [
        OOMUSubCategory(
          name: '원데이 클래스',
          exampleTags: ['향수/비누 만들기 공방', '가죽공예', '베이킹·쿠킹 클래스'],
        ),
        OOMUSubCategory(
          name: '소셜 게더링 (모임 아지트)',
          exampleTags: ['팟럭(Potluck) 디저트 홈파티', '소소한 동네 독서&자기계발 스터디'],
        ),
      ],
    ),
  ];

  /// 이전 레거시 카테고리 명칭 호환성 별칭 매핑
  static const Map<String, List<String>> legacyCategoryAliases = {
    '일상 & 푸드': ['술/맛집', '카페/수다', '맛집', '술', '카페', '음식', '디저트', '푸드', '밥'],
    '문화 & 엔터': ['코노/노래', '문화', '공연', '전시', '노래방', '코노', '콘서트', '뮤지컬'],
    '게임 & 오락': ['보드게임', '방탈출', '게임', '오락'],
    '액티비티 & 스포츠': ['액티비티', '스포츠', '운동', '러닝', '헬스', '클라이밍'],
    '여행 & 나들이': ['여행/드라이브', '여행', '드라이브', '나들이', '출사', '캠핑'],
    '체험 & 취미': ['체험', '취미', '원데이클래스', '공방', '클래스', '스터디'],
  };

  /// 이전 레거시 중분류 명칭 호환성 별칭 매핑
  static const Map<String, List<String>> legacySubCategoryAliases = {
    '동네 맛집 & 소셜 다이닝': ['술/맛집', '맛집', '식사', '밥', '소셜다이닝'],
    '카페 & 디저트': ['카페/수다', '카페', '디저트', '커피'],
    '동네 술 한잔': ['술/맛집', '술', '와인', '맥주', '혼술바'],
    '음악 & 노래방': ['코노/노래', '코노', '노래방', '노래'],
    '야외 액티비티': ['액티비티', '러닝', '운동'],
  };

  /// 특정 키워드나 텍스트가 어떤 대분류/중분류에 속하는지 매칭 헬퍼
  static bool matchesFilter(Map<String, dynamic> meetup, String selectedCategory, String? selectedSubCategory) {
    if (selectedCategory == '전체' && (selectedSubCategory == null || selectedSubCategory == '전체')) {
      return true;
    }

    final cat = (meetup['category'] ?? '').toString();
    final mainCatField = (meetup['mainCategory'] ?? '').toString();
    final title = (meetup['title'] ?? '').toString();
    final desc = (meetup['description'] ?? '').toString();
    final tags = (meetup['tags'] as List?)?.map((t) => t.toString()).toList() ?? [];
    final allText = '$cat $mainCatField $title $desc ${tags.join(' ')}'.toLowerCase();

    // 중분류 필터링이 지정된 경우
    if (selectedSubCategory != null && selectedSubCategory != '전체') {
      if (allText.contains(selectedSubCategory.toLowerCase())) return true;
      final subAliases = legacySubCategoryAliases[selectedSubCategory] ?? [];
      if (subAliases.any((alias) => allText.contains(alias.toLowerCase()))) return true;
    }

    // 대분류 필터링
    if (selectedCategory != '전체') {
      if (mainCatField.toLowerCase().contains(selectedCategory.toLowerCase())) return true;
      final aliases = legacyCategoryAliases[selectedCategory] ?? [];
      if (aliases.any((alias) => allText.contains(alias.toLowerCase()))) return true;

      final mainCat = mainCategories.firstWhere(
        (m) => m.name == selectedCategory || m.id == selectedCategory,
        orElse: () => const OOMUMainCategory(
          id: '',
          name: '',
          icon: '',
          iconData: Icons.circle,
          subCategories: [],
        ),
      );

      if (mainCat.id.isNotEmpty) {
        if (allText.contains(mainCat.name.toLowerCase())) return true;
        for (final sub in mainCat.subCategories) {
          if (allText.contains(sub.name.toLowerCase())) return true;
          for (final tag in sub.exampleTags) {
            if (allText.contains(tag.toLowerCase())) return true;
          }
        }
      } else {
        if (allText.contains(selectedCategory.toLowerCase())) return true;
      }
    }

    return false;
  }

  /// 바이브(상황별 필터)에 맞는지 검사하는 헬퍼
  static bool matchesVibe(Map<String, dynamic> meetup, String vibeTitle) {
    final vibe = vibes.firstWhere(
      (v) => v.title == vibeTitle || v.id == vibeTitle,
      orElse: () => const OOMUVibeFilter(
        id: '',
        title: '',
        emoji: '',
        subtitle: '',
        matchKeywords: [],
      ),
    );

    if (vibe.id.isEmpty) return true;

    final cat = (meetup['category'] ?? '').toString();
    final title = (meetup['title'] ?? '').toString();
    final desc = (meetup['description'] ?? '').toString();
    final tags = (meetup['tags'] as List?)?.map((t) => t.toString()).toList() ?? [];
    final allText = '$cat $title $desc ${tags.join(' ')}'.toLowerCase();

    return vibe.matchKeywords.any((kw) => allText.contains(kw.toLowerCase()));
  }
}
