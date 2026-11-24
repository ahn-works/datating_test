import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../ui/oomu_theme.dart';
import '../ui/oomu_tokens.dart';
import 'global_data.dart';

/// OOMU 공통 UI/데이터 정규화 헬퍼 및 테마 토큰 (docs/OOMU_UI_GUIDE.md 60-30-10 단일 기준)
class OomuUiHelpers {
  OomuUiHelpers._();

  static String formatMeetupCost(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || text.contains('안심 정산') || text.contains('안심정산')) {
      return '비용 안내 확인 필요';
    }
    return text;
  }

  // 1. 핵심 컬러 토큰 (무채색 90% + 코랄 포인트 10% 원칙)
  static const Color brandCoral = OomuTokens.coral;
  static const Color brandCoralSoft = Color(0xFFFFF0F2);
  static const Color brandCoralBorder = Color(0xFFFCD3D9);
  static const Color brandCoralText = OomuTokens.coralText;

  static const Color backgroundNeutral = OomuTokens.background;
  static const Color surfaceCard = OomuTokens.surface;
  static const Color surfaceMuted = OomuTokens.surfaceMuted;
  static const Color borderSubtle = OomuTokens.border;
  static const Color borderNeutral = OomuTokens.border;

  static const Color textPrimary = OomuTokens.textPrimary;
  static const Color textBody = OomuTokens.textBody;
  static const Color textSecondary = OomuTokens.textSecondary;
  static const Color textMuted = OomuTokens.textMuted;

  static const Color safeTeal = OomuTokens.verified;
  static const Color safeTealBg = Color(0xFFF0FDFA);

  static const List<String> koreanFontFallback = OomuTokens.fontFallback;

  /// 2. 제목 문자열 정규화 (표시 시점에 말미 장식 이모지만 제거)
  static String formatTitle(String? title, {String fallback = '취향 모임'}) {
    if (title == null) return fallback;
    final cleaned = title.replaceAll('\u2060', '').trim();
    if (cleaned.isEmpty) return fallback;
    final emojiOnly = RegExp(
      r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}\u{2B00}-\u{2BFF}]+$',
      unicode: true,
    );
    final body = cleaned.replaceAll(emojiOnly, '').trim();
    return body.isEmpty ? fallback : body;
  }

  /// 호스트/유저 본인인증 여부 단일 판정 (문서에 인증 필드가 없을 때만 meetup 폴백 사용)
  static bool resolveVerified(
    Map<String, dynamic>? userDoc,
    Map<String, dynamic>? meetup, {
    bool isSelf = false,
  }) {
    if (isSelf) {
      return globalData.isPhoneVerified.value ||
          userDoc?['isPhoneVerified'] == true ||
          userDoc?['isVerified'] == true;
    }
    if (userDoc?['isPhoneVerified'] == true ||
        userDoc?['isVerified'] == true ||
        userDoc?['phoneVerified'] == true) {
      return true;
    }
    final hasField = userDoc != null &&
        (userDoc.containsKey('isPhoneVerified') ||
            userDoc.containsKey('isVerified'));
    if (!hasField) {
      return meetup?['isVerified'] == true || meetup?['hostVerified'] == true;
    }
    return false;
  }

  /// 3. 단일 매너온도 값 파싱 (num 및 숫자 문자열 호환, 0 초과 유효, 유효하지 않으면 null 반환)
  static double? parseMannerValue(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) {
      final val = raw.toDouble();
      if (val.isNaN || val.isInfinite || val <= 0) return null;
      return val;
    }
    if (raw is String) {
      final cleaned = raw
          .replaceAll('°C', '')
          .replaceAll('℃', '')
          .replaceAll('도', '')
          .trim();
      if (cleaned.isEmpty) return null;
      final parsed = double.tryParse(cleaned);
      if (parsed == null || parsed.isNaN || parsed.isInfinite || parsed <= 0) {
        return null;
      }
      return parsed;
    }
    return null;
  }

  /// 3-1. 전역 단일 표준 모집 상태 뱃지 (모집중: 코랄 틴트, 모집 마감: 쿨그레이)
  static Widget buildStatusBadge({required bool isClosed, String? label}) {
    final text = label ?? (isClosed ? '모집 마감' : '모집중');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: isClosed ? const Color(0xFFF3F4F6) : const Color(0xFFFFF0F1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isClosed ? const Color(0xFFE5E7EB) : const Color(0xFFFFD4D8),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isClosed ? const Color(0xFF6B7280) : const Color(0xFFFF5A5F),
          fontFamily: 'Pretendard',
        ),
      ),
    );
  }

  /// 4. 모임/게시글 Map에서 호스트 매너온도 추출 (우선순위: `manner` -> `mannerTemp`)
  static double? parseMannerTemp(Map<String, dynamic>? data) {
    if (data == null) return null;
    return parseMannerValue(data['manner']) ??
        parseMannerValue(data['mannerTemp']);
  }

  /// 5. 매너온도 일관된 문자열 포맷팅
  static String formatMannerTemp(double? temp, {bool shortEmpty = true}) {
    if (temp == null) {
      return shortEmpty ? '정보 없음' : '매너온도 정보 없음';
    }
    return '${temp.toStringAsFixed(1)}°C';
  }

  /// 6. 매너온도 구간별 일관된 텍스트 색상 (원색 충돌 방지를 위해 차분한 슬레이트/틸 톤 유지)
  static Color mannerTempColor(double? temp) {
    if (temp == null) return textSecondary;
    if (temp < 36.5) return textSecondary;
    return textBody;
  }

  /// 7. 매너온도 구간별 배지 배경 색상 (우측 코랄 배지와 충돌하지 않는 중립 쿨그레이 칩)
  static Color mannerTempBgColor(double? temp) {
    return surfaceMuted;
  }

  /// 8. 매너온도 구간별 이모지
  static String mannerTempEmoji(double? temp) {
    if (temp == null) return '🌡️';
    if (temp < 36.5) return '🙂';
    if (temp < 40.0) return '😊';
    if (temp < 50.0) return '😄';
    return '🔥';
  }

  /// 9. 잔여석 계산 헬퍼 (null 안전 보장)
  static String calcRemainingSeats(dynamic memberValue,
      {String fallback = '잔여석 있음'}) {
    if (memberValue == null) return fallback;
    final memberStr = memberValue.toString().trim();
    if (memberStr.isEmpty) return fallback;
    try {
      final parts = memberStr.split('/');
      if (parts.length == 2) {
        final current = int.parse(parts[0].replaceAll(RegExp(r'[^0-9]'), ''));
        final total = int.parse(parts[1].replaceAll(RegExp(r'[^0-9]'), ''));
        final diff = total - current;
        if (diff <= 0) return '모집 마감';
        return '$diff자리 남음';
      }
    } catch (_) {}
    return fallback;
  }

  /// 10. 모임 데이터에 저장된 유효 좌표 추출 (유효하지 않거나 0이면 null)
  static ({double lat, double lng})? extractValidCoords(
      Map<String, dynamic>? data) {
    if (data == null) return null;
    final rawLat = data['lat'] ?? data['latitude'];
    final rawLng = data['lng'] ?? data['longitude'];
    final lat = rawLat is num
        ? rawLat.toDouble()
        : double.tryParse(rawLat?.toString() ?? '');
    final lng = rawLng is num
        ? rawLng.toDouble()
        : double.tryParse(rawLng?.toString() ?? '');
    if (lat == null || lng == null) return null;
    if (lat.isNaN || lng.isNaN || lat <= 0 || lng <= 0) return null;
    if (lat < 30.0 || lat > 45.0 || lng < 120.0 || lng > 135.0) return null;
    return (lat: lat, lng: lng);
  }

  /// 11. 동네/지역 일치 점수 및 타 지역 제외 판정 (SSOT)
  /// - 3: 같은 동/읍/면/가 일치
  /// - 2: 같은 시/구 또는 동일 생활권 클러스터 일치
  /// - 1: 토큰 부분 일치
  /// - 0: 다른 지역 (제외 대상)
  static int calculateLocationRelevanceScore(
      String currentLocation, String itemLocation) {
    final current = currentLocation.trim();
    final item = itemLocation.trim();
    if (current.isEmpty || item.isEmpty) return 0;

    final parts = current
        .replaceAll('(', ' ')
        .replaceAll(')', ' ')
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();

    // 1. Exact dong/eup/myeon/ga match -> Score 3
    for (final p in parts.reversed) {
      if (p.endsWith('동') ||
          p.endsWith('읍') ||
          p.endsWith('면') ||
          p.endsWith('가')) {
        final stem = p.length > 2 ? p.substring(0, p.length - 1) : p;
        if (item.contains(p) || (stem.length >= 2 && item.contains(stem))) {
          return 3;
        }
      }
    }

    // 2. City / District / Cluster match -> Score 2
    const yeosuCluster = [
      '여수',
      '화장',
      '학동',
      '웅천',
      '여서',
      '선소',
      '무선',
      '성산',
      '해양공원',
      '신기동'
    ];
    const mapoCluster = ['마포', '서교', '연남', '망원', '합정', '상수', '홍대'];

    final bool currentIsYeosu = yeosuCluster.any((k) => current.contains(k));
    final bool itemIsYeosu = yeosuCluster.any((k) => item.contains(k));
    if (currentIsYeosu) {
      return itemIsYeosu ? 2 : 0;
    }
    if (itemIsYeosu && !currentIsYeosu) {
      return 0;
    }

    // 마포 생활권 (마포, 서교, 연남, 망원, 합정, 상수, 홍대) - 타 자치구(강남/성동/송파 등) 모임 엄격 배제
    final bool currentIsMapo = mapoCluster.any((k) => current.contains(k));
    final bool itemIsMapo = mapoCluster.any((k) => item.contains(k));
    if (currentIsMapo) {
      return itemIsMapo ? 2 : 0;
    }
    if (itemIsMapo && !currentIsMapo) {
      return 0;
    }

    // 강남 생활권 (강남, 역삼, 선릉, 신사, 압구정, 논현, 청담, 서초)
    const gangnamCluster = ['강남', '역삼', '선릉', '신사', '압구정', '논현', '청담', '서초'];
    final bool currentIsGangnam =
        gangnamCluster.any((k) => current.contains(k));
    final bool itemIsGangnam = gangnamCluster.any((k) => item.contains(k));
    if (currentIsGangnam) {
      return itemIsGangnam ? 2 : 0;
    }
    if (itemIsGangnam && !currentIsGangnam) {
      return 0;
    }

    // 성수 생활권 (성수, 성동, 뚝섬, 서울숲)
    const seongsuCluster = ['성수', '성동', '뚝섬', '서울숲'];
    final bool currentIsSeongsu =
        seongsuCluster.any((k) => current.contains(k));
    final bool itemIsSeongsu = seongsuCluster.any((k) => item.contains(k));
    if (currentIsSeongsu) {
      return itemIsSeongsu ? 2 : 0;
    }
    if (itemIsSeongsu && !currentIsSeongsu) {
      return 0;
    }

    // 영등포·신길 생활권 (영등포, 신길, 여의도, 문래, 당산, 대방)
    const yeongdeungpoCluster = ['영등포', '신길', '여의도', '문래', '당산', '대방'];
    final bool currentIsYdp =
        yeongdeungpoCluster.any((k) => current.contains(k));
    final bool itemIsYdp = yeongdeungpoCluster.any((k) => item.contains(k));
    if (currentIsYdp) {
      return itemIsYdp ? 2 : 0;
    }
    if (itemIsYdp && !currentIsYdp) {
      return 0;
    }

    for (final p in parts) {
      final clean = p
          .replaceAll('전남', '')
          .replaceAll('전라남도', '')
          .replaceAll('서울특별시', '')
          .replaceAll('서울시', '')
          .replaceAll('서울', '')
          .replaceAll('시', '')
          .replaceAll('구', '')
          .replaceAll('군', '')
          .trim();
      if (item.contains(p) || (clean.length >= 2 && item.contains(clean))) {
        return 2;
      }
    }

    for (final p in parts) {
      if (p.length >= 2 && item.contains(p)) {
        return 1;
      }
    }
    return 0;
  }

  /// 현재 설정 지역과 아이템 지역이 같은 지역권인지 판정 (지역 미기재 문서는 유지, 타 지역은 제외)
  static bool matchesRegionFilter(String currentLocation, String itemLocation) {
    final current = currentLocation.trim();
    final item = itemLocation.trim();
    if (current.isEmpty || item.isEmpty) return true;
    return calculateLocationRelevanceScore(current, item) > 0;
  }

  /// 12. OOMU 공통 ThemeData (정의는 lib/ui/oomu_theme.dart 단일 원천)
  static ThemeData buildTheme() => buildOomuTheme();

  /// 실제 유저(`users`)와 봇(`bots`) 컬렉션을 분리 유지하면서도 프로필을 단일 경로로 조회한다.
  static Future<MapEntry<String, Map<String, dynamic>>?> fetchUserOrBotProfile({
    String uid = '',
    String nickname = '',
  }) async {
    if (Firebase.apps.isEmpty) return null;
    final db = FirebaseFirestore.instance;
    final cleanUid = uid.trim();
    final cleanNick = nickname.trim();

    if (cleanUid.isNotEmpty && cleanUid != 'guest') {
      final order = cleanUid.startsWith('bot_') ? ['bots', 'users'] : ['users', 'bots'];
      for (final coll in order) {
        final doc = await db.collection(coll).doc(cleanUid).get();
        if (doc.exists && doc.data() != null) {
          return MapEntry(doc.id, doc.data()!);
        }
      }
    }

    if (cleanNick.isNotEmpty && cleanNick != '모임 호스트' && cleanNick != '닉네임 미설정') {
      for (final coll in const ['users', 'bots']) {
        final q = await db.collection(coll).where('nickname', isEqualTo: cleanNick).limit(1).get();
        if (q.docs.isNotEmpty) {
          return MapEntry(q.docs.first.id, q.docs.first.data());
        }
      }
    }
    return null;
  }
}
