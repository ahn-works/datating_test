import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// OOMU 로컬 가상 API 서버(g4f) 연동 AI 서비스
/// - Base URL: http://127.0.0.1:1337/v1 (OpenAI 호환 규격)
/// - 기본 모델: claude-3-haiku (보조/상황별 모델: Claude 7종 & GPT 9종 지원)
/// - API Key: pk-dummy (로컬 프록시 서버 전용 더미 값, Zero-Secret 정책 준수)
class OomuAiService {
  static final OomuAiService _instance = OomuAiService._internal();
  factory OomuAiService() => _instance;
  OomuAiService._internal();

  static const String defaultBaseUrl = 'http://127.0.0.1:1337/v1';
  static const String defaultModel = 'claude-3-haiku';
  static const String sonnetModel = 'claude-3-sonnet';
  static const String sonnet35Model = 'claude-3-5-sonnet';
  static const String sonnet4Model = 'claude-sonnet-4';
  static const String opusModel = 'claude-3-opus';
  static const String gpt4oModel = 'gpt-4o';
  static const String gpt4oMiniModel = 'gpt-4o-mini';
  static const String gpt41Model = 'gpt-4.1';
  static const String o3MiniModel = 'o3-mini';
  static const String dummyApiKey = 'pk-dummy';

  /// 로컬 g4f 서버에 설치/등록된 Claude 모델 리스트
  static const List<String> installedClaudeModels = [
    'claude-3-haiku',
    'claude-haiku-4.5',
    'claude-3-sonnet',
    'claude-3-5-sonnet',
    'claude-sonnet-4',
    'claude-3-opus',
    'claude-opus-4',
  ];

  /// 로컬 g4f 서버에 설치/등록된 GPT 모델 리스트
  static const List<String> installedGptModels = [
    'gpt-4o',
    'gpt-4o-mini',
    'gpt-4.1',
    'gpt-4.1-mini',
    'gpt-4.1-nano',
    'gpt-4',
    'gpt-4.5',
    'o3-mini',
    'o4-mini',
  ];

  String baseUrl = defaultBaseUrl;
  String model = defaultModel;
  String apiKey = dummyApiKey;

  String get chatCompletionsUrl {
    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$cleanBase/chat/completions';
  }

  /// 로컬 g4f 프록시 서버(/v1/chat/completions)로 메시지를 전송하고 응답 텍스트를 반환합니다.
  Future<String> createChatCompletion({
    required List<Map<String, String>> messages,
    String? targetModel,
    http.Client? httpClient,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final client = httpClient ?? http.Client();
    final activeModel = (targetModel != null && targetModel.trim().isNotEmpty)
        ? targetModel.trim()
        : model;

    try {
      final response = await client
          .post(
            Uri.parse(chatCompletionsUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': activeModel,
              'messages': messages,
              'stream': false,
            }),
          )
          .timeout(timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic>) {
          final choices = decoded['choices'];
          if (choices is List && choices.isNotEmpty) {
            final first = choices.first;
            if (first is Map && first['message'] is Map) {
              final content = first['message']['content']?.toString().trim() ?? '';
              if (content.isNotEmpty) {
                return content;
              }
            }
          }
        }
      }
      debugPrint('[OOMU AI] Unexpected status ${response.statusCode}: ${response.body}');
    } catch (e) {
      debugPrint('[OOMU AI] Local Claude/GPT proxy error ($activeModel): $e');
    } finally {
      if (httpClient == null) {
        client.close();
      }
    }

    return '';
  }

  /// [OOMU Phase 1] 온보딩 자기소개 텍스트에서 취향/가치관 해시태그 자동 추출
  Future<List<String>> extractOnboardingTags(
    String bioText, {
    String? targetModel,
    http.Client? httpClient,
  }) async {
    const fallbackTags = ['#동네산책', '#카페투어', '#맛집탐방', '#대화환영'];
    if (bioText.trim().isEmpty) return fallbackTags;

    final reply = await createChatCompletion(
      targetModel: targetModel ?? defaultModel,
      httpClient: httpClient,
      messages: [
        {
          'role': 'system',
          'content': '사용자의 자기소개 문장에서 취향 및 가치관 핵심 키워드 4개를 #태그 형식의 쉼표 구분 문자열로만 출력하세요.',
        },
        {
          'role': 'user',
          'content': bioText.trim(),
        },
      ],
    );

    if (reply.isEmpty) return fallbackTags;

    final parsed = reply
        .split(RegExp(r'[,\n]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => s.startsWith('#') ? s : '#$s')
        .take(4)
        .toList();

    return parsed.isNotEmpty ? parsed : fallbackTags;
  }

  /// [OOMU 매칭 알고리즘 4] 모임방 오픈 시 멤버 페르소나 기반 아이스브레이킹 질문 생성
  Future<String> generateIcebreakerQuestion({
    required String meetingTitle,
    List<String> memberTags = const [],
    String? targetModel,
    http.Client? httpClient,
  }) async {
    final fallbackQuestion =
        '반갑습니다! "$meetingTitle" 모임에서 오늘 가장 기대되는 순간은 무엇인가요? 😊';

    final tagsText = memberTags.isEmpty ? '맛집, 대화, 동네모임' : memberTags.join(', ');
    final reply = await createChatCompletion(
      targetModel: targetModel ?? defaultModel,
      httpClient: httpClient,
      messages: [
        {
          'role': 'user',
          'content':
              '모임 제목이 "$meetingTitle"이고 참여 멤버들의 관심사가 [$tagsText]일 때, 어색함을 깨는 환영 인사 겸 첫 질문 한 문장을 한국어로 작성해줘.',
        },
      ],
    );

    return reply.isNotEmpty ? reply : fallbackQuestion;
  }

  /// [OOMU P3] 대화방 성격 및 테마에 맞춘 3가지 아이스브레이킹 대화 주제 추천 생성
  Future<List<Map<String, String>>> generateIcebreakerTopics({
    required String meetingTitle,
    String? category,
    List<String> tags = const [],
    int seedOffset = 0,
  }) async {
    final lowerTitle = meetingTitle.toLowerCase();
    final lowerCategory = (category ?? '').toLowerCase();

    List<Map<String, String>> fallbackTopics;

    if (lowerTitle.contains('공연') || lowerTitle.contains('뮤지컬') || lowerTitle.contains('콘서트') || lowerCategory.contains('공연') || lowerCategory.contains('문화')) {
      fallbackTopics = [
        {
          'tag': '취향 탐색',
          'icon': '🎶',
          'question': '이번 공연에서 가장 기대되는 넘버나 배우님(또는 셋리스트) 있으신가요?',
        },
        {
          'tag': '모임 꿀팁',
          'icon': '🎭',
          'question': '공연장 주변에서 끝나고 가볍게 극 후기 나눌만한 카페나 펍 아시는 곳 있나요?',
        },
        {
          'tag': '밸런스 토크',
          'icon': '👀',
          'question': '오페라글라스로 표정 초집중파 vs 무대 전체 연출과 조명 감상파?',
        },
      ];
    } else if (lowerTitle.contains('러닝') || lowerTitle.contains('운동') || lowerTitle.contains('산책') || lowerCategory.contains('러닝') || lowerCategory.contains('운동')) {
      fallbackTopics = [
        {
          'tag': '취향 탐색',
          'icon': '🎧',
          'question': '뛸 때 들으면 발걸음이 가벼워지는 최애 러닝 플레이리스트 곡 있나요?',
        },
        {
          'tag': '모임 꿀팁',
          'icon': '🏃‍♂️',
          'question': '오늘 러닝 마치고 시원한 편의점 이온음료/맥주 가볍게 한잔 어떠신가요?',
        },
        {
          'tag': '밸런스 토크',
          'icon': '🌙',
          'question': '선선한 밤바람 맞으며 뛰는 야간 러닝파 vs 상쾌한 아침 공기 모닝 러닝파?',
        },
      ];
    } else if (lowerTitle.contains('소개팅') || lowerTitle.contains('애프터') || lowerCategory.contains('소개팅') || lowerCategory.contains('데이트')) {
      fallbackTopics = [
        {
          'tag': '일상 탐색',
          'icon': '☕',
          'question': '퇴근 후나 주말에 보통 충전하는 나만의 소소한 힐링 루틴이 있다면?',
        },
        {
          'tag': '공통 관심사',
          'icon': '🍷',
          'question': '최근에 가본 동네 맛집이나 카페 중 가장 기억에 남는 곳이 어디인가요?',
        },
        {
          'tag': '밸런스 토크',
          'icon': '✨',
          'question': '첫 데이트는 감성 넘치는 조용한 와인바 vs 북적북적 활기찬 야장/노포 포차?',
        },
      ];
    } else {
      // 기본: 맛집, 카페, 소셜 다이닝 (예: 마라탕/와인 등)
      fallbackTopics = [
        {
          'tag': '취향 탐색',
          'icon': '🌶️',
          'question': '다들 오늘 메뉴 맵기나 맛 취향이 어떻게 되시나요? 탕 vs 샹궈 취향도 궁금해요!',
        },
        {
          'tag': '모임 꿀팁',
          'icon': '🍲',
          'question': '오늘 가는 곳에서 절대 빠뜨릴 수 없는 필수 추천 토핑이나 시그니처 메뉴가 있나요?',
        },
        {
          'tag': '밸런스 토크',
          'icon': '📸',
          'question': '음식 나오면 사진부터 찍는 감성파 vs 냄새 맡자마자 숟가락 먼저 드는 직진파?',
        },
      ];
    }

    // 로컬 AI 프록시 연결 시도 (실패 시 안전하게 폴백 반환)
    try {
      final reply = await createChatCompletion(
        timeout: const Duration(seconds: 4),
        messages: [
          {
            'role': 'system',
            'content': '모임 대화방에서 첫 어색함을 깨는 2030 센스 있는 대화 질문 3개를 줄바꿈(1., 2., 3.)으로만 출력해.',
          },
          {
            'role': 'user',
            'content': '모임 제목: $meetingTitle, 카테고리: ${category ?? "동네 모임"}',
          },
        ],
      );

      if (reply.isNotEmpty) {
        final lines = reply.split('\n').where((l) => l.trim().isNotEmpty).toList();
        if (lines.length >= 3) {
          return [
            {'tag': '취향 탐색', 'icon': '✨', 'question': lines[0].replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '').trim()},
            {'tag': '모임 꿀팁', 'icon': '💡', 'question': lines[1].replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '').trim()},
            {'tag': '밸런스 토크', 'icon': '🎯', 'question': lines[2].replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '').trim()},
          ];
        }
      }
    } catch (_) {}

    return fallbackTopics;
  }

  /// [OOMU P3] 장소/맛집 1분 상세 요약 구조체 반환
  Map<String, dynamic> getSpotDetailedSummary(String locationName) {
    if (locationName.contains('마라') || locationName.contains('홍대')) {
      return {
        'spotName': '서교동 마라토끼',
        'summary': '홍대입구역 9번 출구 도보 3분 거리의 인기 맛집입니다.',
        'parkingTip': '인근 서교프라자 민영주차장 도보 2분 (유료)',
        'popularMenu': '진한 사골 육수 마라탕 & 바삭 쫄깃 꿔바로우',
        'vibe': '활기차고 캐주얼한 분위기',
        'tags': ['#홍대맛집', '#마라탕성지', '#웨이팅맛집'],
      };
    }
    if (locationName.contains('카페') || locationName.contains('성수')) {
      return {
        'spotName': '성수동 감성 아틀리에 카페',
        'summary': '성수역 3번 출구 카페거리 중심에 위치한 조용한 공간입니다.',
        'parkingTip': '성수2가1동 공영주차장 도보 5분',
        'popularMenu': '쫀득 버터바 & 피스타치오 크림 라떼',
        'vibe': '대화 나누기 좋은 조용한 테라스 좌석',
        'tags': ['#성수카페', '#감성공간', '#디저트맛집'],
      };
    }
    if (locationName.contains('와인') || locationName.contains('연남')) {
      return {
        'spotName': '연남동 내추럴 와인바',
        'summary': '홍대입구역 3번 출구 연남 미로길의 아늑한 와인바입니다.',
        'parkingTip': '연남동 공영주차장 이용 권장 (주차공간 협소)',
        'popularMenu': '부담 없는 글라스 와인 & 생치즈 플래터 페어링',
        'vibe': '은은한 조명으로 첫 만남 대화 몰입도 최상',
        'tags': ['#연남와인', '#분위기맛집', '#데이트스팟'],
      };
    }
    return {
      'spotName': locationName,
      'summary': '$locationName 인근의 참여자 추천 인기 장소입니다.',
      'parkingTip': '지하철역 및 대중교통 도보 이용 편리',
      'popularMenu': '시그니처 대표 메뉴 및 계절 음료',
      'vibe': '소모임 및 대화에 적합한 쾌적한 공간',
      'tags': ['#추천스팟', '#동네모임', '#소소플레이스'],
    };
  }

  /// [OOMU P3] 장소/맛집 1분 핵심 요약 브리핑 정보 생성
  String getSpotQuickSummary(String locationName) {
    if (locationName.contains('마라') || locationName.contains('홍대')) {
      return '📍 [AI 스팟 1분 요약] 서교동 마라토끼\n'
          '• 위치: 홍대입구역 9번 출구 도보 3분\n'
          '• 대표 메뉴: 진한 사골 육수 마라탕 & 바삭 쫄깃 꿔바로우\n'
          '• 추천 꿀팁: 2단계 보통맛이 신라면 맵기! 저녁 6시 웨이팅 약 15분 예상.';
    }
    if (locationName.contains('카페') || locationName.contains('성수')) {
      return '📍 [AI 스팟 1분 요약] 성수동 감성 카페\n'
          '• 위치: 성수역 3번 출구 카페거리\n'
          '• 시그니처: 쫀득 버터바 & 피스타치오 크림 라떼\n'
          '• 분위기: 대화 나누기 좋은 조용한 테라스 좌석 구비.';
    }
    if (locationName.contains('와인') || locationName.contains('연남')) {
      return '📍 [AI 스팟 1분 요약] 연남동 내추럴 와인바\n'
          '• 위치: 홍대입구역 3번 출구 연남 미로길\n'
          '• 특징: 부담 없는 글라스 와인과 치즈 플래터 페어링\n'
          '• 꿀팁: 은은한 조명으로 첫 만남 대화 몰입도 최상!';
    }
    return '📍 [AI 스팟 1분 요약] $locationName\n'
        '• 교통: 지하철역 인근 도보 이동 편리\n'
        '• 분위기: 모임 및 대화에 적합한 쾌적한 공간\n'
        '• 추천: 참여자 취향에 맞춘 인기 메뉴 구비.';
  }
}

final oomuAi = OomuAiService();

