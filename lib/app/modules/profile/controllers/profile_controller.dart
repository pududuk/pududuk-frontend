import 'package:get/get.dart';

class ProfileController extends GetxController {
  final userName = '사용자'.obs;
  final userEmail = 'user@example.com'.obs;

  void updateProfile(String name, String email) {
    userName.value = name;
    userEmail.value = email;
  }

  @override
  void onInit() {
    super.onInit();
  }
}
