import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../../utils/app_colors.dart';

class MapResultView extends StatefulWidget {
  const MapResultView({Key? key}) : super(key: key);

  @override
  State<MapResultView> createState() => _MapResultViewState();
}

class _MapResultViewState extends State<MapResultView> {
  @override
  Widget build(BuildContext context) {
    final top3 = [
      {
        'rank': 1,
        'name': '매운갈비찜',
        'score': 4.8,
        'menu': '갈비찜',
        'price': '18,000원',
        'sale': '16,000원',
        'desc': '서울시 서대구 중화요리 2관 추천',
      },
      {
        'rank': 2,
        'name': '청년다방',
        'score': 4.8,
        'menu': '떡볶이',
        'price': '8,000원',
        'sale': '9,000원',
        'desc': '서울시 한강역 떡볶이 강추',
      },
      {
        'rank': 3,
        'name': '스시몬',
        'score': 4.5,
        'menu': '연어초밥',
        'price': '2,500원',
        'sale': '3,000원',
        'desc': '서울시 송파구 일식계 강추',
      },
    ];

    final others = [
      {'name': '봉춘', 'desc': '돈까스 12,000원 • 치즈 8,000원', 'score': 4.3},
      {'name': '핸드메이드', 'desc': '핸드버거 • 5,000원 • 치킨버거', 'score': 4.1},
      {'name': '식객반점', 'desc': '짜장면 • 5,000원 • 군만두 4,000원', 'score': 4.0},
      {'name': '이디야커피', 'desc': '아메리카노 • 2,000원 • 베이글 1,500원', 'score': 3.9},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('서대 맛집 랭킹'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 검색창
              TextField(
                decoration: InputDecoration(
                  hintText: '서점가 검색',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 네이버 지도
              SizedBox(
                height: 180,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: NaverMap(
                    options: NaverMapViewOptions(
                      initialCameraPosition: NCameraPosition(
                        target: NLatLng(37.5665, 126.9780), // 서울시청 예시
                        zoom: 13,
                      ),
                      mapType: NMapType.basic,
                      indoorEnable: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 랭킹 카드
              ...top3.map((item) => _buildRankCard(item)).toList(),
              const SizedBox(height: 16),
              // 기타 순위
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '기타 순위',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              ...others.map((item) => _buildOtherCard(item)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankCard(Map item) {
    final colors = [Colors.amber, Colors.blueGrey, Colors.deepOrange];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors[(item['rank'] as int) - 1].withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colors[(item['rank'] as int) - 1],
            child: Text(
              '${item['rank']}',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item['name']}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text('${item['menu']}'),
                Text(
                  '${item['price']}  ${item['sale']}',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${item['desc']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Icon(Icons.star, color: Colors.orange, size: 20),
              Text(
                '${item['score']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtherCard(Map item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(Icons.restaurant, color: Colors.grey[600]),
        title: Text('${item['name']}'),
        subtitle: Text('${item['desc']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.orange, size: 18),
            SizedBox(width: 2),
            Text(
              '${item['score']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
