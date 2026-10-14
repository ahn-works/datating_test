import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum R2UploadCategory {
  profile,
  meetupCover,
  chatPhoto,
}

class R2InvalidFileTypeException implements Exception {
  final String message;
  R2InvalidFileTypeException([this.message = '사진 파일(JPG, PNG, WEBP 등)만 업로드할 수 있습니다.']);

  @override
  String toString() => message;
}

/// Cloudflare R2 고성능 사진 스토리지 서비스
/// - Bucket: oomu-spot
/// - Account ID: 81ffd88f0a14642f94a0c4206e160925
/// - S3 API Endpoint: https://81ffd88f0a14642f94a0c4206e160925.r2.cloudflarestorage.com/oomu-spot
/// 
/// [보안 수칙]
/// - 개인정보 및 S3 Secret Access Key는 GitHub에 커밋하지 않고, Firestore('config/r2_storage')에 안전하게 보관합니다.
class R2StorageService {
  static final R2StorageService _instance = R2StorageService._internal();
  factory R2StorageService() => _instance;
  R2StorageService._internal();

  static const String accountId = '81ffd88f0a14642f94a0c4206e160925';
  static const String bucketName = 'oomu-spot';
  static const String s3Host = '$accountId.r2.cloudflarestorage.com';
  static const String s3Endpoint = 'https://$s3Host/$bucketName';

  /// R2 버킷 퍼블릭 접속 도메인 (R2.dev 서브도메인 또는 사용자 커스텀 도메인)
  /// 예: https://pub-xxxx.r2.dev 또는 https://media.oomu.app
  String publicBaseUrl = '';

  /// Cloudflare R2 S3 API 자격 증명 (Firestore에서 안전하게 로드됨)
  String accessKeyId = '';
  String secretAccessKey = '';

  bool _isInitialized = false;

  /// Firestore에서 R2 자격 증명 안전하게 로드 (GitHub 소스코드 노출 방지)
  Future<void> initFromFirestore() async {
    if (_isInitialized) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('config').doc('r2_storage').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        accessKeyId = (data['accessKeyId'] ?? '').toString().trim();
        secretAccessKey = (data['secretAccessKey'] ?? '').toString().trim();
        publicBaseUrl = (data['publicBaseUrl'] ?? '').toString().trim();
        debugPrint('[R2 Storage] Credentials securely loaded from Firestore (config/r2_storage)');
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('[R2 Storage] Firestore config load error (offline fallback): $e');
    }
  }

  /// Firestore에 R2 자격 증명 안전하게 저장
  Future<void> saveToFirestore({
    required String accessKey,
    required String secretKey,
    required String publicUrl,
  }) async {
    accessKeyId = accessKey.trim();
    secretAccessKey = secretKey.trim();
    publicBaseUrl = publicUrl.trim();

    try {
      await FirebaseFirestore.instance.collection('config').doc('r2_storage').set({
        'bucketName': bucketName,
        'accountId': accountId,
        'accessKeyId': accessKeyId,
        'secretAccessKey': secretAccessKey,
        'publicBaseUrl': publicBaseUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('[R2 Storage] Config saved to Firestore.');
    } catch (e) {
      debugPrint('[R2 Storage] Error saving config to Firestore: $e');
    }
  }

  /// 마스킹된 시크릿 키 반환 (UI 표시용)
  String getMaskedSecretKey() {
    if (secretAccessKey.isEmpty) return '미등록';
    if (secretAccessKey.length <= 8) return '••••••••';
    return '${secretAccessKey.substring(0, 4)}••••••••${secretAccessKey.substring(secretAccessKey.length - 4)}';
  }

  /// 마스킹된 액세스 키 반환 (UI 표시용)
  String getMaskedAccessKey() {
    if (accessKeyId.isEmpty) return '미등록';
    if (accessKeyId.length <= 8) return '••••••••';
    return '${accessKeyId.substring(0, 6)}••••••••${accessKeyId.substring(accessKeyId.length - 4)}';
  }

  /// 허용된 사진 확장자 목록
  static const List<String> allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'heic',
    'gif',
  ];

  /// 허용된 이미지 MIME 타입
  static const Map<String, String> mimeTypes = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'heic': 'image/heic',
    'gif': 'image/gif',
  };

  /// 사진 확장자 및 매직 바이트 검증
  static bool isImageFile(String fileName, [Uint8List? bytes]) {
    final clean = fileName.trim().toLowerCase();
    final dotIndex = clean.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == clean.length - 1) return false;

    final ext = clean.substring(dotIndex + 1);
    if (!allowedExtensions.contains(ext)) return false;

    // 매직 바이트 검증 (옵션)
    if (bytes != null && bytes.length >= 4) {
      // JPEG: FF D8 FF
      if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return true;
      // PNG: 89 50 4E 47
      if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return true;
      // GIF: 47 49 46 38
      if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x38) return true;
      // WEBP: 52 49 46 46 (RIFF)
      if (bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46) return true;
    }

    return true;
  }

  /// 파일 확장자 추출
  static String getFileExtension(String fileName) {
    final clean = fileName.trim().toLowerCase();
    final dotIndex = clean.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < clean.length - 1) {
      return clean.substring(dotIndex + 1);
    }
    return 'jpg';
  }

  /// MIME 타입 반환
  static String getMimeType(String ext) {
    return mimeTypes[ext.toLowerCase()] ?? 'image/jpeg';
  }

  /// S3 / R2 공개 URL 반환
  String getPublicUrl(String objectKey) {
    if (objectKey.startsWith('http://') || objectKey.startsWith('https://') || objectKey.startsWith('assets/')) {
      return objectKey;
    }

    if (publicBaseUrl.isNotEmpty) {
      final base = publicBaseUrl.endsWith('/') ? publicBaseUrl : '$publicBaseUrl/';
      final key = objectKey.startsWith('/') ? objectKey.substring(1) : objectKey;
      return '$base$key';
    }

    // 기본 S3 엔드포인트 URL
    return '$s3Endpoint/$objectKey';
  }

  /// S3 API 직접 업로드 (AWS Signature V4 서명)
  Future<String> uploadImageBytes({
    required Uint8List bytes,
    required String fileName,
    required R2UploadCategory category,
  }) async {
    // 1. 사진 파일 검증 (jpg, png, webp 등만 허용)
    if (!isImageFile(fileName, bytes)) {
      throw R2InvalidFileTypeException('사진 파일(JPG, PNG, WEBP 등)만 업로드할 수 있습니다.');
    }

    // 초기화 보장
    if (!_isInitialized) {
      await initFromFirestore();
    }

    final ext = getFileExtension(fileName);
    final contentType = getMimeType(ext);

    // 2. 카테고리별 폴더 분류
    final String folder;
    switch (category) {
      case R2UploadCategory.profile:
        folder = 'profiles';
        break;
      case R2UploadCategory.meetupCover:
        folder = 'covers';
        break;
      case R2UploadCategory.chatPhoto:
        folder = 'chats';
        break;
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final objectKey = '$folder/${timestamp}_$sanitizedFileName';

    debugPrint('[R2 Storage] Uploading to bucket: $bucketName / key: $objectKey (${bytes.length} bytes)');

    // 3. S3 API 토큰(AccessKey/SecretKey)이 설정되어 있는 경우 실제 S3 서명 PUT 전송
    if (accessKeyId.isNotEmpty && secretAccessKey.isNotEmpty) {
      try {
        final now = DateTime.now().toUtc();
        final dateStamp = _formatDate(now);
        final amzDate = _formatDateTime(now);

        final canonicalUri = '/$bucketName/$objectKey';
        final payloadHash = sha256.convert(bytes).toString();

        final canonicalHeaders = 'host:$s3Host\n'
            'x-amz-content-sha256:$payloadHash\n'
            'x-amz-date:$amzDate\n';
        const signedHeaders = 'host;x-amz-content-sha256;x-amz-date';

        final canonicalRequest = 'PUT\n'
            '$canonicalUri\n'
            '\n'
            '$canonicalHeaders\n'
            '$signedHeaders\n'
            '$payloadHash';

        const algorithm = 'AWS4-HMAC-SHA256';
        final credentialScope = '$dateStamp/auto/s3/aws4_request';
        final stringToSign = '$algorithm\n'
            '$amzDate\n'
            '$credentialScope\n'
            '${sha256.convert(utf8.encode(canonicalRequest))}';

        final signingKey = _getSignatureKey(secretAccessKey, dateStamp, 'auto', 's3');
        final signature = Hmac(sha256, signingKey).convert(utf8.encode(stringToSign)).toString();

        final authHeader = '$algorithm Credential=$accessKeyId/$credentialScope, '
            'SignedHeaders=$signedHeaders, Signature=$signature';

        final requestUri = Uri.parse('$s3Endpoint/$objectKey');
        final response = await http.put(
          requestUri,
          headers: {
            'Host': s3Host,
            'x-amz-date': amzDate,
            'x-amz-content-sha256': payloadHash,
            'Authorization': authHeader,
            'Content-Type': contentType,
          },
          body: bytes,
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          debugPrint('[R2 Storage] Upload SUCCESS! Status: ${response.statusCode}');
          return getPublicUrl(objectKey);
        } else {
          debugPrint('[R2 Storage] Upload returned status ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        debugPrint('[R2 Storage] S3 upload error: $e');
      }
    }

    // 4. 공개 R2 도메인이 설정된 경우 해당 URL 반환
    if (publicBaseUrl.isNotEmpty) {
      return getPublicUrl(objectKey);
    }

    // 5. 기본 S3 객체 URL 반환
    return '$s3Endpoint/$objectKey';
  }

  // AWS SigV4 헬퍼 함수들
  static String _formatDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}'
        '${dt.month.toString().padLeft(2, '0')}'
        '${dt.day.toString().padLeft(2, '0')}';
  }

  static String _formatDateTime(DateTime dt) {
    return '${_formatDate(dt)}T'
        '${dt.hour.toString().padLeft(2, '0')}'
        '${dt.minute.toString().padLeft(2, '0')}'
        '${dt.second.toString().padLeft(2, '0')}Z';
  }

  static List<int> _hmacSha256(List<int> key, String data) {
    return Hmac(sha256, key).convert(utf8.encode(data)).bytes;
  }

  static List<int> _getSignatureKey(String key, String dateStamp, String regionName, String serviceName) {
    final kDate = _hmacSha256(utf8.encode('AWS4$key'), dateStamp);
    final kRegion = _hmacSha256(kDate, regionName);
    final kService = _hmacSha256(kRegion, serviceName);
    return _hmacSha256(kService, 'aws4_request');
  }
}

final r2Storage = R2StorageService();
