import 'package:flutter/material.dart';
import 'travel_payment_screen.dart';

class PartyApplicationScreen extends StatefulWidget { const PartyApplicationScreen({super.key}); @override State<PartyApplicationScreen> createState() => _PartyApplicationScreenState(); }
class _PartyApplicationScreenState extends State<PartyApplicationScreen> {
  final _style = TextEditingController(); final _exp = TextEditingController(); bool _passport = false; bool _agree = false;
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.white, appBar: AppBar(title: const Text('참가 신청서 작성', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)), body: ListView(padding: const EdgeInsets.all(24), children: [
    const Text('성공적인 소개팅/동행을 위해\n호스트에게 나를 소개해주세요!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.4)), const SizedBox(height: 32),
    const Text('1. 본인의 여행/데이트 스타일은?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), const SizedBox(height: 8), TextField(controller: _style, decoration: InputDecoration(hintText: '예: 엑티비티 좋아해요, 맛집 탐방파입니다', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 24),
    const Text('2. 이번 모임에서 기대하는 점은?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), const SizedBox(height: 8), TextField(controller: _exp, maxLines: 3, decoration: InputDecoration(hintText: '예: 좋은 인연을 만나고 싶어요!', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 24),
    const Text('3. 필수 확인 사항', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), const SizedBox(height: 8), CheckboxListTile(title: const Text('해외 일정의 경우 여권 만료일이 6개월 이상 남았나요?', style: TextStyle(fontSize: 14)), value: _passport, onChanged: (v) => setState(() => _passport = v!), activeColor: const Color(0xFFFF3B30), contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading),
    CheckboxListTile(title: const Text('노쇼 방지 보증금 정책에 동의합니다.', style: TextStyle(fontSize: 14)), value: _agree, onChanged: (v) => setState(() => _agree = v!), activeColor: const Color(0xFFFF3B30), contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading), const SizedBox(height: 32),
    ElevatedButton(onPressed: _agree ? () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TravelPaymentScreen())) : null, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30), disabledBackgroundColor: Colors.grey.shade300, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('작성 완료 및 결제하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))
  ]));
}
