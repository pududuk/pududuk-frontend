import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/platform_utils.dart';
import '../controllers/recommend_result_controller.dart';
import 'package:screenshot/screenshot.dart';

class RecommendResultView extends GetView<RecommendResultController> {
  const RecommendResultView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appBar =
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
                          color: AppColors.main.withAlpha((0.08 * 255).toInt()),
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
                              '추천 결과',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: controller.onShare,
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
              iconTheme: const IconThemeData(color: Colors.white),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              title: const Text(
                '추천 결과',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: controller.onShare,
                ),
              ],
            );

    return Scaffold(
      appBar: appBar,
      body: Screenshot(
        controller: controller.screenshotController,
        child: SingleChildScrollView(
          child: Padding(
            padding: PlatformUtils.getResponsivePadding(
              mobileHorizontal: 20,
              webHorizontal: 100,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: kIsWeb ? 4 : 12),
                // 상단 트로피/완료 메시지
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.main.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(18),
                      child: const Icon(
                        Icons.emoji_events,
                        color: AppColors.main,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '추천 완료!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '당신을 위한 맞춤 메뉴를 찾았어요',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 1~3위 메뉴 썸네일
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final menu = controller.topMenus[i];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                CircleAvatar(
                                  radius: i == 1 ? 38 : 32,
                                  backgroundColor:
                                      i == 1
                                          ? AppColors.main
                                          : Colors.grey[200],
                                  child: CircleAvatar(
                                    radius: i == 1 ? 34 : 28,
                                    backgroundImage: AssetImage(
                                      menu['image'] as String,
                                    ),
                                  ),
                                ),
                                if (i == 1)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Icon(
                                      Icons.emoji_events,
                                      color: Colors.amber,
                                      size: 24,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              menu['name'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${menu['score']}점',
                              style: TextStyle(
                                color: AppColors.main,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),
                // 다른 추천 메뉴
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '다른 추천 메뉴',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.otherMenus.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final menu = controller.otherMenus[idx];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(
                              menu['image'] as String,
                            ),
                            radius: 22,
                          ),
                          title: Text('${menu['rank']}. ${menu['name']}'),
                          subtitle: Text('${menu['score']}점'),
                          onTap: () {},
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // 하단 버튼
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.onRetry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.main,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          '다시 추천받기',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.onSave,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.main),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          '결과 저장하기',
                          style: TextStyle(color: AppColors.main, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
