import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pududuk_app/app/routes/app_pages.dart';
import '../controllers/survey_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/platform_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SurveyView extends GetView<SurveyController> {
  const SurveyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          kIsWeb
              ? PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Container(
                  color: Colors.white,
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 100,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.main.withAlpha((0.92 * 255).toInt()),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.main.withAlpha(
                              (0.08 * 255).toInt(),
                            ),
                            blurRadius: 12,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      height: 56,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                            ),
                            onPressed: () => Get.back(),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                '푸드득',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              : AppBar(
                elevation: 0,
                backgroundColor: AppColors.main,
                automaticallyImplyLeading: !kIsWeb,
                iconTheme: const IconThemeData(color: Colors.white),
                centerTitle: kIsWeb,
                leading:
                    kIsWeb
                        ? Padding(
                          padding: EdgeInsets.only(left: 24),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                            ),
                            onPressed: () => Get.back(),
                          ),
                        )
                        : null,
                title: Padding(
                  padding: EdgeInsets.symmetric(horizontal: kIsWeb ? 40 : 0),
                  child:
                      kIsWeb
                          ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.restaurant_menu, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                '푸드득',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )
                          : Row(
                            children: const [
                              Icon(Icons.restaurant_menu, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                '푸드득',
                                style: TextStyle(color: Colors.white),
                              ),
                              Spacer(),
                            ],
                          ),
                ),
              ),
      body: SingleChildScrollView(
        padding: PlatformUtils.getResponsivePadding(),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: kIsWeb ? 600 : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  '푸드득 설문 조사',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const SizedBox(height: 4),
                const Text('더 나은 추천을 위해 입력해주세요'),
                const SizedBox(height: 24),
                const Text('나이', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    int selected =
                        int.tryParse(controller.ageController.text) ?? 25;
                    await showModalBottomSheet<int>(
                      context: context,
                      builder: (context) {
                        return Container(
                          height: 250,
                          child: Column(
                            children: [
                              Expanded(
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(
                                    initialItem: selected,
                                  ),
                                  itemExtent: 40,
                                  onSelectedItemChanged: (index) {
                                    controller.ageController.text =
                                        index.toString();
                                    controller.age.value = index.toString();
                                  },
                                  children: List.generate(
                                    141,
                                    (index) => Center(child: Text('$index')),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('닫기'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: controller.ageController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: '나이를 선택해주세요...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('성별', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Obx(
                  () => Row(
                    children: [
                      _selectButton(
                        label: '남성',
                        icon: Icons.male,
                        selected: controller.gender.value == 'male',
                        onTap: () => controller.gender.value = 'male',
                      ),
                      const SizedBox(width: 12),
                      _selectButton(
                        label: '여성',
                        icon: Icons.female,
                        selected: controller.gender.value == 'female',
                        onTap: () => controller.gender.value = 'female',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '대기시간이 길어도 괜찮나요?',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Row(
                    children: [
                      _selectButton(
                        label: '네!',
                        icon: Icons.timer,
                        selected: controller.waitTime.value == 'yes',
                        onTap: () => controller.waitTime.value = 'yes',
                      ),
                      const SizedBox(width: 12),
                      _selectButton(
                        label: '아뇨!',
                        icon: Icons.hourglass_empty,
                        selected: controller.waitTime.value == 'no',
                        onTap: () => controller.waitTime.value = 'no',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '가까운 지역을 선호하시나요? (사외 전용)',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Row(
                    children: [
                      _selectButton(
                        label: '네!',
                        icon: Icons.location_on,
                        selected: controller.nearby.value == 'yes',
                        onTap: () => controller.nearby.value = 'yes',
                      ),
                      const SizedBox(width: 12),
                      _selectButton(
                        label: '아뇨!',
                        icon: Icons.public,
                        selected: controller.nearby.value == 'no',
                        onTap: () => controller.nearby.value = 'no',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '최대 가격',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.maxPriceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  decoration: InputDecoration(
                    hintText: "최대 가격을 입력해주세요...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    prefixText: '₩ ',
                  ),
                  onChanged: (v) => controller.maxPrice.value = v,
                ),
                const SizedBox(height: 20),
                const Text(
                  '선호 음식',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  maxLines: 2,
                  controller: controller.preferredFoodsController,
                  decoration: InputDecoration(
                    hintText: "좋아하는 음식을 입력해주세요...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (v) => controller.preferredFoods.value = v,
                ),
                const SizedBox(height: 20),
                const Text(
                  "비선호 음식",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  maxLines: 2,
                  controller: controller.restrictionsController,
                  decoration: InputDecoration(
                    hintText: '먹지 못하거나 선호하지 않는 음식을 입력해주세요...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (v) => controller.restrictions.value = v,
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.main.withAlpha((0.08 * 255).toInt()),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.location_on, size: 20),
                      SizedBox(width: 8),
                      Text('Location: Magok'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          controller.isLoading.value
                              ? null
                              : () async {
                                print(
                                  '버튼 클릭됨 - hasExistingData: ${controller.hasExistingData.value}',
                                );

                                // 서버 전송
                                final success = await controller.submitSurvey();

                                print('서버 전송 결과: $success');

                                if (success) {
                                  print('성공 - 다음 페이지로 이동');

                                  // 수정하기면 이전 페이지로, 저장하기면 추천 결과로
                                  if (controller.hasExistingData.value) {
                                    print('수정 완료 - 이전 페이지로 이동');
                                    print(
                                      'Navigator.canPop(): ${Navigator.canPop(context)}',
                                    );

                                    if (Navigator.canPop(context)) {
                                      Get.back();
                                      print('Get.back() 호출 완료');

                                      // 뒤로 간 후에 Snackbar 표시
                                      Future.delayed(
                                        Duration(milliseconds: 100),
                                        () {
                                          Get.snackbar(
                                            '수정 완료',
                                            '설문 정보가 수정되었습니다.',
                                            snackPosition: SnackPosition.BOTTOM,
                                          );
                                        },
                                      );
                                    } else {
                                      print('뒤로 갈 수 없음 - 홈으로 이동');
                                      Get.offAllNamed(Routes.HOME);
                                    }
                                  } else {
                                    print('저장 완료 - 추천 결과 페이지로 이동');
                                    Get.snackbar(
                                      '저장 완료',
                                      '설문 정보가 저장되었습니다.',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                    Get.toNamed(
                                      Routes.RECOMMEND_RESULT,
                                      parameters: {
                                        'affiliation': controller.affiliation,
                                      },
                                    );
                                  }
                                } else {
                                  print('서버 전송 실패');
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            controller.isLoading.value
                                ? Colors.grey.shade300
                                : AppColors.main,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                              : Text(
                                controller.hasExistingData.value
                                    ? '수정하기'
                                    : '저장하기',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color:
                selected
                    ? AppColors.main.withAlpha((0.08 * 255).toInt())
                    : Colors.white,
            border: Border.all(
              color: selected ? AppColors.main : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? AppColors.main : Colors.grey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.main : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
