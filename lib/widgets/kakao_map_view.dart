import 'package:flutter/material.dart';
import 'kakao_map_view_stub.dart'
    if (dart.library.html) 'kakao_map_view_web.dart' as impl;

class KakaoMapView extends StatelessWidget {
  final double lat;
  final double lng;
  final String locationName;
  final double height;
  final double width;

  const KakaoMapView({
    super.key,
    required this.lat,
    required this.lng,
    required this.locationName,
    this.height = 300,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return impl.buildKakaoMapWidget(
      lat: lat,
      lng: lng,
      locationName: locationName,
      height: height,
      width: width,
    );
  }
}
