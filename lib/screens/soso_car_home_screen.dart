import '../widgets/meetup_card_footer.dart';
import 'explore_map_screen.dart';
import 'package:flutter/material.dart';
import '../data/oomu_categories.dart';
import '../utils/app_image.dart';
import '../utils/global_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/oomu_ui_helpers.dart';
import '../services/kakao_map_service.dart';
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
import '../widgets/bouncy_tap.dart';
import '../widgets/balanced_text.dart';
import '../widgets/oomu_discovery_lifestyle_hub.dart';

class OOMUHomeScreen extends StatefulWidget {
  final int initialTab;
  const OOMUHomeScreen({super.key, this.initialTab = 0});

  @override
  State<OOMUHomeScreen> createState() => _OOMUHomeScreenState();
}

class _OOMUHomeScreenState extends State<OOMUHomeScreen> {
  final Color textPrimary = const Color(0xFF191F28);
  final Color textSecondary = const Color(0xFF6B7684);
  final Color surfaceColor = const Color(0xFFF7F8FA);
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
      'content':
          '날씨가 너무 선선하고 좋아서 저녁 7시쯤 비숑 데리고 산책 나가려구요! 댕댕이 없으셔도 가볍게 산책하고 대화 나누실 이웃분 환영합니다 ✨',
      'author': '김민서',
      'authorAvatar': 'assets/images/민지.png',
      'location': '마포구 서교동',
      'time': '10분 전',
      'manner': 37.2,
      'likedUserIds': ['user_demo_1', 'user_demo_2'],
      'likes': 2,
      'isLiked': false,
      'comments': 2,
      'commentList': <Map<String, dynamic>>[
        {
          'id': 'comm_minseo_1',
          'author': '연남산책러',
          'authorAvatar': 'assets/images/시연.png',
          'content': '저도 강아지 산책 나가려던 참인데 연트럴파크 잔디광장 쪽에서 뵈어요!',
          'time': '5분 전',
          'likes': 1,
          'isLiked': false,
          'likedUserIds': <String>['user_demo_2'],
        },
        {
          'id': 'comm_minseo_2',
          'author': '동네이웃준호',
          'authorAvatar': 'assets/images/지훈.png',
          'content': '날씨가 딱 산책하기 좋네요 ㅎㅎ 즐거운 산책 되세요!',
          'time': '2분 전',
          'likes': 0,
          'isLiked': false,
          'likedUserIds': <String>[],
        },
      ],
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
      'content':
          '성수역 뒤쪽 골목에 새로 생긴 곳인데 스트라파짜토랑 크림 에스프레소 진짜 미쳤네요... 이번 주말에 커피 좋아하시는 분들과 같이 가서 메뉴 도장깨기 하고 싶어요!',
      'author': '이준호',
      'authorAvatar': 'assets/images/지훈.png',
      'location': '성동구 성수동',
      'time': '25분 전',
      'manner': 38.5,
      'likedUserIds': ['user_demo_1'],
      'likes': 1,
      'isLiked': false,
      'comments': 0,
      'commentList': <Map<String, dynamic>>[],
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
      'content':
          '겉바속촉 쌀 소금빵 나오자마자 먹었는데 진짜 최고예요ㅠㅠ 자리도 넓고 채광 좋아서 주말 오후에 책 읽거나 노트북 작업하기 딱입니다. 동네 분들 같이 가요!',
      'author': '박지연',
      'authorAvatar': 'assets/images/시연.png',
      'location': '마포구 연남동',
      'time': '40분 전',
      'manner': 36.8,
      'likedUserIds': ['user_demo_2', 'user_demo_3'],
      'likes': 2,
      'isLiked': false,
      'comments': 0,
      'commentList': <Map<String, dynamic>>[],
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
      'content':
          '이번 시즌 스위니토드 캐스팅 역대급이네요... 1층 B구역 8열 시야 정말 완벽합니다. 혹시 다음 주 주말 회차 가시는 분 계시면 공연 전후로 커피나 한잔하며 극 얘기 나눠요!',
      'author': '뮤지컬덕후',
      'authorAvatar': 'assets/images/민지.png',
      'location': '구로구 신도림동',
      'time': '12분 전',
      'manner': 42.5,
      'likedUserIds': ['user_demo_1', 'user_demo_2', 'user_demo_3'],
      'likes': 28,
      'isLiked': false,
      'comments': 0,
      'commentList': <Map<String, dynamic>>[],
      'image':
          'http://www.kopis.or.kr/upload/pfmPoster/PF_PF303043_261012_171201.gif',
      'relatedMeetup': {
        'title': '스위니토드 같이 보실 분!',
        'location': '디큐브 링크아트센터',
        'category': '문화 & 엔터 > 페스티벌 & 공연',
        'poster':
            'http://www.kopis.or.kr/upload/pfmPoster/PF_PF303043_261012_171201.gif',
      }
    },
    {
      'id': 'post_02',
      'category': '맛집/카페',
      'tag': '두바이쫀득쿠키',
      'title': '🍰 연남동 두바이 쫀득 쿠키(두쫀쿠) 실시간 웨이팅 상황 & 솔직 후기',
      'content':
          '오늘 1시 오픈런 뛰어서 드디어 두쫀쿠 겟했습니다... 카다이프 바삭함이 미쳤네요ㅠㅠ 1인당 2개 한정이라 주말에 같이 가서 메뉴 여러 개 털어볼 메이트 구합니다!',
      'author': '달콤빵순이',
      'authorAvatar': 'assets/images/시연.png',
      'location': '마포구 연남동',
      'time': '35분 전',
      'manner': 43.1,
      'likes': 42,
      'isLiked': false,
      'comments': 0,
      'commentList': <Map<String, dynamic>>[],
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
      'content':
          '체조경기장 막콘 좌석 잡았습니다! 콘서트 당일 올림픽공원에서 응원봉 배터리도 나누고 콘서트 끝나고 뒷풀이 감자탕/치맥 하실 분들 계실까요?',
      'author': 'KPOP투게더',
      'authorAvatar': 'assets/images/정재.png',
      'location': '송파구 방이동',
      'time': '1시간 전',
      'manner': 41.2,
      'likes': 51,
      'isLiked': false,
      'comments': 0,
      'commentList': <Map<String, dynamic>>[],
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
      'content':
          '퇴근하고 시끄러운 술집 말고 잔잔하게 재즈 흘러나오는 바 찾고 있어요. 동네 주민분들만 아는 아지트 살짝 공유해주실 천사분 계실까요?',
      'author': '심야산책러',
      'authorAvatar': 'assets/images/지훈.png',
      'location': '중구 을지로동',
      'time': '2시간 전',
      'manner': 40.8,
      'likes': 19,
      'isLiked': false,
      'comments': 0,
      'commentList': <Map<String, dynamic>>[],
      'image': 'assets/images/cover_food.jpg',
      'relatedMeetup': {
        'title': '을지로 감성 와인바 모임 같이 가실 분!',
        'location': '서울 중구 을지로동',
        'category': '일상 & 푸드 > 동네 술 한잔',
        'poster': 'assets/images/cover_food.jpg',
      }
    },
  ];

  final List<Map<String, dynamic>> _liveSpots = [
    {
      'id': 'spot_01',
      'title': '홍대입구역 9번 출구 인생네컷 & 와플 🧇',
      'location': '마포구 홍대입구역 9번 출구 앞',
      'distance': '홍대입구역',
      'timeLeft': '오늘 번개',
      'category': '오늘 번개',
      'members': '2/4',
      'host': '달콤한와플',
      'hostAvatar': 'assets/images/시연.png',
      'manner': 42.1,
      'image': 'assets/images/cover_cafe.jpg',
      'isLightning': true,
      'date': '오늘 저녁 (시간 조율 가능)',
    },
    {
      'id': 'spot_02',
      'title': '연남동 연트럴파크 돗자리 캔맥주 급구 🍺',
      'location': '마포구 경의선숲길 잔디광장',
      'distance': '연트럴파크',
      'timeLeft': '오늘 번개',
      'category': '오늘 번개',
      'members': '3/4',
      'host': '연트럴피플',
      'hostAvatar': 'assets/images/정재.png',
      'manner': 39.4,
      'image': 'assets/images/cover_wine.jpg',
      'isLightning': true,
      'date': '오늘 저녁 8시',
    },
    {
      'id': 'spot_03',
      'title': '성수동 서울숲 잔디마당 플랫화이트 번개 ☕',
      'location': '성동구 서울숲 메인 출구',
      'distance': '서울숲',
      'timeLeft': '모집 중',
      'category': '오늘 번개',
      'members': '1/3',
      'host': '성수동힙스터',
      'hostAvatar': 'assets/images/지연.png',
      'manner': 43.0,
      'image': 'assets/images/cover_cafe.jpg',
      'isLightning': true,
      'date': '오늘 오후 3시',
    },
    {
      'id': 'spot_04',
      'title': '망원 한강공원 야경 산책 & 라면 먹방 🏃',
      'location': '마포구 망원 한강공원 편의점 앞',
      'distance': '망원 한강공원',
      'timeLeft': '오늘 번개',
      'category': '오늘 번개',
      'members': '2/4',
      'host': '망원라이더',
      'hostAvatar': 'assets/images/지훈.png',
      'manner': 41.5,
      'image': 'assets/images/cover_running.jpg',
      'isLightning': true,
      'date': '오늘 밤 9시',
    },
  ];

  final List<Map<String, dynamic>> _yeosuLiveSpots = [
    {
      'id': 'spot_yeosu_01',
      'title': '화장동 선소상가 바삭 와플 & 크로플 🧇',
      'location': '여수시 화장동 선소상가거리',
      'distance': '선소상가',
      'timeLeft': '오늘 번개',
      'category': '오늘 번개',
      'members': '2/4',
      'host': '여수와플러',
      'hostAvatar': 'assets/images/시연.png',
      'manner': 42.1,
      'image': 'assets/images/cover_cafe.jpg',
      'isLightning': true,
      'date': '오늘 저녁 (시간 조율 가능)',
    },
    {
      'id': 'spot_yeosu_02',
      'title': '성산공원 호수 둘레길 야경 산책 & 힐링 🏃',
      'location': '여수시 화장동 성산공원 입구',
      'distance': '성산공원 둘레길',
      'timeLeft': '오늘 번개',
      'category': '오늘 번개',
      'members': '3/4',
      'host': '화장동이웃',
      'hostAvatar': 'assets/images/정재.png',
      'manner': 43.5,
      'image': 'assets/images/cover_running.jpg',
      'isLightning': true,
      'date': '오늘 저녁 8시반',
    },
    {
      'id': 'spot_yeosu_03',
      'title': '웅천 친수공원 잔디마당 노을 캔맥주 급구 🍺',
      'location': '여수시 웅천동 해변공원',
      'distance': '웅천 친수공원',
      'timeLeft': '모집 중',
      'category': '오늘 번개',
      'members': '2/4',
      'host': '웅천피플_준',
      'hostAvatar': 'assets/images/지훈.png',
      'manner': 41.2,
      'image': 'assets/images/cover_wine.jpg',
      'isLightning': true,
      'date': '오늘 저녁 7시',
    },
    {
      'id': 'spot_yeosu_04',
      'title': '무선지구 롯데마트 앞 소금빵 & 카페 나들이 ☕',
      'location': '여수시 화장동 롯데마트 인근',
      'distance': '무선지구',
      'timeLeft': '모집 중',
      'category': '오늘 번개',
      'members': '1/3',
      'host': '무선빵순이',
      'hostAvatar': 'assets/images/지연.png',
      'manner': 44.0,
      'image': 'assets/images/cover_cafe.jpg',
      'isLightning': true,
      'date': '오늘 오후 2시',
    },
  ];

  List<Map<String, dynamic>> _getLiveSpotsForLocation(String location) {
    final clean = location.trim();
    if (clean.contains('여수') || clean.contains('화장동')) {
      return _yeosuLiveSpots;
    }
    return _liveSpots;
  }

  final List<Map<String, dynamic>> _yeosuCommunityPosts = [
    {
      'id': 'post_yeosu_01',
      'category': '동네 토크',
      'tag': '성산공원둘레길',
      'title': '🐕 오늘 저녁 화장동 성산공원 둘레길 댕댕이 산책 같이 하실 분!',
      'content':
          '날씨가 너무 선선해서 저녁 7시쯤 비숑 데리고 성산공원 한 바퀴 돌려구요! 댕댕이 없으셔도 가볍게 산책하고 수다 떠실 화장동 이웃분 환영합니다 ✨',
      'author': '화장동댕댕이',
      'authorAvatar': 'assets/images/민지.png',
      'location': '전남 여수시 화장동',
      'time': '10분 전',
      'manner': 41.5,
      'likedUserIds': ['user_demo_1', 'user_demo_2'],
      'likes': 4,
      'isLiked': false,
      'comments': 2,
      'commentList': <Map<String, dynamic>>[
        {
          'id': 'comm_yeosu_1',
          'author': '선소산책러',
          'authorAvatar': 'assets/images/시연.png',
          'content': '저도 성산공원 장미원 쪽으로 산책 나가려던 참인데 반갑네요!',
          'time': '5분 전',
          'likes': 1,
          'isLiked': false,
          'likedUserIds': <String>['user_demo_2'],
        },
        {
          'id': 'comm_yeosu_2',
          'author': '무선지구이웃',
          'authorAvatar': 'assets/images/지훈.png',
          'content': '오늘 날씨 선선해서 걷기 딱 좋습니다 ㅎㅎ',
          'time': '2분 전',
          'likes': 0,
          'isLiked': false,
          'likedUserIds': <String>[],
        },
      ],
      'image': null,
      'relatedMeetup': {
        'title': '화장동 성산공원 둘레길 가벼운 저녁 5km 런닝 크루 🏃‍♀️',
        'location': '전남 여수시 화장동 성산공원 수변무대',
        'category': '문화 & 엔터 > 야외 액티비티',
        'poster': 'assets/images/cover_running.jpg',
      }
    },
    {
      'id': 'post_yeosu_02',
      'category': '맛집/카페',
      'tag': '선소상가와플',
      'title': '🧇 선소상가 새로 오픈한 수제 소금빵 & 와플 맛집 다녀오신 분 계신가요?',
      'content':
          '선소상가 안쪽에 새로 생긴 베이커리 다녀왔는데 겉바속촉 제대로네요... 쌀가루 소금빵이랑 크림 와플 미쳤습니다. 이번 주말에 디저트 좋아하시는 분들이랑 같이 털러 가고 싶어요!',
      'author': '여수빵순이',
      'authorAvatar': 'assets/images/시연.png',
      'location': '전남 여수시 화장동',
      'time': '35분 전',
      'manner': 43.2,
      'likedUserIds': ['user_demo_3'],
      'likes': 7,
      'isLiked': false,
      'comments': 1,
      'commentList': <Map<String, dynamic>>[
        {
          'id': 'comm_yeosu_3',
          'author': '학동미식가',
          'authorAvatar': 'assets/images/정재.png',
          'content': '오픈런 대기 꽤 길던데 주말에 같이 가요!',
          'time': '15분 전',
          'likes': 2,
          'isLiked': false,
          'likedUserIds': <String>['user_demo_1'],
        },
      ],
      'image': 'assets/images/cover_cafe.jpg',
      'relatedMeetup': {
        'title': '주말 여수 화장동 수제 소금빵 & 감성 베이커리 카페 오픈런 🥐',
        'location': '전남 여수시 화장동 선소상가 카페거리',
        'category': '일상 & 푸드 > 카페 & 디저트',
        'poster': 'assets/images/cover_cafe.jpg',
      }
    },
    {
      'id': 'post_yeosu_03',
      'category': '공연/전시',
      'tag': '웅천친수공원',
      'title': '🌊 웅천 친수공원 잔디마당 주말 버스킹 & 노을 피크닉 같이 즐겨요!',
      'content':
          '이번 주말 저녁에 웅천 친수공원에서 바다 보면서 잔잔한 버스킹 공연 한대요. 돗자리 펴고 노을 보면서 시원한 캔맥주나 커피 한잔하실 이웃분 구합니다~',
      'author': '웅천피플_준',
      'authorAvatar': 'assets/images/지훈.png',
      'location': '전남 여수시 웅천동',
      'time': '1시간 전',
      'manner': 42.0,
      'likedUserIds': ['user_demo_1'],
      'likes': 12,
      'isLiked': false,
      'comments': 0,
      'commentList': <Map<String, dynamic>>[],
      'image': 'assets/images/cover_wine.jpg',
      'relatedMeetup': {
        'title': '여수 웅천친수공원 바다 캔맥주 소셜 피크닉 & 수다 🍺',
        'location': '전남 여수시 웅천동 해변문화공원',
        'category': '일상 & 푸드 > 동네 술 한잔',
        'poster': 'assets/images/cover_wine.jpg',
      }
    },
    {
      'id': 'post_yeosu_04',
      'category': '질문/추천',
      'tag': '동네질문',
      'title': '❓ 화장동이나 무선지구에 혼자 책 읽기 좋은 조용한 카페 추천해주세요!',
      'content':
          '퇴근 후나 주말에 조용하게 책 읽거나 노트북 작업할 수 있는 아지트 찾고 있어요. 통창 뷰 좋거나 잔잔한 음악 나오는 곳 아시는 분 공유 부탁드려요!',
      'author': '북카페러버',
      'authorAvatar': 'assets/images/지연.png',
      'location': '전남 여수시 화장동',
      'time': '2시간 전',
      'manner': 40.8,
      'likedUserIds': [],
      'likes': 5,
      'isLiked': false,
      'comments': 2,
      'commentList': <Map<String, dynamic>>[
        {
          'id': 'comm_yeosu_4',
          'author': '선소주민',
          'authorAvatar': 'assets/images/민지.png',
          'content': '성산공원 맞은편 2층 카페 통창 뷰도 좋고 조용해서 추천드려요!',
          'time': '1시간 전',
          'likes': 1,
          'isLiked': false,
          'likedUserIds': <String>[],
        },
        {
          'id': 'comm_yeosu_5',
          'author': '무선지구이웃',
          'authorAvatar': 'assets/images/정재.png',
          'content': '무선지구 도서관 근처 베이커리 카페도 널찍하고 괜찮아요~',
          'time': '30분 전',
          'likes': 0,
          'isLiked': false,
          'likedUserIds': <String>[],
        },
      ],
      'image': 'assets/images/cover_cafe.jpg',
      'relatedMeetup': {
        'title': '화장동 성산공원 호수 앞 조용한 북카페 독서 모임 📚',
        'location': '전남 여수시 화장동 성산공원 인근',
        'category': '문화 & 엔터 > 북카페 & 독서',
        'poster': 'assets/images/cover_cafe.jpg',
      }
    },
  ];

  List<Map<String, dynamic>> _getActiveCommunityPosts() {
    final clean = _currentLocation.trim();
    if (clean.contains('여수') || clean.contains('화장동')) {
      return _yeosuCommunityPosts;
    }
    return _communityPosts;
  }

  int _calculateLocationRelevanceScore(String itemLocation) {
    if (itemLocation.isEmpty || _currentLocation.isEmpty) return 0;
    final current = _currentLocation.trim();
    final parts = current
        .replaceAll('(', ' ')
        .replaceAll(')', ' ')
        .split(' ')
        .where((s) => s.isNotEmpty)
        .toList();

    // 1. Exact dong match (e.g. '화장동', '서교동') -> Highest priority (Score 3)
    for (final p in parts.reversed) {
      if (p.endsWith('동') ||
          p.endsWith('읍') ||
          p.endsWith('면') ||
          p.endsWith('가')) {
        if (itemLocation.contains(p)) {
          return 3;
        }
      }
    }

    // 2. District / City match (e.g. '여수시', '여수', '마포구', '마포') -> Score 2
    for (final p in parts) {
      final clean = p
          .replaceAll('전남', '')
          .replaceAll('전라남도', '')
          .replaceAll('서울특별시', '')
          .replaceAll('서울', '')
          .replaceAll('시', '')
          .replaceAll('구', '')
          .replaceAll('군', '')
          .trim();
      if (itemLocation.contains(p) ||
          (clean.length >= 2 && itemLocation.contains(clean))) {
        return 2;
      }
    }

    // 3. Fallback: contains any part
    for (final p in parts) {
      if (p.length >= 2 && itemLocation.contains(p)) {
        return 1;
      }
    }

    return 0;
  }

  String _currentLocation = '마포구 서교동';
  String? _selectedVibe;
  int _selectedCategoryIndex = 0;
  String _selectedSubCategory = '전체';
  String _selectedTrendCategory = '전체';
  int _trendPageIndex = 0;
  bool _isTrendExpanded = false;
  final PageController _trendPageController = PageController();
  Stream<QuerySnapshot>? _meetupStream;
  Stream<QuerySnapshot>? _trendStream;
  List<Map<String, dynamic>> _lastTrendItems = [];
  bool _showAllMeetups = false;
  int get _initialMeetupCount => _selectedCategoryIndex == 0 ? 4 : 6;
  Position? _devicePosition;
  final Map<String, Future<KakaoPlace?>> _placeLookupCache = {};
  bool _isListView = false;
  bool _isSubCategoryExpanded = false;

  void _resetAllMeetupFilters() {
    setState(() {
      _selectedCategoryIndex = 0;
      _selectedSubCategory = '전체';
      _selectedVibe = null;
      _isSubCategoryExpanded = false;
    });
  }

  final List<Map<String, dynamic>> _categories = [
    {'icon': '🔥', 'name': '전체', 'desc': '실시간 전체 모임 & 트렌드 큐레이션'},
    {'icon': '⚡', 'name': '오늘 번개', 'desc': '오늘 밤·이번 주말 당장 만나는 당일 오프라인 번개'},
    {'icon': '☕', 'name': '취향 아지트', 'desc': '취미, 공연, 전시, 보드게임, 독서 등 취향 기반 모임'},
    {
      'icon': '🏃‍♂️',
      'name': '라이프 메이트',
      'desc': '1인 가구, 동성 친구, 일상 액티비티 생활 밀착형 모임'
    },
  ];

  static const Map<String, List<String>> _officialSubCategories = {
    '오늘 번개': ['혼술바동행', '불금코노·술', '맛집털기', '오늘번개', '심야드라이브', '야식팟'],
    '취향 아지트': ['공연·전시', '카페·디저트', '보드게임·방탈출', '북카페·독서', 'LP청음', '원데이클래스'],
    '라이프 메이트': ['러닝·운동', '1인가구장보기/소분', '동성캠핑', '동네산책', '헬스메이트', '반려동물산책'],
  };

  // 전국 시·도 및 읍면동 핫스팟 리스트
  static const Map<String, List<String>> _nationwideRegions = {
    '서울': [
      '마포구 서교동',
      '마포구 연남동',
      '마포구 망원동',
      '마포구 합정동',
      '성동구 성수동',
      '용산구 한남동',
      '용산구 이태원동',
      '강남구 신사동',
      '강남구 역삼동',
      '송파구 잠실동',
      '영등포구 여의도동',
      '중구 을지로동',
      '종로구 익선동',
      '광진구 자양동(건대)',
    ],
    '경기/인천': [
      '성남시 분당구 판교동',
      '성남시 분당구 정자동',
      '수원시 영통구 광교동',
      '고양시 일산동구 장항동',
      '인천 연수구 송도동',
      '하남시 미사동',
      '용인시 수지구 풍덕천동',
      '안양시 동안구 평촌동',
      '부천시 원미구 중동',
    ],
    '부산/경상': [
      '부산 해운대구 우동',
      '부산 해운대구 중동',
      '부산 부산진구 전포동',
      '부산 수영구 광안동',
      '대구 수성구 범어동',
      '대구 중구 동성로',
      '울산 남구 삼산동',
      '창원시 성산구 상남동',
    ],
    '대전/충청': [
      '대전 유성구 봉명동',
      '대전 서구 둔산동',
      '세종시 나성동',
      '청주시 상당구 성안동',
      '천안시 서북구 불당동',
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
      '강릉시 교동',
      '속초시 조양동',
      '춘천시 효자동',
      '제주시 노형동',
      '제주시 연동',
      '제주시 아라동',
      '서귀포시 중문동',
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
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                            color: const Color(0xFFE5E5EA),
                            borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text('우리 동네 설정',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: textPrimary)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: const Color(0xFFFFF0EB),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text('전국 지원',
                              style: TextStyle(
                                  color: coralAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('내 위치를 공유하거나 원하는 동네를 검색해보세요.',
                        style: TextStyle(fontSize: 13, color: textSecondary)),
                    const SizedBox(height: 16),

                    // 1. GPS 현재 위치로 찾기 Button (실제 GPS + 역지오코딩 연동)
                    GestureDetector(
                      onTap: isGpsLocating
                          ? null
                          : () async {
                              setModalState(() => isGpsLocating = true);
                              final detected =
                                  await LocationHelper.getCurrentDongName();
                              setModalState(() => isGpsLocating = false);

                              if (detected != null && detected.isNotEmpty) {
                                setState(() {
                                  _currentLocation = detected;
                                });
                                globalData.updateLocation(detected);
                                _loadDevicePosition();
                                try {
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(globalData.activeUserId)
                                      .set({
                                    'location': detected,
                                    'updatedAt': FieldValue.serverTimestamp(),
                                  }, SetOptions(merge: true));
                                } catch (_) {}
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.my_location,
                                            color: Colors.white, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                            child: Text(
                                                '📍 내 현재 위치 자동 할당 완료: $detected')),
                                      ],
                                    ),
                                    backgroundColor: coralAccent,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          '⚠️ 위치 권한을 확인해주시거나 동네를 직접 검색해주세요.')),
                                );
                              }
                            },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF4EE), Color(0xFFFFECE5)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: coralAccent.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isGpsLocating)
                              const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Color(0xFFF25767)))
                            else
                              Icon(Icons.my_location,
                                  color: coralAccent, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              isGpsLocating
                                  ? 'GPS 위치 확인 및 동네 분석 중...'
                                  : '현재 위치로 동네 자동 찾기 (GPS 연동)',
                              style: TextStyle(
                                  color: coralAccent,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14),
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
                        hintStyle:
                            TextStyle(fontSize: 13, color: textSecondary),
                        prefixIcon: const Icon(Icons.search,
                            size: 20, color: Color(0xFF8E8E93)),
                        filled: true,
                        fillColor: surfaceColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none),
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
                              onTap: () =>
                                  setModalState(() => selectedRegionTab = reg),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? const Color(0xFF1E1E24)
                                      : surfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  reg,
                                  style: TextStyle(
                                    color: isSel ? Colors.white : textPrimary,
                                    fontWeight: isSel
                                        ? FontWeight.bold
                                        : FontWeight.w500,
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
                                  Icon(Icons.search_off,
                                      size: 40, color: textSecondary),
                                  const SizedBox(height: 8),
                                  Text('\'$searchQuery\' 검색 결과가 없습니다.',
                                      style: TextStyle(
                                          color: textSecondary, fontSize: 13)),
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
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  leading: Icon(
                                    Icons.location_on,
                                    color: isSelected
                                        ? coralAccent
                                        : const Color(0xFFC7C7CC),
                                    size: 20,
                                  ),
                                  title: Text(
                                    dong,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? coralAccent
                                          : textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(Icons.check_circle,
                                          color: coralAccent, size: 20)
                                      : null,
                                  onTap: () {
                                    setState(() => _currentLocation = dong);
                                    globalData.updateLocation(dong);
                                    try {
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(globalData.activeUserId)
                                          .set({
                                        'location': dong,
                                        'updatedAt':
                                            FieldValue.serverTimestamp(),
                                      }, SetOptions(merge: true));
                                    } catch (_) {}
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('📍 $dong(으)로 동네를 변경했어요')),
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
    if (globalData.userLocation.value.isNotEmpty) {
      _currentLocation = globalData.userLocation.value;
    }
    _homeDashboardTab = widget.initialTab;
    // Demo data must never be created as a side effect of opening production.
    if (const bool.fromEnvironment('OOMU_SEED_DEMO_DATA')) {
      _seedDatabase();
    }
    _loadUserLocation();
    _loadDevicePosition();
    globalData.userLocation.addListener(_onGlobalLocationChanged);
    globalData.currentUserId.addListener(_onActiveUserChanged);
  }

  int _locationLoadGeneration = 0;

  void _onActiveUserChanged() {
    if (mounted) {
      final targetLoc = globalData.userLocation.value.isNotEmpty
          ? globalData.userLocation.value
          : '마포구 서교동';
      if (_currentLocation != targetLoc) {
        setState(() {
          _currentLocation = targetLoc;
        });
      }
      _loadUserLocation();
    }
  }

  void _onGlobalLocationChanged() {
    if (!mounted) return;
    final targetLoc = globalData.userLocation.value.isNotEmpty
        ? globalData.userLocation.value
        : '마포구 서교동';
    if (_currentLocation != targetLoc) {
      setState(() {
        _currentLocation = targetLoc;
      });
    }
  }

  Future<void> _loadUserLocation() async {
    final int reqGen = ++_locationLoadGeneration;
    final int reqSession = globalData.sessionGeneration;
    if (Firebase.apps.isEmpty) return;
    try {
      final activeUid = globalData.activeUserId;
      final uid = (activeUid.isNotEmpty && activeUid != 'guest')
          ? activeUid
          : (FirebaseAuth.instance.currentUser?.uid ?? '');
      if (uid.isNotEmpty && uid != 'guest') {
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (!mounted ||
            reqGen != _locationLoadGeneration ||
            !globalData.isActiveSession(reqSession, uid)) {
          return;
        }
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final loc = data['location'] as String?;
          if (loc != null && loc.trim().isNotEmpty) {
            final trimmedLoc = loc.trim();
            if (mounted) {
              setState(() {
                _currentLocation = trimmedLoc;
              });
            }
            globalData.userLocation.value = trimmedLoc;
          }
          final nick = data['nickname'] as String?;
          if (nick != null && nick.trim().isNotEmpty) {
            globalData.userNickname.value = nick.trim();
          }
          final avatar = (data['photoUrl'] ??
                  data['profileImage'] ??
                  data['avatarUrl'] ??
                  data['authorAvatar'])
              ?.toString()
              .trim();
          if (avatar != null && avatar.isNotEmpty) {
            globalData.userAvatar.value = avatar;
          }
        }
      }
    } catch (e) {
      debugPrint('[HomeScreen] _loadUserLocation error: $e');
    }
  }

  Future<void> _loadDevicePosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(timeLimit: Duration(seconds: 6)),
      );
      if (mounted) {
        setState(() => _devicePosition = position);
      }
    } catch (_) {
      // Permission, GPS and web browser errors leave distance hidden.
    }
  }

  String? _meetupDistance(Map<String, dynamic> meetup,
      {({double lat, double lng})? resolvedCoords}) {
    final position = _devicePosition;
    final coords = OomuUiHelpers.extractValidCoords(meetup) ?? resolvedCoords;
    if (position == null || coords == null) return null;
    final meters = KakaoMapService.calculateDistanceInMeters(
      position.latitude,
      position.longitude,
      coords.lat,
      coords.lng,
    );
    return '내 위치에서 ${KakaoMapService.formatDistance(meters)}';
  }

  Widget _buildMeetupDistance(Map<String, dynamic> meetup) {
    if (_devicePosition == null) return const SizedBox.shrink();
    final savedDistance = _meetupDistance(meetup);
    if (savedDistance != null) {
      return Text(savedDistance,
          style: TextStyle(fontSize: 12, color: textSecondary));
    }
    final location = (meetup['location'] ?? '').toString().trim();
    if (location.isEmpty) return const SizedBox.shrink();
    final lookup = _placeLookupCache.putIfAbsent(
      location,
      () => KakaoMapService.resolveVerifiedPlace(location),
    );
    return FutureBuilder<KakaoPlace?>(
      future: lookup,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(height: 17);
        }
        final place = snapshot.data;
        final distance = place != null && place.hasValidCoords
            ? _meetupDistance(meetup,
                resolvedCoords: (lat: place.lat, lng: place.lng))
            : null;
        return Text(distance ?? '정확한 장소 거리 확인 불가',
            style: TextStyle(fontSize: 12, color: textSecondary));
      },
    );
  }

  Widget _buildMeetupMoreButton(int total) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: OutlinedButton(
          onPressed: () => setState(() => _showAllMeetups = !_showAllMeetups),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            foregroundColor: textPrimary,
            side: const BorderSide(color: Color(0xFFEAECF0)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(_showAllMeetups
              ? '모임 접기'
              : '모임 더보기 · ${total - _initialMeetupCount}개'),
        ),
      );

  @override
  void dispose() {
    globalData.userLocation.removeListener(_onGlobalLocationChanged);
    globalData.currentUserId.removeListener(_onActiveUserChanged);
    _trendPageController.dispose();
    super.dispose();
  }

  Future<void> _seedDatabase() async {
    try {
      var snapshot =
          await FirebaseFirestore.instance.collection('meetups').limit(1).get();
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
            'tags': [
              '주말 마라탕&엽떡 모임',
              '동네 핫플 메뉴 털기',
              '소셜다이닝',
              '소소하게',
              '메이트',
              '홍대맛집',
              '동네찐친'
            ],
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
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 12),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: coralAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('⚡ 오늘 번개',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '지금 내 주변 즉시 번개',
                            style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                                color: textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '10~30분 내 바로 합류할 수 있는 동네 즉석 팟',
                      style: TextStyle(
                          fontSize: 11.5,
                          color: textSecondary,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SoSoSpotScreen())),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('전체 지도',
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4E5968))),
                      Icon(Icons.chevron_right,
                          size: 14, color: Color(0xFF4E5968)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final double cardWidth =
                ((constraints.maxWidth - 52) / 2).clamp(150.0, 260.0);
            final currentLiveSpots = _getLiveSpotsForLocation(_currentLocation);
            return SizedBox(
              height: 184,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: currentLiveSpots.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final spot = currentLiveSpots[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  SoSoSpotDetailScreen(spot: spot)));
                    },
                    child: Container(
                      width: cardWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFEAECF0), width: 1.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
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
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15)),
                                child: Image(
                                  image: appImg(spot['image']),
                                  width: cardWidth,
                                  height: 84,
                                  fit: BoxFit.cover,
                                  alignment: (spot['image'] ?? '')
                                          .toString()
                                          .contains('cover_running')
                                      ? const Alignment(0, 0.55)
                                      : Alignment.center,
                                ),
                              ),
                              Container(
                                height: 84,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(15)),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withValues(alpha: 0.45),
                                      Colors.transparent
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: coralAccent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.bolt_rounded,
                                          size: 12, color: Colors.white),
                                      const SizedBox(width: 3),
                                      Text(
                                        (spot['timeLeft'] ?? '오늘 번개')
                                            .toString(),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    (spot['distance'] ?? '동네 모임').toString(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // 하단 정보
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    OomuUiHelpers.formatTitle(spot['title']),
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                        height: 1.28),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 9,
                                              backgroundImage:
                                                  appImg(spot['hostAvatar']),
                                            ),
                                            const SizedBox(width: 5),
                                            Flexible(
                                              child: Text(
                                                spot['host'],
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: textSecondary,
                                                    fontWeight:
                                                        FontWeight.w600),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF2F4F7),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          '${spot['members']} 참여',
                                          style: const TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF4E5968)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
    final parts = cleanLoc
        .replaceAll('(', ' ')
        .replaceAll(')', ' ')
        .split(' ')
        .where((s) => s.isNotEmpty)
        .toList();
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
          'description':
              '화장동 선소상가 신상 대형 베이커리 카페로 매일 아침 구워내는 겉바속촉 수제 소금빵과 스페셜티 커피를 맛볼 수 있습니다. 쾌적한 좌석과 따뜻한 우드 인테리어로 동네 이웃과 소소한 대화를 나누기 좋습니다.',
        },
        {
          'id': 'my_yeosu_02',
          'title': '여수 이순신광장 원조 딸기모찌 & 돌산 갓버터도나스 디저트 투어',
          'category': '일상 & 푸드 > 카페 & 디저트',
          'location': '전남 여수시 교동 이순신광장 ($cleanLoc 출발)',
          'tag': '🍓 여수 디저트 1위',
          'vibe': '소소하게',
          'poster': 'assets/images/cover_cafe.jpg',
          'period': '이번 주말 오후 2시',
          'rank': 2,
          'isMyNeighborhood': true,
          'isHotspot': true,
          'description':
              '여수 중앙동 이순신광장의 대표 명물로 손꼽히는 수제 딸기모찌 본점입니다. 얇고 쫀득한 찹쌀떡 속에 신선한 생딸기와 백앙금·팥앙금이 가득 차 있어 달콤상큼한 풍미를 자랑합니다. 인근 돌산 갓버터도나스와 함께 둘러보는 여수 필수 디저트 코스입니다.',
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
          'description':
              '웅천친수공원 바로 앞에 위치한 오션뷰 브런치 카페로, 탁 트인 에메랄드빛 바다 전망을 감상하며 갓 구운 바게트와 부드러운 카이막, 시그니처 크림라떼를 즐길 수 있는 힐링 핫플레이스입니다.',
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
          'description':
              'SNS에서 연일 화제인 두바이 피스타치오 카다이프 쫀득 쿠키(두쫀쿠)를 여수 현지에서 맛볼 수 있는 감성 디저트 숍입니다. 바삭한 카다이프 면과 진한 피스타치오 스프레드의 조화가 일품입니다.',
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
          'description':
              '바다 위를 가로지르는 여수의 랜드마크 소호동동다리입니다. 해질녘 노을과 수변을 비추는 은은한 야간 LED 조명이 어우러져, 초보자도 무리 없이 기분 좋게 5km를 달리고 걸을 수 있는 여수 최고의 힐링 러닝 스팟입니다.',
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
        'poster': 'assets/images/cover_cafe.jpg',
        'period': '상시 · 주말 투어',
        'rank': 25,
        'isHotspot': true,
        'description':
            '여수 이순신광장의 명물 수제 생딸기모찌 본점입니다. 얇고 쫀득한 찹쌀떡 안에 생딸기와 백앙금이 어우러져 전국 디저트 러버들이 오픈런하는 필수 코스입니다. 돌산 갓버터도나스와 함께 달콤한 투어를 즐겨보세요.',
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
      // 스포츠 (KBO 프로야구 직관 & K리그 축구) 시드
      {
        'id': 'sports_guaranteed_01',
        'title': '[KBO 프로야구] LG 트윈스 vs 두산 베어스 잠실 더비 3루 네이비석 직관 & 치맥 파티',
        'category': '스포츠 > KBO 프로야구 직관',
        'location': '서울 송파구 잠실야구장',
        'tag': '⚾ KBO 잠실더비',
        'vibe': '활기찬',
        'poster': 'assets/images/cover_running.jpg',
        'period': '주말 직관 팟',
        'rank': 28,
      },
      {
        'id': 'sports_guaranteed_02',
        'title': '[KBO 프로야구] 기아 타이거즈 vs 한화 이글스 주말 원정 응원단 & 챔피언스필드 직관',
        'category': '스포츠 > KBO 프로야구 직관',
        'location': '광주 북구 광주기아챔피언스필드',
        'tag': '⚾ 호랑이 군단 직관',
        'vibe': '활기찬',
        'poster': 'assets/images/cover_running.jpg',
        'period': '이번 주말 경기',
        'rank': 29,
      },
      {
        'id': 'sports_guaranteed_03',
        'title': '[KBO 프로야구] 삼성 라이온즈 vs 롯데 자이언츠 클래식 시리즈 사직 원정 응원 팟',
        'category': '스포츠 > KBO 프로야구 직관',
        'location': '부산 동래구 사직야구장',
        'tag': '⚾ 클래식 시리즈',
        'vibe': '활기찬',
        'poster': 'assets/images/cover_running.jpg',
        'period': '주말 원정 팟',
        'rank': 30,
      },
      {
        'id': 'sports_guaranteed_04',
        'title': '[K리그 축구] FC 서울 vs 전북 현대 서울월드컵경기장 슈퍼매치 N석 응원전',
        'category': '스포츠 > K리그 축구',
        'location': '서울 마포구 서울월드컵경기장',
        'tag': '⚽ K리그 슈퍼매치',
        'vibe': '활기찬',
        'poster': 'assets/images/cover_running.jpg',
        'period': '토요일 16:30',
        'rank': 31,
      },
      {
        'id': 'sports_guaranteed_05',
        'title': '[K리그 축구] 울산 HD vs 포항 스틸러스 동해안 더비 문수경기장 라이브 직관',
        'category': '스포츠 > K리그 축구',
        'location': '울산 남구 울산문수축구경기장',
        'tag': '⚽ 동해안 더비',
        'vibe': '활기찬',
        'poster': 'assets/images/cover_running.jpg',
        'period': '일요일 14:00',
        'rank': 32,
      },
      // 실시간 박스오피스 영화 시드
      {
        'id': 'movie_guaranteed_01',
        'title': '[실시간 박스오피스 1위] 최신 개봉 대작 관람 & CGV 아이맥스 팝콘 메이트',
        'category': '문화 & 엔터 > 영화·CGV',
        'location': '전국 CGV · 롯데시네마 · 메가박스',
        'tag': '🎬 박스오피스 1위',
        'vibe': '소소하게',
        'poster': 'assets/images/cover_wine.jpg',
        'period': '절찬 상영 중',
        'rank': 33,
      },
      {
        'id': 'movie_guaranteed_02',
        'title': '[실시간 박스오피스 2위] 감성 로맨스 영화 보고 심야 맥주 한잔할 동네 친구',
        'category': '문화 & 엔터 > 영화·CGV',
        'location': '전국 멀티플렉스 극장가',
        'tag': '🎬 심야 영화 번개',
        'vibe': '소소하게',
        'poster': 'assets/images/cover_wine.jpg',
        'period': '절찬 상영 중',
        'rank': 34,
      },
      {
        'id': 'movie_guaranteed_03',
        'title': '[실시간 박스오피스 3위] 주말 조조 영화 번개 & 메가박스 돌비시네마 직관',
        'category': '문화 & 엔터 > 영화·CGV',
        'location': '메가박스 코엑스 / 스타필드',
        'tag': '🎬 돌비시네마 사운드',
        'vibe': '소소하게',
        'poster': 'assets/images/cover_wine.jpg',
        'period': '주말 조조',
        'rank': 35,
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
    final basePrimary =
        (primaryCity.endsWith('시') || primaryCity.endsWith('구')) &&
                primaryCity.length > 2
            ? primaryCity.substring(0, primaryCity.length - 1)
            : primaryCity;

    final combined = [
      item['location'] ?? '',
      item['venue'] ?? '',
      item['city'] ?? '',
      item['province'] ?? '',
      item['tag'] ?? '',
      item['title'] ?? '',
      ...(item['regionAliases'] is List
          ? (item['regionAliases'] as List)
          : const []),
    ].join(' ');

    return combined.contains(primaryCity) ||
        (basePrimary.length >= 2 && combined.contains(basePrimary));
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
      return cat.contains('콘서트') ||
          tag.contains('콘서트') ||
          title.toUpperCase().contains('CONCERT') ||
          title.contains('투어 콘서트');
    } else if (filter == '뮤지컬') {
      return cat.contains('뮤지컬') ||
          tag.contains('뮤지컬') ||
          title.contains('스위니토드') ||
          title.contains('지킬') ||
          title.contains('오페라') ||
          title.contains('알라딘') ||
          title.contains('시카고') ||
          title.contains('위키드');
    } else if (filter == '페스티벌') {
      return cat.contains('페스티벌') ||
          tag.contains('페스티벌') ||
          tag.contains('대표축제') ||
          tag.contains('지역축제') ||
          title.toUpperCase().contains('FESTIVAL') ||
          title.contains('범음악제') ||
          title.contains('페스티벌') ||
          title.contains('불꽃축제');
    } else if (filter == '핫플·팝업') {
      return isHotspot ||
          cat.contains('다이닝') ||
          cat.contains('팝업') ||
          cat.contains('LP') ||
          cat.contains('카페') ||
          tag.contains('핫플') ||
          tag.contains('소금빵') ||
          tag.contains('두쫀쿠') ||
          tag.contains('SNS');
    } else if (filter == '⚾ 스포츠') {
      return cat.contains('스포츠') ||
          cat.contains('야구') ||
          cat.contains('축구') ||
          tag.contains('스포츠') ||
          tag.contains('직관') ||
          tag.contains('KBO') ||
          tag.contains('K리그') ||
          title.contains('야구') ||
          title.contains('축구') ||
          title.contains('KBO') ||
          title.contains('K리그') ||
          title.contains('트윈스') ||
          title.contains('타이거즈') ||
          title.contains('라이온즈') ||
          title.contains('이글스') ||
          title.contains('베어스') ||
          title.contains('랜더스') ||
          title.contains('FC') ||
          title.contains('더비');
    } else if (filter == '🎬 영화') {
      return cat.contains('영화') ||
          cat.contains('CGV') ||
          cat.contains('시네마') ||
          tag.contains('영화') ||
          tag.contains('박스오피스') ||
          tag.contains('무비') ||
          title.contains('박스오피스') ||
          title.contains('영화') ||
          title.contains('극장') ||
          title.contains('CGV') ||
          title.contains('시네마') ||
          title.contains('메가박스');
    }
    return true;
  }

  void _showAllTrendsBottomSheet(
      BuildContext context, List<Map<String, dynamic>> items) {
    String modalFilter = _selectedTrendCategory;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final modalFiltered = items
              .where((it) => _matchesTrendFilter(it, modalFilter))
              .toList();
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
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
                                    '공연·전시와 동네 발견',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: textPrimary),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF0EB),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${items.length}개',
                                      style: TextStyle(
                                          color: coralAccent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '관심 가는 공연과 장소를 둘러보세요',
                                style: TextStyle(
                                    fontSize: 12, color: textSecondary),
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
                      children: [
                        '전체',
                        '📍 우리동네',
                        '콘서트',
                        '뮤지컬',
                        '페스티벌',
                        '⚾ 스포츠',
                        '🎬 영화',
                        '핫플·팝업'
                      ].map((c) {
                        final isSel = modalFilter == c;
                        final count = items
                            .where((it) => _matchesTrendFilter(it, c))
                            .length;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() {
                                modalFilter = c;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? const Color(0xFF221B1D)
                                    : const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSel
                                      ? const Color(0xFF221B1D)
                                      : const Color(0xFFEBEBF0),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    c,
                                    style: TextStyle(
                                      color: isSel
                                          ? Colors.white
                                          : const Color(0xFF635559),
                                      fontWeight: isSel
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$count',
                                    style: TextStyle(
                                      color: isSel
                                          ? const Color(0xFFFFB4A8)
                                          : const Color(0xFF9E9EA7),
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
                  const Divider(
                      height: 20, thickness: 1, color: Color(0xFFF0F0F5)),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      itemCount: modalFiltered.length,
                      separatorBuilder: (_, __) => const Divider(
                          height: 20, thickness: 1, color: Color(0xFFF5F5FA)),
                      itemBuilder: (context, idx) {
                        final item = modalFiltered[idx];
                        final title = item['title']?.toString() ?? '';
                        final location = item['location']?.toString() ??
                            item['venue']?.toString() ??
                            '';
                        final category =
                            item['category']?.toString() ?? '문화 & 엔터';
                        final tag = item['tag']?.toString() ?? '가볼 만한 곳';
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
                              border:
                                  Border.all(color: const Color(0xFFEBEBF0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
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
                                          image: appImg(poster.isNotEmpty
                                              ? poster
                                              : 'assets/images/cover_food.jpg'),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Image.asset(
                                                  'assets/images/cover_wine.jpg',
                                                  fit: BoxFit.cover),
                                        ),
                                      ),
                                      Positioned(
                                        top: 6,
                                        left: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: rank <= 3
                                                ? coralAccent
                                                : const Color(0xFF1E1E24)
                                                    .withValues(alpha: 0.85),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item['isSuggested'] == true
                                                ? '아이디어'
                                                : '$rank위',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF0EB),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              tag,
                                              style: TextStyle(
                                                  color: coralAccent,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              category,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: textSecondary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        title,
                                        style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                            color: textPrimary,
                                            height: 1.25),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on_rounded,
                                              size: 15, color: coralAccent),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                              location,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: textSecondary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(
                                              Icons.calendar_month_rounded,
                                              size: 14,
                                              color: Color(0xFF3B82F6)),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                              period,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: textSecondary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
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

  Widget _buildTrendMoreCard(
      BuildContext context, int totalCount, List<Map<String, dynamic>> items) {
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
              color: Colors.black.withValues(alpha: 0.04),
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
                border: Border.all(color: coralAccent.withValues(alpha: 0.3)),
              ),
              child:
                  Icon(Icons.grid_view_rounded, color: coralAccent, size: 22),
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
                style: TextStyle(
                    fontSize: 11,
                    color: coralAccent,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleTrendCard(
      BuildContext context, Map<String, dynamic> item, int index) {
    final title = item['title']?.toString() ?? '';
    final location =
        item['location']?.toString() ?? item['venue']?.toString() ?? '';
    final category = item['category']?.toString() ?? '문화 & 엔터';
    final tag = item['tag']?.toString() ?? '가볼 만한 곳';
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
              color: Colors.black.withValues(alpha: 0.04),
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(19)),
              child: Stack(
                children: [
                  SizedBox(
                    height: 132,
                    width: double.infinity,
                    child: Image(
                      image: appImg(poster.isNotEmpty
                          ? poster
                          : 'assets/images/cover_food.jpg'),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: rank <= 3
                            ? coralAccent
                            : const Color(0xFF1E1E24).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
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
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: coralAccent),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 38,
                    child: BalancedText(
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
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 14, color: textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_month_rounded,
                          size: 15, color: textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          period,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: textSecondary),
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
                    backgroundColor: const Color(0xFFF2F4F7),
                    foregroundColor: textPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailScreen(event: item),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_forward_rounded, size: 14),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '자세히 보기',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11.5, fontWeight: FontWeight.w800),
                        ),
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
        'poster':
            'https://wsrv.nl/?url=https%3A%2F%2Fwww.kopis.or.kr%2Fupload%2FpfmPoster%2FPF_PF303043_261012_171201.gif&w=600&q=85&output=jpg',
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
        'poster':
            'https://wsrv.nl/?url=https%3A%2F%2Fwww.kopis.or.kr%2Fupload%2FpfmPoster%2FPF_PF302745_261007_145954.gif&w=600&q=85&output=jpg',
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
      if (Firebase.apps.isNotEmpty) {
        trendStream = _trendStream ??= FirebaseFirestore.instance
            .collection('trend_events')
            .orderBy('rank')
            .snapshots();
      }
    } catch (_) {}

    return StreamBuilder<QuerySnapshot>(
      stream: trendStream,
      builder: (context, snapshot) {
        List<Map<String, dynamic>> rawItems = [];
        if (snapshot.hasData) {
          rawItems = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
          _lastTrendItems = rawItems;
        } else if (_lastTrendItems.isNotEmpty) {
          rawItems = _lastTrendItems;
        } else if (!const bool.fromEnvironment('dart.vm.product')) {
          rawItems = List<Map<String, dynamic>>.from(fallbackTrends);
        }

        final myLocalItems =
            _buildMyNeighborhoodEvents(_currentLocation).take(3).map((item) {
          final title = (item['title'] ?? '').toString();
          return <String, dynamic>{
            ...item,
            'isSuggested': true,
            'tag': '동네 탐색 아이디어',
            'period': '방문 전 정보 확인',
            if (title.contains('소금빵'))
              'poster': 'assets/images/cover_salt_bread.jpg'
            else if (title.contains('모찌') ||
                title.contains('도나스') ||
                title.contains('디저트'))
              'poster': 'assets/images/cover_cafe.jpg',
          };
        }).toList();
        final guaranteedPool = _getGuaranteedRichCategoryPool();
        final Set<String> seenTitles = {};
        final List<Map<String, dynamic>> items = [];

        for (final it in [...myLocalItems, ...rawItems, ...guaranteedPool]) {
          final t = (it['title'] ?? '').toString().trim();
          if (t.isEmpty || seenTitles.contains(t)) continue;
          seenTitles.add(t);
          items.add(it);
        }

        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Text('지금 확인할 수 있는 공연·동네 정보가 없어요.'),
          );
        }

        final filteredItems = items
            .where((it) => _matchesTrendFilter(it, _selectedTrendCategory))
            .toList()
          ..sort((a, b) {
            final aLocal = a['isSuggested'] == true
                ? 1
                : (_isMyNeighborhoodEvent(a) ? 0 : 2);

            final bLocal = b['isSuggested'] == true
                ? 1
                : (_isMyNeighborhoodEvent(b) ? 0 : 2);

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
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 18, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '공연·전시와 동네 발견',
                          style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '공연·전시와 동네 핫플을 가볍게 둘러보세요.',
                          style: TextStyle(
                              fontSize: 11.5,
                              color: textSecondary,
                              fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
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
                          Icon(Icons.chevron_right_rounded,
                              size: 17, color: textSecondary),
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
                  children: [
                    '전체',
                    '📍 우리동네',
                    '콘서트',
                    '뮤지컬',
                    '페스티벌',
                    '⚾ 스포츠',
                    '🎬 영화',
                    '핫플·팝업'
                  ].map((c) {
                    final bool isSel = _selectedTrendCategory == c;
                    final int count =
                        items.where((it) => _matchesTrendFilter(it, c)).length;
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                isSel ? const Color(0xFF221B1D) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSel
                                  ? const Color(0xFF221B1D)
                                  : const Color(0xFFEBEBF0),
                              width: 1.1,
                            ),
                            boxShadow: isSel
                                ? [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.12),
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
                                  fontWeight:
                                      isSel ? FontWeight.w800 : FontWeight.w600,
                                  color: isSel
                                      ? Colors.white
                                      : const Color(0xFF635559),
                                ),
                              ),
                              if (count > 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '$count',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: isSel
                                        ? const Color(0xFFFFB4A8)
                                        : const Color(0xFF9E9EA7),
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
                    final Map<String, dynamic>? lItem =
                        sIdx < filteredItems.length
                            ? filteredItems[sIdx]
                            : null;
                    final Map<String, dynamic>? rItem =
                        (sIdx + 1) < filteredItems.length
                            ? filteredItems[sIdx + 1]
                            : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: lItem != null
                                ? _buildSingleTrendCard(context, lItem, sIdx)
                                : _buildTrendMoreCard(
                                    context, items.length, items),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: rItem != null
                                ? _buildSingleTrendCard(
                                    context, rItem, sIdx + 1)
                                : _buildTrendMoreCard(
                                    context, items.length, items),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // 위피 / 문토 / 당근 스타일 미니멀 슬림 도트 인디케이터
              if (totalPages > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      '${safePage + 1} / $totalPages',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textSecondary),
                    ),
                  ),
                )
              else if (totalPages > 1)
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
                            color: isActive
                                ? coralAccent
                                : const Color(0xFFE0D8DA),
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
                    final Map<String, dynamic>? lItem =
                        sIdx < filteredItems.length
                            ? filteredItems[sIdx]
                            : null;
                    final Map<String, dynamic>? rItem =
                        (sIdx + 1) < filteredItems.length
                            ? filteredItems[sIdx + 1]
                            : null;
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: rowIdx < expandedRowCount - 1 ? 12 : 0),
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
                                ? _buildSingleTrendCard(
                                    context, rItem, sIdx + 1)
                                : _buildTrendMoreCard(
                                    context, items.length, items),
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
                      border: Border.all(
                          color: const Color(0xFFEAE2E4), width: 1.1),
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
                          _isTrendExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
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
      subList = [
        '전체',
        '오늘번개',
        '맛집털기',
        '카페·디저트',
        '공연·전시',
        '보드게임·방탈출',
        '러닝·운동',
        '1인가구장보기/소분'
      ];
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
                style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
          if (!_isSubCategoryExpanded)
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: subList.length,
                      itemBuilder: (context, idx) {
                        final subName = subList[idx];
                        final isSubSelected = _selectedSubCategory == subName;
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () =>
                              setState(() => _selectedSubCategory = subName),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                                minWidth: 48, minHeight: 48),
                            child: Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isSubSelected
                                      ? textPrimary
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSubSelected
                                        ? textPrimary
                                        : const Color(0xFFEAECF0),
                                  ),
                                ),
                                child: Text(
                                  subName == '전체' ? '전체' : '#$subName',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSubSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isSubSelected
                                        ? Colors.white
                                        : const Color(0xFF4E5968),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _isSubCategoryExpanded = true),
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: 48, minHeight: 48),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F7),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('+더보기',
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF4E5968))),
                              Icon(Icons.keyboard_arrow_down,
                                  size: 14, color: Color(0xFF4E5968)),
                            ],
                          ),
                        ),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEAECF0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$mainCatName 서브태그 선택',
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: textPrimary)),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () =>
                            setState(() => _isSubCategoryExpanded = false),
                        child: ConstrainedBox(
                          constraints:
                              const BoxConstraints(minWidth: 48, minHeight: 48),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('접기',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF666677))),
                              Icon(Icons.keyboard_arrow_up,
                                  size: 16, color: Color(0xFF666677)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: subList.map((subName) {
                      final isSubSelected = _selectedSubCategory == subName;
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() {
                          _selectedSubCategory = subName;
                          _isSubCategoryExpanded = false;
                        }),
                        child: ConstrainedBox(
                          constraints:
                              const BoxConstraints(minWidth: 48, minHeight: 48),
                          child: Center(
                            widthFactor: 1.0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color:
                                    isSubSelected ? textPrimary : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSubSelected
                                      ? textPrimary
                                      : const Color(0xFFEFE4E6),
                                ),
                              ),
                              child: Text(
                                subName == '전체' ? '전체' : '#$subName',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: isSubSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isSubSelected
                                      ? Colors.white
                                      : textSecondary,
                                ),
                              ),
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
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '대분류 ➔ 중분류 ➔ 소분류로 원하는 모임을 탐색하세요',
                            style:
                                TextStyle(fontSize: 12, color: textSecondary),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {
                              _resetAllMeetupFilters();
                              Navigator.pop(ctx);
                            },
                            child: Text(
                              '필터 초기화',
                              style: TextStyle(
                                color: coralAccent,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    children: [
                      Text('📱 지금 내 상황 (분위기)',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textPrimary)),
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
                      Text('🏷️ 전체 카테고리 목록 (대 - 중 - 소)',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textPrimary)),
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
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              initiallyExpanded: true,
                              leading: Text(mainCat.icon,
                                  style: const TextStyle(fontSize: 22)),
                              title: Text(
                                mainCat.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: textPrimary),
                              ),
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: mainCat.subCategories.map((sub) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                int mappedCatIdx = 0;
                                                if (mainCat.id == 'food') {
                                                  mappedCatIdx =
                                                      sub.name.contains('생활')
                                                          ? 3
                                                          : 1;
                                                } else if (mainCat.id ==
                                                        'culture' ||
                                                    mainCat.id == 'game' ||
                                                    mainCat.id == 'hobby') {
                                                  mappedCatIdx = 2;
                                                } else if (mainCat.id ==
                                                        'activity' ||
                                                    mainCat.id == 'travel') {
                                                  mappedCatIdx = 3;
                                                }
                                                setState(() {
                                                  _selectedCategoryIndex =
                                                      mappedCatIdx;
                                                  _selectedSubCategory = '전체';
                                                  _selectedVibe = null;
                                                  _isSubCategoryExpanded =
                                                      false;
                                                });
                                                Navigator.pop(ctx);
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .subdirectory_arrow_right,
                                                      size: 16,
                                                      color: coralAccent),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    sub.name,
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: textPrimary),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              children:
                                                  sub.exampleTags.map((tag) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    int mappedCatIdx = 0;
                                                    if (mainCat.id == 'food') {
                                                      mappedCatIdx = sub.name
                                                              .contains('생활')
                                                          ? 3
                                                          : 1;
                                                    } else if (mainCat.id ==
                                                            'culture' ||
                                                        mainCat.id == 'game' ||
                                                        mainCat.id == 'hobby') {
                                                      mappedCatIdx = 2;
                                                    } else if (mainCat.id ==
                                                            'activity' ||
                                                        mainCat.id ==
                                                            'travel') {
                                                      mappedCatIdx = 3;
                                                    }
                                                    setState(() {
                                                      _selectedCategoryIndex =
                                                          mappedCatIdx;
                                                      _selectedSubCategory =
                                                          '전체';
                                                      _selectedVibe = null;
                                                      _isSubCategoryExpanded =
                                                          false;
                                                    });
                                                    Navigator.pop(ctx);
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                          color: const Color(
                                                              0xFFE4E4EB)),
                                                    ),
                                                    child: Text('#$tag',
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            color:
                                                                textSecondary)),
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
        final bool hasLightningKeyword = (item['category'] ?? '')
                .toString()
                .contains('번개') ||
            (item['title'] ?? '').toString().contains('번개') ||
            ((item['tags'] as List?)?.any((t) => t.toString().contains('번개')) ??
                false);
        if (!isTodayDate && !hasLightningKeyword) {
          return false;
        }
      }

      final bool vibeMatch = OOMUCategoryData.matchesVibe(item, selectedCat);
      final bool filterMatch = OOMUCategoryData.matchesFilter(
          item, selectedCat, _selectedSubCategory);

      // 서브태그가 '전체'일 때는 바이브 매칭이나 필터 매칭 둘 중 하나라도 통과하면 OK
      if (_selectedSubCategory == '전체') {
        if (!vibeMatch && !filterMatch) return false;
      } else {
        // 특정 서브태그 선택 시 해당 태그 매칭 검사
        final cat = (item['category'] ?? '').toString();
        final mainCatField = (item['mainCategory'] ?? '').toString();
        final title = (item['title'] ?? '').toString();
        final desc = (item['description'] ?? '').toString();
        final tags =
            (item['tags'] as List?)?.map((t) => t.toString()).toList() ?? [];
        final allText =
            '$cat $mainCatField $title $desc ${tags.join(' ')}'.toLowerCase();

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
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: (_homeDashboardTab == 3 || _homeDashboardTab == 4)
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              shape: const Border(
                bottom: BorderSide(color: Color(0xFFEAECF0), width: 1),
              ),
              titleSpacing: 20,
              title: BouncyTap(
                scaleDown: 0.96,
                onTap: _showLocationPickerBottomSheet,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          _currentLocation,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: textPrimary,
                            letterSpacing: -0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          size: 22, color: textPrimary),
                    ],
                  ),
                ),
              ),
              actions: [
                Semantics(
                  button: true,
                  label: '지도 탐색',
                  child: BouncyTap(
                    scaleDown: 0.92,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ExploreMapScreen()),
                      );
                    },
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: 44, minHeight: 48),
                      child: Center(
                        child: Icon(Icons.map_outlined,
                            color: textPrimary, size: 22),
                      ),
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: '알림',
                  child: BouncyTap(
                    scaleDown: 0.92,
                    onTap: () async {
                      final tab = await Navigator.push<int>(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const NotificationScreen()));
                      if (mounted && tab != null)
                        setState(() => _homeDashboardTab = tab);
                    },
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: 44, minHeight: 48),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.notifications_none_rounded,
                                color: textPrimary, size: 23),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Semantics(
                    button: true,
                    label: '필터',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const FilterScreen())),
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(minWidth: 44, minHeight: 48),
                        child: Center(
                          child: Icon(Icons.tune_rounded,
                              color: textPrimary, size: 21),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
      body: _homeDashboardTab == 0
          ? _buildMeetupDashboard()
          : (_homeDashboardTab == 1
              ? _buildCommunityDashboard()
              : (_homeDashboardTab == 2
                  ? _buildDiscoveryDashboard()
                  : (_homeDashboardTab == 3
                      ? ChatScreen(
                          isEmbedded: true,
                          onExplore: () =>
                              setState(() => _homeDashboardTab = 0))
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
                padding: const EdgeInsets.only(
                    top: 14, bottom: 8, left: 16, right: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _categories.length) {
                              return BouncyTap(
                                scaleDown: 0.94,
                                onTap: _showFullCategoryBottomSheet,
                                child: Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 11),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF2F4F7),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: const Color(0xFFEAECF0)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.grid_view_rounded,
                                          size: 14, color: Color(0xFF4E5968)),
                                      SizedBox(width: 4),
                                      Text(
                                        '전체보기',
                                        style: TextStyle(
                                            color: Color(0xFF4E5968),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            bool isSelected = _selectedCategoryIndex == index;
                            return BouncyTap(
                              scaleDown: 0.94,
                              onHaptic: OomuHaptics.selection,
                              onTap: () {
                                if (index == 0) {
                                  _resetAllMeetupFilters();
                                } else {
                                  setState(() {
                                    _selectedCategoryIndex = index;
                                    _selectedSubCategory = '전체';
                                    _selectedVibe = null;
                                    _isSubCategoryExpanded = false;
                                  });
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin: const EdgeInsets.only(right: 6),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 11),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? coralAccent
                                      : const Color(0xFFF2F4F7),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? coralAccent
                                        : const Color(0xFFEAECF0),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(_categories[index]['icon'],
                                        style: const TextStyle(fontSize: 13)),
                                    const SizedBox(width: 4),
                                    Text(
                                      _categories[index]['name'],
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF4E5968),
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                        fontSize: 12.5,
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
              if (_selectedCategoryIndex > 0) _buildSubCategoryBar(),
            ],
          ),
        ),

        // 2. 동네 지도 탐색 진입 (오늘 번개 탭에서는 상단 캐러셀의 '전체 지도 >' 버튼과 중복되므로 숨김)
        if (_selectedCategoryIndex != 1)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: _buildHomeShortcut(
                      icon: Icons.map_outlined,
                      label: '지도에서 모임',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ExploreMapScreen())),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildHomeShortcut(
                      icon: Icons.theater_comedy_outlined,
                      label: '공연·핫플',
                      onTap: () => setState(() => _homeDashboardTab = 2),
                    ),
                  ),
                ],
              ),
            ),
          ),

        if (_selectedVibe != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F2),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: coralAccent.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Text(
                      '\'$_selectedVibe\' 분위기 모임 필터링 중',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: coralAccent,
                          fontSize: 13),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _selectedVibe = null),
                      child: Row(
                        children: [
                          Icon(Icons.close, size: 14, color: coralAccent),
                          const SizedBox(width: 2),
                          Text('필터 해제',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: coralAccent)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // 3. 탭별 상단 특화 섹션 (⚡ 오늘 번개: 즉석 팟 캐러셀, ☕ 취향 아지트: 공연·핫플 큐레이션)
        if (_selectedCategoryIndex == 1) ...[
          SliverToBoxAdapter(
            child: _buildLiveSpotCarousel(),
          ),
        ] else if (_selectedCategoryIndex == 2) ...[
          SliverToBoxAdapter(
            child: _buildTrendCurationSection(),
          ),
        ],

        // 5. 우리 동네 취향 모임 Header
        SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 18, bottom: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedCategoryIndex == 1
                            ? '${_currentLocation.split(' ')[0]} 오늘 당일 번개'
                            : (_selectedCategoryIndex == 2
                                ? '${_currentLocation.split(' ')[0]} 감성 취향 아지트'
                                : (_selectedCategoryIndex == 3
                                    ? '${_currentLocation.split(' ')[0]} 일상 라이프 메이트'
                                    : '${_currentLocation.split(' ')[0]}에서 지금 뜨는 모임')),
                        style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                            letterSpacing: -0.4),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedVibe != null
                            ? '✨ \'$_selectedVibe\' 필터링 중'
                            : (_selectedCategoryIndex > 0
                                ? (_selectedSubCategory != '전체'
                                    ? '${_categories[_selectedCategoryIndex]['name']} · #$_selectedSubCategory'
                                    : (_selectedCategoryIndex == 1
                                        ? '오늘 바로 만나는 우리 동네 번개'
                                        : '취향이 통하는 이웃과 만나는 모임'))
                                : (_selectedSubCategory != '전체'
                                    ? '#$_selectedSubCategory 모임'
                                    : '가까운 이웃과 편하게 만나는 동네 모임')),
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // [⊞ 블럭] [☰ 목록] 뷰 전환 토글 (최소 48x48dp 터치 영역 보장)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEAECF0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: '블럭형 보기',
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _isListView = false),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                                minWidth: 50, minHeight: 44),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 6),
                                decoration: BoxDecoration(
                                  color: !_isListView
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: !_isListView
                                      ? [
                                          BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.05),
                                              blurRadius: 4)
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.grid_view_rounded,
                                        size: 14,
                                        color: !_isListView
                                            ? textPrimary
                                            : textSecondary),
                                    const SizedBox(width: 3),
                                    Text(
                                      '블럭',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: !_isListView
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: !_isListView
                                            ? textPrimary
                                            : textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Tooltip(
                        message: '목록형 보기',
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _isListView = true),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                                minWidth: 50, minHeight: 44),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _isListView
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: _isListView
                                      ? [
                                          BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.05),
                                              blurRadius: 4)
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.view_agenda_outlined,
                                        size: 14,
                                        color: _isListView
                                            ? textPrimary
                                            : textSecondary),
                                    const SizedBox(width: 3),
                                    Text(
                                      '목록',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: _isListView
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: _isListView
                                            ? textPrimary
                                            : textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return _buildDummyMeetups();
                    }

                    final List<Map<String, dynamic>> mergedItems = [];
                    final Set<String> seenKeys = {};

                    for (final doc in snapshot.data!.docs) {
                      final data = Map<String, dynamic>.from(
                          doc.data() as Map<String, dynamic>)
                        ..['id'] = doc.id;
                      final key =
                          '${data['id']}_${(data['title'] ?? '').toString().trim()}';
                      seenKeys.add(key);
                      seenKeys.add((data['title'] ?? '').toString().trim());
                      mergedItems.add(data);
                    }

                    for (final dummy
                        in _getDummyMeetupsForLocation(_currentLocation)) {
                      final titleKey = (dummy['title'] ?? '').toString().trim();
                      final idKey = '${dummy['id']}_$titleKey';
                      if (!seenKeys.contains(idKey) &&
                          !seenKeys.contains(titleKey)) {
                        seenKeys.add(idKey);
                        seenKeys.add(titleKey);
                        mergedItems.add(Map<String, dynamic>.from(dummy));
                      }
                    }

                    final filteredDocs = mergedItems
                        .where((data) => _matchesFilters(data))
                        .toList();

                    // 지역 적합도(_calculateLocationRelevanceScore) 최우선 정렬 후 최신순 정렬
                    filteredDocs.sort((dataA, dataB) {
                      final scoreA = _calculateLocationRelevanceScore(
                          dataA['location']?.toString() ?? '');
                      final scoreB = _calculateLocationRelevanceScore(
                          dataB['location']?.toString() ?? '');
                      if (scoreA != scoreB) {
                        return scoreB.compareTo(scoreA);
                      }
                      final aTime = dataA['createdAt'];
                      final bTime = dataB['createdAt'];
                      if (aTime is Timestamp && bTime is Timestamp) {
                        return bTime.compareTo(aTime);
                      }
                      return 0;
                    });

                    if (filteredDocs.isEmpty) {
                      return _buildEmptyFilterState();
                    }

                    return Column(
                      children: [
                        ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _showAllMeetups
                              ? filteredDocs.length
                              : filteredDocs.length
                                  .clamp(0, _initialMeetupCount),
                          itemBuilder: (context, index) {
                            final data = filteredDocs[index];
                            return (_isListView || index > 0)
                                ? _buildMeetupListRow(data)
                                : _buildMeetupCard(data);
                          },
                        ),
                        if (filteredDocs.length > _initialMeetupCount)
                          _buildMeetupMoreButton(filteredDocs.length),
                      ],
                    );
                  },
                ),
        ),

        // 전체 탭에서 모임 피드를 먼저 노출한 뒤, 하단에 동네 문화 행사·핫플 큐레이션 노출
        if (_selectedCategoryIndex == 0) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 8),
              child: Container(
                height: 8,
                width: double.infinity,
                color: const Color(0xFFF2F4F7),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildTrendCurationSection(),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildHomeShortcut({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEAECF0)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: coralAccent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: textPrimary),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 16, color: textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityDashboard() {
    final List<String> simpleTopics = [
      '전체',
      '☕ 일상·수다',
      '🎭 공연·핫플',
      '🍰 맛집·카페',
      '❓ 동네질문'
    ];

    return StreamBuilder<QuerySnapshot>(
      stream: Firebase.apps.isNotEmpty
          ? FirebaseFirestore.instance.collection('community_posts').snapshots()
          : null,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('커뮤니티를 불러오지 못했어요',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Text('연결 상태와 접근 권한을 확인한 뒤 다시 시도해 주세요.',
                        textAlign: TextAlign.center),
                    TextButton(
                        onPressed: () => setState(() {}),
                        child: const Text('다시 불러오기')),
                  ])));
        }
        if (Firebase.apps.isNotEmpty &&
            snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final Map<String, Map<String, dynamic>> postMap = {};

        // 1. Initial 3-persona and preset posts (세션 간 참조 오염 방지를 위해 복제)
        final activeInitialPosts = _getActiveCommunityPosts();
        for (var p in activeInitialPosts) {
          final cloned = Map<String, dynamic>.from(p);
          final pid = cloned['id']?.toString() ?? '';
          if (cloned['commentList'] is List) {
            cloned['comments'] = (cloned['commentList'] as List).length;
          }
          postMap[pid] = cloned;
        }

        // 2. Real-time Firestore posts overlay & new user posts
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          for (var doc in snapshot.data!.docs) {
            final data =
                Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
            final pid = doc.id;
            data['id'] = pid;
            for (final key in [
              'title',
              'content',
              'author',
              'location',
              'category',
              'tag',
              'time'
            ]) {
              data[key] = data[key]?.toString() ?? '';
            }
            for (final key in ['comments', 'likes']) {
              data[key] = int.tryParse(data[key]?.toString() ?? '') ?? 0;
            }

            final likedUsers = data['likedUserIds'] is List
                ? List<dynamic>.from(data['likedUserIds'])
                : <dynamic>[];
            final currentUid = globalData.activeUserId;
            data['isLiked'] =
                currentUid.isNotEmpty && likedUsers.contains(currentUid);
            data['likes'] = likedUsers.isNotEmpty
                ? likedUsers.length
                : (data['likes'] ?? 0);

            if (postMap.containsKey(pid)) {
              postMap[pid]!.addAll(data);
            } else {
              postMap[pid] = data;
            }
          }
        }

        final allPosts = postMap.values.toList();
        allPosts.sort((a, b) {
          final scoreA =
              _calculateLocationRelevanceScore(a['location']?.toString() ?? '');
          final scoreB =
              _calculateLocationRelevanceScore(b['location']?.toString() ?? '');
          if (scoreA != scoreB) {
            return scoreB.compareTo(scoreA);
          }
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
            if (_communityCategoryFilter == '☕ 일상·수다' &&
                post['category'] != '동네 토크' &&
                post['category'] != '일상') return false;
            if (_communityCategoryFilter == '🎭 공연·핫플' &&
                post['category'] != '공연/전시' &&
                post['category'] != '공연') return false;
            if (_communityCategoryFilter == '🍰 맛집·카페' &&
                post['category'] != '맛집/카페' &&
                post['category'] != '맛집') return false;
            if (_communityCategoryFilter == '❓ 동네질문' &&
                post['category'] != '질문/추천' &&
                post['category'] != '질문') return false;
          }
          if (_communityKeywordFilter != null &&
              post['tag'] != _communityKeywordFilter!.replaceAll('#', '')) {
            return false;
          }
          return true;
        }).toList();

        return ListView(
          padding: const EdgeInsets.only(bottom: 60),
          children: [
            // 1. 심플 원터치 글쓰기 바
            Container(
              margin: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEAECF0)),
              ),
              child: InkWell(
                onTap: () async {
                  final newPost = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CommunityPostCreateScreen(
                            currentLocation: _currentLocation)),
                  );
                  if (newPost != null && mounted) {
                    setState(() {
                      _communityPosts.insert(0, newPost);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('🎉 이야기가 동네 커뮤니티에 등록되었습니다!')),
                    );
                  }
                },
                child: Row(
                  children: [
                    ValueListenableBuilder<String>(
                      valueListenable: globalData.userAvatar,
                      builder: (_, avatarUrl, __) => CircleAvatar(
                        radius: 16,
                        backgroundImage: appImg(avatarUrl),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${_currentLocation.split(' ').last}의 일상과 소식을 나눠보세요',
                        style: TextStyle(
                            color: textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: coralAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_outlined,
                              size: 13, color: Colors.white),
                          SizedBox(width: 4),
                          Text('글쓰기',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. 단일 통합 심플 토픽 필터 (2중 적층 해시태그 바를 제거하여 시선 정돈)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: simpleTopics.map((topic) {
                    final isSelected = _communityCategoryFilter == topic;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _communityCategoryFilter = topic),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? textPrimary : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? textPrimary
                                : const Color(0xFFEAECF0),
                          ),
                        ),
                        child: Text(
                          topic,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF4E5968),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // 4. 커뮤니티 피드 리스트
            if (filteredPosts.isEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded,
                          size: 44, color: Color(0xFFC7C7CC)),
                      const SizedBox(height: 12),
                      Text('아직 등록된 이야기가 없어요',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textPrimary)),
                      const SizedBox(height: 6),
                      Text('첫 번째 동네 소식을 가볍게 남겨보세요!',
                          style: TextStyle(fontSize: 13, color: textSecondary)),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
    return BouncyTap(
      scaleDown: 0.98,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => CommunityPostDetailScreen(post: post)),
        ).then((res) {
          if (mounted) {
            if (res is Map && res['deleted'] == true) {
              setState(() {
                _communityPosts
                    .removeWhere((p) => (p['id'] ?? p['title']) == res['id']);
              });
            } else {
              setState(() {});
            }
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEAECF0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                    final authorManner = OomuUiHelpers.parseMannerTemp(post);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserProfileScreen(
                          userName: (post['author'] ?? '동네주민').toString(),
                          userAvatar: post['authorAvatar']?.toString(),
                          userLocation: post['location']?.toString(),
                          userManner: authorManner,
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage:
                        appImg(post['authorAvatar'] ?? 'assets/images/민지.png'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: () {
                                final authorManner =
                                    OomuUiHelpers.parseMannerTemp(post);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UserProfileScreen(
                                      userName:
                                          (post['author'] ?? '동네주민').toString(),
                                      userAvatar:
                                          post['authorAvatar']?.toString(),
                                      userLocation:
                                          post['location']?.toString(),
                                      userManner: authorManner,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                (post['author'] ?? '동네주민').toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                    color: textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Builder(
                            builder: (_) {
                              final authorManner =
                                  OomuUiHelpers.parseMannerTemp(post);
                              if (authorManner == null)
                                return const SizedBox.shrink();
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: OomuUiHelpers.mannerTempBgColor(
                                      authorManner),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  OomuUiHelpers.formatMannerTemp(authorManner),
                                  style: TextStyle(
                                    color: OomuUiHelpers.mannerTempColor(
                                        authorManner),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [post['location'], post['time']]
                            .map((e) => (e ?? '').toString().trim())
                            .where((e) => e.isNotEmpty)
                            .join(' · '),
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    UgcActionSheets.showContentOptions(
                      context: context,
                      contentType: '게시글',
                      contentId: post['id'] ??
                          post['title'] ??
                          'post_${post['author']}',
                      author: post['author'] ?? '동네주민',
                      onContentHidden: () => setState(() {}),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.more_horiz,
                        size: 20, color: Color(0xFF8B95A1)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 서브태그 뱃지 (중립 쿨그레이 칩으로 핑크 범벅 방지)
            if (post['tag'] != null && (post['tag'] as String).isNotEmpty) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.5, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#${post['tag']}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4E5968),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // 제목 (16.5dp, Deep Charcoal, 외톨이 줄바꿈 방지 적용)
            if (post['title'] != null &&
                (post['title'] as String).isNotEmpty) ...[
              BalancedText(
                OomuUiHelpers.formatTitle(post['title']?.toString()),
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF191F28),
                  height: 1.35,
                  letterSpacing: -0.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
            ],

            // 본문 (14dp, 차분한 슬레이트 그레이 #333D4B, 줄간격 1.55)
            Text(
              post['content'] ?? '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF333D4B),
                height: 1.55,
                letterSpacing: -0.15,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),

            // 첨부 사진 (있을 경우만)
            if (post['image'] != null &&
                (post['image'] as String).isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: double.infinity,
                  height: 170,
                  child: Image(
                    image: appImg(post['image']),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFF2F4F7),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 14),

            // 하단 인터랙션 바: 좋아요, 댓글, 연관 모임 바로 만들기 CTA
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      final myUserId = globalData.activeUserId;
                      List<dynamic> likedUsers =
                          List<dynamic>.from(post['likedUserIds'] ?? []);
                      bool currentlyLiked = likedUsers.contains(myUserId) ||
                          likedUsers.contains('user_me_01');
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
                          FirebaseFirestore.instance
                              .collection('community_posts')
                              .doc(postId)
                              .set({
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
                        post['isLiked'] == true
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 17,
                        color: post['isLiked'] == true
                            ? coralAccent
                            : textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post['likes'] ?? 0}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: post['isLiked'] == true
                              ? coralAccent
                              : textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              CommunityPostDetailScreen(post: post)),
                    ).then((_) {
                      if (mounted) setState(() {});
                    });
                  },
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 16, color: textSecondary),
                      const SizedBox(width: 4),
                      Text('${post['comments'] ?? 0}',
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveryDashboard() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 40, top: 8),
      children: [
        OomuDiscoveryLifestyleHub(currentLocation: _currentLocation),
      ],
    );
  }

  Widget _buildEmptyFilterState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 48, color: Color(0xFFC7C7CC)),
            const SizedBox(height: 12),
            Text('선택한 조건의 모임이 아직 없어요',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimary)),
            const SizedBox(height: 6),
            Text('필터를 해제하거나 내가 먼저 모임을 개설해보세요!',
                style: TextStyle(fontSize: 13, color: textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: coralAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _resetAllMeetupFilters,
              child: const Text('필터 초기화',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
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

  String _formatTitleKeepWords(String? title) {
    return OomuUiHelpers.formatTitle(title, fallback: '취향 모임');
  }

  String _meetupCoverImage(Map<String, dynamic> meetup) {
    final source = (meetup['imageUrl'] ?? '').toString();
    final title = (meetup['title'] ?? '').toString();
    if ((title.contains('소금빵') || source.contains('salt_bread')) &&
        (source == 'assets/images/cover_cafe.jpg' ||
            source.contains('salt_bread'))) {
      return 'assets/images/cover_salt_bread.jpg';
    }
    final location = (meetup['location'] ?? '').toString();
    final isSeoulArea = location.contains('서울') ||
        location.contains('마포') ||
        location.contains('망원') ||
        location.contains('한강');
    if ((source == 'assets/images/cover_running.jpg' ||
            source.contains('running_hangang') ||
            (source.contains('run') && isSeoulArea)) &&
        isSeoulArea) {
      return 'assets/images/cover_running_hangang.jpg';
    }
    return source.isEmpty ? 'assets/images/cover_food.jpg' : source;
  }

  Map<String, dynamic> _meetupForDetail(Map<String, dynamic> meetup) {
    final image = _meetupCoverImage(meetup);
    return {
      ...meetup,
      'imageUrl': image,
      'coverIsIllustrative': image == 'assets/images/cover_salt_bread.jpg',
    };
  }

  Widget _buildMeetupCard(Map<String, dynamic> meetup) {
    final bool isLightning = _isLightningMeetup(meetup);

    return BouncyTap(
      scaleDown: 0.98,
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  OOMUDetailScreen(meetup: _meetupForDetail(meetup)))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEAECF0),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 사진 (168dp 비율 일관성 및 정돈된 배지)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image(
                      image: appImg(_meetupCoverImage(meetup)),
                      fit: BoxFit.cover,
                      alignment: (meetup['imageUrl'] ?? '')
                              .toString()
                              .contains('cover_running')
                          ? const Alignment(0, 0.55)
                          : Alignment.center,
                      errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/cover_food.jpg',
                          fit: BoxFit.cover),
                    ),
                    if (_meetupCoverImage(meetup) ==
                        'assets/images/cover_salt_bread.jpg')
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(6)),
                          child: const Text('분위기 이미지',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      ),
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isLightning
                                    ? coralAccent
                                    : Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                meetup['category'] ??
                                    (isLightning ? '오늘 번개' : '동네모임'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isLightning
                                      ? Colors.white
                                      : const Color(0xFF191F28),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ),
                          if (meetup['isFemaleOnly'] == true) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '여성 전용',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Color(0xFFD9384A),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11.5),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. 카드 본문 정보 (Card-in-Card 중첩 박스를 제거하고 깔끔한 여백과 디바이더로 정돈)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 모임 제목 (단어 분리 방지 및 자연스러운 2줄 허용)
                  BalancedText(
                    _formatTitleKeepWords(meetup['title']),
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      height: 1.35,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // 일정 & 장소 정보 (중첩 박스 없이 정갈한 아이콘+텍스트 행)
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 14, color: textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          meetup['date'] ?? (isLightning ? '오늘 저녁' : '일정 협의'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333D4B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14, color: coralAccent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          meetup['location'] ?? '위치 협의',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333D4B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  if (_devicePosition != null) ...[
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: _buildMeetupDistance(meetup),
                    ),
                  ],

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(
                        height: 1, thickness: 1, color: Color(0xFFF2F4F7)),
                  ),

                  MeetupCardFooter(meetup: meetup),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 컴팩트 목록형 뷰 카드 (동일한 데이터, 타이포그래피, 상태 표현 준수)
  Widget _buildMeetupListRow(Map<String, dynamic> meetup) {
    return BouncyTap(
      scaleDown: 0.98,
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  OOMUDetailScreen(meetup: _meetupForDetail(meetup)))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFEAECF0),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일 (88x88)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 88,
                height: 88,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image(
                      image: appImg(_meetupCoverImage(meetup)),
                      fit: BoxFit.cover,
                      alignment: (meetup['imageUrl'] ?? '')
                              .toString()
                              .contains('cover_running')
                          ? const Alignment(0, 0.55)
                          : Alignment.center,
                      errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/cover_food.jpg',
                          fit: BoxFit.cover),
                    ),
                    if (_meetupCoverImage(meetup) ==
                        'assets/images/cover_salt_bread.jpg')
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4)),
                          child: const Text('예시',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 9)),
                        ),
                      ),
                    if (meetup['isFemaleOnly'] == true)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(5)),
                          child: const Text('여성 전용',
                              style: TextStyle(
                                  color: Color(0xFFD9384A),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.5)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 정보 영역 (순서: 카테고리/정산 -> 제목 -> 일정/장소 -> 주최자/참여현황)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((meetup['category'] ?? '동네 모임').toString(),
                      style: TextStyle(fontSize: 13, color: textSecondary)),
                  const SizedBox(height: 5),
                  BalancedText(
                    _formatTitleKeepWords(meetup['title']),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      height: 1.32,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  // 일정 & 장소 각각 별도 행으로 분리하여 긴 주소에 밀리지 않도록 보장
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 12, color: textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          meetup['date'] ?? '일정 확인 필요',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF333D4B),
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 12, color: coralAccent),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          meetup['location'] ?? '위치 협의',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF333D4B),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (_devicePosition != null) ...[
                    const SizedBox(height: 4),
                    _buildMeetupDistance(meetup),
                  ],
                  const SizedBox(height: 12),
                  MeetupCardFooter(meetup: meetup),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDummyMeetups() {
    final List<Map<String, dynamic>> allDummyData =
        _getDummyMeetupsForLocation(_currentLocation);

    final filtered = allDummyData.where((m) => _matchesFilters(m)).toList();
    filtered.sort((a, b) {
      final scoreA =
          _calculateLocationRelevanceScore(a['location']?.toString() ?? '');
      final scoreB =
          _calculateLocationRelevanceScore(b['location']?.toString() ?? '');
      return scoreB.compareTo(scoreA);
    });

    if (filtered.isEmpty) {
      return _buildEmptyFilterState();
    }

    return Column(
      children: [
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _showAllMeetups
              ? filtered.length
              : filtered.length.clamp(0, _initialMeetupCount),
          itemBuilder: (context, index) {
            return (_isListView || index > 0)
                ? _buildMeetupListRow(filtered[index])
                : _buildMeetupCard(filtered[index]);
          },
        ),
        if (filtered.length > _initialMeetupCount)
          _buildMeetupMoreButton(filtered.length),
      ],
    );
  }

  List<Map<String, dynamic>> _getDummyMeetupsForLocation(String location) {
    final clean = location.trim();
    if (clean.contains('여수') || clean.contains('화장동')) {
      return _getYeosuDummyMeetups();
    }
    return _getSeoulDummyMeetups();
  }

  List<Map<String, dynamic>> _getYeosuDummyMeetups() {
    return [
      {
        'id': 'yeosu_dummy_01',
        'title': '주말 여수 화장동 수제 소금빵 & 감성 베이커리 카페 오픈런 🥐',
        'mainCategory': '일상 & 푸드',
        'category': '동네 맛집 & 소셜 다이닝',
        'location': '전남 여수시 화장동 선소상가 카페거리',
        'date': '이번 주 일요일 오전 11:00',
        'imageUrl': 'assets/images/cover_cafe.jpg',
        'isFemaleOnly': true,
        'host': '여수빵순이',
        'hostAvatar': 'assets/images/민지.png',
        'manner': 42.5,
        'members': '2/4',
        'price': '각자 결제',
        'transport': '화장동 선소상가 앞 집결',
        'schedule': '1차 갓 구운 소금빵 & 드립커피 ➔ 2차 루프탑 테라스 수다',
        'tags': ['화장동카페', '소금빵오픈런', '여수디저트', '소소하게', '동네친구', '카페·디저트'],
        'photos': [
          'assets/images/cover_cafe.jpg',
          'assets/images/cover_food.jpg'
        ],
      },
      {
        'id': 'yeosu_dummy_02',
        'title': '화장동 성산공원 호수 둘레길 저녁 5km 런닝 크루 🏃‍♀️',
        'mainCategory': '액티비티 & 스포츠',
        'category': '라이프 메이트',
        'location': '전남 여수시 화장동 성산공원 수변무대',
        'date': '오늘 저녁 7:30',
        'imageUrl': 'assets/images/cover_running.jpg',
        'isFemaleOnly': false,
        'isLightning': true,
        'host': '성산러너_민우',
        'hostAvatar': 'assets/images/지훈.png',
        'manner': 45.2,
        'members': '3/4',
        'price': '각자 결제',
        'transport': '성산공원 입구 집결',
        'schedule': '스트레칭 10분 ➔ 성산공원 호수 둘레길 5km 러닝 ➔ 이온음료 쿨다운',
        'tags': [
          '라이프 메이트',
          '러닝·운동',
          '운동',
          '성산공원',
          '화장동러닝',
          '오운완',
          '둘레길산책',
          '오늘번개'
        ],
        'photos': ['assets/images/cover_running.jpg'],
      },
      {
        'id': 'yeosu_dummy_03',
        'title': '불금엔 여수 화장동 무선상가 코노 & 시원한 하이볼 한잔 🎤',
        'mainCategory': '문화 & 엔터',
        'category': '음악 & 노래방',
        'location': '전남 여수시 화장동 무선지구 상가',
        'date': '오늘 저녁 8:30',
        'imageUrl': 'assets/images/cover_wine.jpg',
        'isFemaleOnly': false,
        'isLightning': true,
        'host': '무선보컬킹',
        'hostAvatar': 'assets/images/정재.png',
        'manner': 40.8,
        'members': '2/4',
        'price': '각자 결제',
        'transport': '무선 롯데마트 앞 집결',
        'schedule': '1차 무선지구 코노 고음 배틀 ➔ 2차 캐주얼 하이볼 한잔',
        'tags': ['불금엔 역시 코노', '음악 & 노래방', '불금코노·술', '오늘번개', '스트레스해소'],
        'photos': ['assets/images/cover_wine.jpg'],
      },
      {
        'id': 'yeosu_dummy_04',
        'title': '여수 웅천친수공원 바다 캔맥주 소셜 피크닉 & 수다 🍺',
        'mainCategory': '일상 & 푸드',
        'category': '동네 술 한잔',
        'location': '전남 여수시 웅천동 해변문화공원',
        'date': '이번 주 토요일 오후 6:30',
        'imageUrl': 'assets/images/cover_wine.jpg',
        'isFemaleOnly': false,
        'host': '웅천피플_준',
        'hostAvatar': 'assets/images/시연.png',
        'manner': 43.0,
        'members': '3/6',
        'price': '각자 결제',
        'transport': '웅천 친수공원 잔디마당',
        'schedule': '노을 보며 돗자리 캔맥주 & 버스킹 감상 피크닉',
        'tags': ['웅천피크닉', '바다캔맥주', '소셜다이닝', '동네친구', '혼술바동행'],
        'photos': [
          'assets/images/cover_wine.jpg',
          'assets/images/cover_cafe.jpg'
        ],
      },
      {
        'id': 'yeosu_dummy_05',
        'title': '여수 학동 선소상가 찐맛집 털기 & 2:2 캐주얼 소셜 다이닝 🥘',
        'mainCategory': '일상 & 푸드',
        'category': '동네 맛집 & 소셜 다이닝',
        'location': '전남 여수시 학동 선소상가 맛집골목',
        'date': '이번 주 금요일 저녁 7:30',
        'imageUrl': 'assets/images/cover_food.jpg',
        'isFemaleOnly': false,
        'host': '선소미식가',
        'hostAvatar': 'assets/images/지연.png',
        'manner': 44.1,
        'members': '2/4',
        'price': '1/N 안심 정산',
        'transport': '학동 선소상가 입구',
        'schedule': '현지인 추천 남도 제철 안주 & 맛집 탐방 ➔ 분위기 좋은 2차',
        'tags': ['선소맛집', '맛집털기', '2:2미팅', '소셜다이닝', '자만추'],
        'photos': ['assets/images/cover_food.jpg'],
      },
      {
        'id': 'yeosu_dummy_06',
        'title': '화장동 보드게임 카페 스플렌더 & 루미큐브 두뇌 배틀 🎲',
        'mainCategory': '게임 & 오락',
        'category': '보드게임',
        'location': '전남 여수시 화장동 보드게임 카페',
        'date': '토요일 오후 3:00',
        'imageUrl': 'assets/images/cover_cafe.jpg',
        'isFemaleOnly': false,
        'host': '미플장인',
        'hostAvatar': 'assets/images/지안.png',
        'manner': 41.5,
        'members': '3/4',
        'price': '무료 참여',
        'transport': '화장동 상가거리',
        'tags': ['보드게임·방탈출', '취향아지트', '전략보드게임', '소소하게'],
        'photos': ['assets/images/cover_cafe.jpg'],
      },
      {
        'id': 'yeosu_dummy_07',
        'title': '여수 소호동동다리 바닷길 야경 산책 & 힐링 워킹 🌊',
        'mainCategory': '여행 & 나들이',
        'category': '동네산책',
        'location': '전남 여수시 소호동 동동다리 산책로',
        'date': '목요일 저녁 8:00',
        'imageUrl': 'assets/images/cover_running.jpg',
        'isFemaleOnly': false,
        'host': '밤바다산책',
        'hostAvatar': 'assets/images/민지.png',
        'manner': 43.8,
        'members': '2/4',
        'price': '무료 참여',
        'transport': '소호동동다리 광장 집결',
        'schedule': '바다 위 데크길 산책 40분 ➔ 오션뷰 카페 차 한잔',
        'tags': ['동네산책', '라이프메이트', '소호동동다리', '야경산책', '힐링'],
        'photos': ['assets/images/cover_running.jpg'],
      },
      {
        'id': 'yeosu_dummy_08',
        'title': '화장동 무선 롯데마트 1인 가구 대용량 식재료 장보기 & 소분 메이트 🛒',
        'mainCategory': '라이프 메이트',
        'category': '1인가구장보기/소분',
        'location': '전남 여수시 화장동 무선 롯데마트 1층 입구',
        'date': '이번 주 토요일 오후 4:00',
        'imageUrl': 'assets/images/cover_food.jpg',
        'isFemaleOnly': false,
        'host': '자취9단_수아',
        'hostAvatar': 'assets/images/시연.png',
        'manner': 44.5,
        'members': '2/4',
        'price': '1/N 안심 정산',
        'transport': '무선 롯데마트 정문 집결',
        'schedule': '제철 과일·삼겹살·생필품 대용량 구매 ➔ 깔끔 1/N 소분 정산',
        'tags': ['라이프 메이트', '1인가구장보기/소분', '1인 가구', '장보기', '소분', '배달비'],
        'photos': ['assets/images/cover_food.jpg'],
      },
      {
        'id': 'yeosu_dummy_09',
        'title': '화장동 피트니스 퇴근 후 득근 헬스 & 오운완 인증 메이트 💪',
        'mainCategory': '라이프 메이트',
        'category': '헬스메이트',
        'location': '전남 여수시 화장동 성산공원 앞 피트니스',
        'date': '평일 저녁 7:30 상시',
        'imageUrl': 'assets/images/cover_running.jpg',
        'isFemaleOnly': false,
        'host': '득근러_현우',
        'hostAvatar': 'assets/images/정재.png',
        'manner': 43.2,
        'members': '2/3',
        'price': '무료 참여',
        'transport': '화장동 성산사거리 집결',
        'schedule': '상·하체 분할 웨이트 50분 + 유산소 20분 함께 인증',
        'tags': ['라이프 메이트', '헬스메이트', '러닝·운동', '헬스', '운동', '메이트'],
        'photos': ['assets/images/cover_running.jpg'],
      },
      {
        'id': 'yeosu_dummy_10',
        'title': '성산공원 잔디광장 저녁 강아지·반려동물 산책 메이트 모임 🐕',
        'mainCategory': '라이프 메이트',
        'category': '반려동물산책',
        'location': '전남 여수시 화장동 성산공원 잔디광장',
        'date': '내일 저녁 7:00',
        'imageUrl': 'assets/images/cover_running.jpg',
        'isFemaleOnly': false,
        'host': '비숑맘_하은',
        'hostAvatar': 'assets/images/지안.png',
        'manner': 45.0,
        'members': '3/5',
        'price': '무료 참여',
        'transport': '성산공원 주차장 입구',
        'schedule': '반려견 인사 & 호수 산책로 1바퀴 ➔ 야외 벤치 간식 타임',
        'tags': ['라이프 메이트', '반려동물산책', '동네산책', '반려견', '댕댕이', '산책'],
        'photos': ['assets/images/cover_running.jpg'],
      },
      {
        'id': 'yeosu_dummy_11',
        'title': '여수 돌산 오션뷰 여성전용 감성 글램핑 & 불멍 바비큐 팟 ⛺',
        'mainCategory': '라이프 메이트',
        'category': '동성캠핑',
        'location': '전남 여수시 돌산읍 오션뷰 글램핑장',
        'date': '이번 주 토요일 오후 4:00',
        'imageUrl': 'assets/images/cover_wine.jpg',
        'isFemaleOnly': true,
        'host': '캠핑요정_유진',
        'hostAvatar': 'assets/images/민지.png',
        'manner': 44.8,
        'members': '3/4',
        'price': '1/N 안심 정산',
        'transport': '화장동에서 카풀 이동',
        'schedule': '오션뷰 노을 감상 ➔ 바비큐 파티 & 모닥불 불멍 토크',
        'tags': ['라이프 메이트', '동성캠핑', '캠핑', '글램핑', '동성', '불멍'],
        'photos': ['assets/images/cover_wine.jpg'],
      },
    ];
  }

  List<Map<String, dynamic>> _getSeoulDummyMeetups() {
    return [
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
        'hostAvatar': 'assets/images/민지.png',
        'manner': 41.2,
        'members': '2/4',
        'price': '1/N 안심 정산',
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
        'hostAvatar': 'assets/images/시연.png',
        'manner': 38.5,
        'members': '2/4',
        'price': '1/N 안심 정산',
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
        'hostAvatar': 'assets/images/지훈.png',
        'manner': 42.0,
        'members': '3/4',
        'price': '1/N 안심 정산',
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
        'hostAvatar': 'assets/images/정재.png',
        'manner': 38.5,
        'price': '1/N 안심 정산',
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
        'hostAvatar': 'assets/images/지연.png',
        'manner': 40.2,
        'members': '2/3',
        'price': '무료 참여',
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
        'hostAvatar': 'assets/images/지훈.png',
        'manner': 40.5,
        'price': '1/N 안심 정산',
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
        'hostAvatar': 'assets/images/지안.png',
        'manner': 39.8,
        'members': '4/6',
        'price': '무료 참여',
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
        'hostAvatar': 'assets/images/정재.png',
        'manner': 43.1,
        'members': '2/2',
        'price': '무료 참여',
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
        'hostAvatar': 'assets/images/지연.png',
        'manner': 42.8,
        'price': '1/N 안심 정산',
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
        'hostAvatar': 'assets/images/민지.png',
        'manner': 44.0,
        'price': '1/N 안심 정산',
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
        'hostAvatar': 'assets/images/지훈.png',
        'manner': 41.5,
        'members': '3/4',
        'price': '1/N 안심 정산',
        'transport': '홍대입구역 3번출구',
        'schedule': '가벼운 와인과 식사 & 편안한 동네 인연 찾기',
        'tags': ['소개팅', '2:2', '미팅', '인연', '소셜다이닝'],
        'photos': [
          'assets/images/cover_wine.jpg',
        ],
      },
      {
        'id': 'dummy_meetup_12',
        'title': '망원시장·합정 홈플러스 1인 가구 대용량 장보기 & 소분 메이트 🛒',
        'mainCategory': '라이프 메이트',
        'category': '1인가구장보기/소분',
        'location': '마포구 망원시장 정문 / 합정역 홈플러스',
        'date': '이번 주 토요일 오후 3:00',
        'imageUrl': 'assets/images/cover_food.jpg',
        'isFemaleOnly': false,
        'host': '망원자취러_소연',
        'hostAvatar': 'assets/images/시연.png',
        'manner': 44.3,
        'members': '3/4',
        'price': '1/N 안심 정산',
        'transport': '망원역 2번 출구 집결',
        'schedule': '제철 과일·구이용 고기·대용량 식재료 공동 구매 후 1/N 소분',
        'tags': ['라이프 메이트', '1인가구장보기/소분', '1인 가구', '장보기', '소분', '배달비'],
        'photos': [
          'assets/images/cover_food.jpg',
        ],
      },
      {
        'id': 'dummy_meetup_13',
        'title': '연트럴파크 경의선숲길 저녁 반려동물·강아지 동네산책 모임 🐕',
        'mainCategory': '라이프 메이트',
        'category': '반려동물산책',
        'location': '마포구 연남동 경의선숲길 잔디광장',
        'date': '오늘 저녁 7:30',
        'imageUrl': 'assets/images/cover_running.jpg',
        'isFemaleOnly': false,
        'host': '보리언니_민서',
        'hostAvatar': 'assets/images/민지.png',
        'manner': 43.9,
        'members': '3/5',
        'price': '무료 참여',
        'transport': '홍대입구역 3번 출구 숲길 시작점',
        'schedule': '경의선숲길 왕복 40분 산책 ➔ 애견 동반 테라스 카페 수다',
        'tags': ['라이프 메이트', '반려동물산책', '동네산책', '반려견', '댕댕이', '산책'],
        'photos': [
          'assets/images/cover_running.jpg',
        ],
      },
      {
        'id': 'dummy_meetup_14',
        'title': '난지한강공원 여성전용 감성 글램핑 & 노을 불멍 바비큐 팟 ⛺',
        'mainCategory': '라이프 메이트',
        'category': '동성캠핑',
        'location': '마포구 상암동 난지캠핑장 바비큐존',
        'date': '이번 주 일요일 오후 4:30',
        'imageUrl': 'assets/images/cover_wine.jpg',
        'isFemaleOnly': true,
        'host': '캠핑메이트_지유',
        'hostAvatar': 'assets/images/지연.png',
        'manner': 44.6,
        'members': '3/4',
        'price': '1/N 안심 정산',
        'transport': '마포구청역 픽업/집결',
        'schedule': '한강 노을 감상 ➔ 그릴 바비큐 & 마시멜로 불멍 토크',
        'tags': ['라이프 메이트', '동성캠핑', '캠핑', '글램핑', '동성', '불멍'],
        'photos': [
          'assets/images/cover_wine.jpg',
        ],
      },
    ];
  }

  Stream<QuerySnapshot>? _getMeetupStream() {
    try {
      if (Firebase.apps.isEmpty) return null;
      return _meetupStream ??= FirebaseFirestore.instance
          .collection('meetups')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .snapshots();
    } catch (e) {
      return null;
    }
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEAECF0), width: 1),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _homeDashboardTab.clamp(0, 4),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: coralAccent,
          unselectedItemColor: const Color(0xFF8B95A1),
          showUnselectedLabels: true,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          elevation: 0,
          backgroundColor: Colors.white,
          onTap: (index) {
            OomuHaptics.selection();
            if (index == 3) {
              oomuChatStore.syncWithCurrentUser();
            }
            setState(() {
              _homeDashboardTab = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 23),
              activeIcon: Icon(Icons.home_rounded, size: 23),
              label: '동네모임',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined, size: 23),
              activeIcon: Icon(Icons.group_rounded, size: 23),
              label: '커뮤니티',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined, size: 23),
              activeIcon: Icon(Icons.explore_rounded, size: 23),
              label: '발견',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded, size: 22),
              activeIcon: Icon(Icons.chat_bubble_rounded, size: 22),
              label: '채팅',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded, size: 23),
              activeIcon: Icon(Icons.person_rounded, size: 23),
              label: 'MY',
            ),
          ],
        ),
      ),
    );
  }
}
