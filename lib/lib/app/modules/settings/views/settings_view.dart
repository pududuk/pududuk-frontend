import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
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
    );
  }
}
