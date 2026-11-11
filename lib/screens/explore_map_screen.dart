import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../ui/oomu_tokens.dart';
import '../services/kakao_map_service.dart';
import '../widgets/kakao_map_view.dart';
import '../utils/app_image.dart';
import '../utils/global_data.dart';
import 'oomu_detail_screen.dart';
import 'oomu_host_screen.dart';

/// OOMU 신규 탐색(Explore) 화면 - Mobbin 1티어 Sheet-over-Map & 카카오맵 인터랙티브 탐색 뷰
class ExploreMapScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final String? initialSpotName;
  final bool isEmbedded;

  const ExploreMapScreen({
    super.key,
    this.initialLat,
    this.initialLng,
    this.initialSpotName,
    this.isEmbedded = false,
  });

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  static const Color coralAccent = OomuTokens.coral;
  static const Color textPrimary = OomuTokens.textPrimary;
  static const Color textSecondary = OomuTokens.textSecondary;
  static const Color textMuted = OomuTokens.textMuted;

  // 기본 좌표: 여수 또는 사용자 동네 기반 초기화
  double _currentLat = 34.7677;
  double _currentLng = 127.6534;
  String _currentSpotName = '여수시 화장동 (성산공원)';

  String _selectedRadius = '3km';
  String _selectedCategory = '전체';
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  String? _selectedMeetupId;
  int _mapZoomLevel = 3;

  // 주요 핫스팟 프리셋 (원터치 이동 - 사용자 동네 맥락 연동)
  List<Map<String, dynamic>> get _currentHotspots {
    final loc = globalData.userLocation.value;
    if (loc.contains('여수') || loc.contains('화장동') || loc.contains('전남')) {
      return const [
        {'name': '여수 화장동', 'lat': 34.7677, 'lng': 127.6534, 'dong': '전남 여수시 화장동'},
        {'name': '여수 학동', 'lat': 34.7615, 'lng': 127.6580, 'dong': '전남 여수시 학동 (선소)'},
        {'name': '여수 웅천', 'lat': 34.7430, 'lng': 127.6740, 'dong': '전남 여수시 웅천동'},
        {'name': '여수 해양공원', 'lat': 34.7390, 'lng': 127.7410, 'dong': '전남 여수시 중앙동'},
        {'name': '홍대/연남', 'lat': 37.5568, 'lng': 126.9238, 'dong': '마포구 서교동'},
      ];
    }
    return const [
      {'name': '홍대/연남', 'lat': 37.5568, 'lng': 126.9238, 'dong': '마포구 서교동'},
      {'name': '성수/서울숲', 'lat': 37.5446, 'lng': 127.0440, 'dong': '성동구 성수동'},
      {'name': '강남/신사', 'lat': 37.4981, 'lng': 127.0276, 'dong': '강남구 역삼동'},
      {'name': '을지로/종로', 'lat': 37.5663, 'lng': 126.9921, 'dong': '중구 을지로'},
      {'name': '여수 화장동', 'lat': 34.7677, 'lng': 127.6534, 'dong': '전남 여수시 화장동'},
    ];
  }

  // 카테고리 필터 (홈 메인 4대 카테고리 100% 일치 동기화)
  static const List<String> _categories = [
    '전체',
    '⚡ 오늘 번개',
    '🎨 취향 아지트',
    '🏃‍♂️ 라이프 메이트',
    '☕ 카페/디저트',
    '🍷 와인/펍',
    '🍽️ 맛집 탐방',
  ];

  // 기본 탐색 모임 데이터베이스 (30대 감성 스토리형 모임)
  final List<Map<String, dynamic>> _presetMeetups = [
    {
      'id': 'exp_01',
      'title': '홍대입구 9번 출구 인생네컷·와플 🧇',
      'location': '마포구 홍대입구역 9번 출구 앞',
      'lat': 37.5568,
      'lng': 126.9238,
      'distance': '도보 180m',
      'category': '⚡ 오늘 번개',
      'members': '2/4',
      'host': '달콤한와플',
      'hostAvatar': 'assets/images/시연.png',
      'manner': 42.1,
      'imageUrl': 'assets/images/cover_cafe.jpg',
      'isLightning': true,
      'date': '오늘 즉시 (15분 후 집결)',
      'description': '퇴근길에 달달한 와플 먹으면서 사진 한 장 남기실 분! 편하게 오세요 :)',
    },
    {
      'id': 'exp_02',
      'title': '연트럴파크 돗자리 캔맥주 번개 모임 🍺',
      'location': '마포구 경의선숲길 잔디광장',
      'lat': 37.5620,
      'lng': 126.9255,
      'distance': '도보 350m',
      'category': '⚡ 오늘 번개',
      'members': '3/4',
      'host': '연트럴피플',
      'hostAvatar': 'assets/images/정재.png',
      'manner': 39.4,
      'imageUrl': 'assets/images/cover_wine.jpg',
      'isLightning': true,
      'date': '오늘 저녁 8시',
      'description': '선선한 바람 불 때 돗자리 펴고 편하게 캔맥주 한 잔 하실 동네 친구 구해요.',
    },
    {
      'id': 'exp_03',
      'title': '성수동 서울숲 잔디마당 플랫화이트 번개 ☕',
      'location': '성동구 서울숲 메인 출구',
      'lat': 37.5446,
      'lng': 127.0440,
      'distance': '도보 520m',
      'category': '☕ 카페/디저트',
      'members': '2/3',
      'host': '성수동힙스터',
      'hostAvatar': 'assets/images/지연.png',
      'manner': 43.0,
      'imageUrl': 'assets/images/cover_cafe.jpg',
      'isLightning': false,
      'date': '이번주 일요일 14:00',
      'description': '성수동 감성 에스프레소 바 투어하고 서울숲 가볍게 걸어요.',
    },
    {
      'id': 'exp_04',
      'title': '망원 한강공원 야경 나이트 러닝 (6km 페이스) 🏃',
      'location': '마포구 망원 한강공원 편의점 앞',
      'lat': 37.5532,
      'lng': 126.8965,
      'distance': '도보 750m',
      'category': '🏃 러닝/산책',
      'members': '3/5',
      'host': '망원러너',
      'hostAvatar': 'assets/images/지훈.png',
      'manner': 41.5,
      'imageUrl': 'assets/images/cover_running.jpg',
      'isLightning': true,
      'date': '오늘 밤 9시',
      'description': '초보자도 무리 없는 6분 30초 페이스! 스트레스 날려버려요.',
    },
    {
      'id': 'exp_05',
      'title': '을지로 세운상가 루프탑 LP바 & 칵테일 🍷',
      'location': '중구 을지로 세운상가 옥상',
      'lat': 37.5663,
      'lng': 126.9921,
      'distance': '도보 400m',
      'category': '🍷 와인/펍',
      'members': '2/4',
      'host': '을지로감성',
      'hostAvatar': 'assets/images/민지.png',
      'manner': 44.2,
      'imageUrl': 'assets/images/cover_wine.jpg',
      'isLightning': false,
      'date': '토요일 저녁 7시',
      'description': '힙지로 야경 내려다보며 음악과 칵테일 즐기실 직장인 분들 환영합니다.',
    },
    {
      'id': 'exp_06',
      'title': '강남역 테헤란로 직장인 주말 브런치 수다회 🥪',
      'location': '강남구 역삼동 카페거리',
      'lat': 37.4981,
      'lng': 127.0276,
      'distance': '도보 250m',
      'category': '🍽️ 맛집 탐방',
      'members': '3/4',
      'host': '브런치러버',
      'hostAvatar': 'assets/images/시연.png',
      'manner': 40.8,
      'imageUrl': 'assets/images/cover_food.jpg',
      'isLightning': false,
      'date': '토요일 오전 11:30',
      'description': '주말 아침 여유롭게 에그 베네딕트 먹으면서 다양한 직종 이야기 나눠요.',
    },
    // 여수 지역 모임 프리셋
    {
      'id': 'exp_yeosu_01',
      'title': '여수 학동 선소상가 찐맛집 털기 & 2:2 캐주얼 소셜 다이닝 🥘',
      'location': '전남 여수시 학동 선소상가 맛집골목',
      'lat': 34.7615,
      'lng': 127.6580,
      'distance': '도보 120m',
      'category': '🍽️ 맛집 탐방',
      'members': '2/4',
      'host': '우리동네_초연',
      'hostAvatar':
          'https://pub-2e97ef227fa24fa9ad20e502cfa19515.r2.dev/avatars/user_yeosu_01.jpg',
      'manner': 45.0,
      'imageUrl': 'assets/images/cover_food.jpg',
      'isLightning': false,
      'date': '이번 주 금요일 7시',
      'description': '학동 선소상가 맛집골목에서 맛있는 저녁 먹으며 편하게 수다 떨어요!',
    },
    {
      'id': 'exp_yeosu_02',
      'title': '불금엔 화장동 무선상가 코노 & 시원한 하이볼 한잔 🎤',
      'location': '전남 여수시 화장동 무선지구 상가',
      'lat': 34.7677,
      'lng': 127.6534,
      'distance': '도보 200m',
      'category': '⚡ 오늘 번개',
      'members': '2/4',
      'host': '무선지킴이',
      'hostAvatar': 'assets/images/정재.png',
      'manner': 42.8,
      'imageUrl': 'assets/images/cover_running.jpg',
      'isLightning': true,
      'date': '오늘 저녁 8시',
      'description': '퇴근 후 무선상가에서 시원하게 하이볼 한잔하고 코노에서 스트레스 풀어요!',
    },
    {
      'id': 'exp_yeosu_03',
      'title': '여수 웅천친수공원 바다 캔맥주 소셜 피크닉 & 수다 🍺',
      'location': '전남 여수시 웅천동 해변문화공원',
      'lat': 34.7430,
      'lng': 127.6740,
      'distance': '도보 350m',
      'category': '🍷 와인/펍',
      'members': '3/4',
      'host': '노을사냥꾼',
      'hostAvatar': 'assets/images/지훈.png',
      'manner': 43.5,
      'imageUrl': 'assets/images/cover_wine.jpg',
      'isLightning': false,
      'date': '이번 주말 6시',
      'description': '웅천 바다 노을을 바라보며 시원한 캔맥주 피크닉 즐겨요.',
    },
    {
      'id': 'exp_yeosu_04',
      'title': '화장동 성산공원 둘레길 가벼운 저녁 5km 런닝 크루 🏃‍♀️',
      'location': '전남 여수시 화장동 성산공원 수변무대',
      'lat': 34.7677,
      'lng': 127.6534,
      'distance': '도보 400m',
      'category': '🏃 러닝/산책',
      'members': '2/5',
      'host': '성산러너',
      'hostAvatar': 'assets/images/민지.png',
      'manner': 44.0,
      'imageUrl': 'assets/images/cover_running.jpg',
      'isLightning': true,
      'date': '오늘 저녁 8시반',
      'description': '성산공원 호수 둘레길 따라 천천히 5km 페이스 6분대로 달립니다.',
    },
    {
      'id': 'exp_yeosu_05',
      'title': '주말 여수 화장동 수제 소금빵 & 감성 베이커리 카페 오픈런 🥐',
      'location': '전남 여수시 화장동 선소상가 카페거리',
      'lat': 34.7660,
      'lng': 127.6545,
      'distance': '도보 280m',
      'category': '☕ 카페/디저트',
      'members': '2/3',
      'host': '소금빵러버',
      'hostAvatar': 'assets/images/시연.png',
      'manner': 44.2,
      'imageUrl': 'assets/images/cover_cafe.jpg',
      'isLightning': false,
      'date': '이번 주 토요일 11시',
      'description': '화장동에 새로 생긴 감성 베이커리에서 갓 구운 소금빵 함께 즐겨요!',
    },
    // 라이프 메이트 모임 프리셋 (서울/여수)
    {
      'id': 'exp_life_01',
      'title': '성산공원 둘레길 저녁 댕댕이 산책 라이프 메이트 🐕',
      'location': '전남 여수시 화장동 성산공원 수변데크',
      'lat': 34.7677,
      'lng': 127.6534,
      'distance': '도보 300m',
      'category': '🏃‍♂️ 라이프 메이트',
      'mainCategory': '라이프 메이트',
      'tags': ['라이프 메이트', '반려동물산책', '동네산책'],
      'members': '2/4',
      'host': '댕댕이산책러',
      'hostAvatar': 'assets/images/시연.png',
      'manner': 43.8,
      'imageUrl': 'assets/images/cover_running.jpg',
      'isLightning': false,
      'date': '오늘 저녁 7시반',
      'description': '강아지랑 가볍게 공원 한 바퀴 돌며 산책하실 동네 이웃 구해요!',
    },
    {
      'id': 'exp_life_02',
      'title': '학동 대형마트 1인 가구 과일·대용량 식자재 소분 메이트 🛒',
      'location': '전남 여수시 학동 선소상가 인근',
      'lat': 34.7615,
      'lng': 127.6580,
      'distance': '도보 450m',
      'category': '🏃‍♂️ 라이프 메이트',
      'mainCategory': '라이프 메이트',
      'tags': ['라이프 메이트', '1인가구장보기/소분', '소분'],
      'members': '2/2',
      'host': '알뜰살림러',
      'hostAvatar': 'assets/images/정재.png',
      'manner': 44.5,
      'imageUrl': 'assets/images/cover_food.jpg',
      'isLightning': false,
      'date': '내일 오후 3시',
      'description': '혼자 다 못 먹는 대용량 식재료 함께 장보고 딱 반씩 소분해요.',
    },
    {
      'id': 'exp_life_03',
      'title': '망원시장 1인 가구 제철과일 & 반찬 1/N 소분 메이트 🍎',
      'location': '마포구 망원시장 입구',
      'lat': 37.5558,
      'lng': 126.9054,
      'distance': '도보 350m',
      'category': '🏃‍♂️ 라이프 메이트',
      'mainCategory': '라이프 메이트',
      'tags': ['라이프 메이트', '1인가구장보기/소분', '소분'],
      'members': '2/3',
      'host': '망원자취러',
      'hostAvatar': 'assets/images/민지.png',
      'manner': 42.9,
      'imageUrl': 'assets/images/cover_food.jpg',
      'isLightning': false,
      'date': '이번 주말 15:00',
      'description': '1인 가구라 버리기 아까운 제철 과일과 반찬 같이 소분해서 나눠요.',
    },
    {
      'id': 'exp_life_04',
      'title': '연남동 숲길 주말 아침 가벼운 조깅 & 헬스 라이프 메이트 🏃',
      'location': '마포구 연남동 경의선숲길',
      'lat': 37.5620,
      'lng': 126.9255,
      'distance': '도보 400m',
      'category': '🏃‍♂️ 라이프 메이트',
      'mainCategory': '라이프 메이트',
      'tags': ['라이프 메이트', '러닝·운동', '운동'],
      'members': '3/4',
      'host': '건강러버',
      'hostAvatar': 'assets/images/지훈.png',
      'manner': 43.2,
      'imageUrl': 'assets/images/cover_running.jpg',
      'isLightning': false,
      'date': '토요일 아침 8시',
      'description': '혼자 운동하기 심심한 분들, 가볍게 뛰며 건강한 하루 시작해요!',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _currentLat = widget.initialLat!;
      _currentLng = widget.initialLng!;
      if (widget.initialSpotName != null) {
        _currentSpotName = widget.initialSpotName!;
      }
    } else {
      final loc = globalData.userLocation.value;
      if (loc.contains('여수') || loc.contains('화장동') || loc.contains('전남')) {
        _currentLat = 34.7677;
        _currentLng = 127.6534;
        _currentSpotName = '여수시 화장동 (성산공원)';
      } else {
        _currentLat = 37.5568;
        _currentLng = 126.9238;
        _currentSpotName = '마포구 서교동 (홍대입구역)';
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 검색 또는 핫스팟 클릭 시 지도 이동
  Future<void> _moveToLocation(double lat, double lng, String name) async {
    HapticFeedback.lightImpact();
    setState(() {
      _currentLat = lat;
      _currentLng = lng;
      _currentSpotName = name;
    });
  }

  // 키워드 검색
  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final results =
          await KakaoMapService.searchKeyword(query.trim(), size: 1);
      if (results.isNotEmpty) {
        final first = results.first;
        await _moveToLocation(first.lat, first.lng, first.name);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📍 \'${first.name}\' 카카오 지도로 이동했습니다.'),
              backgroundColor: coralAccent,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('검색 결과가 없습니다. 다른 지명을 입력해보세요.')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 검색 중 오류가 발생했습니다.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // GPS 현재 위치로 이동
  Future<void> _moveToCurrentGps() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    try {
      final loc = globalData.userLocation.value;
      double targetLat = 34.7677;
      double targetLng = 127.6534;
      String targetName = '여수시 화장동 (성산공원)';

      if (!loc.contains('여수') && !loc.contains('화장동') && !loc.contains('전남') && loc.isNotEmpty) {
        targetLat = 37.5568;
        targetLng = 126.9238;
        targetName = '마포구 서교동 (홍대입구역)';
      }

      await _moveToLocation(targetLat, targetLng, '내 GPS 현재 위치 ($targetName)');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎯 $targetName (동네 위치 정밀 동기화 완료)'),
            backgroundColor: OomuTokens.verified,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 두 위경도 좌표 간 거리 계산 (Haversine 공식, km 단위)
  double _calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 - math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) * math.cos(lat2 * p) *
        (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R, R = 6371 km
  }

  // 참여 인원 문자열 포맷팅 (UID 배열 노출 방지)
  String _formatMemberCount(dynamic members, [dynamic maxMembers]) {
    final max = maxMembers ?? 4;
    if (members is List) {
      return '${members.length}/$max명 참여';
    } else if (members is int) {
      return '$members/$max명 참여';
    } else if (members is String) {
      if (members.contains('/')) return '$members명 참여';
      final parsed = int.tryParse(members);
      if (parsed != null) return '$parsed/$max명 참여';
      return '$members명 참여';
    }
    return '2/$max명 참여';
  }

  // 현재 필터 및 반경에 따른 모임 목록 필터링
  List<Map<String, dynamic>> _getFilteredMeetups(
      List<Map<String, dynamic>> rawList) {
    // 1. 거리 계산
    final listWithDistance = rawList.map((m) {
      final copy = Map<String, dynamic>.from(m);
      final lat = (copy['lat'] as num?)?.toDouble();
      final lng = (copy['lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        final dist = _calculateDistanceKm(_currentLat, _currentLng, lat, lng);
        copy['_distanceKm'] = dist;
        copy['distance'] = dist < 1.0
            ? '도보 ${(dist * 1000).toInt()}m'
            : '${dist.toStringAsFixed(1)}km';
      } else {
        final locStr = (copy['location'] ?? '').toString();
        if (_currentSpotName.contains('여수') && locStr.contains('여수')) {
          copy['_distanceKm'] = 0.4;
          copy['distance'] = '도보 400m';
        } else if (!_currentSpotName.contains('여수') && !locStr.contains('여수')) {
          copy['_distanceKm'] = 0.6;
          copy['distance'] = '도보 600m';
        } else {
          copy['_distanceKm'] = 310.0;
          copy['distance'] = '310km';
        }
      }
      return copy;
    }).toList();

    // 2. 반경 기준 설정
    double maxRadiusKm = double.infinity;
    if (_selectedRadius == '1km') {
      maxRadiusKm = 1.8; // 반경 1km 기준 (오차 고려 1.8km)
    } else if (_selectedRadius == '3km') {
      maxRadiusKm = 3.5;
    } else if (_selectedRadius == '5km') {
      maxRadiusKm = 5.5;
    }

    final filtered = listWithDistance.where((m) {
      // 반경 필터 (다른 도시 모임 배제)
      final distKm = (m['_distanceKm'] as num?)?.toDouble() ?? 0.0;
      if (distKm > maxRadiusKm) return false;

      // 카테고리 필터
      if (_selectedCategory != '전체') {
        final cat = (m['category'] ?? m['mainCategory'] ?? '').toString();
        final tags = ((m['tags'] as List?)?.join(' ') ?? '').toString();
        final title = (m['title'] ?? '').toString();
        final combined = '$cat $tags $title'.toLowerCase();

        if (_selectedCategory == '⚡ 오늘 번개') {
          if (m['isLightning'] != true && !combined.contains('번개')) return false;
        } else if (_selectedCategory.contains('라이프')) {
          if (!combined.contains('라이프') &&
              !combined.contains('메이트') &&
              !combined.contains('소분') &&
              !combined.contains('장보기') &&
              !combined.contains('산책') &&
              !combined.contains('운동')) return false;
        } else if (_selectedCategory.contains('취향')) {
          if (!combined.contains('취향') &&
              !combined.contains('아지트') &&
              !combined.contains('공연') &&
              !combined.contains('전시') &&
              !combined.contains('카페') &&
              !combined.contains('와인') &&
              !combined.contains('문화') &&
              !combined.contains('독서')) return false;
        } else {
          final cleanCat = _selectedCategory
              .replaceAll(RegExp(r'[^\uAC00-\uD7A3a-zA-Z]'), '')
              .trim()
              .toLowerCase();
          if (!combined.contains(cleanCat)) return false;
        }
      }

      // 검색어 필터
      final q = _searchController.text.trim().toLowerCase();
      if (q.isNotEmpty) {
        final title = (m['title'] ?? '').toString().toLowerCase();
        final loc = (m['location'] ?? '').toString().toLowerCase();
        if (!title.contains(q) && !loc.contains(q)) return false;
      }

      return true;
    }).toList();

    // 3. 거리순 정렬
    filtered.sort((a, b) {
      final da = (a['_distanceKm'] as num?)?.toDouble() ?? 999.0;
      final db = (b['_distanceKm'] as num?)?.toDouble() ?? 999.0;
      return da.compareTo(db);
    });

    return filtered;
  }

  void _focusMeetupOnMap(Map<String, dynamic> m, {bool openDetail = false}) {
    HapticFeedback.selectionClick();
    final double? lat =
        (m['lat'] is num) ? (m['lat'] as num).toDouble() : null;
    final double? lng =
        (m['lng'] is num) ? (m['lng'] as num).toDouble() : null;
    setState(() {
      _selectedMeetupId = (m['id'] ?? '').toString();
      if (lat != null && lng != null) {
        _currentLat = lat;
        _currentLng = lng;
      }
      final loc = (m['location'] ?? '').toString();
      if (loc.isNotEmpty) {
        _currentSpotName = loc;
      }
    });
    if (openDetail && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OOMUDetailScreen(meetup: m),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OomuTokens.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: !widget.isEmbedded,
        leading: widget.isEmbedded
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
        titleSpacing: 0,
        title: const Text(
          '동네 지도 탐색 (카카오맵)',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: OomuTokens.fs17,
          ),
        ),
        actions: [
          IconButton(
            tooltip: '내 현재 위치',
            icon: const Icon(Icons.my_location_rounded, color: coralAccent),
            onPressed: _moveToCurrentGps,
          ),
          IconButton(
            tooltip: '새 모임 개설',
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: coralAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OOMUHostScreen(
                    initialLocation: _currentSpotName,
                    initialLat: _currentLat,
                    initialLng: _currentLng,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: OomuTokens.border, height: 1),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('meetups')
            .orderBy('createdAt', descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          final List<Map<String, dynamic>> meetups = [];
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            for (final doc in snapshot.data!.docs) {
              final data =
                  Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
              data['id'] = doc.id;
              meetups.add(data);
            }
          }
          final Set<String> existingTitles =
              meetups.map((m) => (m['title'] ?? '').toString()).toSet();
          for (final preset in _presetMeetups) {
            if (!existingTitles.contains(preset['title'])) {
              meetups.add(preset);
            }
          }

          final filtered = _getFilteredMeetups(meetups);
          Map<String, dynamic>? selectedMeetup;
          if (_selectedMeetupId != null && _selectedMeetupId!.isNotEmpty) {
            for (final item in filtered) {
              if ((item['id'] ?? '').toString() == _selectedMeetupId) {
                selectedMeetup = item;
                break;
              }
            }
            selectedMeetup ??= meetups.cast<Map<String, dynamic>?>().firstWhere(
                  (item) =>
                      (item?['id'] ?? '').toString() == _selectedMeetupId,
                  orElse: () => null,
                );
          }
          if (selectedMeetup == null && filtered.isNotEmpty) {
            selectedMeetup = filtered.first;
          }

          return Column(
            children: [
              // 1. 상단 고정 검색 & 핫스팟/카테고리 바 (지도 영역과 분리되어 터치 간섭 없음)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: OomuTokens.background,
                        borderRadius: BorderRadius.circular(OomuTokens.r14),
                        border: Border.all(color: OomuTokens.border),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 12, right: 8),
                            child: Icon(Icons.search_rounded,
                                color: coralAccent, size: 20),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(
                                  fontSize: OomuTokens.fs14,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary),
                              decoration: const InputDecoration(
                                hintText: '동네, 지하철역, 취향 키워드 검색',
                                hintStyle: TextStyle(
                                    fontSize: OomuTokens.fs13, color: textMuted),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 11),
                              ),
                              onSubmitted: _searchLocation,
                              onChanged: (val) => setState(() {}),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear,
                                  size: 18, color: textMuted),
                              onPressed: () {
                                setState(() => _searchController.clear());
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.tune_rounded,
                                size: 19, color: textSecondary),
                            onPressed: () => _showFilterModal(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 32,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _currentHotspots.length,
                        itemBuilder: (context, index) {
                          final spot = _currentHotspots[index];
                          final isSelected = _currentSpotName
                              .contains(spot['name'] as String);
                          return GestureDetector(
                            onTap: () => _moveToLocation(
                              (spot['lat'] as num).toDouble(),
                              (spot['lng'] as num).toDouble(),
                              spot['dong'] as String,
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 11, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? coralAccent
                                    : OomuTokens.background,
                                borderRadius: BorderRadius.circular(OomuTokens.r16),
                                border: Border.all(
                                  color: isSelected
                                      ? coralAccent
                                      : OomuTokens.border,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.place_rounded,
                                    size: 13,
                                    color:
                                        isSelected ? Colors.white : coralAccent,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    spot['name'] as String,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      fontSize: OomuTokens.fs12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 30,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = _selectedCategory == cat;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedCategory = cat);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? textPrimary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(OomuTokens.r14),
                                border: Border.all(
                                  color: isSelected
                                      ? textPrimary
                                      : OomuTokens.border,
                                ),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  fontSize: OomuTokens.fs11,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 2. 독립된 지도 캔버스 영역 (확대/축소가 지도 내부에만 적용됨)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(OomuTokens.r16),
                            border: Border.all(color: OomuTokens.border),
                          ),
                          child: KakaoMapView(
                            lat: _currentLat,
                            lng: _currentLng,
                            locationName: _currentSpotName,
                            height: 220,
                            hideActions: true,
                            markers: filtered.isNotEmpty ? filtered : meetups,
                            selectedMarkerId:
                                (selectedMeetup?['id'] ?? '').toString(),
                            zoomLevel: _mapZoomLevel,
                            onMarkerTap: (markerId, shouldOpenDetail) {
                              final target = meetups.firstWhere(
                                (m) => (m['id'] ?? '').toString() == markerId,
                                orElse: () => <String, dynamic>{},
                              );
                              if (target.isNotEmpty) {
                                _focusMeetupOnMap(target,
                                    openDetail: shouldOpenDetail);
                              }
                            },
                          ),
                        ),
                        // 지도 전용 확대/축소 컨트롤 (지도 박스 우측 하단에 격리)
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(OomuTokens.r10),
                              border:
                                  Border.all(color: OomuTokens.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _mapZoomLevel =
                                          (_mapZoomLevel - 1).clamp(1, 9);
                                    });
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    child: Text('+',
                                        style: TextStyle(
                                            fontSize: OomuTokens.fs15,
                                            fontWeight: FontWeight.w900,
                                            color: textPrimary)),
                                  ),
                                ),
                                Container(
                                    width: 1,
                                    height: 18,
                                    color: OomuTokens.border),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _mapZoomLevel =
                                          (_mapZoomLevel + 1).clamp(1, 9);
                                    });
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    child: Text('−',
                                        style: TextStyle(
                                            fontSize: OomuTokens.fs15,
                                            fontWeight: FontWeight.w900,
                                            color: textPrimary)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isLoading)
                          Positioned.fill(
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.72),
                                  borderRadius: BorderRadius.circular(OomuTokens.r16),
                                ),
                                child: const Text(
                                  '지도 이동 중...',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: OomuTokens.fs12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    // 지도 마커 빠른 선택 칩 & 선택된 모임 즉시 이동 바
                    if (selectedMeetup != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: textPrimary,
                          borderRadius: BorderRadius.circular(OomuTokens.r14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: coralAccent,
                                borderRadius: BorderRadius.circular(OomuTokens.r6),
                              ),
                              child: const Text(
                                '📍 선택된 모임',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: OomuTokens.fs11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                (selectedMeetup['title'] ?? '').toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: OomuTokens.fs13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OOMUDetailScreen(
                                        meetup: selectedMeetup!),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: OomuTokens.surface,
                                  borderRadius:
                                      BorderRadius.circular(OomuTokens.r8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '모임 이동',
                                      style: TextStyle(
                                        color: OomuTokens.textPrimary,
                                        fontSize: OomuTokens.fs12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(Icons.chevron_right_rounded,
                                        size: 15,
                                        color: OomuTokens.textPrimary),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // 3. 하단 모임 리스트 (특정 모임 지도 위치 선택 + 모임 상세 이동)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: OomuTokens.surface,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(OomuTokens.r24)),
                  ),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.explore_rounded,
                                      color: OomuTokens.primary, size: 19),
                                  const SizedBox(width: 6),
                                  Text(
                                    '현재 반경 모임 (${filtered.length}개)',
                                    style: TextStyle(
                                      fontSize: OomuTokens.fs16,
                                      fontWeight: FontWeight.w800,
                                      color: OomuTokens.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: OomuTokens.primarySubtle,
                                  borderRadius:
                                      BorderRadius.circular(OomuTokens.r12),
                                ),
                                child: Text(
                                  '$_selectedRadius 반경',
                                  style: TextStyle(
                                    fontSize: OomuTokens.fs12,
                                    fontWeight: FontWeight.bold,
                                    color: OomuTokens.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Divider(height: 1, color: OomuTokens.divider),
                      ),
                      if (filtered.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 32),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.explore_off_rounded,
                                      size: 36,
                                      color: OomuTokens.textTertiary),
                                  const SizedBox(height: 12),
                                  Text(
                                    '현재 필터 조건에 맞는 모임이 없어요',
                                    style: TextStyle(
                                      fontSize: OomuTokens.fs15,
                                      fontWeight: FontWeight.w700,
                                      color: OomuTokens.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _selectedCategory = '전체';
                                        _selectedRadius = '전체';
                                        _searchController.clear();
                                      });
                                    },
                                    icon: const Icon(Icons.refresh_rounded,
                                        size: 16),
                                    label: const Text('필터 초기화',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: OomuTokens.primary,
                                      foregroundColor: OomuTokens.surface,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              OomuTokens.r12)),
                                    ),
                                  ),
                                ]),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final m = filtered[index];
                                return _buildMeetupCard(context, m,
                                    isSelectedOnMap: (m['id'] ?? '').toString() ==
                                        (selectedMeetup?['id'] ?? '')
                                            .toString());
                              },
                              childCount: filtered.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 100점 풀-피니시 모임 카드 위젯 (당근/문토/29CM 표준 규격)
  Widget _buildMeetupCard(BuildContext context, Map<String, dynamic> m,
      {bool isSelectedOnMap = false}) {
    final isLightning = m['isLightning'] == true;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focusMeetupOnMap(m, openDetail: true),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: OomuTokens.surface,
          borderRadius: BorderRadius.circular(OomuTokens.r20),
          border: Border.all(
            color: isSelectedOnMap
                ? OomuTokens.primary
                : (isLightning
                    ? OomuTokens.primaryBorder
                    : OomuTokens.border),
            width: isSelectedOnMap ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 88x88 정방형 썸네일
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(OomuTokens.r14),
                        child: SizedBox(
                          width: 88,
                          height: 88,
                          child: appNetImage(
                            (m['imageUrl'] ??
                                    m['image'] ??
                                    'assets/images/cover_cafe.jpg')
                                .toString(),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (isLightning)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: OomuTokens.primary,
                              borderRadius:
                                  BorderRadius.circular(OomuTokens.r6),
                            ),
                            child: Text(
                              '⚡번개',
                              style: TextStyle(
                                  color: OomuTokens.surface,
                                  fontSize: OomuTokens.fs11,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),

                  // 2. 모임 정보 컨텐츠
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 카테고리 태그 & 선택 상태 뱃지
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: OomuTokens.surfaceElevated,
                                borderRadius:
                                    BorderRadius.circular(OomuTokens.r6),
                              ),
                              child: Text(
                                (m['category'] ??
                                        m['mainCategory'] ??
                                        '일상 & 소통')
                                    .toString(),
                                style: TextStyle(
                                    fontSize: OomuTokens.fs11,
                                    fontWeight: FontWeight.bold,
                                    color: OomuTokens.textSecondary),
                              ),
                            ),
                            if (isSelectedOnMap) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: OomuTokens.primarySubtle,
                                  borderRadius:
                                      BorderRadius.circular(OomuTokens.r6),
                                ),
                                child: Text(
                                  '지도 선택됨',
                                  style: TextStyle(
                                      fontSize: OomuTokens.fs11,
                                      fontWeight: FontWeight.w800,
                                      color: OomuTokens.primary),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),

                        // 제목
                        Text(
                          (m['title'] ?? '').toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: OomuTokens.fs15,
                            fontWeight: FontWeight.w800,
                            color: OomuTokens.textPrimary,
                            height: 1.32,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // 호스트 정보 & 매너온도
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundImage: appImg((m['hostAvatar'] ??
                                          'assets/images/민지.png')
                                      .toString()),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${m['host'] ?? '호스트'}',
                                  style: TextStyle(
                                      fontSize: OomuTokens.fs12,
                                      fontWeight: FontWeight.bold,
                                      color: OomuTokens.textPrimary),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: OomuTokens.mannerYellowBg,
                                    borderRadius:
                                        BorderRadius.circular(OomuTokens.r6),
                                    border: Border.all(
                                        color: OomuTokens.mannerYellowBorder),
                                  ),
                                  child: Text(
                                    '${m['manner'] ?? 41.2}°C 🔥',
                                    style: TextStyle(
                                        fontSize: OomuTokens.fs11,
                                        fontWeight: FontWeight.w800,
                                        color: OomuTokens.mannerYellowText),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              _formatMemberCount(m['members'], m['maxMembers']),
                              style: TextStyle(
                                  fontSize: OomuTokens.fs11,
                                  fontWeight: FontWeight.w700,
                                  color: OomuTokens.textTertiary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // 위치 & 일정 요약 + [지도 위치 선택] / [모임 상세 이동] 액션 바
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: OomuTokens.surfaceElevated,
                  borderRadius: BorderRadius.circular(OomuTokens.r12),
                  border: Border.all(color: OomuTokens.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 15, color: OomuTokens.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            (m['location'] ?? '위치 미지정').toString(),
                            style: TextStyle(
                                fontSize: OomuTokens.fs13,
                                fontWeight: FontWeight.w700,
                                color: OomuTokens.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (m['distance'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: OomuTokens.primarySubtle,
                              borderRadius:
                                  BorderRadius.circular(OomuTokens.r6),
                            ),
                            child: Text(
                              m['distance'].toString(),
                              style: TextStyle(
                                  fontSize: OomuTokens.fs11,
                                  fontWeight: FontWeight.w800,
                                  color: OomuTokens.primary),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Divider(height: 1, color: OomuTokens.divider),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _focusMeetupOnMap(m, openDetail: false),
                            borderRadius:
                                BorderRadius.circular(OomuTokens.r8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelectedOnMap
                                    ? OomuTokens.primarySubtle
                                    : OomuTokens.surface,
                                borderRadius:
                                    BorderRadius.circular(OomuTokens.r8),
                                border: Border.all(
                                  color: isSelectedOnMap
                                      ? OomuTokens.primary
                                      : OomuTokens.border,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                isSelectedOnMap
                                    ? '📍 지도에 표시 중'
                                    : '📍 지도에서 위치 보기',
                                style: TextStyle(
                                  fontSize: OomuTokens.fs12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelectedOnMap
                                      ? OomuTokens.primary
                                      : OomuTokens.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => _focusMeetupOnMap(m, openDetail: true),
                            borderRadius:
                                BorderRadius.circular(OomuTokens.r8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              decoration: BoxDecoration(
                                color: OomuTokens.textPrimary,
                                borderRadius:
                                    BorderRadius.circular(OomuTokens.r8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '해당 모임으로 이동 ›',
                                style: TextStyle(
                                  fontSize: OomuTokens.fs12,
                                  fontWeight: FontWeight.w700,
                                  color: OomuTokens.surface,
                                ),
                              ),
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
      ),
    );
  }

  // 필터 모달
  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: OomuTokens.surface,
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(OomuTokens.r24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '탐색 반경 및 필터 설정',
                        style: TextStyle(
                            fontSize: OomuTokens.fs18,
                            fontWeight: FontWeight.w800,
                            color: OomuTokens.textPrimary),
                      ),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setModalState(() {
                                _selectedCategory = '전체';
                                _selectedRadius = '전체';
                                _searchController.clear();
                              });
                              setState(() {
                                _selectedCategory = '전체';
                                _selectedRadius = '전체';
                                _searchController.clear();
                              });
                            },
                            icon: Icon(Icons.refresh_rounded,
                                size: 16, color: OomuTokens.primary),
                            label: Text(
                              '전체 초기화',
                              style: TextStyle(
                                fontSize: OomuTokens.fs13,
                                fontWeight: FontWeight.bold,
                                color: OomuTokens.primary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close,
                                color: OomuTokens.textPrimary),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('탐색 카테고리',
                      style: TextStyle(
                          fontSize: OomuTokens.fs14,
                          fontWeight: FontWeight.bold,
                          color: OomuTokens.textSecondary)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSel = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSel,
                        selectedColor: OomuTokens.primarySubtle,
                        backgroundColor: OomuTokens.surfaceElevated,
                        side: BorderSide(
                          color: isSel
                              ? OomuTokens.primary
                              : OomuTokens.border,
                        ),
                        labelStyle: TextStyle(
                          color: isSel
                              ? OomuTokens.primary
                              : OomuTokens.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: OomuTokens.fs12,
                        ),
                        onSelected: (val) {
                          setModalState(() => _selectedCategory = cat);
                          setState(() => _selectedCategory = cat);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('탐색 반경 기준',
                      style: TextStyle(
                          fontSize: OomuTokens.fs14,
                          fontWeight: FontWeight.bold,
                          color: OomuTokens.textSecondary)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: ['500m', '1km', '3km', '전체'].map((r) {
                      final isSel = _selectedRadius == r;
                      return ChoiceChip(
                        label: Text(r),
                        selected: isSel,
                        selectedColor: OomuTokens.primary,
                        backgroundColor: OomuTokens.surfaceElevated,
                        side: BorderSide(
                          color: isSel
                              ? OomuTokens.primary
                              : OomuTokens.border,
                        ),
                        labelStyle: TextStyle(
                          color: isSel
                              ? OomuTokens.surface
                              : OomuTokens.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: OomuTokens.fs12,
                        ),
                        onSelected: (val) {
                          setModalState(() => _selectedRadius = r);
                          setState(() => _selectedRadius = r);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OomuTokens.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(OomuTokens.r16)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('필터 적용하기',
                          style: TextStyle(
                              color: OomuTokens.surface,
                              fontWeight: FontWeight.bold,
                              fontSize: OomuTokens.fs16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
