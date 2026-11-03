import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../screens/soso_car_detail_screen.dart';

class RelatedMeetups extends StatelessWidget {
  final String eventId;
  const RelatedMeetups({super.key, required this.eventId});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('함께 가는 모임',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        if (Firebase.apps.isEmpty)
          const Text('이 장소에 연결된 모임을 확인하고, 없으면 직접 열어보세요.',
              style: TextStyle(fontSize: 15, height: 1.6))
        else
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('meetups')
                .where('sourceEventId', isEqualTo: eventId)
                .limit(10)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('연결된 모임을 불러오지 못했어요. 잠시 후 다시 확인해 주세요.');
              }
              if (!snapshot.hasData) {
                return const Center(
                    child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator()));
              }
              if (snapshot.data!.docs.isEmpty) {
                return const Text('아직 연결된 모임이 없어요. 같이 갈 이웃을 직접 모아보세요.',
                    style: TextStyle(fontSize: 15, height: 1.6));
              }
              return Column(
                  children: snapshot.data!.docs
                      .map((doc) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                                doc.data()['title']?.toString() ?? '함께 가는 모임'),
                            subtitle: Text(
                                doc.data()['date']?.toString() ?? '일정 확인 필요'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => OOMUDetailScreen(meetup: {
                                          ...doc.data(),
                                          'id': doc.id
                                        }))),
                          ))
                      .toList());
            },
          ),
      ]);
}
