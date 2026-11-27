import '../services/naver_map_service.dart';
import '../ui/oomu_tokens.dart';
import '../utils/global_data.dart';
import '../utils/location_helper.dart';
import 'naver_map_view.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
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
  PlaceSearchResult? _selectedResult;
  int _searchGeneration = 0;
  bool _isLoading = false;
  String _selectedCategoryFilter = '전체';

  List<PlaceSearchResult> _searchResults = [];

  @override
  void initState() {
    super.initState();
    final userLoc = globalData.userLocation.value.trim();
    final dongToken =
        userLoc.isNotEmpty ? userLoc.split(RegExp(r'\s+')).last : '';
    final userCoords = LocationHelper.findCoordsForLocation(
      userLoc.isNotEmpty ? userLoc : '영등포구 신길동',
    );
    _selectedLatLng = widget.initialLatLng ??
        (userCoords != null
            ? LatLng(userCoords['lat']!, userCoords['lng']!)
            : const LatLng(37.5665, 126.9780));
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _searchOnlineNaver(widget.initialQuery!);
    } else if (dongToken.isNotEmpty) {
      _searchOnlineNaver('$dongToken 카페');
    }
  }

  void _filterPlaces(String query) {
    final clean = query.trim();
    setState(() {
      _searchResults = [];
      _selectedResult = null;
    });
    final dong =
        globalData.userLocation.value.trim().split(RegExp(r'\s+')).last;
    final search = clean.isNotEmpty
        ? clean
        : (dong.isNotEmpty && _selectedCategoryFilter != '전체'
            ? '$dong $_selectedCategoryFilter'
            : '');
    if (search.length >= 2) _searchOnlineNaver(search);
  }

  Future<void> _searchOnlineNaver(String query) async {
    final generation = ++_searchGeneration;
    try {
      final places = await NaverMapService.searchKeyword(
        query,
        lat: _selectedLatLng.latitude,
        lng: _selectedLatLng.longitude,
        size: 10,
      );
      if (mounted && generation == _searchGeneration) {
        final regionParts = globalData.userLocation.value
            .trim()
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .toList();
        final city =
            regionParts.length >= 2 ? regionParts[regionParts.length - 2] : '';
        // A venue in another city must not be offered as this neighborhood's
        // meeting place. Users can change their neighborhood before searching.
        final localPlaces = city.isEmpty
            ? places
            : places.where((item) {
                final address = item.roadAddress.isNotEmpty
                    ? item.roadAddress
                    : item.address;
                return address.contains(city) ||
                    address
                        .contains(city.replaceFirst(RegExp(r'(시|군|구)$'), ''));
              }).toList();
        final onlineList = localPlaces.map((item) {
          return PlaceSearchResult(
            name: item.name,
            address:
                item.roadAddress.isNotEmpty ? item.roadAddress : item.address,
            category: item.category.isNotEmpty ? item.category : '네이버 지도 검색',
            latLng: LatLng(item.lat, item.lng),
          );
        }).toList();

        setState(() => _searchResults = onlineList
            .where((p) =>
                _selectedCategoryFilter == '전체' ||
                p.category.contains(_selectedCategoryFilter))
            .toList());
      }
    } catch (_) {
      if (mounted && generation == _searchGeneration) {
        setState(() => _searchResults = []);
      }
    }
  }

  Future<void> _moveToCurrentGpsLocation() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
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
      _selectedLatLng = newLatLng;
      final region = await NaverMapService.coordToRegionName(
          position.latitude, position.longitude);
      if (!mounted) return;
      if (region != null) {
        _searchController.text = '$region 카페';
        _filterPlaces(_searchController.text);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('현재 동네를 확인하지 못했어요. 장소를 직접 검색해 주세요.')),
        );
      }
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

  void _selectLocation(LatLng latLng, String placeName, String address,
      {PlaceSearchResult? verifiedResult}) {
    setState(() {
      _selectedLatLng = latLng;
      _selectedPlaceName = placeName;
      _selectedAddress = address;
      _selectedResult = verifiedResult;
    });
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
            padding:
                const EdgeInsets.only(top: 12, bottom: 8, left: 20, right: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0EB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('📍 장소 선택',
                          style: TextStyle(
                              color: coralAccent,
                              fontWeight: FontWeight.w800,
                              fontSize: 13)),
                    ),
                    const SizedBox(width: 8),
                    const Text('모임 장소 검색 및 설정',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: textPrimary)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: '현재 위치로 이동',
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: coralAccent,
                              ),
                            )
                          : const Icon(Icons.my_location_rounded,
                              size: 22, color: coralAccent),
                      onPressed: _isLoading ? null : _moveToCurrentGpsLocation,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          size: 24, color: textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
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
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textPrimary),
                decoration: InputDecoration(
                  hintText: '카페, 맛집, 역 이름 검색 (예: 스타벅스, 엽떡, 여수 학동)',
                  hintStyle:
                      const TextStyle(fontSize: 13, color: Color(0xFF9E9EA7)),
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: coralAccent),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded,
                              size: 18, color: textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            _filterPlaces('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              children:
                  ['전체', '카페', '맛집', '술집', '엔터', '액티비티', '약속장소'].map((cat) {
                final isSelected = _selectedCategoryFilter == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: const Color(0xFFFFF0EB),
                    labelStyle: TextStyle(
                      color: isSelected ? coralAccent : textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
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

          // Show a map only after a real Naver place result was selected.
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _selectedResult == null
                  ? const Center(child: Text('네이버에서 장소를 검색해 선택해 주세요.'))
                  : NaverMapView(
                      lat: _selectedLatLng.latitude,
                      lng: _selectedLatLng.longitude,
                      locationName: _selectedPlaceName,
                      height: 200,
                      hideActions: true,
                    ),
            ),
          ),

          // 5. Naver place results
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              itemCount: _searchResults.isEmpty ? 1 : _searchResults.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFF0F0F3)),
              itemBuilder: (context, index) {
                if (_searchResults.isEmpty) {
                  final typed = _searchController.text.trim();
                  if (typed.length >= 2) {
                    final dong = globalData.userLocation.value.trim();
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: coralAccent.withValues(alpha: 0.15),
                        radius: 20,
                        child: const Icon(Icons.add_location_alt_rounded, color: coralAccent),
                      ),
                      title: Text(typed, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('$dong $typed (직접 입력한 장소로 선택)'),
                      onTap: () {
                        _selectLocation(
                          _selectedLatLng,
                          typed,
                          '$dong $typed',
                          verifiedResult: PlaceSearchResult(
                            name: typed,
                            address: '$dong $typed',
                            category: '직접 입력',
                            latLng: _selectedLatLng,
                          ),
                        );
                      },
                    );
                  }
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                        '현재 설정한 동네의 장소를 찾지 못했어요. 장소명을 직접 입력하여 선택하거나 동네 설정을 확인해 주세요.'),
                  );
                }
                final item = _searchResults[index];
                final isSelected = _selectedPlaceName == item.name;

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? coralAccent : surfaceColor,
                    radius: 20,
                    child: Icon(
                      item.category == '카페'
                          ? Icons.coffee_rounded
                          : (item.category == '맛집'
                              ? Icons.restaurant_rounded
                              : (item.category == '술집'
                                  ? Icons.wine_bar_rounded
                                  : Icons.place_rounded)),
                      color: isSelected ? Colors.white : textSecondary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w700,
                      fontSize: 14,
                      color: isSelected ? coralAccent : textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '${item.address} · ${NaverMapService.formatDistanceFromNeighborhood(item.latLng.latitude, item.latLng.longitude)}',
                    style: const TextStyle(
                        fontSize: OomuTokens.fs12,
                        color: OomuTokens.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded,
                          color: coralAccent, size: 22)
                      : null,
                  onTap: () {
                    _selectLocation(item.latLng, item.name, item.address,
                        verifiedResult: item);
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
                    color: Colors.black.withValues(alpha: 0.06),
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
                      const Icon(Icons.check_circle_outline,
                          color: coralAccent, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _selectedPlaceName.isNotEmpty
                              ? _selectedPlaceName
                              : '선택된 장소 없음',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: textPrimary),
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
                        style:
                            const TextStyle(fontSize: 12, color: textSecondary),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.check_rounded, size: 20),
                      label: const Text('이 위치로 장소 설정하기',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                      onPressed: _selectedResult == null
                          ? null
                          : () => Navigator.pop(context, _selectedResult),
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
