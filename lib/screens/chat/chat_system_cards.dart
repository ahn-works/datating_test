import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/kakao_map_service.dart';
import '../../ui/oomu_avatar.dart';
import '../../ui/oomu_tokens.dart';
import '../../utils/app_image.dart';
import '../../utils/global_data.dart';

// ===========================================================================
// 동적 컴포넌트: 일정 참석 투표 카드
// ===========================================================================
class InteractiveScheduleCard extends StatefulWidget {
  final Map<String, dynamic> msg;
  final bool isMe;
  final String chatRoomId;
  final Function(Map<String, dynamic> delta)? onUpdate;

  const InteractiveScheduleCard({
    super.key,
    required this.msg,
    required this.isMe,
    required this.chatRoomId,
    this.onUpdate,
  });

  @override
  State<InteractiveScheduleCard> createState() =>
      _InteractiveScheduleCardState();
}

class _InteractiveScheduleCardState extends State<InteractiveScheduleCard> {
  @override
  Widget build(BuildContext context) {
    final currentNick = globalData.userNickname.value.isNotEmpty
        ? globalData.userNickname.value
        : '우리동네민우';
    final int maxMembers = widget.msg['maxMembers'] ?? 4;
    final List<String> attendees = List<String>.from(
        widget.msg['attendees'] ?? [widget.msg['sender'] ?? '우리동네민우']);
    final bool isAttending = attendees.contains(currentNick);
    final int attendCount = attendees.length;
    final bool isFull = attendCount >= maxMembers && !isAttending;

    return Padding(
      padding: const EdgeInsets.only(bottom: OomuTokens.s16),
      child: Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe)
            const OomuAvatar(
              imageUrl: 'assets/images/민지.png',
              name: '민지',
              radius: 16,
            ),
          if (!widget.isMe) const SizedBox(width: OomuTokens.s8),
          if (widget.isMe)
            Text(
              widget.msg['time'] ?? '',
              style: const TextStyle(
                fontSize: OomuTokens.fs11,
                color: OomuTokens.textMuted,
              ),
            ),
          if (widget.isMe) const SizedBox(width: OomuTokens.s4),
          Container(
            width: 270,
            padding: const EdgeInsets.all(OomuTokens.s16),
            decoration: BoxDecoration(
              color: OomuTokens.surface,
              borderRadius: BorderRadius.circular(OomuTokens.r16),
              border: Border.all(color: OomuTokens.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: OomuTokens.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_month,
                        color: OomuTokens.textPrimary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: OomuTokens.s8),
                    Expanded(
                      child: Text(
                        widget.msg['title'] ?? '새로운 일정 제안',
                        style: const TextStyle(
                          fontWeight: OomuTokens.w700,
                          fontSize: OomuTokens.fs14,
                          color: OomuTokens.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (attendCount >= maxMembers)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: OomuTokens.s8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: OomuTokens.surfaceMuted,
                          borderRadius: BorderRadius.circular(OomuTokens.r8),
                        ),
                        child: const Text(
                          '마감됨',
                          style: TextStyle(
                            fontSize: OomuTokens.fs11,
                            fontWeight: OomuTokens.w700,
                            color: OomuTokens.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: OomuTokens.s12),
                Container(
                  padding: const EdgeInsets.all(OomuTokens.s12),
                  decoration: BoxDecoration(
                    color: OomuTokens.surfaceMuted,
                    borderRadius: BorderRadius.circular(OomuTokens.r12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.event,
                            size: 14,
                            color: OomuTokens.textSecondary,
                          ),
                          const SizedBox(width: OomuTokens.s8),
                          const Text(
                            '날짜: ',
                            style: TextStyle(
                              fontSize: OomuTokens.fs12,
                              fontWeight: OomuTokens.w700,
                              color: OomuTokens.textPrimary,
                            ),
                          ),
                          Text(
                            widget.msg['date'] ?? '-',
                            style: const TextStyle(
                              fontSize: OomuTokens.fs12,
                              color: OomuTokens.textBody,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: OomuTokens.s8),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: OomuTokens.textSecondary,
                          ),
                          const SizedBox(width: OomuTokens.s8),
                          const Text(
                            '시간: ',
                            style: TextStyle(
                              fontSize: OomuTokens.fs12,
                              fontWeight: OomuTokens.w700,
                              color: OomuTokens.textPrimary,
                            ),
                          ),
                          Text(
                            widget.msg['timeStr'] ?? widget.msg['time'] ?? '-',
                            style: const TextStyle(
                              fontSize: OomuTokens.fs12,
                              color: OomuTokens.textBody,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: OomuTokens.s8),
                      Row(
                        children: [
                          const Icon(
                            Icons.place,
                            size: 14,
                            color: OomuTokens.textSecondary,
                          ),
                          const SizedBox(width: OomuTokens.s8),
                          const Text(
                            '장소: ',
                            style: TextStyle(
                              fontSize: OomuTokens.fs12,
                              fontWeight: OomuTokens.w700,
                              color: OomuTokens.textPrimary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.msg['location'] ?? '-',
                              style: const TextStyle(
                                fontSize: OomuTokens.fs12,
                                color: OomuTokens.textBody,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: OomuTokens.s12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.group,
                          size: 14,
                          color: OomuTokens.textSecondary,
                        ),
                        SizedBox(width: OomuTokens.s4),
                        Text(
                          '참석 확정 현황',
                          style: TextStyle(
                            fontSize: OomuTokens.fs12,
                            color: OomuTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$attendCount / $maxMembers 명',
                      style: const TextStyle(
                        fontSize: OomuTokens.fs12,
                        fontWeight: OomuTokens.w700,
                        color: OomuTokens.coral,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: OomuTokens.s8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(OomuTokens.r8),
                  child: LinearProgressIndicator(
                    value: (attendCount / maxMembers).clamp(0.0, 1.0),
                    backgroundColor: OomuTokens.surfaceMuted,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      OomuTokens.coral,
                    ),
                    minHeight: 6,
                  ),
                ),
                if (attendees.isNotEmpty) ...[
                  const SizedBox(height: OomuTokens.s8),
                  Wrap(
                    spacing: OomuTokens.s4,
                    runSpacing: OomuTokens.s4,
                    children: attendees
                        .map(
                          (name) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: OomuTokens.s8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: OomuTokens.surfaceMuted,
                              borderRadius: BorderRadius.circular(OomuTokens.r8),
                            ),
                            child: Text(
                              '✓ $name',
                              style: const TextStyle(
                                fontSize: OomuTokens.fs11,
                                color: OomuTokens.textPrimary,
                                fontWeight: OomuTokens.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: OomuTokens.s12),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isFull) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('모집 인원이 마감되었습니다!')),
                        );
                        return;
                      }
                      final newAttendees = List<String>.from(attendees);
                      if (isAttending) {
                        newAttendees.remove(currentNick);
                      } else {
                        newAttendees.add(currentNick);
                      }
                      if (widget.onUpdate != null) {
                        widget.onUpdate!({'attendees': newAttendees});
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            !isAttending
                                ? '👍 모임 참석이 확정되었습니다!'
                                : '일정 참석을 취소했습니다.',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAttending
                          ? OomuTokens.surfaceMuted
                          : (isFull ? OomuTokens.border : OomuTokens.coral),
                      foregroundColor: isAttending
                          ? OomuTokens.textPrimary
                          : OomuTokens.surface,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(OomuTokens.r12),
                      ),
                    ),
                    child: Text(
                      isAttending
                          ? '참석 취소하기'
                          : (isFull ? '모집 마감' : '👍 저도 참석할게요!'),
                      style: const TextStyle(
                        fontWeight: OomuTokens.w700,
                        fontSize: OomuTokens.fs12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!widget.isMe) const SizedBox(width: OomuTokens.s4),
          if (!widget.isMe)
            Text(
              widget.msg['time'] ?? '',
              style: const TextStyle(
                fontSize: OomuTokens.fs11,
                color: OomuTokens.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}

// ===========================================================================
// 동적 컴포넌트: 안건 투표 카드
// ===========================================================================
class InteractivePollCard extends StatefulWidget {
  final Map<String, dynamic> msg;
  final bool isMe;
  final String chatRoomId;
  final Function(Map<String, dynamic> delta)? onUpdate;

  const InteractivePollCard({
    super.key,
    required this.msg,
    required this.isMe,
    required this.chatRoomId,
    this.onUpdate,
  });

  @override
  State<InteractivePollCard> createState() => _InteractivePollCardState();
}

class _InteractivePollCardState extends State<InteractivePollCard> {
  @override
  Widget build(BuildContext context) {
    final currentNick = globalData.userNickname.value.isNotEmpty
        ? globalData.userNickname.value
        : '우리동네민우';
    final voters = widget.msg['voters'] != null
        ? Map<String, dynamic>.from(widget.msg['voters'])
        : <String, dynamic>{};
    final int? selectedOption = voters[currentNick] as int?;

    final int opt1Count = voters.values.where((v) => v == 1).length;
    final int opt2Count = voters.values.where((v) => v == 2).length;
    final int totalVotes = opt1Count + opt2Count;

    return Padding(
      padding: const EdgeInsets.only(bottom: OomuTokens.s16),
      child: Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe)
            const OomuAvatar(
              imageUrl: 'assets/images/민지.png',
              name: '민지',
              radius: 16,
            ),
          if (!widget.isMe) const SizedBox(width: OomuTokens.s8),
          if (widget.isMe)
            Text(
              widget.msg['time'] ?? '',
              style: const TextStyle(
                fontSize: OomuTokens.fs11,
                color: OomuTokens.textMuted,
              ),
            ),
          if (widget.isMe) const SizedBox(width: OomuTokens.s4),
          Container(
            width: 260,
            padding: const EdgeInsets.all(OomuTokens.s16),
            decoration: BoxDecoration(
              color: OomuTokens.surface,
              borderRadius: BorderRadius.circular(OomuTokens.r16),
              border: Border.all(color: OomuTokens.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: OomuTokens.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.how_to_vote,
                        color: OomuTokens.textPrimary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: OomuTokens.s8),
                    Expanded(
                      child: Text(
                        widget.msg['title'] ?? '투표',
                        style: const TextStyle(
                          fontWeight: OomuTokens.w700,
                          fontSize: OomuTokens.fs14,
                          color: OomuTokens.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: OomuTokens.s8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '실시간 실명 투표',
                      style: TextStyle(
                        fontSize: OomuTokens.fs11,
                        color: OomuTokens.textSecondary,
                      ),
                    ),
                    Text(
                      '총 $totalVotes명 참여',
                      style: const TextStyle(
                        fontSize: OomuTokens.fs11,
                        fontWeight: OomuTokens.w700,
                        color: OomuTokens.coral,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: OomuTokens.s12),
                _buildPollOption(
                  1,
                  widget.msg['opt1'] ?? '옵션 1',
                  opt1Count,
                  totalVotes,
                  selectedOption == 1,
                  currentNick,
                  voters,
                ),
                const SizedBox(height: OomuTokens.s8),
                _buildPollOption(
                  2,
                  widget.msg['opt2'] ?? '옵션 2',
                  opt2Count,
                  totalVotes,
                  selectedOption == 2,
                  currentNick,
                  voters,
                ),
              ],
            ),
          ),
          if (!widget.isMe) const SizedBox(width: OomuTokens.s4),
          if (!widget.isMe)
            Text(
              widget.msg['time'] ?? '',
              style: const TextStyle(
                fontSize: OomuTokens.fs11,
                color: OomuTokens.textMuted,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPollOption(
    int optionIndex,
    String text,
    int count,
    int totalVotes,
    bool isSelected,
    String currentNick,
    Map<String, dynamic> voters,
  ) {
    final double percent = totalVotes > 0 ? (count / totalVotes) : 0.0;

    return GestureDetector(
      onTap: () {
        final newVoters = Map<String, dynamic>.from(voters);
        if (isSelected) {
          newVoters.remove(currentNick);
        } else {
          newVoters[currentNick] = optionIndex;
        }
        if (widget.onUpdate != null) {
          widget.onUpdate!({'voters': newVoters});
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: OomuTokens.s12,
          vertical: OomuTokens.s8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? OomuTokens.surfaceMuted
              : OomuTokens.surface,
          borderRadius: BorderRadius.circular(OomuTokens.r12),
          border: Border.all(
            color: isSelected ? OomuTokens.coral : OomuTokens.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 16,
                        color: isSelected ? OomuTokens.coral : OomuTokens.textMuted,
                      ),
                      const SizedBox(width: OomuTokens.s8),
                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: OomuTokens.fs12,
                            fontWeight: isSelected
                                ? OomuTokens.w700
                                : OomuTokens.w600,
                            color: isSelected
                                ? OomuTokens.textPrimary
                                : OomuTokens.textBody,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$count명',
                  style: TextStyle(
                    fontSize: OomuTokens.fs12,
                    fontWeight: OomuTokens.w700,
                    color: isSelected
                        ? OomuTokens.coral
                        : OomuTokens.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: OomuTokens.s8),
            ClipRRect(
              borderRadius: BorderRadius.circular(OomuTokens.r8),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: OomuTokens.surfaceMuted,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isSelected
                      ? OomuTokens.coral
                      : OomuTokens.textMuted,
                ),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 동적 컴포넌트: 추천 핫플 장소 카드 (카카오 길찾기 연동)
// ===========================================================================
class InteractiveHotspotCard extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMe;

  const InteractiveHotspotCard({
    super.key,
    required this.msg,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final String name = msg['name'] ?? '핫플 이름';
    final String address = msg['address'] ?? '주소 정보 없음';
    final double? lat = (msg['lat'] as num?)?.toDouble();
    final double? lng = (msg['lng'] as num?)?.toDouble();

    final String kakaoMapUrl = (lat != null && lng != null)
        ? KakaoMapService.getKakaoMapPinUrl(name, lat, lng)
        : KakaoMapService.getKakaoSearchUrl('$name $address');

    return Padding(
      padding: const EdgeInsets.only(bottom: OomuTokens.s16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            const OomuAvatar(
              imageUrl: 'assets/images/민지.png',
              name: '민지',
              radius: 16,
            ),
          if (!isMe) const SizedBox(width: OomuTokens.s8),
          if (isMe)
            Text(
              msg['time'] ?? '',
              style: const TextStyle(
                fontSize: OomuTokens.fs11,
                color: OomuTokens.textMuted,
              ),
            ),
          if (isMe) const SizedBox(width: OomuTokens.s4),
          Container(
            width: 250,
            padding: const EdgeInsets.all(OomuTokens.s16),
            decoration: BoxDecoration(
              color: OomuTokens.surface,
              borderRadius: BorderRadius.circular(OomuTokens.r16),
              border: Border.all(color: OomuTokens.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((msg['imageUrl'] ?? msg['photo']) != null &&
                    (msg['imageUrl'] ?? msg['photo']).toString().isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(OomuTokens.r10),
                    child: SizedBox(
                      height: 110,
                      width: double.infinity,
                      child: appNetImage(
                        (msg['imageUrl'] ?? msg['photo']).toString(),
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: OomuTokens.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_cafe,
                        color: OomuTokens.textPrimary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: OomuTokens.s8),
                    Expanded(
                      child: Text(
                        msg['title'] ?? '동네 핫플 추천',
                        style: const TextStyle(
                          fontWeight: OomuTokens.w700,
                          fontSize: OomuTokens.fs14,
                          color: OomuTokens.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: OomuTokens.s12),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: OomuTokens.fs15,
                    fontWeight: OomuTokens.w700,
                    color: OomuTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: OomuTokens.s4),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: OomuTokens.fs12,
                    color: OomuTokens.textSecondary,
                  ),
                ),
                const SizedBox(height: OomuTokens.s12),

                // 중립 Secondary 카카오 길찾기 버튼
                GestureDetector(
                  onTap: () async {
                    final Uri url = Uri.parse(kakaoMapUrl);
                    if (!await launchUrl(url)) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('지도를 열 수 없습니다.')),
                        );
                      }
                    }
                  },
                  child: Container(
                    height: 44,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: OomuTokens.surfaceMuted,
                      borderRadius: BorderRadius.circular(OomuTokens.r12),
                      border: Border.all(color: OomuTokens.border),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 16,
                            color: OomuTokens.textPrimary,
                          ),
                          SizedBox(width: OomuTokens.s8),
                          Text(
                            '카카오 길찾기',
                            style: TextStyle(
                              color: OomuTokens.textPrimary,
                              fontSize: OomuTokens.fs12,
                              fontWeight: OomuTokens.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isMe) const SizedBox(width: OomuTokens.s4),
          if (!isMe)
            Text(
              msg['time'] ?? '',
              style: const TextStyle(
                fontSize: OomuTokens.fs11,
                color: OomuTokens.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}

// ===========================================================================
// 동적 컴포넌트: 리뷰 공유 카드
// ===========================================================================
class InteractiveReviewCard extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMe;

  const InteractiveReviewCard({
    super.key,
    required this.msg,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final int rating = msg['rating'] ?? 5;
    final String text = msg['text'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: OomuTokens.s16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            const OomuAvatar(
              imageUrl: 'assets/images/민지.png',
              name: '민지',
              radius: 16,
            ),
          if (!isMe) const SizedBox(width: OomuTokens.s8),
          if (isMe)
            Text(
              msg['time'] ?? '',
              style: const TextStyle(
                fontSize: OomuTokens.fs11,
                color: OomuTokens.textMuted,
              ),
            ),
          if (isMe) const SizedBox(width: OomuTokens.s4),
          Container(
            width: 250,
            padding: const EdgeInsets.all(OomuTokens.s16),
            decoration: BoxDecoration(
              color: OomuTokens.surface,
              borderRadius: BorderRadius.circular(OomuTokens.r16),
              border: Border.all(color: OomuTokens.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: OomuTokens.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.rate_review,
                        color: OomuTokens.textPrimary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: OomuTokens.s8),
                    const Expanded(
                      child: Text(
                        '✨ 모임 후기가 도착했어요!',
                        style: TextStyle(
                          fontWeight: OomuTokens.w700,
                          fontSize: OomuTokens.fs14,
                          color: OomuTokens.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: OomuTokens.s12),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      size: 18,
                      color: OomuTokens.coral,
                    ),
                  ),
                ),
                if (text.isNotEmpty) ...[
                  const SizedBox(height: OomuTokens.s8),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: OomuTokens.fs12,
                      color: OomuTokens.textBody,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isMe) const SizedBox(width: OomuTokens.s4),
          if (!isMe)
            Text(
              msg['time'] ?? '',
              style: const TextStyle(
                fontSize: OomuTokens.fs11,
                color: OomuTokens.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}

// ===========================================================================
// 동적 컴포넌트: 안심 귀가 확인 카드
// ===========================================================================
class InteractiveSafeReturnCard extends StatefulWidget {
  final Map<String, dynamic> msg;
  final bool isMe;
  final String chatRoomId;
  final Function(Map<String, dynamic> delta)? onUpdate;

  const InteractiveSafeReturnCard({
    super.key,
    required this.msg,
    required this.isMe,
    required this.chatRoomId,
    this.onUpdate,
  });

  @override
  State<InteractiveSafeReturnCard> createState() =>
      _InteractiveSafeReturnCardState();
}

class _InteractiveSafeReturnCardState extends State<InteractiveSafeReturnCard> {
  @override
  Widget build(BuildContext context) {
    final currentNick = globalData.userNickname.value.isNotEmpty
        ? globalData.userNickname.value
        : '우리동네민우';
    final List<String> cheers = List<String>.from(widget.msg['cheers'] ?? []);
    final bool isLiked = cheers.contains(currentNick);
    final int likes = cheers.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: OomuTokens.s16),
      child: Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe)
            const OomuAvatar(
              imageUrl: 'assets/images/민지.png',
              name: '민지',
              radius: 16,
            ),
          if (!widget.isMe) const SizedBox(width: OomuTokens.s8),
          if (widget.isMe)
            Text(
              widget.msg['time'] ?? '',
              style: const TextStyle(
                fontSize: OomuTokens.fs11,
                color: OomuTokens.textMuted,
              ),
            ),
          if (widget.isMe) const SizedBox(width: OomuTokens.s4),
          Container(
            width: 260,
            padding: const EdgeInsets.all(OomuTokens.s16),
            decoration: BoxDecoration(
              color: OomuTokens.surface,
              borderRadius: BorderRadius.circular(OomuTokens.r16),
              border: Border.all(color: OomuTokens.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: OomuTokens.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.nightlife_rounded,
                        color: OomuTokens.textPrimary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: OomuTokens.s8),
                    Expanded(
                      child: Text(
                        widget.msg['title'] ?? '안심 귀가 완료',
                        style: const TextStyle(
                          fontWeight: OomuTokens.w700,
                          fontSize: OomuTokens.fs14,
                          color: OomuTokens.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: OomuTokens.s8),
                Text(
                  widget.msg['desc'] ?? '모임 후 무사히 귀가했습니다 :)',
                  style: const TextStyle(
                    fontSize: OomuTokens.fs12,
                    color: OomuTokens.textSecondary,
                  ),
                ),
                const SizedBox(height: OomuTokens.s12),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final newCheers = List<String>.from(cheers);
                      if (isLiked) {
                        newCheers.remove(currentNick);
                      } else {
                        newCheers.add(currentNick);
                      }
                      if (widget.onUpdate != null) {
                        widget.onUpdate!({'cheers': newCheers});
                      }
                    },
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: isLiked ? OomuTokens.coral : OomuTokens.textSecondary,
                    ),
                    label: Text(
                      likes > 0 ? '수고하셨어요 ($likes)' : '수고하셨어요 응원하기',
                      style: TextStyle(
                        fontSize: OomuTokens.fs12,
                        fontWeight: OomuTokens.w600,
                        color: isLiked ? OomuTokens.coral : OomuTokens.textPrimary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: OomuTokens.surfaceMuted,
                      side: const BorderSide(color: OomuTokens.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(OomuTokens.r12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!widget.isMe) const SizedBox(width: OomuTokens.s4),
          if (!widget.isMe)
            Text(
              widget.msg['time'] ?? '',
              style: const TextStyle(
                fontSize: OomuTokens.fs11,
                color: OomuTokens.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}

// ===========================================================================
// 동적 컴포넌트: 프로필 교환 요청 카드
// ===========================================================================
class InteractiveProfileExchangeCard extends StatefulWidget {
  final Map<String, dynamic> msg;
  final bool isMe;
  final String chatRoomId;
  final Function(Map<String, dynamic> delta)? onUpdate;

  const InteractiveProfileExchangeCard({
    super.key,
    required this.msg,
    required this.isMe,
    required this.chatRoomId,
    this.onUpdate,
  });

  @override
  State<InteractiveProfileExchangeCard> createState() =>
      _InteractiveProfileExchangeCardState();
}

class _InteractiveProfileExchangeCardState
    extends State<InteractiveProfileExchangeCard> {
  void _showProfileModal(String nickname) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(OomuTokens.s24),
        decoration: const BoxDecoration(
          color: OomuTokens.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(OomuTokens.r24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const OomuAvatar(
                imageUrl: 'assets/images/민지.png',
                name: '민지',
                radius: 36,
              ),
              const SizedBox(height: OomuTokens.s12),
              Text(
                nickname,
                style: const TextStyle(
                  fontSize: OomuTokens.fs18,
                  fontWeight: OomuTokens.w700,
                  color: OomuTokens.textPrimary,
                ),
              ),
              const SizedBox(height: OomuTokens.s4),
              const Text(
                '인증된 이웃 · 매너온도 41.2℃',
                style: TextStyle(
                  fontSize: OomuTokens.fs12,
                  color: OomuTokens.textSecondary,
                  fontWeight: OomuTokens.w600,
                ),
              ),
              const SizedBox(height: OomuTokens.s16),
              Container(
                padding: const EdgeInsets.all(OomuTokens.s12),
                decoration: BoxDecoration(
                  color: OomuTokens.surfaceMuted,
                  borderRadius: BorderRadius.circular(OomuTokens.r12),
                ),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user,
                          color: OomuTokens.verified,
                          size: 16,
                        ),
                        SizedBox(width: OomuTokens.s8),
                        Text(
                          'OOMU 본인 인증 및 매너 검증 완료',
                          style: TextStyle(
                            fontSize: OomuTokens.fs12,
                            fontWeight: OomuTokens.w700,
                            color: OomuTokens.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: OomuTokens.s8),
                    Text(
                      '관심사: 맛집 탐방, 주말 러닝, 로컬 아지트 탐험',
                      style: TextStyle(
                        fontSize: OomuTokens.fs12,
                        color: OomuTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: OomuTokens.s20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OomuTokens.surfaceMuted,
                    foregroundColor: OomuTokens.textPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(OomuTokens.r12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    '닫기',
                    style: TextStyle(
                      fontWeight: OomuTokens.w700,
                      fontSize: OomuTokens.fs14,
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

  @override
  Widget build(BuildContext context) {
    final currentNick = globalData.userNickname.value.isNotEmpty
        ? globalData.userNickname.value
        : '이웃';
    final List<String> acceptedMembers =
        List<String>.from(widget.msg['acceptedMembers'] ?? []);
    final bool isAccepted =
        acceptedMembers.isNotEmpty || widget.msg['status'] == 'accepted';

    return Padding(
      padding: const EdgeInsets.only(bottom: OomuTokens.s16),
      child: Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe)
            const OomuAvatar(
              imageUrl: 'assets/images/민지.png',
              name: '민지',
              radius: 16,
            ),
          if (!widget.isMe) const SizedBox(width: OomuTokens.s8),
          if (widget.isMe)
            Text(
              widget.msg['time'] ?? '',
              style: const TextStyle(
                fontSize: OomuTokens.fs11,
                color: OomuTokens.textMuted,
              ),
            ),
          if (widget.isMe) const SizedBox(width: OomuTokens.s4),
          Container(
            width: 260,
            padding: const EdgeInsets.all(OomuTokens.s16),
            decoration: BoxDecoration(
              color: OomuTokens.surface,
              borderRadius: BorderRadius.circular(OomuTokens.r16),
              border: Border.all(color: OomuTokens.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: OomuTokens.surfaceMuted,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.badge,
                    color: OomuTokens.textPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: OomuTokens.s8),
                Text(
                  widget.msg['title'] ?? '명함/프로필 교환',
                  style: const TextStyle(
                    fontWeight: OomuTokens.w700,
                    fontSize: OomuTokens.fs14,
                    color: OomuTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: OomuTokens.s4),
                Text(
                  widget.msg['desc'] ?? '서로의 상세 프로필과 소셜 정보를 확인해볼까요?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: OomuTokens.fs12,
                    color: OomuTokens.textSecondary,
                  ),
                ),
                const SizedBox(height: OomuTokens.s12),
                if (isAccepted)
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showProfileModal(widget.msg['sender'] ?? '상대방'),
                      icon: const Icon(
                        Icons.person,
                        size: 16,
                        color: OomuTokens.textPrimary,
                      ),
                      label: const Text(
                        '교환 완료 · 프로필 보기 🤝',
                        style: TextStyle(
                          color: OomuTokens.textPrimary,
                          fontWeight: OomuTokens.w600,
                          fontSize: OomuTokens.fs12,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: OomuTokens.surfaceMuted,
                        side: const BorderSide(color: OomuTokens.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(OomuTokens.r12),
                        ),
                      ),
                    ),
                  )
                else if (!widget.isMe)
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        final newAccepted = List<String>.from(acceptedMembers)
                          ..add(currentNick);
                        if (widget.onUpdate != null) {
                          widget.onUpdate!({
                            'acceptedMembers': newAccepted,
                            'status': 'accepted',
                          });
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎉 프로필 교환을 수락했습니다! 상세 프로필이 공개됩니다.'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OomuTokens.coral,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(OomuTokens.r12),
                        ),
                      ),
                      child: const Text(
                        '수락하기 🤝',
                        style: TextStyle(
                          color: OomuTokens.surface,
                          fontWeight: OomuTokens.w700,
                          fontSize: OomuTokens.fs12,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: OomuTokens.s8),
                    decoration: BoxDecoration(
                      color: OomuTokens.surfaceMuted,
                      borderRadius: BorderRadius.circular(OomuTokens.r8),
                    ),
                    child: const Center(
                      child: Text(
                        '상대방의 수락을 대기중입니다...',
                        style: TextStyle(
                          fontSize: OomuTokens.fs11,
                          color: OomuTokens.textMuted,
                          fontWeight: OomuTokens.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!widget.isMe) const SizedBox(width: OomuTokens.s4),
          if (!widget.isMe)
            Text(
              widget.msg['time'] ?? '',
              style: const TextStyle(
                fontSize: OomuTokens.fs11,
                color: OomuTokens.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}

// ===========================================================================
// 동적 컴포넌트: 시크릿 애프터 1:1 호감 매칭
// ===========================================================================
class InteractiveSecretAfterMatchCard extends StatefulWidget {
  final Map<String, dynamic> msg;
  final bool isMe;
  final String? chatRoomId;
  final Function(Map<String, dynamic> delta)? onUpdate;

  const InteractiveSecretAfterMatchCard({
    super.key,
    required this.msg,
    required this.isMe,
    this.chatRoomId,
    this.onUpdate,
  });

  @override
  State<InteractiveSecretAfterMatchCard> createState() =>
      _InteractiveSecretAfterMatchCardState();
}

class _InteractiveSecretAfterMatchCardState
    extends State<InteractiveSecretAfterMatchCard> {
  final List<Map<String, String>> _candidates = [
    {'name': '민지', 'tag': '여수 신기동 · 카페/베이킹', 'avatar': 'assets/images/민지.png'},
    {'name': '지훈', 'tag': '여수 웅천동 · 한강 러닝', 'avatar': 'assets/images/지훈.png'},
    {'name': '지연', 'tag': '여수 여서동 · 와인/다이닝', 'avatar': 'assets/images/지연.png'},
  ];

  final Set<String> _selectedMembers = {};
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    final choices = widget.msg['secretChoices'];
    if (choices is List) {
      _selectedMembers.addAll(choices.map((e) => e.toString()));
      if (_selectedMembers.isNotEmpty) {
        _isSubmitted = true;
      }
    }
  }

  void _toggleMember(String name) {
    if (_isSubmitted) return;
    setState(() {
      if (_selectedMembers.contains(name)) {
        _selectedMembers.remove(name);
      } else {
        if (_selectedMembers.length >= 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('시크릿 애프터 호감은 최대 2명까지만 선택할 수 있습니다.')),
          );
          return;
        }
        _selectedMembers.add(name);
      }
    });
  }

  void _submitSecretAfter() {
    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('호감을 표시할 멤버를 1명 이상 선택해 주세요!')),
      );
      return;
    }

    setState(() {
      _isSubmitted = true;
    });

    if (widget.onUpdate != null) {
      widget.onUpdate!({
        'secretChoices': _selectedMembers.toList(),
        'submittedAt': DateTime.now().toIso8601String(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '💌 ${_selectedMembers.join(", ")}님에게 비공개 호감이 전달되었습니다! (0% 노출 보장)',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: OomuTokens.s20),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(OomuTokens.s16),
          decoration: BoxDecoration(
            color: OomuTokens.surface,
            borderRadius: BorderRadius.circular(OomuTokens.r16),
            border: Border.all(color: OomuTokens.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: OomuTokens.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: OomuTokens.coral,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: OomuTokens.s8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '시크릿 애프터 1:1 호감 매칭',
                          style: TextStyle(
                            fontSize: OomuTokens.fs14,
                            fontWeight: OomuTokens.w700,
                            color: OomuTokens.textPrimary,
                          ),
                        ),
                        Text(
                          '상호 선택 시에만 1:1 대화방 개설 (거절 부담 0%)',
                          style: TextStyle(
                            fontSize: OomuTokens.fs11,
                            color: OomuTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: OomuTokens.s12),
              const Text(
                '오늘 모임에서 대화가 가장 잘 통했던 멤버 1~2명을 선택하세요.',
                style: TextStyle(
                  fontSize: OomuTokens.fs12,
                  fontWeight: OomuTokens.w600,
                  color: OomuTokens.textBody,
                ),
              ),
              const SizedBox(height: OomuTokens.s12),
              Column(
                children: _candidates.map((cand) {
                  final isSelected = _selectedMembers.contains(cand['name']);
                  return GestureDetector(
                    onTap: () => _toggleMember(cand['name']!),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: OomuTokens.s8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: OomuTokens.s12,
                        vertical: OomuTokens.s8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? OomuTokens.surfaceMuted
                            : OomuTokens.surface,
                        borderRadius: BorderRadius.circular(OomuTokens.r12),
                        border: Border.all(
                          color: isSelected ? OomuTokens.coral : OomuTokens.border,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          OomuAvatar(
                            imageUrl: cand['avatar']!,
                            name: cand['name']!,
                            radius: 18,
                          ),
                          const SizedBox(width: OomuTokens.s8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cand['name']!,
                                  style: const TextStyle(
                                    fontSize: OomuTokens.fs14,
                                    fontWeight: OomuTokens.w700,
                                    color: OomuTokens.textPrimary,
                                  ),
                                ),
                                Text(
                                  cand['tag']!,
                                  style: const TextStyle(
                                    fontSize: OomuTokens.fs11,
                                    color: OomuTokens.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isSelected ? OomuTokens.coral : OomuTokens.textMuted,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: OomuTokens.s12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: _isSubmitted ? null : _submitSecretAfter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OomuTokens.coral,
                    disabledBackgroundColor: OomuTokens.surfaceMuted,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(OomuTokens.r12),
                    ),
                  ),
                  child: Text(
                    _isSubmitted ? '비공개 전달 완료 💌' : '선택 완료 (비밀 유지)',
                    style: TextStyle(
                      color: _isSubmitted ? OomuTokens.textMuted : OomuTokens.surface,
                      fontWeight: OomuTokens.w700,
                      fontSize: OomuTokens.fs14,
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
}
