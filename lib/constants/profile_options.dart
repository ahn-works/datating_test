/// OOMU 프로필 옵션 및 선택지 표준 상수 (SSOT)
/// 온보딩(ProfileSetupScreen), 프로필 수정(ProfileEditScreen), 프로필 상세(UserProfileScreen), 마이페이지(MyPageScreen) 전역 통일
class ProfileOptions {
  ProfileOptions._();

  // 필드 라벨 표준
  static const String jobLabel = '직무/직업';
  static const String ageLabel = '나이';
  static const String genderLabel = '성별';
  static const String mbtiLabel = 'MBTI';
  static const String drinkingLabel = '음주 성향';
  static const String smokingLabel = '흡연 여부';
  static const String petLabel = '반려동물';
  static const String personalityLabel = '성격 및 매력 태그';
  static const String hobbiesLabel = '관심사 / 취향';
  static const String unsetValue = '미설정';

  // 1. 반려동물 (4종)
  static const List<String> petOptions = [
    '반려동물 없음',
    '강아지',
    '고양이',
    '기타 반려동물',
  ];

  // 2. 음주 성향 (4종)
  static const List<String> drinkingOptions = [
    '가볍게 한잔',
    '술자리 좋아함',
    '분위기만 즐김',
    '비음주',
  ];

  // 3. 흡연 여부 (3종)
  static const List<String> smokingOptions = [
    '비흡연',
    '전자담배',
    '흡연',
  ];

  // 4. 성격 및 매력 태그 (8종)
  static const List<String> personalityOptions = [
    '리액션 요정',
    '친화력 갑',
    '열정 가득',
    '긍정 에너지',
    '조용한 편',
    '배려심 깊은',
    '센스 있는',
    '솔직 담백',
  ];

  // 5. 16가지 MBTI
  static const List<String> mbtiOptions = [
    'ENFP', 'INFP', 'ENFJ', 'INFJ',
    'ENTP', 'INTP', 'ENTJ', 'INTJ',
    'ESFP', 'ISFP', 'ESFJ', 'ISFJ',
    'ESTP', 'ISTP', 'ESTJ', 'ISTJ',
  ];

  // 6. 추천 취미/관심사 태그
  static const List<String> hobbiesOptions = [
    '☕ 카페투어', '🍷 내추럴와인', '🏃‍♀️ 한강러닝', '🐕 반려견 산책',
    '🎨 전시회/문화', '🍜 동네 숨은맛집', '🎬 영화/넷플릭스', '🚗 드라이브',
    '🏕️ 주말캠핑', '🏸 배드민턴', '🧗 클라이밍', '📚 독서/스터디',
  ];
}
