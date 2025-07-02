import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/platform_utils.dart';
import '../controllers/affiliation_controller.dart';
import '../../../routes/app_pages.dart';
import 'package:flutter/foundation.dart';

class AffiliationView extends GetView<AffiliationController> {
  const AffiliationView({Key? key}) : super(key: key);

  Future<void> _handleContinue() async {
    final prefs = await SharedPreferences.getInstance();
    final age = prefs.getString('survey_age') ?? '';
    final gender = prefs.getString('survey_gender') ?? '';
    final waitTime = prefs.getString('survey_waitTime') ?? '';
    final nearby = prefs.getString('survey_nearby') ?? '';
    final preferredFoods = prefs.getString('survey_preferredFoods') ?? '';
    final restrictions = prefs.getString('survey_restrictions') ?? '';

    if ([
      age,
      gender,
      waitTime,
      nearby,
      preferredFoods,
      restrictions,
    ].every((v) => v.isEmpty)) {
      // 모두 비어있으면 SurveyView로 이동
      Get.toNamed(Routes.SURVEY);
    } else {
      // 하나라도 있으면 RecommendResultView로 이동
      Get.toNamed(Routes.RECOMMEND_RESULT);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      backgroundColor: AppColors.main,
      elevation: 0,
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => Get.toNamed(Routes.SURVEY),
        ),
      ],
    );

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
                          const SizedBox(width: 40), // leading 없음
                          const Expanded(
                            child: Center(
                              child: Text(
                                "LG's 푸드득",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                            onPressed: () => Get.toNamed(Routes.SURVEY),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              : appBar,
      body: SingleChildScrollView(
        padding: PlatformUtils.getResponsivePadding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: AppColors.main.withAlpha((0.08 * 255).toInt()),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(18),
              child: Icon(Icons.apartment, color: AppColors.main, size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              "LG's 푸드득",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 8),
            const Text(
              '사내 식당과 사외 식당 중 원하시는 옵션을 선택하세요',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 32),
            Obx(
              () => _affiliationCard(
                icon: Icons.restaurant,
                iconColor: Colors.blue,
                title: '사내 식당',
                subtitle: '아워홈, CJ, 풀무원',
                value: 'inside',
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => _affiliationCard(
                icon: Icons.store,
                iconColor: Colors.green,
                title: '사외 식당',
                subtitle: '회사 근처 맛집 추천',
                value: 'outside',
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.main.withAlpha((0.08 * 255).toInt()),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '선택한 구분에 따라 이용 가능한 서비스가 달라질 수 있습니다.',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      controller.selected.value.isNotEmpty
                          ? () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString(
                              'affiliation',
                              controller.selected.value,
                            );
                            await _handleContinue();
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.main,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '계속하기',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _affiliationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = controller.selected.value == value;
    return GestureDetector(
      onTap: () async {
        controller.selected.value = value;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('affiliation', value);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.main.withAlpha((0.08 * 255).toInt())
                  : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.main : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withAlpha((0.15 * 255).toInt()),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: controller.selected.value,
              activeColor: AppColors.main,
              onChanged: (v) async {
                controller.selected.value = v ?? '';
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('affiliation', v ?? '');
              },
            ),
          ],
        ),
      ),
    );
  }
}
