import 'package:flutter/material.dart';

void showDriverProfileModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return const _DriverProfileModalWidget();
    },
  );
}

class _DriverProfileModalWidget extends StatelessWidget {
  const _DriverProfileModalWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 24, left: 24, right: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBCEECF), width: 3),
                  color: Colors.grey.shade100,
                ),
                child: const Icon(Icons.person, size: 50, color: Colors.grey),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: const Color(0xFF14422D), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  child: const Icon(Icons.verified, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('달리는 민우', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(width: 6),
              const Text('(32세)', style: TextStyle(fontSize: 16, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF14422D), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  children: [
                    Icon(Icons.shield, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text('공식 안심 드라이버', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFBF9F6), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Color(0xFFA33D23)),
                    SizedBox(width: 4),
                    Text('마포구 연남동 2년차', style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(20)),
            child: const Text('가입 2023.04 (1년 6개월)', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ),
          const SizedBox(height: 24),
          const Text(
            '"안전하고 기분 좋은 동네 드라이브를 지향합니다 🚗✨ 주말엔 주로 강화도, 파주 쪽 다녀요!"',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _metricBox('동행 횟수', '28회', '운전 24 · 동승 4', Colors.black87, Colors.grey),
              const SizedBox(width: 12),
              _metricBox('안전 운전', '무사고', '6년 연속 안전', const Color(0xFF14422D), const Color(0xFFBCEECF)),
              const SizedBox(width: 12),
              _metricBox('매너온도', '42.8°C', '상위 1% 호스트', const Color(0xFFA33D23), const Color(0xFFFFDAD2)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F8F4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2EFE7)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Color(0xFF14422D), borderRadius: BorderRadius.all(Radius.circular(6))),
                      child: const Text('AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('AI 전산망 실시간 공인 검증 완료', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFE2EFE7), borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        children: [
                          Icon(Icons.circle, size: 6, color: Color(0xFF14422D)),
                          SizedBox(width: 4),
                          Text('적격 판정', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF14422D))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _aiCheckItem('경찰청 실시간 전산 대조 면허 적격', '2종 보통 · 적성검사 유효 (2027년까지 갱신 완료)'),
                const SizedBox(height: 12),
                _aiCheckItem('종합보험 실시간 가입 검증 완료', '대인배상 II (무한) · 대물배상 (10억원 보상 가입)'),
                const SizedBox(height: 12),
                _aiCheckItem('본인 명의 실명 및 통신사 3사 인증', '신원 불일치 0건 · 마포구 실거주 생활권 인증 완료'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 16, color: Colors.black87),
                        SizedBox(width: 8),
                        Text('1:1 대화하기', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF14422D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('민우님의 여행 모임 보기 →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _metricBox(String title, String value, String sub, Color mainColor, Color subBgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mainColor)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: subBgColor.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
              child: Text(sub, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: mainColor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiCheckItem(String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, size: 16, color: Colors.black87),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
