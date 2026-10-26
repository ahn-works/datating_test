import '../services/kakao_map_service.dart';
import 'kakao_map_view.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

/// 장소 및 위치 검색 데이터 모델
class PlaceSearchResult {
  final String name;
  final String address;
  final String category;
  final LatLng latLng;

  const PlaceSearchResult({
    required this.name,
    required this.address,
    required this.category,
    required this.latLng,
  });
}

/// OOMU 모임 장소 검색 및 인터랙티브 지도 위치 선택 모달
class PlaceSearchMapModal extends StatefulWidget {
  final String? initialQuery;
  final LatLng? initialLatLng;

  const PlaceSearchMapModal({
    super.key,
    this.initialQuery,
    this.initialLatLng,
  });

  @override
  State<PlaceSearchMapModal> createState() => _PlaceSearchMapModalState();
}

class _PlaceSearchMapModalState extends State<PlaceSearchMapModal> {
  final TextEditingController _searchController = TextEditingController();

  late LatLng _selectedLatLng;
  String _selectedPlaceName = '';
  String _selectedAddress = '';
  bool _isLoading = false;
  String _selectedCategoryFilter = '전체';

  // 전국 주요 추천 핫플 및 모임 장소 기본 데이터베이스 (오프라인 및 즉시 자동완성)
  final List<PlaceSearchResult> _defaultPlaces = [
    // 카페 & 디저트
    const PlaceSearchResult(
      name: '스타벅스 홍대입구역사거리점',
      address: '서울 마포구 양화로 165',
      category: '카페',
      latLng: LatLng(37.5568, 126.9238),
    ),
    const PlaceSearchResult(
      name: '성수동 블루보틀 카페 & 베이커리',
      address: '서울 성동구 아차산로 7',
      category: '카페',
      latLng: LatLng(37.5478, 127.0456),
    ),
    const PlaceSearchResult(
      name: '연남동 감성 북카페 & 에스프레소 바',
      address: '서울 마포구 동교로 242-4',
      category: '카페',
      latLng: LatLng(37.5615, 126.9242),
    ),
    const PlaceSearchResult(
      name: '여수 학동 감성 오션뷰 카페',
      address: '전남 여수시 시청서1길 23',
      category: '카페',
      latLng: LatLng(34.7604, 127.6622),
    ),
    const PlaceSearchResult(
      name: '투썸플레이스 신촌역점',
      address: '서울 서대문구 신촌로 109',
      category: '카페',
      latLng: LatLng(37.5552, 126.9368),
    ),

    // 맛집 & 소셜 다이닝
    const PlaceSearchResult(
      name: '동대문엽기떡볶이 홍대점 (마라떡볶이)',
      address: '서울 마포구 어울마당로 112',
      category: '맛집',
      latLng: LatLng(37.5545, 126.9228),
    ),
    const PlaceSearchResult(
      name: '하이디라오 홍대점 (소셜 마라탕)',
      address: '서울 마포구 양화로 176 와이즈파크 5층',
      category: '맛집',
      latLng: LatLng(37.5574, 126.9255),
    ),
    const PlaceSearchResult(
      name: '연남동 내추럴 와인바 미로길',
      address: '서울 마포구 연남로1길 42',
      category: '술집',
      latLng: LatLng(37.5620, 126.9230),
    ),
    const PlaceSearchResult(
      name: '여수 학동 맛집거리 낭만식당',
      address: '전남 여수시 시청동1길 15',
      category: '맛집',
      latLng: LatLng(34.7620, 127.6605),
    ),
    const PlaceSearchResult(
      name: '강남역 땀땀 (매운 소곱창 쌀국수)',
      address: '서울 강남구 강남대로98길 12-5',
      category: '맛집',
      latLng: LatLng(37.5002, 127.0279),
    ),

    // 엔터 & 액티비티
    const PlaceSearchResult(
      name: '수코인노래연습장 합정역점 (불금 코노)',
      address: '서울 마포구 양화로 45 세아베스틸빌딩',
      category: '엔터',
      latLng: LatLng(37.5498, 126.9142),
    ),
    const PlaceSearchResult(
      name: '레드버튼 보드게임카페 신촌점',
      address: '서울 서대문구 연세로 12 4층',
      category: '엔터',
      latLng: LatLng(37.5569, 126.9363),
    ),
    const PlaceSearchResult(
      name: '망원 한강공원 입구 편의점 (야경 산책로)',
      address: '서울 마포구 마포나루길 467',
      category: '액티비티',
      latLng: LatLng(37.5540, 126.8960),
    ),
    const PlaceSearchResult(
      name: '서울숲 잔디마당 피크닉 스팟',
      address: '서울 성동구 뚝섬로 273',
      category: '액티비티',
      latLng: LatLng(37.5443, 127.0374),
    ),

    // 지하철역 및 약속 장소
    const PlaceSearchResult(
      name: '홍대입구역 9번 출구 앞 만남의 장소',
      address: '서울 마포구 양화로 160 지하철 2호선',
      category: '약속장소',
      latLng: LatLng(37.5562, 126.9235),
    ),
    const PlaceSearchResult(
      name: '합정역 8번 출구 홀트아동복지회 앞',
      address: '서울 마포구 양화로 19',
      category: '약속장소',
      latLng: LatLng(37.5490, 126.9135),
    ),
    const PlaceSearchResult(
      name: '성수역 3번 출구 카페거리 입구',
      address: '서울 성동구 아차산로 100',
      category: '약속장소',
      latLng: LatLng(37.5445, 127.0560),
    ),
    const PlaceSearchResult(
      name: '여수시청 앞 분수광장',
      address: '전남 여수시 시청로 1',
      category: '약속장소',
      latLng: LatLng(34.7600, 127.6625),
    ),
  ];

  List<PlaceSearchResult> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _selectedLatLng = widget.initialLatLng ?? const LatLng(37.5568, 126.9238); // 홍대입구 기본값
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _selectedPlaceName = widget.initialQuery!;
      _selectedAddress = '설정된 장소';
    } else {
      _selectedPlaceName = _defaultPlaces.first.name;
      _selectedAddress = _defaultPlaces.first.address;
    }
    _searchResults = List.from(_defaultPlaces);
  }

  void _filterPlaces(String query) {
    final clean = query.trim().toLowerCase();
    setState(() {
      if (clean.isEmpty) {
        if (_selectedCategoryFilter == '전체') {
          _searchResults = List.from(_defaultPlaces);
        } else {
          _searchResults = _defaultPlaces.where((p) => p.category == _selectedCategoryFilter).toList();
        }
      } else {
        _searchResults = _defaultPlaces.where((p) {
          final matchesCategory = _selectedCategoryFilter == '전체' || p.category == _selectedCategoryFilter;
          final matchesText = p.name.toLowerCase().contains(clean) ||
              p.address.toLowerCase().contains(clean) ||
              p.category.toLowerCase().contains(clean);
          return matchesCategory && matchesText;
        }).toList();
      }
    });

    // 카카오 공식 키워드 검색 (Kakao Local API) 디바운스 지원
    if (clean.length >= 2) {
      _searchOnlineKakao(clean);
    }
  }

  Future<void> _searchOnlineKakao(String query) async {
    try {
      final places = await KakaoMapService.searchKeyword(
        query,
        lat: _selectedLatLng.latitude,
        lng: _selectedLatLng.longitude,
        size: 10,
      );
      if (places.isNotEmpty && mounted) {
        final onlineList = places.map((item) {
          return PlaceSearchResult(
            name: item.name,
            address: item.roadAddress.isNotEmpty ? item.roadAddress : item.address,
            category: item.category.isNotEmpty ? item.category : '카카오맵 검색',
            latLng: LatLng(item.lat, item.lng),
          );
        }).toList();

        setState(() {
          final existingNames = _searchResults.map((r) => r.name).toSet();
          for (final item in onlineList) {
            if (!existingNames.contains(item.name)) {
              _searchResults.insert(0, item);
            }
          }
        });
      }
    } catch (_) {
      // 온라인 검색 실패 시 내장 데이터베이스 결과 계속 사용
    }
  }

  Future<void> _moveToCurrentGpsLocation() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('위치 권한이 필요합니다. 설정에서 허용해주세요.')),
          );
        }
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getLastKnownPosition().timeout(
          const Duration(milliseconds: 400),
          onTimeout: () => null,
        );
      } catch (_) {}
      position ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(milliseconds: 1800),
      );

      final newLatLng = LatLng(position.latitude, position.longitude);
      _selectLocation(
        newLatLng,
        '내 현재 위치 주변',
        '위도: ${position.latitude.toStringAsFixed(4)}, 경도: ${position.longitude.toStringAsFixed(4)}',
      );
      // kakao map updated
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('현재 위치를 가져오지 못했습니다.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _selectLocation(LatLng latLng, String placeName, String address) {
    setState(() {
      _selectedLatLng = latLng;
      _selectedPlaceName = placeName;
      _selectedAddress = address;
    });
    // kakao map updated
  }

  @override
  Widget build(BuildContext context) {
    final double modalHeight = MediaQuery.of(context).size.height * 0.88;
    const Color coralAccent = Color(0xFFFF5E36);
    const Color textPrimary = Color(0xFF1E1E24);
    const Color textSecondary = Color(0xFF767676);
    const Color surfaceColor = Color(0xFFF4F4F7);

    return Container(
      height: modalHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // 1. 드래그 핸들 & 헤더
          Container(
            padding: const EdgeInsets.only(top: 12, bottom: 8, left: 20, right: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0EB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('📍 장소 선택', style: TextStyle(color: coralAccent, fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                    const SizedBox(width: 8),
                    const Text('모임 장소 검색 및 설정', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textPrimary)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 24, color: textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // 2. 검색창 (oo카페, 맛집, 역 등 검색)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E5EB)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary),
                decoration: InputDecoration(
                  hintText: '카페, 맛집, 역 이름 검색 (예: 스타벅스, 엽떡, 여수 학동)',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9E9EA7)),
                  prefixIcon: const Icon(Icons.search_rounded, color: coralAccent),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            _filterPlaces('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                onChanged: _filterPlaces,
              ),
            ),
          ),

          // 3. 카테고리 필터 칩
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              children: ['전체', '카페', '맛집', '술집', '엔터', '액티비티', '약속장소'].map((cat) {
                final isSelected = _selectedCategoryFilter == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: const Color(0xFFFFF0EB),
                    labelStyle: TextStyle(
                      color: isSelected ? coralAccent : textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 12,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() => _selectedCategoryFilter = cat);
                        _filterPlaces(_searchController.text);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),

          // 4. 지도 뷰 (FlutterMap)
          // 4. 카카오 공식 지도 뷰 (KakaoMapView)
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: KakaoMapView(
                lat: _selectedLatLng.latitude,
                lng: _selectedLatLng.longitude,
                locationName: _selectedPlaceName,
                height: 200,
              ),
            ),
          ),

          // 5. 검색 결과 및 직접 지정 리스트
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              itemCount: _searchResults.length + (_searchController.text.trim().isNotEmpty ? 1 : 0),
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF0F0F3)),
              itemBuilder: (context, index) {
                // 직접 입력 옵션이 최상단에 있는 경우
                if (_searchController.text.trim().isNotEmpty && index == 0) {
                  final customText = _searchController.text.trim();
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFF0EB),
                      radius: 20,
                      child: Icon(Icons.edit_location_alt_rounded, color: coralAccent, size: 22),
                    ),
                    title: Text(
                      '\'$customText\' (으)로 직접 지정',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: coralAccent),
                    ),
                    subtitle: const Text('입력하신 이름을 모임 장소로 즉시 확정합니다', style: TextStyle(fontSize: 12, color: textSecondary)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: coralAccent),
                    onTap: () {
                      _selectLocation(_selectedLatLng, customText, '직접 입력한 모임 장소');
                    },
                  );
                }

                final actualIndex = _searchController.text.trim().isNotEmpty ? index - 1 : index;
                final item = _searchResults[actualIndex];
                final isSelected = _selectedPlaceName == item.name;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? coralAccent : surfaceColor,
                    radius: 20,
                    child: Icon(
                      item.category == '카페'
                          ? Icons.coffee_rounded
                          : (item.category == '맛집'
                              ? Icons.restaurant_rounded
                              : (item.category == '술집' ? Icons.wine_bar_rounded : Icons.place_rounded)),
                      color: isSelected ? Colors.white : textSecondary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                      fontSize: 14,
                      color: isSelected ? coralAccent : textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    item.address,
                    style: const TextStyle(fontSize: 12, color: textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: coralAccent, size: 22)
                      : null,
                  onTap: () {
                    _selectLocation(item.latLng, item.name, item.address);
                  },
                );
              },
            ),
          ),

          // 6. 하단 선택 확정 영역
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: coralAccent, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _selectedPlaceName.isNotEmpty ? _selectedPlaceName : '선택된 장소 없음',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (_selectedAddress.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 24, top: 2),
                      child: Text(
                        _selectedAddress,
                        style: const TextStyle(fontSize: 12, color: textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: coralAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.check_rounded, size: 20),
                      label: const Text('이 위치로 장소 설정하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      onPressed: () {
                        if (_selectedPlaceName.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('장소를 선택하거나 검색어를 입력해주세요.')),
                          );
                          return;
                        }
                        Navigator.pop(context, _selectedPlaceName.trim());
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
