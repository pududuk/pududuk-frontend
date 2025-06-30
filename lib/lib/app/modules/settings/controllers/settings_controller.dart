import 'package:get/get.dart';

class SettingsController extends GetxController {
  final isDarkMode = false.obs;
  final notificationsEnabled = true.obs;

  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
  }

  void toggleNotifications() {
    notificationsEnabled.value = !notificationsEnabled.value;
  }

  @override
  void onInit() {
    super.onInit();
  }
}
