import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/housing_type.dart';
import '../models/interested_area.dart';
import '../services/hive_service.dart';
import '../data/seoul_districts.dart';


class MyPage extends StatefulWidget {
  final UserProfile profile;
  final HiveService hiveService;

  const MyPage({
    Key? key,
    required this.profile,
    required this.hiveService,
  }) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late List<Map<String, String>> _selectedAreasWithReasons; // 변경!
  late bool _hasPets;
  late bool _livesWithFamily;
  late HousingType _housingType;
  late bool _hasVehicle;

  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

  @override
  void didUpdateWidget(MyPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _initializeValues();
    }
  }

  void _initializeValues() {
    _selectedAreasWithReasons = widget.profile.interestedAreas
        .map((area) => {
      'address': area.address,
      'reason': area.reasons.isNotEmpty ? area.reasons.first : '직접입력'
    })
        .toList();
    _hasPets = widget.profile.hasPets;
    _livesWithFamily = widget.profile.livesWithFamily;
    _housingType = widget.profile.housingType;
    _hasVehicle = widget.profile.hasVehicle;
  }

  void _checkChanges() {
    final originalAreas = widget.profile.interestedAreas
        .map((area) => area.address)
        .toList();

    setState(() {
      _hasChanges = _hasPets != widget.profile.hasPets ||
          _livesWithFamily != widget.profile.livesWithFamily ||
          _housingType != widget.profile.housingType ||
          _hasVehicle != widget.profile.hasVehicle ||
          _selectedAreasWithReasons.length != originalAreas.length ||
          !_selectedAreasWithReasons
              .every((item) => originalAreas.contains(item['address']));
    });
  }

  void _removeArea(int index) {
    setState(() {
      _selectedAreasWithReasons.removeAt(index);
    });
    _checkChanges();
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    final areas = _selectedAreasWithReasons
        .asMap()
        .entries
        .map((entry) => InterestedArea(
      id: 'area_${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
      address: entry.value['address']!,
      reasons: [entry.value['reason']!],
      order: entry.key + 1,
    ))
        .toList();

    final updatedProfile = widget.profile.copyWith(
      interestedAreas: areas,
      hasPets: _hasPets,
      livesWithFamily: _livesWithFamily,
      housingTypeCode: _housingType.code,
      hasVehicle: _hasVehicle,
    );

    await widget.hiveService.saveProfile(updatedProfile);

    if (mounted) {
      final savedProfile = widget.hiveService.getProfile()!;

      setState(() {
        _isSaving = false;
        _hasChanges = false;
      });

      setState(() {
        _selectedAreasWithReasons = savedProfile.interestedAreas
            .map((area) => {
          'address': area.address,
          'reason': area.reasons.isNotEmpty ? area.reasons.first : '직접입력'
        })
            .toList();
        _hasPets = savedProfile.hasPets;
        _livesWithFamily = savedProfile.livesWithFamily;
        _housingType = savedProfile.housingType;
        _hasVehicle = savedProfile.hasVehicle;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('저장되었습니다'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '내 정보',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildCurrentLocationSection(),
                const SizedBox(height: 8),
                _buildInterestedAreasSection(),
                const SizedBox(height: 8),
                _buildPetToggleSection(),
                const SizedBox(height: 8),
                _buildFamilyToggleSection(),
                const SizedBox(height: 8),
                _buildHousingTypeSection(),
                const SizedBox(height: 8),
                _buildVehicleToggleSection(),
                const SizedBox(height: 80),
              ],
            ),
          ),
          if (_hasChanges)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
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
        ],
      ),
    );
  }

  Widget _buildCurrentLocationSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.location_on, size: 20, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                '현 위치',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.gps_fixed, size: 16, color: Colors.pink),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.profile.currentLocation?.address ??
                        '서울특별시 강남구 역삼동',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestedAreasSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.favorite_border, size: 20, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                '관심 지역 및 등록 이유',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedAreasWithReasons.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '등록된 관심 지역이 없습니다',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            )
          else
            ..._selectedAreasWithReasons
                .asMap()
                .entries
                .map((entry) => _buildAreaChip(entry.key, entry.value))
                .toList(),
          const SizedBox(height: 12),
          _buildAddAreaButton(),
        ],
      ),
    );
  }

  Widget _buildAreaChip(int index, Map<String, String> areaData) {
    final address = areaData['address']!;
    final reason = areaData['reason']!;

    // 아이콘 선택
    IconData reasonIcon;
    Color iconColor;

    if (reason == '집') {
      reasonIcon = Icons.home;
      iconColor = Colors.blue;
    } else if (reason == '직장') {
      reasonIcon = Icons.work;
      iconColor = Colors.orange;
    } else {
      reasonIcon = Icons.edit;
      iconColor = Colors.purple;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 이유 아이콘 (원형 배경)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              reasonIcon,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 14),

          // 지역명과 이유
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        reason,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 삭제 버튼
          GestureDetector(
            onTap: () => _removeArea(index),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 18,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddAreaButton() {
    return GestureDetector(
      onTap: _selectedAreasWithReasons.length < 5 ? _showAreaInputDialog : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedAreasWithReasons.length < 5
                ? const Color(0xFFFF6B9D)
                : Colors.grey[300]!,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 20,
              color: _selectedAreasWithReasons.length < 5
                  ? const Color(0xFFFF6B9D)
                  : Colors.grey[400],
            ),
            const SizedBox(width: 8),
            Text(
              '지역 추가 (${_selectedAreasWithReasons.length}/5)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _selectedAreasWithReasons.length < 5
                    ? const Color(0xFFFF6B9D)
                    : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAreaInputDialog() {
    String? selectedDistrict;
    String? selectedReason;
    String customReason = '';
    int currentPage = 0;
    final int itemsPerPage = 21;
    final int totalPages = (SeoulDistricts.districts.length / itemsPerPage).ceil();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxHeight: 900,),
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '관심 지역 추가',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  '지역 선택',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  height: 320,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(1),
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                          ),
                          itemCount: _getItemsForPage(currentPage, itemsPerPage, SeoulDistricts.districts.length),
                          itemBuilder: (context, index) {
                            final districtIndex = currentPage * itemsPerPage + index;
                            final district = SeoulDistricts.districts[districtIndex];
                            final isSelected = selectedDistrict == district;

                            return GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  selectedDistrict = district;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFFF6B9D) : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFFF6B9D) : Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    district,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: currentPage > 0
                                  ? () {
                                setDialogState(() {
                                  currentPage--;
                                });
                              }
                                  : null,
                              color: const Color(0xFFFF6B9D),
                            ),
                            Text(
                              '${currentPage + 1} / $totalPages',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: currentPage < totalPages - 1
                                  ? () {
                                setDialogState(() {
                                  currentPage++;
                                });
                              }
                                  : null,
                              color: const Color(0xFFFF6B9D),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  '등록 이유',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildReasonButton(
                        '집',
                        Icons.home,
                        selectedReason == '집',
                            () {
                          setDialogState(() {
                            selectedReason = '집';
                            customReason = '';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildReasonButton(
                        '직장',
                        Icons.work,
                        selectedReason == '직장',
                            () {
                          setDialogState(() {
                            selectedReason = '직장';
                            customReason = '';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildReasonButton(
                        '기타',
                        Icons.edit,
                        selectedReason == '기타',
                            () {
                          setDialogState(() {
                            selectedReason = '기타';
                          });
                        },
                      ),
                    ),
                  ],
                ),

                if (selectedReason == '기타') ...[
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: '이유를 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onChanged: (value) {
                      customReason = value;
                    },
                  ),
                ],

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedDistrict != null && selectedReason != null) {
                            if (selectedReason == '기타' && customReason.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('이유를 입력해주세요')),
                              );
                              return;
                            }

                            final reason = selectedReason == '기타' ? customReason : selectedReason!;
                            _addAreaWithReason(selectedDistrict!, reason);
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('지역과 이유를 모두 선택해주세요')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B9D),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '추가',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getItemsForPage(int currentPage, int itemsPerPage, int totalItems) {
    final startIndex = currentPage * itemsPerPage;
    final remainingItems = totalItems - startIndex;
    return remainingItems < itemsPerPage ? remainingItems : itemsPerPage;
  }

  Widget _buildReasonButton(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B9D) : Colors.grey[100],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6B9D) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addAreaWithReason(String area, String reason) {
    if (_selectedAreasWithReasons.length < 5) {
      final exists = _selectedAreasWithReasons.any(
            (item) => item['address'] == area,
      );

      if (!exists) {
        setState(() {
          _selectedAreasWithReasons.add({
            'address': area,
            'reason': reason,
          });
        });
        _checkChanges();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미 추가된 지역입니다')),
        );
      }
    }
  }

  Widget _buildPetToggleSection() {
    return _buildToggleSection(
      icon: Icons.pets_outlined,
      title: '반려동물 등기 여부',
      value: _hasPets,
      onChanged: (value) {
        setState(() => _hasPets = value);
        _checkChanges();
      },
    );
  }

  Widget _buildFamilyToggleSection() {
    return _buildToggleSection(
      icon: Icons.family_restroom_outlined,
      title: '가족 동거 여부',
      value: _livesWithFamily,
      onChanged: (value) {
        setState(() => _livesWithFamily = value);
        _checkChanges();
      },
    );
  }

  Widget _buildVehicleToggleSection() {
    return _buildToggleSection(
      icon: Icons.car_rental_outlined,
      title: '차량 소유 여부',
      value: _hasVehicle,
      onChanged: (value) {
        setState(() => _hasVehicle = value);
        _checkChanges();
      },
    );
  }

  Widget _buildToggleSection({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.pink,
          ),
        ],
      ),
    );
  }

  Widget _buildHousingTypeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.home_outlined, size: 20, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                '거주 주택',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...HousingType.values
              .map((type) => _buildHousingTypeOption(type))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildHousingTypeOption(HousingType type) {
    final isSelected = _housingType == type;
    return GestureDetector(
      onTap: () {
        setState(() => _housingType = type);
        _checkChanges();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink.shade50 : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.pink : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getHousingIcon(type),
              size: 20,
              color: isSelected ? Colors.pink : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                type.displayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.pink : Colors.black,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, size: 20, color: Colors.pink),
          ],
        ),
      ),
    );
  }

  IconData _getHousingIcon(HousingType type) {
    switch (type) {
      case HousingType.apartment:
        return Icons.apartment;
      case HousingType.semiBasement:
        return Icons.stairs;
      case HousingType.detachedHouse:
        return Icons.house;
      case HousingType.officetel:
        return Icons.business;
      case HousingType.dormitory:
        return Icons.domain;
    }
  }
}