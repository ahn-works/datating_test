import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'travel_payment_screen.dart';

class PartyApplicationScreen extends StatefulWidget {
  const PartyApplicationScreen({super.key});

  @override
  State<PartyApplicationScreen> createState() => _PartyApplicationScreenState();
}

class _PartyApplicationScreenState extends State<PartyApplicationScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final int _totalQuestions = 10;
  final Map<int, String> _answers = {};

  final List<Map<String, dynamic>> _q = [
    {
      'type': 'choice',
      'q': '1. 남녀 사이에 순수한 친구가 존재할 수 있나요?',
      'opt': ['네, 당연히 가능하죠!', '아니요, 절대 불가능해요']
    },
    {
      'type': 'choice',
      'q': '2. 이른바 깻잎 논쟁! 내 애인이 내 절친의 깻잎을 떼어준다면?',
      'opt': ['매너니까 전혀 상관없다', '절대 용납 못한다']
    },
    {
      'type': 'choice',
      'q': '3. 연인 혹은 썸남썸녀와의 이상적인 연락 빈도는?',
      'opt': ['틈나는 대로 계속 연락하는 편', '각자의 시간은 존중하는 편']
    },
    {
      'type': 'choice',
      'q': '4. 선호하는 여행 스타일은 어느 쪽인가요?',
      'opt': ['발길 닿는 대로! 즉흥(P) 여행', '시간표까지 완벽하게! 계획(J) 여행']
    },
    {
      'type': 'choice',
      'q': '5. 여행 중 의견 충돌이나 갈등이 생겼을 때 나는?',
      'opt': ['그 자리에서 대화로 바로 푼다', '감정을 식힐 혼자만의 시간이 필요하다']
    },
    {
      'type': 'choice',
      'q': '6. 모임에서의 술자리 선호도는?',
      'opt': ['술은 빠질 수 없죠! 즐기는 편', '술 없이도 분위기만 잘 맞춰요', '아예 마시지 않습니다']
    },
    {
      'type': 'choice',
      'q': '7. 소비를 할 때 나의 가치관에 더 가까운 것은?',
      'opt': ['비싸도 퀄리티지! 가심비 럭셔리', '합리적인 게 최고! 가성비 실속형']
    },
    {
      'type': 'choice',
      'q': '8. 새로운 사람을 만났을 때 나의 낯가림 정도는?',
      'opt': ['먼저 다가가는 편안한 스타일', '친해지기까지 시간이 꽤 필요한 편']
    },
    {
      'type': 'text',
      'q': '9. 사람을 만날 때 가장 중요하게 생각하는 가치관이나 성격은 무엇인가요?'
    },
    {
      'type': 'text',
      'q': '10. 마지막으로, 이번 모임에서 가장 기대하는 점을 자유롭게 적어주세요!'
    },
  ];

  void _next() {
    HapticFeedback.lightImpact();
    if (_currentIndex < _totalQuestions - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.fastOutSlowIn,
      );
      setState(() => _currentIndex++);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TravelPaymentScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / _totalQuestions,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B4A)),
            minHeight: 6,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1}/$_totalQuestions',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _totalQuestions,
          itemBuilder: (ctx, i) {
            final q = _q[i];
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // 큰 글자 확대 지원 및 줄바꿈 보존 타이포그래피
                  Text(
                    q['q'] as String,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      height: 1.4,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  if (q['type'] == 'choice') ...[
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: (q['opt'] as List<String>).map((opt) {
                          final bool sel = _answers[i] == opt;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _answers[i] = opt);
                                Future.delayed(const Duration(milliseconds: 220), _next);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: sel ? const Color(0xFFFFF4EB) : Colors.white,
                                  border: Border.all(
                                    color: sel ? const Color(0xFFFF6B4A) : const Color(0xFFE2E8F0),
                                    width: sel ? 2.0 : 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: sel
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFFFF6B4A).withOpacity(0.12),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  opt,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                                    color: sel ? const Color(0xFFFF6B4A) : const Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        maxLines: 6,
                        onChanged: (v) => setState(() => _answers[i] = v),
                        style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          hintText: '자유롭게 편안한 마음으로 적어주세요...',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFFF6B4A), width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.all(18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedOpacity(
                      opacity: (_answers[i] ?? '').trim().isNotEmpty ? 1.0 : 0.4,
                      duration: const Duration(milliseconds: 200),
                      child: ElevatedButton(
                        onPressed: (_answers[i] ?? '').trim().isNotEmpty ? _next : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B4A),
                          disabledBackgroundColor: const Color(0xFFE2E8F0),
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          i == _totalQuestions - 1 ? '제출하고 참여 확정하기' : '다음 질문으로',
                          style: TextStyle(
                            color: (_answers[i] ?? '').trim().isNotEmpty ? Colors.white : const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
