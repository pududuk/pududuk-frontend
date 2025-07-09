import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';

class RecommendResultController extends GetxController {
  // ApiService 인스턴스
  final ApiService _apiService = Get.find<ApiService>();

  // 로딩 상태
  var isLoading = true.obs; // 초기값을 true로 설정

  // 오늘의 메뉴 없음 상태
  var isNoMenuToday = false.obs;

  // 1~3위 메뉴 (초기값은 빈 리스트)
  final topMenus = <Map<String, dynamic>>[].obs;

  // 4위 이후 메뉴 (topMenus에서 상위 3개를 제외한 나머지)
  RxList<Map<String, dynamic>> get otherMenus {
    if (topMenus.length <= 3) return <Map<String, dynamic>>[].obs;

    return topMenus
        .skip(3)
        .map((menu) {
          return {
            'rank': topMenus.indexOf(menu) + 1,
            'name': menu['name'],
            'menu': menu['menu'], // 메뉴명 추가
            'store': menu['store'], // 매장명 추가
            'score': menu['score'],
            'image': menu['image'],
            'latitude': menu['latitude'],
            'longitude': menu['longitude'],
            'price': menu['price'],
          };
        })
        .toList()
        .obs;
  }

  final screenshotController = ScreenshotController();

  // 검색 관련 반응형 변수
  final searchQuery = ''.obs;
  final isSearching = false.obs;

  // 필터링된 메뉴 리스트 (반응형)
  RxList<Map<String, dynamic>> get filteredMenus {
    if (searchQuery.value.isEmpty) {
      return topMenus;
    }

    final filtered =
        topMenus.where((menu) {
          final menuName = menu['name']?.toString().toLowerCase() ?? '';
          return menuName.contains(searchQuery.value.toLowerCase());
        }).toList();

    return filtered.obs;
  }

  // 필터링된 상위 3개 메뉴
  RxList<Map<String, dynamic>> get filteredTopMenus {
    final filtered = filteredMenus.take(3).toList();
    return filtered.obs;
  }

  // 필터링된 기타 메뉴 (4위 이후)
  RxList<Map<String, dynamic>> get filteredOtherMenus {
    if (filteredMenus.length <= 3) return <Map<String, dynamic>>[].obs;

    return filteredMenus.skip(3).toList().obs;
  }

  // 검색어 업데이트
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    isSearching.value = query.isNotEmpty;
  }

  // 검색 초기화
  void clearSearch() {
    searchQuery.value = '';
    isSearching.value = false;
  }

  void onRetry() {
    print('다시 추천받기 버튼 클릭 - affiliation: ${affiliation.value}');

    // 기존 데이터 즉시 초기화
    topMenus.clear();
    isLoading.value = true;
    isNoMenuToday.value = false; // 오늘의 메뉴 없음 상태도 초기화

    if (isInside) {
      // 사내 추천 - 서버에서 새로운 데이터 받아오기
      _loadIndoorRecommendations();
      Get.snackbar(
        '알림',
        '새로운 사내 추천을 받아오고 있습니다...',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      // 사외 추천 - 서버에서 새로운 데이터 받아오기
      _loadOutdoorRecommendations(showSuccessMessage: true);
      Get.snackbar(
        '알림',
        '새로운 사외 추천을 받아오고 있습니다...',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> onSave() async {
    try {
      final image = await screenshotController.capture();
      if (image == null) return;

      if (kIsWeb) {
        Get.snackbar('알림', '웹에서는 이미지 저장 기능을 지원하지 않습니다.');
        return;
      }

      // 권한 체크 (앱 시작 시 이미 요청했으므로 간단히 체크)
      final photosStatus = await Permission.photos.status;
      final storageStatus = await Permission.storage.status;

      if (!photosStatus.isGranted && !storageStatus.isGranted) {
        Get.snackbar('권한 필요', '이미지 저장을 위해 사진 권한이 필요합니다. 설정에서 권한을 허용해주세요.');
        return;
      }

      // 앱 내부 저장소에 저장 (권한 불필요)
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'pududuk_result_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(image);

      Get.snackbar('저장 완료', '이미지가 앱 내부에 저장되었습니다: $fileName');
    } catch (e) {
      Get.snackbar('오류', '이미지 저장에 실패했습니다: $e');
    }
  }

  Future<void> onShare() async {
    try {
      final image = await screenshotController.capture();
      if (image == null) return;

      if (kIsWeb) {
        Get.snackbar('알림', '웹에서는 이미지 공유 기능을 지원하지 않습니다.');
        return;
      }

      // 임시 디렉토리에 이미지 저장
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/pududuk_share_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await tempFile.writeAsBytes(image);

      // 공유
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: '푸드득의 점메추!',
        subject: '푸드득 추천 결과',
      );

      // 임시 파일 삭제
      await tempFile.delete();
    } catch (e) {
      Get.snackbar('오류', '이미지 공유에 실패했습니다: $e');
    }
  }

  Future<String?> getAffiliation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('affiliation');
  }

  // affiliation 정보 (사내/사외)
  var affiliation = 'outside'.obs;

  @override
  void onInit() {
    super.onInit();

    // 파라미터에서 affiliation 값 가져오기
    affiliation.value = Get.parameters['affiliation'] ?? 'outside';
    print(
      'RecommendResultController onInit - affiliation: ${affiliation.value}',
    );

    if (isInside) {
      // 사내 추천 데이터 로드
      _loadIndoorRecommendations();
    } else {
      // 사외 추천 데이터 로드
      _loadOutdoorRecommendations();
    }
  }

  // 사내 추천 데이터를 서버에서 가져오기
  Future<void> _loadIndoorRecommendations() async {
    try {
      isLoading.value = true;
      isNoMenuToday.value = false; // 요청 시작 시 상태 초기화

      final response = await _apiService.get('/users/indoor');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['isSuccess'] == true &&
            responseData['result'] != null) {
          final List<dynamic> indoorData = responseData['result'];

          // 서버 데이터를 topMenus 형식으로 변환
          final convertedMenus =
              indoorData.map((item) {
                return <String, dynamic>{
                  'name':
                      '${_convertStoreName(item['store'])} ${item['corner']}',
                  'score': item['score'],
                  'image': item['imgUrl'] ?? '', // 서버에서 제공하는 이미지 URL 사용
                  'menu': item['menu'],
                  'waiting_pred': item['waiting_pred'],
                  'comment': item['comment'],
                  'rank': item['rank'],
                  'store': _convertStoreName(item['store']),
                  'corner': item['corner'],
                };
              }).toList();

          topMenus.value = convertedMenus;
          print('사내 추천 데이터 로드 완료: ${topMenus.length}개');
        } else {
          // 응답은 성공했지만 데이터가 없거나 실패인 경우
          final errorCode = responseData['code'];
          final errorMessage =
              responseData['message'] ?? '사내 추천 데이터를 불러오는데 실패했습니다.';

          if (errorCode == 4014) {
            // 오늘의 메뉴가 등록되지 않은 경우
            isNoMenuToday.value = true;
          } else {
            Get.snackbar('오류', errorMessage);
          }

          print('사내 추천 API 응답 오류: $errorMessage (코드: $errorCode)');
        }
      }
    } catch (e) {
      print('사내 추천 데이터 로드 실패: $e');
      Get.snackbar('오류', '사내 추천 데이터를 불러오는데 실패했습니다.');
    } finally {
      isLoading.value = false;
    }
  }

  // 영문 매장명을 한글로 변환
  String _convertStoreName(String? storeName) {
    if (storeName == null) return '';

    switch (storeName.toLowerCase()) {
      case 'ourhome':
      case 'our_home':
        return '아워홈';
      case 'cj_fresh':
        return 'CJ프레시';
      default:
        return storeName;
    }
  }

  // 사내/사외 여부 확인
  bool get isInside => affiliation.value == 'inside';
  bool get isOutside => affiliation.value == 'outside';

  // 사외 추천 데이터를 서버에서 가져오기
  Future<void> _loadOutdoorRecommendations({
    bool showSuccessMessage = false,
  }) async {
    try {
      isLoading.value = true;

      // 실제 사외 추천 API 호출
      final response = await _apiService.get('/users/outdoor');

      if (response.data['isSuccess'] == true &&
          response.data['result'] != null) {
        final List<dynamic> resultList = response.data['result'];

        // 서버 데이터를 앱 내부 형식으로 변환
        final List<Map<String, dynamic>> convertedMenus =
            resultList.map((item) {
              return {
                'name': item['store'] ?? '', // 가게명만 표시
                'menu': item['menu'] ?? '',
                'store': item['store'] ?? '',
                'score': item['score'] ?? 0,
                'price': _formatPrice(item['price']),
                'rank': item['rank'] ?? 0,
                'comment': item['comment'] ?? '',
                // latitude와 longitude를 문자열에서 double로 변환
                'latitude': _parseDouble(item['latitude']),
                'longitude': _parseDouble(item['longitude']),
                'image': item['imgUrl'] ?? '', // 서버에서 제공하는 이미지 URL 사용
              };
            }).toList();

        topMenus.value = convertedMenus;
        print('사외 추천 데이터 로드 완료: ${topMenus.length}개');

        // 재시도일 때만 성공 메시지 표시
        if (showSuccessMessage) {
          Get.snackbar(
            '완료',
            '새로운 사외 추천을 받아왔습니다!',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        print('사외 추천 API 응답 오류: ${response.data['message']}');
        Get.snackbar(
          '오류',
          response.data['message'] ?? '사외 추천 데이터를 불러오는데 실패했습니다.',
        );
      }
    } catch (e) {
      print('사외 추천 데이터 로드 실패: $e');
      Get.snackbar('오류', '사외 추천 데이터를 불러오는데 실패했습니다.');
    } finally {
      isLoading.value = false;
    }
  }

  // 가격 포맷팅 함수
  String _formatPrice(dynamic price) {
    if (price == null) return '';

    // 숫자인 경우 천 단위 콤마 추가
    if (price is int) {
      return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원';
    }

    // 이미 문자열인 경우 그대로 반환
    return price.toString();
  }

  // 문자열 또는 숫자를 double로 안전하게 변환하는 함수
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is double) return value;
    if (value is int) return value.toDouble();

    // 문자열인 경우 파싱 시도
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print('좌표 파싱 실패: $value, 오류: $e');
        return 0.0;
      }
    }

    return 0.0;
  }
}
