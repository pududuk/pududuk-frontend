import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/routes/app_pages.dart';
import 'app/utils/env_config.dart';
import 'package:pududuk_app/app/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 로드five0401
  await EnvConfig.load();

  // API 서비스 초기화  
  final apiService = Get.put(ApiService());

  // 저장된 토큰 자동 로드
  await _loadSavedToken(apiService);

  // 네이버 지도 초기화 (웹이 아닌 경우에만)
  if (!kIsWeb) {
    await FlutterNaverMap().init(clientId: EnvConfig.naverMapsClientId);
  }

  // 디버그 모드일 때 환경 변수 출력
  EnvConfig.printAllEnv();

  // 앱 시작 시 권한 요청 (웹이 아닌 경우에만)
  if (!kIsWeb) {
    await _requestPermissions();
  }

  runApp(const MyApp());
}

Future<void> _loadSavedToken(ApiService apiService) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('access_token');

    if (savedToken != null && savedToken.isNotEmpty) {
      apiService.setAuthToken(savedToken);
      print('저장된 토큰 로드 완료');
    }
  } catch (e) {
    print('토큰 로드 중 오류: $e');
  }
}

Future<void> _requestPermissions() async {
  try {
    // 사진 권한 요청 (Android 13+)
    final photosStatus = await Permission.photos.request();

    // 저장소 권한도 요청 (Android 12 이하)
    final storageStatus = await Permission.storage.request();

    if (photosStatus.isGranted || storageStatus.isGranted) {
      print('권한이 승인되었습니다.');
    } else {
      print('권한이 거부되었습니다. 이미지 저장 기능이 제한될 수 있습니다.');
    }
  } catch (e) {
    print('권한 요청 중 오류 발생: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: EnvConfig.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: EnvConfig.enableDebugMode,
    );
  }
}
