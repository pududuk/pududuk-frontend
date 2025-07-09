import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/platform_utils.dart';
import '../../../utils/env_config.dart';
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
                // Stack(추천 완료 메시지+지도 버튼) 가장 위에 배치 - 오늘의 메뉴가 없는 경우 숨김
                Obx(() {
                  if (controller.isNoMenuToday.value) {
                    return SizedBox.shrink(); // 오늘의 메뉴가 없으면 숨김
                  }

                  return Stack(
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
                            // 추천 상태에 따른 동적 텍스트
                            Obx(() {
                              if (controller.isLoading.value) {
                                return Column(
                                  children: [
                                    Text(
                                      '찾고 있는 중...',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      '당신을 위한 맞춤 메뉴를 찾고 있어요',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                );
                              } else {
                                return Column(
                                  children: [
                                    Text(
                                      '추천 완료!',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      '당신을 위한 맞춤 메뉴를 찾았어요',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                );
                              }
                            }),
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
                                    backgroundColor: AppColors.main.withAlpha(
                                      30,
                                    ),
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
                  );
                }),
                const SizedBox(height: 24),
                // 1~3위 메뉴 썸네일
                Obx(() {
                  final isOutside = controller.isOutside;
                  final isInside = controller.isInside;

                  // 오늘의 메뉴가 없는 경우 (사내 추천)
                  if (controller.isNoMenuToday.value) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 24),
                            Text(
                              '오늘의 사내 메뉴가\n아직 등록되지 않았습니다',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              '잠시 후 다시 시도해주세요',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (controller.isLoading.value ||
                      controller.topMenus.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(color: AppColors.main),
                      ),
                    );
                  }

                  if (isInside) {
                    // 사내 추천 - 상위 3개를 카드 형태로 표시
                    final top3 = controller.topMenus.take(3).toList();
                    return Column(
                      children:
                          top3.map((menu) {
                            final index = top3.indexOf(menu);
                            return Container(
                              margin: EdgeInsets.only(bottom: 12),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: index == 0 ? 4 : 2, // 1위는 더 강조
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            // 메뉴 이미지 추가
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.grey[300]!,
                                                  width: 1,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child:
                                                    (menu['image'] != null &&
                                                            (menu['image']
                                                                    as String)
                                                                .isNotEmpty)
                                                        ? Image(
                                                          image: getMenuImage(
                                                            menu['image']
                                                                as String?,
                                                          ),
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return Container(
                                                              color:
                                                                  Colors
                                                                      .grey[200],
                                                              child: Icon(
                                                                Icons
                                                                    .restaurant,
                                                                color:
                                                                    Colors
                                                                        .grey[600],
                                                                size: 24,
                                                              ),
                                                            );
                                                          },
                                                        )
                                                        : Container(
                                                          color:
                                                              Colors.grey[200],
                                                          child: Icon(
                                                            Icons.restaurant,
                                                            color:
                                                                Colors
                                                                    .grey[600],
                                                            size: 24,
                                                          ),
                                                        ),
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            // 순위 표시
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color:
                                                    index == 0
                                                        ? AppColors.main
                                                        : Colors.grey[400],
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Center(
                                                child:
                                                    index == 0
                                                        ? Icon(
                                                          Icons.emoji_events,
                                                          color: Colors.white,
                                                          size: 24,
                                                        )
                                                        : Text(
                                                          '${index + 1}',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${menu['store']} ${menu['corner']}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.access_time,
                                                        size: 14,
                                                        color: Colors.grey,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        '대기시간 ${menu['waiting_pred']}분',
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      SizedBox(width: 12),
                                                      Icon(
                                                        Icons.star,
                                                        size: 14,
                                                        color: Colors.amber,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        '${menu['score']}점',
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          '메뉴: ${menu['menu']}',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.main.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.chat_bubble_outline,
                                                size: 16,
                                                color: AppColors.main,
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  menu['comment'] ?? '',
                                                  style: TextStyle(
                                                    color: AppColors.main,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    );
                  } else {
                    // 사외 추천 - 기존 썸네일 방식
                    if (controller.topMenus.length < 3) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(
                            color: AppColors.main,
                          ),
                        ),
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 2위 (왼쪽)
                        _buildMenuThumbnail(
                          controller.topMenus[1],
                          1,
                          isOutside,
                        ),
                        // 1위 (가운데)
                        _buildMenuThumbnail(
                          controller.topMenus[0],
                          0,
                          isOutside,
                        ),
                        // 3위 (오른쪽)
                        _buildMenuThumbnail(
                          controller.topMenus[2],
                          2,
                          isOutside,
                        ),
                      ],
                    );
                  }
                }),
                const SizedBox(height: 24),
                // 다른 추천 메뉴 - 사내일 때는 4위 이후 표시
                Obx(() {
                  final isInside = controller.isInside;

                  if (isInside) {
                    // 사내 추천 - 4위 이후 메뉴 표시
                    final otherMenus =
                        controller.topMenus.length > 3
                            ? controller.topMenus.skip(3).toList()
                            : <Map<String, dynamic>>[];

                    if (otherMenus.isEmpty) return SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '다른 추천 메뉴',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 12),
                        ...otherMenus.where((menu) => menu != null).map((menu) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // 메뉴 이미지 추가
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child:
                                                (menu['image'] != null &&
                                                        (menu['image']
                                                                as String)
                                                            .isNotEmpty)
                                                    ? Image(
                                                      image: getMenuImage(
                                                        menu['image']
                                                            as String?,
                                                      ),
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Container(
                                                          color:
                                                              Colors.grey[200],
                                                          child: Icon(
                                                            Icons.restaurant,
                                                            color:
                                                                Colors
                                                                    .grey[600],
                                                            size: 20,
                                                          ),
                                                        );
                                                      },
                                                    )
                                                    : Container(
                                                      color: Colors.grey[200],
                                                      child: Icon(
                                                        Icons.restaurant,
                                                        color: Colors.grey[600],
                                                        size: 20,
                                                      ),
                                                    ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: AppColors.main,
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${menu['rank'] ?? '?'}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${menu['store'] ?? ''} ${menu['corner'] ?? ''}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 16,
                                                    color: Colors.grey,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '대기시간 ${menu['waiting_pred'] ?? 0}분',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Icon(
                                                    Icons.star,
                                                    size: 16,
                                                    color: Colors.amber,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '${menu['score'] ?? 0}점',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      '메뉴: ${menu['menu'] ?? '정보 없음'}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    if (menu['comment'] != null &&
                                        menu['comment']
                                            .toString()
                                            .isNotEmpty) ...[
                                      SizedBox(height: 8),
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.main.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.chat_bubble_outline,
                                              size: 16,
                                              color: AppColors.main,
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                menu['comment'].toString(),
                                                style: TextStyle(
                                                  color: AppColors.main,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  } else {
                    // 사외 추천 - 기존 방식
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '다른 추천 메뉴',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: controller.otherMenus.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 8),
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
                                              (menu['image'] as String)
                                                  .isNotEmpty)
                                          ? getMenuImage(
                                            menu['image'] as String?,
                                          )
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
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${menu['rank']}. ${menu['store'] ?? ''}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '${menu['menu'] ?? ''}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Text(
                                  '${menu['score']}점',
                                  style: TextStyle(fontSize: 13),
                                ),
                                trailing:
                                    (menu['price'] != null &&
                                            (menu['price'] as String)
                                                .isNotEmpty)
                                        ? Text(
                                          '${menu['price'] as String}',
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        )
                                        : null,
                                onTap:
                                    () => Get.toNamed(
                                      '/map_result',
                                      arguments: {
                                        'selectedMenuIndex': menu['rank'] - 1,
                                      },
                                    ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }
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
          mainAxisAlignment: MainAxisAlignment.start, // 상단 정렬로 통일
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 아바타 영역을 고정 높이로 설정 (1위가 가장 크므로 그 크기 기준)
            Container(
              height: 76, // 1위 아바타 크기(38*2) 기준으로 고정
              width: 76,
              alignment: Alignment.center,
              child: Stack(
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
            ),
            const SizedBox(height: 8),
            // 메뉴명 영역을 고정 높이로 설정
            Container(
              width: 80,
              height: 42,
              alignment: Alignment.topCenter,
              child: Text(
                menu['menu'] as String? ?? menu['name'] as String,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            // 간격을 완전히 제거하거나 최소화
            // 점수 영역을 고정 높이로 설정
            Container(
              height: 20, // 고정 높이
              alignment: Alignment.center,
              child: Text(
                '${menu['score']}점',
                style: TextStyle(
                  color: AppColors.main,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // 가격 영역을 고정 높이로 설정하여 모든 메뉴의 높이를 동일하게 유지
            Container(
              height: 20, // 고정 높이
              alignment: Alignment.center,
              child:
                  (menu['price'] != null &&
                          (menu['price'] as String).isNotEmpty)
                      ? Text(
                        menu['price'] as String,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
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
      // 웹에서 네이버 이미지는 백엔드 프록시를 통해 제공
      if (kIsWeb &&
          (imagePath.contains('search.pstatic.net') ||
              imagePath.contains('ldb-phinf.pstatic.net'))) {
        final proxyUrl =
            '${EnvConfig.apiBaseUrl}/proxy/image?url=${Uri.encodeComponent(imagePath)}';
        print('웹에서 네이버 이미지 프록시 사용: $proxyUrl');
        return NetworkImage(proxyUrl);
      }
      return NetworkImage(imagePath);
    } else {
      return AssetImage(imagePath);
    }
  }
}
