// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:convert';
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
  List<Map<String, dynamic>>? markers,
  String? selectedMarkerId,
  int zoomLevel = 3,
  void Function(String markerId, bool shouldOpenDetail)? onMarkerTap,
}) {
  return _KakaoMapWebView(
    lat: lat,
    lng: lng,
    locationName: locationName,
    height: height,
    width: width,
    hideActions: hideActions,
    markers: markers,
    selectedMarkerId: selectedMarkerId,
    zoomLevel: zoomLevel,
    onMarkerTap: onMarkerTap,
  );
}

class _KakaoMapWebView extends StatefulWidget {
  final double lat;
  final double lng;
  final String locationName;
  final double height;
  final double width;
  final bool hideActions;
  final List<Map<String, dynamic>>? markers;
  final String? selectedMarkerId;
  final int zoomLevel;
  final void Function(String markerId, bool shouldOpenDetail)? onMarkerTap;

  const _KakaoMapWebView({
    required this.lat,
    required this.lng,
    required this.locationName,
    required this.height,
    required this.width,
    required this.hideActions,
    this.markers,
    this.selectedMarkerId,
    required this.zoomLevel,
    this.onMarkerTap,
  });

  @override
  State<_KakaoMapWebView> createState() => _KakaoMapWebViewState();
}

class _KakaoMapWebViewState extends State<_KakaoMapWebView> {
  StreamSubscription<html.MessageEvent>? _msgSub;

  @override
  void initState() {
    super.initState();
    _msgSub = html.window.onMessage.listen((event) {
      if (widget.onMarkerTap == null) return;
      try {
        final raw = event.data;
        final Map<String, dynamic> decoded = raw is String
            ? jsonDecode(raw) as Map<String, dynamic>
            : Map<String, dynamic>.from(raw as Map);
        if (decoded['type'] == 'oomu_marker_click') {
          final id = (decoded['id'] ?? '').toString();
          final action = (decoded['action'] ?? 'select').toString();
          if (id.isNotEmpty) {
            widget.onMarkerTap!(id, action == 'open');
          }
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cleanName =
        widget.locationName.replaceAll(RegExp(r'[^a-zA-Z0-9가-힣]'), '');
    final actionSuffix = widget.hideActions ? '-clean' : '';
    final markersCount = widget.markers?.length ?? 0;
    final selId = (widget.selectedMarkerId ?? '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    final viewType =
        'kakao-map-${widget.lat.toStringAsFixed(4)}-${widget.lng.toStringAsFixed(4)}-$cleanName$actionSuffix-m$markersCount-s$selId-z${widget.zoomLevel}';

    String markersQuery = '';
    if (widget.markers != null && widget.markers!.isNotEmpty) {
      try {
        final jsonStr = jsonEncode(widget.markers!
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

    final selectedQuery = (widget.selectedMarkerId != null &&
            widget.selectedMarkerId!.isNotEmpty)
        ? '&selectedId=${Uri.encodeComponent(widget.selectedMarkerId!)}'
        : '';

    try {
      ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
        final iframe = html.IFrameElement()
          ..src =
              'kakao_map.html?lat=${widget.lat}&lng=${widget.lng}&level=${widget.zoomLevel}&name=${Uri.encodeComponent(widget.locationName)}${widget.hideActions ? '&hideActions=true' : ''}$selectedQuery$markersQuery'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.borderRadius = '16px';
        return iframe;
      });
    } catch (_) {}

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: HtmlElementView(viewType: viewType),
      ),
    );
  }
}
