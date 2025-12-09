<<<<<<< Updated upstream
import 'package:flutter/material.dart'; 
=======
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:excel/excel.dart' hide Border;
import '../models/user_profile.dart';
import '../models/shelter.dart';
>>>>>>> Stashed changes

// StatefulWidget을 선언함으로써, RandingPage에서의 데이터는 변화할 수 있음
class RandingPage extends StatefulWidget {
  // super.key를 통해 StatefulWidget에 알림 
  const RandingPage({super.key});
  // StatefulWidget은 항상 createState로 상태 클래스를 생성해야함 
  @override
  State<RandingPage> createState() => _RandingPageState(); 
}

// State<RandingPage>는 RandingPage 클래스로 생성된 상태 클래스를 의미함 
class _RandingPageState extends State<RandingPage> {
<<<<<<< Updated upstream

  @override
  Widget build(BuildContext context){

    // Scaffold는 Material Design 앱의 기본적인 레이아웃 구조를 제공함 
=======
  InAppWebViewController? _webViewController;
  bool _isMapLoading = true;
  List<Shelter> allShelters = [];
  List<Shelter> nearbyShelters = [];

  final double searchRadiusKm = 1.0; // 검색 반경 1km

  @override
  void initState() {
    super.initState();
    _loadShelters();
  }

  Future<void> _loadShelters() async {
    try {
      final bytes = await rootBundle.load('assets/shelter.xlsx');
      final excel = Excel.decodeBytes(bytes.buffer.asUint8List());

      final sheet = excel.tables.keys.first;
      final table = excel.tables[sheet];

      if (table == null) return;

      List<Shelter> shelters = [];

      // 첫 번째 행은 헤더이므로 건너뛰기
      for (var i = 1; i < table.rows.length; i++) {
        final row = table.rows[i];

        if (row.length >= 4) {
          final name = row[0]?.value?.toString() ?? '';
          final address = row[1]?.value?.toString() ?? '';
          final longitude = double.tryParse(row[2]?.value?.toString() ?? '0') ?? 0.0;
          final latitude = double.tryParse(row[3]?.value?.toString() ?? '0') ?? 0.0;

          if (name.isNotEmpty && latitude != 0 && longitude != 0) {
            shelters.add(Shelter(
              name: name,
              address: address,
              longitude: longitude,
              latitude: latitude,
            ));
          }
        }
      }

      print('✅ 전체 대피소: ${shelters.length}개 로드 완료');

      setState(() {
        allShelters = shelters;
        _filterNearbyShelters();
        print('✅ 근처 대피소: ${nearbyShelters.length}개');
      });
    } catch (e) {
      print('❌ 대피소 로드 실패: $e');
    }
  }

  void _filterNearbyShelters() {
    final currentLocation = widget.profile.currentLocation;

    if (currentLocation == null || !currentLocation.isValid) {
      nearbyShelters = [];
      return;
    }

    nearbyShelters = allShelters.where((shelter) {
      final distance = shelter.distanceFrom(
        currentLocation.latitude,
        currentLocation.longitude,
      );
      return distance <= searchRadiusKm;
    }).toList();

    // 거리순으로 정렬
    nearbyShelters.sort((a, b) {
      final distA = a.distanceFrom(
        currentLocation.latitude,
        currentLocation.longitude,
      );
      final distB = b.distanceFrom(
        currentLocation.latitude,
        currentLocation.longitude,
      );
      return distA.compareTo(distB);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = widget.profile.currentLocation;
    final bool hasCurrentLocation = currentLocation != null && currentLocation.isValid;
    final bool hasInterestedAreas = widget.profile.interestedAreas.isNotEmpty;

    final String headerTitle = () {
      if (hasCurrentLocation) return '현재 위치 모니터링';
      if (hasInterestedAreas) return '관심 지역 모니터링';
      return '관심 지역 미설정';
    }();

    final String mainAreaText = () {
      if (hasCurrentLocation) {
        return currentLocation!.address;
      } else if (hasInterestedAreas) {
        return widget.profile.interestedAreas.first.address;
      } else {
        return '하단의 "내 정보"에서 관심 지역을 등록하면\n해당 지역의 침수 위험을 자동으로 알려드려요.';
      }
    }();

    final String subAreaText = () {
      if (hasCurrentLocation) {
        return '현재 GPS 기준으로 침수 위험을 모니터링 중입니다.';
      } else if (hasInterestedAreas) {
        final reasons = widget.profile.interestedAreas.first.hashtagReasons;
        return reasons.isNotEmpty ? '등록 이유: $reasons' : '사용자가 미리 등록한 관심 지역입니다.';
      } else {
        return '';
      }
    }();

    double centerLat = 37.5665;
    double centerLng = 126.9780;

    if (hasCurrentLocation) {
      centerLat = currentLocation!.latitude;
      centerLng = currentLocation!.longitude;
    }

>>>>>>> Stashed changes
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // SingleChildScrollView를 통해 화면이 작아도 콘텐츠가 잘리지 않도록 설정함
      body:SingleChildScrollView(
        // Column은 children을 세로 방향으로 나열함 
        child: Column(
          children: [
<<<<<<< Updated upstream

            Container(
              margin: const EdgeInsets.only(bottom: 20.0, top: 60.0, left:20.0, right:20.0),
=======
            // 상단 카드
            Container(
              margin: const EdgeInsets.only(bottom: 20.0, top: 60.0, left: 20.0, right: 20.0),
>>>>>>> Stashed changes
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade600, Colors.red.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow:[
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    spreadRadius:2,
                    blurRadius:10,
                    offset: const Offset(0, 5),)
                ],
              ),
              // Column이지만, crossAxisAlignment를 통해 가로 방향으로 children을 정렬함
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row를 통해 가로 방향으로 나열 
                  Row(
                    children: [
<<<<<<< Updated upstream
                      const Icon(
                        Icons.warning_amber_rounded,
                        color:Colors.white,
                        size: 28,
                      ),
                      // SizedBox를 통해 여백을 생성
                      const SizedBox(width : 12),
                      const Text(
                        '현재 위치: 위험',
                        style: TextStyle(
                          color:Colors.white,
                          fontSize:22,
                          fontWeight: FontWeight.bold,
                        ),
=======
                      const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        headerTitle,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
>>>>>>> Stashed changes
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // EdgeInsets.only(left)를 통해 왼쪽에만 여백을 줌 
                  Padding(
<<<<<<< Updated upstream
                    padding: const EdgeInsets.only(left:40.0),
                    child: Text(
                      '서울시 강남구 역삼동',
                      style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize:16,
                      ),
=======
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mainAreaText,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                        if (subAreaText.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            subAreaText,
                            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, height: 1.3),
                          ),
                        ],
                      ],
>>>>>>> Stashed changes
                    ),
                  ),
                ],
              ),
            ),

<<<<<<< Updated upstream
=======
            // Tmap
            _buildTmapView(centerLat, centerLng),

            // 범례
>>>>>>> Stashed changes
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
<<<<<<< Updated upstream
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.shade100.withOpacity(0.5),
                          Colors.blue.shade100.withOpacity(0.5),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  // Positioned를 통해 위치를 명시적으로 지정
                  Positioned(
                    left: 100,
                    top: 150,
                    child: Container(
                      width:20,
                      height:20,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        shape:BoxShape.circle,
                        border: Border.all(color:Colors.white, width:3),
                      ),
                    ),
                  ),

                  Positioned(
                    left:150,
                    top: 80,
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red.shade700,
                      size : 40,
                    ),
                  ),

                  Positioned(
                    left:60,
                    top: 180,
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red.shade700,
                      size: 40,
                    ),
                  ),

                  Positioned(
                    right: 60,
                    bottom: 150,
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red.shade700,
                      size:40,
                    ),
                  ),

                  // 범례 표시 
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical:10, horizontal:20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0,2),
                          ),
                        ],
                      ),
                      child: Row(
                        // mainAxisAlignment.spaceAround를 통해 Raw에서 자식들을 동일한 간격으로 정렬함 
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // _buildLegendItem은 따로 생성한 함수
                          _buildLegendItem(Colors.blue, '내 위치'),
                          _buildLegendItem(Colors.red.shade700, '대피소'),
                          _buildLegendItem(Colors.pink.shade200, '침수 지역'),
                        ],
                      ),
                    ),
                  ),
=======
                  _buildLegendItem(Colors.blue, '내 위치'),
                  _buildLegendItem(Colors.red.shade700, '대피소 (${nearbyShelters.length})'),
>>>>>>> Stashed changes
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.all(16.0),
              padding : const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color:Colors.grey.shade300, width:1),
              ),
              child: Row(
                children: [
<<<<<<< Updated upstream
                  const Icon(
                    Icons.warning_amber_rounded,
                    color : Colors.red,
                  ),
                  const SizedBox(width:5),
                  Expanded(
                    child: Text(
                      '긴급 상황! AI 비서와 함께 안전한 대피 요령을 확인하세요.',
                      style: const TextStyle(fontSize:14),
                      // softWrap을 통해 자동 줄바꿈
                      softWrap:true,
=======
                  const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      '반경 ${searchRadiusKm}km 내 대피소 ${nearbyShelters.length}개\n침수·재난 상황 발생 시 AI 비서와 함께 가까운 대피소를 확인하세요.',
                      style: const TextStyle(fontSize: 14),
                      softWrap: true,
>>>>>>> Stashed changes
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
    );
  }
  Widget _buildTmapView(double lat, double lng) {
    // 대피소 로드가 완료될 때까지 로딩 표시
    if (allShelters.isEmpty) {
      return Container(
        height: 400,
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.white,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.blue),
              SizedBox(height: 16),
              Text('대피소 데이터 로딩 중...', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: InAppWebView(
              // key 제거 - WebView를 재생성하지 않음
              initialData: InAppWebViewInitialData(
                data: _getTmapHtml(lat, lng),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                domStorageEnabled: true,
                useHybridComposition: true,
                cacheEnabled: true, // 캐시 활성화
                clearCache: false,
                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStop: (controller, url) async {
                print('✅ WebView 로드 완료');
                await Future.delayed(const Duration(milliseconds: 300));
                setState(() {
                  _isMapLoading = false;
                });
              },
              onConsoleMessage: (controller, consoleMessage) {
                print('📱 Tmap: ${consoleMessage.message}');
              },
            ),
          ),
          if (_isMapLoading)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.white,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blue),
                    SizedBox(height: 16),
                    Text('지도 로딩 중...', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  String _getTmapHtml(double lat, double lng) {
    print('📍 HTML 생성 - 근처 대피소: ${nearbyShelters.length}개');

    // 대피소 마커 데이터를 JavaScript 배열로 변환
    final sheltersJson = nearbyShelters.map((shelter) {
      final escapedName = shelter.name
          .replaceAll('\\', '\\\\')
          .replaceAll('"', '\\"')
          .replaceAll("'", "\\'")
          .replaceAll('\n', ' ');
      return '{lat: ${shelter.latitude}, lng: ${shelter.longitude}, name: "$escapedName"}';
    }).join(',');

    final blueMarkerSvg = '''<svg width="32" height="40" viewBox="0 0 32 40" xmlns="http://www.w3.org/2000/svg"><path d="M16 0C9.373 0 4 5.373 4 12c0 9 12 28 12 28s12-19 12-28c0-6.627-5.373-12-12-12z" fill="#1E90FF"/><circle cx="16" cy="12" r="5" fill="white"/></svg>''';

    final redMarkerSvg = '''<svg width="32" height="40" viewBox="0 0 32 40" xmlns="http://www.w3.org/2000/svg"><path d="M16 0C9.373 0 4 5.373 4 12c0 9 12 28 12 28s12-19 12-28c0-6.627-5.373-12-12-12z" fill="#DC143C"/><circle cx="16" cy="12" r="5" fill="white"/></svg>''';

    final blueMarkerBase64 = base64Encode(utf8.encode(blueMarkerSvg));
    final redMarkerBase64 = base64Encode(utf8.encode(redMarkerSvg));

    return '''
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <style>
        * { margin: 0; padding: 0; }
        html, body { width: 100%; height: 100%; overflow: hidden; }
        #map_div { width: 100%; height: 100%; }
    </style>
</head>
<body>
    <div id="map_div"></div>
    <script src="https://apis.openapi.sk.com/tmap/vectorjs?version=1&appKey=nMfEZNvtFKaTbAvHKprLE1cX5kzq41dC3omd9Hwi"></script>
    <script type="text/javascript">
        var map;
        var markers = [];
        var shelters = [$sheltersJson];
        
        console.log('=== 디버깅 시작 ===');
        console.log('대피소 개수:', shelters.length);
        console.log('대피소 전체:', JSON.stringify(shelters));
        console.log('중심 좌표: $lat, $lng');
        
        function initTmap() {
            try {
                map = new Tmapv3.Map("map_div", {
                    center: new Tmapv3.LatLng($lat, $lng),
                    width: "100%",
                    height: "100%",
                    zoom: 14  // 줌 레벨을 낮춰서 더 넓은 범위 확인
                });
                
                console.log('지도 생성 완료');
                console.log('지도 중심:', map.getCenter());
                console.log('지도 줌:', map.getZoom());
                
                // 내 위치 마커 (파란색)
                var myMarker = new Tmapv3.Marker({
                    position: new Tmapv3.LatLng($lat, $lng),
                    icon: "data:image/svg+xml;base64,$blueMarkerBase64",
                    iconSize: new Tmapv3.Size(32, 40),
                    map: map
                });
                
                console.log('내 위치 마커 생성:', myMarker.getPosition());
                
                // 대피소 마커 추가
                console.log('=== 마커 추가 시작 ===');
                for (var i = 0; i < shelters.length; i++) {
                    var s = shelters[i];
                    console.log('마커 ' + i + ':', s.name, '좌표:', s.lat + ', ' + s.lng);
                    
                    try {
                        var position = new Tmapv3.LatLng(s.lat, s.lng);
                        console.log('  - LatLng 객체:', position);
                        
                        var marker = new Tmapv3.Marker({
                            position: position,
                            icon: "data:image/svg+xml;base64,$redMarkerBase64",
                            iconSize: new Tmapv3.Size(28, 36),
                            label: s.name,
                            map: map
                        });
                        
                        console.log('  - 마커 생성 완료:', marker.getPosition());
                        markers.push(marker);
                        
                    } catch(markerError) {
                        console.error('  - 마커 생성 실패:', markerError);
                    }
                }
                
                console.log('=== 마커 추가 완료: ' + markers.length + '개 ===');
                
                // 모든 마커가 보이도록 지도 범위 조정
                if (markers.length > 0) {
                    var bounds = new Tmapv3.LatLngBounds();
                    bounds.extend(new Tmapv3.LatLng($lat, $lng)); // 내 위치 포함
                    for (var i = 0; i < markers.length; i++) {
                        bounds.extend(markers[i].getPosition());
                    }
                    map.fitBounds(bounds);
                    console.log('지도 범위 조정 완료');
                }
                
            } catch(e) {
                console.error('에러 발생:', e);
                console.error('에러 스택:', e.stack);
            }
        }
        
        window.onload = initTmap;
    </script>
</body>
</html>
    ''';
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width:12,
          height: 12,
<<<<<<< Updated upstream
          decoration: BoxDecoration(
            color:color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize:12),
        ),
=======
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
>>>>>>> Stashed changes
      ],
    );
  }
}