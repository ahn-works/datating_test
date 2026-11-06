// ignore: avoid_web_libraries_in_flutter
import 'dart:convert';
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
  List<Map<String, dynamic>>? markers,
}) {
  // Use unique viewId based on coordinates, clean name, actions flag, and markers count
  final cleanName = locationName.replaceAll(RegExp(r'[^a-zA-Z0-9가-힣]'), '');
  final actionSuffix = hideActions ? '-clean' : '';
  final markersCount = markers?.length ?? 0;
  final viewType =
      'kakao-map-${lat.toStringAsFixed(4)}-${lng.toStringAsFixed(4)}-$cleanName$actionSuffix-m$markersCount';

  String markersQuery = '';
  if (markers != null && markers.isNotEmpty) {
    try {
      final jsonStr = jsonEncode(markers
          .where((m) => m['lat'] != null && m['lng'] != null)
          .map((m) => {
                'lat': m['lat'],
                'lng': m['lng'],
                'title': m['title'] ?? '',
                'category': m['category'] ?? '',
                'id': m['id'] ?? m['_id'] ?? '',
              })
          .toList());
      markersQuery = '&markers=${Uri.encodeComponent(jsonStr)}';
    } catch (_) {}
  }

  try {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..src =
            'kakao_map.html?lat=$lat&lng=$lng&name=${Uri.encodeComponent(locationName)}${hideActions ? '&hideActions=true' : ''}$markersQuery'
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
