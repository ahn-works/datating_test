import io
import re

# 1. Update soso_car_host_screen.dart
with io.open('lib/screens/soso_car_host_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Make sure we import chat screen
if "import 'soso_car_chat_screen.dart';" not in text:
    text = text.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'soso_car_chat_screen.dart';")

host_btn_old = "onPressed: () => Navigator.pop(context),"
host_btn_new = """onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('🎉 모임 개설 완료!'),
                    content: const Text('취향 저격 찐친 모임이 만들어졌습니다!\\n참여자들이 기다리는 채팅방으로 이동할까요?'),
                    actions: [
                      TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: const Text('닫기', style: TextStyle(color: Colors.grey))),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14422D)),
                        onPressed: () {
                          Navigator.pop(ctx); // close dialog
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OOMUChatScreen(title: '새로 개설한 모임', memberCount: 1)));
                        },
                        child: const Text('이동하기', style: TextStyle(color: Colors.white)),
                      )
                    ]
                  )
                );
              },"""

text = text.replace(host_btn_old, host_btn_new)

with io.open('lib/screens/soso_car_host_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)


# 2. Update soso_car_detail_screen.dart
with io.open('lib/screens/soso_car_detail_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

detail_apply_old = """void _showApplyToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            const Text('참여 신청이 완료되었습니다!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: darkGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }"""

detail_apply_new = """void _showApplyToast() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        height: 280,
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF14422D), size: 64),
            const SizedBox(height: 16),
            const Text('모임 참여 신청이 완료되었습니다!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            const Text('호스트가 수락하면 단톡방 초대가 완료됩니다.\\n미리 채팅방에 입장하시겠어요?', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, height: 1.4)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14422D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const OOMUChatScreen(title: '주말 엽떡+마라탕 조지실 분', memberCount: 3)));
                },
                child: const Text('채팅방 입장하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              )
            )
          ]
        )
      )
    );
  }"""

text = text.replace(detail_apply_old, detail_apply_new)

with io.open('lib/screens/soso_car_detail_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("Updated navigation flows!")
