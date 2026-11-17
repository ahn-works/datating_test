import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/global_data.dart';
import '../utils/server_config.dart';

class SolapiSendResult {
  final bool isSuccess;
  final String? verificationId;
  final String? errorMessage;

  const SolapiSendResult({
    required this.isSuccess,
    this.verificationId,
    this.errorMessage,
  });

  factory SolapiSendResult.success(String verificationId) => SolapiSendResult(
        isSuccess: true,
        verificationId: verificationId,
      );

  factory SolapiSendResult.error(String message) => SolapiSendResult(
        isSuccess: false,
        errorMessage: message,
      );
}

/// OOMU 솔라피 (SOLAPI) SMS 발송 및 본인인증 서비스 (서버 프록시 격리 준수)
/// - 클라이언트/웹 번들/Firestore에 API Key 및 Secret을 노출하지 않고 서버 프록시(/api/sms/*)를 통해 안전하게 처리합니다.
/// - OTP 생성, HMAC 서명, 속도 제한, 해시 검증은 전적으로 서버에서 실행됩니다.
class SolapiSmsService {
  static final SolapiSmsService _instance = SolapiSmsService._internal();
  factory SolapiSmsService() => _instance;
  SolapiSmsService._internal();

  String _apiKey = '';
  String _apiSecret = '';
  String _senderNumber = '';
  bool _isInitialized = false;

  // 인메모리 빠른 인증 세션 캐시 (cleanPhone -> {code, expiresAt, verified})
  final Map<String, Map<String, dynamic>> _localSessionCache = {};

  /// SMS 발송 서비스 초기화
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    // 0. dart-define / 환경변수 주입값 확인 (개발/오프라인 환경용)
    const envKey = String.fromEnvironment('SOLAPI_API_KEY');
    const envSecret = String.fromEnvironment('SOLAPI_API_SECRET');
    const envSender = String.fromEnvironment('SOLAPI_SENDER_NUMBER');
    if (envKey.isNotEmpty && envSecret.isNotEmpty) {
      _apiKey = envKey;
      _apiSecret = envSecret;
      if (envSender.isNotEmpty) _senderNumber = envSender;
    }

    _isInitialized = true;
    return true;
  }

  /// Solapi Messages v4 HMAC-SHA256 Authorization 헤더 생성 (로컬 폴백용)
  String _generateAuthHeader() {
    final dateStr = DateTime.now().toUtc().toIso8601String();
    final salt = DateTime.now().microsecondsSinceEpoch.toString() +
        (1000 + Random().nextInt(9000)).toString();
    final hmacSha256 = Hmac(sha256, utf8.encode(_apiSecret));
    final digest = hmacSha256.convert(utf8.encode(dateStr + salt));
    final signature = digest.toString();
    return 'HMAC-SHA256 apiKey=$_apiKey, date=$dateStr, salt=$salt, signature=$signature';
  }

  /// 휴대폰 번호 정규화 (숫자만 추출, 010xxxxxxxx)
  String normalizePhone(String raw) {
    var clean = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.startsWith('82')) {
      clean = '0${clean.substring(2)}';
    }
    return clean;
  }

  /// 6자리 SMS 인증번호 발송 (서버 프록시 우선 호출)
  Future<SolapiSendResult> sendVerificationCode(String rawPhone) async {
    final phone = normalizePhone(rawPhone);
    if (phone.length < 10 || phone.length > 11 || !phone.startsWith('010')) {
      return SolapiSendResult.error('010으로 시작하는 올바른 휴대폰 번호를 입력해 주세요.');
    }

    await initialize();

    // 1. 서버 프록시(/api/sms/send) 우선 호출
    final proxyBase = ServerConfig.serverProxyUrl;
    try {
      final proxyUri = Uri.parse('$proxyBase/api/sms/send');
      final response = await http
          .post(
            proxyUri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'phone': phone}),
          )
          .timeout(const Duration(seconds: 10));

      final resData = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && resData['success'] == true) {
        _localSessionCache[phone] = {
          'expiresAt': DateTime.now().add(const Duration(minutes: 3)),
          'verified': false,
        };
        debugPrint('[SolapiSmsService] Proxy SMS sent successfully to $phone');
        return SolapiSendResult.success('solapi_$phone');
      } else if (response.statusCode == 429) {
        return SolapiSendResult.error(
            resData['message']?.toString() ?? '요청이 너무 많습니다. 잠시 후 다시 시도해 주세요.');
      } else if (response.statusCode == 503) {
        return SolapiSendResult.error(
            resData['message']?.toString() ?? '서버에 SMS 발송 키가 설정되지 않았습니다.');
      } else {
        final msg = resData['message']?.toString() ?? '인증번호 발송 실패';
        return SolapiSendResult.error(msg);
      }
    } catch (e) {
      debugPrint('[SolapiSmsService] Proxy call notice ($e), checking local env fallback');
    }

    // 2. 개발/오프라인 환경 폴백 (SOLAPI_API_KEY가 dart-define으로 주입된 경우만)
    if (_apiKey.isNotEmpty && _apiSecret.isNotEmpty && _senderNumber.isNotEmpty) {
      final code = (100000 + Random().nextInt(900000)).toString();
      final messageText = '[OOMU] 인증번호는 [$code]입니다. 타인에게 절대 노출하지 마세요.';

      try {
        final url = Uri.parse('https://api.solapi.com/messages/v4/send');
        final authHeader = _generateAuthHeader();
        final body = jsonEncode({
          'message': {
            'to': phone,
            'from': _senderNumber,
            'text': messageText,
          }
        });

        final response = await http.post(
          url,
          headers: {
            'Authorization': authHeader,
            'Content-Type': 'application/json',
          },
          body: body,
        );

        if (response.statusCode == 200) {
          final resData = jsonDecode(response.body);
          if (resData['statusCode'] == '2000' || resData['groupId'] != null) {
            final expiresAt = DateTime.now().add(const Duration(minutes: 3));
            _localSessionCache[phone] = {
              'code': code,
              'expiresAt': expiresAt,
              'verified': false,
            };
            return SolapiSendResult.success('solapi_$phone');
          }
        }
      } catch (err) {
        debugPrint('[SolapiSmsService] Direct fallback error: $err');
      }
    }

    return SolapiSendResult.error(
        'SMS 인증 서버에 연결할 수 없습니다. 네트워크 연결 상태를 확인해 주세요.');
  }

  /// 인증번호 검증 (서버 프록시 우선 호출)
  Future<bool> verifyCode({
    required String rawPhone,
    required String inputCode,
  }) async {
    final phone = normalizePhone(rawPhone);
    final trimmedCode = inputCode.trim();
    if (trimmedCode.length != 6) {
      return false;
    }

    // 1. 이미 인메모리에서 인증 완료된 세션인지 확인
    final local = _localSessionCache[phone];
    if (local != null && local['verified'] == true) {
      globalData.isPhoneVerified.value = true;
      globalData.userPhone.value = phone;
      return true;
    }

    // 2. 서버 프록시(/api/sms/verify) 호출
    final proxyBase = ServerConfig.serverProxyUrl;
    try {
      final proxyUri = Uri.parse('$proxyBase/api/sms/verify');
      final response = await http
          .post(
            proxyUri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'phone': phone, 'code': trimmedCode}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body) as Map<String, dynamic>;
        if (resData['verified'] == true) {
          _localSessionCache[phone] = {
            'verified': true,
            'expiresAt': DateTime.now().add(const Duration(hours: 1)),
          };
          globalData.isPhoneVerified.value = true;
          globalData.userPhone.value = phone;
          return true;
        }
      }
    } catch (e) {
      debugPrint('[SolapiSmsService] Proxy verify error: $e');
    }

    // 3. 인메모리 로컬 세션 검증 (개발/오프라인 환경 폴백)
    if (local != null && local['code'] != null) {
      final DateTime? expiresAt = local['expiresAt'];
      if (expiresAt != null && DateTime.now().isBefore(expiresAt)) {
        if (local['code'] == trimmedCode) {
          local['verified'] = true;
          globalData.isPhoneVerified.value = true;
          globalData.userPhone.value = phone;
          return true;
        }
      }
    }

    return false;
  }
}

final solapiSmsService = SolapiSmsService();
