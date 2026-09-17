import io, re

with io.open('lib/screens/soso_car_detail_screen.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# 1. Move _buildHeaderInfo out of slivers
code = code.replace('_buildHeaderInfo(),\n                _buildDivider(),', '')

# 2. Update SliverAppBar to include _buildHeaderInfo and change height
sliver_app_bar_old = '''Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? terracotta : Colors.black87),
          onPressed: () => setState(() => _isFavorite = !_isFavorite),
        ),
        IconButton(icon: const Icon(Icons.share, color: Colors.black87), onPressed: (){}),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network('https://picsum.photos/800/600?random=111', fit: BoxFit.cover),
            Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black54, Colors.transparent, Colors.black54]))),
          ],
        ),
      ),
    );
  }'''

sliver_app_bar_new = '''Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? terracotta : Colors.white),
          onPressed: () => setState(() => _isFavorite = !_isFavorite),
        ),
        IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: (){}),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network('https://picsum.photos/800/600?random=111', fit: BoxFit.cover),
            Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black54, Colors.transparent, Colors.black87]))),
            Positioned(
              bottom: 20, left: 20, right: 20,
              child: _buildHeaderInfo(),
            ),
          ],
        ),
      ),
    );
  }'''
code = code.replace(sliver_app_bar_old, sliver_app_bar_new)

# 3. Update _buildHeaderInfo to use white text and no Padding wrapper
header_info_old = '''Widget _buildHeaderInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: badgeGreen.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(Icons.nature_people, color: darkGreen, size: 14),
                    const SizedBox(width: 4),
                    Text('당일치기 힐링', style: TextStyle(color: darkGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: terracotta, borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('마감 임박', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('강화도 동막해변 일몰 보고 대하구이 먹고 올 분! 🦐', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.3)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
              const SizedBox(width: 8),
              const Text('이번 주 토요일 (10월 28일)', style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
              const SizedBox(width: 12),
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              const Text('오후 2:00 출발', style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
            ],
          )
        ],
      ),
    );
  }'''

header_info_new = '''Widget _buildHeaderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: badgeGreen, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(Icons.nature_people, color: darkGreen, size: 14),
                  const SizedBox(width: 4),
                  Text('당일치기 힐링', style: TextStyle(color: darkGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: terracotta, borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.local_fire_department, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('마감 임박', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('강화도 동막해변 일몰 보고 대하구이 먹고 올 분! 🦐', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.3, color: Colors.white)),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
            const SizedBox(width: 8),
            const Text('이번 주 토요일 (10월 28일)', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(width: 12),
            Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            const Text('오후 2:00 출발', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        )
      ],
    );
  }'''
code = code.replace(header_info_old, header_info_new)

# 4. Update timeline vertical line height
timeline_old = 'if (!isLast) Container(width: 2, height: 60, color: badgeGreen.withOpacity(0.5)),'
timeline_new = 'if (!isLast) Container(width: 2, height: 75, color: badgeGreen),'
code = code.replace(timeline_old, timeline_new)

with io.open('lib/screens/soso_car_detail_screen.dart', 'w', encoding='utf-8') as f:
    f.write(code)