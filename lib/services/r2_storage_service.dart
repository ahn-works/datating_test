import 'package:flutter/foundation.dart';

/// Cloudflare R2 스토리지 연동 서비스
/// - 계정 ID: 81ffd88f0a14642f94a0c4206e160925
/// - 파이어베이스: 텍스트 및 메타데이터 보관
/// - 클라우드플레어 R2: 고화질 사진 및 미디어 보관
class R2StorageService {
  static final R2StorageService _instance = R2StorageService._internal();
  factory R2StorageService() => _instance;
  R2StorageService._internal();

  static const String accountId = '81ffd88f0a14642f94a0c4206e160925';
  static const String s3Endpoint = 'https://$accountId.r2.cloudflarestorage.com';

  /// R2 버킷 퍼블릭 도메인 또는 Cloudflare Worker 프록시 도메인
  /// (예: https://pub-xxxx.r2.dev 또는 https://media.yourdomain.com)
  String publicCustomDomain = '';

  /// R2 버킷명
  String bucketName = 'oomu-images';

  /// R2 URL 생성 헬퍼
  String getImageUrl(String key) {
    if (key.startsWith('http://') || key.startsWith('https://') || key.startsWith('assets/')) {
      return key;
    }
    if (publicCustomDomain.isNotEmpty) {
      final base = publicCustomDomain.endsWith('/') ? publicCustomDomain : '$publicCustomDomain/';
      return '$base$key';
    }
    return key;
  }

  /// Cloudflare R2 직접 업로드 시뮬레이션 및 URL 반환
  Future<String> uploadImageBytes({
    required List<int> bytes,
    required String fileName,
    String folder = 'profiles',
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileKey = '$folder/${timestamp}_$fileName';
    debugPrint('[R2 Storage] Uploading ${bytes.length} bytes to R2: $fileKey');
    
    // 퍼블릭 도메인이 설정되어 있으면 해당 URL 반환, 아니면 키 반환
    if (publicCustomDomain.isNotEmpty) {
      return getImageUrl(fileKey);
    }
    return 'assets/images/kr_female_1.jpg';
  }
}

final r2Storage = R2StorageService();
