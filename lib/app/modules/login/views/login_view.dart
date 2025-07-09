import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../controllers/login_controller.dart';
import '../../../utils/app_colors.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 기존 앱과 동일한 흰색 배경
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: kIsWeb ? 400 : double.infinity, // 웹에서 최대 너비 제한
              ),
              padding: EdgeInsets.symmetric(
                horizontal: kIsWeb ? 32 : 32,
                vertical: 20,
              ),
              child: Column(
                children: [
                  SizedBox(height: kIsWeb ? 60 : 80),

                  // 앱 로고
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.main, // 기존 앱 메인 컬러 사용
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 앱 이름
                  const Text(
                    '푸드득',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 부제목
                  const Text(
                    '맛있는 음식을 쉽게 추천받으세요',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 48),

                  // 간편하게 로그인을 진행합니다
                  const Text(
                    '샌디로 로그인을 진행합니다',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 아이디와 비밀번호를 입력해주세요
                  const Text(
                    '샌디 아이디와 비밀번호를 입력해주세요',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 32),

                  // 아이디 입력 필드
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '샌디 아이디(이메일)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller.idController,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value) {
                          FocusScope.of(context).nextFocus();
                        },
                        decoration: InputDecoration(
                          hintText: '아이디(이메일)를 입력해주세요',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: AppColors.main,
                          ),
                          filled: true,
                          fillColor: AppColors.main.withOpacity(
                            0.05,
                          ), // 기존 앱 스타일의 연한 배경
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.main.withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.main.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.main,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 비밀번호 입력 필드
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '샌디 비밀번호',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => TextField(
                          controller: controller.passwordController,
                          obscureText: !controller.isPasswordVisible.value,
                          obscuringCharacter: '●', // 마스킹 문자 설정
                          keyboardType:
                              TextInputType.visiblePassword, // 비밀번호 키보드 타입
                          enableSuggestions: false, // 자동완성 비활성화
                          autocorrect: false, // 자동수정 비활성화
                          enableInteractiveSelection: false, // 텍스트 선택 비활성화
                          textInputAction: TextInputAction.done,
                          onSubmitted: (value) {
                            if (controller.isLoginButtonEnabled.value &&
                                !controller.isLoading.value) {
                              controller.onLogin();
                            }
                          },
                          decoration: InputDecoration(
                            hintText: '비밀번호를 입력해주세요',
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: AppColors.main,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordVisible.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.main,
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                            filled: true,
                            fillColor: AppColors.main.withOpacity(
                              0.05,
                            ), // 기존 앱 스타일의 연한 배경
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.main.withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.main.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.main,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 아이디 저장 체크박스
                  Obx(
                    () => GestureDetector(
                      onTap: controller.toggleRememberId, // 전체 영역 클릭 시 토글
                      child: Row(
                        children: [
                          Transform.scale(
                            scale: 0.9, // 체크박스 크기 조정
                            child: Checkbox(
                              value: controller.isRememberIdChecked.value,
                              onChanged:
                                  (value) => controller.toggleRememberId(),
                              activeColor: AppColors.main, // 기존 앱 메인 컬러 사용
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity:
                                  VisualDensity.compact, // 체크박스 패딩 최소화
                            ),
                          ),
                          const SizedBox(width: 8), // 체크박스와 텍스트 간격
                          const Text(
                            '로그인 상태 유지',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 로그인 버튼
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            controller.isLoginButtonEnabled.value &&
                                    !controller.isLoading.value
                                ? controller.onLogin
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              controller.isLoginButtonEnabled.value &&
                                      !controller.isLoading.value
                                  ? AppColors.main
                                  : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child:
                            controller.isLoading.value
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  '로그인',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
