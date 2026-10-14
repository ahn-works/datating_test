import 'package:flutter_test/flutter_test.dart';
import 'package:spot10_app/services/r2_storage_service.dart';

void main() {
  group('Cloudflare R2 Storage Service 단위 테스트', () {
    test('이미지 확장자 필터링 검증 (JPG, PNG, WEBP, HEIC, GIF 허용)', () {
      expect(R2StorageService.isImageFile('profile.jpg'), isTrue);
      expect(R2StorageService.isImageFile('photo.jpeg'), isTrue);
      expect(R2StorageService.isImageFile('image.png'), isTrue);
      expect(R2StorageService.isImageFile('banner.webp'), isTrue);
      expect(R2StorageService.isImageFile('avatar.heic'), isTrue);
      expect(R2StorageService.isImageFile('animation.gif'), isTrue);
      expect(R2StorageService.isImageFile('UPPERCASE.JPG'), isTrue);
    });

    test('비이미지 파일 차단 검증 (EXE, PDF, ZIP 등 차단)', () {
      expect(R2StorageService.isImageFile('malware.exe'), isFalse);
      expect(R2StorageService.isImageFile('document.pdf'), isFalse);
      expect(R2StorageService.isImageFile('archive.zip'), isFalse);
      expect(R2StorageService.isImageFile('script.sh'), isFalse);
      expect(R2StorageService.isImageFile('no_extension'), isFalse);
    });

    test('MIME 타입 매핑 검증', () {
      expect(R2StorageService.getMimeType('jpg'), 'image/jpeg');
      expect(R2StorageService.getMimeType('png'), 'image/png');
      expect(R2StorageService.getMimeType('webp'), 'image/webp');
      expect(R2StorageService.getMimeType('heic'), 'image/heic');
    });

    test('R2 엔드포인트 및 버킷 제원 검증', () {
      expect(R2StorageService.bucketName, 'oomu-spot');
      expect(R2StorageService.accountId, '81ffd88f0a14642f94a0c4206e160925');
      expect(
        R2StorageService.s3Endpoint,
        'https://81ffd88f0a14642f94a0c4206e160925.r2.cloudflarestorage.com/oomu-spot',
      );
    });

    test('마스킹 키 유틸리티 검증', () {
      final r2 = R2StorageService();
      r2.accessKeyId = '';
      r2.secretAccessKey = '';
      expect(r2.getMaskedAccessKey(), '미등록');
      expect(r2.getMaskedSecretKey(), '미등록');

      r2.accessKeyId = 'TEST_ACCESS_KEY_12345';
      r2.secretAccessKey = 'TEST_SECRET_KEY_SECRET_98765';
      expect(r2.getMaskedAccessKey().contains('••••••••'), isTrue);
      expect(r2.getMaskedSecretKey().contains('••••••••'), isTrue);
    });

    test('Presigned GET URL 생성 및 getPublicViewUrl 변환 검증', () {
      final r2 = R2StorageService();
      r2.accessKeyId = 'TEST_ACCESS_KEY';
      r2.secretAccessKey = 'TEST_SECRET_KEY';
      r2.publicBaseUrl = '';

      final presigned = r2.generatePresignedGetUrl('chats/sample.jpg');
      expect(presigned.contains('https://81ffd88f0a14642f94a0c4206e160925.r2.cloudflarestorage.com/oomu-spot/chats/sample.jpg'), isTrue);
      expect(presigned.contains('X-Amz-Algorithm=AWS4-HMAC-SHA256'), isTrue);
      expect(presigned.contains('X-Amz-Signature='), isTrue);

      // getPublicViewUrl 변환 테스트
      const rawS3Url = 'https://81ffd88f0a14642f94a0c4206e160925.r2.cloudflarestorage.com/oomu-spot/chats/sample.jpg';
      final viewUrl = r2.getPublicViewUrl(rawS3Url);
      expect(viewUrl.contains('X-Amz-Signature='), isTrue);

      // 퍼블릭 베이스 URL이 지정된 경우
      r2.publicBaseUrl = 'https://pub-sample.r2.dev';
      final cdnUrl = r2.getPublicViewUrl(rawS3Url);
      expect(cdnUrl, 'https://pub-sample.r2.dev/chats/sample.jpg');

      // 로컬 에셋 및 blob은 그대로 통과
      expect(r2.getPublicViewUrl('assets/images/cover.jpg'), 'assets/images/cover.jpg');
      expect(r2.getPublicViewUrl('blob:http://localhost/123'), 'blob:http://localhost/123');
    });
  });
}
