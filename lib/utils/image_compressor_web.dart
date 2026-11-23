// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:typed_data';

Future<String> compressBytesToDataUrl(
  Uint8List bytes,
  String mimeType, {
  int maxDimension = 520,
  double quality = 0.72,
  int maxChars = 95000,
}) async {
  String? blobUrl;
  try {
    final blob = html.Blob([bytes], mimeType);
    blobUrl = html.Url.createObjectUrlFromBlob(blob);
    final compressed = await _decodeAndCompressUrl(
      blobUrl,
      maxDimension: maxDimension,
      quality: quality,
      maxChars: maxChars,
    );
    if (compressed != null && compressed.isNotEmpty) {
      return compressed;
    }
  } catch (_) {
  } finally {
    if (blobUrl != null) {
      try {
        html.Url.revokeObjectUrl(blobUrl);
      } catch (_) {}
    }
  }
  final rawDataUrl = 'data:$mimeType;base64,${base64Encode(bytes)}';
  return compressDataUrlForFirestore(
    rawDataUrl,
    maxDimension: maxDimension,
    quality: quality,
    maxChars: maxChars,
  );
}

Future<String> compressDataUrlForFirestore(
  String dataUrl, {
  int maxDimension = 520,
  double quality = 0.72,
  int maxChars = 95000,
}) async {
  if (!dataUrl.startsWith('data:image')) {
    return dataUrl;
  }
  final compressed = await _decodeAndCompressUrl(
    dataUrl,
    maxDimension: maxDimension,
    quality: quality,
    maxChars: maxChars,
  );
  if (compressed != null && compressed.isNotEmpty) {
    return compressed;
  }
  // 이미지 디코딩 실패 시에도 Firestore 1MB 한도 초과를 일으키지 않도록 안전 크기 검증
  if (dataUrl.length > 220000) {
    return 'assets/images/민지.png';
  }
  return dataUrl;
}

Future<String?> _decodeAndCompressUrl(
  String srcUrl, {
  required int maxDimension,
  required double quality,
  required int maxChars,
}) async {
  try {
    final completer = Completer<html.ImageElement>();
    final img = html.ImageElement();
    img.onLoad.first.then((_) {
      if (!completer.isCompleted) completer.complete(img);
    });
    img.onError.first.then((_) {
      if (!completer.isCompleted) {
        completer.completeError(StateError('Image decode failed'));
      }
    });
    img.src = srcUrl;

    final loaded = await completer.future.timeout(const Duration(seconds: 4));
    final origW = loaded.naturalWidth > 0 ? loaded.naturalWidth : 520;
    final origH = loaded.naturalHeight > 0 ? loaded.naturalHeight : 520;

    String encodeAt(int targetMax, double q) {
      final scale = math.min(1.0, targetMax / math.max(origW, origH));
      final w = math.max(1, (origW * scale).round());
      final h = math.max(1, (origH * scale).round());
      final canvas = html.CanvasElement(width: w, height: h);
      final ctx = canvas.context2D;
      ctx.fillStyle = '#FFFFFF';
      ctx.fillRect(0, 0, w, h);
      ctx.drawImageScaled(loaded, 0, 0, w, h);
      return canvas.toDataUrl('image/jpeg', q);
    }

    var compressed = encodeAt(maxDimension, quality);
    if (compressed.length > maxChars) {
      compressed = encodeAt(380, 0.60);
    }
    if (compressed.length > maxChars) {
      compressed = encodeAt(280, 0.50);
    }
    return compressed;
  } catch (_) {
    return null;
  }
}
