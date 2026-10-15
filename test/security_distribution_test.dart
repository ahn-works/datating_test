import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot10_app/services/r2_storage_service.dart';

void main() {
  group('🔒 OOMU 보안 및 3계층 분배 규칙 자동 테스트', () {
    test('1. 소스코드 내 Secret Access Key 및 민감정보 하드코딩 부재 검증', () {
      final r2 = R2StorageService();
      expect(r2.secretAccessKey, isEmpty, reason: '기본 소스코드 상의 secretAccessKey는 반드시 비어 있어야 합니다.');
      expect(r2.getMaskedSecretKey(), '미등록', reason: '키 미등록 시 UI 마스킹은 "미등록"이어야 합니다.');
    });

    test('2. 사진/미디어 확장자 화이트리스트 검증 (Cloudflare R2 전용)', () {
      // 허용 포맷
      expect(R2StorageService.isImageFile('avatar.jpg'), isTrue);
      expect(R2StorageService.isImageFile('photo.png'), isTrue);
      expect(R2StorageService.isImageFile('banner.webp'), isTrue);
      expect(R2StorageService.isImageFile('pic.heic'), isTrue);
      expect(R2StorageService.isImageFile('anim.gif'), isTrue);

      // 차단 포맷
      expect(R2StorageService.isImageFile('script.sh'), isFalse);
      expect(R2StorageService.isImageFile('malware.exe'), isFalse);
      expect(R2StorageService.isImageFile('document.pdf'), isFalse);
      expect(R2StorageService.isImageFile('secret.key'), isFalse);
    });

    test('3. AWS SigV4 Presigned GET URL 서명 및 유효기간(7일) 검증', () {
      final r2 = R2StorageService();
      r2.accessKeyId = 'TEST_KEY_ID';
      r2.secretAccessKey = 'TEST_SECRET_KEY';
      r2.publicBaseUrl = '';

      final presignedUrl = r2.generatePresignedGetUrl('covers/weekend_wine.jpg');
      expect(presignedUrl.contains('X-Amz-Algorithm=AWS4-HMAC-SHA256'), isTrue);
      expect(presignedUrl.contains('X-Amz-Credential='), isTrue);
      expect(presignedUrl.contains('X-Amz-Expires=604800'), isTrue);
      expect(presignedUrl.contains('X-Amz-Signature='), isTrue);
      expect(presignedUrl.contains('oomu-spot/covers/weekend_wine.jpg'), isTrue);
    });

    test('4. 필수 보안 규칙 파일 존재 여부 검증', () {
      final ruleFile = File('.antigravity/rules/security_distribution_rules.md');
      final guideFile = File('docs/SECURITY_AGENT_GUIDE.md');
      final instructionsFile = File('AI_INSTRUCTIONS.md');

      expect(ruleFile.existsSync(), isTrue, reason: '보안 규칙 파일(.antigravity/rules/security_distribution_rules.md)이 반드시 존재해야 합니다.');
      expect(guideFile.existsSync(), isTrue, reason: '보안 가이드 문서(docs/SECURITY_AGENT_GUIDE.md)가 반드시 존재해야 합니다.');
      expect(instructionsFile.existsSync(), isTrue, reason: 'AI 지침서(AI_INSTRUCTIONS.md)가 반드시 존재해야 합니다.');
    });
  });
}
