import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Icons.restaurant 아이콘을 PNG로 추출
  final pngBytes = await iconToPng(
    Icons.restaurant,
    size: 200,
    color: Colors.white,
  );

  // assets/image/ 폴더에 저장
  final file = File('assets/image/restaurant_icon.png');
  await file.writeAsBytes(pngBytes);

  print('restaurant_icon.png 파일이 assets/image/ 폴더에 저장되었습니다!');
}

Future<Uint8List> iconToPng(
  IconData icon, {
  double size = 200,
  Color color = Colors.black,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // 배경을 투명하게 설정
  final paint = Paint()..color = Colors.transparent;
  canvas.drawRect(Rect.fromLTWH(0, 0, size, size), paint);

  final textPainter = TextPainter(textDirection: TextDirection.ltr);
  textPainter.text = TextSpan(
    text: String.fromCharCode(icon.codePoint),
    style: TextStyle(fontSize: size, fontFamily: icon.fontFamily, color: color),
  );
  textPainter.layout();

  // 아이콘을 중앙에 배치
  final offset = Offset(
    (size - textPainter.width) / 2,
    (size - textPainter.height) / 2,
  );
  textPainter.paint(canvas, offset);

  final picture = recorder.endRecording();
  final img = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
