import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class RecommendResultController extends GetxController {
  // 1~3위 메뉴
  // 쇼쿠,이자카야,37.56095210066757,126.82881756217137,얼큰해물짬뽕,"23,000",
  // 홀리즉떡,한식,37.55905430305593,126.82859334598922,떡볶이 2인분,"15,000",https://search.pstatic.net/common/?autoRotate=true&quality=95&type=f320_320&src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20250629_217%2F1751205189369TKPx5_JPEG%2FIMG_9942.jpeg
  // 흥탄양갈비 마곡본점,양갈비,37.559878832899585,126.8291562863812,고급양갈비(250g),"30,000",https://search.pstatic.net/common/?autoRotate=true&quality=95&type=f320_320&src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20200628_283%2F1593328413878kPwua_JPEG%2F7CNwoLKqyMthvIe40a019CS0.jpg
  // 나룻목 마곡나루역점,"육류,고기요리",37.56731824213836,126.82700200214423,쫄깃쫄깃 갈매기살 180g,"16,900",https://search.pstatic.net/common/?autoRotate=true&quality=95&type=f320_320&src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20250529_25%2F1748496606944RgdNx_JPEG%2FKakaoTalk_20250529_142907134_02.jpg
  // 예향정 마곡점,37.5678688,126.8265941,된장찌개(공기밥포함),8000
  // 무쇠김치찌개,37.5666100,126.9783882,꽁치김치찌개,9000
  // 삼미당마곡점,37.5598184,126.8315996,니쿠니쿠마제소바,13000

  final topMenus =
      [
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
        // {
        //   'name': '무쇠김치찌개',
        //   'score': 92,
        //   'image': '',
        //   'latitude': 37.5666100,
        //   'longitude': 126.9783882,
        //   'price': '9,000',
        // },
        // {
        //   'name': '삼미당마곡점',
        //   'score': 92,
        //   'image': '',
        //   'latitude': 37.5598184,
        //   'longitude': 126.8315996,
        //   'price': '13,000',
        // },
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
    Get.snackbar('다시 추천', '추천을 새로 받습니다!');
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
}
