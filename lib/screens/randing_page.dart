import 'package:flutter/material.dart'; 

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

  @override
  Widget build(BuildContext context){

    // Scaffold는 Material Design 앱의 기본적인 레이아웃 구조를 제공함 
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // SingleChildScrollView를 통해 화면이 작아도 콘텐츠가 잘리지 않도록 설정함
      body:SingleChildScrollView(
        // Column은 children을 세로 방향으로 나열함 
        child: Column(
          children: [

            Container(
              margin: const EdgeInsets.only(bottom: 20.0, top: 60.0, left:20.0, right:20.0),
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // EdgeInsets.only(left)를 통해 왼쪽에만 여백을 줌 
                  Padding(
                    padding: const EdgeInsets.only(left:40.0),
                    child: Text(
                      '서울시 강남구 역삼동',
                      style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize:16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: 400,
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Stack(
                children: [
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

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width:12,
          height: 12,
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
      ],
    );
  }
}
