import io
import re

with io.open('lib/screens/soso_car_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

new_build = """  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Text('마포구 서교동', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: textPrimary)),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 24, color: textPrimary),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen())),
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              width: 40, height: 40,
              decoration: const BoxDecoration(color: Color(0xFFF5F5F7), shape: BoxShape.circle),
              child: Icon(Icons.tune, color: textPrimary, size: 20),
            ),
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 1. Categories Tab (Horizontal Scroll)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 24, left: 24),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedCategoryIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? accentColor : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? accentColor : const Color(0xFFEBEBEF)),
                          boxShadow: isSelected ? [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_categories[index]['icon'], style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              _categories[index]['name'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : textSecondary,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          // 2. 지금 내 상황 (My Current Situation)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('지금 내 상황', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary)),
                      Text('전체 보기', style: TextStyle(fontSize: 14, color: textSecondary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildVibeCard('⚡', '놀줄아는', '핫플·페스티벌', const Color(0xFFFFF4E6)),
                      const SizedBox(width: 12),
                      _buildVibeCard('☕', '소소하게', '카페·산책', const Color(0xFFF3F4F6)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildVibeCard('🍔', '메이트', '맛집·배달', const Color(0xFFFCE8E6)),
                      const SizedBox(width: 12),
                      _buildVibeCard('💖', '소개팅', '취향 기반', const Color(0xFFFCE4EC)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // 3. 우리 동네 취향 모임 Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('우리 동네\\n취향 모임', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary, height: 1.2)),
                  Text('12개 진행 중', style: TextStyle(fontSize: 14, color: accentColor, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          
          // 4. StreamBuilder (List of Meetups)
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('meetups').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: Colors.black)));
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("데이터를 불러오는데 실패했습니다."));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("아직 등록된 모임이 없습니다.")));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return _buildMeetupCard(data);
                  },
                );
              },
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildMapMarker"""

# The regex will match from `@override\n  Widget build` up to `  Widget _buildMapMarker`
pattern = re.compile(r'  @override\s+Widget build\(BuildContext context\) \{.*?  Widget _buildMapMarker', re.DOTALL)
content = pattern.sub(new_build, content)

with io.open('lib/screens/soso_car_home_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
