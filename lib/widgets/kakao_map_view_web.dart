// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Widget buildKakaoMapWidget({
  required double lat,
  required double lng,
  required String locationName,
  required double height,
  required double width,
  bool hideActions = false,
}) {
  // Use unique viewId based on coordinates, clean name, and hideActions flag
  final cleanName = locationName.replaceAll(RegExp(r'[^a-zA-Z0-9가-힣]'), '');
  final actionSuffix = hideActions ? '-clean' : '';
  final viewType = 'kakao-map-${lat.toStringAsFixed(4)}-${lng.toStringAsFixed(4)}-$cleanName$actionSuffix';
  
  try {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = 'kakao_map.html?lat=$lat&lng=$lng&name=${Uri.encodeComponent(locationName)}${hideActions ? '&hideActions=true' : ''}'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.borderRadius = '16px';
      return iframe;
    });
  } catch (_) {
    // Factory might already be registered for this viewType
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: SizedBox(
      width: width,
      height: height,
      child: HtmlElementView(viewType: viewType),
    ),
  );
}
