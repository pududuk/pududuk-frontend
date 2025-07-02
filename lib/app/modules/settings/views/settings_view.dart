import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../../utils/platform_utils.dart';
import 'package:flutter/foundation.dart';
import '../../../utils/app_colors.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

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
                          const SizedBox(width: 40), // leading 없음
                          const Expanded(
                            child: Center(
                              child: Text(
                                '설정',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              : AppBar(
                elevation: 0,
                backgroundColor: Colors.blue,
                centerTitle: true,
                leading:
                    kIsWeb
                        ? Padding(
                          padding: EdgeInsets.only(left: 24),
                          child: Icon(Icons.settings, color: Colors.white),
                        )
                        : Icon(Icons.settings, color: Colors.white),
                title: Padding(
                  padding: EdgeInsets.symmetric(horizontal: kIsWeb ? 40 : 0),
                  child: const Text(
                    '설정',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                actions:
                    kIsWeb
                        ? [
                          Padding(
                            padding: EdgeInsets.only(right: 24),
                            child: Icon(Icons.edit, color: Colors.white),
                          ),
                        ]
                        : [Icon(Icons.edit, color: Colors.white)],
              ),
      body: SingleChildScrollView(
        padding: PlatformUtils.getResponsivePadding(
          mobileHorizontal: 16,
          webHorizontal: 100,
        ),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.settings, size: 48, color: Colors.orange),
            const SizedBox(height: 8),
            const Text(
              '앱 설정',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 4),
            const Text(
              '푸드득 앱의 다양한 설정을 변경하세요',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('다크 모드'),
                    trailing: Obx(
                      () => Switch(
                        value: controller.isDarkMode.value,
                        onChanged: (value) => controller.toggleDarkMode(),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('알림'),
                    trailing: Obx(
                      () => Switch(
                        value: controller.notificationsEnabled.value,
                        onChanged: (value) => controller.toggleNotifications(),
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('앱 정보'),
                    onTap: () {
                      Get.snackbar(
                        '앱 정보',
                        '푸드득 앱 v1.0.0',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.arrow_back),
                    title: const Text('뒤로 가기'),
                    onTap: () => Get.back(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
