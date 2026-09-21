import io

# 1. Update home_screen.dart to remove the old Drive section
with io.open('lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# We want to remove the "우무 드라이브 메이트" section. 
# We'll just slice the string up to the '우무 드라이브 메이트' text, and then close the array and widget.
idx = text.find("const Text('우무 드라이브 메이트'")
if idx != -1:
    new_text = text[:idx] + "          const SizedBox(height: 40)\n        ]\n      )\n    );\n  }\n"
    
    # We also need to keep the helper widgets at the bottom of the class
    # Let's find _userCard
    user_card_idx = text.find("Widget _userCard")
    if user_card_idx != -1:
        new_text += "\n  " + text[user_card_idx:]
    
    with io.open('lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
        f.write(new_text)

# 2. Rewrite soso_car_home_screen.dart (Explore Tab)
explore_code = '''import 'package:flutter/material.dart';
import 'soso_car_host_screen.dart';
import 'chat_screen.dart';
import 'oomu_my_trips_screen.dart';
import 'my_page_screen.dart';
import 'soso_car_detail_screen.dart';
import 'filter_screen.dart';
import 'dart:math';

class OOMUHomeScreen extends StatefulWidget {
  const OOMUHomeScreen({super.key});

  @override
  State<OOMUHomeScreen> createState() => _OOMUHomeScreenState();
}

class _OOMUHomeScreenState extends State<OOMUHomeScreen> {
  final Color darkGreen = const Color(0xFF14422D);
  final Color badgeGreen = const Color(0xFFBCEECF);
  
  final List<Map<String, dynamic>> _meetups = [
    {
      'title': '주말 엽떡+마라탕 조지실 분',
      'category': '맛집/카페',
      'location': '홍대입구역 9번 출구',
      'date': '이번주 토요일 18:00',
      'host': '매운맛킬러',
      'manner': 41.2,
      'price': 'N빵',
      'members': '2/4명',
      'isFemaleOnly': true,
      'transport': '각자 이동',
      'imageUrl': 'https://images.unsplash.com/photo-1583314782006-25f0cb175b16?w=500&q=80'
    },
    {
      'title': '파주 대형 북카페로 드라이브 가요',
      'category': '드라이브/독서',
      'location': '파주 지혜의 숲',
      'date': '일요일 14:00',
      'host': '달리는 민우',
      'manner': 42.8,
      'price': 'N빵',
      'members': '1/3명',
      'isFemaleOnly': false,
      'transport': '호스트 차로 같이 이동',
      'imageUrl': 'https://images.unsplash.com/photo-1497215842964-222b430dc094?w=500&q=80'
    },
    {
      'title': '볼링 에버리지 100 쪼렙팟',
      'category': '액티비티',
      'location': '연남동 스매싱볼',
      'date': '오늘 저녁 8시',
      'host': '볼링초보',
      'manner': 36.5,
      'price': 'N빵',
      'members': '3/4명',
      'isFemaleOnly': false,
      'transport': '각자 이동',
      'imageUrl': 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=500&q=80'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dummy Map Background
          Positioned.fill(
            child: Container(
              color: const Color(0xFFE8ECEF),
              child: CustomPaint(
                painter: _GridPainter(),
                child: Stack(
                  children: [
                    _buildMapMarker(context, 150, 100, '마라탕 팟'),
                    _buildMapMarker(context, 250, 200, '파주 북카페'),
                    _buildMapMarker(context, 100, 350, '볼링팟'),
                  ],
                ),
              ),
            ),
          ),
          
          // Custom AppBar
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.white.withOpacity(0.0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: darkGreen, size: 18),
                        const SizedBox(width: 8),
                        const Text('마포구 연남동', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const Icon(Icons.keyboard_arrow_down, size: 18),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
                      child: Icon(Icons.tune, color: darkGreen),
                    ),
                  )
                ],
              ),
            ),
          ),

          // Bottom Sheet with Meetups
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: const BoxDecoration(
                color: Color(0xFFFBF9F6),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('우리 동네 취향 모임', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkGreen)),
                        Text('12개 진행 중', style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                      itemCount: _meetups.length,
                      itemBuilder: (context, index) => _buildMeetupCard(_meetups[index]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildMapMarker(BuildContext context, double top, double left, String label) {
    return Positioned(
      top: top, left: left,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: darkGreen, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: darkGreen.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]),
            child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          CustomPaint(size: const Size(10, 10), painter: _TrianglePainter(color: darkGreen)),
          const SizedBox(height: 4),
          Container(width: 12, height: 4, decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(50))),
        ],
      ),
    );
  }

  Widget _buildMeetupCard(Map<String, dynamic> meetup) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OOMUDetailScreen())),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Column(
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                image: DecorationImage(image: NetworkImage(meetup['imageUrl']), fit: BoxFit.cover),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(colors: [Colors.black.withOpacity(0.6), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Text(meetup['category'], style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                    if (meetup['isFemaleOnly'])
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFA33D23), borderRadius: BorderRadius.circular(12)),
                        child: const Text('여성 전용', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meetup['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(meetup['location'], style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(meetup['date'], style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(meetup['transport'] == '각자 이동' ? Icons.directions_walk : Icons.directions_car, size: 14, color: darkGreen),
                      const SizedBox(width: 4),
                      Text(meetup['transport'], style: TextStyle(fontSize: 12, color: darkGreen, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(radius: 12, backgroundColor: badgeGreen, child: Icon(Icons.person, size: 14, color: darkGreen)),
                          const SizedBox(width: 8),
                          Text('${meetup['host']} (${meetup['manner']}°C)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      ),
                      Text('${meetup['members']} 참여', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: darkGreen,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      onTap: (index) {
        if (index == 0) { }
        else if (index == 1) { Navigator.push(context, MaterialPageRoute(builder: (context) => const OOMUHostScreen())); }
        else if (index == 2) { Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen())); }
        else if (index == 3) { Navigator.push(context, MaterialPageRoute(builder: (context) => const OOMUMyTripsScreen())); }
        else if (index == 4) { Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPageScreen())); }
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: '탐색'),
        const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: '모집하기'),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.chat_bubble_outline),
              Positioned(right: -4, top: -4, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Color(0xFFA33D23), shape: BoxShape.circle), child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
            ],
          ),
          label: '채팅',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.directions_car_outlined), activeIcon: Icon(Icons.directions_car), label: '내 모임'),
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: '마이'),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 40) canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    for (double i = 0; i < size.height; i += 40) canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path()..moveTo(0, 0)..lineTo(size.width, 0)..lineTo(size.width / 2, size.height)..close();
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
'''
with io.open('lib/screens/soso_car_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(explore_code)

# 3. Rewrite soso_car_host_screen.dart (Host Tab)
host_code = '''import 'package:flutter/material.dart';

class OOMUHostScreen extends StatefulWidget {
  const OOMUHostScreen({super.key});

  @override
  State<OOMUHostScreen> createState() => _OOMUHostScreenState();
}

class _OOMUHostScreenState extends State<OOMUHostScreen> {
  final Color darkGreen = const Color(0xFF14422D);
  String _transportMethod = '각자 이동';
  bool _isFemaleOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('새로운 동네 모임 열기', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('어떤 취향의 찐친을 찾고 있나요?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.3)),
          const SizedBox(height: 32),
          
          _buildTextField('모임 제목', '예: 파주 대형 북카페 같이 가실 분!'),
          const SizedBox(height: 24),
          
          _buildTextField('카테고리', '예: 독서/카페, 맛집탐방, 러닝'),
          const SizedBox(height: 24),
          
          _buildTextField('만날 장소', '예: 홍대입구역 9번 출구 앞'),
          const SizedBox(height: 24),
          
          _buildTextField('일시', '예: 이번주 토요일 오후 2시'),
          const SizedBox(height: 32),

          const Text('이동 방법 (선택)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTransportOption('각자 이동'),
              const SizedBox(width: 12),
              _buildTransportOption('내 차로 카풀'),
            ],
          ),
          if (_transportMethod == '내 차로 카풀') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFFBF9F6), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('여성 전용 카풀 설정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 4),
                      Text('안전을 위해 여성 멤버만 탑승하도록 제한합니다.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  Switch(
                    value: _isFemaleOnly,
                    activeColor: darkGreen,
                    onChanged: (val) => setState(() => _isFemaleOnly = val),
                  )
                ],
              ),
            )
          ],
          
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('모임 등록하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            filled: true,
            fillColor: const Color(0xFFFBF9F6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildTransportOption(String title) {
    bool isSelected = _transportMethod == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _transportMethod = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? darkGreen : Colors.white,
            border: Border.all(color: isSelected ? darkGreen : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
'''
with io.open('lib/screens/soso_car_host_screen.dart', 'w', encoding='utf-8') as f:
    f.write(host_code)

print("Files rewritten successfully.")
