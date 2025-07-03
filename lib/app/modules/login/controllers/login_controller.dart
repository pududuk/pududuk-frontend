import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pududuk_app/app/services/api_service.dart';

class LoginController extends GetxController {
  final idController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordVisible = false.obs;
  var isLoginButtonEnabled = false.obs;
  var isRememberIdChecked = false.obs;
  var isLoading = false.obs;

  final ApiService _apiService = Get.find<ApiService>();

  @override
  void onInit() {
    super.onInit();

    // 입력 필드 변경 감지
    idController.addListener(_updateLoginButtonState);
    passwordController.addListener(_updateLoginButtonState);

    // 저장된 이메일 확인 및 자동 로그인
    _checkAutoLogin();
  }

  void _updateLoginButtonState() {
    isLoginButtonEnabled.value =
        idController.text.isNotEmpty && passwordController.text.isNotEmpty;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRememberId() {
    isRememberIdChecked.value = !isRememberIdChecked.value;
  }

  // 자동 로그인 체크
  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');

    if (savedEmail != null && savedEmail.isNotEmpty) {
      // 저장된 이메일이 있으면 자동으로 홈으로 이동
      print('저장된 이메일 발견: $savedEmail - 자동 로그인 진행');
      Get.offAllNamed('/home');
    } else {
      // 저장된 이메일이 없으면 입력 필드만 로드
      _loadSavedEmail();
    }
  }

  // 저장된 이메일 불러오기 (자동 로그인 하지 않을 때만 사용)
  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    if (savedEmail != null) {
      idController.text = savedEmail;
      isRememberIdChecked.value = true;
    }
  }

  Future<void> onLogin() async {
    if (idController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('오류', '아이디와 비밀번호를 입력해주세요.');
      return;
    }

    isLoading.value = true;

    try {
      // 로그인 요청 바디 구성
      final requestBody = {
        "email": idController.text.trim(),
        "password": passwordController.text.trim(),
      };

      final response = await _apiService.post(
        '/sandi/login',
        data: requestBody,
      );

      if (response.statusCode == 200) {
        // 로그인 성공
        final prefs = await SharedPreferences.getInstance();

        // 로그인 상태 유지가 체크되어 있다면 이메일 저장
        if (isRememberIdChecked.value) {
          await prefs.setString('saved_email', idController.text.trim());
        } else {
          // 체크 해제되어 있으면 저장된 이메일 삭제
          await prefs.remove('saved_email');
        }

        Get.snackbar('로그인 성공', '환영합니다!');
        Get.offAllNamed('/home');
      } else {
        // 로그인 실패
        Get.snackbar('로그인 실패', '아이디 또는 비밀번호가 올바르지 않습니다.');
      }
    } catch (e) {
      // ApiService에서 이미 에러 처리됨
      Get.snackbar('로그인 실패', '로그인에 실패했습니다.');
    } finally {
      isLoading.value = false;
    }
  }

  void onFindPassword() {
    Get.snackbar('비밀번호 찾기', '비밀번호 찾기 기능은 준비 중입니다.');
  }

  @override
  void onClose() {
    idController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
