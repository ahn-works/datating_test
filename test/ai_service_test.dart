import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:spot10_app/services/ai_service.dart';
import 'package:spot10_app/features/matching/match_controller.dart';

void main() {
  group('🤖 OOMU 로컬 Claude 가상 API 서버(g4f) 연동 테스트', () {
    test('1. 기본 설정값(Base URL, 모델명 claude-3-haiku, 더미 키 pk-dummy) 검증', () {
      final ai = OomuAiService();
      expect(ai.baseUrl, 'http://127.0.0.1:1337/v1');
      expect(ai.chatCompletionsUrl, 'http://127.0.0.1:1337/v1/chat/completions');
      expect(ai.model, 'claude-3-haiku');
      expect(OomuAiService.sonnetModel, 'claude-3-sonnet');
      expect(ai.apiKey, 'pk-dummy');
    });

    test('2. OpenAI 호환 요청 포맷 및 응답 파싱 검증 (claude-3-haiku)', () async {
      final ai = OomuAiService();
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), 'http://127.0.0.1:1337/v1/chat/completions');
        expect(request.headers['Authorization'], 'Bearer pk-dummy');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['model'], 'claude-3-haiku');

        return http.Response.bytes(
          utf8.encode(jsonEncode({
            'id': 'chatcmpl-test',
            'object': 'chat.completion',
            'model': 'claude-3-haiku',
            'choices': [
              {
                'index': 0,
                'message': {
                  'role': 'assistant',
                  'content': '안녕하세요! 성수동 카페 투어 모임에 오신 것을 환영합니다 ☕',
                },
                'finish_reason': 'stop',
              }
            ],
          })),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final reply = await ai.generateIcebreakerQuestion(
        meetingTitle: '성수동 주말 카페 투어',
        memberTags: ['#커피', '#디저트'],
        httpClient: mockClient,
      );

      expect(reply, contains('환영합니다'));
    });

    test('3. MatchController 온보딩 태그 추출 및 폴백 방어 로직 검증', () async {
      final controller = MatchController();
      final fallbackTags = await controller.analyzeBioTags('');
      expect(fallbackTags, isNotEmpty);
      expect(fallbackTags.first, startsWith('#'));
    });
  });
}
