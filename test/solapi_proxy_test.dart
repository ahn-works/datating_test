import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:oomu_app/services/solapi_sms_service.dart';
import 'package:oomu_app/utils/server_config.dart';

void main() {
  // Synthetic number used only with MockClient; no SMS is sent.
  final phone = '010${List.filled(8, '0').join()}';
  test('send uses only server proxy with normalized phone', () async {
    final service = SolapiSmsService.withClient(MockClient((request) async {
      expect(request.url.toString(),
          '${ServerConfig.serverProxyUrl}/api/sms/send');
      expect(jsonDecode(request.body), {'phone': phone});
      expect(request.headers.containsKey('Authorization'), isFalse);
      return http.Response('{"success":true}', 200);
    }));
    expect(
        (await service.sendVerificationCode('+82${phone.substring(1)}'))
            .isSuccess,
        isTrue);
  });

  test('old success cannot bypass server verification on subsequent code',
      () async {
    var calls = 0;
    final service = SolapiSmsService.withClient(MockClient((_) async {
      calls++;
      return calls == 1
          ? http.Response('{"success":true,"verified":true}', 200)
          : http.Response('{"success":false,"verified":false}', 400);
    }));
    expect(
        await service.verifyCode(rawPhone: phone, inputCode: '654321'), isTrue);
    expect(await service.verifyCode(rawPhone: phone, inputCode: '000000'),
        isFalse);
    expect(calls, 2);
  });

  test('invalid phone and nonnumeric OTP never reach network', () async {
    final service = SolapiSmsService.withClient(MockClient((_) async {
      fail('Invalid input must not reach server');
    }));
    expect((await service.sendVerificationCode(phone.substring(1))).isSuccess,
        isFalse);
    expect(await service.verifyCode(rawPhone: phone, inputCode: 'abcdef'),
        isFalse);
  });

  test('error status and malformed responses never verify', () async {
    for (final response in [
      http.Response('{"success":true,"verified":true}', 503),
      http.Response('<html>Unavailable</html>', 200),
      http.Response('{"success":false,"verified":true}', 200),
    ]) {
      final service =
          SolapiSmsService.withClient(MockClient((_) async => response));
      expect(await service.verifyCode(rawPhone: phone, inputCode: '654321'),
          isFalse);
    }
  });
}
