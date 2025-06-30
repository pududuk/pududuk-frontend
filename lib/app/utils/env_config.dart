import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // API Configuration
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.example.com';
  static String get apiVersion => dotenv.env['API_VERSION'] ?? 'v1';

  // App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'Pududuk';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';

  // Database Configuration
  static String get dbHost => dotenv.env['DB_HOST'] ?? 'localhost';
  static int get dbPort =>
      int.tryParse(dotenv.env['DB_PORT'] ?? '5432') ?? 5432;
  static String get dbName => dotenv.env['DB_NAME'] ?? 'pududuk_db';

  // Feature Flags
  static bool get enableDebugMode => dotenv.env['ENABLE_DEBUG_MODE'] == 'true';
  static bool get enableAnalytics => dotenv.env['ENABLE_ANALYTICS'] == 'true';

  // External Services
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  // 환경 변수 초기화
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  // 환경 변수 값 가져오기 (기본값 없이)
  static String? getEnv(String key) => dotenv.env[key];

  // 환경 변수 값 가져오기 (기본값과 함께)
  static String getEnvOrDefault(String key, String defaultValue) =>
      dotenv.env[key] ?? defaultValue;

  // 모든 환경 변수 출력 (디버그용)
  static void printAllEnv() {
    if (enableDebugMode) {
      print('=== Environment Variables ===');
      print('API Base URL: $apiBaseUrl');
      print('API Version: $apiVersion');
      print('App Name: $appName');
      print('App Version: $appVersion');
      print('DB Host: $dbHost');
      print('DB Port: $dbPort');
      print('DB Name: $dbName');
      print('Debug Mode: $enableDebugMode');
      print('Analytics: $enableAnalytics');
      print(
        'Google Maps API Key: ${googleMapsApiKey.isNotEmpty ? "Set" : "Not Set"}',
      );
      print(
        'Firebase Project ID: ${firebaseProjectId.isNotEmpty ? "Set" : "Not Set"}',
      );
      print('============================');
    }
  }
}
