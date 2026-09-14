import 'package:flutter/material.dart';
import 'party_application_screen.dart';

class PartyDetailScreen extends StatelessWidget { 
  const PartyDetailScreen({super.key});

  void _showHostManagementModal(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85, 
        padding: const EdgeInsets.all(24), 
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('호스트 관리: 동승 신청자 (2)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
              ]
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _applicantCard(context, '지훈', '28세 · 남성', 42.5, ['약속 시간 칼같아요 ⏰', '안전벨트 꼭 매요 🛡️', '조용히 가요 🎧'], '비흡연자', '조용한 이동 선호', '아이유 노래 좋아해요', true),
                  const SizedBox(height: 20),
                  _applicantCard(context, '수아', '25세 · 여성', 38.0, ['분위기 메이커 🥳', '맛집 잘 알아요 🍔'], '비흡연자', '유쾌한 대화 선호', '신나는 팝송', false),
                ]
              )
            )
          ]
        )
      )
    );
  }

  Widget _applicantCard(BuildContext ctx, String name, String info, double temp, List<String> reviews, String smoke, String talk, String music, bool isAccepted) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(radius: 28, backgroundImage: NetworkImage('https://picsum.photos/100?random=800')),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(width: 8), const Icon(Icons.verified, color: Colors.blue, size: 16)]),
                  const SizedBox(height: 4),
                  Text(info, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ]
              )
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('매너온도', style: TextStyle(color: Colors.grey, fontSize: 11)),
                Text('°C', style: const TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.w900, fontSize: 16))
              ]
            )
          ]
        ),
        const SizedBox(height: 16),
        const Text('이전 동승 후기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: reviews.map((r) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)), child: Text(r, style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)))).toList()),
        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
        const Text('취향 궁합 체크', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 12),
        Row(children: [const Icon(Icons.smoke_free, size: 16, color: Colors.grey), const SizedBox(width: 8), Text(smoke, style: const TextStyle(fontSize: 13))]),
        const SizedBox(height: 8),
        Row(children: [const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey), const SizedBox(width: 8), Text(talk, style: const TextStyle(fontSize: 13))]),
        const SizedBox(height: 8),
        Row(children: [const Icon(Icons.music_note, size: 16, color: Colors.grey), const SizedBox(width: 8), Text('선곡: ', style: const TextStyle(fontSize: 13))]),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: ElevatedButton(onPressed: (){ Navigator.pop(ctx); ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('정중하게 거절 메시지를 보냈습니다.'))); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('거절하기', style: TextStyle(fontWeight: FontWeight.bold)))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(onPressed: (){ Navigator.pop(ctx); ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('동승 수락 완료! 단톡방이 열립니다.'))); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('수락하기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
          ]
        )
      ]
    )
  );

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: CustomScrollView(
      slivers: [
        SliverAppBar(expandedHeight: 300, pinned: true, flexibleSpace: FlexibleSpaceBar(background: Image.network('https://picsum.photos/600/400?random=11', fit: BoxFit.cover)), leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)), actions: [IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: (){})]),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFE8F5E9).withOpacity(0.7), borderRadius: BorderRadius.circular(8)), child: const Text('카풀/드라이브', style: TextStyle(color: Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.bold))),
                    ElevatedButton.icon(
                      onPressed: () => _showHostManagementModal(context), 
                      icon: const Icon(Icons.people_alt, size: 16, color: Colors.white), 
                      label: const Text('호스트 관리', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black87, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))
                    )
                  ]
                ),
                const SizedBox(height: 16),
                const Text('이번 주말 양양 카풀 서핑 🚙 (제 차로 편하게 가요!)', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.4)),
                const SizedBox(height: 24),
                const Text('상세 일정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                const Row(children: [Icon(Icons.calendar_today, color: Colors.grey, size: 20), SizedBox(width: 8), Text('9월 19일 (토) 오전 8:00 출발', style: TextStyle(fontSize: 15))]),
                const SizedBox(height: 8),
                const Row(children: [Icon(Icons.location_on, color: Colors.grey, size: 20), SizedBox(width: 8), Text('출발: 서울 잠실역 4번 출구', style: TextStyle(fontSize: 15))]),
                const SizedBox(height: 32),
                const Text('참여 비용 안내', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(16)), child: const Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('예상 주유비/톨비 (1/N)', style: TextStyle(color: Colors.black87)), Text('약 15,000원', style: TextStyle(fontWeight: FontWeight.bold))]), SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('노쇼 방지 보증금', style: TextStyle(color: Colors.black87)), Text('10,000원', style: TextStyle(fontWeight: FontWeight.bold))])])),
                const SizedBox(height: 32),
                const Text('호스트 소개', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                Row(children: [const CircleAvatar(radius: 24, backgroundImage: NetworkImage('https://picsum.photos/100?random=20')), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('스윗드라이버', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text('30대 · 남성 · 베스트 드라이버', style: TextStyle(color: Colors.grey, fontSize: 13))])), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)), child: const Text('프로필', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))]),
                const SizedBox(height: 32),
                const Text('상세 내용', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                const Text('안녕하세요! 이번 주말에 서핑하러 양양에 가는데 혼자 가기 심심해서 카풀 인원 모집합니다. 제 차는 싼타페라 뒷자리 넉넉하고 트렁크 공간도 충분해요! 운전은 제가 다 할 테니 편하게 오시면 됩니다. 휴게소에서 소떡소떡 쏘실 분 환영해요 😆', style: TextStyle(fontSize: 15, height: 1.6, color: Colors.black87)),
                const SizedBox(height: 100),
              ]
            )
          )
        )
      ]
    ),
    bottomSheet: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PartyApplicationScreen())), 
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), 
          child: const Text('동승 신청하기', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
        )
      )
    )
  );
}