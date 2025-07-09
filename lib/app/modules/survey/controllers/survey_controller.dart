import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pududuk_app/app/services/api_service.dart';

class SurveyController extends GetxController {
  var age = '25'.obs;
  var gender = 'male'.obs;
  var waitTime = 'yes'.obs;
  var nearby = 'yes'.obs;
  var maxPrice = ''.obs;
  var preferredFoods = ''.obs;
  var restrictions = ''.obs;
  var hasExistingData = false.obs;
  var isLoading = false.obs;
  var isInitialLoading = true.obs;

  final ageController = TextEditingController(text: '25');
  final maxPriceController = TextEditingController();
  final preferredFoodsController = TextEditingController();
  final restrictionsController = TextEditingController();

  final ApiService _apiService = Get.find<ApiService>();

  @override
  void onInit() {
    super.onInit();
    _loadSurveyFromServer();
    ever(age, (String value) {
      if (ageController.text != value) {
        ageController.text = value;
        ageController.selection = TextSelection.collapsed(offset: value.length);
      }
    });
  }

  // affiliation 정보 가져오기
  String get affiliation => Get.parameters['affiliation'] ?? 'outside';

  // 서버에서 설문조사 데이터 가져오기
  Future<void> _loadSurveyFromServer() async {
    try {
      isInitialLoading.value = true;

      final response = await _apiService.get('/users/profile');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // isSuccess 필드로 성공 여부 확인
        if (responseData['isSuccess'] == true &&
            responseData['result'] != null) {
          final surveyData = responseData['result'];

          // 서버 데이터로 UI 업데이트
          _updateUIFromServerData(surveyData);

          print('서버에서 설문조사 데이터 로드 완료');
        } else {
          print('서버에 설문조사 데이터가 없음');
          // 서버에 데이터가 없으면 기본값 사용
          _setDefaultValues();
        }
      }
    } catch (e) {
      print('서버 데이터 로드 중 오류: $e');
      // 오류 발생 시 기본값 사용
      _setDefaultValues();
    } finally {
      isInitialLoading.value = false;
    }
  }

  // 서버 데이터로 UI 업데이트
  void _updateUIFromServerData(Map<String, dynamic> surveyData) {
    try {
      // 나이
      if (surveyData['age'] != null) {
        age.value = surveyData['age'].toString();
        ageController.text = surveyData['age'].toString();
      }

      // 성별 (서버에서 받은 값을 소문자로 변환)
      if (surveyData['gender'] != null) {
        gender.value = surveyData['gender'].toString().toLowerCase();
      }

      // 가격 제한
      if (surveyData['priceLimit'] != null) {
        maxPrice.value = surveyData['priceLimit'].toString();
        maxPriceController.text = surveyData['priceLimit'].toString();
      }

      // 선호 음식
      if (surveyData['foodPreferred'] != null) {
        preferredFoods.value = surveyData['foodPreferred'].toString();
        preferredFoodsController.text = surveyData['foodPreferred'].toString();
      }

      // 비선호 음식
      if (surveyData['foodDislike'] != null) {
        restrictions.value = surveyData['foodDislike'].toString();
        restrictionsController.text = surveyData['foodDislike'].toString();
      }

      // 근거리 선호 (서버: boolean → UI: yes/no)
      if (surveyData['localPreferred'] != null) {
        nearby.value = surveyData['localPreferred'] == true ? 'yes' : 'no';
      }

      // 대기시간 허용 (서버: boolean → UI: yes/no)
      if (surveyData['tolerateWaitTime'] != null) {
        waitTime.value = surveyData['tolerateWaitTime'] == true ? 'yes' : 'no';
      }

      // 서버 데이터가 있으면 기존 데이터로 표시
      hasExistingData.value = true;
    } catch (e) {
      print('서버 데이터 파싱 중 오류: $e');
    }
  }

  // 기본값 설정
  void _setDefaultValues() {
    age.value = '25';
    ageController.text = '25';
    gender.value = 'male';
    waitTime.value = 'yes';
    nearby.value = 'yes';
    maxPrice.value = '';
    maxPriceController.text = '';
    preferredFoods.value = '';
    preferredFoodsController.text = '';
    restrictions.value = '';
    restrictionsController.text = '';
    hasExistingData.value = false;
  }

  // 설문조사 데이터를 서버에 전송
  Future<bool> submitSurvey() async {
    isLoading.value = true;

    try {
      // 성별 값을 서버 형식으로 변환 (소문자로 변경)
      String genderForServer = gender.value; // 'male' 또는 'female' 그대로 사용

      // 설문조사 데이터를 JSON 바디로 구성
      final surveyData = {
        "age": int.tryParse(age.value) ?? 25,
        "gender": genderForServer,
        "priceLimit": int.tryParse(maxPrice.value) ?? 0,
        "foodPreferred": preferredFoods.value.trim(),
        "foodDislike": restrictions.value.trim(),
        "localPreferred": nearby.value == 'yes',
        "tolerateWaitTime": waitTime.value == 'yes',
      };

      print('전송할 설문조사 데이터: $surveyData');

      final response = await _apiService.patch(
        '/users/profile',
        data: surveyData,
      );

      print('서버 응답: ${response.statusCode}, ${response.data}');

      if (response.statusCode == 200) {
        // 응답 데이터 확인
        final responseData = response.data;

        // IsSuccess 필드로 성공 여부 확인
        if (responseData['isSuccess'] == true) {
          // 서버 전송 성공
          return true;
        } else {
          // isSuccess가 false인 경우
          final errorMessage = responseData['message'] ?? '설문조사 전송에 실패했습니다.';
          Get.snackbar('오류', errorMessage);
          return false;
        }
      } else {
        // HTTP 상태 코드가 200이 아닌 경우
        Get.snackbar('오류', '서버 오류가 발생했습니다.');
        return false;
      }
    } catch (e) {
      // 네트워크 오류 등
      Get.snackbar('오류', '설문조사 전송 중 오류가 발생했습니다.');
      print('설문조사 전송 오류: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    ageController.dispose();
    maxPriceController.dispose();
    preferredFoodsController.dispose();
    restrictionsController.dispose();
    super.onClose();
  }
}
