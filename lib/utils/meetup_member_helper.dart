/// 모임 정원(capacity) 및 참여 인원(attendance), 카드 표시용 members 문자열을
/// 안전하고 일관되게 정규화하는 헬퍼 클래스입니다.
/// 실DB에서 members가 List<UID> 또는 '2/4' String, 또는 누락된 경우를 완벽히 포괄합니다.
class MeetupMemberHelper {
  /// 모임의 최대 정원을 반환합니다.
  /// 우선순위: maxMembers -> capacity -> maxParticipants -> members('X/Y')의 Y -> memberCount 숫자 -> 기본값 4
  static int parseCapacity(Map<String, dynamic>? data) {
    if (data == null) return 4;

    // 1. maxMembers
    final maxMembers = data['maxMembers'];
    if (maxMembers is num && maxMembers > 0) return maxMembers.toInt();
    if (maxMembers is String) {
      final parsed = int.tryParse(maxMembers.replaceAll(RegExp(r'[^0-9]'), ''));
      if (parsed != null && parsed > 0) return parsed;
    }

    // 2. capacity
    final cap = data['capacity'];
    if (cap is num && cap > 0) return cap.toInt();
    if (cap is String) {
      final parsed = int.tryParse(cap.replaceAll(RegExp(r'[^0-9]'), ''));
      if (parsed != null && parsed > 0) return parsed;
    }

    // 3. maxParticipants
    final maxPart = data['maxParticipants'];
    if (maxPart is num && maxPart > 0) return maxPart.toInt();
    if (maxPart is String) {
      final parsed = int.tryParse(maxPart.replaceAll(RegExp(r'[^0-9]'), ''));
      if (parsed != null && parsed > 0) return parsed;
    }

    // 4. members 문자열 'X/Y'에서 Y 추출
    final rawMembers = data['members'];
    if (rawMembers is String && rawMembers.contains('/')) {
      final parts = rawMembers.split('/');
      if (parts.length >= 2) {
        final parsed =
            int.tryParse(parts.last.replaceAll(RegExp(r'[^0-9]'), ''));
        if (parsed != null && parsed > 0) return parsed;
      }
    }

    // 5. memberCount ('4명', '정원 4명' 등)
    final memberCount = data['memberCount'];
    if (memberCount is num && memberCount > 0) return memberCount.toInt();
    if (memberCount is String) {
      final match = RegExp(r'(\d+)')
          .allMatches(memberCount)
          .map((m) => m.group(1))
          .lastOrNull;
      if (match != null) {
        final parsed = int.tryParse(match);
        if (parsed != null && parsed > 0) return parsed;
      }
    }

    return 4;
  }

  /// 모임의 현재 참여 인원수를 반환합니다.
  /// 우선순위: participantIds.length -> members가 List면 length -> members가 'X/Y'면 X -> members가 숫자면 숫자 -> 기본값 1
  static int parseAttendance(Map<String, dynamic>? data) {
    if (data == null) return 1;

    // 1. participantIds 배열
    final partIds = data['participantIds'];
    if (partIds is List && partIds.isNotEmpty) {
      return partIds.length;
    }

    // 2. members 필드
    final rawMembers = data['members'];
    if (rawMembers is List) {
      return rawMembers.length;
    }
    if (rawMembers is num && rawMembers > 0) {
      return rawMembers.toInt();
    }
    if (rawMembers is String) {
      final str = rawMembers.trim();
      if (str.contains('/')) {
        final parts = str.split('/');
        final parsed =
            int.tryParse(parts.first.replaceAll(RegExp(r'[^0-9]'), ''));
        if (parsed != null && parsed >= 0) return parsed;
      } else {
        final parsed = int.tryParse(str.replaceAll(RegExp(r'[^0-9]'), ''));
        if (parsed != null && parsed >= 0) return parsed;
      }
    }

    // 3. currentMembers
    final current = data['currentMembers'];
    if (current is num && current >= 0) return current.toInt();

    return 1;
  }

  /// 모임 카드 및 상세 화면에 표시할 '참여인원/정원' (예: '2/4') 문자열을 반환합니다.
  /// - members가 List면 '${list.length}/${정원}'
  /// - members가 'X/Y' 형태의 String이면 그대로 반환
  /// - 누락되거나 기타 형식이면 '${attendance}/${capacity}'로 포맷팅
  static String formatMembersLabel(Map<String, dynamic>? data,
      {String fallback = '2/4'}) {
    if (data == null) return fallback;
    final rawMembers = data['members'];
    final cap = parseCapacity(data);

    if (rawMembers is List) {
      final count = rawMembers.length;
      return '$count/$cap';
    }

    if (rawMembers is String) {
      final str = rawMembers.trim();
      if (str.contains('/')) {
        return str;
      }
      if (str.isNotEmpty && !str.startsWith('[')) {
        final numOnly = int.tryParse(str.replaceAll(RegExp(r'[^0-9]'), ''));
        if (numOnly != null) {
          return '$numOnly/$cap';
        }
        return str;
      }
    }

    if (rawMembers is num) {
      return '${rawMembers.toInt()}/$cap';
    }

    final att = parseAttendance(data);
    return '$att/$cap';
  }

  /// 잔여석 계산 문자열 반환 (예: '2자리 남음', '모집 마감')
  static String calcRemainingSeats(Map<String, dynamic>? data,
      {String fallback = '잔여석 있음'}) {
    if (data == null) return fallback;
    if (isClosed(data)) return '모집 마감';
    final cap = parseCapacity(data);
    final att = parseAttendance(data);
    final diff = cap - att;
    if (diff <= 0) return '모집 마감';
    return '$diff자리 남음';
  }

  /// 모임 마감 여부 판별 (호스트 마감, 정원 초과, 또는 마감일 도래 시에만 true)
  static bool isClosed(Map<String, dynamic>? data) {
    if (data == null) return false;
    if (data['closedByHost'] == true ||
        data['isClosed'] == true ||
        data['closed'] == true) {
      return true;
    }
    // 정원 충족 여부 (정원이 찼을 때만 인원 마감)
    final cap = parseCapacity(data);
    final att = parseAttendance(data);
    if (cap > 0 && att >= cap) {
      return true;
    }
    // 마감 기한 초과 여부
    final dl = DateTime.tryParse((data['deadline'] ?? '').toString());
    if (dl != null && dl.isBefore(DateTime.now())) {
      return true;
    }
    return false;
  }

  /// 모임 마감 사유 반환 (마감이 아니면 null)
  static String? closeReason(Map<String, dynamic>? data) {
    if (data == null) return null;
    if (data['closedByHost'] == true) return '호스트가 모집을 마감했어요';
    final cap = parseCapacity(data);
    final att = parseAttendance(data);

    if (data['isClosed'] == true ||
        data['closed'] == true ||
        (data['status'] ?? '').toString().toLowerCase() == 'closed') {
      final dl = DateTime.tryParse((data['deadline'] ?? '').toString());
      if (dl != null && dl.isBefore(DateTime.now())) return '모집 마감일이 지났어요';
      if (att >= cap) return '정원이 다 찼어요';
      return '모집이 마감됐어요';
    }
    final dl = DateTime.tryParse((data['deadline'] ?? '').toString());
    if (dl != null && dl.isBefore(DateTime.now())) return '모집 마감일이 지났어요';
    if (cap > 0 && att >= cap) {
      return '정원이 다 찼어요';
    }
    return null;
  }

  /// 모임 상태 한글 라벨 ('모집 중' 또는 '마감')
  static String formatStatusLabel(Map<String, dynamic>? data) {
    return isClosed(data) ? '마감' : '모집 중';
  }
}

