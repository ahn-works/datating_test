// 유저의 인증 상태(가입 중인지, 로그인 완료인지)를 관리하는 컨트롤러

enum AuthState { initial, unauthenticated, inSignupProcess, authenticated }

class AuthController {
  AuthState _state = AuthState.initial;
  AuthState get state => _state;

  // 1. 소셜 로그인 흐름
  void loginWithSocial(String provider) {
    print('$provider 로그인 시도...');
    // TODO: 백엔드로 토큰 전송 후 회원 여부 파악
    // 신규 유저면 -> _state = AuthState.inSignupProcess; (회원가입으로 이동)
    // 기존 유저면 -> _state = AuthState.authenticated; (메인 화면으로 이동)
  }

  // 2. 회원가입 프로세스 단계별 흐름
  void verifyIdentity() {
    // PASS 본인인증 및 직장인증 로직 API 호출
  }

  void saveProfileData(Map<String, dynamic> profileData) {
    // 취향 태그, MBTI 등 DB에 저장
  }

  void completeSignup() {
    // 모든 가입 절차가 끝나면 상태를 변경하여 앱이 자동으로 메인 화면으로 넘어가게 함
    _state = AuthState.authenticated;
  }
}
