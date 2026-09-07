import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import 'party_host_screen.dart';

class PartyScreen extends StatelessWidget {
  const PartyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text('Spot Party', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: DummyData.parties.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final party = DummyData.parties[index];
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(party['date'], style: const TextStyle(color: Color(0xFFFF8A65), fontWeight: FontWeight.bold, fontSize: 13)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                      child: Text('${party['members']} 모집중', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Text(party['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(party['location'], style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: (party['tags'] as List<String>).map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                    child: Text('#$tag', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  )).toList(),
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PartyHostScreen()));
        },
        backgroundColor: const Color(0xFFFF8A65),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('모임 주최하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
