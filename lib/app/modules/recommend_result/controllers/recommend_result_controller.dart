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
  final topMenus =
      [
        {'name': '불고기덮밥', 'score': 92, 'image': 'assets/image/bulgogi.png'},
        {'name': '비빔밥', 'score': 95, 'image': 'assets/image/bibimbap.png'},
        {
          'name': '김치볶음밥',
          'score': 89,
          'image': 'assets/image/kimchi_fried_rice.png',
        },
      ].obs;

  // 4~8위 메뉴
  final otherMenus =
      [
        {
          'rank': 4,
          'name': '치킨테리야키',
          'score': 85,
          'image': 'assets/image/chicken_teriyaki.png',
        },
        {
          'rank': 5,
          'name': '돈까스',
          'score': 82,
          'image': 'assets/image/pork_cutlet.png',
        },
        {
          'rank': 6,
          'name': '라면',
          'score': 78,
          'image': 'assets/image/ramen.png',
        },
        {
          'rank': 7,
          'name': '치킨',
          'score': 75,
          'image': 'assets/image/chicken.png',
        },
        {
          'rank': 8,
          'name': '해물파전',
          'score': 72,
          'image': 'assets/image/seafood_pancake.png',
        },
      ].obs;

  final screenshotController = ScreenshotController();

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
