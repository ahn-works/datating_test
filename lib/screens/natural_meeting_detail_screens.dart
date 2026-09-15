import 'package:flutter/material.dart';

// 1. 밥친구/카공 상세 화면
class MealDetailScreen extends StatelessWidget {
  final String title;
  const MealDetailScreen({super.key, required this.title});
  
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
    body: Column(
      children: [
        Expanded(child: ListView(
          children: [
            Image.network('https://picsum.photos/600/400?random=300', width: double.infinity, height: 250, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFF3B30).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Text('밥친구 🥩', style: TextStyle(color: Color(0xFFFF3B30), fontSize: 12, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 12),
                  Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.3)),
                  const SizedBox(height: 16),
                  const Row(children: [Icon(Icons.location_on, color: Colors.grey, size: 16), SizedBox(width: 4), Text('강남역 하남돼지집', style: TextStyle(color: Colors.grey, fontSize: 14))]),
                  const SizedBox(height: 8),
                  const Row(children: [Icon(Icons.access_time, color: Colors.grey, size: 16), SizedBox(width: 4), Text('오늘 오후 7:00', style: TextStyle(color: Colors.grey, fontSize: 14))]),
                  const SizedBox(height: 24),
                  const Text('호스트', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(children: [const CircleAvatar(backgroundImage: NetworkImage('https://picsum.photos/100?random=301')), const SizedBox(width: 12), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('고기러버', style: TextStyle(fontWeight: FontWeight.bold)), Text('20대 · 남성', style: TextStyle(color: Colors.grey, fontSize: 12))]), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)), child: const Text('프로필 보기', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))]),
                  const SizedBox(height: 24),
                  const Text('상세 내용', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  const Text('혼자서 고기 구워먹기 뻘쭘해서 동행 구합니다! 술은 안 마시고 밥만 맛있게 먹고 쿨하게 헤어지실 분들 환영해요. 비용은 철저하게 N빵입니다 ㅎㅎ', style: TextStyle(fontSize: 15, height: 1.6, color: Colors.black87)),
                  const SizedBox(height: 32),
                  const Text('참여자 (1/4)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(children: List.generate(4, (i) => Container(margin: const EdgeInsets.only(right: 12), width: 48, height: 48, decoration: BoxDecoration(color: i==0 ? Colors.transparent : Colors.grey.shade100, shape: BoxShape.circle, border: i==0 ? null : Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), image: i==0 ? const DecorationImage(image: NetworkImage('https://picsum.photos/100?random=301')) : null), child: i==0 ? null : const Icon(Icons.person_outline, color: Colors.grey))))
                ]
              )
            )
          ]
        )),
        SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('참여하기', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))))
      ]
    )
  );
}

// 2. 동네 크루 상세 화면
class CrewDetailScreen extends StatelessWidget {
  final String title;
  const CrewDetailScreen({super.key, required this.title});
  
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black), actions: [IconButton(icon: const Icon(Icons.share, color: Colors.black), onPressed: (){})]),
    body: Column(
      children: [
        Expanded(child: ListView(
          children: [
            Container(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle), child: const Icon(Icons.directions_run, color: Colors.blue, size: 40)), const SizedBox(height: 16), Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('서울 강남구 · 회원 42명', style: TextStyle(color: Colors.grey, fontSize: 14)), const SizedBox(height: 16), const Text('매주 수요일 저녁 8시 반포대교에서 달리는 나이트 러닝 크루입니다! 초보자 대환영! 🏃‍♂️🏃‍♀️', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87))])),
            const Divider(thickness: 8, color: Color(0xFFF8F9FA)),
            Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('정기 모임', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(height: 16), Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(16)), child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)), child: const Column(children: [Text('9월', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)), Text('16', style: TextStyle(color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold))])), const SizedBox(width: 16), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('반포 한강공원 5km 펀런', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), SizedBox(height: 4), Text('수요일 오후 8:00', style: TextStyle(color: Colors.grey, fontSize: 13))]))]))])),
            const Divider(thickness: 8, color: Color(0xFFF8F9FA)),
            Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('멤버 (42)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(height: 16), Wrap(spacing: 12, runSpacing: 12, children: List.generate(8, (i) => Column(children: [CircleAvatar(radius: 28, backgroundImage: NetworkImage('https://picsum.photos/100?random=')), const SizedBox(height: 4), Text('러너', style: const TextStyle(fontSize: 12))])))])),
          ]
        )),
        SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('크루 가입하기', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))))
      ]
    )
  );
}

// 3. 오늘의 번개 상세 화면
class LightningDetailScreen extends StatelessWidget {
  final String title;
  const LightningDetailScreen({super.key, required this.title});
  
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
    body: Column(
      children: [
        Expanded(child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(4)), child: const Text('번개모집 ⚡', style: TextStyle(color: Color(0xFFFF3B30), fontSize: 12, fontWeight: FontWeight.bold)))]),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.4)),
            const SizedBox(height: 24),
            Row(children: [const CircleAvatar(backgroundImage: NetworkImage('https://picsum.photos/100?random=501')), const SizedBox(width: 12), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('퇴근맨', style: TextStyle(fontWeight: FontWeight.bold)), Text('30대 · 남성 · 5분 전', style: TextStyle(color: Colors.grey, fontSize: 12))]), const Spacer(), Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), child: const Icon(Icons.chat_bubble_outline, size: 20))]),
            const SizedBox(height: 24),
            const Text('오늘 갑자기 야근 취소됐는데 집 가기 아쉬워서요!! 강남역 근처에서 시원하게 생맥주 한잔 하실 분 계신가요? 🍻 편하게 수다 떨어요~', style: TextStyle(fontSize: 16, height: 1.6, color: Colors.black87)),
            const SizedBox(height: 32),
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(16)), child: const Column(children: [Row(children: [Icon(Icons.location_on, color: Colors.grey), SizedBox(width: 8), Text('강남역 11번 출구', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))]), SizedBox(height: 16), ClipRRect(borderRadius: BorderRadius.all(Radius.circular(12)), child: SizedBox(height: 120, child: ColoredBox(color: Color(0xFFE9ECEF), child: Center(child: Text('지도 API 연동 영역', style: TextStyle(color: Colors.grey))))))]))
          ]
        )),
        SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('참여하기', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))))
      ]
    )
  );
}