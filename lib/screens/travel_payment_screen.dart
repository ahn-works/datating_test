import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'travel_gps_checkin_screen.dart';

class TravelPaymentScreen extends StatefulWidget {
  const TravelPaymentScreen({super.key});

  @override
  State<TravelPaymentScreen> createState() => _TravelPaymentScreenState();
}

class _TravelPaymentScreenState extends State<TravelPaymentScreen> {
  bool _agreedToRules = true;
  bool _isProcessing = false;

  void _confirmParticipation() {
    if (!_agreedToRules) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('1/N 안심 정산 및 노쇼 방지 규정에 동의해주세요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TravelGpsCheckinScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F7), // OOMU 오트밀 로즈 크림
      appBar: AppBar(
        title: const Text(
          '참여 확정 및 정산 안내',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 모임 안내 헤더
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEFF1F5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4EB),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '1/N 안심 정산 모임',
                      style: TextStyle(
                        color: Color(0xFFFF6B4A),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '이번 주말 양양 드라이브 서핑 🚙',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '9월 19일 (토) 오전 8:00 출발 · 서울 잠실역 4번 출구',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. 1/N 정산 원칙 상세 카드 (원화 직접 표기 배제 원칙 100% 준수)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEFF1F5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.receipt_long_rounded, color: Color(0xFFFF6B4A), size: 20),
                      SizedBox(width: 8),
                      Text(
                        '투명 1/N 정산 안내',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildBillingRow('사전 참가비', '0원 (무료 참여)', isHighlight: false),
                  const SizedBox(height: 12),
                  _buildBillingRow('정산 방식', '현장 실비 1/N 균등 정산', isHighlight: true),
                  const SizedBox(height: 12),
                  _buildBillingRow('정산 수단', '토스 / 카카오페이 간편 송금', isHighlight: false),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(color: Color(0xFFF1F5F9), height: 1),
                  ),
                  const Text(
                    '• 모임 중 발생한 주유비, 톨게이트비, 식대는 모임 종료 즉시 영수증을 등록하여 N등분 정산됩니다.\n• 주최자(호스트)에게 사적으로 선입금하지 마세요.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. 노쇼 방지 및 매너 서약 카드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreedToRules,
                    activeColor: const Color(0xFFFF6B4A),
                    onChanged: (v) => setState(() => _agreedToRules = v ?? false),
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '노쇼(No-show) 방지 및 매너 서약',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '약속 시간 2시간 전 무단 불참 및 연락 두절 시 OOMU 서비스 영구 정지 및 매너온도 대폭 하향 조치됩니다.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 하단 고정 신청 완료 버튼
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            )
          ],
          border: const Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1.0)),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _confirmParticipation,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B4A),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : const Text(
                    '1/N 안심 서약하고 참여 확정',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillingRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isHighlight ? const Color(0xFFFF6B4A) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
