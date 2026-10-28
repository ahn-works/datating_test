import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import '../services/kakao_map_service.dart';
import '../widgets/kakao_map_view.dart';
import '../widgets/interactive_map_popup.dart';
import '../utils/app_image.dart';
import '../utils/global_data.dart';
import '../utils/oomu_ui_helpers.dart';
import 'soso_car_chat_screen.dart';
import 'user_profile_screen.dart';

/// OOMU 모임 상세 화면 - 100점 풀-피니시 (29CM 에디토리얼 + TDS 제로프릭션 + 카카오맵 네이티브 뷰)
class OOMUDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? meetup;
  const OOMUDetailScreen({super.key, this.meetup});

  @override
  State<OOMUDetailScreen> createState() => _OOMUDetailScreenState();
}

class _OOMUDetailScreenState extends State<OOMUDetailScreen> {
  bool _isApplying = false;
  final TextEditingController _applyMsgController = TextEditingController();

  // 디자인 토큰 (docs/OOMU_UI_GUIDE.md 기준)
  final Color textPrimary = OomuUiHelpers.textPrimary;
  final Color textSecondary = OomuUiHelpers.textSecondary;
  final Color surfaceColor = OomuUiHelpers.backgroundNeutral;
  final Color coralAccent = OomuUiHelpers.brandCoral;
  final Color borderSubtle = OomuUiHelpers.borderSubtle;
  final Color destructiveColor = const Color(0xFFE11D48);

  bool _isFavorite = false;

  // 카카오 지도 연동 좌표 및 실시간 거리 (미검증 기본 좌표 하드코딩 배제)
  double? _targetLat;
  double? _targetLng;
  bool _isResolvingLocation = true;
  String _distanceText = '거리 계산 중...';
  int _locationReqId = 0;

  bool get _isLightning {
    final m = widget.meetup;
    if (m == null) return false;
    if (m['isLightning'] == true) return true;
    final id = (m['id'] ?? '').toString();
    if (id.startsWith('spot_')) return true;
    final cat = (m['category'] ?? '').toString();
    final mainCat = (m['mainCategory'] ?? '').toString();
    final date = (m['date'] ?? m['time'] ?? '').toString();
    final title = (m['title'] ?? '').toString();
    final tags = (m['tags'] as List?)?.join(' ') ?? '';
    final combined = '$cat $mainCat $date $title $tags'.toLowerCase();
    return combined.contains('오늘') ||
        combined.contains('번개') ||
        combined.contains('10분') ||
        combined.contains('즉시');
  }

  String _formatTitleKeepWords(String? title) {
    return OomuUiHelpers.formatTitle(title, fallback: '취향 모임');
  }

  String _calcRemainingSeats(dynamic memberRaw) {
    return OomuUiHelpers.calcRemainingSeats(memberRaw);
  }

  @override
  void initState() {
    super.initState();
    _isFavorite = globalData.isFavorite(widget.meetup?['id'] ?? widget.meetup?['title']);
    _initLocationState();
  }

  @override
  void didUpdateWidget(covariant OOMUDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.meetup != widget.meetup) {
      _isFavorite = globalData.isFavorite(widget.meetup?['id'] ?? widget.meetup?['title']);
      _initLocationState();
    }
  }

  @override
  void dispose() {
    _applyMsgController.dispose();
    super.dispose();
  }

  // 저장된 좌표 우선 사용 및 장소명 검증 기반 거리 동기화
  Future<void> _initLocationState() async {
    final int reqId = ++_locationReqId;
    final saved = OomuUiHelpers.extractValidCoords(widget.meetup);

    if (saved != null) {
      if (mounted) {
        setState(() {
          _targetLat = saved.lat;
          _targetLng = saved.lng;
          _isResolvingLocation = false;
          _distanceText = '거리 계산 중...';
        });
      }
      final dist = await KakaoMapService.getDistanceTextFromCurrent(saved.lat, saved.lng);
      if (!mounted || reqId != _locationReqId) return;
      setState(() {
        _distanceText = dist;
      });
      return;
    }

    if (mounted) {
      setState(() {
        _targetLat = null;
        _targetLng = null;
        _isResolvingLocation = true;
        _distanceText = '거리 계산 중...';
      });
    }

    final loc = (widget.meetup?['location'] ?? '').toString().trim();
    if (loc.isEmpty) {
      if (!mounted || reqId != _locationReqId) return;
      setState(() {
        _targetLat = null;
        _targetLng = null;
        _isResolvingLocation = false;
        _distanceText = '거리 확인 불가';
      });
      return;
    }

    try {
      final verified = await KakaoMapService.resolveVerifiedPlace(loc);
      if (!mounted || reqId != _locationReqId) return;
      if (verified != null && verified.hasValidCoords) {
        setState(() {
          _targetLat = verified.lat;
          _targetLng = verified.lng;
          _isResolvingLocation = false;
        });
        final dist = await KakaoMapService.getDistanceTextFromCurrent(verified.lat, verified.lng);
        if (!mounted || reqId != _locationReqId) return;
        setState(() {
          _distanceText = dist;
        });
      } else {
        setState(() {
          _targetLat = null;
          _targetLng = null;
          _isResolvingLocation = false;
          _distanceText = '거리 확인 불가';
        });
      }
    } catch (_) {
      if (!mounted || reqId != _locationReqId) return;
      setState(() {
        _targetLat = null;
        _targetLng = null;
        _isResolvingLocation = false;
        _distanceText = '거리 확인 불가';
      });
    }
  }

  // 매너온도 게이지 (데이터 유무 및 동일 기준 통일)
  Widget _buildMannerGauge(double? temp) {
    if (temp == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '매너온도 정보 없음',
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: textSecondary),
        ),
      );
    }

    final Color tempColor = OomuUiHelpers.mannerTempColor(temp);
    final String emoji = OomuUiHelpers.mannerTempEmoji(temp);
    final progress = (temp / 100.0).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                '${temp.toStringAsFixed(1)}°C',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: tempColor),
              ),
            ),
            const SizedBox(width: 4),
            Text(emoji, style: const TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 90,
          height: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(tempColor),
            ),
          ),
        ),
      ],
    );
  }

  // 참여 신청 바텀시트
  void _showApplicationBottomSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool withFriend = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 24,
                right: 24,
                top: 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('참여 신청 메시지', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary)),
                        IconButton(icon: Icon(Icons.close, color: textSecondary), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '모임장에게 간단한 자기소개나 인사말을 남겨주세요!',
                      style: TextStyle(fontSize: 13.5, color: textSecondary, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderSubtle),
                      ),
                      child: TextField(
                        controller: _applyMsgController,
                        maxLines: 4,
                        style: TextStyle(color: textPrimary, fontSize: 14.5),
                        decoration: const InputDecoration(
                          hintText: '예) 안녕하세요! 주말에 가볍게 수다 떨며 즐겁게 함께하고 싶어 신청합니다 :)',
                          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 여성 안심 동반 참석(+1) 옵션
                    GestureDetector(
                      onTap: () {
                        setModalState(() => withFriend = !withFriend);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: withFriend ? const Color(0xFFFFF0F2) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: withFriend ? coralAccent : borderSubtle),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.group_add_rounded, color: withFriend ? coralAccent : textSecondary, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('지인 1명과 함께 가기 (+1 동반)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                  const SizedBox(height: 2),
                                  Text(
                                    withFriend ? '✨ 동반 참석(+1)으로 신청됩니다' : '낯선 모임이 처음이라면 찐친과 함께 참석해 보세요!',
                                    style: TextStyle(
                                      color: withFriend ? coralAccent : textSecondary,
                                      fontSize: 11.5,
                                      fontWeight: withFriend ? FontWeight.w700 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: withFriend,
                              onChanged: (val) => setModalState(() => withFriend = val ?? false),
                              activeColor: coralAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() => _isApplying = true);
                          HapticFeedback.mediumImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('참여 신청을 보냈습니다. 호스트의 승인을 기다려주세요.'),
                              backgroundColor: coralAccent,
                            ),
                          );

                          // 3초 후 승인 완료 시뮬레이션
                          Future.delayed(const Duration(seconds: 3), () {
                            if (!mounted) return;
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: const Text('🎉 승인 완료!'),
                                content: const Text('호스트님이 참여를 승인했습니다.\n채팅방으로 이동할까요?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('닫기', style: TextStyle(color: textSecondary)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      final rId = oomuChatStore.canonicalRoomId(widget.meetup?['id'] ?? 'room_mala_01');
                                      oomuChatStore.rejoinRoom(rId);
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => OOMUChatScreen(
                                            title: (widget.meetup != null ? widget.meetup!['title'] : '모임 단톡방'),
                                            memberCount: 4,
                                            chatRoomId: rId,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: coralAccent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('채팅방 이동', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: coralAccent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('신청서 전송하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 모임 신고 바텀시트
  void _showMeetupReportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.report_problem_outlined, color: Colors.redAccent),
                title: const Text('이 모임 신고하기', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('부적절한 목적이나 스팸성 모임을 신고합니다', style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showReportReasonDialog(context);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showReportReasonDialog(BuildContext context) {
    final reasons = ['부적절한 만남 유도', '스팸 및 상업적 홍보', '위험 및 불법적인 내용', '허위 정보 / 사칭'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('신고 사유를 선택해 주세요', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reasons.map((r) => ListTile(
            title: Text(r, style: const TextStyle(fontSize: 14)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            onTap: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('운영진에게 접수되었습니다. 24시간 내 검토 후 조치됩니다.'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
          )).toList(),
        ),
      ),
    );
  }

  List<String> _extractHostPraiseTags(Map<String, dynamic>? m) {
    if (m == null) return const [];
    final raw = m['praiseTags'] ?? m['hostBadges'];
    if (raw is List) {
      return raw.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final locName = (widget.meetup?['location'] ?? '장소 정보 없음').toString();
    final double? hostManner = OomuUiHelpers.parseMannerTemp(widget.meetup);
    final bool isHostVerified = widget.meetup?['isVerified'] == true || widget.meetup?['hostVerified'] == true;
    final List<String> praiseTags = _extractHostPraiseTags(widget.meetup);
    final bool hasResolvedCoords = _targetLat != null && _targetLng != null;
    final bool isDistanceUnknown = _distanceText == '거리 확인 불가' || _distanceText == '거리 계산 중...';

    return Scaffold(
      backgroundColor: surfaceColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. 슬리버 패럴랙스 헤더 (SliverAppBar - 적정 높이 240dp로 조정하여 본문 가시성 확보)
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF0F172A),
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                child: IconButton(
                  tooltip: '뒤로가기',
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                  child: IconButton(
                    tooltip: '상단 찜하기',
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? destructiveColor : Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() => _isFavorite = !_isFavorite);
                      if (widget.meetup != null) {
                        globalData.toggleFavorite(widget.meetup!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isFavorite ? '❤️ 찜한 모임에 추가되었습니다' : '💔 찜한 모임에서 제거되었습니다'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              IconButton(
                tooltip: '모임 신고',
                icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                onPressed: () => _showMeetupReportBottomSheet(context),
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  appNetImage(
                    (widget.meetup != null && widget.meetup!['imageUrl'] != null)
                        ? widget.meetup!['imageUrl']
                        : 'assets/images/cover_food.jpg',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.45),
                          Colors.transparent,
                          Colors.black.withOpacity(0.75),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. 메인 컨텐츠 시트 (순백 `#FFFFFF` 카드 서피스 + 곡률 32dp 오버랩)
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -32, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A. 상단 뱃지 행
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (_isLightning)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: coralAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                                SizedBox(width: 3),
                                Text(
                                  '실시간 당일 번개',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11.5),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: borderSubtle)),
                            child: Text(
                              (widget.meetup != null ? (widget.meetup!['category'] ?? widget.meetup!['mainCategory'] ?? '일상 & 푸드') : '동네 맛집 & 소셜 다이닝'),
                              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 11.5),
                            ),
                          ),
                        if (widget.meetup?['isFemaleOnly'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: const Color(0xFFFFF0F2), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFF8C6CD))),
                            child: const Text(
                              '여성 안심 전용',
                              style: TextStyle(color: Color(0xFFC83243), fontWeight: FontWeight.bold, fontSize: 11.5),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // B. 모임 메인 타이틀 (이모지 안전한 줄바꿈)
                    Text(
                      _formatTitleKeepWords(
                        (widget.meetup != null && widget.meetup!['title'] != null)
                            ? widget.meetup!['title'].toString()
                            : '주말 엽떡+마라탕 조지실 분 구해요!',
                      ),
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.38,
                      ),
                    ),
                    const SizedBox(height: 26),

                    // 번개 안내 콜아웃 카드 (브랜드 틴트 + 단색 아이콘 정돈)
                    if (_isLightning) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5F6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF7D9DE)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: coralAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '오늘 바로 만나는 실시간 번개 모임',
                                    style: TextStyle(color: Color(0xFFC83243), fontWeight: FontWeight.w800, fontSize: 13.5),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '대기 시간 없이 즉시 채팅방으로 연결되어 바로 합류할 수 있습니다.',
                                    style: TextStyle(color: textSecondary, fontSize: 12, height: 1.35),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // 1. 모임 기본 정보 카드 (일시, 장소, 이동, 실제 비용 데이터 있을 때만 표시)
                    Text('모임 정보', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textPrimary)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: borderSubtle),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.calendar_today_rounded, '일시', (widget.meetup?['date'] ?? '이번주 토요일 18:00').toString()),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: Color(0xFFF1F5F9))),
                          _buildInfoRow(Icons.location_on_rounded, '장소', locName),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: Color(0xFFF1F5F9))),
                          _buildInfoRow(Icons.directions_subway_rounded, '이동', (widget.meetup?['transport'] ?? '대중교통 / 각자 이동').toString()),
                          if (widget.meetup != null && (widget.meetup!['fee'] != null || widget.meetup!['cost'] != null || widget.meetup!['price'] != null)) ...[
                            const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: Color(0xFFF1F5F9))),
                            _buildInfoRow(
                              Icons.payments_rounded,
                              '비용',
                              (widget.meetup!['fee'] ?? widget.meetup!['cost'] ?? widget.meetup!['price']).toString(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 2. 참여 멤버 아바타 스택 (정원 및 잔여석 안내)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '참여 멤버',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textPrimary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0F2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${widget.meetup?['members'] ?? '2/4'}명 참여',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12.5, color: coralAccent, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _buildMemberAvatar((widget.meetup?['hostAvatar'] ?? 'assets/images/kr_female_1.jpg').toString(), isHost: true),
                        Transform.translate(
                          offset: const Offset(-12, 0),
                          child: _buildMemberAvatar('assets/images/kr_male_2.jpg', isHost: false),
                        ),
                        Transform.translate(
                          offset: const Offset(-24, 0),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: borderSubtle, width: 2),
                            ),
                            child: Icon(Icons.add, color: textSecondary, size: 20),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(-36, 0),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: borderSubtle, width: 2),
                            ),
                            child: Icon(Icons.add, color: textSecondary, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF5E8EB)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 16, color: coralAccent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '현재 ${_calcRemainingSeats(widget.meetup?['members'])} (정원 ${widget.meetup?['maxMembers'] ?? '4명'})',
                              style: TextStyle(fontSize: 12.5, color: textSecondary, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 3. 이 모임을 여는 호스트 - 독립된 강조 카드 (실제 데이터 기반)
                    Text('이 모임을 여는 호스트', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textPrimary)),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9FA),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF7D9DE), width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              final hostName = (widget.meetup != null ? (widget.meetup!['host'] ?? '모임 호스트') : '매운맛킬러').toString();
                              final hostAvatar = (widget.meetup != null && widget.meetup!['hostAvatar'] != null)
                                  ? widget.meetup!['hostAvatar'].toString()
                                  : 'assets/images/kr_female_1.jpg';
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UserProfileScreen(
                                    userName: hostName,
                                    userAvatar: hostAvatar,
                                    userManner: hostManner,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 27,
                                  backgroundImage: appImg(
                                    (widget.meetup != null && widget.meetup!['hostAvatar'] != null)
                                        ? widget.meetup!['hostAvatar'].toString()
                                        : 'assets/images/kr_female_1.jpg',
                                  ),
                                  backgroundColor: surfaceColor,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              (widget.meetup != null ? (widget.meetup!['host'] ?? '모임 호스트') : '매운맛킬러').toString(),
                                              style: TextStyle(fontSize: 17.5, fontWeight: FontWeight.w700, color: textPrimary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF3D3135),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                '호스트',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isHostVerified ? Icons.verified_user_rounded : Icons.person_pin_circle_outlined,
                                            color: isHostVerified ? const Color(0xFF0D9488) : textSecondary,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              isHostVerified ? 'PASS 본인인증 호스트' : '동네 모임 호스트',
                                              style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Flexible(child: _buildMannerGauge(hostManner)),
                              ],
                            ),
                          ),
                          if (widget.meetup != null && widget.meetup!['hostBio'] != null && widget.meetup!['hostBio'].toString().trim().isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Text(
                              widget.meetup!['hostBio'].toString().trim(),
                              style: TextStyle(fontSize: 13.5, height: 1.5, color: textPrimary),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (praiseTags.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            const Divider(height: 1, color: Color(0xFFF3D5DB)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: praiseTags.map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                                  decoration: BoxDecoration(
                                    color: surfaceColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFF0E4E6)),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                final hostName = (widget.meetup != null ? (widget.meetup!['host'] ?? '모임 호스트') : '매운맛킬러').toString();
                                final hostAvatar = (widget.meetup != null && widget.meetup!['hostAvatar'] != null)
                                    ? widget.meetup!['hostAvatar'].toString()
                                    : 'assets/images/kr_female_1.jpg';
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UserProfileScreen(
                                      userName: hostName,
                                      userAvatar: hostAvatar,
                                      userManner: hostManner,
                                    ),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFF4C2CB)),
                                backgroundColor: Colors.white,
                                foregroundColor: textPrimary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                minimumSize: const Size.fromHeight(48),
                              ),
                              icon: Icon(Icons.person_outline_rounded, size: 16, color: coralAccent),
                              label: const Text('호스트 프로필 보기', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 4. 모임 소개 & 이런 분을 찾아요
                    Text('모임 소개', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textPrimary)),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderSubtle),
                      ),
                      child: Text(
                        (widget.meetup?['description'] ??
                            "스트레스 팍팍 받는 주말엔 역시 매운 음식과 기분 좋은 대화 아니겠습니까? 🔥\n\n취향과 라이프스타일이 통하는 동네 이웃과 편안하게 이야기 나누며 스트레스 풀 분 구해요!\n\n식사 후에는 근처 감성 카페에서 커피 한 잔 하며 주말을 여유롭게 마무리해요 :)").toString(),
                        style: TextStyle(fontSize: 14.5, height: 1.62, color: textPrimary),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 5. 모임 장소 & 카카오 지도 (좌표 유무·거리 상태 명확히 구분)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '모임 장소 & 지도',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textPrimary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDistanceUnknown ? const Color(0xFFF1F5F9) : const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isDistanceUnknown ? borderSubtle : const Color(0xFFA7F3D0)),
                            ),
                            child: Text(
                              _distanceText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: isDistanceUnknown ? textSecondary : const Color(0xFF0D9488),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: borderSubtle),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasResolvedCoords)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                              child: SizedBox(
                                height: 170,
                                width: double.infinity,
                                child: Stack(
                                  children: [
                                    KakaoMapView(
                                      key: ValueKey('kakao-detail-$_targetLat-$_targetLng'),
                                      lat: _targetLat!,
                                      lng: _targetLng!,
                                      locationName: locName,
                                      height: 170,
                                      hideActions: true,
                                    ),
                                    Positioned(
                                      right: 10,
                                      top: 10,
                                      child: GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          showDialog(
                                            context: context,
                                            builder: (_) => InteractiveMapPopup(
                                              initialCenter: LatLng(_targetLat!, _targetLng!),
                                              locationName: locName,
                                              kakaoLink: KakaoMapService.getKakaoRouteUrl(locName, _targetLat!, _targetLng!),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.75),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.fullscreen_rounded, size: 14, color: Colors.white),
                                              SizedBox(width: 4),
                                              Text('전체화면 지도', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else if (_isResolvingLocation)
                            Container(
                              height: 140,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2.2, color: coralAccent),
                                  ),
                                  const SizedBox(height: 10),
                                  Text('장소 좌표를 확인하고 있어요...', style: TextStyle(fontSize: 12.5, color: textSecondary)),
                                ],
                              ),
                            )
                          else
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: borderSubtle),
                                    ),
                                    child: Icon(Icons.location_searching_rounded, color: textSecondary, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '정확한 위치를 확인할 수 없어요',
                                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: textPrimary),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '장소명만으로 상세 좌표를 특정할 수 없어 지도를 숨겼습니다. 아래 주소와 길찾기 검색을 이용해 주세요.',
                                          style: TextStyle(fontSize: 12, color: textSecondary, height: 1.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        locName,
                                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: textPrimary),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '모임 시간 10분 전 현장 도착을 권장합니다',
                                        style: TextStyle(fontSize: 12, color: textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFFBEA),
                                    side: const BorderSide(color: Color(0xFFF6D84C)),
                                    foregroundColor: const Color(0xFF333333),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    minimumSize: const Size(48, 48),
                                  ),
                                  icon: const Icon(Icons.directions_rounded, size: 16, color: Color(0xFF333333)),
                                  label: const Text('길찾기', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                  onPressed: () => KakaoMapService.launchDirections(locName, lat: _targetLat, lng: _targetLng),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 75),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // 3. 하단 고정 참여 신청 바 (Sticky Bottom CTA Bar)
      bottomSheet: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // 찜하기 버튼 (52x52dp 1:1 수평 대칭 및 터치영역 확보)
              SizedBox(
                width: 52,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderSubtle),
                  ),
                  child: IconButton(
                    tooltip: '찜하기',
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
                      color: _isFavorite ? destructiveColor : textSecondary,
                      size: 22,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() => _isFavorite = !_isFavorite);
                      if (widget.meetup != null) {
                        globalData.toggleFavorite(widget.meetup!);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 핵심 신청 버튼
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      if (_isLightning) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('⚡ 실시간 번개 모임에 합류했습니다! 채팅방으로 바로 연결됩니다.'),
                            backgroundColor: coralAccent,
                          ),
                        );
                        final rId = oomuChatStore.canonicalRoomId(widget.meetup?['id'] ?? 'lightning_room_01');
                        oomuChatStore.rejoinRoom(rId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OOMUChatScreen(
                              title: widget.meetup?['title'] ?? '실시간 번개 팟',
                              memberCount: 3,
                              chatRoomId: rId,
                            ),
                          ),
                        );
                      } else {
                        if (!_isApplying) {
                          _showApplicationBottomSheet(context);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: coralAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isLightning) ...[
                          const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          _isLightning
                              ? '지금 바로 번개 합류하기'
                              : (_isApplying ? '신청 확인 중...' : '참여 신청하기'),
                          style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, color: textSecondary, size: 20),
        ),
        const SizedBox(width: 14),
        SizedBox(
          width: 50,
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(title, style: TextStyle(color: textSecondary, fontSize: 14)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textPrimary, height: 1.35),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Widget _buildMemberAvatar(String url, {required bool isHost}) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4),
            ],
          ),
          child: CircleAvatar(radius: 24, backgroundImage: appImg(url)),
        ),
        if (isHost)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(3.5),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                shape: BoxShape.circle,
              ),
              child: const Text('👑', style: TextStyle(fontSize: 10)),
            ),
          )
      ],
    );
  }
}
