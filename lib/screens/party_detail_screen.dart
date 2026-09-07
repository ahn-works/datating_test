import 'package:flutter/material.dart';

class PartyDetailScreen extends StatelessWidget {
  final Map<String, dynamic> partyData;
  
  const PartyDetailScreen({super.key, required this.partyData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black87),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFFFFF0EC),
                child: const Center(child: Icon(Icons.celebration, size: 80, color: Color(0xFFFF8A65))),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFFF8A65), borderRadius: BorderRadius.circular(20)),
                        child: const Text('모집중', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      Text(partyData['date'], style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(partyData['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey, size: 18),
                      const SizedBox(width: 4),
                      Text(partyData['location'], style: const TextStyle(fontSize: 16, color: Colors.black87)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('참여자 현황', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildMemberAvatar('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80', isHost: true),
                      const SizedBox(width: 12),
                      _buildMemberAvatar('https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=150&q=80'),
                      const SizedBox(width: 12),
                      _buildEmptyAvatar(),
                      const SizedBox(width: 12),
                      _buildEmptyAvatar(),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Text('모임 장소 지도', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                    child: const Center(child: Text('Google Maps 영역', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(height: 60),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8A65),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('이 모임에 참여하기', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMemberAvatar(String url, {bool isHost = false}) {
    return Stack(
      children: [
        CircleAvatar(radius: 28, backgroundImage: NetworkImage(url)),
        if (isHost)
          Positioned(
            bottom: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
              child: const Icon(Icons.star, color: Colors.white, size: 12),
            ),
          )
      ],
    );
  }

  Widget _buildEmptyAvatar() {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.grey.shade100,
      child: const Icon(Icons.person_outline, color: Colors.grey),
    );
  }
}
