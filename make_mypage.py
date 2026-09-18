import io

code = '''import 'package:flutter/material.dart';
import 'soso_car_home_screen.dart';
import 'soso_car_host_screen.dart';
import 'chat_screen.dart';
import 'oomu_my_trips_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFBF9F6).withOpacity(0.9),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.local_taxi, color: Color(0xFF14422D), size: 24),
            const SizedBox(width: 4),
            const Text(
              '소소카',
              style: TextStyle(
                color: Color(0xFF14422D),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFEEEB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Text('마포구 연남동', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF414943))),
                  Icon(Icons.expand_more, size: 16, color: Color(0xFF717973)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Stack(
              children: [
                const Icon(Icons.notifications_none, color: Color(0xFF414943)),
                Positioned(
                  right: 2, top: 2,
                  child: Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA33D23),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFBF9F6), width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 16),
            _buildAiDriverCard(),
            const SizedBox(height: 16),
            _buildMannerTempCard(),
            const SizedBox(height: 16),
            _buildPraiseBadgesCard(),
            const SizedBox(height: 16),
            _buildMyCarCard(),
            const SizedBox(height: 16),
            _buildReviewsCard(),
            const SizedBox(height: 16),
            _buildAccountMenu(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _footerLink('로그아웃'),
                const Text(' · ', style: TextStyle(color: Colors.grey)),
                _footerLink('서비스 이용약관'),
                const Text(' · ', style: TextStyle(color: Colors.grey)),
                _footerLink('개인정보 처리방침'),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                      border: Border.all(color: const Color(0xFF14422D).withOpacity(0.2), width: 2),
                    ),
                    child: const Icon(Icons.person, color: Colors.grey, size: 40),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Color(0xFF14422D), shape: BoxShape.circle),
                      child: const Icon(Icons.verified_user, size: 14, color: Color(0xFFBCEECF)),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('햇살가득 지우', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFF14422D), borderRadius: BorderRadius.circular(12)),
                          child: const Row(
                            children: [
                              Icon(Icons.verified, size: 12, color: Color(0xFFBCEECF)),
                              SizedBox(width: 2),
                              Text('공식 안심 드라이버', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFBCEECF))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Color(0xFF14422D)),
                        SizedBox(width: 4),
                        Text('마포구 연남동 · 가입 1년 4개월', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFBCEECF).withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                          child: const Row(
                            children: [
                              Icon(Icons.shield, size: 12, color: Color(0xFF14422D)),
                              SizedBox(width: 4),
                              Text('면허·보험 100% 검증', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF14422D))),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFEFEEEB), borderRadius: BorderRadius.circular(12)),
                          child: const Row(
                            children: [
                              Icon(Icons.local_police, size: 12, color: Color(0xFF14422D)),
                              SizedBox(width: 4),
                              Text('베스트 드라이버', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFEFEEEB), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  children: [
                    Icon(Icons.edit, size: 14, color: Colors.black54),
                    SizedBox(width: 4),
                    Text('수정', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _metricBox('동행 횟수', '14회', '운전 8 · 동승 6'),
              const SizedBox(width: 8),
              _metricBox('안전 운전', '5년', '무사고 운행'),
              const SizedBox(width: 8),
              _metricBox('함께한 이웃', '38명', '만족도 100%', highlight: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricBox(String title, String value, String sub, {bool highlight = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFBF9F6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: highlight ? const Color(0xFFA33D23) : const Color(0xFF14422D))),
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(fontSize: 10, color: highlight ? const Color(0xFFA33D23) : Colors.grey, fontWeight: highlight ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildAiDriverCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF14422D).withOpacity(0.1),
            const Color(0xFFBCEECF).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF14422D).withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFF14422D), shape: BoxShape.circle),
            child: const Icon(Icons.verified_user, color: Color(0xFFBCEECF), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('AI 안심 드라이버 인증 완료!', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF14422D))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF14422D), borderRadius: BorderRadius.circular(4)),
                      child: const Text('승인 완료', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('경찰청 운전면허 전산 대조 및 종합보험 자격 자동 심사 통과', style: TextStyle(fontSize: 11, color: Colors.black87)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _tagBadge(Icons.trending_up, '매칭 신뢰도 2.4배 UP', color: const Color(0xFFA33D23)),
                    const SizedBox(width: 6),
                    // Removed 5000P points reference, replaced with badge mention
                    _tagBadge(Icons.verified, '첫 카풀 시 안심 배지 부여', color: const Color(0xFF14422D)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF14422D), size: 18),
        ],
      ),
    );
  }

  Widget _tagBadge(IconData icon, String text, {Color color = Colors.black}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)],
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildMannerTempCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('소소 매너온도', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 6),
                  Icon(Icons.help_outline, size: 16, color: Colors.grey),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFFDAD2), borderRadius: BorderRadius.circular(16)),
                child: const Row(
                  children: [
                    Icon(Icons.local_fire_department, size: 14, color: Color(0xFF3C0700)),
                    SizedBox(width: 4),
                    Text('상위 3% 이웃', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3C0700))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFFBF9F6), borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text('41.2°C', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFA33D23))),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_upward, size: 12, color: Color(0xFFA33D23)),
                        const Text('4.7°C', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFA33D23))),
                      ],
                    ),
                    const Row(
                      children: [
                        Text('기본 36.5°C', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        SizedBox(width: 6),
                        Text('따뜻한 열정 이웃', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF14422D))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    Container(height: 10, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(5))),
                    Container(
                      height: 10, width: 250,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF2D5A43), Color(0xFFE76F51)]),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('30°C', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('첫 온도 36.5°C', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('50°C', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFEFEEEB), borderRadius: BorderRadius.circular(8)),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.eco, size: 16, color: Color(0xFF14422D)),
                SizedBox(width: 8),
                Expanded(
                  child: Text('소소카 매너온도는 함께한 동행 이웃들의 배려와 신뢰 후기로 올라가요. 40°C를 넘은 이웃은 동네 인증 카풀 요청 수락률이 2배 더 높아요!', style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPraiseBadgesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('내가 받은 칭찬 배지', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFBCEECF), borderRadius: BorderRadius.circular(12)),
                    child: const Text('총 52개', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF002112))),
                  ),
                ],
              ),
              const Text('최근 6개월', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFBCEECF).withOpacity(0.2), border: Border.all(color: const Color(0xFF14422D).withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Color(0xFF14422D), shape: BoxShape.circle),
                  child: const Icon(Icons.shield, color: Color(0xFFBCEECF), size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('공식 안심 검증 마크 획득', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF14422D))),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(color: const Color(0xFF14422D), borderRadius: BorderRadius.circular(12)),
                            child: const Text('Special', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFBCEECF))),
                          ),
                        ],
                      ),
                      const Text('동행 안전 규정 준수 및 심사 만점', style: TextStyle(fontSize: 10, color: Colors.black54)),
                    ],
                  ),
                ),
                const Icon(Icons.verified, color: Color(0xFF14422D), size: 20),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.8,
            children: [
              _badgeItem(Icons.airline_seat_recline_extra, '안전하고 편안해요', '12회 선택', const Color(0xFF14422D), const Color(0xFFBCEECF)),
              _badgeItem(Icons.schedule, '시간 약속 칼준수', '11회 선택', const Color(0xFFA33D23), const Color(0xFFFFDAD2)),
              _badgeItem(Icons.auto_awesome, '쾌적하고 향기로워요', '9회 선택', const Color(0xFF14422D), const Color(0xFFBCEECF)),
              _badgeItem(Icons.queue_music, '선곡 센스 최고', '8회 선택', const Color(0xFF5D2E00), const Color(0xFFFFDCC4)),
              _badgeItem(Icons.forum, '따뜻하고 편한 대화', '7회 선택', Colors.black87, Colors.grey.shade300),
              _badgeItem(Icons.restaurant, '동네 숨은 맛집 마스터', '5회 선택', const Color(0xFFA33D23), const Color(0xFFFFDAD2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badgeItem(IconData icon, String title, String count, Color mainColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFFFBF9F6), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: mainColor, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87), overflow: TextOverflow.ellipsis),
                Text(count, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: mainColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyCarCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.directions_car, color: Color(0xFF14422D), size: 20),
                  SizedBox(width: 6),
                  Text('등록된 내 차량', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  Text('차량 정보 변경', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF14422D))),
                  Icon(Icons.chevron_right, size: 16, color: Color(0xFF14422D)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFFBF9F6), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('현대 아이오닉 5', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFF14422D), borderRadius: BorderRadius.circular(4)),
                          child: const Text('전기차 EV', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF14422D), borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        children: [
                          Icon(Icons.gpp_good, size: 10, color: Color(0xFFBCEECF)),
                          SizedBox(width: 4),
                          Text('안심 검증 완료', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFBCEECF))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('롱레인지 익스클루시브 · 12가 34**', style: TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.verified, size: 12, color: Color(0xFF14422D)),
                    SizedBox(width: 4),
                    Text('종합보험 가입 (대인배상 무한 · 대물 10억원 충족)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF14422D))),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: [
                    _carOptionBadge(Icons.smoke_free, '완전 금연 차량'),
                    _carOptionBadge(Icons.luggage, '트렁크 여유 (캠핑/백팩)'),
                    _carOptionBadge(Icons.pets, '소형 반려동물 케이지 가능', color: const Color(0xFFA33D23)),
                    _carOptionBadge(Icons.battery_charging_full, '스마트폰 고속 충전 지원'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _carOptionBadge(IconData icon, String text, {Color color = const Color(0xFF14422D)}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildReviewsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.2))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('이웃들의 동행 후기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 6),
                  Text('14개', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFA33D23))),
                ],
              ),
              Row(
                children: [
                  const Text('전체보기', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF14422D))),
                  const Icon(Icons.chevron_right, size: 16, color: Color(0xFF14422D)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _reviewItem('달리는 민우', '마포구 성산동', '10월 28일', '"강화도 동막해변 갈 때 음악 선곡이랑 운전이 너무 편안했어요! 처음 타보는 카풀이었는데 긴장 다 풀렸습니다 ㅎㅎ 다음에 바다 보러 갈 때 또 함께해요!"', '강화도 해변 드라이브', '운전 매너 최고', const Color(0xFFFFDAD2), const Color(0xFFA33D23)),
          const SizedBox(height: 12),
          _reviewItem('책읽는 지은', '서대문구 연희동', '10월 14일', '"파주 출판도시 북카페 갈 때 약속 시간도 정확하시고 차도 너무 쾌적하고 향기로웠어요. 조용히 책 읽으면서 편안하게 이동했습니다. 지우님 차 완전 추천해요!"', '파주 북스테이 카풀', '시간 약속 칼준수', const Color(0xFFBCEECF), const Color(0xFF14422D)),
        ],
      ),
    );
  }

  Widget _reviewItem(String name, String loc, String date, String comment, String tag1, String tag2, Color avatarBg, Color avatarTxt) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFBF9F6), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: avatarBg, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(name[4], style: TextStyle(color: avatarTxt, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text(loc, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Text(comment, style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)]), child: Text(tag1, style: const TextStyle(fontSize: 10, color: Colors.black54))),
              const SizedBox(width: 6),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFBCEECF).withOpacity(0.4), borderRadius: BorderRadius.circular(12)), child: Text(tag2, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF002112)))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.2))),
      child: Column(
        children: [
          // Remove financial wording completely from menu!
          _menuItem(Icons.receipt_long, '내 여행 히스토리 & 동행 내역', '완료된 소규모 카풀 14건', const Color(0xFF14422D)),
          const Divider(height: 1, color: Color(0xFFFBF9F6)),
          _menuItem(Icons.favorite, '관심 모임 (찜한 드라이브)', '이번 주말 가고 싶은 곳 4개', const Color(0xFFA33D23), badgeText: '4'),
          const Divider(height: 1, color: Color(0xFFFBF9F6)),
          _menuItem(Icons.group_add, '나의 동네 기여도', '이웃과의 따뜻한 동행 지수', const Color(0xFF14422D), extraText: '14회 동행'),
          const Divider(height: 1, color: Color(0xFFFBF9F6)),
          _menuItem(Icons.settings, '동네 인증 및 알림 설정', null, Colors.black54),
          const Divider(height: 1, color: Color(0xFFFBF9F6)),
          _menuItem(Icons.support_agent, '고객센터 및 안전 동행 수칙', null, Colors.black54),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, String? sub, Color iconColor, {String? badgeText, String? extraText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFFBF9F6), shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                if (sub != null) ...[
                  const SizedBox(height: 2),
                  Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ],
            ),
          ),
          if (badgeText != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFA33D23), borderRadius: BorderRadius.circular(12)),
              child: Text(badgeText, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          if (extraText != null)
            Text(extraText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF14422D))),
          if (badgeText != null || extraText != null) const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _footerLink(String text) {
    return Text(text, style: const TextStyle(fontSize: 11, color: Colors.grey, decoration: TextDecoration.underline));
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 4,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF14422D),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      onTap: (index) {
        if (index == 0) {
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const OOMUHostScreen()));
        } else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
        } else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const OOMUMyTripsScreen()));
        } else if (index == 4) {
          // 마이페이지 (현재 화면)
        }
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: '탐색'),
        const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: '모집하기'),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.chat_bubble_outline),
              Positioned(
                right: -4, top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Color(0xFFB53D25), shape: BoxShape.circle),
                  child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
          label: '채팅',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.directions_car_outlined), activeIcon: Icon(Icons.directions_car), label: '내 여행'),
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: '마이'),
      ],
    );
  }
}
'''

with io.open('lib/screens/my_page_screen.dart', 'w', encoding='utf-8') as f:
    f.write(code)
