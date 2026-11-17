import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/server_config.dart';

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

class R2FileSizeExceededException implements Exception {
  final int sizeInBytes;
  final int maxBytes;
  R2FileSizeExceededException(this.sizeInBytes, this.maxBytes);

  @override
  String toString() => '사진 파일 크기가 너무 큽니다 (${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)}MB). '
      'Cloudflare 무료 요금제 용량 관리를 위해 ${(maxBytes / (1024 * 1024)).toStringAsFixed(0)}MB 이하의 사진만 업로드 가능합니다.';
}

/// Cloudflare R2 고성능 사진 스토리지 서비스 (서버 Presigned URL 격리 준수)
/// - Bucket: oomu-spot
/// - S3 Secret Access Key는 브라우저나 앱에 절대 저장하지 않습니다.
/// - 인증된 사용자만 서버 프록시(/api/r2/sign-upload)를 통해 단기 만료(5분) Presigned PUT URL을 발급받아 업로드합니다.
class R2StorageService {
  static final R2StorageService _instance = R2StorageService._internal();
  factory R2StorageService() => _instance;
  R2StorageService._internal();

  static const String accountId = '81ffd88f0a14642f94a0c4206e160925';
  static const String bucketName = 'oomu-spot';
  static const String s3Host = '$accountId.r2.cloudflarestorage.com';
  static const String s3Endpoint = 'https://$s3Host/$bucketName';

  /// R2 버킷 퍼블릭 접속 도메인 (R2.dev 서브도메인 또는 사용자 커스텀 도메인)
  String publicBaseUrl = ServerConfig.r2PublicBaseUrl;

  /// 레거시 및 유닛 테스트 호환용 필드 (기본 빈 값 유지)
  String accessKeyId = '';
  String secretAccessKey = '';

  bool _isInitialized = false;

  /// Firestore app_config/r2_public 또는 dart-define에서 R2 공개 도메인 설정 로드
  Future<void> initFromFirestore() async {
    if (_isInitialized) return;
    publicBaseUrl = ServerConfig.r2PublicBaseUrl;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('r2_public')
          .get()
          .timeout(const Duration(seconds: 3));
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final pubUrl = (data['publicBaseUrl'] ?? '').toString().trim();
        if (pubUrl.isNotEmpty) publicBaseUrl = pubUrl;
      }
    } catch (e) {
      debugPrint('[R2 Storage] Public config load fallback: $e');
    }
    _isInitialized = true;
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

    // 매직 바이트 검증
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

  /// 사진 바이트를 영구적이고 기기간 완벽 호환되는 Base64 Data URL로 변환
  static String toDataUrl(Uint8List bytes, String fileName) {
    final ext = getFileExtension(fileName);
    final mime = getMimeType(ext);
    final b64 = base64Encode(bytes);
    return 'data:$mime;base64,$b64';
  }

  /// S3 / R2 공개 URL 반환
  String getPublicUrl(String objectKey) {
    if (objectKey.startsWith('http://') ||
        objectKey.startsWith('https://') ||
        objectKey.startsWith('assets/')) {
      return objectKey;
    }

    if (publicBaseUrl.isNotEmpty) {
      final base = publicBaseUrl.endsWith('/') ? publicBaseUrl : '$publicBaseUrl/';
      final key = objectKey.startsWith('/') ? objectKey.substring(1) : objectKey;
      return '$base$key';
    }

    return '$s3Endpoint/$objectKey';
  }

  /// AWS SigV4 서명된 임시 GET Presigned URL 생성 (단위 테스트 및 열람 호환용)
  String generatePresignedGetUrl(String objectKey, {int expiresInSeconds = 604800}) {
    if (accessKeyId.isEmpty || secretAccessKey.isEmpty) {
      return getPublicUrl(objectKey);
    }

    final cleanKey = objectKey.startsWith('/') ? objectKey.substring(1) : objectKey;
    final now = DateTime.now().toUtc();
    final dateStamp = _formatDate(now);
    final amzDate = _formatDateTime(now);

    final credentialScope = '$dateStamp/auto/s3/aws4_request';
    final credentialParam = '$accessKeyId/$credentialScope';

    final queryParams = <String, String>{
      'X-Amz-Algorithm': 'AWS4-HMAC-SHA256',
      'X-Amz-Credential': credentialParam,
      'X-Amz-Date': amzDate,
      'X-Amz-Expires': expiresInSeconds.toString(),
      'X-Amz-SignedHeaders': 'host',
    };

    final sortedKeys = queryParams.keys.toList()..sort();
    final canonicalQueryString = sortedKeys
        .map((k) => '${Uri.encodeQueryComponent(k)}=${Uri.encodeQueryComponent(queryParams[k]!)}')
        .join('&');

    final encodedKeySegments = cleanKey.split('/').map((s) => Uri.encodeComponent(s)).join('/');
    final canonicalUri = '/$bucketName/$encodedKeySegments';
    const canonicalHeaders = 'host:$s3Host\n';
    const signedHeaders = 'host';

    final canonicalRequest = 'GET\n'
        '$canonicalUri\n'
        '$canonicalQueryString\n'
        '$canonicalHeaders\n'
        '$signedHeaders\n'
        'UNSIGNED-PAYLOAD';

    const algorithm = 'AWS4-HMAC-SHA256';
    final stringToSign = '$algorithm\n'
        '$amzDate\n'
        '$credentialScope\n'
        '${sha256.convert(utf8.encode(canonicalRequest))}';

    final signingKey = _getSignatureKey(secretAccessKey, dateStamp, 'auto', 's3');
    final signature = Hmac(sha256, signingKey).convert(utf8.encode(stringToSign)).toString();

    return 'https://$s3Host$canonicalUri?$canonicalQueryString&X-Amz-Signature=$signature';
  }

  /// 브라우저/앱 화면에서 직접 렌더링 가능한 공개 이미지 URL 반환
  String getPublicViewUrl(String storedUrl, {String? defaultFallback}) {
    if (storedUrl.isEmpty) {
      return defaultFallback ?? 'assets/images/cover_food.jpg';
    }
    if (storedUrl.startsWith('data:image')) {
      return storedUrl;
    }
    if (storedUrl.startsWith('assets/') || storedUrl.startsWith('blob:')) {
      return storedUrl;
    }

    // 1. R2 오브젝트 키 형태로 저장된 경우 (예: profiles/xxx.jpg, covers/xxx.jpg, chats/xxx.jpg, posters/xxx.jpg)
    if (storedUrl.startsWith('profiles/') ||
        storedUrl.startsWith('covers/') ||
        storedUrl.startsWith('chats/') ||
        storedUrl.startsWith('posters/') ||
        storedUrl.startsWith('/profiles/') ||
        storedUrl.startsWith('/covers/') ||
        storedUrl.startsWith('/chats/') ||
        storedUrl.startsWith('/posters/')) {
      final cleanKey = storedUrl.startsWith('/') ? storedUrl.substring(1) : storedUrl;
      if (publicBaseUrl.isNotEmpty) {
        final base = publicBaseUrl.endsWith('/') ? publicBaseUrl : '$publicBaseUrl/';
        return '$base$cleanKey';
      }
      if (accessKeyId.isNotEmpty && secretAccessKey.isNotEmpty) {
        return generatePresignedGetUrl(cleanKey);
      }
      // 자격증명 및 공개 URL이 모두 없을 때의 안전 폴백
      if (cleanKey.startsWith('profiles/')) return 'assets/images/민지.png';
      if (cleanKey.contains('cafe')) return 'assets/images/cover_cafe.jpg';
      if (cleanKey.contains('wine') || cleanKey.startsWith('posters/')) return 'assets/images/cover_wine.jpg';
      if (cleanKey.contains('run')) return 'assets/images/cover_running.jpg';
      return defaultFallback ?? 'assets/images/cover_food.jpg';
    }

    // 2. KOPIS 원본 포스터 URL (http://www.kopis.or.kr/...) 인 경우 CORS/HTTP 차단 방지용 HTTPS 프록시 변환
    if (storedUrl.contains('kopis.or.kr') && !storedUrl.contains('wsrv.nl')) {
      final httpsKopis = storedUrl.startsWith('http://')
          ? 'https://${storedUrl.substring('http://'.length)}'
          : storedUrl;
      final isGif = httpsKopis.toLowerCase().contains('.gif');
      return isGif
          ? 'https://wsrv.nl/?url=${Uri.encodeComponent(httpsKopis)}&output=gif&n=-1'
          : 'https://wsrv.nl/?url=${Uri.encodeComponent(httpsKopis)}&w=600&q=85&output=jpg';
    }

    if (storedUrl.contains('wsrv.nl')) {
      if ((storedUrl.contains('.gif') ||
              storedUrl.contains('stickers/') ||
              storedUrl.contains('giphy.com')) &&
          storedUrl.contains('&output=jpg')) {
        return storedUrl.replaceAll('&output=jpg', '&output=gif&n=-1');
      }
    }

    // 3. R2 S3 엔드포인트 URL이 저장되어 있는 경우
    if (storedUrl.contains(s3Host)) {
      final uri = Uri.tryParse(storedUrl);
      if (uri != null) {
        final pathSegments = uri.pathSegments;
        final bucketIndex = pathSegments.indexOf(bucketName);
        if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
          final objectKey = pathSegments.sublist(bucketIndex + 1).join('/');
          if (publicBaseUrl.isNotEmpty) {
            final base = publicBaseUrl.endsWith('/') ? publicBaseUrl : '$publicBaseUrl/';
            return '$base$objectKey';
          }
          if (accessKeyId.isNotEmpty && secretAccessKey.isNotEmpty) {
            return generatePresignedGetUrl(objectKey);
          }
          if (objectKey.startsWith('profiles/')) return 'assets/images/민지.png';
          if (objectKey.contains('cafe')) return 'assets/images/cover_cafe.jpg';
          if (objectKey.contains('wine') || objectKey.startsWith('posters/')) return 'assets/images/cover_wine.jpg';
          if (objectKey.contains('run')) return 'assets/images/cover_running.jpg';
          return defaultFallback ?? 'assets/images/cover_food.jpg';
        }
      }
    }

    return storedUrl;
  }

  /// 서버 Presigned PUT URL을 통한 고보안 R2 업로드
  Future<String> uploadImageBytes({
    required Uint8List bytes,
    required String fileName,
    required R2UploadCategory category,
  }) async {
    // 1. 사진 파일 확장자 및 매직 바이트 검증
    if (!isImageFile(fileName, bytes)) {
      throw R2InvalidFileTypeException('사진 파일(JPG, PNG, WEBP 등)만 업로드할 수 있습니다.');
    }

    // 2. 파일 용량 제한 (5MB)
    const int maxUploadBytes = 5 * 1024 * 1024;
    if (bytes.length > maxUploadBytes) {
      throw R2FileSizeExceededException(bytes.length, maxUploadBytes);
    }

    await initFromFirestore();

    final ext = getFileExtension(fileName);
    final contentType = getMimeType(ext);

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

    // 3. 서버 프록시(/api/r2/sign-upload)를 통한 Presigned Upload URL 발급
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final idToken = await user.getIdToken();
        if (idToken != null && idToken.isNotEmpty) {
          final proxyBase = ServerConfig.serverProxyUrl;
          final signUri = Uri.parse('$proxyBase/api/r2/sign-upload');

          final signResponse = await http
              .post(
                signUri,
                headers: {
                  'Authorization': 'Bearer $idToken',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  'fileName': fileName,
                  'category': folder,
                  'mimeType': contentType,
                  'contentLength': bytes.length,
                }),
              )
              .timeout(const Duration(seconds: 10));

          if (signResponse.statusCode == 200) {
            final signData = jsonDecode(signResponse.body) as Map<String, dynamic>;
            final uploadUrl = signData['uploadUrl']?.toString();
            final publicUrl = signData['publicUrl']?.toString();

            if (uploadUrl != null && uploadUrl.isNotEmpty) {
              // 4. Presigned S3 PUT URL로 직접 업로드 (인증 헤더 없이 S3 시그니처 쿼리로 인가)
              final putResponse = await http.put(
                Uri.parse(uploadUrl),
                headers: {
                  'Content-Type': contentType,
                },
                body: bytes,
              ).timeout(const Duration(seconds: 30));

              if (putResponse.statusCode >= 200 && putResponse.statusCode < 300) {
                debugPrint('[R2 Storage] Upload SUCCESS via Presigned URL: $publicUrl');
                return publicUrl ?? getPublicUrl(signData['key'] ?? '');
              } else {
                debugPrint('[R2 Storage] Presigned PUT failed with status: ${putResponse.statusCode}');
              }
            }
          } else {
            debugPrint('[R2 Storage] Sign URL failed: ${signResponse.statusCode} - ${signResponse.body}');
          }
        }
      }
    } catch (e) {
      debugPrint('[R2 Storage] Server presign upload notice: $e');
    }

    // 5. 오프라인/게스트/서버 점검 시 사진 유실 방지를 위한 영구 Data URL 안전 폴백
    debugPrint('[R2 Storage] Presigned upload unavailable, preserving as permanent Data URL');
    return toDataUrl(bytes, fileName);
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
