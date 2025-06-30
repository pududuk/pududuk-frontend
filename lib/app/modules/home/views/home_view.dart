import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('버튼을 눌러 카운터를 증가시키세요:'),
            Obx(
              () => Text(
                '${controller.count}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.toNamed('/profile'),
              child: const Text('프로필로 이동'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Get.toNamed('/settings'),
              child: const Text('설정으로 이동'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        tooltip: '증가',
        child: const Icon(Icons.add),
      ),
    );
  }
}
