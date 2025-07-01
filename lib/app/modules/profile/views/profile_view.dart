import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        centerTitle: true,
        actions: [Icon(Icons.edit)],
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.person, size: 48, color: Colors.orange),
          const SizedBox(height: 8),
          const Text(
            '내 정보',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 4),
          const Text(
            '회원님의 프로필을 확인하세요',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Obx(
            () => ListTile(
              leading: const CircleAvatar(
                radius: 30,
                child: Icon(Icons.person, size: 30),
              ),
              title: Text('이름: ${controller.userName}'),
              subtitle: Text('이메일: ${controller.userEmail}'),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('뒤로 가기', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
