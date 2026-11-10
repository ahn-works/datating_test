import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

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

/// OOMU 솔라피 (SOLAPI) SMS 발송 및 휴대폰 본인인증 전용 서비스 (Zero-Secret 준수)
/// - API Key 및 API Secret은 코드/Git에 하드코딩하지 않고 Firestore 'config/api_keys'에서 런타임 로드합니다.
/// - HMAC-SHA256 전자서명 생성 및 Solapi Messages v4 API(단문 SMS) 발송을 처리합니다.
class SolapiSmsService {
  static final SolapiSmsService _instance = SolapiSmsService._internal();
  factory SolapiSmsService() => _instance;
  SolapiSmsService._internal();

  String _apiKey = '';
  String _apiSecret = '';
  String _senderNumber = '';
  bool _isInitialized = false;

  // 인메모리 빠른 인증 세션 캐시 (cleanPhone -> {code, expiresAt})
  final Map<String, Map<String, dynamic>> _localSessionCache = {};

  /// Firestore 'config/api_keys' 문서에서 솔라피 인증키 런타임 동적 조회
  Future<bool> initialize() async {
    if (_isInitialized && _apiKey.isNotEmpty && _apiSecret.isNotEmpty) {
      return true;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('api_keys')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _apiKey = (data['solapiApiKey'] ?? '').toString().trim();
        _apiSecret = (data['solapiApiSecret'] ?? '').toString().trim();
        final sender = (data['solapiSenderNumber'] ?? '').toString().trim();
        if (sender.isNotEmpty) {
          _senderNumber = sender;
        }
        _isInitialized = true;
        debugPrint(
            '[SolapiSmsService] Solapi credentials securely loaded from Firestore (sender: $_senderNumber)');
        return _apiKey.isNotEmpty && _apiSecret.isNotEmpty;
      }
    } catch (e) {
      debugPrint('[SolapiSmsService] Failed to load config/api_keys: $e');
    }
    return false;
  }

  /// Solapi Messages v4 HMAC-SHA256 Authorization 헤더 생성
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

  /// 6자리 SMS 인증번호 발송 (Solapi API v4)
  Future<SolapiSendResult> sendVerificationCode(String rawPhone) async {
    final phone = normalizePhone(rawPhone);
    if (phone.length < 10 || phone.length > 11 || !phone.startsWith('010')) {
      return SolapiSendResult.error('010으로 시작하는 올바른 휴대폰 번호를 입력해 주세요.');
    }

    final ready = await initialize();
    if (!ready || _apiKey.isEmpty || _apiSecret.isEmpty || _senderNumber.isEmpty) {
      return SolapiSendResult.error(
          'SMS 발송 설정(Solapi 키 및 발신번호)을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.');
    }

    // 6자리 난수 인증번호 생성
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
        final Map<String, dynamic> resData = jsonDecode(response.body);
        final statusCode = resData['statusCode']?.toString();
        // 2000: 정상 접수
        if (statusCode == '2000' || resData['groupId'] != null) {
          final expiresAt = DateTime.now().add(const Duration(minutes: 5));

          // 인메모리 캐시 저장
          _localSessionCache[phone] = {
            'code': code,
            'expiresAt': expiresAt,
            'verified': false,
          };

          // Firestore 'phone_verifications/{phone}' 세션 저장
          try {
            await FirebaseFirestore.instance
                .collection('phone_verifications')
                .doc(phone)
                .set({
              'phone': phone,
              'code': code,
              'createdAt': FieldValue.serverTimestamp(),
              'expiresAt': Timestamp.fromDate(expiresAt),
              'verified': false,
              'attempts': 0,
            });
          } catch (e) {
            debugPrint('[SolapiSmsService] Firestore session save notice: $e');
          }

          debugPrint(
              '[SolapiSmsService] SMS successfully sent to $phone via Solapi!');
          return SolapiSendResult.success('solapi_$phone');
        } else {
          final msg = resData['statusMessage'] ?? '인증번호 발송 실패';
          return SolapiSendResult.error('SMS 발송 실패: $msg');
        }
      } else {
        try {
          final Map<String, dynamic> errData = jsonDecode(response.body);
          final msg = errData['errorMessage'] ?? errData['message'] ?? '';
          return SolapiSendResult.error('SMS 발송 오류 (${response.statusCode}): $msg');
        } catch (_) {
          return SolapiSendResult.error(
              'SMS 발송 서버 오류가 발생했습니다. (${response.statusCode})');
        }
      }
    } catch (e) {
      debugPrint('[SolapiSmsService] Send exception: $e');
      return SolapiSendResult.error('SMS 전송 중 네트워크 오류가 발생했습니다: $e');
    }
  }

  /// 인증번호 검증
  Future<bool> verifyCode({
    required String rawPhone,
    required String inputCode,
  }) async {
    final phone = normalizePhone(rawPhone);
    final trimmedCode = inputCode.trim();

    // 1. 인메모리 세션 우선 검증
    final local = _localSessionCache[phone];
    if (local != null) {
      final DateTime expiresAt = local['expiresAt'];
      if (DateTime.now().isBefore(expiresAt)) {
        if (local['code'] == trimmedCode) {
          local['verified'] = true;
          _markFirestoreVerified(phone);
          return true;
        }
      }
    }

    // 2. Firestore 'phone_verifications/{phone}' 검증
    try {
      final doc = await FirebaseFirestore.instance
          .collection('phone_verifications')
          .doc(phone)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final String savedCode = (data['code'] ?? '').toString().trim();
        final Timestamp? expiresTs = data['expiresAt'] as Timestamp?;
        final isExpired =
            expiresTs != null && expiresTs.toDate().isBefore(DateTime.now());

        if (!isExpired && savedCode == trimmedCode) {
          await _markFirestoreVerified(phone);
          return true;
        }
      }
    } catch (e) {
      debugPrint('[SolapiSmsService] Verify error: $e');
    }

    return false;
  }

  Future<void> _markFirestoreVerified(String phone) async {
    try {
      await FirebaseFirestore.instance
          .collection('phone_verifications')
          .doc(phone)
          .set({'verified': true, 'verifiedAt': FieldValue.serverTimestamp()},
              SetOptions(merge: true));
    } catch (_) {}
  }
}

final solapiSmsService = SolapiSmsService();

