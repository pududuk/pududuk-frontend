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
  var isLoading = false.obs;

  // 1~3위 메뉴 (기본값은 사외 데이터)
  final topMenus =
      <Map<String, dynamic>>[
        {
          'name': '홀리즉떡',
          'score': 92,
          'image':
              'https://search.pstatic.net/common/?autoRotate=true&quality=95&type=f320_320&src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20250629_217%2F1751205189369TKPx5_JPEG%2FIMG_9942.jpeg',
          'latitude': 37.55905430305593,
          'longitude': 126.82859334598922,
          'price': '15,000',
        },
        {
          'name': '흥탄양갈비 마곡본점',
          'score': 92,
          'image':
              'https://search.pstatic.net/common/?autoRotate=true&quality=95&type=f320_320&src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20200628_283%2F1593328413878kPwua_JPEG%2F7CNwoLKqyMthvIe40a019CS0.jpg',
          'latitude': 37.559878832899585,
          'longitude': 126.8291562863812,
          'price': '30,000',
        },
        {
          'name': '나룻목 마곡나루역점',
          'score': 92,
          'image':
              'https://search.pstatic.net/common/?autoRotate=true&quality=95&type=f320_320&src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20250529_25%2F1748496606944RgdNx_JPEG%2FKakaoTalk_20250529_142907134_02.jpg',
          'latitude': 37.56731824213836,
          'longitude': 126.82700200214423,
          // 'price': '16,900',
        },
        {
          'name': '예향정 마곡점',
          'score': 92,
          'image': '',
          'latitude': 37.5678688,
          'longitude': 126.8265941,
          'price': '8,000',
        },
        {
          'name': '쇼쿠 이자카야',
          'score': 89,
          'image':
              'https://search.pstatic.net/common/?autoRotate=true&quality=95&type=f320_320&src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20250619_157%2F1750316153284HHone_JPEG%2FKakaoTalk_20250619_155400664_02.jpg',
          'latitude': 37.56095210066757,
          'longitude': 126.82881756217137,
          'price': '23,000',
        },
      ].obs;

  // 4위 이후 메뉴 (topMenus에서 상위 3개를 제외한 나머지)
  RxList<Map<String, dynamic>> get otherMenus {
    if (topMenus.length <= 3) return <Map<String, dynamic>>[].obs;

    return topMenus
        .skip(3)
        .map((menu) {
          return {
            'rank': topMenus.indexOf(menu) + 1,
            'name': menu['name'],
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

    if (isInside) {
      // 사내 추천 - 서버에서 새로운 데이터 받아오기
      _loadIndoorRecommendations();
      Get.snackbar(
        '알림',
        '새로운 사내 추천을 받아오고 있습니다...',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      // 사외 추천 - 서버에서 새로운 데이터 받아오기 (추후 구현)
      // TODO: 사외 추천 API 호출 추가
      _loadOutdoorRecommendations();
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
                  'image': '', // 사내 식당은 이미지 없음
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
        return '아워홈';
      default:
        return storeName;
    }
  }

  // 사내/사외 여부 확인
  bool get isInside => affiliation.value == 'inside';
  bool get isOutside => affiliation.value == 'outside';

  // 사외 추천 데이터를 서버에서 가져오기
  Future<void> _loadOutdoorRecommendations() async {
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
                'name': item['store'] ?? '',
                'menu': item['menu'] ?? '',
                'score': item['score'] ?? 0,
                'price': _formatPrice(item['price']),
                'rank': item['rank'] ?? 0,
                'comment': item['comment'] ?? '',
                // latitude와 longitude는 나중에 추가될 예정
                'latitude': item['latitude'] ?? 0.0,
                'longitude': item['longitude'] ?? 0.0,
                'image': '', // 이미지는 기본값으로 설정 (웹에서는 기본 이미지 사용)
              };
            }).toList();

        topMenus.value = convertedMenus;
        print('사외 추천 데이터 로드 완료: ${topMenus.length}개');

        // 성공 메시지
        Get.snackbar(
          '완료',
          '새로운 사외 추천을 받아왔습니다!',
          snackPosition: SnackPosition.BOTTOM,
        );
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
}
