import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/kakao_map_service.dart';
import '../../utils/app_image.dart';
import '../../utils/global_data.dart';
import '../../ui/oomu_tokens.dart';

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
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe)
            const CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/images/민지.png')),
          if (!widget.isMe) const SizedBox(width: 8),
          if (widget.isMe)
            Text(widget.msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (widget.isMe) const SizedBox(width: 4),
          Container(
            width: 270,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.35), width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.12),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.calendar_month,
                          color: Colors.blue, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.msg['title'] ?? '새로운 일정 제안',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (attendCount >= maxMembers)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6)),
                        child: const Text('마감됨',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      Row(children: [
                        const Icon(Icons.event, size: 14, color: Colors.blue),
                        const SizedBox(width: 6),
                        const Text('날짜: ',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(widget.msg['date'] ?? '-',
                            style: const TextStyle(fontSize: 12)),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.access_time,
                            size: 14, color: Colors.blue),
                        const SizedBox(width: 6),
                        const Text('시간: ',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(widget.msg['timeStr'] ?? widget.msg['time'] ?? '-',
                            style: const TextStyle(fontSize: 12)),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.place, size: 14, color: Colors.blue),
                        const SizedBox(width: 6),
                        const Text('장소: ',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(widget.msg['location'] ?? '-',
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.group, size: 14, color: Color(0xFF767676)),
                        SizedBox(width: 4),
                        Text('참석 확정 현황',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF767676))),
                      ],
                    ),
                    Text('$attendCount / $maxMembers 명',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (attendCount / maxMembers).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                        attendCount >= maxMembers ? Colors.green : Colors.blue),
                    minHeight: 6,
                  ),
                ),
                if (attendees.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: attendees
                        .map((name) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text('✓ $name',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600)),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isFull) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('모집 인원이 마감되었습니다!')));
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
                            content: Text(!isAttending
                                ? '👍 모임 참석이 확정되었습니다!'
                                : '일정 참석을 취소했습니다.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAttending
                          ? const Color(0xFFF0F0F0)
                          : (isFull ? Colors.grey[300] : Colors.blue),
                      foregroundColor:
                          isAttending ? Colors.black87 : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      isAttending
                          ? '참석 취소하기'
                          : (isFull ? '모집 마감' : '👍 저도 참석할게요!'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!widget.isMe) const SizedBox(width: 4),
          if (!widget.isMe)
            Text(widget.msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe)
            const CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/images/민지.png')),
          if (!widget.isMe) const SizedBox(width: 8),
          if (widget.isMe)
            Text(widget.msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (widget.isMe) const SizedBox(width: 4),
          Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: Colors.purple.withValues(alpha: 0.35), width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.12),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.how_to_vote,
                          color: Colors.purple, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.msg['title'] ?? '투표',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('실시간 실명 투표',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text('총 $totalVotes명 참여',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildPollOption(1, widget.msg['opt1'] ?? '옵션 1', opt1Count,
                    totalVotes, selectedOption == 1, currentNick, voters),
                const SizedBox(height: 8),
                _buildPollOption(2, widget.msg['opt2'] ?? '옵션 2', opt2Count,
                    totalVotes, selectedOption == 2, currentNick, voters),
              ],
            ),
          ),
          if (!widget.isMe) const SizedBox(width: 4),
          if (!widget.isMe)
            Text(widget.msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
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
      Map<String, dynamic> voters) {
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.purple.withValues(alpha: 0.08)
              : const Color(0xFFF7F7F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isSelected
                  ? Colors.purple
                  : Colors.grey.withValues(alpha: 0.2),
              width: isSelected ? 1.5 : 1.0),
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
                          color: isSelected ? Colors.purple : Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? Colors.purple
                                : const Color(0xFF222222),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Text('$count명',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.purple : Colors.grey[700])),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(isSelected
                    ? Colors.purple
                    : Colors.purple.withValues(alpha: 0.5)),
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
// 동적 컴포넌트: 1/N 더치페이 정산 카드
// ===========================================================================
class InteractiveHotspotCard extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMe;

  const InteractiveHotspotCard(
      {super.key, required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final String name = msg['name'] ?? '핫플 이름';
    final String address = msg['address'] ?? '주소 정보 없음';
    final double? lat = (msg['lat'] as num?)?.toDouble();
    final double? lng = (msg['lng'] as num?)?.toDouble();

    // 실제 카카오맵 링크 생성 (이름과 좌표 포함)
    final String kakaoMapUrl = (lat != null && lng != null)
        ? KakaoMapService.getKakaoMapPinUrl(name, lat, lng)
        : KakaoMapService.getKakaoSearchUrl('$name $address');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            const CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/images/민지.png')),
          if (!isMe) const SizedBox(width: 8),
          if (isMe)
            Text(msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (isMe) const SizedBox(width: 4),
          Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.brown.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                    color: Colors.brown.withValues(alpha: 0.05), blurRadius: 10)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: Colors.brown.withValues(alpha: 0.1),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.local_cafe,
                            color: Colors.brown, size: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(msg['title'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87)),
                const SizedBox(height: 4),
                Text(address,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF767676))),
                const SizedBox(height: 12),

                // 미니 지도 썸네일
                GestureDetector(
                  onTap: () async {
                    final Uri url = Uri.parse(kakaoMapUrl);
                    if (!await launchUrl(url))
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('지도를 열 수 없습니다.')));
                  },
                  child: Container(
                    height: 90,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBE6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFFEE500), width: 1.2),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE500),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2)),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on,
                                size: 14, color: Color(0xFF191919)),
                            SizedBox(width: 4),
                            Text('카카오맵에서 위치 보기',
                                style: TextStyle(
                                    color: Color(0xFF191919),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isMe) const SizedBox(width: 4),
          if (!isMe)
            Text(msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
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

  const InteractiveReviewCard(
      {super.key, required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final int rating = msg['rating'] ?? 5;
    final String text = msg['text'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            const CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/images/민지.png')),
          if (!isMe) const SizedBox(width: 8),
          if (isMe)
            Text(msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (isMe) const SizedBox(width: 4),
          Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.05),
                    blurRadius: 10)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.rate_review,
                            color: Colors.orange, size: 16)),
                    const SizedBox(width: 8),
                    const Expanded(
                        child: Text('✨ 모임 후기가 도착했어요!',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: List.generate(
                      5,
                      (index) => Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.orange,
                            size: 20,
                          )),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(text,
                      style: const TextStyle(
                          fontSize: 14, color: Colors.black87, height: 1.4)),
                ),
              ],
            ),
          ),
          if (!isMe) const SizedBox(width: 4),
          if (!isMe)
            Text(msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
        ],
      ),
    );
  }
}

// ===========================================================================
// 동적 컴포넌트: 안전 귀가 (Safe Return)
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe)
            const CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/images/민지.png')),
          if (!widget.isMe) const SizedBox(width: 8),
          if (widget.isMe)
            Text(widget.msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (widget.isMe) const SizedBox(width: 4),
          Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F5),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: Colors.pink.withValues(alpha: 0.35), width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: Colors.pink.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.pink.withValues(alpha: 0.15),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.nightlight_round,
                          color: Colors.pink, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.msg['title'] ?? '🏠 안전 귀가 알림',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.pink),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.msg['desc'] ?? '방금 집에 무사히 도착했습니다! 다들 조심히 들어가세요.',
                  style: const TextStyle(
                      fontSize: 13, height: 1.4, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () {
                    final newCheers = List<String>.from(cheers);
                    if (isLiked) {
                      newCheers.remove(currentNick);
                    } else {
                      newCheers.add(currentNick);
                    }
                    if (widget.onUpdate != null) {
                      widget.onUpdate!({'cheers': newCheers});
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(!isLiked
                            ? '💖 무사 귀가를 축하해 주셨습니다!'
                            : '안심 반응을 취소했습니다.'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isLiked ? Colors.pink : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.pink),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite,
                            color: isLiked ? Colors.white : Colors.pink,
                            size: 16),
                        const SizedBox(width: 6),
                        Text('다행이에요! $likes',
                            style: TextStyle(
                                color: isLiked ? Colors.white : Colors.pink,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!widget.isMe) const SizedBox(width: 4),
          if (!widget.isMe)
            Text(widget.msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
        ],
      ),
    );
  }
}

// ===========================================================================
// 동적 컴포넌트: 프로필 교환 (Profile Exchange)
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
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundImage: AssetImage('assets/images/민지.png'),
              ),
              const SizedBox(height: 12),
              Text(nickname,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('인증된 이웃 · 매너온도 41.2℃ 🔥',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.teal,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12)),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified_user, color: Colors.teal, size: 16),
                        SizedBox(width: 6),
                        Text('OOMU 본인 인증 및 매너 검증 완료',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text('관심사: 맛집 탐방, 주말 러닝, 로컬 아지트 탐험',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF555555))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('닫기',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe)
            const CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/images/민지.png')),
          if (!widget.isMe) const SizedBox(width: 8),
          if (widget.isMe)
            Text(widget.msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
          if (widget.isMe) const SizedBox(width: 4),
          Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)]),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.teal.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.badge, color: Colors.teal, size: 26)),
                const SizedBox(height: 10),
                Text(widget.msg['title'] ?? '명함/프로필 교환',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.teal)),
                const SizedBox(height: 6),
                Text(widget.msg['desc'] ?? '서로의 상세 프로필과 소셜 정보를 확인해볼까요?',
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black87)),
                const SizedBox(height: 14),
                if (isAccepted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showProfileModal(widget.msg['sender'] ?? '상대방'),
                      icon: const Icon(Icons.person,
                          size: 16, color: Colors.white),
                      label: const Text('교환 완료 · 프로필 보기 🤝',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                    ),
                  )
                else if (!widget.isMe)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final newAccepted = List<String>.from(acceptedMembers)
                          ..add(currentNick);
                        if (widget.onUpdate != null) {
                          widget.onUpdate!({
                            'acceptedMembers': newAccepted,
                            'status': 'accepted'
                          });
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('🎉 프로필 교환을 수락했습니다! 상세 프로필이 공개됩니다.')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Text('수락하기 🤝',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Center(
                        child: Text('상대방의 수락을 대기중입니다...',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.teal,
                                fontWeight: FontWeight.bold))),
                  ),
              ],
            ),
          ),
          if (!widget.isMe) const SizedBox(width: 4),
          if (!widget.isMe)
            Text(widget.msg['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Color(0xFF767676))),
        ],
      ),
    );
  }
}

// ===========================================================================
// 동적 컴포넌트: 시크릿 애프터 1:1 호감 매칭 (Secret After Match)
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
            '💌 ${_selectedMembers.join(", ")}님에게 비공개 호감이 전달되었습니다! (0% 노출 보장)'),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }

  void _simulateMutualMatch() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.pinkAccent),
            SizedBox(width: 8),
            Text('💖 시크릿 매칭 성사!',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage: AssetImage('assets/images/민지.png'),
            ),
            SizedBox(height: 12),
            Text(
              '민지님도 당신에게 호감을 표시했습니다! 💕',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '두 분만의 1:1 소개팅 단독 대화방이 생성되었습니다.\n자연스럽게 대화를 이어가 보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('💬 1:1 시크릿 소개팅 대화방으로 이동합니다!'),
                    backgroundColor: Colors.pinkAccent,
                  ),
                );
              },
              child: const Text('1:1 소개팅 대화방 열기 💬',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF0F5), Color(0xFFFFE4E1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.pinkAccent.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.pinkAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '시크릿 애프터 1:1 호감 매칭',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC2185B)),
                        ),
                        Text(
                          '상호 선택 시에만 1:1 대화방 개설 (거절 부담 0%)',
                          style:
                              TextStyle(fontSize: 11, color: Color(0xFF880E4F)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                '오늘 모임에서 대화가 가장 잘 통했던 멤버 1~2명을 선택하세요.',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333)),
              ),
              const SizedBox(height: 12),
              Column(
                children: _candidates.map((cand) {
                  final isSelected = _selectedMembers.contains(cand['name']);
                  return GestureDetector(
                    onTap: () => _toggleMember(cand['name']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? Colors.pinkAccent
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                    color: Colors.pinkAccent
                                        .withValues(alpha: 0.2),
                                    blurRadius: 8)
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: appImg(cand['avatar']!),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cand['name']!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                                Text(
                                  cand['tag']!,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isSelected ? Icons.favorite : Icons.favorite_border,
                            color: isSelected ? Colors.pinkAccent : Colors.grey,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              if (!_isSubmitted)
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _submitSecretAfter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      '비공개 호감 전달하기 (${_selectedMembers.length}명 선택)',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                )
              else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, size: 16, color: Colors.pinkAccent),
                      SizedBox(width: 6),
                      Text(
                        '💌 비공개 호감 전송 완료! (상대방 응답 대기 중)',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.pinkAccent,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: _simulateMutualMatch,
                    icon: const Icon(Icons.flash_on,
                        size: 16, color: Colors.purple),
                    label: const Text(
                      '🧪 상호 매칭 성사 시뮬레이션 테스트',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
