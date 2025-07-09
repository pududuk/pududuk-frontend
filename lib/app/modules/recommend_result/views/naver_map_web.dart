import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../../utils/env_config.dart';

// 웹 전용 조건부 import
import 'dart:html' as html show DivElement, ScriptElement, document;
import 'dart:ui_web' as ui show platformViewRegistry;
import 'dart:js' as js show context;

class NaverMapWeb extends StatefulWidget {
  final double latitude;
  final double longitude;
  final List<Map<String, dynamic>> markers;
  final Function(int)? onMarkerTap;

  const NaverMapWeb({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.markers,
    this.onMarkerTap,
  }) : super(key: key);

  @override
  State<NaverMapWeb> createState() => _NaverMapWebState();
}

class _NaverMapWebState extends State<NaverMapWeb> {
  final String _mapElementId =
      'naver-map-${DateTime.now().millisecondsSinceEpoch}';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initializeWebMap();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = '이 위젯은 웹에서만 사용 가능합니다.';
      });
    }
  }

  Future<void> _initializeWebMap() async {
    if (!kIsWeb) return;

    try {
      // 환경 변수에서 클라이언트 ID 확인
      final clientId = EnvConfig.naverMapsClientId;
      if (clientId.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              '네이버 지도 클라이언트 ID가 설정되지 않았습니다.\n.env 파일에 NAVER_MAP_CLIENT_ID를 설정해주세요.';
        });
        return;
      }

      // HTML 요소 생성 (웹에서만)
      final mapElement =
          html.DivElement()
            ..id = _mapElementId
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.border = 'none';

      // Flutter 웹에서 HTML 요소 등록
      ui.platformViewRegistry.registerViewFactory(
        _mapElementId,
        (int viewId) => mapElement,
      );

      // 네이버 지도 스크립트 로드 및 초기화
      await _loadNaverMapScript(clientId);
    } catch (e) {
      print('웹 지도 초기화 오류: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = '지도 초기화 중 오류가 발생했습니다: $e';
      });
    }
  }

  Future<void> _loadNaverMapScript(String clientId) async {
    if (!kIsWeb) return;

    try {
      // 네이버 지도 API 스크립트 동적 로드
      final script =
          html.ScriptElement()
            ..type = 'text/javascript'
            ..src =
                'https://oapi.map.naver.com/openapi/v3/maps.js?ncpClientId=$clientId';

      final completer = Completer<void>();

      script.onLoad.listen((event) {
        print('네이버 지도 API 로드 완료');
        completer.complete();
      });

      script.onError.listen((event) {
        print('네이버 지도 API 로드 실패');
        completer.completeError('네이버 지도 API 로드 실패');
      });

      html.document.head!.append(script);
      await completer.future;

      // 지도 초기화
      await _initializeMap();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '네이버 지도 API 로드 실패: $e';
      });
    }
  }

  Future<void> _initializeMap() async {
    if (!kIsWeb) return;

    try {
      // 짧은 지연 후 지도 초기화
      await Future.delayed(Duration(milliseconds: 300));

      // JavaScript로 지도 초기화
      final jsCode = '''
        (function() {
          try {
            if (typeof naver === 'undefined' || typeof naver.maps === 'undefined') {
              console.error('네이버 지도 API가 로드되지 않았습니다.');
              return false;
            }

            var mapOptions = {
              center: new naver.maps.LatLng(${widget.latitude}, ${widget.longitude}),
              zoom: 17,
              mapTypeControl: true,
              mapTypeControlOptions: {
                style: naver.maps.MapTypeControlStyle.BUTTON,
                position: naver.maps.Position.TOP_RIGHT
              },
              zoomControl: true,
              zoomControlOptions: {
                style: naver.maps.ZoomControlStyle.SMALL,
                position: naver.maps.Position.TOP_RIGHT
              }
            };

            var map = new naver.maps.Map('$_mapElementId', mapOptions);
            
            // 마커 추가
            ${_generateMarkersScript()}
            
            console.log('네이버 지도 초기화 완료');
            return true;
          } catch (error) {
            console.error('지도 초기화 오류:', error);
            return false;
          }
        })();
      ''';

      final result = js.context.callMethod('eval', [jsCode]);

      if (result == true) {
        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception('지도 초기화 실패');
      }
    } catch (e) {
      print('지도 초기화 오류: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = '지도 초기화 실패: $e';
      });
    }
  }

  String _generateMarkersScript() {
    StringBuffer script = StringBuffer();

    for (int i = 0; i < widget.markers.length; i++) {
      final marker = widget.markers[i];
      final lat = marker['latitude'];
      final lng = marker['longitude'];
      final name = (marker['name'] ?? '').toString().replaceAll("'", "\\'");
      final score = marker['score'] ?? 0;
      final price = (marker['price'] ?? '').toString().replaceAll("'", "\\'");

      script.writeln('''
        var marker$i = new naver.maps.Marker({
          position: new naver.maps.LatLng($lat, $lng),
          map: map,
          title: '$name',
          icon: {
            content: '<div style="background-color: ${_getMarkerColor(i)}; color: white; border-radius: 50%; width: 30px; height: 30px; display: flex; align-items: center; justify-content: center; font-weight: bold; border: 2px solid white; box-shadow: 0 2px 4px rgba(0,0,0,0.3);">${i + 1}</div>',
            size: new naver.maps.Size(30, 30),
            anchor: new naver.maps.Point(15, 15)
          }
        });
        
        var infoWindow$i = new naver.maps.InfoWindow({
          content: '<div style="padding: 10px; font-size: 12px; text-align: center;">' +
                   '<strong>${i + 1}위. $name</strong><br>' +
                   '$score점${price.isNotEmpty ? ' • $price' : ''}</div>'
        });
        
        naver.maps.Event.addListener(marker$i, 'click', function() {
          if (infoWindow$i.getMap()) {
            infoWindow$i.close();
          } else {
            infoWindow$i.open(map, marker$i);
          }
        });
      ''');
    }

    return script.toString();
  }

  String _getMarkerColor(int index) {
    const colors = [
      '#FF0000', // 빨강 (1위)
      '#FF8C00', // 주황 (2위)
      '#FFD700', // 금색 (3위)
      '#32CD32', // 초록
      '#9932CC', // 보라
      '#20B2AA', // 청록
      '#4B0082', // 남색
      '#FF69B4', // 분홍
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.withOpacity(0.1),
              Colors.blue.withOpacity(0.3),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                '네이버 지도 로딩 중...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.red.withOpacity(0.1), Colors.red.withOpacity(0.3)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red),
              SizedBox(height: 16),
              Text(
                '지도 로딩 실패',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(fontSize: 14, color: Colors.red[700]),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!kIsWeb) {
      return Container(child: Center(child: Text('웹에서만 사용 가능한 지도입니다.')));
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: HtmlElementView(viewType: _mapElementId),
    );
  }
}
