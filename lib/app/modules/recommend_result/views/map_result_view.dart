import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/env_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../controllers/recommend_result_controller.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'naver_map_web.dart';

class MapResultView extends StatefulWidget {
  const MapResultView({Key? key}) : super(key: key);

  @override
  State<MapResultView> createState() => _MapResultViewState();
}

class _MapResultViewState extends State<MapResultView> {
  final controller = Get.find<RecommendResultController>();
  String? currentOpenInfoWindowId; // 현재 열린 정보창 ID 추적
  late NaverMapController mapController; // 지도 컨트롤러 저장
  bool isMapReady = false; // 지도 준비 상태

  // 버튼 애니메이션 상태
  bool isZoomInPressed = false;
  bool isZoomOutPressed = false;

  // 검색 기능
  final TextEditingController searchController = TextEditingController();

  // 선택된 메뉴 인덱스 (추천 결과 페이지에서 전달받음)
  int? selectedMenuIndex;

  @override
  void initState() {
    super.initState();
    // 전달받은 arguments 처리
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments.containsKey('selectedMenuIndex')) {
      selectedMenuIndex = arguments['selectedMenuIndex'] as int?;
      print('선택된 메뉴 인덱스: $selectedMenuIndex');
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // 커스텀 마커 아이콘 생성 함수
  Future<NOverlayImage> createCustomMarkerIcon(Color color, int rank) async {
    print('createCustomMarkerIcon 호출됨 - rank: $rank, color: $color');

    // 검색 중일 때 4를 3으로 강제 변경 (임시 해결책)
    int displayRank = rank;
    if (controller.searchQuery.value.isNotEmpty && rank == 4) {
      displayRank = 3;
      print('검색 중 rank 4를 3으로 강제 변경: $rank -> $displayRank');
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(60, 60);

    // 마커 배경 (둥근 원)
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final borderPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    // 원 그리기
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 25, paint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 25, borderPaint);

    // 순위 텍스트 그리기
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$displayRank',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final uint8List = byteData!.buffer.asUint8List();

    return NOverlayImage.fromByteArray(uint8List);
  }

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
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                '마곡 맛집 랭킹',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
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
                automaticallyImplyLeading: !kIsWeb,
                iconTheme: const IconThemeData(color: Colors.white),
                centerTitle: kIsWeb,
                leading:
                    kIsWeb
                        ? Padding(
                          padding: EdgeInsets.only(left: 24),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        )
                        : null,
                title: Padding(
                  padding: EdgeInsets.symmetric(horizontal: kIsWeb ? 40 : 0),
                  child: Row(
                    children: const [
                      Icon(Icons.restaurant_menu, color: Colors.white),
                      SizedBox(width: 8),
                      Text('마곡 맛집 랭킹', style: TextStyle(color: Colors.white)),
                      Spacer(),
                    ],
                  ),
                ),
                actions:
                    kIsWeb
                        ? [
                          Padding(
                            padding: EdgeInsets.only(right: 24),
                            child: SizedBox.shrink(),
                          ),
                        ]
                        : [],
              ),
      body: GestureDetector(
        onTap: () => _closeCurrentInfoWindow(),
        child: Column(
          children: [
            // 상단 고정 영역 (검색창 + 지도)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 검색창 (GetX 반응형)
                  Obx(
                    () => TextField(
                      controller: searchController,
                      onChanged: (value) {
                        print('=== 검색어 변경 시작 ===');
                        print('입력값: "$value"');

                        // GetX 컨트롤러 업데이트 (즉시 반영)
                        controller.updateSearchQuery(value);

                        print(
                          '변경된 searchQuery: "${controller.searchQuery.value}"',
                        );

                        // 검색어 변경 시 마커 즉시 업데이트 (지연 없음)
                        if (isMapReady && !kIsWeb) {
                          print('마커 즉시 업데이트 시작');
                          _forceUpdateMarkers();

                          // 검색 결과가 있으면 1위로 카메라 이동 및 정보창 표시
                          if (value.isNotEmpty) {
                            Future.delayed(Duration(milliseconds: 150), () {
                              _moveToFirstSearchResult();
                            });
                          }
                        }
                        print('=== 검색어 변경 끝 ===');
                      },
                      decoration: InputDecoration(
                        hintText: '가게 검색',
                        prefixIcon: Icon(Icons.search),
                        suffixIcon:
                            controller.searchQuery.value.isNotEmpty
                                ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    print('검색어 지우기 버튼 클릭');
                                    searchController.clear();
                                    controller.clearSearch();

                                    // 검색어 지우기 시 마커 즉시 업데이트
                                    if (isMapReady && !kIsWeb) {
                                      _forceUpdateMarkers();
                                    }
                                  },
                                )
                                : null,
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 네이버 지도 (고정 영역)
                  Obx(() {
                    // 1등 메뉴 위치 가져오기
                    final firstMenu =
                        controller.topMenus.isNotEmpty
                            ? controller.topMenus[0]
                            : null;
                    final centerLat =
                        (firstMenu?['latitude'] as num?)?.toDouble() ?? 37.5665;
                    final centerLng =
                        (firstMenu?['longitude'] as num?)?.toDouble() ??
                        126.9780;

                    return Container(
                      height: 250,
                      child:
                          kIsWeb
                              ? // 웹에서는 네이버 지도 웹 API 사용
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: NaverMapWeb(
                                  latitude: centerLat,
                                  longitude: centerLng,
                                  markers:
                                      controller.topMenus.map((menu) {
                                        return {
                                          'latitude':
                                              (menu['latitude'] as num?)
                                                  ?.toDouble() ??
                                              0.0,
                                          'longitude':
                                              (menu['longitude'] as num?)
                                                  ?.toDouble() ??
                                              0.0,
                                          'name': menu['name'] ?? '',
                                          'score': menu['score'] ?? 0,
                                          'price': menu['price'] ?? '',
                                        };
                                      }).toList(),
                                  onMarkerTap: (index) {
                                    // 마커 클릭 시 처리
                                    print('마커 클릭: $index');
                                  },
                                ),
                              )
                              : // 모바일에서는 네이버 지도 표시
                              Stack(
                                children: [
                                  // 지도
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child:
                                        kIsWeb
                                            ? Container(
                                              color: Colors.grey[300],
                                              child: Center(
                                                child: Text('지도는 모바일에서만 지원됩니다'),
                                              ),
                                            )
                                            : NaverMap(
                                              options: NaverMapViewOptions(
                                                initialCameraPosition:
                                                    NCameraPosition(
                                                      target: NLatLng(
                                                        centerLat,
                                                        centerLng,
                                                      ),
                                                      zoom: 17,
                                                    ),
                                                mapType: NMapType.basic,
                                                indoorEnable: false,
                                                // 지도 상호작용 활성화
                                                scrollGesturesEnable: true,
                                                zoomGesturesEnable: true,
                                                tiltGesturesEnable: true,
                                                rotationGesturesEnable: true,
                                                stopGesturesEnable: true,
                                                consumeSymbolTapEvents: false,
                                                // 컨트롤 버튼
                                                scaleBarEnable: true,
                                                indoorLevelPickerEnable: false,
                                                locationButtonEnable: false,
                                                logoClickEnable: false,
                                              ),
                                              onMapReady: (naverMapController) {
                                                mapController =
                                                    naverMapController; // 컨트롤러 저장
                                                isMapReady = true; // 지도 준비 완료

                                                // 웹이 아닐 때만 지도 기능 실행
                                                if (!kIsWeb) {
                                                  // 모든 메뉴 위치에 마커 추가
                                                  _addMarkersToMap();

                                                  // 선택된 메뉴가 있으면 해당 메뉴로 이동, 없으면 1위 메뉴로 이동
                                                  if (selectedMenuIndex !=
                                                      null) {
                                                    _showSelectedMenuInfoWindow(
                                                      selectedMenuIndex!,
                                                    );
                                                  } else {
                                                    _showFirstMenuInfoWindow();
                                                  }
                                                }
                                              },
                                              onMapTapped: (point, latLng) {
                                                // 지도 클릭 시 정보창 닫기
                                                _closeCurrentInfoWindow();
                                              },
                                            ),
                                  ),
                                  // 커스텀 줌 버튼들
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: GestureDetector(
                                      onTap: () {}, // 이벤트 전파 방지
                                      child: Column(
                                        children: [
                                          // 줌 인 버튼
                                          GestureDetector(
                                            onTapDown:
                                                (_) => setState(
                                                  () => isZoomInPressed = true,
                                                ),
                                            onTapUp:
                                                (_) => setState(
                                                  () => isZoomInPressed = false,
                                                ),
                                            onTapCancel:
                                                () => setState(
                                                  () => isZoomInPressed = false,
                                                ),
                                            onTap: () async {
                                              if (isMapReady) {
                                                // 정보창 닫기
                                                await _closeCurrentInfoWindow();
                                                // 현재 카메라 위치 가져오기
                                                final cameraPosition =
                                                    await mapController
                                                        .getCameraPosition();
                                                // 줌 인 (현재 줌 레벨 + 1)
                                                await mapController
                                                    .updateCamera(
                                                      NCameraUpdate.withParams(
                                                        target:
                                                            cameraPosition
                                                                .target,
                                                        zoom:
                                                            cameraPosition
                                                                .zoom +
                                                            1,
                                                      ),
                                                    );
                                              }
                                            },
                                            child: AnimatedContainer(
                                              duration: Duration(
                                                milliseconds: 100,
                                              ),
                                              width: 40,
                                              height: 40,
                                              transform:
                                                  Matrix4.identity()..scale(
                                                    isZoomInPressed
                                                        ? 0.95
                                                        : 1.0,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius:
                                                        isZoomInPressed ? 2 : 4,
                                                    offset: Offset(
                                                      0,
                                                      isZoomInPressed ? 1 : 2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                Icons.add,
                                                size: 20,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          // 줌 아웃 버튼
                                          GestureDetector(
                                            onTapDown:
                                                (_) => setState(
                                                  () => isZoomOutPressed = true,
                                                ),
                                            onTapUp:
                                                (_) => setState(
                                                  () =>
                                                      isZoomOutPressed = false,
                                                ),
                                            onTapCancel:
                                                () => setState(
                                                  () =>
                                                      isZoomOutPressed = false,
                                                ),
                                            onTap: () async {
                                              if (isMapReady) {
                                                // 정보창 닫기
                                                await _closeCurrentInfoWindow();
                                                // 현재 카메라 위치 가져오기
                                                final cameraPosition =
                                                    await mapController
                                                        .getCameraPosition();
                                                // 줌 아웃 (현재 줌 레벨 - 1)
                                                await mapController
                                                    .updateCamera(
                                                      NCameraUpdate.withParams(
                                                        target:
                                                            cameraPosition
                                                                .target,
                                                        zoom:
                                                            cameraPosition
                                                                .zoom -
                                                            1,
                                                      ),
                                                    );
                                              }
                                            },
                                            child: AnimatedContainer(
                                              duration: Duration(
                                                milliseconds: 100,
                                              ),
                                              width: 40,
                                              height: 40,
                                              transform:
                                                  Matrix4.identity()..scale(
                                                    isZoomOutPressed
                                                        ? 0.95
                                                        : 1.0,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius:
                                                        isZoomOutPressed
                                                            ? 2
                                                            : 4,
                                                    offset: Offset(
                                                      0,
                                                      isZoomOutPressed ? 1 : 2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                Icons.remove,
                                                size: 20,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                    );
                  }),
                ],
              ),
            ),
            // 하단 스크롤 가능 영역 (카드 리스트)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 랭킹 카드 (top3 - 검색 필터링 적용)
                    Obx(() {
                      final filteredTop3 = controller.filteredTopMenus.toList();
                      if (filteredTop3.isEmpty &&
                          controller.searchQuery.value.isNotEmpty) {
                        return Container(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            '검색 결과가 없습니다.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return Column(
                        children:
                            filteredTop3.asMap().entries.map((entry) {
                              final item = entry.value;
                              // 검색 결과에서의 새로운 순위 적용 (1, 2, 3위)
                              final itemWithRank = Map<String, dynamic>.from(
                                item,
                              );
                              itemWithRank['rank'] = entry.key + 1; // 검색 결과 순위
                              itemWithRank['originalRank'] =
                                  item['originalRank']; // 원래 순위 보존
                              return _buildRankCard(itemWithRank);
                            }).toList(),
                      );
                    }),
                    const SizedBox(height: 16),
                    // 기타 순위 (otherMenus)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '다른 추천 메뉴',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      final filteredOthers = getFilteredOtherMenus();
                      return Column(
                        children:
                            filteredOthers.asMap().entries.map((entry) {
                              final item = entry.value;
                              // 검색 결과에서의 새로운 순위 적용 (4위부터 시작)
                              final itemWithRank = Map<String, dynamic>.from(
                                item,
                              );
                              itemWithRank['rank'] =
                                  entry.key + 4; // 검색 결과 순위 (4위부터)
                              itemWithRank['originalRank'] =
                                  item['originalRank']; // 원래 순위 보존
                              return _buildOtherCard(itemWithRank);
                            }).toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 검색 필터링 함수 (원래 순위 정보 포함)
  List<Map> getFilteredTopMenus() {
    if (controller.searchQuery.value.isEmpty) {
      return controller.topMenus.take(3).toList().asMap().entries.map((entry) {
        final item = Map<String, dynamic>.from(entry.value);
        item['originalRank'] = entry.key + 1;
        return item;
      }).toList();
    }

    final filtered = <Map>[];
    for (
      int i = 0;
      i < controller.topMenus.length && filtered.length < 3;
      i++
    ) {
      final menu = controller.topMenus[i];
      if ((menu['name'] as String? ?? '').toLowerCase().contains(
        controller.searchQuery.value.toLowerCase(),
      )) {
        final item = Map<String, dynamic>.from(menu);
        item['originalRank'] = i + 1;
        filtered.add(item);
      }
    }
    return filtered;
  }

  List<Map> getFilteredOtherMenus() {
    if (controller.searchQuery.value.isEmpty) {
      return controller.otherMenus.asMap().entries.map((entry) {
        final item = Map<String, dynamic>.from(entry.value);
        item['originalRank'] = entry.key + 4; // 4위부터 시작
        return item;
      }).toList();
    }

    final filtered = <Map>[];
    for (int i = 0; i < controller.otherMenus.length; i++) {
      final menu = controller.otherMenus[i];
      if ((menu['name'] as String? ?? '').toLowerCase().contains(
        controller.searchQuery.value.toLowerCase(),
      )) {
        final item = Map<String, dynamic>.from(menu);
        item['originalRank'] = i + 4; // 4위부터 시작
        filtered.add(item);
      }
    }
    return filtered;
  }

  // 1위 메뉴 정보창 자동 표시 함수
  Future<void> _showFirstMenuInfoWindow() async {
    // 잠시 대기 후 정보창 표시 (마커가 완전히 로드된 후)
    await Future.delayed(Duration(milliseconds: 500));

    if (controller.topMenus.isNotEmpty && isMapReady) {
      final firstMenu = controller.topMenus[0];

      try {
        final latValue = firstMenu['latitude'];
        final lngValue = firstMenu['longitude'];

        if (latValue != null && lngValue != null) {
          // 안전한 타입 변환 - String이나 num 모두 처리
          double? lat;
          double? lng;

          try {
            if (latValue is String) {
              lat = double.tryParse(latValue);
            } else if (latValue is num) {
              lat = latValue.toDouble();
            }

            if (lngValue is String) {
              lng = double.tryParse(lngValue);
            } else if (lngValue is num) {
              lng = lngValue.toDouble();
            }
          } catch (e) {
            print('좌표 변환 실패: $e');
            return;
          }

          if (lat != null &&
              lng != null &&
              !lat.isNaN &&
              !lat.isInfinite &&
              !lng.isNaN &&
              !lng.isInfinite) {
            // 1위 메뉴 정보창 생성 및 표시
            final infoText =
                '1위. ${firstMenu['name']}\n${firstMenu['score']}점${firstMenu['price'] != null && (firstMenu['price'] as String).isNotEmpty ? ' • ${firstMenu['price']}' : ''}';

            final infoWindow = NInfoWindow.onMap(
              id: 'info_0',
              text: infoText,
              position: NLatLng(lat + 0.0001, lng), // 마커 위에 표시
            );

            // 정보창 클릭 이벤트 설정 (클릭 시 사라지도록)
            infoWindow.setOnTapListener((NInfoWindow infoWindow) async {
              await mapController.deleteOverlay(
                NOverlayInfo(type: NOverlayType.infoWindow, id: 'info_0'),
              );
              currentOpenInfoWindowId = null;
            });

            await mapController.addOverlay(infoWindow);
            currentOpenInfoWindowId = 'info_0';
          }
        }
      } catch (e) {
        print('1위 메뉴 정보창 표시 실패: $e');
      }
    }
  }

  // 선택된 메뉴 정보창 표시 및 카메라 이동 함수
  Future<void> _showSelectedMenuInfoWindow(int menuIndex) async {
    await Future.delayed(Duration(milliseconds: 500));

    if (controller.topMenus.length > menuIndex && isMapReady) {
      final selectedMenu = controller.topMenus[menuIndex];
      print('선택된 메뉴로 이동: ${selectedMenu['name']} (인덱스: $menuIndex)');

      try {
        final latValue = selectedMenu['latitude'];
        final lngValue = selectedMenu['longitude'];

        if (latValue != null && lngValue != null) {
          // 안전한 타입 변환 - String이나 num 모두 처리
          double? lat;
          double? lng;

          try {
            if (latValue is String) {
              lat = double.tryParse(latValue);
            } else if (latValue is num) {
              lat = latValue.toDouble();
            }

            if (lngValue is String) {
              lng = double.tryParse(lngValue);
            } else if (lngValue is num) {
              lng = lngValue.toDouble();
            }
          } catch (e) {
            print('좌표 변환 실패: $e');
            return;
          }

          if (lat != null &&
              lng != null &&
              !lat.isNaN &&
              !lat.isInfinite &&
              !lng.isNaN &&
              !lng.isInfinite) {
            // 카메라를 선택된 메뉴 위치로 이동
            final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
              target: NLatLng(lat, lng),
              zoom: 17,
            );
            await mapController.updateCamera(cameraUpdate);

            // 짧은 지연 후 정보창 표시
            await Future.delayed(Duration(milliseconds: 300));

            // 선택된 메뉴 정보창 생성 및 표시
            final rank = menuIndex + 1;
            final infoText =
                '$rank위. ${selectedMenu['name']}\n${selectedMenu['score']}점${selectedMenu['price'] != null && (selectedMenu['price'] as String).isNotEmpty ? ' • ${selectedMenu['price']}' : ''}';

            final infoWindow = NInfoWindow.onMap(
              id: 'info_$menuIndex',
              text: infoText,
              position: NLatLng(lat + 0.0001, lng),
            );

            infoWindow.setOnTapListener((NInfoWindow infoWindow) async {
              await mapController.deleteOverlay(
                NOverlayInfo(
                  type: NOverlayType.infoWindow,
                  id: 'info_$menuIndex',
                ),
              );
              currentOpenInfoWindowId = null;
            });

            await mapController.addOverlay(infoWindow);
            currentOpenInfoWindowId = 'info_$menuIndex';

            print('선택된 메뉴 정보창 표시 완료: ${selectedMenu['name']}');
          }
        }
      } catch (e) {
        print('선택된 메뉴 정보창 표시 실패: $e');
      }
    }
  }

  // 마커 강제 업데이트 함수
  Future<void> _forceUpdateMarkers() async {
    print('=== 마커 강제 업데이트 시작 ===');
    if (!isMapReady || kIsWeb) return;

    try {
      // 1. 모든 오버레이 완전 제거 (빠른 제거)
      await _clearAllMarkers();

      // 2. 정보창 닫기
      await _closeCurrentInfoWindow();

      // 3. 최소 대기 시간
      await Future.delayed(Duration(milliseconds: 100));

      if (controller.searchQuery.value.isEmpty) {
        print('검색어 없음 - 원본 마커 추가');
        await _addMarkersToMap();
        await _showFirstMenuInfoWindow();
      } else {
        print('검색어 있음 - 필터링된 마커 추가');
        await _addFilteredMarkersToMap();
        await _showFirstFilteredMenuInfoWindow();
      }
    } catch (e) {
      print('마커 강제 업데이트 실패: $e');
    }
    print('=== 마커 강제 업데이트 완료 ===');
  }

  // 검색에 따른 마커 업데이트 함수
  Future<void> _updateMarkersForSearch() async {
    print(
      '_updateMarkersForSearch 호출됨, isMapReady=$isMapReady, searchQuery="${controller.searchQuery.value}"',
    );
    if (!isMapReady) return;

    try {
      // 기존 마커들 모두 제거
      await _clearAllMarkers();

      // 정보창도 닫기
      await _closeCurrentInfoWindow();

      if (controller.searchQuery.value.isEmpty) {
        print('검색어 없음 - 모든 마커 추가');
        // 검색어가 없으면 모든 마커 다시 추가
        await _addMarkersToMap();
        // 1위 메뉴 정보창 다시 표시
        await _showFirstMenuInfoWindow();
      } else {
        print('검색어 있음 - 필터링된 마커 추가');
        // 검색 결과에 맞는 마커만 추가
        await _addFilteredMarkersToMap();
        // 검색 결과 1위 정보창 표시
        await _showFirstFilteredMenuInfoWindow();
      }
    } catch (e) {
      print('마커 업데이트 실패: $e');
    }
  }

  // 모든 마커 제거 함수
  Future<void> _clearAllMarkers() async {
    try {
      print('=== 모든 마커 제거 시작 ===');

      // 방법 1: 모든 오버레이 제거 시도
      try {
        await mapController.clearOverlays();
        print('모든 오버레이 제거 성공');
      } catch (e) {
        print('모든 오버레이 제거 실패: $e');
      }

      // 방법 2: 개별 마커 ID로 제거 시도 (범위를 매우 크게 늘림)
      for (int i = 0; i < 100; i++) {
        // 일반 마커 제거
        try {
          await mapController.deleteOverlay(
            NOverlayInfo(type: NOverlayType.marker, id: 'menu_$i'),
          );
          print('마커 제거 성공: menu_$i');
        } catch (e) {
          // 마커가 없으면 무시
        }

        // 검색 마커 제거
        try {
          await mapController.deleteOverlay(
            NOverlayInfo(type: NOverlayType.marker, id: 'search_$i'),
          );
          print('검색 마커 제거 성공: search_$i');
        } catch (e) {
          // 마커가 없으면 무시
        }
      }

      // 방법 3: 4번 마커 특별 집중 제거 시도 (여러 번 반복)
      final problematicIds = ['menu_3', 'menu_4', 'menu_5'];

      for (int attempt = 0; attempt < 5; attempt++) {
        print('4번 마커 특별 제거 시도 ${attempt + 1}/5');
        for (String id in problematicIds) {
          try {
            await mapController.deleteOverlay(
              NOverlayInfo(type: NOverlayType.marker, id: id),
            );
            print('특별 마커 제거 성공: $id (시도 ${attempt + 1})');
          } catch (e) {
            // 마커가 없으면 무시
          }
        }
        await Future.delayed(Duration(milliseconds: 50));
      }

      // 추가 가능한 ID들도 제거
      final additionalIds = [
        'marker_3',
        'marker_4',
        'marker_5',
        'restaurant_3',
        'restaurant_4',
        'restaurant_5',
        'food_3',
        'food_4',
        'food_5',
        'location_3',
        'location_4',
        'location_5',
        'rank_4',
        'top_4',
        'item_4',
        'point_4',
      ];

      for (String id in additionalIds) {
        try {
          await mapController.deleteOverlay(
            NOverlayInfo(type: NOverlayType.marker, id: id),
          );
          print('추가 마커 제거 성공: $id');
        } catch (e) {
          // 마커가 없으면 무시
        }
      }

      // 방법 4: 정보창도 모두 제거
      for (int i = 0; i < 50; i++) {
        try {
          await mapController.deleteOverlay(
            NOverlayInfo(type: NOverlayType.infoWindow, id: 'info_$i'),
          );
        } catch (e) {
          // 정보창이 없으면 무시
        }
      }

      print('=== 모든 마커 제거 완료 ===');
    } catch (e) {
      print('마커 제거 실패: $e');
    }
  }

  // 필터링된 마커 추가 함수
  Future<void> _addFilteredMarkersToMap() async {
    final filteredTop3 = controller.filteredTopMenus.toList();
    final filteredOthers = getFilteredOtherMenus();
    final allFiltered = [...filteredTop3, ...filteredOthers];
    print('_addFilteredMarkersToMap 호출됨, 필터링된 메뉴 수=${allFiltered.length}');

    for (
      int filteredIndex = 0;
      filteredIndex < allFiltered.length;
      filteredIndex++
    ) {
      final menu = allFiltered[filteredIndex];
      print('필터링된 인덱스: $filteredIndex, 메뉴: ${menu['name']}');

      // 위치 데이터 안전성 검증
      double? lat;
      double? lng;

      try {
        final latValue = menu['latitude'];
        final lngValue = menu['longitude'];

        if (latValue != null && lngValue != null) {
          // 안전한 타입 변환 - String이나 num 모두 처리
          double? lat;
          double? lng;

          try {
            if (latValue is String) {
              lat = double.tryParse(latValue);
            } else if (latValue is num) {
              lat = latValue.toDouble();
            }

            if (lngValue is String) {
              lng = double.tryParse(lngValue);
            } else if (lngValue is num) {
              lng = lngValue.toDouble();
            }
          } catch (e) {
            print('좌표 변환 실패: $e');
            continue;
          }

          if (lat != null &&
              lng != null &&
              !lat.isNaN &&
              !lat.isInfinite &&
              !lng.isNaN &&
              !lng.isInfinite) {
            // 검색 결과에서의 새로운 순위에 따른 마커 색상
            Color markerColor;
            if (filteredIndex == 0) {
              markerColor = Colors.red; // 검색 결과 1위
            } else if (filteredIndex == 1) {
              markerColor = Colors.orange; // 검색 결과 2위
            } else if (filteredIndex == 2) {
              markerColor = Colors.yellow; // 검색 결과 3위
            } else {
              final randomColors = [
                Colors.blue,
                Colors.green,
                Colors.purple,
                Colors.teal,
                Colors.indigo,
                Colors.pink,
                Colors.cyan,
                Colors.lime,
                Colors.amber,
                Colors.deepOrange,
                Colors.lightBlue,
                Colors.lightGreen,
                Colors.deepPurple,
                Colors.brown,
                Colors.blueGrey,
              ];
              markerColor =
                  randomColors[(filteredIndex - 3) % randomColors.length];
            }

            // 마커 순위를 필터링된 인덱스 기준으로 설정 (1, 2, 3...)
            final markerRank = filteredIndex + 1; // 필터링된 결과에서의 순위
            print('마커 순위 설정: $markerRank (필터링된 인덱스: $filteredIndex)');

            final customIcon = await createCustomMarkerIcon(
              markerColor,
              markerRank,
            );

            // 검색 상태에 따라 다른 ID 사용
            final markerId = 'search_$filteredIndex';
            print('검색 마커 생성 - ID: $markerId, 순위: $markerRank');

            final marker = NMarker(
              id: markerId,
              position: NLatLng(lat, lng),
              size: const NSize(40, 40),
              icon: customIcon,
            );

            mapController.addOverlay(marker);

            // 마커 클릭 이벤트 설정
            marker.setOnTapListener((NMarker marker) async {
              if (currentOpenInfoWindowId != null) {
                try {
                  await mapController.deleteOverlay(
                    NOverlayInfo(
                      type: NOverlayType.infoWindow,
                      id: currentOpenInfoWindowId!,
                    ),
                  );
                } catch (e) {}
              }

              // 검색 상태에 따라 순위 표시 조정
              final displayRank =
                  filteredIndex + 1; // 필터링된 결과에서의 순위 (1, 2, 3...)
              final infoText =
                  '$displayRank위. ${menu['name']}\n${menu['score']}점${menu['price'] != null && (menu['price'] as String).isNotEmpty ? ' • ${menu['price']}' : ''}';
              final infoWindow = NInfoWindow.onMap(
                id: 'info_$filteredIndex',
                text: infoText,
                position: NLatLng(lat! + 0.0001, lng!),
              );

              infoWindow.setOnTapListener((NInfoWindow infoWindow) async {
                await mapController.deleteOverlay(
                  NOverlayInfo(
                    type: NOverlayType.infoWindow,
                    id: 'info_$filteredIndex',
                  ),
                );
                currentOpenInfoWindowId = null;
              });

              await mapController.addOverlay(infoWindow);
              currentOpenInfoWindowId = 'info_$filteredIndex';
            });
          }
        }
      } catch (e) {
        print('필터링된 마커 생성 실패: $e');
        continue;
      }
    }
  }

  // 검색 결과 1위 정보창 표시 함수
  Future<void> _showFirstFilteredMenuInfoWindow() async {
    await Future.delayed(Duration(milliseconds: 500));

    final filteredTop3 = controller.filteredTopMenus.toList();
    if (filteredTop3.isNotEmpty && isMapReady) {
      final firstMenu = filteredTop3[0];

      try {
        final latValue = firstMenu['latitude'];
        final lngValue = firstMenu['longitude'];

        if (latValue != null && lngValue != null) {
          // 안전한 타입 변환 - String이나 num 모두 처리
          double? lat;
          double? lng;

          try {
            if (latValue is String) {
              lat = double.tryParse(latValue);
            } else if (latValue is num) {
              lat = latValue.toDouble();
            }

            if (lngValue is String) {
              lng = double.tryParse(lngValue);
            } else if (lngValue is num) {
              lng = lngValue.toDouble();
            }
          } catch (e) {
            print('좌표 변환 실패: $e');
            return;
          }

          if (lat != null &&
              lng != null &&
              !lat.isNaN &&
              !lat.isInfinite &&
              !lng.isNaN &&
              !lng.isInfinite) {
            final infoText =
                '1위. ${firstMenu['name']}\n${firstMenu['score']}점${firstMenu['price'] != null && (firstMenu['price'] as String).isNotEmpty ? ' • ${firstMenu['price']}' : ''}';

            final infoWindow = NInfoWindow.onMap(
              id: 'info_0',
              text: infoText,
              position: NLatLng(lat + 0.0001, lng),
            );

            infoWindow.setOnTapListener((NInfoWindow infoWindow) async {
              await mapController.deleteOverlay(
                NOverlayInfo(type: NOverlayType.infoWindow, id: 'info_0'),
              );
              currentOpenInfoWindowId = null;
            });

            await mapController.addOverlay(infoWindow);
            currentOpenInfoWindowId = 'info_0';
          }
        }
      } catch (e) {
        print('검색 결과 1위 정보창 표시 실패: $e');
      }
    }
  }

  // 검색 결과 1위로 카메라 이동 및 정보창 표시
  Future<void> _moveToFirstSearchResult() async {
    final filteredTop3 = controller.filteredTopMenus.toList();
    if (filteredTop3.isEmpty || !isMapReady) return;

    final firstMenu = filteredTop3[0];
    print('검색 결과 1위로 이동: ${firstMenu['name']}');

    try {
      final latValue = firstMenu['latitude'];
      final lngValue = firstMenu['longitude'];

      if (latValue != null && lngValue != null) {
        // 안전한 타입 변환 - String이나 num 모두 처리
        double? lat;
        double? lng;

        try {
          if (latValue is String) {
            lat = double.tryParse(latValue);
          } else if (latValue is num) {
            lat = latValue.toDouble();
          }

          if (lngValue is String) {
            lng = double.tryParse(lngValue);
          } else if (lngValue is num) {
            lng = lngValue.toDouble();
          }
        } catch (e) {
          print('좌표 변환 실패: $e');
          return;
        }

        if (lat != null &&
            lng != null &&
            !lat.isNaN &&
            !lat.isInfinite &&
            !lng.isNaN &&
            !lng.isInfinite) {
          // 기존 정보창 닫기
          if (currentOpenInfoWindowId != null) {
            try {
              await mapController.deleteOverlay(
                NOverlayInfo(
                  type: NOverlayType.infoWindow,
                  id: currentOpenInfoWindowId!,
                ),
              );
            } catch (e) {
              // 이미 삭제된 경우 무시
            }
          }

          // 카메라 이동
          final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
            target: NLatLng(lat, lng),
            zoom: 17,
          );
          await mapController.updateCamera(cameraUpdate);

          // 짧은 지연 후 정보창 표시
          await Future.delayed(Duration(milliseconds: 300));

          final infoText =
              '1위. ${firstMenu['name']}\n${firstMenu['score']}점${firstMenu['price'] != null && (firstMenu['price'] as String).isNotEmpty ? ' • ${firstMenu['price']}' : ''}';

          final infoWindow = NInfoWindow.onMap(
            id: 'info_0',
            text: infoText,
            position: NLatLng(lat + 0.0001, lng),
          );

          infoWindow.setOnTapListener((NInfoWindow infoWindow) async {
            await mapController.deleteOverlay(
              NOverlayInfo(type: NOverlayType.infoWindow, id: 'info_0'),
            );
            currentOpenInfoWindowId = null;
          });

          await mapController.addOverlay(infoWindow);
          currentOpenInfoWindowId = 'info_0';

          print('검색 결과 1위로 카메라 이동 및 정보창 표시 완료');
        }
      }
    } catch (e) {
      print('검색 결과 1위로 이동 실패: $e');
    }
  }

  // 마커 추가 함수
  Future<void> _addMarkersToMap() async {
    // 검색 중일 때는 원본 마커 생성하지 않음
    if (controller.searchQuery.value.isNotEmpty) {
      print('검색 중이므로 원본 마커 생성 건너뜀');
      return;
    }

    print('원본 마커 생성 시작');
    for (int i = 0; i < controller.topMenus.length; i++) {
      final menu = controller.topMenus[i];

      // 위치 데이터 안전성 검증
      double? lat;
      double? lng;

      try {
        final latValue = menu['latitude'];
        final lngValue = menu['longitude'];

        if (latValue != null && lngValue != null) {
          // 안전한 타입 변환 - String이나 num 모두 처리
          double? lat;
          double? lng;

          try {
            if (latValue is String) {
              lat = double.tryParse(latValue);
            } else if (latValue is num) {
              lat = latValue.toDouble();
            }

            if (lngValue is String) {
              lng = double.tryParse(lngValue);
            } else if (lngValue is num) {
              lng = lngValue.toDouble();
            }
          } catch (e) {
            print('좌표 변환 실패: $e');
            continue;
          }

          if (lat != null &&
              lng != null &&
              !lat.isNaN &&
              !lat.isInfinite &&
              !lng.isNaN &&
              !lng.isInfinite) {
            // 순위에 따른 마커 색상 설정
            Color markerColor;
            if (i == 0) {
              markerColor = Colors.red; // 1위 - 빨간색 (고정)
            } else if (i == 1) {
              markerColor = Colors.orange; // 2위 - 주황색 (고정)
            } else if (i == 2) {
              markerColor = Colors.yellow; // 3위 - 노란색 (고정)
            } else {
              // 4등부터는 다양한 색상 중 순위에 따라 고정된 색상 선택
              final randomColors = [
                Colors.blue,
                Colors.green,
                Colors.purple,
                Colors.teal,
                Colors.indigo,
                Colors.pink,
                Colors.cyan,
                Colors.lime,
                Colors.amber,
                Colors.deepOrange,
                Colors.lightBlue,
                Colors.lightGreen,
                Colors.deepPurple,
                Colors.brown,
                Colors.blueGrey,
              ];
              markerColor = randomColors[(i - 3) % randomColors.length];
            }

            // 검색 중일 때는 원본 마커 생성하지 않음 (이중 체크)
            if (controller.searchQuery.value.isNotEmpty) {
              print('검색 중이므로 원본 마커($i) 생성 건너뜀');
              continue;
            }

            // 커스텀 마커 아이콘 생성 (원본 순서로 1, 2, 3...)
            final markerNumber = i + 1; // 원본 순위
            print('=== 원본 마커 생성 ===');
            print('인덱스: $i');
            print('마커번호: $markerNumber (원본 순위)');
            print('메뉴: ${menu['name']}');
            print('마커색상: $markerColor');

            final customIcon = await createCustomMarkerIcon(
              markerColor,
              markerNumber,
            );
            print('원본 마커 아이콘 생성 완료 - 번호: $markerNumber');
            print('=== 원본 마커 생성 완료 ===');

            // 커스텀 마커 생성
            final marker = NMarker(
              id: 'menu_$i',
              position: NLatLng(lat, lng),
              size: const NSize(40, 40),
              icon: customIcon,
            );

            mapController.addOverlay(marker);

            // 마커 클릭 이벤트 설정
            marker.setOnTapListener((NMarker marker) async {
              // 이전 정보창이 열려있으면 닫기
              if (currentOpenInfoWindowId != null) {
                try {
                  await mapController.deleteOverlay(
                    NOverlayInfo(
                      type: NOverlayType.infoWindow,
                      id: currentOpenInfoWindowId!,
                    ),
                  );
                } catch (e) {
                  // 이미 삭제된 경우 무시
                }
              }

              // 새로운 정보창 생성 및 열기 (마커 바로 위에 표시)
              final infoText =
                  '${i + 1}위. ${menu['name']}\n${menu['score']}점${menu['price'] != null && (menu['price'] as String).isNotEmpty ? ' • ${menu['price']}' : ''}';

              final infoWindow = NInfoWindow.onMap(
                id: 'info_$i',
                text: infoText,
                position: NLatLng(lat! + 0.0001, lng!), // 마커 위에 표시
              );

              // 정보창 클릭 이벤트 설정 (클릭 시 사라지도록)
              infoWindow.setOnTapListener((NInfoWindow infoWindow) async {
                await mapController.deleteOverlay(
                  NOverlayInfo(type: NOverlayType.infoWindow, id: 'info_$i'),
                );
                currentOpenInfoWindowId = null;
              });

              await mapController.addOverlay(infoWindow);
              currentOpenInfoWindowId = 'info_$i';
            });
          }
        }
      } catch (e) {
        print('원본 마커 생성 실패: $e');
        continue;
      }
    }
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

  Widget _buildRankCard(Map item) {
    final colors = [
      Colors.amber, // 1위 - 금색
      Colors.blueGrey, // 2위 - 회색
      Colors.deepOrange, // 3위 - 주황색
      Colors.green, // 4위 - 초록색
      Colors.purple, // 5위 - 보라색
      Colors.teal, // 6위 - 청록색
      Colors.indigo, // 7위 - 남색
      Colors.pink, // 8위 - 분홍색
      Colors.cyan, // 9위 - 하늘색
      Colors.brown, // 10위 - 갈색
    ];
    final rank = item['rank'] as int? ?? 1;
    final colorIndex = (rank - 1).clamp(0, colors.length - 1); // 색상 인덱스 안전하게 제한

    return GestureDetector(
      onTap: () => _moveToLocation(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors[colorIndex].withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colors[colorIndex],
              backgroundImage:
                  (item['image'] != null &&
                          (item['image'] as String).isNotEmpty)
                      ? getMenuImage(item['image'] as String?)
                      : null,
              child:
                  (item['image'] == null || (item['image'] as String).isEmpty)
                      ? Text('$rank', style: TextStyle(color: Colors.white))
                      : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item['store'] ?? item['name'] ?? ''}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item['originalRank'] != null &&
                          item['originalRank'] != item['rank'])
                        Container(
                          margin: EdgeInsets.only(left: 8),
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '원래 ${item['originalRank']}위',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (item['menu'] != null) Text('${item['menu']}'),
                  if (item['price'] != null || item['sale'] != null)
                    Text(
                      '${item['price'] != null ? '${item['price']}' : ''}  ${item['sale'] ?? ''}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  if (item['desc'] != null)
                    Text(
                      '${item['desc']}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                Icon(Icons.star, color: Colors.orange, size: 20),
                Text(
                  '${item['score'] ?? ''}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherCard(Map item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: () => _moveToLocation(item),
        leading: CircleAvatar(
          backgroundImage:
              (item['image'] != null && (item['image'] as String).isNotEmpty)
                  ? getMenuImage(item['image'] as String?)
                  : null,
          child:
              (item['image'] == null || (item['image'] as String).isEmpty)
                  ? Icon(Icons.restaurant, color: Colors.grey[600])
                  : null,
        ),
        title: Text(
          '${item['store'] ?? item['name'] ?? ''}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['price'] != null && (item['price'] as String).isNotEmpty)
              Text(
                '${item['price']}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            if (item['desc'] != null) Text('${item['desc']}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.orange, size: 16),
            SizedBox(width: 2),
            Text(
              '${item['score'] ?? ''}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // 현재 열린 정보창 닫기 함수
  Future<void> _closeCurrentInfoWindow() async {
    if (currentOpenInfoWindowId != null && isMapReady) {
      try {
        await mapController.deleteOverlay(
          NOverlayInfo(
            type: NOverlayType.infoWindow,
            id: currentOpenInfoWindowId!,
          ),
        );
      } catch (e) {
        // 이미 삭제된 경우 무시
      }
      currentOpenInfoWindowId = null;
    }
  }

  // 지도 위치 이동 함수
  void _moveToLocation(Map item) async {
    if (!isMapReady || kIsWeb) return;

    try {
      final latValue = item['latitude'];
      final lngValue = item['longitude'];

      if (latValue != null && lngValue != null) {
        // 안전한 타입 변환 - String이나 num 모두 처리
        double? lat;
        double? lng;

        try {
          if (latValue is String) {
            lat = double.tryParse(latValue);
          } else if (latValue is num) {
            lat = latValue.toDouble();
          }

          if (lngValue is String) {
            lng = double.tryParse(lngValue);
          } else if (lngValue is num) {
            lng = lngValue.toDouble();
          }
        } catch (e) {
          print('좌표 변환 실패: $e');
          return;
        }

        if (lat != null &&
            lng != null &&
            !lat.isNaN &&
            !lat.isInfinite &&
            !lng.isNaN &&
            !lng.isInfinite) {
          // 지도 카메라를 해당 위치로 이동
          await mapController.updateCamera(
            NCameraUpdate.withParams(
              target: NLatLng(lat, lng),
              zoom: 18, // 더 가까이 줌인
            ),
          );

          // 해당 마커의 정보창을 표시
          final rank = item['rank'] as int? ?? 1;
          // 검색 상태에 따라 마커 ID 계산
          String markerId;
          if (controller.searchQuery.value.isNotEmpty) {
            // 검색 중일 때는 검색 결과 순서로 마커 ID 계산
            final filteredTop3 = controller.filteredTopMenus.toList();
            final filteredOthers = getFilteredOtherMenus();
            final allFiltered = [...filteredTop3, ...filteredOthers];

            final itemIndex = allFiltered.indexWhere(
              (menu) => menu['name'] == item['name'],
            );
            markerId = 'info_$itemIndex';
            print(
              '검색 중 정보창 열기: ${item['name']} -> itemIndex=$itemIndex, markerId=$markerId',
            );
          } else {
            // 검색하지 않을 때는 원래 순위로 마커 ID 계산
            final originalRank = item['originalRank'] ?? rank;
            markerId = 'info_${originalRank - 1}';
            print(
              '일반 정보창 열기: ${item['name']} -> originalRank=$originalRank, markerId=$markerId',
            );
          }

          // 기존 정보창이 있으면 닫기
          if (currentOpenInfoWindowId != null) {
            try {
              await mapController.deleteOverlay(
                NOverlayInfo(
                  type: NOverlayType.infoWindow,
                  id: currentOpenInfoWindowId!,
                ),
              );
            } catch (e) {
              // 이미 삭제된 경우 무시
            }
          }

          // 새로운 정보창 생성 및 열기 (마커 바로 위에 표시)
          // 검색 상태에 따라 순위 표시 조정
          int displayRank;
          if (controller.searchQuery.value.isNotEmpty) {
            // 검색 중일 때는 검색 결과에서의 순위 표시
            final filteredTop3 = controller.filteredTopMenus.toList();
            final filteredOthers = getFilteredOtherMenus();
            final allFiltered = [...filteredTop3, ...filteredOthers];
            final itemIndex = allFiltered.indexWhere(
              (m) => m['name'] == item['name'],
            );
            displayRank = itemIndex + 1;
          } else {
            // 검색하지 않을 때는 원래 순위 표시
            displayRank = rank;
          }

          final infoText =
              '$displayRank위. ${item['name']}\n${item['score']}점${item['price'] != null && (item['price'] as String).isNotEmpty ? ' • ${item['price']}' : ''}';

          final infoWindow = NInfoWindow.onMap(
            id: markerId,
            text: infoText,
            position: NLatLng(lat + 0.0001, lng), // 마커 위에 표시
          );

          // 정보창 클릭 이벤트 설정 (클릭 시 사라지도록)
          infoWindow.setOnTapListener((NInfoWindow infoWindow) async {
            await mapController.deleteOverlay(
              NOverlayInfo(type: NOverlayType.infoWindow, id: markerId),
            );
            currentOpenInfoWindowId = null;
          });

          await mapController.addOverlay(infoWindow);
          currentOpenInfoWindowId = markerId;
        }
      }
    } catch (e) {
      print('지도 이동 실패: $e');
    }
  }
}
