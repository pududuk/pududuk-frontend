import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/survey_controller.dart';
import 'package:flutter/cupertino.dart';
import '../../../utils/app_colors.dart';

class SurveyView extends GetView<SurveyController> {
  const SurveyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.main,
        title: Row(
          children: [
            const Icon(Icons.restaurant_menu),
            const SizedBox(width: 8),
            const Text('푸드득', style: TextStyle(color: Colors.black)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            const Text('선호 음식', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              maxLines: 2,
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
            const Text("비선호 음식", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              maxLines: 2,
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
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.main.withOpacity(0.08),
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
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.main,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
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
            color: selected ? AppColors.main.withOpacity(0.08) : Colors.white,
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
