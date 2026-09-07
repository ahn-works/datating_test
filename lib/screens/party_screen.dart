import 'package:flutter/material.dart';

class PartyScreen extends StatelessWidget {
  const PartyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Text('모임 탐색', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Color(0xFFFF8A65),
            labelColor: Color(0xFFFF8A65),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Spot Party (번개)'),
              Tab(text: '시그널 하우스 (기수)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPartyList(),
            _buildSignalHouseList(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: const Color(0xFFFF8A65),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('주최하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildPartyList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: const Color(0xFFFFF0EC), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.local_bar, color: Color(0xFFFF8A65)),
            ),
            title: const Text('오늘 저녁 성수동 하이볼 파티', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('오늘 19:30 · 2/4명 참여 중\n#자만추 #캐주얼'),
            isThreeLine: true,
            trailing: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A65),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('참여'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignalHouseList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF8A65), Color(0xFFFFB09C)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🏠 현재 진행 중인 내 기수', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('시그널 하우스 3기 (강남/서초)', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.timer, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text('자정 비밀 투표까지 04:23 남음', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('모집 중인 다음 기수', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          // Additional mock lists could go here
        ],
      ),
    );
  }
}
