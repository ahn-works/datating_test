import 'package:flutter/material.dart';

class SosoCarHomeScreen extends StatefulWidget {
  const SosoCarHomeScreen({super.key});

  @override
  State<SosoCarHomeScreen> createState() => _SosoCarHomeScreenState();
}

class _SosoCarHomeScreenState extends State<SosoCarHomeScreen> {
  // 웜 올리브 그린 & 테라코타 오렌지 테마 컬러
  final Color oliveGreen = const Color(0xFF556B2F);
  final Color terracotta = const Color(0xFFE2725B);
  
  int _selectedFilter = 0;
  final List<String> _filters = ['전체', '당일치기', '1박 2일', '반려동물 동반', '여성 전용'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F7), // 따뜻한 오프화이트 배경
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('동네 카풀 SosoCar', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black87), onPressed: (){}),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 필터 영역
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final isSelected = _selectedFilter == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_filters[index], style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      )),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedFilter = index);
                      },
                      selectedColor: oliveGreen,
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? oliveGreen : Colors.grey.shade200)),
                    ),
                  );
                }),
              ),
            ),
          ),
          
          // 리스트 영역
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTripCard(
                  title: '이번 주말 강화도 일몰 보고 조개구이 팟',
                  destTags: ['#일몰 명소', '#바다뷰 카페'],
                  driverName: '달리는 민우',
                  mannerTemp: 42.5,
                  seats: '2/4석',
                  time: '이번 주 토요일 오후 3시',
                  price: '약 12,000원',
                ),
                const SizedBox(height: 16),
                _buildTripCard(
                  title: '분당 율동공원 반려견 산책 힐링 드라이브',
                  destTags: ['#힐링 숲', '#반려동물'],
                  driverName: '댕댕이엄마',
                  mannerTemp: 38.0,
                  seats: '1/3석',
                  time: '내일 오전 10시',
                  price: '약 5,000원',
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: terracotta,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('빠른 모임 생성', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTripCard({
    required String title,
    required List<String> destTags,
    required String driverName,
    required double mannerTemp,
    required String seats,
    required String time,
    required String price,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // 둥글고 부드러운 카드 UI
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: terracotta.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('잔여 좌석 ', style: TextStyle(color: terracotta, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              Row(
                children: [
                  const Icon(Icons.thermostat, color: Colors.orange, size: 14),
                  Text('°C', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange)),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.3)),
          const SizedBox(height: 12),
          Row(
            children: destTags.map((tag) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(tag, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            )).toList(),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: oliveGreen.withOpacity(0.2),
                    child: Icon(Icons.person, color: oliveGreen, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(driverName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
              Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}
