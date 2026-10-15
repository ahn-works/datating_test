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
      return const AssetImage('assets/images/kr_female_1.jpg');
    } else if (target.contains('507003211169') || target.contains('1500648767791') || target.contains('1527980965255') || target.contains('img=12') || target.contains('img=36')) {
      return const AssetImage('assets/images/kr_male_1.jpg');
    } else {
      return const AssetImage('assets/images/cover_food.jpg');
    }
  }

  // 1. Flutter 로컬 에셋 경로
  if (target.startsWith('assets/')) {
    return AssetImage(target);
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
