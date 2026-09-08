
import 'package:flutter/material.dart';

class SignalGroupChatScreen extends StatelessWidget {
  const SignalGroupChatScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(title: const Text('시그널 하우스 당일치기 투어', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
    body: Column(children: [
      Container(padding: const EdgeInsets.all(16), color: const Color(0xFFFFF5F5), child: const Row(children: [Icon(Icons.push_pin, color: Color(0xFFFF3B30), size: 18), SizedBox(width: 8), Text('투표가 시작되었습니다! [>투표하러 가기]', style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold, fontSize: 13))])),
      Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
        _msg('유스', '안녕하세요! 여행 기대되네요 ☺️', false),
        _msg('나', '네 저도요 하하하', true),
        _msg('지은', '목포 낙지 맛있을 것 같아요!', false),
      ])),
      SafeArea(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade200))), child: Row(children: [
        Expanded(child: TextField(decoration: InputDecoration(hintText: '메시지를 입력하세요', filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)))),
        const SizedBox(width: 8),
        const CircleAvatar(backgroundColor: Color(0xFFFF3B30), child: Icon(Icons.send, color: Colors.white, size: 18)),
      ]))),
    ]),
  );
  static Widget _msg(String name, String text, bool isMe) => Align(
    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
    child: Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
      if (!isMe) Text(name, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      Container(margin: const EdgeInsets.symmetric(vertical: 4), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: isMe ? const Color(0xFFFF3B30) : Colors.grey.shade100, borderRadius: BorderRadius.circular(18)), child: Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black))),
    ]),
  );
}
