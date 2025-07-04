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
                color: Colors.transparent,
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
                // Stack(추천 완료 메시지+지도 버튼) 가장 위에 배치
                Stack(
                  children: [
                    // 중앙에 추천 완료 메시지
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          // 트로피 아이콘
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
                          // 추천 완료! 텍스트
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
                    ),
                    // 오른쪽에 지도 버튼 - affiliation이 outside일 때만 노출
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Obx(() {
                        if (controller.isOutside) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  Get.toNamed(
                                    '/map_result',
                                    arguments: {'selectedMenuIndex': 0},
                                  ); // 기본값: 1위 메뉴
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.main.withAlpha(30),
                                  child: const Icon(
                                    Icons.map,
                                    color: AppColors.main,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '지도로 보기',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          );
                        }
                        return SizedBox.shrink();
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 1~3위 메뉴 썸네일
                Obx(() {
                  final isOutside = controller.isOutside;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 2위 (왼쪽)
                      _buildMenuThumbnail(controller.topMenus[1], 1, isOutside),
                      // 1위 (가운데)
                      _buildMenuThumbnail(controller.topMenus[0], 0, isOutside),
                      // 3위 (오른쪽)
                      _buildMenuThumbnail(controller.topMenus[2], 2, isOutside),
                    ],
                  );
                }),
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
                Obx(() {
                  final isOutside = controller.isOutside;
                  return ListView.separated(
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
                            backgroundImage:
                                (menu['image'] != null &&
                                        (menu['image'] as String).isNotEmpty)
                                    ? getMenuImage(menu['image'] as String?)
                                    : null,
                            child:
                                (menu['image'] == null ||
                                        (menu['image'] as String).isEmpty)
                                    ? Icon(
                                      Icons.restaurant,
                                      color: Colors.grey[600],
                                    )
                                    : null,
                            radius: 22,
                          ),
                          title: SizedBox(
                            width: 120,
                            child: Text(
                              '\t${menu['rank']}. ${menu['name']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          subtitle: Text(
                            '${menu['score']}점',
                            style: TextStyle(fontSize: 13),
                          ),
                          trailing:
                              (menu['price'] != null &&
                                      (menu['price'] as String).isNotEmpty)
                                  ? Text(
                                    '₩${menu['price'] as String}',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  )
                                  : null,
                          onTap:
                              isOutside
                                  ? () => Get.toNamed(
                                    '/map_result',
                                    arguments: {
                                      'selectedMenuIndex': menu['rank'] - 1,
                                    },
                                  )
                                  : null,
                        ),
                      );
                    },
                  );
                }),
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

  // 메뉴 썸네일 위젯 생성 함수
  Widget _buildMenuThumbnail(Map menu, int index, bool isOutside) {
    return GestureDetector(
      onTap:
          isOutside
              ? () => Get.toNamed(
                '/map_result',
                arguments: {'selectedMenuIndex': index},
              )
              : null,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                CircleAvatar(
                  radius: index == 0 ? 38 : 32, // 1위(index 0)가 가장 큼
                  backgroundColor:
                      index == 0 ? AppColors.main : Colors.grey[200],
                  child: CircleAvatar(
                    radius: index == 0 ? 34 : 28,
                    backgroundImage:
                        (menu['image'] != null &&
                                (menu['image'] as String).isNotEmpty)
                            ? getMenuImage(menu['image'] as String?)
                            : null,
                    child:
                        (menu['image'] == null ||
                                (menu['image'] as String).isEmpty)
                            ? Icon(Icons.restaurant, color: Colors.grey[600])
                            : null,
                  ),
                ),
                if (index == 0) // 1위에만 왕관
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
            SizedBox(
              width: 80,
              child: Text(
                menu['name'] as String,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            Text(
              '${menu['score']}점',
              style: TextStyle(
                color: AppColors.main,
                fontWeight: FontWeight.bold,
              ),
            ),
            // 가격 영역을 고정 높이로 설정하여 모든 메뉴의 높이를 동일하게 유지
            SizedBox(
              height: 20, // 고정 높이
              child:
                  (menu['price'] != null &&
                          (menu['price'] as String).isNotEmpty)
                      ? Text(
                        '₩${menu['price'] as String}',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                      : SizedBox.shrink(), // 가격이 없어도 높이는 유지
            ),
          ],
        ),
      ),
    );
  }

  // 이미지 프로바이더 분기 함수
  ImageProvider getMenuImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return AssetImage('assets/image/default.png');
    } else if (imagePath.startsWith('http')) {
      // 웹에서는 CORS 문제로 외부 이미지 사용 불가, 기본 이미지 사용
      if (kIsWeb) {
        return AssetImage('assets/image/default.png');
      }
      return NetworkImage(imagePath);
    } else {
      return AssetImage(imagePath);
    }
  }
}
