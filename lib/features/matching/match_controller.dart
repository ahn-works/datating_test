import 'package:flutter/foundation.dart';
import '../../services/ai_service.dart';

/// OOMU 모임 매칭 및 페르소나 케미 시뮬레이션 컨트롤러
/// 로컬 g4f API 서버(http://127.0.0.1:1337/v1, 모델: claude-3-haiku / claude-3-sonnet)를 활용합니다.
class MatchController extends ChangeNotifier {
  final OomuAiService _aiService;

  bool isLoading = false;
  String lastIcebreaker = '';
  List<String> extractedTags = const [];

  MatchController({OomuAiService? aiService})
      : _aiService = aiService ?? oomuAi;

  /// 모임방 입장 시 로컬 claude-3-haiku 모델을 호출하여 아이스브레이킹 질문을 생성합니다.
  Future<String> createRoomIcebreaker({
    required String meetingTitle,
    List<String> memberTags = const [],
    bool useSonnet = false,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _aiService.generateIcebreakerQuestion(
        meetingTitle: meetingTitle,
        memberTags: memberTags,
        targetModel: useSonnet
            ? OomuAiService.sonnetModel
            : OomuAiService.defaultModel,
      );
      lastIcebreaker = result;
      return result;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 온보딩 자기소개 문장에서 취향 태그를 자동 추출합니다.
  Future<List<String>> analyzeBioTags(String bioText) async {
    isLoading = true;
    notifyListeners();

    try {
      extractedTags = await _aiService.extractOnboardingTags(bioText);
      return extractedTags;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
