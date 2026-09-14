import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class SosoCarHubScreen extends StatelessWidget {
  const SosoCarHubScreen({super.key});

  final List<Map<String, String>> screens = const [
    {'folder': '1_n', 'title': '1_n'},
    {'folder': 'ai', 'title': 'ai'},
    {'folder': '_1', 'title': '소소카 - 중간 경유지 픽업 &amp; 동네 랑데부 스팟 투표 (Smart Pickup &amp; Meetup Point)'},
    {'folder': '_10', 'title': '소소카 - 동네 소규모 카풀 여행'},
    {'folder': '_11', 'title': '소소카 - 중간 경유지 픽업 &amp; 동네 랑데부 스팟 투표 (Smart Pickup &amp; Meetup Point)'},
    {'folder': '_12', 'title': '소소카 - 드라이버 안심 프로필'},
    {'folder': '_13', 'title': '_13'},
    {'folder': '_14', 'title': '소소카 - 동네 소규모 카풀 여행'},
    {'folder': '_15', 'title': '소소카 - 동네 소규모 카풀 여행'},
    {'folder': '_16', 'title': '_16'},
    {'folder': '_17', 'title': '소소카 - 동네 소규모 카풀 여행'},
    {'folder': '_18', 'title': '소소카 - 상세 정보'},
    {'folder': '_19', 'title': '소소카 - 동네 소규모 카풀 여행'},
    {'folder': '_2', 'title': '_2'},
    {'folder': '_20', 'title': 'Edit Vehicle &amp; License Verification - 소소카'},
    {'folder': '_21', 'title': '소소카 - Manage Applicants &amp; Requests'},
    {'folder': '_22', 'title': '소소카 - 스마트 대체 일정 &amp; 코스 변경 (Weather &amp; Traffic Reroute)'},
    {'folder': '_23', 'title': '소소카 - SosoCar'},
    {'folder': '_3', 'title': '소소카 - 상세 정보'},
    {'folder': '_4', 'title': '_4'},
    {'folder': '_5', 'title': '_5'},
    {'folder': '_6', 'title': '소소카 - 상세 정보'},
    {'folder': '_7', 'title': '소소카 - 동네 소규모 카풀 여행'},
    {'folder': '_8', 'title': '_8'},
    {'folder': '_9', 'title': '소소카 - 상세 정보'},
  ];

  void _openWebDesign(String folder) {
    final url = 'soso_car_ui/$folder/code.html';
    html.window.open(url, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('소소카 (SosoCar) 디자인 허브', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: screens.length,
        itemBuilder: (context, index) {
          final s = screens[index];
          return GestureDetector(
            onTap: () => _openWebDesign(s['folder']!),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        'soso_car_ui/${s['folder']}/screen.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Center(child: Icon(Icons.broken_image, color: Colors.grey))),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      s['title']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
