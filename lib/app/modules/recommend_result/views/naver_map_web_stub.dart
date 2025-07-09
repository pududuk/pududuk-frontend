import 'package:flutter/material.dart';

class NaverMapWeb extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.withOpacity(0.1), Colors.grey.withOpacity(0.3)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '지도 기능',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '웹에서만 이용 가능합니다',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
