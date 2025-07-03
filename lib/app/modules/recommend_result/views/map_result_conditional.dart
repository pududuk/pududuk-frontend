import 'package:flutter/material.dart';
import 'map_result_stub.dart'
    if (dart.library.io) 'map_result_mobile.dart'
    if (dart.library.html) 'map_result_web.dart';

Widget getConditionalMapView() {
  return getMapResultView();
}
