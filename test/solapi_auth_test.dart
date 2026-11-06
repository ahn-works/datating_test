import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Solapi HMAC-SHA256 signature generation test', () {
    const apiSecret = 'dummy_secret_for_unit_test';
    const apiKey = 'dummy_key_for_unit_test';
    final dateStr = DateTime.now().toUtc().toIso8601String();
    final salt = Random().nextInt(1000000).toString();
    
    final hmacSha256 = Hmac(sha256, utf8.encode(apiSecret));
    final digest = hmacSha256.convert(utf8.encode(dateStr + salt));
    final signature = digest.toString();
    
    final authHeader = 'HMAC-SHA256 apiKey=$apiKey, date=$dateStr, salt=$salt, signature=$signature';
    expect(authHeader, contains('HMAC-SHA256 apiKey=dummy_key_for_unit_test'));
    expect(signature.length, equals(64));
  });
}
