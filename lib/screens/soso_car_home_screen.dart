import 'explore_map_screen.dart';
import 'package:flutter/material.dart';
import '../data/oomu_categories.dart';
import '../utils/app_image.dart';
import '../utils/global_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'soso_car_host_screen.dart';
import 'chat_screen.dart';
import 'my_page_screen.dart';
import 'soso_car_detail_screen.dart';
import 'filter_screen.dart';
import 'soso_spot_screen.dart';
import '../utils/location_helper.dart';
import 'soso_car_chat_screen.dart';
import '../widgets/ugc_action_sheets.dart';
import 'notification_screen.dart';
import 'community_post_detail_screen.dart';
import 'community_post_create_screen.dart';
import 'event_detail_screen.dart';
import 'user_profile_screen.dart';

class OOMUHomeScreen extends StatefulWidget {
  final int initialTab;
  const OOMUHomeScreen({super.key, this.initialTab = 0});

  @override
  State<OOMUHomeScreen> createState() => _OOMUHomeScreenState();
}

class _OOMUHomeScreenState extends State<OOMUHomeScreen> {
  final Color textPrimary = const Color(0xFF221B1D);
  final Color textSecondary = const Color(0xFF635559);
  final Color surfaceColor = const Color(0xFFFAF6F7);
  final Color accentColor = const Color(0xFFF25767);
  final Color coralAccent = const Color(0xFFF25767);
  final Color destructiveColor = const Color(0xFFE11D48);
  final Color trustColor = const Color(0xFF0D9488);

  late int _homeDashboardTab; // 0: 모임, 1: 커뮤니티, 2: 소개팅, 3: 채팅, 4: MY
  String _communityCategoryFilter = '전체';
  String? _communityKeywordFilter;

  final List<Map<String, dynamic>> _communityPosts = [
    {
      'id': 'post_minseo_01',
      'category': '동네 토크',
      'tag': '산책메이트',
      'title': '🐕 오늘 저녁 연트럴파크 강아지 산책 같이 하실 분 계신가요?',
      'content': '날씨가 너무 선선하고 좋아서 저녁 7시쯤 비숑 데리고 산책 나가려구요! 댕댕이 없으셔도 가볍게 산책하고 대화 나누실 이웃분 환영합니다 ✨',
      'author': '김민서',
      'authorAvatar': 'assets/images/kr_female_1.jpg',
      'location': '마포구 서교동',
      'time': '10분 전',
      'manner': 37.2,
      'likedUserIds': ['user_demo_1', 'user_demo_2'],
      'likes': 2,
      'isLiked': false,
      'comments': 4,
      'image': 'assets/images/cover_running.jpg',
      'relatedMeetup': {
        'title': '연트럴파크 저녁 산책 같이 하실 분!',
        'location': '마포구 연트럴파크 잔디광장',
        'category': '일상 & 푸드 > 카페 & 디저트',
        'poster': 'assets/images/cover_running.jpg',
      }
    },
    {
      'id': 'post_junho_02',
      'category': '맛집/카페',
      'tag': '성수에스프레소',
      'title': '☕ 성수동 새로 오픈한 에스프레소 바 다녀왔는데 인생 커피 찾았습니다',
      'content': '성수역 뒤쪽 골목에 새로 생긴 곳인데 스트라파짜토랑 크림 에스프레소 진짜 미쳤네요... 이번 주말에 커피 좋아하시는 분들과 같이 가서 메뉴 도장깨기 하고 싶어요!',
      'author': '이준호',
      'authorAvatar': 'assets/images/kr_male_1.jpg',
      'location': '성동구 성수동',
      'time': '25분 전',
      'manner': 38.5,
      'likedUserIds': ['user_demo_1'],
      'likes': 1,
      'isLiked': false,
      'comments': 6,
      'image': 'assets/images/cover_cafe.jpg',
      'relatedMeetup': {
        'title': '성수동 에스프레소 바 투어 같이 가실 분!',
        'location': '성동구 성수동 카페거리',
        'category': '일상 & 푸드 > 카페 & 디저트',
        'poster': 'assets/images/cover_cafe.jpg',
      }
    },
    {
      'id': 'post_jiyeon_03',
      'category': '맛집/카페',
      'tag': '연남베이킹',
      'title': '🥐 연남동 골목에 조용하고 소금빵 맛있는 북카페 찾았어요',
      'content': '겉바속촉 쌀 소금빵 나오자마자 먹었는데 진짜 최고예요ㅠㅠ 자리도 넓고 채광 좋아서 주말 오후에 책 읽거나 노트북 작업하기 딱입니다. 동네 분들 같이 가요!',
      'author': '박지연',
      'authorAvatar': 'assets/images/kr_female_2.jpg',
      'location': '마포구 연남동',
      'time': '40분 전',
      'manner': 36.8,
      'likedUserIds': ['user_demo_2', 'user_demo_3'],
      'likes': 2,
      'isLiked': false,
      'comments': 3,
      'image': 'assets/images/cover_food.jpg',
      'relatedMeetup': {
        'title': '연남동 소금빵 & 북카페 나들이 같이 가실 분!',
        'location': '마포구 연남동 미로길',
        'category': '일상 & 푸드 > 카페 & 디저트',
        'poster': 'assets/images/cover_food.jpg',
      }
    },
    {
      'id': 'post_01',
      'category': '공연/전시',
      'tag': '스위니토드',
      'title': '🎭 이번 주 스위니토드 샤롯데/디큐브 1차 예매 다녀왔습니다! 꿀자리 추천',
      'content': '이번 시즌 스위니토드 캐스팅 역대급이네요... 1층 B구역 8열 시야 정말 완벽합니다. 혹시 다음 주 주말 회차 가시는 분 계시면 공연 전후로 커피나 한잔하며 극 얘기 나눠요!',
      'author': '뮤지컬덕후',
      'authorAvatar': 'assets/images/kr_female_1.jpg',
      'location': '구로구 신도림동',
      'time': '12분 전',
      'manner': 42.5,
      'likedUserIds': ['user_demo_1', 'user_demo_2', 'user_demo_3'],
      'likes': 28,
      'isLiked': false,
      'comments': 9,
      'image': 'http://www.kopis.or.kr/upload/pfmPoster/PF_PF303043_261012_171201.gif',
      'relatedMeetup': {
        'title': '스위니토드 같이 보실 분!',
        'location': '디큐브 링크아트센터',
        'category': '문화 & 엔터 > 페스티벌 & 공연',
        'poster': 'http://www.kopis.or.kr/upload/pfmPoster/PF_PF303043_261012_171201.gif',
      }
    },
    {
      'id': 'post_02',
      'category': '맛집/카페',
      'tag': '두바이쫀득쿠키',
      'title': '🍰 연남동 두바이 쫀득 쿠키(두쫀쿠) 실시간 웨이팅 상황 & 솔직 후기',
      'content': '오늘 1시 오픈런 뛰어서 드디어 두쫀쿠 겟했습니다... 카다이프 바삭함이 미쳤네요ㅠㅠ 1인당 2개 한정이라 주말에 같이 가서 메뉴 여러 개 털어볼 메이트 구합니다!',
      'author': '달콤빵순이',
      'authorAvatar': 'assets/images/kr_female_2.jpg',
      'location': '마포구 연남동',
      'time': '35분 전',
      'manner': 43.1,
      'likes': 42,
      'isLiked': false,
      'comments': 16,
      'image': 'assets/images/cover_cafe.jpg',
      'relatedMeetup': {
        'title': '두바이 쫀득 쿠키(두쫀쿠) 카페 탐방 같이 가실 분!',
        'location': '서울 마포구 연남동',
        'category': '일상 & 푸드 > 카페 & 디저트',
        'poster': 'assets/images/cover_cafe.jpg',
      }
    },
    {
      'id': 'post_03',
      'category': '공연/전시',
      'tag': 'TXT월드투어',
      'title': '⚡ KSPO DOME 투모로우바이투게더 콘서트 티켓팅 성공하신 분 동행 구해요!',
      'content': '체조경기장 막콘 좌석 잡았습니다! 콘서트 당일 올림픽공원에서 응원봉 배터리도 나누고 콘서트 끝나고 뒷풀이 감자탕/치맥 하실 분들 계실까요?',
      'author': 'KPOP투게더',
      'authorAvatar': 'assets/images/kr_male_2.jpg',
      'location': '송파구 방이동',
      'time': '1시간 전',
      'manner': 41.2,
      'likes': 51,
      'isLiked': false,
      'comments': 23,
      'image': 'assets/images/cover_wine.jpg',
      'relatedMeetup': {
        'title': 'TOMORROW X TOGETHER WORLD TOUR 콘서트 동행 같이 가실 분!',
        'location': '올림픽공원 KSPO DOME',
        'category': '문화 & 엔터 > 페스티벌 & 공연',
        'poster': 'assets/images/cover_wine.jpg',
      }
    },
    {
      'id': 'post_04',
      'category': '동네 토크',
      'tag': '을지로혼술바',
      'title': '🍷 을지로 골목길 조용하게 책 읽거나 와인 마시기 좋은 바 있나요?',
      'content': '퇴근하고 시끄러운 술집 말고 잔잔하게 재즈 흘러나오는 바 찾고 있어요. 동네 주민분들만 아는 아지트 살짝 공유해주실 천사분 계실까요?',
      'author': '심야산책러',
      'authorAvatar': 'assets/images/kr_male_1.jpg',
      'location': '중구 을지로동',
      'time': '2시간 전',
      'manner': 40.8,
      'likes': 19,
      'isLiked': false,
      'comments': 11,
      'image': 'assets/images/cover_food.jpg',
      'relatedMeetup': {
        'title': '을지로 감성 와인바 모임 같이 가실 분!',
        'location': '서울 중구 을지로동',
        'category': '일상 & 푸드 > 동네 술 한잔',
        'poster': 'assets/images/cover_food.jpg',
      }
    },
  ];


  final List<Map<String, dynamic>> _groupDatingPots = [
    {
      'id': 'group_dating_01',
      'title': '🍷 불금 홍대 2:2 직장인 와인 & 타파스 미팅 (20대 중후반)',
      'location': '마포구 연남동 와인바',
      'time': '이번 주 금요일 저녁 7:30',
      'members': '3/4 (여성 1자리 남음)',
      'category': '동네 2:2 미팅',
      'host': '매운맛킬러',
      'hostAvatar': 'assets/images/kr_female_1.jpg',
      'manner': 42.1,
      'image': 'assets/images/cover_wine.jpg',
      'desc': '어색하지 않고 편안한 분위기의 2:2 동네 미팅입니다! 직장인 20대 중후반 동네 친구도 사귀고 좋은 인연 만들어봐요.',
    },
    {
      'id': 'group_dating_02',
      'title': '☕ 주말 성수 3:3 자연스러운 카페 & 보드게임 미팅 🎲',
      'location': '성동구 성수동 카페거리',
      'time': '이번 주 토요일 오후 3:00',
      'members': '4/6 (남2/여2 모집완료)',
      'category': '동네 3:3 미팅',
      'host': '성수러버',
      'hostAvatar': 'assets/images/kr_male_2.jpg',
      'manner': 41.8,
      'image': 'assets/images/cover_cafe.jpg',
      'desc': '술 없이 가볍게 보드게임과 커피 마시면서 자연스럽게 친해지는 3:3 미팅 팟입니다.',
    },
  ];

  final List<Map<String, dynamic>> _liveSpots = [
    {
      'id': 'spot_01',
      'title': '홍대입구역 9번 출구 인생네컷 & 와플 🧇',
      'location': '마포구 홍대입구역 9번 출구 앞',
      'distance': '도보 180m',
      'timeLeft': '8분 남음',
      'category': '오늘 번개',
      'members': '2/4',
      'host': '달콤한와플',
      'hostAvatar': 'assets/images/kr_female_2.jpg',
      'manner': 42.1,
      'image': 'assets/images/cover_cafe.jpg',
      'isLightning': true,
      'date': '오늘 즉시 (8분 후 집결)',
    },
    {
      'id': 'spot_02',
      'title': '연남동 연트럴파크 돗자리 캔맥주 급구 🍺',
      'location': '마포구 경의선숲길 잔디광장',
      'distance': '도보 350m',
      'timeLeft': '12분 남음',
      'category': '오늘 번개',
      'members': '3/4',
      'host': '연트럴피플',
      'hostAvatar': 'assets/images/kr_male_2.jpg',
      'manner': 39.4,
      'image': 'assets/images/cover_wine.jpg',
      'isLightning': true,
      'date': '오늘 즉시 (12분 후 집결)',
    },
    {
      'id': 'spot_03',
      'title': '성수동 서울숲 잔디마당 플랫화이트 번개 ☕',
      'location': '성동구 서울숲 메인 출구',
      'distance': '도보 520m',
      'timeLeft': '15분 남음',
      'category': '오늘 번개',
      'members': '1/3',
      'host': '성수동힙스터',
      'hostAvatar': 'assets/images/kr_female_3.jpg',
      'manner': 43.0,
      'image': 'assets/images/cover_cafe.jpg',
      'isLightning': true,
      'date': '오늘 즉시 (15분 후 집결)',
    },
    {
      'id': 'spot_04',
      'title': '망원 한강공원 야경 산책 & 라면 먹방 🏃',
      'location': '마포구 망원 한강공원 편의점 앞',
      'distance': '도보 750m',
      'timeLeft': '22분 남음',
      'category': '오늘 번개',
      'members': '2/4',
      'host': '망원라이더',
      'hostAvatar': 'assets/images/kr_male_1.jpg',
      'manner': 41.5,
      'image': 'assets/images/cover_running.jpg',
      'isLightning': true,
      'date': '오늘 즉시 (22분 후 집결)',
    },
  ];

  String _currentLocation = '마포구 서교동';
  String? _selectedVibe;
  int _selectedCategoryIndex = 0;
  String _selectedSubCategory = '전체';
  String _selectedTrendCategory = '전체';
  int _trendPageIndex = 0;
  bool _isTrendExpanded = false;
  final PageController _trendPageController = PageController();
  bool _isListView = false;
  bool _isSubCategoryExpanded = false;

  final List<Map<String, dynamic>> _categories = [
    {'icon': '🔥', 'name': '전체', 'desc': '실시간 전체 모임 & 트렌드 큐레이션'},
    {'icon': '⚡', 'name': '오늘 번개', 'desc': '오늘 밤·이번 주말 당장 만나는 당일 오프라인 번개'},
    {'icon': '☕', 'name': '취향 아지트', 'desc': '취미, 공연, 전시, 보드게임, 독서 등 취향 기반 모임'},
    {'icon': '🏃‍♂️', 'name': '라이프 메이트', 'desc': '1인 가구, 동성 친구, 일상 액티비티 생활 밀착형 모임'},
  ];

  static const Map<String, List<String>> _officialSubCategories = {
    '오늘 번개': ['혼술바동행', '불금코노·술', '맛집털기', '오늘번개', '심야드라이브', '야식팟'],
    '취향 아지트': ['공연·전시', '카페·디저트', '보드게임·방탈출', '북카페·독서', 'LP청음', '원데이클래스'],
    '라이프 메이트': ['러닝·운동', '1인가구장보기/소분', '동성캠핑', '동네산책', '헬스메이트', '반려동물산책'],
  };

  // 전국 시·도 및 읍면동 핫스팟 리스트
  static const Map<String, List<String>> _nationwideRegions = {
    '서울': [
      '마포구 서교동', '마포구 연남동', '마포구 망원동', '마포구 합정동',
      '성동구 성수동', '용산구 한남동', '용산구 이태원동', '강남구 신사동',
      '강남구 역삼동', '송파구 잠실동', '영등포구 여의도동', '중구 을지로동',
      '종로구 익선동', '광진구 자양동(건대)',
    ],
    '경기/인천': [
      '성남시 분당구 판교동', '성남시 분당구 정자동', '수원시 영통구 광교동',
      '고양시 일산동구 장항동', '인천 연수구 송도동', '하남시 미사동',
      '용인시 수지구 풍덕천동', '안양시 동안구 평촌동', '부천시 원미구 중동',
    ],
    '부산/경상': [
      '부산 해운대구 우동', '부산 해운대구 중동', '부산 부산진구 전포동',
      '부산 수영구 광안동', '대구 수성구 범어동', '대구 중구 동성로',
      '울산 남구 삼산동', '창원시 성산구 상남동',
    ],
    '대전/충청': [
      '대전 유성구 봉명동', '대전 서구 둔산동', '세종시 나성동',
      '청주시 상당구 성안동', '천안시 서북구 불당동',
    ],
    '광주/전라': [
      // 전남 여수시 (전역 정밀 지원)
      '여수시 학동', '여수시 웅천동', '여수시 여서동', '여수시 문수동',
      '여수시 신월동', '여수시 교동(이순신광장)', '여수시 돌산읍',
      '여수시 소라면', '여수시 화장동', '여수시 봉산동(게장거리)',
      '여수시 덕충동(엑스포역)', '여수시 미평동(전남대)', '여수시 국동',
      // 전남 순천시 / 광양시 / 목포시 / 나주시
      '순천시 조례동', '순천시 연향동', '순천시 신대지구', '순천시 중앙동',
      '광양시 중마동', '광양시 광영동',
      '목포시 하당동', '목포시 평화광장(상동)', '목포시 남악',
      '나주시 빛가람동(혁신도시)',
      // 전북 전주시 / 익산시 / 군산시
      '전주시 완산구 효자동', '전주시 덕진구 송천동', '전주시 완산구 고사동(객사)',
      '전주시 덕진구 혁신도시', '익산시 영등동', '군산시 수송동',
      // 광주광역시
      '광주 서구 상무동', '광주 동구 동명동', '광주 광산구 수완동',
      '광주 남구 봉선동', '광주 북구 용봉동(전남대)', '광주 광산구 첨단동',
    ],
    '강원/제주': [
      '강릉시 교동', '속초시 조양동', '춘천시 효자동',
      '제주시 노형동', '제주시 연동', '제주시 아라동', '서귀포시 중문동',
    ],
  };

  void _showLocationPickerBottomSheet() {
    String searchQuery = '';
    String selectedRegionTab = '서울';
    bool isGpsLocating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          // 검색 필터링된 리스트
          List<String> displayedList = [];
          if (searchQuery.trim().isNotEmpty) {
            final q = searchQuery.trim().toLowerCase();
            for (var regionList in _nationwideRegions.values) {
              for (var dong in regionList) {
                if (dong.toLowerCase().contains(q)) {
                  displayedList.add(dong);
                }
              }
            }
          } else {
            displayedList = _nationwideRegions[selectedRegionTab] ?? [];
          }

          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(color: const Color(0xFFE5E5EA), borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text('우리 동네 설정', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFFF0EB), borderRadius: BorderRadius.circular(8)),
                          child: Text('전국 지원', style: TextStyle(color: coralAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('내 위치를 공유하거나 원하는 동네를 검색해보세요.', style: TextStyle(fontSize: 13, color: textSecondary)),
                    const SizedBox(height: 16),

                    // 1. GPS 현재 위치로 찾기 Button (실제 GPS + 역지오코딩 연동)
                    GestureDetector(
                      onTap: isGpsLocating
                          ? null
                          : () async {
                              setModalState(() => isGpsLocating = true);
                              final detected = await LocationHelper.getCurrentDongName();
                              setModalState(() => isGpsLocating = false);

                              if (detected != null && detected.isNotEmpty) {
                                setState(() {
                                  _currentLocation = detected;
                                });
                                globalData.updateLocation(detected);
                                try {
                                  FirebaseFirestore.instance.collection('users').doc(globalData.activeUserId).set({
                                    'location': detected,
                                    'updatedAt': FieldValue.serverTimestamp(),
                                  }, SetOptions(merge: true));
                                } catch (_) {}
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.my_location, color: Colors.white, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text('📍 내 현재 위치 자동 할당 완료: $detected')),
                                      ],
                                    ),
                                    backgroundColor: coralAccent,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('⚠️ 위치 권한을 확인해주시거나 동네를 직접 검색해주세요.')),
                                );
                              }
                            },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF4EE), Color(0xFFFFECE5)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: coralAccent.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isGpsLocating)
                              const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF5E36)))
                            else
                              Icon(Icons.my_location, color: coralAccent, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              isGpsLocating ? 'GPS 위치 확인 및 동네 분석 중...' : '현재 위치로 동네 자동 찾기 (GPS 연동)',
                              style: TextStyle(color: coralAccent, fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 2. 동·읍·면 검색 TextField
                    TextField(
                      onChanged: (val) {
                        setModalState(() {
                          searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: '읍·면·동 검색 (예: 판교, 해운대, 서교, 둔산동)',
                        hintStyle: TextStyle(fontSize: 13, color: textSecondary),
                        prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF8E8E93)),
                        filled: true,
                        fillColor: surfaceColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 3. 지역 탭 (검색 중이 아닐 때)
                    if (searchQuery.trim().isEmpty)
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _nationwideRegions.keys.map((reg) {
                            final isSel = selectedRegionTab == reg;
                            return GestureDetector(
                              onTap: () => setModalState(() => selectedRegionTab = reg),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFF1E1E24) : surfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  reg,
                                  style: TextStyle(
                                    color: isSel ? Colors.white : textPrimary,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    const SizedBox(height: 10),

                    // 4. 동네 목록 List
                    Expanded(
                      child: displayedList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 40, color: textSecondary),
                                  const SizedBox(height: 8),
                                  Text('\'$searchQuery\' 검색 결과가 없습니다.', style: TextStyle(color: textSecondary, fontSize: 13)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: displayedList.length,
                              itemBuilder: (context, idx) {
                                final dong = displayedList[idx];
                                final isSelected = dong == _currentLocation;
                                return ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  leading: Icon(
                                    Icons.location_on,
                                    color: isSelected ? coralAccent : const Color(0xFFC7C7CC),
                                    size: 20,
                                  ),
                                  title: Text(
                                    dong,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                      color: isSelected ? coralAccent : textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(Icons.check_circle, color: coralAccent, size: 20)
                                      : null,
                                  onTap: () {
                                    setState(() => _currentLocation = dong);
                                    globalData.updateLocation(dong);
                                    try {
                                      FirebaseFirestore.instance.collection('users').doc(globalData.activeUserId).set({
                                        'location': dong,
                                        'updatedAt': FieldValue.serverTimestamp(),
                                      }, SetOptions(merge: true));
                                    } catch (_) {}
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('📍 $dong(으)로 동네를 변경했어요')),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _homeDashboardTab = widget.initialTab;
    _seedDatabase();
  }

  Future<void> _seedDatabase() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('meetups').limit(1).get();
      if (snapshot.docs.isEmpty) {
        final dummyMeetups = [
          {
            'title': '불금엔 역시 코노! 스트레스 풀 분 🎤',
            'mainCategory': '문화 & 엔터',
            'category': '음악 & 노래방',
            'location': '합정역 수코인노래방',
            'date': '오늘 저녁 8시',
            'host': '고음불가',
            'manner': 38.5,
            'price': 'N빵',
            'members': '2/4',
            'isFemaleOnly': true,
            'transport': '각자 이동',
            'imageUrl': 'assets/images/cover_wine.jpg',
            'tags': ['불금엔 역시 코노', '음악 & 노래방', '놀줄아는', '스트레스해소', '코노'],
            'createdAt': FieldValue.serverTimestamp()
          },
          {
            'title': '주말 엽떡+마라탕 조지실 분 🔥',
            'mainCategory': '일상 & 푸드',
            'category': '동네 맛집 & 소셜 다이닝',
            'location': '홍대입구역 9번 출구',
            'date': '이번주 토요일 18:00',
            'host': '매운맛킬러',
            'manner': 41.2,
            'price': 'N빵',
            'members': '2/4',
            'isFemaleOnly': true,
            'transport': '각자 이동',
            'imageUrl': 'assets/images/cover_food.jpg',
            'tags': ['주말 마라탕&엽떡 모임', '동네 핫플 메뉴 털기', '소셜다이닝', '소소하게', '메이트', '홍대맛집', '동네찐친'],
            'createdAt': FieldValue.serverTimestamp()
          },
          {
            'title': '성수동 대형 에스프레소 바 & 감성 북카페 나들이 ☕📚',
            'mainCategory': '일상 & 푸드',
            'category': '카페 & 디저트',
            'location': '성동구 성수동 카페거리',
            'date': '일요일 14:00',
            'host': '성수동힙스터',
            'manner': 42.8,
            'price': '각자 결제',
            'members': '2/4',
            'isFemaleOnly': false,
            'transport': '성수역 집결',
            'imageUrl': 'assets/images/cover_cafe.jpg',
            'tags': ['북카페 겸 근교 드라이브', '동네 핫플 디저트 투어', '소소하게', '성수동', '디저트'],
            'createdAt': FieldValue.serverTimestamp()
          }
        ];
        for (var m in dummyMeetups) {
          await FirebaseFirestore.instance.collection('meetups').add(m);
        }
      }
    } catch (e) {
      debugPrint("Seed error: $e");
    }
  }

  Widget _buildLiveSpotCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFF25767), Color(0xFFFF707F)]),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('LIVE 4개', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900)),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '지금 내 주변 10분 컷 번개',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '⏱️ 10~30분 내 바로 만나는 실시간 즉석 팟',
                      style: TextStyle(fontSize: 12, color: coralAccent, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SoSoSpotScreen())),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F2),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFF8C6CD)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('전체 지도', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: coralAccent)),
                      Icon(Icons.chevron_right, size: 14, color: coralAccent),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final double cardWidth = ((constraints.maxWidth - 52) / 2).clamp(150.0, 260.0);
            return SizedBox(
              height: 168,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _liveSpots.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final spot = _liveSpots[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => SoSoSpotDetailScreen(spot: spot)));
                    },
                    child: Container(
                      width: cardWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFF8C6CD), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: coralAccent.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 상단 썸네일 + 실시간 타이머 뱃지
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: Image(
                                  image: appImg(spot['image']),
                                  width: cardWidth,
                                  height: 84,
                                  fit: BoxFit.cover,
                                ),
                              ),
                          Container(
                            height: 84,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              gradient: LinearGradient(
                                colors: [Colors.black.withOpacity(0.55), Colors.transparent],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5E36),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.alarm, size: 11, color: Colors.white),
                                  const SizedBox(width: 3),
                                  Text(
                                    spot['timeLeft'],
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                spot['distance'],
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // 하단 정보
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              spot['title'],
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 9,
                                      backgroundImage: appImg(spot['hostAvatar']),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      spot['host'],
                                      style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF4EB),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    '${spot['members']} 참여',
                                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFFD9480F)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ),
      ],
    );
  }

  List<Map<String, dynamic>> _buildMyNeighborhoodEvents(String currentLoc) {
    final cleanLoc = currentLoc.trim();
    final parts = cleanLoc.replaceAll('(', ' ').replaceAll(')', ' ').split(' ').where((s) => s.isNotEmpty).toList();
    final cityOrGu = parts.isNotEmpty ? parts[0] : cleanLoc;
    final dongName = parts.length >= 2 ? parts[1] : cityOrGu;

    if (cleanLoc.contains('여수')) {
      return [
        {
          'id': 'my_yeosu_01',
          'title': '$cleanLoc 수제 소금빵 & 신상 대형 베이커리 카페 오픈런',
          'category': '일상 & 푸드 > 카페 & 디저트',
          'location': '전남 $cleanLoc 카페거리',
          'tag': '🥐 $dongName 소금빵 핫플',
          'vibe': '소소하게',
          'poster': 'assets/images/cover_cafe.jpg',
          'period': '상시 · 주말 오전 오픈런',
          'rank': 1,
          'isMyNeighborhood': true,
          'isHotspot': true,
        },
        {
          'id': 'my_yeosu_02',
          'title': '여수 이순신광장 원조 딸기모찌 & 돌산 갓버터도나스 디저트 투어',
          'category': '일상 & 푸드 > 카페 & 디저트',
          'location': '전남 여수시 교동 이순신광장 ($cleanLoc 출발)',
          'tag': '🍓 여수 디저트 1위',
          'vibe': '소소하게',
          'poster': 'assets/images/cover_food.jpg',
          'period': '이번 주말 오후 2시',
          'rank': 2,
          'isMyNeighborhood': true,
          'isHotspot': true,
        },
        {
          'id': 'my_yeosu_03',
          'title': '여수 웅천해변 오션뷰 루프탑 브런치 & 카이막 카페 탐방',
          'category': '일상 & 푸드 > 카페 & 디저트',
          'location': '전남 여수시 웅천동 해변문화공원',
          'tag': '🌊 웅천 오션뷰 핫플',
          'vibe': '소소하게',
          'poster': 'assets/images/cover_cafe.jpg',
          'period': '상시 · 주말 브런치',
          'rank': 3,
          'isMyNeighborhood': true,
          'isHotspot': true,
        },
        {
          'id': 'my_yeosu_04',
          'title': '$cleanLoc 두바이 쫀득 쿠키(두쫀쿠) & 피스타치오 디저트 도장깨기',
          'category': '일상 & 푸드 > 카페 & 디저트',
          'location': '전남 $cleanLoc 디저트 골목',
          'tag': '🍪 $dongName 두쫀쿠',
          'vibe': '소소하게',
          'poster': 'assets/images/cover_cafe.jpg',
          'period': '상시 운영',
          'rank': 4,
          'isMyNeighborhood': true,
          'isHotspot': true,
        },
        {
          'id': 'my_yeosu_05',
          'title': '여수 소호동동다리 밤바다 야경 산책 & 5km 나이트 러닝 크루',
          'category': '문화 & 엔터 > 러닝 & 피트니스',
          'location': '전남 여수시 소호동 동동다리 ($cleanLoc 집결)',
          'tag': '🏃 여수 밤바다러닝',
          'vibe': '열정적인',
          'poster': 'assets/images/cover_running.jpg',
          'period': '매주 금·토 저녁 8시',
          'rank': 5,
          'isMyNeighborhood': true,
          'isHotspot': true,
        },
        {
          'id': 'my_yeosu_06',
          'title': '여수 학동·화장동·여서동 로컬 숙성회 & 하이볼 이자카야 미식 팟',
          'category': '일상 & 푸드 > 동네 술 한잔',
          'location': '전남 $cleanLoc 중심상가',
          'tag': '🍶 $dongName 로컬맛집',
          'vibe': '놀줄아는',
          'poster': 'assets/images/cover_wine.jpg',
          'period': '오늘·주말 저녁 7시 30분',
          'rank': 6,
          'isMyNeighborhood': true,
          'isHotspot': true,
        },
        {
          'id': 'my_yeosu_07',
          'title': '여수 해양공원 낭만포차 해물삼합 & 밤바다 거리 버스킹 직관',
          'category': '문화 & 엔터 > 페스티벌 & 공연',
          'location': '전남 여수시 중앙동 해양공원',
          'tag': '🎶 여수 밤바다버스킹',
          'vibe': '놀줄아는',
          'poster': 'assets/images/cover_wine.jpg',
          'period': '매주 금·토·일 밤',
          'rank': 7,
          'isMyNeighborhood': true,
        },
        {
          'id': 'my_yeosu_08',
          'title': '여수 봉산동 원조 간장·양념게장 정식 & 바다뷰 디저트 코스',
          'category': '일상 & 푸드 > 동네 맛집 & 소셜 다이닝',
          'location': '전남 여수시 봉산동 게장거리',
          'tag': '🦀 여수 미식투어',
          'vibe': '소소하게',
          'poster': 'assets/images/cover_food.jpg',
          'period': '주말 점심 12시',
          'rank': 8,
          'isMyNeighborhood': true,
          'isHotspot': true,
        },
        {
          'id': 'my_yeosu_09',
          'title': '여수 돌산읍 무슬목 감성 오션뷰 카페 & 일몰 사진 출사 모임',
          'category': '문화 & 엔터 > 전시 & 팝업스토어',
          'location': '전남 여수시 돌산읍 무슬목',
          'tag': '📸 돌산 오션뷰출사',
          'vibe': '소소하게',
          'poster': 'assets/images/cover_cafe.jpg',
          'period': '이번 주 토요일 오후 4시',
          'rank': 9,
          'isMyNeighborhood': true,
          'isHotspot': true,
        },
        {
          'id': 'my_yeosu_10',
          'title': '여수 예울마루 현대미술 전시 관람 & 장도 예술의섬 산책',
          'category': '문화 & 엔터 > 전시 & 팝업스토어',
          'location': '전남 여수시 시전동 예울마루 ($cleanLoc 인접)',
          'tag': '🖼️ 예울마루 전시',
          'vibe': '소소하게',
          'poster': 'assets/images/cover_cafe.jpg',
          'period': '상시 전시 · 주말 모임',
          'rank': 10,
          'isMyNeighborhood': true,
          'isHotspot': true,
        },
        {
          'id': 'my_yeosu_11',
          'title': '$cleanLoc 신상 보드게임 카페 & 추리 방탈출 도장깨기 팟',
          'category': '문화 & 엔터 > 보드게임·방탈출',
          'location': '전남 $cleanLoc 보드게임 아지트',
          'tag': '🎲 $dongName 보드게임',
          'vibe': '놀줄아는',
          'poster': 'assets/images/cover_food.jpg',
          'period': '주말 오후 3시',
          'rank': 11,
          'isMyNeighborhood': true,
        },
        {
          'id': 'my_yeosu_12',
          'title': '2026 여수 밤바다 불꽃축제 & 문화의 달 페스티벌 동행 메이트',
          'category': '문화 & 엔터 > 페스티벌 & 공연',
          'location': '전남 여수시 이순신광장·박람회장 일대',
          'tag': '🎆 여수 대표축제',
          'vibe': '놀줄아는',
          'poster': 'assets/images/cover_wine.jpg',
          'period': '여수 문화축제 시즌',
          'rank': 12,
          'isMyNeighborhood': true,
        },
      ];
    }

    return [
      {
        'id': 'my_loc_01_$cleanLoc',
        'title': '망원·$dongName 겉바속촉 수제 소금빵 & 화덕 쌀베이글 오픈런 투어',
        'category': '일상 & 푸드 > 카페 & 디저트',
        'location': '$cleanLoc 베이커리 거리',
        'tag': '🥐 $dongName 소금빵 핫플',
        'vibe': '소소하게',
        'poster': 'assets/images/cover_cafe.jpg',
        'period': '상시 · 주말 오픈런',
        'rank': 1,
        'isMyNeighborhood': true,
        'isHotspot': true,
      },
      {
        'id': 'my_loc_02_$cleanLoc',
        'title': '$cleanLoc 두바이 쫀득 쿠키(두쫀쿠) & 피스타치오 디저트 카페 탐방',
        'category': '일상 & 푸드 > 카페 & 디저트',
        'location': '$cleanLoc 카페거리',
        'tag': '🍪 $dongName 두쫀쿠 1위',
        'vibe': '소소하게',
        'poster': 'assets/images/cover_food.jpg',
        'period': '상시 운영',
        'rank': 2,
        'isMyNeighborhood': true,
        'isHotspot': true,
      },
      {
        'id': 'my_loc_03_$cleanLoc',
        'title': '$cleanLoc 신상 브랜드 팝업스토어 & 플리마켓 주말 도장깨기',
        'category': '문화 & 엔터 > 전시 & 팝업스토어',
        'location': '$cleanLoc 메인 스트리트',
        'tag': '✨ $dongName 팝업·핫플',
        'vibe': '놀줄아는',
        'poster': 'assets/images/cover_cafe.jpg',
        'period': '이번 주말 오후 2시',
        'rank': 3,
        'isMyNeighborhood': true,
        'isHotspot': true,
      },
      {
        'id': 'my_loc_04_$cleanLoc',
        'title': '$cleanLoc 골목 감성 LP 바이닐 바 & 내추럴 와인 시음 모임',
        'category': '일상 & 푸드 > 동네 술 한잔',
        'location': '$cleanLoc 로데오·문화거리',
        'tag': '🍷 $dongName LP·와인바',
        'vibe': '놀줄아는',
        'poster': 'assets/images/cover_wine.jpg',
        'period': '매주 금·토 저녁 7시 30분',
        'rank': 4,
        'isMyNeighborhood': true,
        'isHotspot': true,
      },
      {
        'id': 'my_loc_05_$cleanLoc',
        'title': '$cleanLoc 저녁 노을 5km 러닝 크루 & 야간 산책 번개',
        'category': '문화 & 엔터 > 러닝 & 피트니스',
        'location': '$cleanLoc 근린공원·산책로',
        'tag': '🏃 $dongName 나이트런',
        'vibe': '열정적인',
        'poster': 'assets/images/cover_running.jpg',
        'period': '매주 수·일 저녁 8시',
        'rank': 5,
        'isMyNeighborhood': true,
        'isHotspot': true,
      },
      {
        'id': 'my_loc_06_$cleanLoc',
        'title': '$cleanLoc 카이막·그리스요거트 & 유럽풍 테라스 브런치 모임',
        'category': '일상 & 푸드 > 카페 & 디저트',
        'location': '$cleanLoc 브런치 골목',
        'tag': '🥞 $dongName 브런치 핫플',
        'vibe': '소소하게',
        'poster': 'assets/images/cover_cafe.jpg',
        'period': '주말 오전 11시 30분',
        'rank': 6,
        'isMyNeighborhood': true,
        'isHotspot': true,
      },
      {
        'id': 'my_loc_07_$cleanLoc',
        'title': '$cleanLoc 줄 서서 먹는 로컬 노포 & 숯불 화로구이 미식 팟',
        'category': '일상 & 푸드 > 동네 맛집 & 소셜 다이닝',
        'location': '$cleanLoc 먹자골목',
        'tag': '🍲 $dongName 노포맛집',
        'vibe': '놀줄아는',
        'poster': 'assets/images/cover_food.jpg',
        'period': '금요일 저녁 7시',
        'rank': 7,
        'isMyNeighborhood': true,
        'isHotspot': true,
      },
      {
        'id': 'my_loc_08_$cleanLoc',
        'title': '$cleanLoc 독립서점 심야 책맥 & 스페셜티 핸드드립 커피 모임',
        'category': '문화 & 엔터 > 북카페·독서',
        'location': '$cleanLoc 북카페 거리',
        'tag': '📚 $dongName 독립서점',
        'vibe': '소소하게',
        'poster': 'assets/images/cover_cafe.jpg',
        'period': '토요일 오후 4시',
        'rank': 8,
        'isMyNeighborhood': true,
        'isHotspot': true,
      },
      {
        'id': 'my_loc_09_$cleanLoc',
        'title': '$cleanLoc 공방 시그니처 향수 조향 & 터프팅 주말 원데이 클래스',
        'category': '문화 & 엔터 > 원데이 클래스',
        'location': '$cleanLoc 공방거리',
        'tag': '🎨 $dongName 원데이클래스',
        'vibe': '소소하게',
        'poster': 'assets/images/cover_wine.jpg',
        'period': '주말 오후 2시',
        'rank': 9,
        'isMyNeighborhood': true,
        'isHotspot': true,
      },
      {
        'id': 'my_loc_10_$cleanLoc',
        'title': '$cleanLoc 야외 거리 버스킹 공연 직관 & 수제맥주 피크닉',
        'category': '문화 & 엔터 > 페스티벌 & 공연',
        'location': '$cleanLoc 문화광장',
        'tag': '🎶 $dongName 거리버스킹',
        'vibe': '놀줄아는',
        'poster': 'assets/images/cover_wine.jpg',
        'period': '주말 저녁 6시',
        'rank': 10,
        'isMyNeighborhood': true,
      },
      {
        'id': 'my_loc_11_$cleanLoc',
        'title': '$cleanLoc 전략 보드게임 & 공포/추리 방탈출 도장깨기 모임',
        'category': '문화 & 엔터 > 보드게임·방탈출',
        'location': '$cleanLoc 중심상가',
        'tag': '🎲 $dongName 보드게임',
        'vibe': '놀줄아는',
        'poster': 'assets/images/cover_food.jpg',
        'period': '토·일 오후 3시',
        'rank': 11,
        'isMyNeighborhood': true,
      },
      {
        'id': 'my_loc_12_$cleanLoc',
        'title': '$cityOrGu 청년 로컬 페스티벌 & 야시장 푸드트럭 야식 투어',
        'category': '문화 & 엔터 > 페스티벌 & 공연',
        'location': '$cleanLoc 중앙광장 일원',
        'tag': '🎪 $cityOrGu 지역축제',
        'vibe': '놀줄아는',
        'poster': 'assets/images/cover_food.jpg',
        'period': '이번 달 주말 상시',
        'rank': 12,
        'isMyNeighborhood': true,
      },
    ];
  }

  List<Map<String, dynamic>> _getGuaranteedRichCategoryPool() {
    return [
      // 뮤지컬 10개 보장용 시드
      {
        'id': 'mus_guaranteed_01',
        'title': '뮤지컬 지킬앤하이드 (Jekyll & Hyde) 20주년 스페셜',
        'category': '문화 & 엔터 > 뮤지컬 & 오페라',
        'location': '블루스퀘어 신한카드홀',
        'tag': '뮤지컬 TOP 🔥',
        'vibe': '놀줄아는',
        'poster': 'assets/images/cover_wine.jpg',
        'period': '2026.11.20~2027.05.10',
        'rank': 11,
      },
      {
        'id': 'mus_guaranteed_02',
        'title': '뮤지컬 알라딘 (ALADDIN) 한국 초연 오리지널 스케일',
        'category': '문화 & 엔터 > 뮤지컬 & 오페라',
        'location': '샤롯데씨어터 (잠실)',
        'tag': '뮤지컬 예매 1위 ✨',
        'vibe': '놀줄아는',
        'poster': 'assets/images/cover_wine.jpg',
        'period': '2026.11.22~2027.06.22',
        'rank': 12,
      },
      {
        'id': 'mus_guaranteed_03',
        'title': '뮤지컬 시카고 (CHICAGO) 브로드웨이 명작 관람 팟',
        'category': '문화 & 엔터 > 뮤지컬 & 오페라',
        'location': '디큐브 링크아트센터',
        'tag': '뮤지컬 명작 🎭',
        'vibe': '놀줄아는',
        'poster': 'assets/images/cover_wine.jpg',
        'period': '2026.10.15~2027.02.28',
        'rank': 13,
      },
      {
        'id': 'mus_guaranteed_04',
        'title': '뮤지컬 킹키부츠 (KINKY BOOTS) 텐션 폭발 커튼콜 동행',
        'category': '문화 & 엔터 > 뮤지컬 & 오페라',
        'location': '블루스퀘어 신한카드홀',
        'tag': '뮤지컬 인기 👠',
        'vibe': '놀줄아는',
        'poster': 'assets/images/cover_wine.jpg',
        'period': '2026.10.10~2027.01.15',
        'rank': 14,
      },
      {
        'id': 'mus_guaranteed_05',
        'title': '뮤지컬 위키드 (WICKED) 내한 & 한국어 시즌 관람 모임',
        'category': '문화 & 엔터 > 뮤지컬 & 오페라',
        'location': '예술의전당 오페라극장',
        'tag': '뮤지컬 대작 💚',
        'vibe': '놀줄아는',
        'poster': 'assets/images/cover_wine.jpg',
        'period': '2026.12.01~2027.03.30',
        'rank': 15,
      },
      {
        'id': 'mus_guaranteed_06',
        'title': '뮤지컬 프랑켄슈타인 10주년 기념 공연 동행 모집',
        'category': '문화 & 엔터 > 뮤지컬 & 오페라',
        'location': '블루스퀘어 신한카드홀',
        'tag': '뮤지컬 화제작 ⚡',
        'vibe': '놀줄아는',
        'poster': 'assets/images/cover_wine.jpg',
        'period': '2026.10.05~2026.12.28',
        'rank': 16,
      },
      {
        'id': 'mus_guaranteed_07',
        'title': '뮤지컬 오페라의 유령 (The Phantom of the Opera) 전국 투어',
        'category': '문화 & 엔터 > 뮤지컬 & 오페라',
        'location': '샤롯데씨어터 / 부산 드림씨어터',
        'tag': '뮤지컬 레전드 🌹',
        'vibe': '놀줄아는',
        'poster': 'assets/images/cover_wine.jpg',
        'period': '2026.11.01~2027.04.15',
        'rank': 17,
      },
      // 콘서트 6개 보장용 시드 (2번째 카드 짤림 방지 및 100:100 대칭 페어 보장)
      {
        'id': 'con_guaranteed_01',
        'title': 'TOMORROW X TOGETHER WORLD TOUR 콘서트 동행 팟',
        'category': '문화 & 엔터 > 페스티벌 & 공연',
        'location': 'KSPO DOME (올림픽체조경기장)',
        'tag': '콘서트 1위 ⚡',
        'vibe': '놀줄아는',
        'poster': 'assets/images/cover_wine.jpg',
        'period': '2026.11.14~2026.11.16',
        'rank': 3,
      },
      {
        'id': 'con_guaranteed_02',
        'title': 'DAVICHI CONCERT: IN OUR SCENES 감성 라이브 관람',
        'category': '문화 & 엔터 > 페스티벌 & 공연',
        'location': '올림픽공원 KSPO DOME',
        'tag': '콘서트 인기 🎤',
        'vibe': '놀줄아는',
        'poster': 'assets/images/cover_wine.jpg',
        'period': '2026.12.12~2026.12.13',
        'rank': 4,
      },
      {
        'id': 'con_guaranteed_03',
        'title': 'DAY6 (데이식스) 3RD WORLD TOUR 잠실 콘서트 팟',
        'category': '문화 & 엔터 > 페스티벌 & 공연',
        'location': '잠실실내체육관',
        'tag': '콘서트 화제 🎸',
        'vibe': '놀줄아는',
        'poster': 'assets/images/cover_wine.jpg',
        'period': '2026.12.20~2026.12.22',
        'rank': 5,
      },
      {
        'id': 'con_guaranteed_04',
        'title': '성시경 연말 콘서트 따뜻한 발라드 귀호강 동행',
        'category': '문화 & 엔터 > 페스티벌 & 공연',
        'location': 'KSPO DOME (올림픽공원)',
        'tag': '콘서트 추천 🎶',
        'vibe': '소소하게',
        'poster': 'assets/images/cover_wine.jpg',
        'period': '2026.12.27~2026.12.29',
        'rank': 6,
      },
      {
        'id': 'con_guaranteed_05',
        'title': '10CM 단독 콘서트 겨울밤 힐링 어쿠스틱 라이브',
        'category': '문화 & 엔터 > 페스티벌 & 공연',
        'location': '올림픽홀',
        'tag': '콘서트 힐링 ☕',
        'vibe': '소소하게',
        'poster': 'assets/images/cover_wine.jpg',
        'period': '2026.11.28~2026.11.30',
        'rank': 7,
      },
      {
        'id': 'con_guaranteed_06',
        'title': '아이유 (IU) 월드투어 앙코르 콘서트 상암 동행 모임',
        'category': '문화 & 엔터 > 페스티벌 & 공연',
        'location': '서울월드컵경기장',
        'tag': '콘서트 레전드 ✨',
        'vibe': '놀줄아는',
        'poster': 'assets/images/cover_wine.jpg',
        'period': '2026.10.20~2026.10.22',
        'rank': 8,
      },
      // 핫플·팝업 (트렌드 음식 & 지역 대표 핫플) 10개 이상 보장용 시드
      {
        'id': 'hot_guaranteed_01',
        'title': '망원동 겉바속촉 소금빵 & 수제 베이글 베이커리 오픈런 투어',
        'category': '일상 & 푸드 > 카페 & 디저트',
        'location': '서울 마포구 망원동',
        'tag': '🥐 망원 소금빵 핫플',
        'vibe': '소소하게',
        'poster': 'assets/images/cover_cafe.jpg',
        'period': '상시 · 주말 오픈런',
        'rank': 18,
        'isHotspot': true,
      },
      {
        'id': 'hot_guaranteed_02',
        'title': '연남동 두바이 쫀득 쿠키(두쫀쿠) & 피스타치오 디저트 도장깨기',
        'category': '일상 & 푸드 > 카페 & 디저트',
        'location': '서울 마포구 연남동',
        'tag': '🍪 연남 두쫀쿠 1위',
        'vibe': '소소하게',
        'poster': 'assets/images/cover_food.jpg',
        'period': '상시 운영',
        'rank': 19,
        'isHotspot': true,
      },
      {
        'id': 'hot_guaranteed_03',
        'title': '성수동 연무장길 뷰티·패션 신상 팝업스토어 주말 투어',
        'category': '문화 & 엔터 > 전시 & 팝업스토어',
        'location': '서울 성동구 성수동 연무장길',
        'tag': '✨ 성수 팝업 1위',
        'vibe': '놀줄아는',
        'poster': 'assets/images/cover_cafe.jpg',
        'period': '이번 주말 오후 2시',
        'rank': 20,
        'isHotspot': true,
      },
      {
        'id': 'hot_guaranteed_04',
        'title': '성수 자연도 소금빵 & 카이막 스페셜티 카페 웨이팅 팟',
        'category': '일상 & 푸드 > 카페 & 디저트',
        'location': '서울 성동구 성수동 카페거리',
        'tag': '🥐 성수 디저트 핫플',
        'vibe': '소소하게',
        'poster': 'assets/images/cover_food.jpg',
        'period': '상시 운영',
        'rank': 21,
        'isHotspot': true,
      },
      {
        'id': 'hot_guaranteed_05',
        'title': '여의도 더현대 서울 지하1층 신상 디저트 팝업 도장깨기',
        'category': '문화 & 엔터 > 전시 & 팝업스토어',
        'location': '서울 영등포구 여의도 더현대 서울',
        'tag': '🍰 더현대 디저트팝업',
        'vibe': '소소하게',
        'poster': 'assets/images/cover_cafe.jpg',
        'period': '상시 · 주말 모임',
        'rank': 22,
        'isHotspot': true,
      },
      {
        'id': 'hot_guaranteed_06',
        'title': '을지로 힙당동 감성 LP 바이닐 바 & 수제 하이볼 투어',
        'category': '일상 & 푸드 > 동네 술 한잔',
        'location': '서울 중구 을지로3가',
        'tag': '🍷 을지로 LP·하이볼',
        'vibe': '놀줄아는',
        'poster': 'assets/images/cover_wine.jpg',
        'period': '금·토 저녁 7시 30분',
        'rank': 23,
        'isHotspot': true,
      },
      {
        'id': 'hot_guaranteed_07',
        'title': '한남동·이태원 루프탑 에스프레소 바 & 수제 타르트 모임',
        'category': '일상 & 푸드 > 카페 & 디저트',
        'location': '서울 용산구 한남동 카페거리',
        'tag': '☕ 한남동 루프탑 핫플',
        'vibe': '소소하게',
        'poster': 'assets/images/cover_cafe.jpg',
        'period': '주말 오후 3시',
        'rank': 24,
        'isHotspot': true,
      },
      {
        'id': 'hot_guaranteed_08',
        'title': '여수 이순신광장 원조 딸기모찌 & 갓버터도나스 로컬 핫플 투어',
        'category': '일상 & 푸드 > 카페 & 디저트',
        'location': '전남 여수시 교동 이순신광장',
        'tag': '🍓 여수 디저트 핫플',
        'vibe': '소소하게',
        'poster': 'assets/images/cover_food.jpg',
        'period': '상시 · 주말 투어',
        'rank': 25,
        'isHotspot': true,
      },
      {
        'id': 'hot_guaranteed_09',
        'title': '해운대 해리단길 카이막·소금빵 & 오션뷰 브런치 카페 투어',
        'category': '일상 & 푸드 > 카페 & 디저트',
        'location': '부산 해운대구 우동 해리단길',
        'tag': '🌊 해운대 해리단길',
        'vibe': '소소하게',
        'poster': 'assets/images/cover_cafe.jpg',
        'period': '상시 · 주말 모임',
        'rank': 26,
        'isHotspot': true,
      },
      {
        'id': 'hot_guaranteed_10',
        'title': '판교 아브뉴프랑 & 정자동 카페거리 유럽풍 브런치 모임',
        'category': '일상 & 푸드 > 카페 & 디저트',
        'location': '경기 성남시 분당구 판교·정자동',
        'tag': '🥞 판교·분당 핫플',
        'vibe': '소소하게',
        'poster': 'assets/images/cover_cafe.jpg',
        'period': '주말 브런치',
        'rank': 27,
        'isHotspot': true,
      },
    ];
  }

  bool _isMyNeighborhoodEvent(Map<String, dynamic> item) {
    if (item['isMyNeighborhood'] == true) return true;
    final locTokens = _currentLocation
        .replaceAll('(', ' ')
        .replaceAll(')', ' ')
        .split(' ')
        .map((s) => s.trim())
        .where((s) => s.length >= 2)
        .toList();
    if (locTokens.isEmpty) return false;

    final primaryCity = locTokens.first;
    final basePrimary = (primaryCity.endsWith('시') || primaryCity.endsWith('구')) && primaryCity.length > 2
        ? primaryCity.substring(0, primaryCity.length - 1)
        : primaryCity;

    final combined = [
      item['location'] ?? '',
      item['venue'] ?? '',
      item['city'] ?? '',
      item['province'] ?? '',
      item['tag'] ?? '',
      item['title'] ?? '',
      ...(item['regionAliases'] is List ? (item['regionAliases'] as List) : const []),
    ].join(' ');

    return combined.contains(primaryCity) || (basePrimary.length >= 2 && combined.contains(basePrimary));
  }

  bool _matchesTrendFilter(Map<String, dynamic> item, String filter) {
    if (filter == '전체') return true;
    final cat = (item['category'] ?? '').toString();
    final tag = (item['tag'] ?? '').toString();
    final title = (item['title'] ?? '').toString();
    final isHotspot = item['isHotspot'] == true;

    if (filter == '📍 우리동네') {
      // 타 지역(예: 여수시인데 경기도 영통/일산)이 절대 섞이지 않도록 오직 내 동네(_currentLocation) 매칭 이벤트만 엄격 노출!
      return _isMyNeighborhoodEvent(item);
    } else if (filter == '콘서트') {
      return cat.contains('콘서트') || tag.contains('콘서트') || title.toUpperCase().contains('CONCERT') || title.contains('투어 콘서트');
    } else if (filter == '뮤지컬') {
      return cat.contains('뮤지컬') || tag.contains('뮤지컬') || title.contains('스위니토드') || title.contains('지킬') || title.contains('오페라') || title.contains('알라딘') || title.contains('시카고') || title.contains('위키드');
    } else if (filter == '페스티벌') {
      return cat.contains('페스티벌') || tag.contains('페스티벌') || tag.contains('대표축제') || tag.contains('지역축제') || title.toUpperCase().contains('FESTIVAL') || title.contains('범음악제') || title.contains('페스티벌') || title.contains('불꽃축제');
    } else if (filter == '핫플·팝업') {
      return isHotspot || cat.contains('다이닝') || cat.contains('팝업') || cat.contains('LP') || cat.contains('카페') || tag.contains('핫플') || tag.contains('소금빵') || tag.contains('두쫀쿠') || tag.contains('SNS');
    }
    return true;
  }

  void _showAllTrendsBottomSheet(BuildContext context, List<Map<String, dynamic>> items) {
    String modalFilter = _selectedTrendCategory;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final modalFiltered = items.where((it) => _matchesTrendFilter(it, modalFilter)).toList();
          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5EA),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        const Text('🎭', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '실시간 공연·뮤지컬 & 트렌드 핫플',
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textPrimary),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF0EB),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${items.length}개',
                                      style: TextStyle(color: coralAccent, fontSize: 11, fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '원하는 이벤트를 선택해 바로 모임을 만들어보세요',
                                style: TextStyle(fontSize: 12, color: textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 22),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: ['전체', '📍 우리동네', '콘서트', '뮤지컬', '페스티벌', '핫플·팝업'].map((c) {
                        final isSel = modalFilter == c;
                        final count = items.where((it) => _matchesTrendFilter(it, c)).length;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() {
                                modalFilter = c;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFF221B1D) : const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSel ? const Color(0xFF221B1D) : const Color(0xFFEBEBF0),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    c,
                                    style: TextStyle(
                                      color: isSel ? Colors.white : const Color(0xFF635559),
                                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$count',
                                    style: TextStyle(
                                      color: isSel ? const Color(0xFFFFB4A8) : const Color(0xFF9E9EA7),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 20, thickness: 1, color: Color(0xFFF0F0F5)),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: modalFiltered.length,
                      separatorBuilder: (_, __) => const Divider(height: 20, thickness: 1, color: Color(0xFFF5F5FA)),
                      itemBuilder: (context, idx) {
                        final item = modalFiltered[idx];
                        final title = item['title']?.toString() ?? '';
                        final location = item['location']?.toString() ?? item['venue']?.toString() ?? '';
                        final category = item['category']?.toString() ?? '문화 & 엔터';
                        final tag = item['tag']?.toString() ?? '🔥 실시간';
                        final poster = item['poster']?.toString() ?? '';
                        final period = item['period']?.toString() ?? '상시 운영';
                        final rank = item['rank'] as int? ?? (idx + 1);

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EventDetailScreen(event: item),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFEBEBF0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        height: 105,
                                        child: Image(
                                          image: appImg(poster.isNotEmpty ? poster : 'assets/images/cover_food.jpg'),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Image.asset('assets/images/cover_wine.jpg', fit: BoxFit.cover),
                                        ),
                                      ),
                                      Positioned(
                                        top: 6,
                                        left: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: rank <= 3 ? coralAccent : const Color(0xFF1E1E24).withOpacity(0.85),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '$rank위',
                                            style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF0EB),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              tag,
                                              style: TextStyle(color: coralAccent, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              category,
                                              style: TextStyle(fontSize: 10.5, color: textSecondary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        title,
                                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: textPrimary, height: 1.25),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFFFF5E36)),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                              location,
                                              style: TextStyle(fontSize: 11, color: textSecondary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today_outlined, size: 11, color: textSecondary),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                              period,
                                              style: TextStyle(fontSize: 10.5, color: textSecondary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 32,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: coralAccent,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            final mainCat = category.contains('>') ? category.split('>')[0].trim() : '문화 & 엔터';
                                            final subCat = category.contains('>') ? category.split('>')[1].trim() : '페스티벌 & 공연';
                                            final finalVibe = item['vibe']?.toString() ?? '놀줄아는';

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => OOMUHostScreen(
                                                  initialTitle: '$title 같이 가실 분!',
                                                  initialLocation: location,
                                                  initialMainCategory: mainCat,
                                                  initialSubCategory: subCat,
                                                  initialCoverImageUrl: poster.isNotEmpty ? poster : 'assets/images/cover_food.jpg',
                                                  initialVibe: finalVibe,
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.add, size: 14),
                                              SizedBox(width: 4),
                                              Text('이 이벤트로 모임 만들기', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendMoreCard(BuildContext context, int totalCount, List<Map<String, dynamic>> items) {
    return GestureDetector(
      onTap: () => _showAllTrendsBottomSheet(context, items),
      child: Container(
        height: 340,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEBEBF0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0EB),
                shape: BoxShape.circle,
                border: Border.all(color: coralAccent.withOpacity(0.3)),
              ),
              child: Icon(Icons.grid_view_rounded, color: coralAccent, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              '전체 $totalCount개 이벤트\n한눈에 모두보기',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEBEBF0)),
              ),
              child: Text(
                '더보기 열기 >',
                style: TextStyle(fontSize: 11, color: coralAccent, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleTrendCard(BuildContext context, Map<String, dynamic> item, int index) {
    final title = item['title']?.toString() ?? '';
    final location = item['location']?.toString() ?? item['venue']?.toString() ?? '';
    final category = item['category']?.toString() ?? '문화 & 엔터';
    final tag = item['tag']?.toString() ?? '🔥 실시간 트렌드';
    final poster = item['poster']?.toString() ?? '';
    final period = item['period']?.toString() ?? '상시 운영';
    final rank = item['rank'] as int? ?? (index + 1);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailScreen(event: item),
          ),
        );
      },
      child: Container(
        height: 340,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEBEBF0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 포스터 영역
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
              child: Stack(
                children: [
                  SizedBox(
                    height: 132,
                    width: double.infinity,
                    child: Image(
                      image: appImg(poster.isNotEmpty ? poster : 'assets/images/cover_food.jpg'),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/cover_wine.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: rank <= 3 ? coralAccent : const Color(0xFF1E1E24).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 중단 텍스트 영역 (좌우 100:100 대칭 카드 내부에 제목 2줄 완전 노출)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: coralAccent),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 38,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        height: 1.32,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFFFF5E36)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(fontSize: 11, color: textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 11, color: textSecondary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          period,
                          style: TextStyle(fontSize: 10.5, color: textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            // 하단 버튼 영역 (좌우 대칭 카드 폭 안에 100% 온전히 들어감)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF0EB),
                    foregroundColor: coralAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                  onPressed: () {
                    final mainCat = category.contains('>') ? category.split('>')[0].trim() : '문화 & 엔터';
                    final subCat = category.contains('>') ? category.split('>')[1].trim() : '페스티벌 & 공연';
                    final finalVibe = item['vibe']?.toString() ?? '놀줄아는';

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OOMUHostScreen(
                          initialTitle: '$title 같이 가실 분!',
                          initialLocation: location,
                          initialMainCategory: mainCat,
                          initialSubCategory: subCat,
                          initialCoverImageUrl: poster.isNotEmpty ? poster : 'assets/images/cover_food.jpg',
                          initialVibe: finalVibe,
                        ),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, size: 14),
                      SizedBox(width: 4),
                      Text(
                        '+ 모임 만들기',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendCurationSection() {
    final List<Map<String, dynamic>> fallbackTrends = [
      {
        'id': 'fallback_kopis_1',
        'title': '스위니토드 (SWEENEY TODD)',
        'category': '문화 & 엔터 > 페스티벌 & 공연',
        'location': '디큐브 링크아트센터',
        'tag': '뮤지컬 1위 🔥',
        'vibe': '놀줄아는',
        'poster': 'https://wsrv.nl/?url=https%3A%2F%2Fwww.kopis.or.kr%2Fupload%2FpfmPoster%2FPF_PF303043_261012_171201.gif&w=600&q=85&output=jpg',
        'period': '2026.12.04~2027.05.02',
        'rank': 1,
      },
      {
        'id': 'fallback_trend_2',
        'title': '두바이 쫀득 쿠키(두쫀쿠) 카페 탐방',
        'category': '일상 & 푸드 > 카페 & 디저트',
        'location': '서울 마포구 연남동',
        'tag': '☕ SNS 핫플',
        'vibe': '소소하게',
        'poster': 'assets/images/cover_cafe.jpg',
        'period': '상시 운영',
        'rank': 2,
      },
      {
        'id': 'fallback_kopis_3',
        'title': 'DAVICHI CONCERT: IN OUR SCENES',
        'category': '문화 & 엔터 > 페스티벌 & 공연',
        'location': '올림픽공원 KSPO DOME',
        'tag': '콘서트 1위 ⚡',
        'vibe': '놀줄아는',
        'poster': 'https://wsrv.nl/?url=https%3A%2F%2Fwww.kopis.or.kr%2Fupload%2FpfmPoster%2FPF_PF302745_261007_145954.gif&w=600&q=85&output=jpg',
        'period': '2026.12.12~2026.12.13',
        'rank': 3,
      },
      {
        'id': 'fallback_trend_4',
        'title': '성수동 감성 팝업스토어 웨이팅 팟',
        'category': '문화 & 엔터 > 전시 & 팝업스토어',
        'location': '서울 성동구 성수동',
        'tag': '⚡ 핫플 투어',
        'vibe': '놀줄아는',
        'poster': 'assets/images/cover_food.jpg',
        'period': '주말 팟',
        'rank': 4,
      },
    ];

    Stream<QuerySnapshot>? trendStream;
    try {
      trendStream = FirebaseFirestore.instance.collection('trend_events').orderBy('rank').snapshots();
    } catch (_) {}

    return StreamBuilder<QuerySnapshot>(
      stream: trendStream,
      builder: (context, snapshot) {
        List<Map<String, dynamic>> rawItems = [];
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          rawItems = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .where((d) => d['isLocalCrawled'] != true)
              .toList();
        } else {
          rawItems = List<Map<String, dynamic>>.from(fallbackTrends);
        }

        final myLocalItems = _buildMyNeighborhoodEvents(_currentLocation);
        final guaranteedPool = _getGuaranteedRichCategoryPool();
        final Set<String> seenTitles = {};
        final List<Map<String, dynamic>> items = [];

        for (final it in [...myLocalItems, ...rawItems, ...guaranteedPool]) {
          final t = (it['title'] ?? '').toString().trim();
          if (t.isEmpty || seenTitles.contains(t)) continue;
          seenTitles.add(t);
          items.add(it);
        }

        final filteredItems = items.where((it) => _matchesTrendFilter(it, _selectedTrendCategory)).toList()

          ..sort((a, b) {

            final aLocal = _isMyNeighborhoodEvent(a) ? 0 : 1;

            final bLocal = _isMyNeighborhoodEvent(b) ? 0 : 1;

            if (aLocal != bLocal) return aLocal.compareTo(bLocal);

            final aRank = (a['rank'] as num?)?.toInt() ?? 999;

            final bRank = (b['rank'] as num?)?.toInt() ?? 999;

            return aRank.compareTo(bRank);

          });
        final int totalPages = (filteredItems.length / 2).ceil().clamp(1, 99);
        final int safePage = _trendPageIndex.clamp(0, totalPages - 1);

        // 펼침 모드일 때 보여줄 행(Row) 개수 계산
        final int expandedRowCount = (filteredItems.length / 2).ceil();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 헤더 영역 (당근/문토/오늘의집 스타일의 심플한 '전체보기 >' 텍스트 액션)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 28, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Text('🎭', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      '실시간 공연·뮤지컬 & 트렌드 핫플',
                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textPrimary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF0EB),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: coralAccent.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.bolt, size: 11, color: coralAccent),
                                        const SizedBox(width: 2),
                                        Text('LIVE', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: coralAccent)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '📍 내 동네($_currentLocation) 맞춤 행사 & 전국 트렌드로 모임 만들기',
                                style: TextStyle(fontSize: 11.5, color: textSecondary, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showAllTrendsBottomSheet(context, items),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '전체보기',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: textSecondary,
                            ),
                          ),
                          const SizedBox(width: 1),
                          Icon(Icons.chevron_right_rounded, size: 17, color: textSecondary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. 카테고리 칩 필터 바
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: ['전체', '📍 우리동네', '콘서트', '뮤지컬', '페스티벌', '핫플·팝업'].map((c) {
                    final bool isSel = _selectedTrendCategory == c;
                    final int count = items.where((it) => _matchesTrendFilter(it, c)).length;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTrendCategory = c;
                            _trendPageIndex = 0;
                            _isTrendExpanded = false;
                          });
                          if (_trendPageController.hasClients) {
                            _trendPageController.jumpToPage(0);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFF221B1D) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSel ? const Color(0xFF221B1D) : const Color(0xFFEBEBF0),
                              width: 1.1,
                            ),
                            boxShadow: isSel
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                c,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                  color: isSel ? Colors.white : const Color(0xFF635559),
                                ),
                              ),
                              if (count > 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '$count',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: isSel ? const Color(0xFFFFB4A8) : const Color(0xFF9E9EA7),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // 3. 본문: 기본 상태는 스냅 PageView (좌우 100:100 대칭 2열) + 슬림 도트 인디케이터,
            //    '더보기 ▾' 클릭 시 당근/오늘의집/무신사처럼 인피드 2열 그리드로 즉시 펼쳐짐!
            if (!_isTrendExpanded) ...[
              SizedBox(
                height: 342,
                child: PageView.builder(
                  controller: _trendPageController,
                  itemCount: totalPages,
                  onPageChanged: (page) {
                    setState(() => _trendPageIndex = page);
                  },
                  itemBuilder: (context, pageIdx) {
                    final int sIdx = pageIdx * 2;
                    final Map<String, dynamic>? lItem = sIdx < filteredItems.length ? filteredItems[sIdx] : null;
                    final Map<String, dynamic>? rItem = (sIdx + 1) < filteredItems.length ? filteredItems[sIdx + 1] : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: lItem != null
                                ? _buildSingleTrendCard(context, lItem, sIdx)
                                : _buildTrendMoreCard(context, items.length, items),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: rItem != null
                                ? _buildSingleTrendCard(context, rItem, sIdx + 1)
                                : _buildTrendMoreCard(context, items.length, items),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // 위피 / 문토 / 당근 스타일 미니멀 슬림 도트 인디케이터
              if (totalPages > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(totalPages, (dotIdx) {
                      final bool isActive = dotIdx == safePage;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _trendPageIndex = dotIdx);
                          if (_trendPageController.hasClients) {
                            _trendPageController.animateToPage(
                              dotIdx,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isActive ? 18 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isActive ? coralAccent : const Color(0xFFE0D8DA),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
            ] else ...[
              // 인라인 펼침 상태: 당근/무신사 스타일 2열 대칭 그리드 전체 노출
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: List.generate(expandedRowCount, (rowIdx) {
                    final int sIdx = rowIdx * 2;
                    final Map<String, dynamic>? lItem = sIdx < filteredItems.length ? filteredItems[sIdx] : null;
                    final Map<String, dynamic>? rItem = (sIdx + 1) < filteredItems.length ? filteredItems[sIdx + 1] : null;
                    return Padding(
                      padding: EdgeInsets.only(bottom: rowIdx < expandedRowCount - 1 ? 12 : 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: lItem != null
                                ? _buildSingleTrendCard(context, lItem, sIdx)
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: rItem != null
                                ? _buildSingleTrendCard(context, rItem, sIdx + 1)
                                : _buildTrendMoreCard(context, items.length, items),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],

            // 4. 당근마켓 / 무신사 / 오늘의집 표준 풀와이드 '더보기 ▾ / 접기 ▴' 버튼
            if (filteredItems.length > 2)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isTrendExpanded = !_isTrendExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEAE2E4), width: 1.1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isTrendExpanded
                              ? '${_selectedTrendCategory == '전체' ? '트렌드 이벤트' : _selectedTrendCategory} 접기'
                              : '${_selectedTrendCategory == '전체' ? '트렌드 이벤트' : _selectedTrendCategory} 더보기',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        if (!_isTrendExpanded) ...[
                          const SizedBox(width: 5),
                          Text(
                            '+${filteredItems.length - 2}',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: coralAccent,
                            ),
                          ),
                        ],
                        const SizedBox(width: 4),
                        Icon(
                          _isTrendExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSubCategoryBar() {
    final mainCatName = _categories[_selectedCategoryIndex]['name'] as String;
    final List<String> subList;
    if (_selectedCategoryIndex == 0) {
      subList = ['전체', '오늘번개', '맛집털기', '카페·디저트', '공연·전시', '보드게임·방탈출', '러닝·운동', '1인가구장보기/소분'];
    } else {
      subList = ['전체', ...(_officialSubCategories[mainCatName] ?? [])];
    }
    final desc = _categories[_selectedCategoryIndex]['desc'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (desc.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '💡 $desc',
                style: const TextStyle(fontSize: 12, color: Color(0xFF888899), fontWeight: FontWeight.w600),
              ),
            ),
          ],
          if (!_isSubCategoryExpanded)
            SizedBox(
              height: 32,
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: subList.length,
                      itemBuilder: (context, idx) {
                        final subName = subList[idx];
                        final isSubSelected = _selectedSubCategory == subName;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedSubCategory = subName),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSubSelected ? textPrimary : const Color(0xFFF9F9FB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSubSelected ? textPrimary : const Color(0xFFE5E5EA),
                              ),
                            ),
                            child: Text(
                              subName == '전체' ? '전체' : '#$subName',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSubSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSubSelected ? Colors.white : textSecondary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => _isSubCategoryExpanded = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EAEB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEFE4E6)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('+더보기', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF666677))),
                          Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF666677)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6F7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEFE4E6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$mainCatName 서브태그 선택', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textPrimary)),
                      GestureDetector(
                        onTap: () => setState(() => _isSubCategoryExpanded = false),
                        child: const Row(
                          children: [
                            Text('접기', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF666677))),
                            Icon(Icons.keyboard_arrow_up, size: 14, color: Color(0xFF666677)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: subList.map((subName) {
                      final isSubSelected = _selectedSubCategory == subName;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedSubCategory = subName;
                          _isSubCategoryExpanded = false;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSubSelected ? textPrimary : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSubSelected ? textPrimary : const Color(0xFFE5E5EA),
                            ),
                          ),
                          child: Text(
                            subName == '전체' ? '전체' : '#$subName',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSubSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSubSelected ? Colors.white : textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showFullCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5EA),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OOMU 카테고리 전체 체계도',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '대분류 ➔ 중분류 ➔ 소분류로 원하는 모임을 탐색하세요',
                            style: TextStyle(fontSize: 12, color: textSecondary),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      Text('📱 지금 내 상황 (분위기)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: OOMUCategoryData.vibes.map((v) {
                          final isSelected = _selectedVibe == v.title;
                          return ChoiceChip(
                            label: Text('${v.emoji} ${v.title}'),
                            selected: isSelected,
                            selectedColor: const Color(0xFFFFECE5),
                            labelStyle: TextStyle(
                              color: isSelected ? coralAccent : textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            onSelected: (val) {
                              setState(() {
                                _selectedVibe = val ? v.title : null;
                              });
                              Navigator.pop(ctx);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Text('🏷️ 전체 카테고리 목록 (대 - 중 - 소)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
                      const SizedBox(height: 12),
                      ...OOMUCategoryData.mainCategories.map((mainCat) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEBEBEF)),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              initiallyExpanded: true,
                              leading: Text(mainCat.icon, style: const TextStyle(fontSize: 22)),
                              title: Text(
                                mainCat.name,
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: textPrimary),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: mainCat.subCategories.map((sub) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                final catIdx = _categories.indexWhere((c) => c['name'] == mainCat.name);
                                                setState(() {
                                                  if (catIdx != -1) _selectedCategoryIndex = catIdx;
                                                  _selectedSubCategory = sub.name;
                                                });
                                                Navigator.pop(ctx);
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(Icons.subdirectory_arrow_right, size: 16, color: coralAccent),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    sub.name,
                                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              children: sub.exampleTags.map((tag) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    final catIdx = _categories.indexWhere((c) => c['name'] == mainCat.name);
                                                    setState(() {
                                                      if (catIdx != -1) _selectedCategoryIndex = catIdx;
                                                      _selectedSubCategory = sub.name;
                                                    });
                                                    Navigator.pop(ctx);
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(color: const Color(0xFFE4E4EB)),
                                                    ),
                                                    child: Text('#$tag', style: TextStyle(fontSize: 11, color: textSecondary)),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _matchesFilters(Map<String, dynamic> item) {
    // 1. Category Filter (대분류 & 서브태그)
    if (_selectedCategoryIndex > 0) {
      final selectedCat = _categories[_selectedCategoryIndex]['name'] as String;

      // [오늘 번개 기준]: 오늘 일정 (당일 만남, 오늘 날짜 기준 번개에 도래하는 것)
      if (selectedCat == '오늘 번개') {
        final dateStr = (item['date'] ?? '').toString();
        final bool isTodayDate = dateStr.contains('오늘') ||
                                 dateStr.contains('당일') ||
                                 dateStr.contains('즉시') ||
                                 dateStr.contains('26.10.20') ||
                                 dateStr.contains('2026.10.20') ||
                                 item['isLightning'] == true;
        final bool hasLightningKeyword = (item['category'] ?? '').toString().contains('번개') ||
                                         (item['title'] ?? '').toString().contains('번개') ||
                                         ((item['tags'] as List?)?.any((t) => t.toString().contains('번개')) ?? false);
        if (!isTodayDate && !hasLightningKeyword) {
          return false;
        }
      }

      final bool vibeMatch = OOMUCategoryData.matchesVibe(item, selectedCat);
      final bool filterMatch = OOMUCategoryData.matchesFilter(item, selectedCat, _selectedSubCategory);

      // 서브태그가 '전체'일 때는 바이브 매칭이나 필터 매칭 둘 중 하나라도 통과하면 OK
      if (_selectedSubCategory == '전체') {
        if (!vibeMatch && !filterMatch) return false;
      } else {
        // 특정 서브태그 선택 시 해당 태그 매칭 검사
        final cat = (item['category'] ?? '').toString();
        final mainCatField = (item['mainCategory'] ?? '').toString();
        final title = (item['title'] ?? '').toString();
        final desc = (item['description'] ?? '').toString();
        final tags = (item['tags'] as List?)?.map((t) => t.toString()).toList() ?? [];
        final allText = '$cat $mainCatField $title $desc ${tags.join(' ')}'.toLowerCase();
        
        final sub = _selectedSubCategory.toLowerCase();
        if (!allText.contains(sub) && !filterMatch) {
          return false;
        }
      }
    } else if (_selectedSubCategory != '전체') {
      if (!OOMUCategoryData.matchesFilter(item, '전체', _selectedSubCategory)) {
        return false;
      }
    }

    // 2. Vibe Filter (상황별 필터)
    if (_selectedVibe != null) {
      if (!OOMUCategoryData.matchesVibe(item, _selectedVibe!)) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F7),
      appBar: (_homeDashboardTab == 3 || _homeDashboardTab == 4)
          ? null
          : AppBar(
        backgroundColor: const Color(0xFFFAF6F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _showLocationPickerBottomSheet,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _currentLocation,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19, color: textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 22, color: textPrimary),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F7F5),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.2)),
                ),
                child: const Text(
                  '🟢 이웃 54명 접속 중',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0D9488)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExploreMapScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: Color(0xFFFFF0F2), shape: BoxShape.circle),
              child: const Icon(Icons.map_rounded, color: Color(0xFFF25767), size: 21),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: Color(0xFFFFF0F2), shape: BoxShape.circle),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.notifications_outlined, color: Color(0xFF221B1D), size: 22),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(radius: 3.5, backgroundColor: Color(0xFFF25767)),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen())),
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: Color(0xFFFFF0F2), shape: BoxShape.circle),
              child: Icon(Icons.tune, color: textPrimary, size: 20),
            ),
          )
        ],
      ),
      body: _homeDashboardTab == 0
          ? _buildMeetupDashboard()
          : (_homeDashboardTab == 1
              ? _buildCommunityDashboard()
              : (_homeDashboardTab == 2
                  ? _buildDatingDashboard()
                  : (_homeDashboardTab == 3
                      ? const ChatScreen(isEmbedded: true)
                      : const MyPageScreen(isEmbedded: true)))),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildMeetupDashboard() {
    return CustomScrollView(
      slivers: [
          // 1. Categories Tab (Horizontal Scroll) + Full Category Explorer Button
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 8, left: 20, right: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 42,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            itemCount: _categories.length + 1,
                            itemBuilder: (context, index) {
                              if (index == _categories.length) {
                                return GestureDetector(
                                  onTap: _showFullCategoryBottomSheet,
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF0F2),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(color: const Color(0xFFF8C6CD)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.grid_view_rounded, size: 15, color: coralAccent),
                                        const SizedBox(width: 5),
                                        Text(
                                          '전체보기',
                                          style: TextStyle(color: coralAccent, fontWeight: FontWeight.w700, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              bool isSelected = _selectedCategoryIndex == index;
                              return GestureDetector(
                                onTap: () => setState(() {
                                  _selectedCategoryIndex = index;
                                  _selectedSubCategory = '전체';
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? const LinearGradient(
                                            colors: [Color(0xFFFF707F), Color(0xFFE84355)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color: isSelected ? null : const Color(0xFFF3EAEB),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: isSelected ? Colors.transparent : const Color(0xFFEFE4E6),
                                      width: 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: coralAccent.withOpacity(0.32),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(_categories[index]['icon'], style: const TextStyle(fontSize: 14)),
                                      const SizedBox(width: 6),
                                      Text(
                                        _categories[index]['name'],
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : const Color(0xFF221B1D),
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 1-1. 서브태그 트레이 (특정 카테고리 진입 시에만 표시하여 메인 탭 중복/겹침 해결!)
                if (_selectedCategoryIndex > 0)
                  _buildSubCategoryBar(),
              ],
            ),
          ),

          // 2-0. 카카오맵 동네 실시간 지도 탐색 배너
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExploreMapScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: coralAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.map_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('내 주변 동네 지도 탐색', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5)),
                                SizedBox(width: 6),
                                Text('카카오맵', style: TextStyle(color: Color(0xFFFEE500), fontWeight: FontWeight.bold, fontSize: 11)),
                              ],
                            ),
                            SizedBox(height: 2),
                            Text('반경 1km 내 열려있는 번개 & 모임 한눈에 보기', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. 실시간 참여 알림 배너 (Oomu Prototype 규격 일원화)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF8C6CD)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Color(0xFFF25767), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '지금 $_currentLocation 이웃 54명이 모임을 보고 있어요',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFC83243)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text('실시간 인증', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFFC83243))),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_selectedVibe != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: coralAccent.withOpacity(0.35)),
                  ),
                  child: Row(
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 15)),
                      const SizedBox(width: 6),
                      Text(
                        '\'$_selectedVibe\' 분위기 모임 필터링 중',
                        style: TextStyle(fontWeight: FontWeight.bold, color: coralAccent, fontSize: 13),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _selectedVibe = null),
                        child: Row(
                          children: [
                            Icon(Icons.close, size: 14, color: coralAccent),
                            const SizedBox(width: 2),
                            Text('필터 해제', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: coralAccent)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 3. 탭별 특화 큐레이션 섹션 (소소스팟 & 트렌드 큐레이션)
          if (_selectedCategoryIndex == 0) ...[
            // [전체 탭]: 내 동네 맞춤 핫플 & 실시간 공연·뮤지컬 큐레이션 바로 노출
            SliverToBoxAdapter(
              child: _buildTrendCurationSection(),
            ),
          ] else if (_selectedCategoryIndex == 1) ...[
            // [⚡ 오늘 번개 탭]: 중복 검은 배너 및 공연 섹션 제거! -> 10분 컷 실시간 번개 캐러셀 직접 노출!
            SliverToBoxAdapter(
              child: _buildLiveSpotCarousel(),
            ),
          ] else if (_selectedCategoryIndex == 2) ...[
            // [☕ 취향 아지트 탭]: 공연·뮤지컬 & 트렌드 핫플 (KOPIS) 상단 배치!
            SliverToBoxAdapter(
              child: _buildTrendCurationSection(),
            ),
          ],

          // 4. 우리 동네 취향 모임 Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 26, bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCategoryIndex == 1
                              ? '${_currentLocation.split(' ')[0]}에서\n오늘 만나는 당일 번개'
                              : (_selectedCategoryIndex == 2
                                  ? '${_currentLocation.split(' ')[0]}의\n감성 취향 아지트'
                                  : (_selectedCategoryIndex == 3
                                      ? '${_currentLocation.split(' ')[0]}의\n일상 라이프 메이트'
                                      : '${_currentLocation.split(' ')[0]}에서\n지금 뜨는 모임')),
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary, height: 1.2),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _selectedVibe != null
                              ? '✨ \'$_selectedVibe\' 필터링 중'
                              : (_selectedCategoryIndex > 0
                                  ? '${_categories[_selectedCategoryIndex]['name']}${_selectedSubCategory != '전체' ? ' > #$_selectedSubCategory' : ''}'
                                  : (_selectedSubCategory != '전체'
                                      ? '#$_selectedSubCategory 모임'
                                      : (_selectedCategoryIndex == 1
                                          ? '⚡ 오늘 바로 합류 가능한 동네 번개 팟'
                                          : (_selectedCategoryIndex == 2
                                              ? '☕ 공연·전시·취미를 함께하는 아지트'
                                              : (_selectedCategoryIndex == 3
                                                  ? '🏃‍♂️ 1인 가구 일상 생활 공유 메이트'
                                                  : '실시간 참여 가능한 이웃 모임'))))),
                          style: TextStyle(
                            fontSize: 12.5,
                            color: _selectedCategoryIndex == 1 ? const Color(0xFFFF5E36) : coralAccent,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // [⊞ 블럭] [☰ 목록] 뷰 전환 토글
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EAEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEFE4E6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _isListView = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: !_isListView ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: !_isListView
                                  ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.grid_view_rounded, size: 14, color: !_isListView ? coralAccent : textSecondary),
                                const SizedBox(width: 3),
                                Text(
                                  '블럭',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: !_isListView ? FontWeight.w800 : FontWeight.w600,
                                    color: !_isListView ? coralAccent : textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        GestureDetector(
                          onTap: () => setState(() => _isListView = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: _isListView ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: _isListView
                                  ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.view_agenda_outlined, size: 14, color: _isListView ? coralAccent : textSecondary),
                                const SizedBox(width: 3),
                                Text(
                                  '목록',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: _isListView ? FontWeight.w800 : FontWeight.w600,
                                    color: _isListView ? coralAccent : textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. StreamBuilder / Fallback with Filtering
          SliverToBoxAdapter(
            child: _getMeetupStream() == null
                ? _buildDummyMeetups()
                : StreamBuilder<QuerySnapshot>(
                    stream: _getMeetupStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: Colors.black)));
                      }
                      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildDummyMeetups();
                      }

                      final filteredDocs = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return _matchesFilters(data);
                      }).toList();

                      if (filteredDocs.isEmpty) {
                        return _buildEmptyFilterState();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          var doc = filteredDocs[index];
                          var data = doc.data() as Map<String, dynamic>;
                          data['id'] = doc.id;
                          return _isListView ? _buildMeetupListRow(data) : _buildMeetupCard(data);
                        },
                      );
                    },
                  ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      );
  }

  Widget _buildCommunityDashboard() {
    final List<String> trendKeywords = [
      '#스위니토드',
      '#두바이쫀득쿠키',
      '#TXT월드투어',
      '#성수팝업웨이팅',
      '#을지로혼술바',
      '#마라탕릴레이',
    ];

    final List<String> simpleTopics = ['전체', '☕ 일상·수다', '🎭 공연·핫플', '🍰 맛집·카페', '❓ 동네질문'];

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('community_posts').snapshots(),
      builder: (context, snapshot) {
        final Map<String, Map<String, dynamic>> postMap = {};

        // 1. Initial 3-persona and preset posts
        for (var p in _communityPosts) {
          final pid = p['id']?.toString() ?? '';
          postMap[pid] = Map<String, dynamic>.from(p);
        }

        // 2. Real-time Firestore posts overlay & new user posts
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          for (var doc in snapshot.data!.docs) {
            final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
            final pid = data['id']?.toString() ?? doc.id;
            data['id'] = pid;

            final likedUsers = List<dynamic>.from(data['likedUserIds'] ?? []);
            final currentUid = globalData.activeUserId;
            data['isLiked'] = likedUsers.contains(currentUid) || likedUsers.contains('user_me_01');
            data['likes'] = likedUsers.isNotEmpty ? likedUsers.length : (data['likes'] ?? 0);

            if (postMap.containsKey(pid)) {
              postMap[pid]!.addAll(data);
            } else {
              postMap[pid] = data;
            }
          }
        }

        final allPosts = postMap.values.toList();
        allPosts.sort((a, b) {
          final aTime = a['createdAt'];
          final bTime = b['createdAt'];
          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime);
          }
          if (aTime is Timestamp) return -1;
          if (bTime is Timestamp) return 1;
          return 0;
        });

        final blocked = globalData.blockedUsers.value;
        final hiddenPosts = globalData.hiddenPostIds.value;

        final filteredPosts = allPosts.where((post) {
          final author = post['author'] ?? '';
          final postId = post['id'] ?? post['title'] ?? '';
          if (blocked.contains(author)) return false;
          if (hiddenPosts.contains(postId)) return false;

          if (_communityCategoryFilter != '전체') {
            if (_communityCategoryFilter == '☕ 일상·수다' && post['category'] != '동네 토크' && post['category'] != '일상') return false;
            if (_communityCategoryFilter == '🎭 공연·핫플' && post['category'] != '공연/전시' && post['category'] != '공연') return false;
            if (_communityCategoryFilter == '🍰 맛집·카페' && post['category'] != '맛집/카페' && post['category'] != '맛집') return false;
            if (_communityCategoryFilter == '❓ 동네질문' && post['category'] != '질문/추천' && post['category'] != '질문') return false;
          }
          if (_communityKeywordFilter != null && post['tag'] != _communityKeywordFilter!.replaceAll('#', '')) {
            return false;
          }
          return true;
        }).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 60),
      children: [
        // 1. 심플 원터치 글쓰기 바
        Container(
          margin: const EdgeInsets.fromLTRB(20, 14, 20, 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEFE4E6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () async {
              final newPost = await Navigator.push<Map<String, dynamic>>(
                context,
                MaterialPageRoute(builder: (_) => CommunityPostCreateScreen(currentLocation: _currentLocation)),
              );
              if (newPost != null) {
                setState(() {
                  _communityPosts.insert(0, newPost);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🎉 이야기가 동네 커뮤니티에 등록되었습니다!')),
                );
              }
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: appImg('assets/images/kr_female_1.jpg'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$_currentLocation 이웃들과 소소한 이야기를 나눠보세요...',
                    style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: coralAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 13, color: Colors.white),
                      SizedBox(width: 4),
                      Text('글쓰기', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. 단일 통합 심플 토픽 필터 (중복 태그 줄 완전히 제거하여 시원하고 깔끔한 UI 제공!)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: simpleTopics.map((topic) {
                final isSelected = _communityCategoryFilter == topic;
                return GestureDetector(
                  onTap: () => setState(() => _communityCategoryFilter = topic),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFFFF707F), Color(0xFFE84355)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : const Color(0xFFEFE4E6),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: coralAccent.withOpacity(0.28),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Text(
                      topic,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 6),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F4)),

        // 4. 커뮤니티 피드 리스트
        if (filteredPosts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 44, color: const Color(0xFFC7C7CC)),
                  const SizedBox(height: 12),
                  Text('아직 등록된 이야기가 없어요', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textPrimary)),
                  const SizedBox(height: 6),
                  Text('첫 번째 동네 소식을 가볍게 남겨보세요!', style: TextStyle(fontSize: 13, color: textSecondary)),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredPosts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildCommunityCard(filteredPosts[index]);
            },
          ),
      ],
    );
      },
    );
  }

  Widget _buildCommunityCard(Map<String, dynamic> post) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CommunityPostDetailScreen(post: post)),
        ).then((_) => setState(() {}));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEFE4E6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 작성자 헤더
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserProfileScreen(
                          userName: post['author'] ?? '김민서',
                          userAvatar: post['authorAvatar'],
                          userLocation: post['location'],
                          userManner: post['manner'] is num ? (post['manner'] as num).toDouble() : 37.0,
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 17,
                    backgroundImage: appImg(post['authorAvatar'] ?? 'assets/images/kr_female_1.jpg'),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UserProfileScreen(
                                    userName: post['author'] ?? '김민서',
                                    userAvatar: post['authorAvatar'],
                                    userLocation: post['location'],
                                    userManner: post['manner'] is num ? (post['manner'] as num).toDouble() : 37.0,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              post['author'] ?? '동네주민',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textPrimary),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDE8EC),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${post['manner']}°C',
                              style: TextStyle(color: coralAccent, fontSize: 10, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${post['location']} · ${post['time']}',
                        style: TextStyle(fontSize: 11, color: textSecondary),
                      ),
                    ],
                  ),
                ),
                if (post['tag'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF6F7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${post['tag']}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textSecondary),
                    ),
                  ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () {
                    UgcActionSheets.showContentOptions(
                      context: context,
                      contentType: '게시글',
                      contentId: post['id'] ?? post['title'] ?? 'post_${post['author']}',
                      author: post['author'] ?? '동네주민',
                      onContentHidden: () => setState(() {}),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.more_vert, size: 18, color: Color(0xFF8E8E93)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 제목 (있을 경우만 볼드 처리, 본문과 자연스럽게 연결)
            if (post['title'] != null && (post['title'] as String).isNotEmpty) ...[
              Text(
                post['title'] ?? '',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPrimary, height: 1.35),
              ),
              const SizedBox(height: 4),
            ],

            // 본문
            Text(
              post['content'] ?? '',
              style: TextStyle(fontSize: 13, color: textPrimary, height: 1.45),
            ),

            // 첨부 사진 (있을 경우만)
            if (post['image'] != null && (post['image'] as String).isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: double.infinity,
                  height: 170,
                  child: Image(
                    image: appImg(post['image']),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFF2F2F5),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // 하단 인터랙션 바: 좋아요, 댓글, 연관 모임 바로 만들기 CTA
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      final myUserId = globalData.activeUserId;
                      List<dynamic> likedUsers = List<dynamic>.from(post['likedUserIds'] ?? []);
                      bool currentlyLiked = likedUsers.contains(myUserId) || likedUsers.contains('user_me_01');
                      if (currentlyLiked) {
                        likedUsers.remove(myUserId);
                        likedUsers.remove('user_me_01');
                      } else {
                        likedUsers.add(myUserId);
                      }
                      post['likedUserIds'] = likedUsers;
                      post['likes'] = likedUsers.length;
                      post['isLiked'] = !currentlyLiked;

                      final postId = post['id']?.toString();
                      if (postId != null && postId.isNotEmpty) {
                        try {
                          FirebaseFirestore.instance.collection('community_posts').doc(postId).set({
                            'likedUserIds': likedUsers,
                            'likes': likedUsers.length,
                            'updatedAt': FieldValue.serverTimestamp(),
                          }, SetOptions(merge: true));
                        } catch (_) {}
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        post['isLiked'] == true ? Icons.favorite : Icons.favorite_border,
                        size: 17,
                        color: post['isLiked'] == true ? const Color(0xFFFF3B30) : textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post['likes'] ?? 0}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: post['isLiked'] == true ? const Color(0xFFFF3B30) : textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CommunityPostDetailScreen(post: post)),
                    ).then((_) => setState(() {}));
                  },
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 16, color: textSecondary),
                      const SizedBox(width: 4),
                      Text('${post['comments'] ?? 0}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary)),
                    ],
                  ),
                ),
                const Spacer(),
                // 연관 모임 바로 만들기 CTA
                if (post['relatedMeetup'] != null)
                  GestureDetector(
                    onTap: () {
                      final related = post['relatedMeetup'] as Map<String, dynamic>;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OOMUHostScreen(
                            initialTitle: related['title'],
                            initialLocation: related['location'],
                            initialMainCategory: related['category'],
                            initialCoverImageUrl: related['poster'],
                            initialVibe: '놀줄아는',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8EC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: coralAccent.withOpacity(0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, size: 13, color: coralAccent),
                          const SizedBox(width: 3),
                          Text(
                            '모임 만들기',
                            style: TextStyle(color: coralAccent, fontSize: 11, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateCommunityPostSheet() {
    final textController = TextEditingController();
    String selectedTag = '일상';
    final List<String> quickTags = ['일상', '맛집', '공연', '동네질문'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final hasText = textController.text.trim().isNotEmpty;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 바: 취소 | 동네 이야기 | 등록
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Text('취소', style: TextStyle(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      Text(
                        '동네 이야기 쓰기',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPrimary),
                      ),
                      GestureDetector(
                        onTap: () {
                          final text = textController.text.trim();
                          if (text.isEmpty) return;

                          final lines = text.split('\n');
                          final postTitle = lines.first.length > 25 ? '${lines.first.substring(0, 25)}...' : lines.first;

                          setState(() {
                            _communityPosts.insert(0, {
                              'id': 'post_${DateTime.now().millisecondsSinceEpoch}',
                              'category': selectedTag == '공연' ? '공연/전시' : (selectedTag == '맛집' ? '맛집/카페' : (selectedTag == '동네질문' ? '질문/추천' : '동네 토크')),
                              'tag': selectedTag,
                              'title': postTitle,
                              'content': text,
                              'author': '나 (방금)',
                              'authorAvatar': 'assets/images/kr_female_1.jpg',
                              'location': _currentLocation,
                              'time': '방금 전',
                              'manner': 45.0,
                              'likes': 0,
                              'isLiked': false,
                              'comments': 0,
                              'image': null,
                              'relatedMeetup': {
                                'title': '$postTitle 같이 하실 분!',
                                'location': _currentLocation,
                                'category': '일상 & 푸드 > 카페 & 디저트',
                                'poster': 'assets/images/cover_cafe.jpg',
                              }
                            });
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('🎉 이야기가 동네 커뮤니티에 등록되었습니다!')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: hasText ? coralAccent : const Color(0xFFE5E5EA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '등록',
                            style: TextStyle(
                              color: hasText ? Colors.white : const Color(0xFF999999),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 20, color: Color(0xFFEEEEEE)),

                  // 작성자 정보 및 위치
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: appImg('assets/images/kr_female_1.jpg'),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_currentLocation 주민',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textPrimary),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 단일 통합 본문 텍스트필드 (카테고리/제목 강요 없음! Threads/당근 스타일)
                  TextField(
                    controller: textController,
                    maxLines: 6,
                    autofocus: true,
                    style: TextStyle(fontSize: 14, color: textPrimary, height: 1.45),
                    onChanged: (_) => setSheetState(() {}),
                    decoration: InputDecoration(
                      hintText: '공연/맛집 후기나 궁금한 동네 소식을 자유롭게 남겨보세요.\n사진이나 약속 장소도 함께 공유할 수 있어요 :)',
                      hintStyle: TextStyle(color: textSecondary, fontSize: 13, height: 1.4),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 간편 태그 선택 (원터치 선택사항)
                  Row(
                    children: [
                      Text('주제: ', style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      ...quickTags.map((tag) {
                        final isSel = selectedTag == tag;
                        return GestureDetector(
                          onTap: () => setSheetState(() => selectedTag = tag),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFFFFF0EB) : const Color(0xFFF3F3F6),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSel ? coralAccent : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                color: isSel ? coralAccent : const Color(0xFF666666),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 하단 툴바: 사진 추가 아이콘
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.photo_camera_outlined, size: 16, color: textSecondary),
                            const SizedBox(width: 4),
                            Text('사진 첨부', style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${textController.text.length}자',
                        style: TextStyle(fontSize: 11, color: textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDatingDashboard() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
          // Group Dating Banner & Host CTA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF0F4FF), Color(0xFFE8EFFF)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD0DEFF)),
              ),
              child: Row(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('친구와 함께 나가는 동네 미팅 팟!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: textPrimary)),
                        const SizedBox(height: 2),
                        Text('부담 없는 2:2 / 3:3 동네 친구 & 연인 만들기', style: TextStyle(fontSize: 11, color: textSecondary)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OOMUHostScreen(
                            initialTitle: '홍대 2:2 직장인 미팅 팟',
                            initialLocation: '서울 마포구 서교동',
                            initialMainCategory: '소개팅 & 미팅 > 2:2 / 3:3 미팅',
                            initialVibe: '소개팅',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B68FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('+ 팟 만들기', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Group Dating Pots List
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _groupDatingPots.length,
            itemBuilder: (context, index) {
              return _buildGroupDatingCard(_groupDatingPots[index]);
            },
          ),
      ],
    );
  }

  Widget _buildGroupDatingCard(Map<String, dynamic> pot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECECEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: Image(
                image: appImg(pot['image']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        pot['category'],
                        style: const TextStyle(color: Color(0xFF3B68FF), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0EB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        pot['members'],
                        style: TextStyle(color: coralAccent, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  pot['title'],
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  pot['desc'] ?? '',
                  style: TextStyle(fontSize: 12, color: textSecondary, height: 1.35),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 13, color: textSecondary),
                    const SizedBox(width: 4),
                    Text(pot['time'], style: TextStyle(fontSize: 12, color: textSecondary)),
                    const SizedBox(width: 12),
                    Icon(Icons.location_on_outlined, size: 14, color: textSecondary),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(pot['location'], style: TextStyle(fontSize: 12, color: textSecondary), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: coralAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OOMUChatScreen(
                            title: pot['title'],
                            memberCount: 4,
                            chatRoomId: 'group_dating_${pot['id']}',
                          ),
                        ),
                      );
                    },
                    child: const Text('미팅 팟 참여하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off, size: 48, color: const Color(0xFFC7C7CC)),
            const SizedBox(height: 12),
            Text('선택한 조건의 모임이 아직 없어요', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
            const SizedBox(height: 6),
            Text('필터를 해제하거나 내가 먼저 모임을 개설해보세요!', style: TextStyle(fontSize: 13, color: textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: coralAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                setState(() {
                  _selectedVibe = null;
                  _selectedCategoryIndex = 0;
                });
              },
              child: const Text('필터 초기화', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  bool _isLightningMeetup(Map<String, dynamic> meetup) {
    if (meetup['isLightning'] == true) return true;
    final id = (meetup['id'] ?? '').toString();
    if (id.startsWith('spot_')) return true;
    final cat = (meetup['category'] ?? '').toString();
    final mainCat = (meetup['mainCategory'] ?? '').toString();
    final date = (meetup['date'] ?? meetup['time'] ?? '').toString();
    final title = (meetup['title'] ?? '').toString();
    final tags = (meetup['tags'] as List?)?.join(' ') ?? '';
    final combined = '$cat $mainCat $date $title $tags'.toLowerCase();
    return combined.contains('오늘') ||
        combined.contains('번개') ||
        combined.contains('10분') ||
        combined.contains('소소스팟') ||
        combined.contains('코노') ||
        combined.contains('즉시');
  }

  Widget _buildMeetupCard(Map<String, dynamic> meetup) {
    final int liveViewers = meetup['viewing'] ?? (11 + (meetup['title']?.toString().length ?? 5) % 9);
    final bool isLightning = _isLightningMeetup(meetup);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OOMUDetailScreen(meetup: meetup))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isLightning ? const Color(0xFFFFD8A8) : const Color(0xFFEFE4E6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isLightning ? const Color(0xFFFF5E36).withOpacity(0.08) : const Color(0xFFF25767).withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 176,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                image: DecorationImage(image: appImg(meetup['imageUrl'] ?? 'assets/images/cover_food.jpg'), fit: BoxFit.cover),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.45), Colors.transparent, Colors.black.withOpacity(0.55)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: isLightning
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [Color(0xFFFF5E36), Color(0xFFFF8A3D)]),
                                        borderRadius: BorderRadius.circular(9),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFF5E36).withOpacity(0.35),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('⚡', style: TextStyle(fontSize: 12)),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              meetup['category'] ?? '오늘 번개',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11.5),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF8F9).withOpacity(0.96),
                                        borderRadius: BorderRadius.circular(9),
                                        border: Border.all(color: const Color(0xFFF8C6CD)),
                                      ),
                                      child: Text(
                                        meetup['category'] ?? '동네모임',
                                        style: const TextStyle(color: Color(0xFFC83243), fontWeight: FontWeight.w800, fontSize: 11.5),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                            ),
                            if (meetup['isFemaleOnly'] == true)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                decoration: BoxDecoration(color: destructiveColor, borderRadius: BorderRadius.circular(8)),
                                child: const Text('여성 전용', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5)),
                              ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C1215).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isLightning ? const Color(0xFFFF5E36) : const Color(0xFF34D399),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    isLightning ? '🔥 번개 $liveViewers명 참여 중' : '지금 $liveViewers명이 보고 있어요',
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                            isLightning
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF5E36).withOpacity(0.92),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.bolt, size: 12, color: Colors.white),
                                        SizedBox(width: 2),
                                        Text('즉시 합류', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800)),
                                      ],
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF0F2),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: const Color(0xFFF8C6CD)),
                                    ),
                                    child: const Text(
                                      '✨ 공식 인증 아지트',
                                      style: TextStyle(color: Color(0xFFC83243), fontSize: 10.5, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meetup['title'] ?? '취향 모임',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      height: 1.35,
                      letterSpacing: -0.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 15, color: isLightning ? const Color(0xFFFF5E36) : coralAccent),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          meetup['location'] ?? '위치 협의',
                          style: TextStyle(fontSize: 12.5, color: textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(isLightning ? Icons.bolt : Icons.access_time, size: 15, color: isLightning ? const Color(0xFFFF5E36) : coralAccent),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          meetup['date'] ?? (isLightning ? '오늘 즉시' : '일정 협의'),
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isLightning ? const Color(0xFFFF5E36) : textSecondary,
                            fontWeight: isLightning ? FontWeight.w800 : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFEFE4E6)),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 13,
                              backgroundImage: appImg(
                                meetup['hostAvatar'] ??
                                    (meetup['isFemaleOnly'] == true ? 'assets/images/kr_female_1.jpg' : 'assets/images/kr_male_1.jpg'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                meetup['host'] ?? '호스트',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.local_fire_department, size: 13, color: Color(0xFFD97706)),
                                  Text('${meetup['manner'] ?? 40.5}°C', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFFD97706))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isLightning ? const Color(0xFFFFF4EB) : const Color(0xFFFFF0F2),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: isLightning ? const Color(0xFFFFD8A8) : const Color(0xFFF8C6CD)),
                        ),
                        child: Text(
                          isLightning ? '⚡ 즉시 (${meetup['members'] ?? '2/4'})' : '${meetup['members'] ?? '2/4'} 참여',
                          style: TextStyle(
                            fontSize: 12,
                            color: isLightning ? const Color(0xFFD9480F) : const Color(0xFFC83243),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 참여 중인 멤버 프로필 요약 & 잔여석 안내 (금액 표시 제외)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF6F7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEFE4E6)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.groups_outlined, size: 15, color: Color(0xFF888899)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            isLightning
                                ? '⚡ 지금 ${meetup['host'] ?? '방장'} 님과 바로 만날 수 있어요'
                                : '참여: ${meetup['host'] ?? '방장'}(방장) 외 참여 이웃',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF555566), fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _calcRemainingSeats(meetup['members']?.toString() ?? '2/4'),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isLightning ? const Color(0xFFFF5E36) : coralAccent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calcRemainingSeats(String memberStr) {
    try {
      final parts = memberStr.split('/');
      if (parts.length == 2) {
        final current = int.parse(parts[0].replaceAll(RegExp(r'[^0-9]'), ''));
        final total = int.parse(parts[1].replaceAll(RegExp(r'[^0-9]'), ''));
        final diff = total - current;
        if (diff <= 0) return '마감 임박';
        return '$diff자리 남음';
      }
    } catch (_) {}
    return '1자리 남음';
  }

  /// 컴팩트 목록형 뷰 카드 (Zero-Price & 기존 테마 준수)
  Widget _buildMeetupListRow(Map<String, dynamic> meetup) {
    final int liveViewers = meetup['viewing'] ?? (11 + (meetup['title']?.toString().length ?? 5) % 9);
    final bool isLightning = _isLightningMeetup(meetup);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OOMUDetailScreen(meetup: meetup))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isLightning ? const Color(0xFFFFD8A8) : const Color(0xFFEFE4E6),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isLightning ? const Color(0xFFFF5E36).withOpacity(0.06) : const Color(0xFFF25767).withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일 (88x88 당근/Karrot 표준)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 88,
                height: 88,
                child: Stack(
                  children: [
                    Image(
                      image: appImg(meetup['imageUrl'] ?? 'assets/images/cover_food.jpg'),
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset('assets/images/cover_food.jpg', fit: BoxFit.cover),
                    ),
                    if (meetup['isFemaleOnly'] == true)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(color: destructiveColor, borderRadius: BorderRadius.circular(4)),
                          child: const Text('여성 전용', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 정보 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: isLightning
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF4EB),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: const Color(0xFFFFD8A8)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('⚡', style: TextStyle(fontSize: 10)),
                                    const SizedBox(width: 2),
                                    Flexible(
                                      child: Text(
                                        meetup['category'] ?? '오늘 번개',
                                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFFD9480F)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Text(
                                meetup['category'] ?? '동네모임',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFC83243)),
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                      isLightning
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5E36),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('⚡ 즉시합류', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800)),
                            )
                          : Text(
                              '👀 $liveViewers명 조회',
                              style: const TextStyle(fontSize: 10.5, color: Color(0xFF888899), fontWeight: FontWeight.w600),
                            ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meetup['title'] ?? '취향 모임',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      height: 1.32,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 13, color: isLightning ? const Color(0xFFFF5E36) : coralAccent),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '${meetup['location'] ?? '위치 협의'} · ${meetup['date'] ?? '일정 협의'}',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isLightning ? const Color(0xFFFF5E36) : textSecondary,
                            fontWeight: isLightning ? FontWeight.w700 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 9,
                            backgroundImage: appImg(
                              meetup['hostAvatar'] ??
                                  (meetup['isFemaleOnly'] == true ? 'assets/images/kr_female_1.jpg' : 'assets/images/kr_male_1.jpg'),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            meetup['host'] ?? '호스트',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: textPrimary),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isLightning ? const Color(0xFFFFF4EB) : const Color(0xFFFFF0F2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isLightning ? const Color(0xFFFFD8A8) : const Color(0xFFF8C6CD)),
                        ),
                        child: Text(
                          isLightning
                              ? '⚡ 즉시 (${meetup['members'] ?? '2/4'})'
                              : '${meetup['members'] ?? '2/4'} (${_calcRemainingSeats(meetup['members']?.toString() ?? '2/4')})',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isLightning ? const Color(0xFFD9480F) : const Color(0xFFC83243),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDummyMeetups() {
    final List<Map<String, dynamic>> allDummyData = [
      {
        'id': 'dummy_meetup_01',
        'title': '주말 엽떡+마라탕 조지실 분 🔥',
        'mainCategory': '일상 & 푸드',
        'category': '동네 맛집 & 소셜 다이닝',
        'location': '마포구 홍대입구역 9번 출구',
        'date': '이번주 토요일 18:00',
        'imageUrl': 'assets/images/cover_food.jpg',
        'isFemaleOnly': true,
        'host': '매운맛킬러',
        'hostAvatar': 'assets/images/kr_female_1.jpg',
        'manner': 41.2,
        'members': '2/4',
        'price': 'N빵',
        'transport': '각자 이동',
        'schedule': '1차 엽떡+마라탕 먹방 ➔ 2차 인생네컷 & 보드게임 카페',
        'tags': ['동네 핫플 메뉴 털기', '주말 마라탕&엽떡 모임', '소셜다이닝', '소소하게', '메이트'],
        'photos': [
          'assets/images/cover_food.jpg',
          'assets/images/cover_food.jpg',
          'assets/images/cover_cafe.jpg',
        ],
      },
      {
        'id': 'dummy_meetup_02',
        'title': '성수동 감성 에스프레소 바 & 북카페 나들이 ☕📚',
        'mainCategory': '일상 & 푸드',
        'category': '카페 & 디저트',
        'location': '성동구 성수동 카페거리',
        'date': '이번주 일요일 오후 2:00',
        'imageUrl': 'assets/images/cover_cafe.jpg',
        'isFemaleOnly': false,
        'host': '성수동힙스터',
        'hostAvatar': 'assets/images/kr_female_2.jpg',
        'manner': 38.5,
        'members': '2/4',
        'price': '각자 결제',
        'transport': '성수역 3번출구 집결',
        'schedule': '힙한 신상 에스프레소 바 ➔ 베이커리 북카페 & 디저트 탐방',
        'tags': ['북카페 겸 근교 드라이브', '동네 핫플 디저트 투어', '소소하게', '디저트', '주말여유'],
        'photos': [
          'assets/images/cover_cafe.jpg',
          'assets/images/cover_cafe.jpg',
        ],
      },
      {
        'id': 'dummy_meetup_03',
        'title': '연남동 힙한 내추럴 혼술바 동행 & 와인 팟 🍷',
        'mainCategory': '일상 & 푸드',
        'category': '동네 술 한잔',
        'location': '마포구 연남동 미로길',
        'date': '금요일 저녁 7:30',
        'imageUrl': 'assets/images/cover_wine.jpg',
        'isFemaleOnly': false,
        'host': '와인앤모어',
        'hostAvatar': 'assets/images/kr_male_1.jpg',
        'manner': 42.0,
        'members': '3/4',
        'price': '1/N 분담',
        'transport': '홍대입구역 3번출구 도보',
        'schedule': '내추럴 와인 2병 페어링 & 소소한 금요일 밤 이야기',
        'tags': ['힙한 혼술바 동행', '동네 수제맥주·와인 팟', '놀줄아는', '와인바', '소셜다이닝'],
        'photos': [
          'assets/images/cover_wine.jpg',
          'assets/images/cover_food.jpg',
        ],
      },
      {
        'id': 'dummy_meetup_04',
        'title': '불금엔 역시 코노! 스트레스 풀 고음 릴레이 🎤',
        'mainCategory': '문화 & 엔터',
        'category': '음악 & 노래방',
        'location': '합정역 수코인노래방',
        'date': '오늘 저녁 8시',
        'host': '고음불가',
        'hostAvatar': 'assets/images/kr_male_2.jpg',
        'manner': 38.5,
        'price': 'N빵',
        'members': '2/4',
        'isFemaleOnly': false,
        'transport': '각자 이동',
        'imageUrl': 'assets/images/cover_wine.jpg',
        'tags': ['불금엔 역시 코노', '음악 & 노래방', '놀줄아는', '스트레스해소', '코노'],
        'photos': [
          'assets/images/cover_wine.jpg',
        ],
      },
      {
        'id': 'dummy_meetup_05',
        'title': '성수동 핫한 팝업스토어 웨이팅 동행 구해요 🛍️',
        'mainCategory': '문화 & 엔터',
        'category': '전시 & 팝업스토어',
        'location': '성동구 성수 연무장길',
        'date': '토요일 오전 11:30',
        'imageUrl': 'assets/images/cover_cafe.jpg',
        'isFemaleOnly': false,
        'host': '팝업헌터',
        'hostAvatar': 'assets/images/kr_female_3.jpg',
        'manner': 40.2,
        'members': '2/3',
        'price': '무료',
        'transport': '성수역 4번출구',
        'schedule': '팝업스토어 2곳 웨이팅 & 인생샷 교환 ➔ 카페 수다',
        'tags': ['성수/연남 팝업스토어 웨이팅 동행', '전시 & 팝업스토어', '놀줄아는', '팝업'],
        'photos': [
          'assets/images/cover_cafe.jpg',
        ],
      },
      {
        'id': 'dummy_meetup_06',
        'title': '신촌 보드게임 카페 파티 & 전략 보드게임 모임 🎲',
        'mainCategory': '게임 & 오락',
        'category': '보드게임',
        'location': '서대문구 신촌 보드게임 카페',
        'date': '토요일 오후 3:00',
        'host': '미플마스터',
        'hostAvatar': 'assets/images/kr_male_1.jpg',
        'manner': 40.5,
        'price': '게임비 각자',
        'members': '3/4',
        'isFemaleOnly': false,
        'transport': '신촌역 2번출구',
        'imageUrl': 'assets/images/cover_cafe.jpg',
        'tags': ['보드게임 카페 파티', '전략 보드게임 모임', '소소하게', '보드게임'],
        'photos': [
          'assets/images/cover_cafe.jpg',
        ],
      },
      {
        'id': 'dummy_meetup_07',
        'title': '망원 한강공원 야경 러닝 & 플로깅 5km 🏃‍♀️',
        'mainCategory': '액티비티 & 스포츠',
        'category': '야외 액티비티',
        'location': '마포구 망원 한강공원 입구',
        'date': '목요일 저녁 8:00',
        'imageUrl': 'assets/images/cover_running.jpg',
        'isFemaleOnly': false,
        'host': '러닝크루장',
        'hostAvatar': 'assets/images/kr_male_3.jpg',
        'manner': 39.8,
        'members': '4/6',
        'price': '무료',
        'transport': '망원역 집결',
        'schedule': '스트레칭 10분 ➔ 6분 페이스 5km 러닝 ➔ 이온음료 쿨다운',
        'tags': ['한강 러닝 & 플로깅', '야외 액티비티', '메이트', '러닝', '운동'],
        'photos': [
          'assets/images/cover_running.jpg',
          'assets/images/cover_running.jpg',
        ],
      },
      {
        'id': 'dummy_meetup_08',
        'title': '동네 헬스장 득근 헬스 메이트 구함 (동성/상하체 분할) 💪',
        'mainCategory': '액티비티 & 스포츠',
        'category': '운동 메이트 (동성 추천)',
        'location': '마포구 서교동 피트니스',
        'date': '평일 저녁 7:00 매일',
        'imageUrl': 'assets/images/cover_running.jpg',
        'isFemaleOnly': false,
        'host': '헬린이탈출',
        'hostAvatar': 'assets/images/kr_male_2.jpg',
        'manner': 43.1,
        'members': '2/2',
        'price': '무료',
        'transport': '헬스장 정문',
        'schedule': '웨이트 60분 + 유산소 20분 보조',
        'tags': ['동네 헬스장 헬스 메이트', '운동 메이트', '메이트', '헬스'],
        'photos': [
          'assets/images/cover_running.jpg',
        ],
      },
      {
        'id': 'dummy_meetup_09',
        'title': '지하철 타고 떠나는 감성 골목길 인생샷 출사 투어 📷',
        'mainCategory': '여행 & 나들이',
        'category': '출사 & 사진',
        'location': '종로구 익선동 한옥마을',
        'date': '일요일 오전 11:00',
        'host': '셔터버기',
        'hostAvatar': 'assets/images/kr_female_3.jpg',
        'manner': 42.8,
        'price': '카페비 각자',
        'members': '2/4',
        'isFemaleOnly': false,
        'transport': '종로3가역 4번출구',
        'imageUrl': 'assets/images/cover_running.jpg',
        'tags': ['지하철/버스 타고 떠나는 근교 출사', '동네 골목길 인생샷 투어', '소소하게', '출사'],
        'photos': [
          'assets/images/cover_running.jpg',
        ],
      },
      {
        'id': 'dummy_meetup_10',
        'title': '나만의 시그니처 향수 만들기 원데이 공방 🎨✨',
        'mainCategory': '체험 & 취미',
        'category': '원데이 클래스',
        'location': '마포구 연남동 조향 아틀리에',
        'date': '토요일 오후 1:00',
        'host': '향기디자이너',
        'hostAvatar': 'assets/images/kr_female_1.jpg',
        'manner': 44.0,
        'price': '클래스비 35,000원',
        'members': '2/3',
        'isFemaleOnly': true,
        'transport': '홍대입구역 도보 8분',
        'imageUrl': 'assets/images/cover_food.jpg',
        'tags': ['향수/비누 만들기 공방', '원데이 클래스', '소소하게', '취미'],
        'photos': [
          'assets/images/cover_food.jpg',
        ],
      },
      {
        'id': 'dummy_meetup_11',
        'title': '자연스러운 동네 2:2 와인&다이닝 미팅 💖',
        'mainCategory': '일상 & 푸드',
        'category': '동네 술 한잔',
        'location': '마포구 연남동 분위기 좋은 다이닝',
        'date': '이번주 토요일 저녁 7:00',
        'imageUrl': 'assets/images/cover_wine.jpg',
        'isFemaleOnly': false,
        'host': '연남러버',
        'hostAvatar': 'assets/images/kr_male_1.jpg',
        'manner': 41.5,
        'members': '3/4',
        'price': '1/N',
        'transport': '홍대입구역 3번출구',
        'schedule': '가벼운 와인과 식사 & 편안한 동네 인연 찾기',
        'tags': ['소개팅', '2:2', '미팅', '인연', '소셜다이닝'],
        'photos': [
          'assets/images/cover_wine.jpg',
        ],
      },
    ];

    final filtered = allDummyData.where((m) => _matchesFilters(m)).toList();

    if (filtered.isEmpty) {
      return _buildEmptyFilterState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _isListView ? _buildMeetupListRow(filtered[index]) : _buildMeetupCard(filtered[index]);
      },
    );
  }

  Stream<QuerySnapshot>? _getMeetupStream() {
    try {
      return FirebaseFirestore.instance.collection('meetups').orderBy('createdAt', descending: true).limit(20).snapshots();
    } catch (e) {
      return null;
    }
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _homeDashboardTab.clamp(0, 4),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: coralAccent,
      unselectedItemColor: const Color(0xFF767676),
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      elevation: 20,
      backgroundColor: Colors.white,
      onTap: (index) {
        setState(() {
          _homeDashboardTab = index;
        });
      },
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined, size: 24),
          activeIcon: Icon(Icons.home, size: 24),
          label: '동네모임',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.group_outlined, size: 24),
          activeIcon: Icon(Icons.group, size: 24),
          label: '커뮤니티',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border, size: 24),
          activeIcon: Icon(Icons.favorite, size: 24),
          label: '소개팅',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.chat_bubble_outline, size: 23),
              Positioned(
                right: -6,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: const BoxDecoration(color: Color(0xFFFF3B30), shape: BoxShape.circle),
                  child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          activeIcon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.chat_bubble, size: 23),
              Positioned(
                right: -6,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: const BoxDecoration(color: Color(0xFFFF3B30), shape: BoxShape.circle),
                  child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          label: '채팅',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline, size: 24),
          activeIcon: Icon(Icons.person, size: 24),
          label: 'MY',
        ),
      ],
    );
  }
}
