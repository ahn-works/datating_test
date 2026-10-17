import 'package:flutter/material.dart';
import 'soso_car_home_screen.dart';
import '../utils/app_image.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandRose = Color(0xFFF25767);
    const Color brandInk = Color(0xFFC83243);
    const Color brandSoft = Color(0xFFFFF0F2);
    const Color brandBorder = Color(0xFFF8C6CD);
    const Color trustTeal = Color(0xFF0D9488);
    const Color trustSoft = Color(0xFFE6F7F5);
    const Color inkColor = Color(0xFF221B1D);
    const Color subColor = Color(0xFF635559);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFE4E8),
              Color(0xFFFAF6F7),
              Color(0xFFFFFFFF),
            ],
            stops: [0.0, 0.56, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. 상단 브랜드 로고 & 실시간 동네 접속 칩
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF707F), Color(0xFFE84355)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: brandRose.withOpacity(0.28),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'O',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'OOMU 오뮤',
                          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: brandInk, letterSpacing: -0.5),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: trustTeal.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(color: trustTeal, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            '서교동 54명 활동 중',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: trustTeal),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 2. 히어로 타이틀 & 설레는 자만추 철학 문구
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                    decoration: BoxDecoration(
                      color: brandSoft,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: brandBorder),
                    ),
                    child: const Text(
                      '🌸 안전한 동네 친구부터 설레는 자만추까지',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: brandInk),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: inkColor, height: 1.3, letterSpacing: -0.7),
                    children: [
                      TextSpan(text: '오늘 우리 동네에서\n'),
                      TextSpan(text: '설레는 첫 만남', style: TextStyle(color: brandRose)),
                      TextSpan(text: '을\n시작해 볼까요?'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '본인·동네 인증을 마친 검증된 이웃들과\n부담 없는 동네 번개부터 자연스러운 소개팅까지 함께해요.',
                  style: TextStyle(fontSize: 13.5, color: subColor, height: 1.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),

                // 3. 실시간 모임 & 자만추 프리뷰 카드 2종
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: brandBorder, width: 1.5),
                    boxShadow: [
                      BoxShadow(color: brandRose.withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image(image: appImg('assets/images/cover_wine.jpg'), width: 48, height: 48, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(color: brandSoft, borderRadius: BorderRadius.circular(6)),
                              child: const Text('⚡ 오늘 번개 · 👀 지금 19명이 보고 있어요', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: brandInk)),
                            ),
                            const SizedBox(height: 4),
                            const Text('연남동 LP바에서 신청곡 들으며 하이볼 한잔', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: inkColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const Text('서교동 520m · 호스트 40.5°C · 2/4명 참여', style: TextStyle(fontSize: 11.5, color: subColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: brandBorder, width: 1.5),
                    boxShadow: [
                      BoxShadow(color: brandRose.withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image(image: appImg('assets/images/kr_female_1.jpg'), width: 48, height: 48, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(color: trustSoft, borderRadius: BorderRadius.circular(6)),
                              child: const Text('💓 지인 추천 자만추 · 시크릿 매칭', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: trustTeal)),
                            ),
                            const SizedBox(height: 4),
                            const Text('"리액션 좋고 대화 편한 마케터 친구 소개해요"', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: inkColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const Text('성수·연남 카페투어 · 서로 호감일 때만 채팅 오픈', style: TextStyle(fontSize: 11.5, color: subColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // 4. 하단 시작 액션 버튼 3종
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OOMUHomeScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE500),
                    foregroundColor: const Color(0xFF191919),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('💬 카카오로 3초 만에 시작하기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OOMUHomeScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandRose,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('📱 휴대폰 번호로 안전하게 시작', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OOMUHomeScreen())),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: brandInk,
                    side: const BorderSide(color: brandBorder, width: 1.5),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('먼저 우리 동네 모임 둘러보기 ›', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
