import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../utils/platform_utils.dart';
import 'package:flutter/foundation.dart';
import '../../../utils/app_colors.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

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
                                '프로필',
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
                backgroundColor: Colors.green,
                centerTitle: true,
                leading:
                    kIsWeb
                        ? Padding(
                          padding: EdgeInsets.only(left: 24),
                          child: Icon(Icons.person, color: Colors.white),
                        )
                        : Icon(Icons.person, color: Colors.white),
                title: Padding(
                  padding: EdgeInsets.symmetric(horizontal: kIsWeb ? 40 : 0),
                  child: const Text(
                    '프로필',
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
          vertical: 12,
        ),
        child: Column(
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
      ),
    );
  }
}
