import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/profile_policy.dart';

/// Links a verified number to the signed-in account; never signs into a second
/// phone account or merges somebody else's account based on a typed number.
class PhoneVerificationField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<bool> onVerified;
  const PhoneVerificationField(
      {super.key, required this.controller, required this.onVerified});

  @override
  State<PhoneVerificationField> createState() => _PhoneVerificationFieldState();
}

class _PhoneVerificationFieldState extends State<PhoneVerificationField> {
  final _code = TextEditingController();
  String? _verificationId;
  String? _requestedNumber;
  String? _requestUid;
  ConfirmationResult? _confirmation;
  bool _busy = false;
  String? _error;
  bool get _verified {
    if (Firebase.apps.isEmpty) return false;
    final user = FirebaseAuth.instance.currentUser;
    final number = normalizeKoreanMobile(widget.controller.text);
    return user != null && number != null && user.phoneNumber == number;
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  String _message(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'credential-already-in-use':
        case 'account-exists-with-different-credential':
          return '이미 다른 계정에 연결된 번호예요. 기존 로그인 방법으로 접속해 주세요. 계정을 자동으로 합치지 않습니다.';
        case 'provider-already-linked':
          return '이미 번호가 연결되어 있어요. 다른 번호로 변경하려면 계정 설정을 이용해 주세요.';
        case 'invalid-verification-code':
          return '인증번호가 맞지 않아요. 다시 확인해 주세요.';
        case 'session-expired':
          return '인증 시간이 지났어요. 인증번호를 다시 받아 주세요.';
        case 'too-many-requests':
          return '요청이 많아요. 잠시 후 다시 시도해 주세요.';
        case 'operation-not-allowed':
          return '현재 휴대폰 인증을 사용할 수 없어요. 잠시 후 다시 시도해 주세요.';
      }
    }
    return '인증을 완료하지 못했어요. 연결 상태를 확인하고 다시 시도해 주세요.';
  }

  Future<void> _finish(PhoneAuthCredential credential) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid != _requestUid) return;
    await user.linkWithCredential(credential);
    await user.reload();
    if (!mounted || FirebaseAuth.instance.currentUser?.uid != _requestUid) {
      return;
    }
    widget.onVerified(_verified);
    setState(() {
      _busy = false;
      _error = _verified ? null : '번호가 확인되지 않았어요. 다시 시도해 주세요.';
    });
  }

  Future<void> _send() async {
    if (_busy) return;
    if (Firebase.apps.isEmpty) {
      setState(() => _error = '이 화면은 미리보기예요. 실제 앱에서 인증해 주세요.');
      return;
    }
    final number = normalizeKoreanMobile(widget.controller.text);
    final user = FirebaseAuth.instance.currentUser;
    if (number == null || user == null) {
      setState(() => _error =
          user == null ? '로그인 후 인증해 주세요.' : '010으로 시작하는 휴대폰 번호를 확인해 주세요.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _verificationId = null;
      _confirmation = null;
      _code.clear();
    });
    _requestedNumber = number;
    _requestUid = user.uid;
    try {
      if (kIsWeb) {
        final result = await user.linkWithPhoneNumber(number);
        if (!mounted || FirebaseAuth.instance.currentUser?.uid != _requestUid) {
          return;
        }
        setState(() {
          _confirmation = result;
          _busy = false;
        });
      } else {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: number,
          verificationCompleted: (credential) async {
            try {
              await _finish(credential);
            } catch (e) {
              if (mounted) {
                setState(() {
                  _busy = false;
                  _error = _message(e);
                });
              }
            }
          },
          verificationFailed: (e) {
            if (mounted) {
              setState(() {
                _busy = false;
                _error = _message(e);
              });
            }
          },
          codeSent: (id, _) {
            if (mounted) {
              setState(() {
                _verificationId = id;
                _busy = false;
              });
            }
          },
          codeAutoRetrievalTimeout: (_) {},
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = _message(e);
        });
      }
    }
  }

  Future<void> _confirm() async {
    if (_busy) return;
    if (normalizeKoreanMobile(widget.controller.text) != _requestedNumber ||
        FirebaseAuth.instance.currentUser?.uid != _requestUid) {
      setState(() => _error = '번호나 계정이 변경됐어요. 인증번호를 다시 받아 주세요.');
      return;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(_code.text.trim())) {
      setState(() => _error = '문자로 받은 인증번호 6자리를 입력해 주세요.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (kIsWeb && _confirmation != null) {
        await _confirmation!.confirm(_code.text.trim());
        await FirebaseAuth.instance.currentUser?.reload();
        if (!mounted || FirebaseAuth.instance.currentUser?.uid != _requestUid) {
          return;
        }
        widget.onVerified(_verified);
        setState(() {
          _busy = false;
          _error = _verified ? null : '번호를 확인할 수 없어요.';
        });
      } else if (_verificationId != null) {
        await _finish(PhoneAuthProvider.credential(
            verificationId: _verificationId!, smsCode: _code.text.trim()));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = _message(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: widget.controller,
            keyboardType: TextInputType.phone,
            enabled: !_busy,
            decoration: const InputDecoration(
                labelText: '휴대폰 번호', hintText: '010-0000-0000'),
            onChanged: (_) {
              widget.onVerified(_verified);
              setState(() {
                _error = null;
              });
            },
          ),
          const SizedBox(height: 8),
          if (_verified)
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('휴대폰 번호 확인 완료'))
          else
            OutlinedButton(
                onPressed: _busy ? null : _send,
                child: Text(_busy
                    ? '확인 중…'
                    : (_confirmation != null || _verificationId != null
                        ? '인증번호 다시 받기'
                        : '인증번호 받기'))),
          if (!_verified &&
              (_confirmation != null || _verificationId != null)) ...[
            const SizedBox(height: 12),
            TextField(
                controller: _code,
                keyboardType: TextInputType.number,
                maxLength: 6,
                autofillHints: const [AutofillHints.oneTimeCode],
                decoration: const InputDecoration(labelText: '인증번호 6자리')),
            OutlinedButton(
                onPressed: _busy ? null : _confirm,
                child: const Text('인증번호 확인')),
          ],
          if (_error != null)
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        height: 1.5))),
          const SizedBox(height: 8),
          const Text('현재 로그인한 계정에 번호를 연결해요. 이미 다른 계정에 연결된 번호는 중복 연결할 수 없어요.',
              style: TextStyle(fontSize: 13, height: 1.5)),
        ],
      );
}
