import 'package:flutter/material.dart';
import 'soso_car_detail_screen.dart';
import 'soso_car_host_screen.dart';

class SosoCarHomeScreen extends StatefulWidget {
  const SosoCarHomeScreen({super.key});

  @override
  State<SosoCarHomeScreen> createState() => _SosoCarHomeScreenState();
}

class _SosoCarHomeScreenState extends State<SosoCarHomeScreen> {
  final Color darkGreen = const Color(0xFF2E4F28);
  
  int _selectedFilter = 0;
  final List<Map<String, dynamic>> _filters = [
    {'label': '전체', 'key': 'all'},
    {'label': '당일치기 ☕', 'key': '#당일치기'},
    {'label': '노을 드라이브 🌅', 'key': '#노을'},
    {'label': '주말 🚗', 'key': '#주말'},
  ];

  final List<Map<String, dynamic>> _allTrips = [
    {
      'title': '강화도 동막해변 일몰 보고 대하구이 먹...',
      'location': '강화도 동막해변',
      'tags': ['#노을', '#수다환영', '#플리공유'],
      'driverName': '달리는 민우',
      'seats': '1자리',
      'price': '약 12,000원',
      'image': 'https://picsum.photos/600/300?random=20',
      'badge': '🔥 마감임박 1자리!',
      'time': '토요일 당일',
    },
    {
      'title': '파주 마장호수 출렁다리 당일치기 팟',
      'location': '파주 마장호수',
      'tags': ['#당일치기', '#조용한힐링'],
      'driverName': '베스트드라이버',
      'seats': '2자리',
      'price': '약 8,000원',
      'image': 'https://picsum.photos/600/300?random=21',
      'badge': '모집중',
      'time': '일요일 당일',
    },
    {
      'title': '가평 풀빌라 호캉스 1박2일 주말 여행',
      'location': '가평 아침고요수목원 인근',
      'tags': ['#주말', '#1박2일', '#수다환영'],
      'driverName': '여행조아',
      'seats': '3자리',
      'price': '약 15,000원',
      'image': 'https://picsum.photos/600/300?random=22',
      'badge': '여유있음',
      'time': '이번 주말',
    },
  ];

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('지도에서 위치 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.black87),
                    hintText: '어디로 떠날까요? (강화도, 헤이리 등)',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // 가짜 지도 이미지
                        Image.network('https://picsum.photos/800/800?random=100', width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                        Container(color: Colors.white.withOpacity(0.5)),
                        const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on, color: Color(0xFFC04020), size: 48),
                              Text('지도를 움직여 핀을 설정하세요', style: TextStyle(fontWeight: FontWeight.bold, backgroundColor: Colors.white70)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('위치가 선택되었습니다.')));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E4F28), padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('이 위치로 설정', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    // 필터 로직 적용
    final filterKey = _filters[_selectedFilter]['key'];
    final filteredTrips = filterKey == 'all' 
        ? _allTrips 
        : _allTrips.where((trip) => (trip['tags'] as List).contains(filterKey)).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.directions_car, color: Color(0xFF2E4F28)),
            const SizedBox(width: 8),
            const Text('소소카', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 20)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.yellow.withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
              child: const Row(
                children: [
                  Text('마포구 연남동', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
                  Icon(Icons.keyboard_arrow_down, color: Colors.black87, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 배너
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFEEF3E9), borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFA5D6A7), borderRadius: BorderRadius.circular(12)),
                          child: const Text('🏠 마포 이웃 전용 소모임', style: TextStyle(color: Color(0xFF1B5E20), fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        const Text('연남동 이웃과 떠나는\n소소한 주말 로드트립', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, height: 1.3)),
                      ],
                    ),
                  ),
                  const Icon(Icons.wb_sunny, color: Color(0xFFC85A32), size: 48),
                ],
              ),
            ),

            // 1. 검색바 -> 위치 선택 모달 연결
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: _showLocationPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.black87),
                      const SizedBox(width: 12),
                      Expanded(child: Text('어디로 떠날까요? (강화도, 헤이리, 바다)', style: TextStyle(color: Colors.grey.shade600, fontSize: 14))),
                    ],
                  ),
                ),
              ),
            ),
            
            // 2. 필터 칩 연결 (동작)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final isSelected = _selectedFilter == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? darkGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? darkGreen : Colors.grey.shade300),
                      ),
                      child: Text(_filters[index]['label'], style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                    ),
                  );
                }),
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text('이번 주말 출발 모집 🔴', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            ),

            // 3. 필터링된 모임 리스트
            if (filteredTrips.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('조건에 맞는 모임이 없습니다.', style: TextStyle(color: Colors.grey))),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: filteredTrips.map((trip) => _buildTripCard(context, trip)).toList(),
                ),
              ),
              
            const SizedBox(height: 100),
          ],
        ),
      ),
      // 모임 등록 연동
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const SosoCarHostScreen()));
          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              _allTrips.insert(0, result); // 새 모임을 리스트 맨 앞에 추가
            });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('새 여행 모임이 성공적으로 등록되었습니다! 🎉')));
          }
        },
        backgroundColor: const Color(0xFFC04020),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('빠른 모임 생성', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, Map<String, dynamic> trip) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SosoCarDetailScreen())),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(trip['image'], height: 180, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 12, left: 12,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFB53D25), borderRadius: BorderRadius.circular(12)),
                        child: Text(trip['badge'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Text(trip['time'], style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12, left: 12,
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 14), 
                      const SizedBox(width: 4), 
                      Text(trip['location'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  Row(
                    children: (trip['tags'] as List).map<Widget>((tag) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                      child: Text(tag, style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w500)),
                    )).toList(),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
