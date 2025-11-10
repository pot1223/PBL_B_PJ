import 'package:flutter/material.dart';


class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}


class _MyPageState extends State<MyPage> {

  

  final List<bool> _familySelection = [true, false, false];


  bool _needPrescription = false;
  bool _needMedicalDevice = false;

  
  String? _residenceType = '고층 아파트';

  final List<String> _residenceOptions = [
    '고층 아파트',
    '저층 빌라/주택',
    '오피스텔',
    '기타'
  ];

 
  int _transportationType = 0; 

  @override
  Widget build(BuildContext context) {

    return Container(
      color: const Color(0xFFF9FAFB), 
      child: SingleChildScrollView(
    
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      
            _buildProfileHeader(),
            const SizedBox(height: 24),

      
            _buildFamilyCard(),
            const SizedBox(height: 16),

        
            _buildMedicalCard(),
            const SizedBox(height: 16),

        
            _buildResidenceCard(),
            const SizedBox(height: 16),

          
            _buildTransportationCard(),
            const SizedBox(height: 32),

           
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }


  Widget _buildProfileHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFF9EA5FF), 
            child: Icon(Icons.person, color: Colors.white, size: 28),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '내 정보 설정',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '맞춤형 대피 안내를 위한 정보',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildFamilyCard() {
    return _buildBaseCard(
      icon: Icons.people_outline,
      title: '가족 구성',
      child: ToggleButtons(
        isSelected: _familySelection,
        onPressed: (int index) {
          setState(() {
         
            if (index == 0) {
              _familySelection[0] = true;
              _familySelection[1] = false;
              _familySelection[2] = false;
            } else {
            
              _familySelection[0] = false;
              _familySelection[index] = !_familySelection[index];
            }
          });
        },
        borderRadius: BorderRadius.circular(30.0),
        selectedColor: Colors.white,
        fillColor: Colors.red.shade400, 
        color: Colors.black, 
        constraints: const BoxConstraints(minHeight: 40.0, minWidth: 80.0),
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(children: [Icon(Icons.person, size: 16), SizedBox(width: 4), Text('혼자')]),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(children: [Icon(Icons.child_care, size: 16), SizedBox(width: 4), Text('어린이')]),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(children: [Icon(Icons.elderly, size: 16), SizedBox(width: 4), Text('어르신')]),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalCard() {
    return _buildBaseCard(
      icon: Icons.link,
      title: '필수 의료 사항',
      child: Column(
        children: [
          _buildCheckboxListTile(
            title: '필수 처방약',
            value: _needPrescription,
            onChanged: (bool? value) {
              setState(() {
                _needPrescription = value ?? false;
              });
            },
          ),
          _buildCheckboxListTile(
            title: '전기 의료기기',
            value: _needMedicalDevice,
            onChanged: (bool? value) {
              setState(() {
                _needMedicalDevice = value ?? false;
              });
            },
          ),
        ],
      ),
    );
  }


  Widget _buildResidenceCard() {
    return _buildBaseCard(
      icon: Icons.home_outlined,
      title: '거주 형태',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _residenceType,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down),
            items: _residenceOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    const Icon(Icons.apartment, color: Colors.grey), 
                    const SizedBox(width: 10),
                    Text(value),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _residenceType = newValue;
              });
            },
          ),
        ),
      ),
    );
  }

 
  Widget _buildTransportationCard() {
    return _buildBaseCard(
      icon: Icons.directions_car_filled_outlined,
      title: '이동 수단',
      child: Column(
        children: [
          _buildRadioListTile(
            title: '도보 / 대중교통',
            value: 0,
            groupValue: _transportationType,
            onChanged: (int? value) {
              setState(() {
                _transportationType = value ?? 0;
              });
            },
          ),
          _buildRadioListTile(
            title: '자가용',
            value: 1,
            groupValue: _transportationType,
            onChanged: (int? value) {
              setState(() {
                _transportationType = value ?? 0;
              });
            },
          ),
        ],
      ),
    );
  }

 
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
  
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('정보가 저장되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
       
          backgroundColor: Colors.transparent, 
          shadowColor: Colors.transparent,
        ).copyWith(
         
          elevation: MaterialStateProperty.all(0),
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade400, Colors.pink.shade400],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: const Center(
            child: Text(
              '저장하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildBaseCard(
      {required IconData icon, required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child, 
        ],
      ),
    );
  }

  // 커스텀 체크박스 리스트 타일
  Widget _buildCheckboxListTile(
      {required String title,
      required bool value,
      required ValueChanged<bool?> onChanged}) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.red.shade400,
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  // 커스텀 라디오 버튼 리스트 타일
  Widget _buildRadioListTile(
      {required String title,
      required int value,
      required int groupValue,
      required ValueChanged<int?> onChanged}) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Radio<int>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: Colors.red.shade400,
            ),
            Text(title),
          ],
        ),
      ),
    );
  }
}