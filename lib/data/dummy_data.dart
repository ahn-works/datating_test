class DummyData {
  static final List<Map<String, dynamic>> users = [
    {
      'name': 'Ji-won',
      'age': 24,
      'location': '서울 강남구',
      'temp': 36.5,
      'tags': ['🎨 Creative', '☕ Coffee Lover', '✈️ Traveler'],
      'bio': '퇴근하고 분위기 좋은 카페에서 커피 마시는 걸 좋아해요! 비슷한 취향이시라면 편하게 대화 나눠요 😊',
    },
    {
      'name': 'Min-soo',
      'age': 28,
      'location': '서울 성동구',
      'temp': 37.2,
      'tags': ['💪 Workout', '🍷 Wine', '🎬 Netflix'],
      'bio': '주말엔 한강 러닝하고 저녁엔 와인 한잔하는 걸 즐깁니다. 같이 뛸 사람?',
    },
    {
      'name': 'Su-ah',
      'age': 25,
      'location': '서울 마포구',
      'temp': 36.8,
      'tags': ['🐶 Dog Mom', '📸 Photography', '🍰 Dessert'],
      'bio': '귀여운 강아지 키우고 있어요! 예쁜 카페가서 디저트 사진 찍는 거 좋아합니다.',
    },
    {
      'name': 'Do-yoon',
      'age': 29,
      'location': '서울 용산구',
      'temp': 38.1,
      'tags': ['🎧 Music', '🚗 Drive', '🎸 Guitar'],
      'bio': '음악 듣는 걸 좋아하고 최근엔 일렉 기타를 배우기 시작했어요. 근교 드라이브도 자주 갑니다.',
    },
  ];

  static final List<Map<String, dynamic>> notifications = [
    {'title': '새로운 대화 요청!', 'body': 'Min-soo님이 10분 익명 대화를 요청했습니다.', 'time': '방금 전', 'isRead': false},
    {'title': '보증금 환불 완료', 'body': 'QR 체크인이 확인되어 보증금 10,000원이 환불되었습니다.', 'time': '2시간 전', 'isRead': true},
    {'title': '시그널 하우스 알림', 'body': '자정 비밀 투표 결과가 도착했습니다!', 'time': '어제', 'isRead': true},
  ];
}
