
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});
  final _items = const [
    ['남성 모집 마감 임박!', '[목포] 당일치기 모임이 남성 모집 기준 98%입니다.', '5분 전', Icons.people],
    ['투표가 시작되었습니다!', '[목포 투어] 코스 투표를 진행해 주세요.', '1시간 전', Icons.how_to_vote],
    ['미션 성공!', '매너 온도 +1.5도 상승했습니다.', '어제', Icons.star],
    ['최종 선택 시간!', '하트 시그널 투표를 진행해 주세요.', '어제', Icons.favorite],
  ];
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(title: const Text('알림', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
    body: ListView.separated(itemCount: _items.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (_, i) => ListTile(
      leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFFF3B30).withOpacity(0.1), shape: BoxShape.circle), child: Icon(_items[i][3] as IconData, color: const Color(0xFFFF3B30))),
      title: Text(_items[i][0] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(_items[i][1] as String, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Text(_items[i][2] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    )),
  );
}
