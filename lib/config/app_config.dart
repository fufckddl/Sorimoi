class AppConfig {
  static const String kakaoNativeAppKey = String.fromEnvironment(
    'SORIMOI_KAKAO_NATIVE_APP_KEY',
  );
  static const String apiBaseUrl = String.fromEnvironment(
    'SORIMOI_API_BASE_URL',
  );
  static const String scoreApiBaseUrl = String.fromEnvironment(
    'SORIMOI_SCORE_API_BASE_URL',
    defaultValue: '',
  );
  static const String websocketBaseUrl = String.fromEnvironment(
    'SORIMOI_WS_BASE_URL',
  );

  static Uri apiUri(String path) => Uri.parse(_join(apiBaseUrl, path));

  static Uri scoreUri(String path) => Uri.parse(
    _join(scoreApiBaseUrl.isNotEmpty ? scoreApiBaseUrl : apiBaseUrl, path),
  );

  static Uri websocketUri(String path) =>
      Uri.parse(_join(websocketBaseUrl, path));

  static String _join(String baseUrl, String path) {
    if (baseUrl.isEmpty) {
      throw StateError('Sorimoi base URL is not configured.');
    }

    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$normalizedBase$normalizedPath';
  }
}
