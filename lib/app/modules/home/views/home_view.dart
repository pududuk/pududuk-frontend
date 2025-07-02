import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../utils/platform_utils.dart';
import 'package:flutter/foundation.dart';
import '../../../utils/app_colors.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 예시 데이터
    final menus = [
      {'name': '오늘의 추천', 'desc': '비빔밥, 불고기덮밥, 김치볶음밥', 'icon': Icons.star},
      {'name': '인기 메뉴', 'desc': '치킨, 돈까스, 라면', 'icon': Icons.trending_up},
      {'name': '신규 메뉴', 'desc': '해물파전, 치킨테리야키', 'icon': Icons.new_releases},
    ];

    final appBar = AppBar(
      elevation: 0,
      backgroundColor: Colors.orange,
      centerTitle: true,
      leading:
          kIsWeb
              ? Padding(
                padding: EdgeInsets.only(left: 24),
                child: Icon(Icons.home, size: 48, color: Colors.orange),
              )
              : Icon(Icons.home, size: 48, color: Colors.orange),
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: kIsWeb ? 40 : 0),
        child: const Text(
          '푸드득',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      actions:
          kIsWeb
              ? [
                Padding(
                  padding: EdgeInsets.only(right: 24),
                  child: Icon(Icons.settings, color: Colors.white),
                ),
              ]
              : [Icon(Icons.settings, color: Colors.white)],
    );

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
                                '푸드득',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              : appBar,
      body: Column(
        children: [
          const SizedBox(height: 24),
          const Text(
            '오늘의 추천 메뉴를 확인해보세요!',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: PlatformUtils.getResponsivePadding(
                mobileHorizontal: 16,
                webHorizontal: 100,
              ),
              itemCount: menus.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final menu = menus[idx];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      menu['icon'] as IconData,
                      size: 36,
                      color: Colors.orange,
                    ),
                    title: Text(menu['name'] as String),
                    subtitle: Text(menu['desc'] as String),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Get.toNamed('/survey');
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: PlatformUtils.getResponsivePadding(
              mobileHorizontal: 16,
              webHorizontal: 100,
              vertical: 12,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.orange,
                ),
                child: const Text(
                  '추천 새로고침',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
