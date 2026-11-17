/// OOMU 서버 프록시 및 백엔드 설정 관리 클래스
class ServerConfig {
  /// Firebase Functions v2 기본 엔드포인트 (Seoul 리전: asia-northeast3, 프로젝트: test-b54fc)
  static const String defaultFunctionsUrl =
      'https://asia-northeast3-test-b54fc.cloudfunctions.net/api';

  /// 서버 프록시 기본 엔드포인트 URL
  static String get serverProxyUrl {
    const envUrl = String.fromEnvironment('OOMU_SERVER_PROXY_URL');
    if (envUrl.isNotEmpty) {
      return envUrl.endsWith('/') ? envUrl.substring(0, envUrl.length - 1) : envUrl;
    }
    return defaultFunctionsUrl;
  }

  /// Cloudflare R2 퍼블릭 접속 기본 베이스 URL
  static const String defaultR2PublicBaseUrl =
      'https://pub-8d0ba75990524458bc26ba403bf6aef4.r2.dev';

  static String get r2PublicBaseUrl {
    const envUrl = String.fromEnvironment('R2_PUBLIC_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl.endsWith('/') ? envUrl.substring(0, envUrl.length - 1) : envUrl;
    }
    return defaultR2PublicBaseUrl;
  }
}
