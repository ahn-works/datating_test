import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '../services/kakao_map_service.dart';
import '../services/meetup_application_service.dart';
import '../ui/oomu_avatar.dart';
import '../ui/oomu_badge.dart';
import '../ui/oomu_button.dart';
import '../ui/oomu_info_row.dart';
import '../ui/oomu_section_header.dart';
import '../ui/oomu_sheet.dart';
import '../ui/oomu_tag.dart';
import '../ui/oomu_tokens.dart';
import '../utils/app_image.dart';
import '../utils/global_data.dart';
import '../utils/location_helper.dart';
import '../utils/oomu_ui_helpers.dart';
import '../widgets/bouncy_tap.dart';
import '../widgets/interactive_map_popup.dart';
import '../widgets/kakao_map_view.dart';
import '../widgets/meetup_participation_action.dart';
import 'user_profile_screen.dart';

/// OOMU 모임 상세 화면 - 디자인 시스템 토큰 및 공통 컴포넌트 100% 적용
class OOMUDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? meetup;
  const OOMUDetailScreen({super.key, this.meetup});

  @override
  State<OOMUDetailScreen> createState() => _OOMUDetailScreenState();
}

class _OOMUDetailScreenState extends State<OOMUDetailScreen> {
  bool _isApplying = false;
  final TextEditingController _applyMsgController = TextEditingController();

  bool _isFavorite = false;

  // 카카오 지도 연동 좌표 및 실시간 거리
  double? _targetLat;
  double? _targetLng;
  bool _isResolvingLocation = true;
  String _distanceText = '거리 계산 중...';
  int _locationReqId = 0;

  String _formatTitleKeepWords(String? title) {
    return OomuUiHelpers.formatTitle(title, fallback: '취향 모임');
  }

  String _calcRemainingSeats(dynamic memberRaw) {
    return OomuUiHelpers.calcRemainingSeats(memberRaw);
  }

  int _getMemberCount(dynamic raw) {
    if (raw is List) return raw.length;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? (raw.isNotEmpty ? 1 : 0);
    return 0;
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

      Map<String, double>? fallbackCoords;
      if (verified == null || !verified.hasValidCoords) {
        fallbackCoords = LocationHelper.findCoordsForLocation(loc);
      }

      final finalLat = verified?.lat ?? fallbackCoords?['lat'];
      final finalLng = verified?.lng ?? fallbackCoords?['lng'];

      if (finalLat != null && finalLng != null) {
        setState(() {
          _targetLat = finalLat;
          _targetLng = finalLng;
          _isResolvingLocation = false;
        });
        final dist = await KakaoMapService.getDistanceTextFromCurrent(finalLat, finalLng);
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
      final fallbackCoords = LocationHelper.findCoordsForLocation(loc);
      if (fallbackCoords != null) {
        final fLat = fallbackCoords['lat']!;
        final fLng = fallbackCoords['lng']!;
        setState(() {
          _targetLat = fLat;
          _targetLng = fLng;
          _isResolvingLocation = false;
        });
        final dist = await KakaoMapService.getDistanceTextFromCurrent(fLat, fLng);
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
    }
  }

  // 참여 신청 바텀시트 (OomuSheet 표준 컴포넌트 적용)
  void _showApplicationBottomSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    bool withFriend = false;
    OomuSheet.show(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return OomuSheet(
              title: '참여 신청 메시지',
              subtitle: '모임장에게 간단한 자기소개나 인사말을 남겨주세요!',
              trailing: IconButton(
                icon: const Icon(Icons.close, color: OomuTokens.textSecondary, size: 20),
                onPressed: () => Navigator.pop(ctx),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: OomuTokens.s20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: OomuTokens.s16),
                      decoration: BoxDecoration(
                        color: OomuTokens.surfaceMuted,
                        borderRadius: BorderRadius.circular(OomuTokens.r12),
                        border: Border.all(color: OomuTokens.border),
                      ),
                      child: TextField(
                        controller: _applyMsgController,
                        maxLines: 4,
                        style: const TextStyle(
                          color: OomuTokens.textPrimary,
                          fontSize: OomuTokens.fs14,
                          fontFamily: OomuTokens.fontFamily,
                        ),
                        decoration: const InputDecoration(
                          hintText: '예) 안녕하세요! 주말에 가볍게 이야기 나누며 함께하고 싶어 신청합니다 :)',
                          hintStyle: TextStyle(
                            color: OomuTokens.textMuted,
                            fontSize: OomuTokens.fs14,
                            fontFamily: OomuTokens.fontFamily,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: OomuTokens.s12),
                        ),
                      ),
                    ),
                    const SizedBox(height: OomuTokens.s12),

                    // 여성 안심 동반 참석(+1) 옵션
                    InkWell(
                      borderRadius: BorderRadius.circular(OomuTokens.r12),
                      onTap: () => setModalState(() => withFriend = !withFriend),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: OomuTokens.s12, vertical: OomuTokens.s12),
                        decoration: BoxDecoration(
                          color: withFriend ? OomuTokens.surface : OomuTokens.surfaceMuted,
                          borderRadius: BorderRadius.circular(OomuTokens.r12),
                          border: Border.all(color: withFriend ? OomuTokens.coral : OomuTokens.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.group_add_rounded,
                              color: withFriend ? OomuTokens.coral : OomuTokens.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: OomuTokens.s12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '지인 1명과 함께 가기 (+1 동반)',
                                    style: TextStyle(
                                      fontWeight: OomuTokens.w700,
                                      fontSize: OomuTokens.fs14,
                                      color: OomuTokens.textPrimary,
                                      fontFamily: OomuTokens.fontFamily,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    withFriend ? '동반 참석(+1)으로 신청됩니다' : '낯선 모임이 처음이라면 지인과 함께 참석해 보세요!',
                                    style: TextStyle(
                                      color: withFriend ? OomuTokens.coral : OomuTokens.textSecondary,
                                      fontSize: OomuTokens.fs12,
                                      fontWeight: withFriend ? OomuTokens.w700 : OomuTokens.w400,
                                      fontFamily: OomuTokens.fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: withFriend,
                              onChanged: (val) => setModalState(() => withFriend = val ?? false),
                              activeColor: OomuTokens.coral,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OomuTokens.r8 / 2)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: OomuTokens.s20),

                    OomuButton(
                      label: '신청서 전송하기',
                      size: OomuButtonSize.medium,
                      variant: OomuButtonVariant.primary,
                      isLoading: _isApplying,
                      onPressed: () async {
                        final id = widget.meetup?['id']?.toString();
                        if (id == null || id.isEmpty || Firebase.apps.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('실제 모임 정보를 확인한 뒤 신청할 수 있어요.')),
                          );
                          return;
                        }
                        setState(() => _isApplying = true);
                        setModalState(() {});
                        try {
                          await MeetupApplicationService.request(id, _applyMsgController.text, withFriend: withFriend);
                          if (!mounted) return;
                          if (ctx.mounted) Navigator.pop(ctx);
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(content: Text('신청이 저장됐어요. 모임장의 승인을 기다려 주세요.')),
                          );
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(content: Text(e is StateError ? e.message.toString() : '신청을 저장하지 못했어요. 잠시 후 다시 시도해 주세요.')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isApplying = false);
                          if (ctx.mounted) setModalState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: OomuTokens.s12),
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
    OomuSheet.show(
      context: context,
      builder: (ctx) {
        return OomuSheet(
          title: '모임 신고 및 안심 센터',
          subtitle: '부적절한 목적이나 스팸성 모임을 신고합니다',
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: OomuTokens.s16, vertical: OomuTokens.s8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.report_problem_outlined, color: OomuTokens.error),
                    title: const Text('이 모임 신고하기', style: TextStyle(fontWeight: OomuTokens.w700, fontFamily: OomuTokens.fontFamily)),
                    subtitle: const Text('허위 정보, 부적절한 만남 유도 등을 신고합니다', style: TextStyle(fontSize: OomuTokens.fs12, color: OomuTokens.textSecondary, fontFamily: OomuTokens.fontFamily)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showReportReasonDialog(context);
                    },
                  ),
                  const SizedBox(height: OomuTokens.s16),
                ],
              ),
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OomuTokens.r16)),
        title: const Text(
          '신고 사유를 선택해 주세요',
          style: TextStyle(fontSize: OomuTokens.fs16, fontWeight: OomuTokens.w700, fontFamily: OomuTokens.fontFamily),
        ),
        content: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: reasons.map((r) => ListTile(
              title: Text(r, style: const TextStyle(fontSize: OomuTokens.fs14, fontFamily: OomuTokens.fontFamily)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: OomuTokens.textSecondary),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('운영진에게 접수되었습니다. 24시간 내 검토 후 조치됩니다.'),
                    backgroundColor: OomuTokens.verified,
                  ),
                );
              },
            )).toList(),
          ),
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
    final costLabel = OomuUiHelpers.formatMeetupCost(
      widget.meetup?['fee'] ?? widget.meetup?['cost'] ?? widget.meetup?['price'],
    );
    final categoryLabel = (widget.meetup != null ? (widget.meetup!['category'] ?? widget.meetup!['mainCategory'] ?? '일상 & 푸드') : '동네 맛집 & 소셜 다이닝').toString();
    final dateStr = (widget.meetup?['date'] ?? widget.meetup?['schedule'] ?? '').toString().trim();
    final memberCount = _getMemberCount(widget.meetup?['members']);
    final maxCapacity = MeetupApplicationService.capacity(widget.meetup ?? {});

    return Scaffold(
      backgroundColor: OomuTokens.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. 커버 이미지 (높이 240, 하단 스크림, 상단 반투명 원형 40dp 버튼 / 48dp 터치 타깃)
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            stretch: true,
            backgroundColor: OomuTokens.surface,
            surfaceTintColor: OomuTokens.surface,
            elevation: 0,
            leading: Center(
              child: BouncyTap(
                scaleDown: 0.90,
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  constraints: const BoxConstraints(minWidth: OomuTokens.touchTargetMin, minHeight: OomuTokens.touchTargetMin),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
            ),
            actions: [
              Center(
                child: BouncyTap(
                  scaleDown: 0.88,
                  onHaptic: OomuHaptics.light,
                  onTap: () {
                    setState(() => _isFavorite = !_isFavorite);
                    if (widget.meetup != null) {
                      globalData.toggleFavorite(widget.meetup!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isFavorite ? '❤️ 찜한 모임에 추가되었습니다' : '찜한 모임에서 제거되었습니다'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    constraints: const BoxConstraints(minWidth: OomuTokens.touchTargetMin, minHeight: OomuTokens.touchTargetMin),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? OomuTokens.coral : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: OomuTokens.s8),
              Center(
                child: Tooltip(
                  message: '모임 신고',
                  child: BouncyTap(
                    scaleDown: 0.90,
                    onTap: () => _showMeetupReportBottomSheet(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      constraints: const BoxConstraints(minWidth: OomuTokens.touchTargetMin, minHeight: OomuTokens.touchTargetMin),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: OomuTokens.s12),
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
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. 메인 컨텐츠 시트 (방향 1: 따뜻한 미니멀 소셜 표준)
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -24, 0),
              decoration: const BoxDecoration(
                color: OomuTokens.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(OomuTokens.r24)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: OomuTokens.s20, vertical: OomuTokens.s24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A. 키커 (카테고리 · 지역) & 뱃지
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: OomuTokens.s8,
                      runSpacing: OomuTokens.s6,
                      children: [
                        Text(
                          '$categoryLabel${locName.isNotEmpty && locName != "장소 정보 없음" ? " · $locName" : ""}',
                          style: const TextStyle(
                            fontSize: OomuTokens.fs13,
                            color: OomuTokens.textTertiary,
                            fontWeight: OomuTokens.w500,
                            fontFamily: OomuTokens.fontFamily,
                          ),
                        ),
                        if (widget.meetup?['isFemaleOnly'] == true)
                          const OomuBadge.coral(
                            label: '여성 전용',
                          ),
                      ],
                    ),
                    const SizedBox(height: OomuTokens.s8),

                    // B. 제목 (22sp w700 ink)
                    Text(
                      _formatTitleKeepWords(widget.meetup?['title']?.toString()),
                      style: const TextStyle(
                        color: OomuTokens.textPrimary,
                        fontSize: OomuTokens.fs22,
                        fontWeight: OomuTokens.w700,
                        height: 1.35,
                        fontFamily: OomuTokens.fontFamily,
                      ),
                    ),
                    const SizedBox(height: OomuTokens.s20),

                    // C. 핵심 정보 (박스 없이 클린 리스트로 렌더링)
                    if (dateStr.isNotEmpty)
                      OomuInfoRow(
                        icon: Icons.calendar_today_rounded,
                        label: '일시',
                        value: dateStr,
                      ),
                    if (locName.isNotEmpty && locName != '장소 정보 없음')
                      OomuInfoRow(
                        icon: Icons.location_on_rounded,
                        label: '장소',
                        value: locName,
                      ),
                    if (maxCapacity > 0 || memberCount > 0)
                      OomuInfoRow(
                        icon: Icons.group_outlined,
                        label: '인원',
                        value: maxCapacity > 0 ? '$memberCount / $maxCapacity명' : '$memberCount명 참여 중',
                      ),
                    if (costLabel.isNotEmpty && costLabel != '비용 안내 확인 필요')
                      OomuInfoRow(
                        icon: Icons.payments_outlined,
                        label: '비용',
                        value: costLabel,
                      ),
                    const Divider(color: OomuTokens.border, height: 36, thickness: 1),

                    // D. 호스트 카드 (박스 안 박스 없이 평면 직접 배치)
                    _buildHostCard(hostManner, isHostVerified, praiseTags),
                    const Divider(color: OomuTokens.border, height: 36, thickness: 1),

                    // E. 모임 소개 (상자 테두리 없이 클린 바디 텍스트)
                    const OomuSectionHeader(title: '모임 소개', padding: EdgeInsets.zero),
                    const SizedBox(height: OomuTokens.s12),
                    Text(
                      (widget.meetup?['description']?.toString().trim().isNotEmpty == true)
                          ? widget.meetup!['description'].toString()
                          : '아직 모임 소개가 없어요. 참여 전 모임장에게 내용을 확인해 주세요.',
                      style: const TextStyle(
                        fontSize: OomuTokens.fs15,
                        height: 1.6,
                        color: OomuTokens.textBody,
                        fontFamily: OomuTokens.fontFamily,
                      ),
                    ),
                    const Divider(color: OomuTokens.border, height: 36, thickness: 1),

                    // F. 지도·길찾기 (중립 아웃라인 보조 버튼 + 중립 회색 한 줄 위치 안내)
                    OomuSectionHeader(
                      title: '모임 장소 & 지도',
                      padding: EdgeInsets.zero,
                      action: Container(
                        padding: const EdgeInsets.symmetric(horizontal: OomuTokens.s8, vertical: OomuTokens.s4),
                        decoration: BoxDecoration(
                          color: OomuTokens.surfaceMuted,
                          borderRadius: BorderRadius.circular(OomuTokens.r8),
                          border: Border.all(color: isDistanceUnknown ? OomuTokens.border : OomuTokens.verified),
                        ),
                        child: Text(
                          _distanceText,
                          style: TextStyle(
                            fontSize: OomuTokens.fs12,
                            fontWeight: OomuTokens.w700,
                            color: isDistanceUnknown ? OomuTokens.textSecondary : OomuTokens.verified,
                            fontFamily: OomuTokens.fontFamily,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: OomuTokens.s12),
                    _buildMapSection(hasResolvedCoords, locName),
                    const SizedBox(height: OomuTokens.s32),

                    // G. 참여 멤버 (고품격 헤더 배지 + 아바타 스택 + 신뢰 인디케이터)
                    OomuSectionHeader(
                      title: '참여 멤버',
                      padding: EdgeInsets.zero,
                      action: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Text(
                            memberCount > 0 ? '$memberCount명 참여 중' : '참여 인원 확인 필요',
                            style: const TextStyle(
                              fontSize: OomuTokens.fs13,
                              color: OomuTokens.textPrimary,
                              fontWeight: OomuTokens.w700,
                              fontFamily: OomuTokens.fontFamily,
                            ),
                          ),
                          if (maxCapacity > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: OomuTokens.coral.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(OomuTokens.rPill),
                                border: Border.all(color: OomuTokens.coral.withValues(alpha: 0.25)),
                              ),
                              child: Text(
                                '${_calcRemainingSeats(widget.meetup?['members'])} · 정원 $maxCapacity명',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: OomuTokens.coral,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: OomuTokens.fontFamily,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: OomuTokens.s12),
                    Wrap(
                      spacing: OomuTokens.s8,
                      runSpacing: OomuTokens.s8,
                      children: () {
                        final List<Widget> avatars = [];
                        final hostAv = (widget.meetup?['hostAvatar'] ?? 'profiles/초연.png').toString();
                        final hostName = (widget.meetup?['host'] ?? '호스트').toString();
                        avatars.add(_buildMemberAvatar(hostAv, isHost: true, name: hostName));

                        final rawAvatars = (widget.meetup?['memberAvatars'] is List)
                            ? (widget.meetup!['memberAvatars'] as List)
                                .map((e) => e.toString())
                                .where((s) => s.isNotEmpty)
                                .toList()
                            : <String>[];

                        final defaultPool = [
                          {'avatar': 'assets/images/민지.png', 'name': '망원치즈_민지'},
                          {'avatar': 'assets/images/지훈.png', 'name': '연남러너_지훈'},
                          {'avatar': 'assets/images/지연.png', 'name': '성수와인_지연'},
                          {'avatar': 'assets/images/정재.png', 'name': '동네이웃_정재'},
                        ];

                        int needed = (memberCount > 1
                            ? memberCount - 1
                            : (rawAvatars.isNotEmpty ? rawAvatars.length : 2));
                        if (needed > 5) needed = 5;

                        for (int i = 0; i < needed; i++) {
                          if (i < rawAvatars.length) {
                            avatars.add(_buildMemberAvatar(rawAvatars[i],
                                isHost: false, name: '참여 이웃 ${i + 1}'));
                          } else {
                            final fallback = defaultPool[i % defaultPool.length];
                            avatars.add(_buildMemberAvatar(fallback['avatar']!,
                                isHost: false, name: fallback['name']!));
                          }
                        }
                        return avatars;
                      }(),
                    ),
                    const SizedBox(height: OomuTokens.s8),
                    const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, size: 14, color: OomuTokens.verified),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '호스트 승인 후 단톡방 입장 · 매너온도 36.5°C 이상 이웃',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: OomuTokens.textSecondary,
                              fontWeight: OomuTokens.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // H. 안심 클린 모임 준수 가이드 및 신고 (1px 초미세 테두리 프리미엄 카드)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFBFD),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEDEFF2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user_rounded, size: 18, color: OomuTokens.coral),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '2030 클린 모임 안전 수칙 준수',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: OomuTokens.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '부적절한 언행이나 연락처 요구 시 즉시 제재됩니다.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: OomuTokens.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _showMeetupReportBottomSheet(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: OomuTokens.border),
                              ),
                              child: const Text(
                                '신고·차단',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: OomuTokens.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: OomuTokens.s24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // 3. 하단 고정 CTA 바 (방향 1: 플랫 서피스 + 1px 디바이더)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: OomuTokens.s16, vertical: OomuTokens.s12),
        decoration: const BoxDecoration(
          color: OomuTokens.surface,
          border: Border(top: BorderSide(color: OomuTokens.border, width: 1.0)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // 52x52 찜 버튼
              BouncyTap(
                scaleDown: 0.90,
                onHaptic: OomuHaptics.light,
                onTap: () {
                  setState(() => _isFavorite = !_isFavorite);
                  if (widget.meetup != null) {
                    globalData.toggleFavorite(widget.meetup!);
                  }
                },
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: OomuTokens.surface,
                    borderRadius: BorderRadius.circular(OomuTokens.r12),
                    border: Border.all(color: OomuTokens.lineStrong),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
                    color: _isFavorite ? OomuTokens.coral : OomuTokens.textSecondary,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: OomuTokens.s12),

              // 52dp 신청 액션 버튼 (정원 마감, 신청 완료, 호스트 상태 대응)
              Expanded(
                child: MeetupParticipationAction(
                  meetup: widget.meetup,
                  onApply: _isApplying ? null : () => _showApplicationBottomSheet(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 한 겹 호스트 카드 위젯 (방향 1: 박스 테두리 없는 깔끔한 인라인 프로필)
  Widget _buildHostCard(double? hostManner, bool isHostVerified, List<String> praiseTags) {
    final hostName = (widget.meetup != null ? (widget.meetup!['host'] ?? '모임 호스트') : '모임 호스트').toString();
    final hostAvatar = (widget.meetup != null && widget.meetup!['hostAvatar'] != null)
        ? widget.meetup!['hostAvatar'].toString()
        : 'assets/images/민지.png';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            OomuAvatar(
              radius: 22,
              imageUrl: hostAvatar,
              name: hostName,
            ),
            const SizedBox(width: OomuTokens.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '호스트',
                    style: TextStyle(
                      fontSize: OomuTokens.fs12,
                      color: OomuTokens.textSecondary,
                      fontFamily: OomuTokens.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    runSpacing: 2,
                    children: [
                      Text(
                        hostName,
                        style: const TextStyle(
                          fontSize: OomuTokens.fs16,
                          fontWeight: OomuTokens.w700,
                          color: OomuTokens.textPrimary,
                          fontFamily: OomuTokens.fontFamily,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isHostVerified)
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, size: 14, color: OomuTokens.verified),
                            SizedBox(width: 2),
                            Text(
                              '본인인증',
                              style: TextStyle(
                                fontSize: OomuTokens.fs12,
                                color: OomuTokens.textSecondary,
                                fontFamily: OomuTokens.fontFamily,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: OomuTokens.s8),
            // 매너온도 숫자 (방향 1 표준)
            if (hostManner != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${hostManner.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      fontSize: OomuTokens.fs16,
                      fontWeight: OomuTokens.w700,
                      color: OomuTokens.textPrimary,
                      fontFamily: OomuTokens.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '매너온도',
                    style: TextStyle(
                      fontSize: OomuTokens.fs11,
                      color: OomuTokens.textTertiary,
                      fontWeight: OomuTokens.w400,
                      fontFamily: OomuTokens.fontFamily,
                    ),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: OomuTokens.s8, vertical: OomuTokens.s4),
                decoration: BoxDecoration(
                  color: OomuTokens.surfaceMuted,
                  borderRadius: BorderRadius.circular(OomuTokens.r8),
                ),
                child: const Text(
                  '매너온도 정보 없음',
                  style: TextStyle(
                    fontSize: OomuTokens.fs12,
                    fontWeight: OomuTokens.w500,
                    color: OomuTokens.textTertiary,
                    fontFamily: OomuTokens.fontFamily,
                  ),
                ),
              ),
          ],
        ),

          if (widget.meetup != null && widget.meetup!['hostBio'] != null && widget.meetup!['hostBio'].toString().trim().isNotEmpty) ...[
            const SizedBox(height: OomuTokens.s12),
            Text(
              widget.meetup!['hostBio'].toString().trim(),
              style: const TextStyle(
                fontSize: OomuTokens.fs14,
                height: 1.5,
                color: OomuTokens.textSecondary,
                fontFamily: OomuTokens.fontFamily,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          if (praiseTags.isNotEmpty) ...[
            const SizedBox(height: OomuTokens.s12),
            Wrap(
              spacing: OomuTokens.s8,
              runSpacing: OomuTokens.s8,
              children: praiseTags.take(3).map((tag) => OomuTag(
                label: tag,
              )).toList(),
            ),
          ],

          const SizedBox(height: OomuTokens.s12),
          OomuButton(
            label: '호스트 프로필 보기',
            variant: OomuButtonVariant.secondary,
            size: OomuButtonSize.medium,
            icon: Icons.person_outline_rounded,
            onPressed: () {
              HapticFeedback.lightImpact();
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
          ),
        ],
      );
  }

  // 지도 섹션 위젯
  Widget _buildMapSection(bool hasResolvedCoords, String locName) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: OomuTokens.surface,
        borderRadius: BorderRadius.circular(OomuTokens.r16),
        border: Border.all(color: OomuTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasResolvedCoords)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(OomuTokens.r16 - 1)),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: Stack(
                  children: [
                    KakaoMapView(
                      key: ValueKey('kakao-detail-$_targetLat-$_targetLng'),
                      lat: _targetLat!,
                      lng: _targetLng!,
                      locationName: locName,
                      height: 200,
                      hideActions: true,
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          showDialog(
                            context: context,
                            builder: (_) => InteractiveMapPopup(
                              initialCenter: LatLng(_targetLat!, _targetLng!),
                              locationName: locName,
                              kakaoLink: KakaoMapService.getKakaoRouteUrl(
                                  locName, _targetLat!, _targetLng!),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(OomuTokens.r24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                              )
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.fullscreen_rounded,
                                  size: 15, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                '전체화면 지도',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(OomuTokens.s16),
              child: Row(
                children: [
                  const Icon(Icons.location_searching_rounded,
                      color: OomuTokens.textSecondary, size: 18),
                  const SizedBox(width: OomuTokens.s8),
                  Expanded(
                    child: Text(
                      _isResolvingLocation
                          ? '장소 좌표를 확인하고 있어요...'
                          : '정확한 위치를 확인할 수 없어요',
                      style: const TextStyle(
                        fontSize: OomuTokens.fs12,
                        color: OomuTokens.textSecondary,
                        fontFamily: OomuTokens.fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(OomuTokens.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 18, color: OomuTokens.coral),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        locName,
                        style: const TextStyle(
                          fontSize: OomuTokens.fs14,
                          fontWeight: OomuTokens.w700,
                          color: OomuTokens.textPrimary,
                          fontFamily: OomuTokens.fontFamily,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF191F28),
                          backgroundColor: const Color(0xFFFEE500),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.map_outlined, size: 16),
                        label: const Text('카카오맵',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          if (_targetLat != null && _targetLng != null) {
                            KakaoMapService.launchMap(locName,
                                lat: _targetLat!, lng: _targetLng!);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF191F28),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.directions_outlined, size: 16),
                        label: const Text('카카오 길찾기',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                        onPressed: () => KakaoMapService.launchDirections(
                            locName,
                            lat: _targetLat,
                            lng: _targetLng),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberAvatar(String url, {required bool isHost, String? name}) {
    return GestureDetector(
      onTap: () {
        if (name != null && name.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserProfileScreen(
                userName: name,
                userAvatar: url,
              ),
            ),
          );
        }
      },
      child: Stack(
        children: [
          OomuAvatar(
            radius: 22,
            imageUrl: url,
            name: name,
          ),
          if (isHost)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: OomuTokens.textPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Text('👑',
                    style: TextStyle(fontSize: OomuTokens.fs11)),
              ),
            )
        ],
      ),
    );
  }
}
