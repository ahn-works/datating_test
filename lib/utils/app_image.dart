import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/r2_storage_service.dart';

/// 로컬 에셋(assets/...), 로컬 파일 경로(File), 웹 Blob, Cloudflare R2 및 네트워크 URL을 모두 완벽 지원하는 이미지 헬퍼.
ImageProvider appImg(String? path,
    {String fallback = 'assets/images/cover_food.jpg'}) {
  final target =
      (path != null && path.trim().isNotEmpty) ? path.trim() : fallback;
  if (target.contains('unsplash.com') ||
      target.contains('pravatar.cc') ||
      target.contains('picsum.photos')) {
    if (target.contains('1511895426328') ||
        target.contains('cafe') ||
        target.contains('1554118811') ||
        target.contains('1501339817309')) {
      return const AssetImage('assets/images/cover_cafe.jpg');
    } else if (target.contains('wine') ||
        target.contains('1510812431401') ||
        target.contains('1516280440502')) {
      return const AssetImage('assets/images/cover_wine.jpg');
    } else if (target.contains('run') ||
        target.contains('1502680390469') ||
        target.contains('1552674605') ||
        target.contains('1519681393784')) {
      return const AssetImage('assets/images/cover_running.jpg');
    } else if (target.contains('534528741775') ||
        target.contains('1517841905240') ||
        target.contains('1438761681033') ||
        target.contains('img=33') ||
        target.contains('img=5') ||
        target.contains('img=47') ||
        target.contains('img=45')) {
      return const AssetImage('assets/images/민지.png');
    } else if (target.contains('507003211169') ||
        target.contains('1500648767791') ||
        target.contains('1527980965255') ||
        target.contains('img=12') ||
        target.contains('img=36')) {
      return const AssetImage('assets/images/지훈.png');
    } else {
      return const AssetImage('assets/images/cover_food.jpg');
    }
  }

  // 1. Flutter 로컬 에셋 경로 (한글 파일명은 Web/GitHub Pages 인코딩 오류 방지 위해 안전한 영문 에셋으로 자동 매핑)
  if (target.startsWith('assets/')) {
    final safePath = _resolveSafeAssetPath(target);
    return AssetImage(safePath);
  }

  // 1-1. R2 프로필 키 중 번들 에셋에 존재하는 실제 사진 즉시 로컬 에셋 매핑 (CORS 및 렌더링 지연 원천 차단)
  if (target.startsWith('profiles/') || target.startsWith('/profiles/')) {
    final cleanKey = target.startsWith('/') ? target.substring(1) : target;
    final fileName = cleanKey.substring('profiles/'.length);
    final mappedAsset = _resolveBundledProfileAsset(fileName);
    if (mappedAsset != null) {
      return AssetImage('assets/images/$mappedAsset');
    }
  }

  // 1-2. R2 커버 키 중 번들 에셋 매핑
  if (target.startsWith('covers/') || target.startsWith('/covers/')) {
    final cleanKey = target.startsWith('/') ? target.substring(1) : target;
    final fileName = cleanKey.substring('covers/'.length);
    if (fileName.contains('cafe'))
      return const AssetImage('assets/images/cover_cafe.jpg');
    if (fileName.contains('wine'))
      return const AssetImage('assets/images/cover_wine.jpg');
    if (fileName.contains('run'))
      return const AssetImage('assets/images/cover_running.jpg');
    if (fileName.contains('bread') || fileName.contains('salt'))
      return const AssetImage('assets/images/cover_salt_bread.jpg');
    if (fileName.contains('hangang'))
      return const AssetImage('assets/images/cover_running_hangang.jpg');
    return const AssetImage('assets/images/cover_food.jpg');
  }

  // 1-3. 만료되었거나 타 세션의 웹 Blob URL은 접근 불가하므로 안전 폴백 에셋으로 즉시 변환
  if (target.startsWith('blob:')) {
    return AssetImage(fallback.startsWith('assets/')
        ? fallback
        : 'assets/images/cover_food.jpg');
  }

  // 2. 모바일 / 데스크톱 네이티브 로컬 파일 경로 (FileImage 지원)
  if (!kIsWeb &&
      !target.startsWith('http://') &&
      !target.startsWith('https://') &&
      !target.startsWith('blob:')) {
    try {
      final file = io.File(target);
      if (file.existsSync()) {
        return FileImage(file);
      }
    } catch (_) {}
  }

  // 3. Cloudflare R2 Presigned / Public URL 자동 변환
  String resolvedUrl =
      r2Storage.getPublicViewUrl(target, defaultFallback: fallback);
  if ((resolvedUrl.contains('.gif') ||
          resolvedUrl.contains('stickers/') ||
          resolvedUrl.contains('giphy.com')) &&
      resolvedUrl.contains('&output=jpg')) {
    resolvedUrl = resolvedUrl.replaceAll('&output=jpg', '&output=gif&n=-1');
  }
  if (resolvedUrl.startsWith('assets/')) {
    return AssetImage(resolvedUrl);
  }

  // 4. 웹 blob: 및 네트워크 URL
  return NetworkImage(resolvedUrl);
}

Widget appNetImage(String? path,
    {BoxFit? fit,
    double? width,
    double? height,
    String fallback = 'assets/images/cover_food.jpg'}) {
  final cleanFallback =
      (fallback.isNotEmpty) ? fallback : 'assets/images/cover_food.jpg';
  final fallbackAsset = cleanFallback.startsWith('assets/')
      ? cleanFallback
      : 'assets/images/cover_food.jpg';
  final safeFallback = _resolveSafeAssetPath(fallbackAsset);

  return Image(
    image: appImg(path, fallback: safeFallback),
    fit: fit,
    width: width,
    height: height,
    errorBuilder: (_, __, ___) => Image.asset(
      safeFallback,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/cover_food.jpg',
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: const Color(0xFFF5F5F7),
          child: const Center(
            child:
                Icon(Icons.photo_outlined, color: Color(0xFFC7C7CC), size: 28),
          ),
        ),
      ),
    ),
  );
}

/// DiceBear 기반 2030 감성 캐릭터 아바타 PNG URL 생성 (무료, 무인증, 영구 캐시)
/// - seed: 유저 이메일 주소 또는 닉네임 (동일한 시드 = 언제나 동일한 얼굴 보장)
/// - style: 'lorelei' (2030 세련된 감성 일러스트 캐릭터, OOMU 1순위 추천)
String getDiceBearAvatarUrl(String seed,
    {String style = 'lorelei', int size = 128}) {
  final cleanSeed = Uri.encodeComponent(seed.trim().toLowerCase());
  return 'https://api.dicebear.com/9.x/$style/png?seed=$cleanSeed&size=$size';
}

const Map<String, String> _bundledProfileMap = {
  '민지.png': 'minji.png',
  '민지2.png': 'minji.png',
  '시연.png': 'siyeon.png',
  '정재.png': 'jungjae.png',
  '정재2.png': 'jungjae.png',
  '주아.png': 'jua.png',
  '지안.png': 'jian.png',
  '지안2.png': 'jian.png',
  '지연.png': 'jiyeon.png',
  '지연2.png': 'jiyeon.png',
  '지연3.png': 'jiyeon.png',
  '지훈.png': 'jihun.png',
  '지훈2.png': 'jihun.png',
  '지훈3.png': 'jihun.png',
  '초연.png': 'choyeon.png',
  'minji.png': 'minji.png',
  'minji2.png': 'minji.png',
  'siyan.png': 'siyeon.png',
  'siyeon.png': 'siyeon.png',
  'jeongjae.png': 'jungjae.png',
  'jungjae.png': 'jungjae.png',
  'jua.png': 'jua.png',
  'jian.png': 'jian.png',
  'jian2.png': 'jian.png',
  'jiyeon.png': 'jiyeon.png',
  'jiyeon2.png': 'jiyeon.png',
  'jiyeon3.png': 'jiyeon.png',
  'jihun.png': 'jihun.png',
  'jihun2.png': 'jihun.png',
  'jihun3.png': 'jihun.png',
  'choyeon.png': 'choyeon.png',
  'p_choyeon.jpg': 'p_choyeon.jpg',
  'test_user_01.jpg': 'minji.png',
  'test_user_02.jpg': 'jihun.png',
  'test_user_03.jpg': 'jiyeon.png',
  'user_yeosu_neighbor.jpg': 'choyeon.png',
  'bot_mangwon_runner.jpg': 'jian.png',
  'bot_seongsu_wine.jpg': 'jungjae.png',
  'bot_yeosu_food.jpg': 'jungjae.png',
  'bot_yeosu_karaoke.jpg': 'siyeon.png',
  'bot_yeosu_ungcheon.jpg': 'jian.png',
  'bot_yeosu_running.jpg': 'jihun.png',
  'bot_yeosu_bakery.jpg': 'jua.png',
};

/// 한글 파일명 에셋을 웹/서버 안전한 ASCII 에셋 경로로 매핑 (Web 환경에서 URL 인코딩 불일치 방지)
String _resolveSafeAssetPath(String path) {
  if (!kIsWeb) return path;
  if (!path.startsWith('assets/images/')) return path;
  final fn = path.substring('assets/images/'.length);
  if (_bundledProfileMap.containsKey(fn)) {
    return 'assets/images/${_bundledProfileMap[fn]}';
  }
  return path;
}

String? _resolveBundledProfileAsset(String rawName) {
  final trimmed = rawName.trim();
  if (kIsWeb && _bundledProfileMap.containsKey(trimmed)) {
    return _bundledProfileMap[trimmed];
  }
  if (!kIsWeb &&
      (trimmed == '초연.png' ||
          trimmed == '민지.png' ||
          trimmed == '시연.png' ||
          trimmed == '정재.png' ||
          trimmed == '주아.png' ||
          trimmed == '지안.png' ||
          trimmed == '지연.png' ||
          trimmed == '지훈.png')) {
    return trimmed;
  }
  if (trimmed.contains('%')) {
    try {
      final decoded = Uri.decodeComponent(trimmed).trim();
      if (_bundledProfileMap.containsKey(decoded)) {
        return kIsWeb ? _bundledProfileMap[decoded] : decoded;
      }
    } catch (_) {}
  }
  // 추가: 초연 / test 계정 / 주요 프로필 키워드 자동 매핑 (CORS 및 로드 오류 원천 차단)
  if (trimmed.contains('초연') ||
      trimmed.contains('choyeon') ||
      trimmed.startsWith('test_')) {
    return kIsWeb ? 'choyeon.png' : '초연.png';
  }
  if (trimmed.contains('민지') || trimmed.contains('minji')) {
    return kIsWeb ? 'minji.png' : '민지.png';
  }
  if (trimmed.contains('주아') || trimmed.contains('jua')) {
    return kIsWeb ? 'jua.png' : '주아.png';
  }
  if (trimmed.contains('시연') ||
      trimmed.contains('siyeon') ||
      trimmed.contains('siyan')) {
    return kIsWeb ? 'siyeon.png' : '시연.png';
  }
  if (trimmed.contains('지안') || trimmed.contains('jian')) {
    return kIsWeb ? 'jian.png' : '지안.png';
  }
  if (trimmed.contains('정재') ||
      trimmed.contains('jungjae') ||
      trimmed.contains('jeongjae')) {
    return kIsWeb ? 'jungjae.png' : '정재.png';
  }
  if (trimmed.contains('지훈') || trimmed.contains('jihun')) {
    return kIsWeb ? 'jihun.png' : '지훈.png';
  }
  if (trimmed.contains('지연') || trimmed.contains('jiyeon')) {
    return kIsWeb ? 'jiyeon.png' : '지연.png';
  }
  return null;
}
