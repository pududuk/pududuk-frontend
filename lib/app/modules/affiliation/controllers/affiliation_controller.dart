import 'package:get/get.dart';
import 'package:pududuk_app/app/services/api_service.dart';

class AffiliationController extends GetxController {
  // 'inside' 또는 'outside' 값을 가짐
  var selected = ''.obs;
  var isLoading = false.obs;

  final ApiService _apiService = Get.find<ApiService>();

  // 사내/사외 선택 후 다음 페이지로 이동
  Future<void> selectAffiliationAndProceed(String affiliation) async {
    selected.value = affiliation;
    isLoading.value = true;

    try {
      // 서버에서 설문조사 데이터 확인
      final hasSurveyData = await _checkSurveyData();

      if (hasSurveyData) {
        // 설문조사 데이터가 있으면 추천 결과 페이지로
        print('설문조사 데이터 존재 - 추천 결과 페이지로 이동');
        Get.toNamed(
          '/recommend_result',
          parameters: {'affiliation': affiliation},
        );
      } else {
        // 설문조사 데이터가 없으면 설문조사 페이지로
        print('설문조사 데이터 없음 - 설문조사 페이지로 이동');
        Get.toNamed('/survey', parameters: {'affiliation': affiliation});
      }
    } catch (e) {
      print('설문조사 데이터 확인 중 오류: $e');
      // 오류 발생 시 설문조사 페이지로 이동
      Get.toNamed('/survey');
    } finally {
      isLoading.value = false;
    }
  }

  // 서버에서 설문조사 데이터 존재 여부 확인
  Future<bool> _checkSurveyData() async {
    try {
      final response = await _apiService.get('/users/profile');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // isSuccess가 true이고 result에 데이터가 있으면 설문조사 완료
        if (responseData['isSuccess'] == true &&
            responseData['result'] != null) {
          final surveyData = responseData['result'];

          // 필수 필드들이 모두 있는지 확인
          return surveyData['age'] != null &&
              surveyData['gender'] != null &&
              surveyData['priceLimit'] != null;
        }
      }

      return false;
    } catch (e) {
      print('설문조사 데이터 확인 API 오류: $e');
      return false;
    }
  }
}
