import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'dart:js' as js;
import '../../../utils/env_config.dart';

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
  bool _isApiLoaded = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNaverMapAPI();
  }

  Future<void> _loadNaverMapAPI() async {
    if (kIsWeb) {
      try {
        // 네이버 지도 API가 이미 로드되었는지 확인
        final isAlreadyLoaded =
            js.context.hasProperty('naver') &&
            js.context['naver'] != null &&
            js.context['naver'].hasProperty('maps');

        if (isAlreadyLoaded) {
          print('네이버 지도 API가 이미 로드되어 있습니다.');
          setState(() {
            _isApiLoaded = true;
            _isLoading = false;
          });
          _createMapElement();
          return;
        }

        // 환경 변수에서 클라이언트 ID 가져오기
        final clientId = EnvConfig.naverMapsClientId;
        if (clientId.isEmpty) {
          print('네이버 지도 클라이언트 ID가 설정되지 않았습니다.');
          setState(() {
            _isLoading = false;
            _errorMessage = '네이버 지도 클라이언트 ID가 설정되지 않았습니다.';
          });
          return;
        }

        print('네이버 지도 API 로딩 시작 - Client ID: $clientId');

        // 스크립트 요소 생성
        final script =
            html.ScriptElement()
              ..type = 'text/javascript'
              ..src =
                  'https://oapi.map.naver.com/openapi/v3/maps.js?ncpClientId=$clientId';

        // 스크립트 로드 완료 이벤트 리스너
        script.onLoad.listen((event) {
          print('네이버 지도 API 로드 완료');
          setState(() {
            _isApiLoaded = true;
            _isLoading = false;
          });
          _createMapElement();
        });

        // 스크립트 로드 실패 이벤트 리스너
        script.onError.listen((event) {
          print('네이버 지도 API 로드 실패');
          setState(() {
            _isLoading = false;
            _errorMessage = '네이버 지도 API 로드에 실패했습니다.';
          });
        });

        // HTML head에 스크립트 추가
        html.document.head!.append(script);
      } catch (e) {
        print('네이버 지도 API 로딩 중 오류: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = '네이버 지도 API 로딩 중 오류가 발생했습니다.';
        });
      }
    }
  }

  void _createMapElement() {
    if (kIsWeb && _isApiLoaded) {
      // HTML 요소 생성
      final mapElement =
          html.DivElement()
            ..id = _mapElementId
            ..style.width = '100%'
            ..style.height = '100%';

      // Flutter 웹에서 HTML 요소 등록
      ui_web.platformViewRegistry.registerViewFactory(
        _mapElementId,
        (int viewId) => mapElement,
      );

      // 지도 초기화를 위한 지연 실행
      Future.delayed(Duration(milliseconds: 500), () {
        _initializeMap();
      });
    }
  }

  void _initializeMap() {
    if (kIsWeb && _isApiLoaded) {
      try {
        // JavaScript 코드 실행
        js.context.callMethod('eval', [
          '''
          (function() {
            // 네이버 지도 API가 로드되었는지 확인
            if (typeof naver === 'undefined' || typeof naver.maps === 'undefined') {
              console.error('네이버 지도 API가 로드되지 않았습니다.');
              return;
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
            var markers = [];
            ${_generateMarkersScript()}
            
            console.log('네이버 지도 초기화 완료');
          })();
        ''',
        ]);
      } catch (e) {
        print('네이버 지도 초기화 오류: $e');
      }
    }
  }

  String _generateMarkersScript() {
    StringBuffer script = StringBuffer();

    for (int i = 0; i < widget.markers.length; i++) {
      final marker = widget.markers[i];
      final lat = marker['latitude'];
      final lng = marker['longitude'];
      final name = marker['name'] ?? '';
      final score = marker['score'] ?? 0;
      final price = marker['price'] ?? '';

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
        
        markers.push(marker$i);
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
    if (!kIsWeb) {
      return Container(child: Center(child: Text('웹에서만 사용 가능한 지도입니다.')));
    }

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
              Text(
                _errorMessage!,
                style: TextStyle(fontSize: 14, color: Colors.red[700]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: HtmlElementView(viewType: _mapElementId),
    );
  }
}
