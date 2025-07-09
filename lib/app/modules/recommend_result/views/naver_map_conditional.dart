// 조건부 import - 웹에서는 실제 지도, 모바일에서는 스텁
export 'naver_map_web.dart' if (dart.library.io) 'naver_map_web_stub.dart';
