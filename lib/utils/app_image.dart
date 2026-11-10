import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/r2_storage_service.dart';

/// 로컬 에셋(assets/...), 로컬 파일 경로(File), 웹 Blob, Cloudflare R2 및 네트워크 URL을 모두 완벽 지원하는 이미지 헬퍼.
ImageProvider appImg(String? path, {String fallback = 'assets/images/cover_food.jpg'}) {
  final target = (path != null && path.trim().isNotEmpty) ? path.trim() : fallback;
  if (target.contains('unsplash.com') || target.contains('pravatar.cc') || target.contains('picsum.photos')) {
    if (target.contains('1511895426328') || target.contains('cafe') || target.contains('1554118811') || target.contains('1501339817309')) {
      return const AssetImage('assets/images/cover_cafe.jpg');
    } else if (target.contains('wine') || target.contains('1510812431401') || target.contains('1516280440502')) {
      return const AssetImage('assets/images/cover_wine.jpg');
    } else if (target.contains('run') || target.contains('1502680390469') || target.contains('1552674605') || target.contains('1519681393784')) {
      return const AssetImage('assets/images/cover_running.jpg');
    } else if (target.contains('534528741775') || target.contains('1517841905240') || target.contains('1438761681033') || target.contains('img=33') || target.contains('img=5') || target.contains('img=47') || target.contains('img=45')) {
      return const AssetImage('assets/images/민지.png');
    } else if (target.contains('507003211169') || target.contains('1500648767791') || target.contains('1527980965255') || target.contains('img=12') || target.contains('img=36')) {
      return const AssetImage('assets/images/지훈.png');
    } else {
      return const AssetImage('assets/images/cover_food.jpg');
    }
  }

  // 1. Flutter 로컬 에셋 경로
  if (target.startsWith('assets/')) {
    return AssetImage(target);
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
    if (fileName.contains('cafe')) return const AssetImage('assets/images/cover_cafe.jpg');
    if (fileName.contains('wine')) return const AssetImage('assets/images/cover_wine.jpg');
    if (fileName.contains('run')) return const AssetImage('assets/images/cover_running.jpg');
    if (fileName.contains('bread') || fileName.contains('salt')) return const AssetImage('assets/images/cover_salt_bread.jpg');
    if (fileName.contains('hangang')) return const AssetImage('assets/images/cover_running_hangang.jpg');
    return const AssetImage('assets/images/cover_food.jpg');
  }

  // 2. 모바일 / 데스크톱 네이티브 로컬 파일 경로 (FileImage 지원)
  if (!kIsWeb && !target.startsWith('http://') && !target.startsWith('https://') && !target.startsWith('blob:')) {
    try {
      final file = io.File(target);
      if (file.existsSync()) {
        return FileImage(file);
      }
    } catch (_) {}
  }

  // 3. Cloudflare R2 Presigned / Public URL 자동 변환
  final resolvedUrl = r2Storage.getPublicViewUrl(target, defaultFallback: fallback);
  if (resolvedUrl.startsWith('assets/')) {
    return AssetImage(resolvedUrl);
  }

  // 4. 웹 blob: 및 네트워크 URL
  return NetworkImage(resolvedUrl);
}

Widget appNetImage(String? path, {BoxFit? fit, double? width, double? height, String fallback = 'assets/images/cover_food.jpg'}) {
  return Image(
    image: appImg(path, fallback: fallback),
    fit: fit,
    width: width,
    height: height,
    errorBuilder: (_, __, ___) => Container(
      width: width,
      height: height,
      color: const Color(0xFFF5F5F7),
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
    ),
  );
}

/// DiceBear 기반 2030 감성 캐릭터 아바타 PNG URL 생성 (무료, 무인증, 영구 캐시)
/// - seed: 유저 이메일 주소 또는 닉네임 (동일한 시드 = 언제나 동일한 얼굴 보장)
/// - style: 'lorelei' (2030 세련된 감성 일러스트 캐릭터, OOMU 1순위 추천)
String getDiceBearAvatarUrl(String seed, {String style = 'lorelei', int size = 128}) {
  final cleanSeed = Uri.encodeComponent(seed.trim().toLowerCase());
  return 'https://api.dicebear.com/9.x/$style/png?seed=$cleanSeed&size=$size';
}

const Map<String, String> _bundledProfileMap = {
  '민지.png': '민지.png',
  '민지2.png': '민지.png',
  '시연.png': '시연.png',
  '정재.png': '정재.png',
  '정재2.png': '정재.png',
  '주아.png': '주아.png',
  '지안.png': '지안.png',
  '지안2.png': '지안.png',
  '지연.png': '지연.png',
  '지연2.png': '지연.png',
  '지연3.png': '지연.png',
  '지훈.png': '지훈.png',
  '지훈2.png': '지훈.png',
  '지훈3.png': '지훈.png',
  '초연.png': '초연.png',
  'minji.png': '민지.png',
  'minji2.png': '민지.png',
  'siyan.png': '시연.png',
  'jeongjae.png': '정재.png',
  'jeongjae2.png': '정재.png',
  'jua.png': '주아.png',
  'jian.png': '지안.png',
  'jian2.png': '지안.png',
  'jiyeon.png': '지연.png',
  'jiyeon2.png': '지연.png',
  'jiyeon3.png': '지연.png',
  'jihun.png': '지훈.png',
  'jihun2.png': '지훈.png',
  'jihun3.png': '지훈.png',
  'choyeon.png': '초연.png',
  'test_user_01.jpg': '민지.png',
  'test_user_02.jpg': '지훈.png',
  'test_user_03.jpg': '지연.png',
  'user_yeosu_neighbor.jpg': '초연.png',
  'bot_mangwon_runner.jpg': '지안.png',
  'bot_seongsu_wine.jpg': '정재.png',
  'bot_yeosu_food.jpg': '정재.png',
  'bot_yeosu_karaoke.jpg': '시연.png',
  'bot_yeosu_ungcheon.jpg': '지안.png',
  'bot_yeosu_running.jpg': '지훈.png',
  'bot_yeosu_bakery.jpg': '주아.png',
};

String? _resolveBundledProfileAsset(String rawName) {
  final trimmed = rawName.trim();
  if (_bundledProfileMap.containsKey(trimmed)) {
    return _bundledProfileMap[trimmed];
  }
  if (trimmed.contains('%')) {
    try {
      final decoded = Uri.decodeComponent(trimmed).trim();
      if (_bundledProfileMap.containsKey(decoded)) {
        return _bundledProfileMap[decoded];
      }
    } catch (_) {}
  }
  return null;
}
