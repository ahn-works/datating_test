import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot10_app/screens/oomu_detail_screen.dart';
import 'package:spot10_app/utils/global_data.dart';

void main() {
  testWidgets('OOMUDetailScreen renders without exception', (tester) async {
    final sampleMeetup = {
      'id': 'meetup_yeosu_salt_bread_01',
      'title': '주말 여수 화장동 수제 소금빵 & 감성 베이커리 카페 오픈런 🥐',
      'location': '전남 여수시 화장동 선소상가 카페거리',
      'time': '일정 협의',
      'schedule': '이번 주말 오후 2시',
      'category': '카페·디저트',
      'imageUrl': 'assets/images/cover_salt_bread.jpg',
      'host': '화장동베이커',
      'hostAvatar': 'profiles/초연.png',
      'hostManner': 42.5,
      'members': 2,
      'maxMembers': 4,
      'memberList': ['초연', '지연'],
      'description': '따끈따끈한 소금빵 나오는 시간에 맞춰 가실 분 구해요!',
      'fee': '각자 주문',
      'cost': '각자 주문 (1/N)',
    };

    await tester.pumpWidget(
      MaterialApp(
        home: OOMUDetailScreen(meetup: sampleMeetup),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('소금빵'), findsWidgets);
  });
}

