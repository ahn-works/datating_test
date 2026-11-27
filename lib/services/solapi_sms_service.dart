import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/server_config.dart';

class SolapiSendResult {
  final bool isSuccess;
  final String? verificationId;
  final String? errorMessage;
  const SolapiSendResult(
      {required this.isSuccess, this.verificationId, this.errorMessage});
  factory SolapiSendResult.success(String id) =>
      SolapiSendResult(isSuccess: true, verificationId: id);
  factory SolapiSendResult.error(String message) =>
      SolapiSendResult(isSuccess: false, errorMessage: message);
}

/// OTP generation, secrets, expiry and verification belong to the server.
/// Never cache an OTP or treat previous success as new verification proof.
class SolapiSmsService {
  static final SolapiSmsService _instance = SolapiSmsService._(http.Client());
  factory SolapiSmsService() => _instance;
  SolapiSmsService._(this._client);
  @visibleForTesting
  SolapiSmsService.withClient(http.Client client) : _client = client;
  final http.Client _client;

  String normalizePhone(String raw) {
    var clean = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.startsWith('82')) clean = '0${clean.substring(2)}';
    return clean;
  }

  Future<http.Response> _post(String path, Map<String, String> body) => _client
      .post(
        Uri.parse('${ServerConfig.serverProxyUrl}/api/sms/$path'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      )
      .timeout(const Duration(seconds: 15));

  Future<SolapiSendResult> sendVerificationCode(String rawPhone) async {
    final phone = normalizePhone(rawPhone);
    if (!RegExp(r'^010\d{8}$').hasMatch(phone)) {
      return SolapiSendResult.error('010으로 시작하는 휴대폰 번호 11자리를 입력해 주세요.');
    }
    try {
      final response = await _post('send', {'phone': phone});
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['success'] == true) {
        return SolapiSendResult.success('solapi_$phone');
      }
      if (response.statusCode == 429) {
        return SolapiSendResult.error('인증 요청이 많아요. 잠시 후 다시 시도해 주세요.');
      }
    } catch (_) {
      // Do not log phone numbers, OTPs or response bodies.
    }
    return SolapiSendResult.error('인증번호를 보내지 못했어요. 잠시 후 다시 시도해 주세요.');
  }

  Future<bool> verifyCode(
      {required String rawPhone, required String inputCode}) async {
    final phone = normalizePhone(rawPhone);
    final code = inputCode.trim();
    if (!RegExp(r'^010\d{8}$').hasMatch(phone) ||
        !RegExp(r'^\d{6}$').hasMatch(code)) {
      return false;
    }
    try {
      final response = await _post('verify', {'phone': phone, 'code': code});
      if (response.statusCode != 200) return false;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['success'] == true && data['verified'] == true;
    } catch (_) {
      return false;
    }
  }
}

final solapiSmsService = SolapiSmsService();
