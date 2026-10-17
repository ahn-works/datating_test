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
}

final oomuAi = OomuAiService();
