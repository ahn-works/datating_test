import 'package:flutter/material.dart';

/// 로컬 에셋(assets/...) 또는 네트워크 URL을 모두 지원하는 이미지 헬퍼.
ImageProvider appImg(String path) {
  if (path.startsWith('assets/')) return AssetImage(path);
  return NetworkImage(path);
}

Widget appNetImage(String path, {BoxFit? fit, double? width, double? height}) {
  return Image(
    image: appImg(path),
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
