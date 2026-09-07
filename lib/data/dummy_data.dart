class DummyData {
  static final List<Map<String, dynamic>> users = [
    {
      'name': 'Ji-won', 'age': 24, 'location': '서울 강남구', 'temp': 36.5,
      'tags': ['🎨 전시회', '☕ 카페 투어', '✈️ 여행'],
      'bio': '퇴근하고 분위기 좋은 카페에서 커피 마시는 걸 좋아해요! 비슷한 취향이시라면 편하게 대화 나눠요 😊',
      'profileUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
    },
    {
      'name': 'Min-soo', 'age': 28, 'location': '서울 성동구', 'temp': 37.2,
      'tags': ['💪 헬스/러닝', '🍷 와인', '🎬 넷플릭스'],
      'bio': '주말엔 한강 러닝하고 저녁엔 와인 한잔하는 걸 즐깁니다. 뚝섬에서 같이 뛸 사람?',
      'profileUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=400&q=80',
    },
    {
      'name': 'Su-ah', 'age': 25, 'location': '서울 마포구', 'temp': 36.8,
      'tags': ['🐶 강아지', '📸 사진', '🍰 디저트'],
      'bio': '귀여운 비숑 키우고 있어요! 연남동 예쁜 카페가서 디저트 부수는 거 제일 좋아합니다.',
      'profileUrl': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=400&q=80',
    },
    {
      'name': 'Do-yoon', 'age': 29, 'location': '서울 용산구', 'temp': 38.1,
      'tags': ['🎧 인디음악', '🚗 드라이브', '🎸 기타'],
      'bio': '음악 듣는 걸 좋아하고 최근엔 일렉 기타를 배우기 시작했어요. 심야에 근교 드라이브도 자주 갑니다.',
      'profileUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
    },
  ];

  static final List<Map<String, dynamic>> parties = [
    {'title': '🍺 성수동 퇴근길 하이볼 & 타코 팟!', 'location': '성수역 3번 출구', 'date': '오늘 오후 7:30', 'members': '3/4', 'tags': ['직장인', '간단하게']},
    {'title': '🏸 뚝섬유원지 저녁 배드민턴 칠 분', 'location': '뚝섬유원지', 'date': '내일 오후 8:00', 'members': '2/4', 'tags': ['운동', '초보환영']},
    {'title': '☕ 주말 성수 카페투어 + 사진 품앗이', 'location': '오우드 성수', 'date': '토요일 오후 2:00', 'members': '1/2', 'tags': ['사진', '인스타감성']},
  ];

  static final List<Map<String, dynamic>> chats = [
    {'name': 'Min-soo', 'lastMessage': '네 완전 좋아해요! 주말마다 카페 가거든요.', 'time': '오후 2:30', 'unread': 1, 'profileUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=150&q=80'},
    {'name': '익명 (강남구)', 'lastMessage': '혹시 어떤 영화 좋아하세요?', 'time': '어제', 'unread': 0, 'profileUrl': null},
  ];

  static final List<Map<String, dynamic>> balanceGames = [
    {'question': '연인과 데이트를 한다면?', 'optionA': '핫플레이스 성수동 카페 투어', 'optionB': '인적 드문 근교 드라이브'},
    {'question': '연락 빈도 취향은?', 'optionA': '수시로 계속 카톡으로 일상 공유하기', 'optionB': '아침, 저녁에만 길게 통화하기'},
    {'question': '스트레스 받을 때 나는?', 'optionA': '사람들과 만나서 신나게 놀며 푼다', 'optionB': '혼자 집에서 조용히 쉰다'},
  ];

  static final List<Map<String, dynamic>> notifications = [
    {'title': '새로운 대화 요청!', 'body': 'Min-soo님이 10분 익명 대화를 요청했습니다.', 'time': '방금 전', 'isRead': false},
    {'title': '보증금 환불 완료', 'body': 'QR 체크인이 확인되어 보증금 10,000원이 환불되었습니다.', 'time': '2시간 전', 'isRead': true},
  ];
}
