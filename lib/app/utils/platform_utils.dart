import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlatformUtils {
  static EdgeInsets getResponsivePadding({
    double mobileHorizontal = 24,
    double webHorizontal = 100,
    double vertical = 16,
  }) {
    if (kIsWeb) {
      return EdgeInsets.symmetric(
        horizontal: webHorizontal,
        vertical: vertical,
      );
    } else {
      return EdgeInsets.symmetric(
        horizontal: mobileHorizontal,
        vertical: vertical,
      );
    }
  }
}
