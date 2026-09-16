import 'package:flutter/material.dart';
import 'package:kpostal/kpostal.dart';
import 'soso_car_detail_screen.dart';
import 'soso_car_host_screen.dart';
import 'soso_car_chat_screen.dart';

class SosoCarHomeScreen extends StatefulWidget {
  const SosoCarHomeScreen({super.key});

  @override
  State<SosoCarHomeScreen> createState() => _SosoCarHomeScreenState();
}

class _SosoCarHomeScreenState extends State<SosoCarHomeScreen> {
  String _currentLocation = '留덊룷援??곕궓??;
  final Color darkGreen = const Color(0xFF1B4D3E); // ?뚯냼移??κ렇由?
  final Color badgeGreen = const Color(0xFFA5D6A7); // ?몄쬆?댁썐 諭껋? 洹몃┛
  final Color terracotta = const Color(0xFFC04020);
  int _bottomNavIndex = 0;
  int _selectedFilter = 0;

  final List<Map<String, dynamic>> _filters = [
    {'label': '?꾩껜', 'key': 'all'},
    {'label': '?뱀씪移섍린 ??, 'key': '#?뱀씪移섍린'},
    {'label': '?몄쓣 ?쒕씪?대툕 ?똿', 'key': '#?몄쓣留쏆쭛'},
    {'label': '二쇰쭚 ?슅', 'key': '#二쇰쭚'},
  ];

  final List<Map<String, dynamic>> _allTrips = [
    {
      'title': '媛뺥솕???숇쭑?대? ?쇰ぐ 蹂닿퀬 ??섍뎄??癒?..',
      'location': '媛뺥솕???숇쭑?대?',
      'tags': ['#?몄쓣留쏆쭛', '#?섎떎?섏쁺', '#?뚮━怨듭쑀'],
      'driverName': '?щ━??誘쇱슦',
      'driverCar': '蹂쇰낫 XC40 - 鍮꾪씉??- ?대옒?앹쓬??,
      'driverTemp': 38.5,
      'reservedSeats': 3,
      'totalSeats': 4,
      'price': '18,000',
      'image': 'https://picsum.photos/600/300?random=30',
      'badge': '?뵦 留덇컧?꾨컯 1?먮━!',
      'timeBadge': '?좎슂???뱀씪',
      'distance': '?몃룄 ??1?쒓컙 20遺?,
      'scheduleTime': '?대쾲 二??좎슂??14:00 異쒕컻 - 21:00 ?곕궓 ?꾩갑 ?덉젙',
      'scheduleLoc': '吏묎껐吏: ?띾??낃뎄??3踰?異쒓뎄 ??,
    },
    {
      'title': '?뚯＜ ?ㅼ씠由щ쭏?????遺곸뭅??梨??쎄퀬 ...',
      'location': '?뚯＜ ?ㅼ씠由??덉닠留덉쓣',
      'tags': ['#議곗슜?쒗옄留?, '#而ㅽ뵾?쒖옍', '#?먯쑀?쒓컙', '#?뱀씪移섍린'],
      'driverName': '梨낆씫??吏??,
      'driverCar': '?섎젋???섏씠釉뚮━??- ?덉쟾?댁쟾 5?꾩감',
      'driverTemp': 41.2,
      'reservedSeats': 2,
      'totalSeats': 4,
      'price': '12,000',
      'image': 'https://picsum.photos/600/300?random=31',
      'badge': '?쇱슂????,
      'timeBadge': '議곗슜???먮쭅',
      'distance': '?몃룄 ??45遺?,
      'scheduleTime': '?대쾲 二??쇱슂??10:30 異쒕컻 - 17:30 蹂듦?',
      'scheduleLoc': '吏묎껐吏: ?곕궓?뚯텧????誘명똿',
    },
    {
      'title': '?묓룊 ?먮Ъ癒몃━ ?고빂?꾧렇 & 臾쇱븞媛???..',
      'location': '?묓룊 ?먮Ъ癒몃━',
      'tags': ['#臾쇱븞媛쒖궛梨?, '#?뚭퇋紐???, '#苡뚯쟻?쒕씪?대툕', '#二쇰쭚'],
      'driverName': '?쇰━踰꾨뱶 吏꾪샇',
      'driverCar': '?꾩씠?ㅻ땳 5 ?꾧린李?- 臾댁궗怨?,
      'driverTemp': 39.1,
      'reservedSeats': 2,
      'totalSeats': 3,
      'price': '15,000',
      'image': 'https://picsum.photos/600/300?random=32',
      'badge': '?좎슂???꾩묠',
      'timeBadge': '?고빂?꾧렇 ?ъ뼱 ?뙪',
      'distance': '?몃룄 ??55遺?,
      'scheduleTime': '?대쾲 二??좎슂??07:00 異쒕컻 - 12:30 蹂듦? (?ㅼ쟾?쒖궘)',
      'scheduleLoc': '吏묎껐吏: 媛醫뚯뿭 1踰?異쒓뎄',
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
                    const Text('吏?꾩뿉???꾩튂 ?좏깮', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.black87),
                    hintText: '?대뵒濡??좊궇源뚯슂? (媛뺥솕?? ?ㅼ씠由???',
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
                        Image.network('https://picsum.photos/800/800?random=100', width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                        Container(color: Colors.white.withOpacity(0.5)),
                        const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on, color: Color(0xFFC04020), size: 48),
                              Text('吏?꾨? ?吏곸뿬 ????ㅼ젙?섏꽭??, style: TextStyle(fontWeight: FontWeight.bold, backgroundColor: Colors.white70)),
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
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('?꾩튂媛 ?좏깮?섏뿀?듬땲??')));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E4F28), padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('???꾩튂濡??ㅼ젙', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final filterKey = _filters[_selectedFilter]['key'];
    final filteredTrips = filterKey == 'all' 
        ? _allTrips 
        : _allTrips.where((trip) => (trip['tags'] as List).any((tag) => tag.contains(filterKey))).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F7),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainBanner(),
            _buildSearchBar(context),
            _buildFilterChips(),
            _buildListHeader(),
            if (filteredTrips.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('議곌굔??留욌뒗 紐⑥엫???놁뒿?덈떎.', style: TextStyle(color: Colors.grey))),
              )
            else
              ...filteredTrips.map((trip) => _buildTripCard(context: context, trip: trip)).toList(),
            _buildSafetyBanner(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const SosoCarHostScreen()));
          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              _allTrips.insert(0, {
                'title': result['title'],
                'location': result['location'],
                'tags': result['tags'],
                'driverName': result['driverName'],
                'driverCar': '?섏쓽 硫뗭쭊 李?- 臾댁궗怨?,
                'driverTemp': 36.5,
                'reservedSeats': 1,
                'totalSeats': 4,
                'price': result['price'].toString().replaceAll('??', '').replaceAll('??, ''),
                'image': result['image'],
                'badge': result['badge'],
                'timeBadge': result['time'],
                'distance': '?꾩튂 怨꾩궛以?..',
                'scheduleTime': '?ㅻ뒛 異쒕컻 ?덉젙',
                'scheduleLoc': '吏묎껐吏: ' + result['location'],
              });
            });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('???ы뻾 紐⑥엫???깃났?곸쑝濡??깅줉?섏뿀?듬땲?? ?럦')));
          }
        },
        backgroundColor: const Color(0xFFB53D25),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('踰덇컻 ?쒕씪?대툕 ?닿린', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (i) => setState(() => _bottomNavIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: darkGreen,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: '?먯깋'),
          const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: '紐⑥쭛?섍린'),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.chat_bubble_outline),
                Positioned(
                  right: -4, top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Color(0xFFB53D25), shape: BoxShape.circle),
                    child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
            label: '?숉뻾梨꾪똿',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.directions_car_outlined), activeIcon: Icon(Icons.directions_car), label: '?댁뿬??),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF9F9F7),
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.directions_car, color: darkGreen),
          const SizedBox(width: 8),
          const Text('?뚯냼移?, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 20)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                Text('留덊룷援??곕궓??, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, color: Colors.black87, size: 16),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black87), onPressed: (){}),
            Positioned(top: 12, right: 12, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)))
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(radius: 16, backgroundColor: darkGreen, child: const Icon(Icons.emoji_people, color: Colors.white, size: 18)),
        )
      ],
    );
  }

  Widget _buildMainBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF1F6EC), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: badgeGreen, borderRadius: BorderRadius.circular(12)),
                  child: Text('?룧 留덊룷 ?댁썐 ?꾩슜 ?뚮え??, style: TextStyle(color: darkGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                const Text('?곕궓???댁썐怨??좊굹??n?뚯냼??二쇰쭚 濡쒕뱶?몃┰', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, height: 1.3)),
                const SizedBox(height: 8),
                const Text('媛源뚯슫 3~4紐낃낵 ?좊쪟鍮??섎늻硫?媛蹂띻쾶 ??n姨??ㅻ????', style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
          const Icon(Icons.wb_sunny, color: Color(0xFFC85A32), size: 48),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
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
              const Icon(Icons.search, color: Colors.black54),
              const SizedBox(width: 12),
              Expanded(child: Text('?대뵒濡??좊궇源뚯슂? (媛뺥솕?? ?ㅼ씠由? 諛붾떎)', style: TextStyle(color: Colors.grey.shade500, fontSize: 14))),
              const Icon(Icons.tune, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
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
              child: Text(_filters[index]['label'], style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 13)),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('?대쾲 二쇰쭚 異쒕컻 紐⑥쭛 ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFC04020), shape: BoxShape.circle)),
            ],
          ),
          Text('異쒕컻 ?꾨컯??, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildTripCard({required BuildContext context, required Map<String, dynamic> trip}) {
    final double temp = trip['driverTemp'];
    final int reserved = trip['reservedSeats'];
    final int total = trip['totalSeats'];
    final String price = trip['price'];

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SosoCarDetailScreen())),
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(trip['image'], height: 160, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 12, left: 12,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: trip['badge'].contains('留덇컧') ? const Color(0xFFB53D25) : (trip['badge'].contains('?쇱슂??) ? const Color(0xFF90CAF9) : Colors.white), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            if (trip['badge'].contains('留덇컧')) const Icon(Icons.local_fire_department, color: Colors.white, size: 12),
                            if (trip['badge'].contains('留덇컧')) const SizedBox(width: 4),
                            Text(trip['badge'], style: TextStyle(color: trip['badge'].contains('留덇컧') ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 11)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Text(trip['timeBadge'], style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 12, right: 12,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        trip['isFavorite'] = !(trip['isFavorite'] ?? false);
                      });
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white, 
                      radius: 14, 
                      child: Icon(
                        (trip['isFavorite'] ?? false) ? Icons.favorite : Icons.favorite_border, 
                        color: (trip['isFavorite'] ?? false) ? const Color(0xFFC04020) : Colors.black87, 
                        size: 16,
                      )
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12, left: 12, right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [const Icon(Icons.location_on, color: Color(0xFFC04020), size: 14), const SizedBox(width: 4), Text(trip['location'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, shadows: [Shadow(color: Colors.black87, blurRadius: 4)]))]),
                      Text(trip['distance'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, shadows: [Shadow(color: Colors.black87, blurRadius: 4)])),
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
                  const SizedBox(height: 8),
                  Row(children: (trip['tags'] as List).map<Widget>((t) => Container(margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)), child: Text(t, style: TextStyle(color: Colors.grey.shade700, fontSize: 11, fontWeight: FontWeight.bold)))).toList()),
                  
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.black54), const SizedBox(width: 8),
                          Expanded(child: Text(trip['scheduleTime'], style: const TextStyle(fontSize: 12, color: Colors.black87)))
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.near_me, size: 14, color: Color(0xFFC04020)), const SizedBox(width: 8),
                          Expanded(child: Text(trip['scheduleLoc'], style: const TextStyle(fontSize: 12, color: Colors.black87)))
                        ]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=11')),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(trip['driverName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(width: 6),
                                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: badgeGreen, borderRadius: BorderRadius.circular(10)), child: Text('?몄쬆?댁썐', style: TextStyle(color: darkGreen, fontSize: 10, fontWeight: FontWeight.bold))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(trip['driverCar'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(temp.toString() + '째C ?윞', style: const TextStyle(color: Color(0xFFC04020), fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Container(
                            width: 60, height: 4,
                            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(2)),
                            child: Row(children: [Container(width: (temp/100)*60, height: 4, decoration: BoxDecoration(color: const Color(0xFFC04020), borderRadius: BorderRadius.circular(2)))]),
                          )
                        ],
                      )
                    ],
                  ),

                  const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('?묒듅 ?몄썝 (' + reserved.toString() + '/' + total.toString() + '???덉빟??', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                          const SizedBox(height: 6),
                          Row(
                            children: List.generate(total, (index) {
                              bool isReserved = index < reserved;
                              return Container(
                                margin: const EdgeInsets.only(right: 4),
                                width: 24, height: 24,
                                decoration: BoxDecoration(color: isReserved ? darkGreen : Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
                                child: Icon(isReserved ? Icons.person : Icons.add, color: isReserved ? Colors.white : Colors.grey, size: 14),
                              );
                            }),
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('?덉긽 1???⑹궛湲?, style: TextStyle(fontSize: 11, color: Colors.black54)),
                          const SizedBox(height: 4),
                          Text(price + '??, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: (){},
                        style: ElevatedButton.styleFrom(backgroundColor: darkGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                        child: const Text('?숉뻾 ?좎껌', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF9F9F7), borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: badgeGreen, shape: BoxShape.circle), child: Icon(Icons.shield_outlined, color: darkGreen, size: 20)),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('?뚯냼移??덉쟾 ?숉뻾 ?쎌냽', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 6),
                Text('?숇꽕 ?댁썐 ?몄쬆, ?댁쟾硫댄뿀 諛??먮룞李⑤낫??寃利앹씠 ?꾨즺??李⑥＜留?紐⑥쭛湲???깅줉?????덉뒿?덈떎.', style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
