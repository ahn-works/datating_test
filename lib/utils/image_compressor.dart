import 'dart:typed_data';
import 'image_compressor_stub.dart'
    if (dart.library.html) 'image_compressor_web.dart' as impl;

Future<String> compressDataUrlForFirestore(
  String dataUrl, {
  int maxDimension = 520,
  double quality = 0.72,
  int maxChars = 95000,
}) =>
    impl.compressDataUrlForFirestore(
      dataUrl,
      maxDimension: maxDimension,
      quality: quality,
      maxChars: maxChars,
    );

Future<String> compressBytesToDataUrl(
  Uint8List bytes,
  String mimeType, {
  int maxDimension = 520,
  double quality = 0.72,
  int maxChars = 95000,
}) =>
    impl.compressBytesToDataUrl(
      bytes,
      mimeType,
      maxDimension: maxDimension,
      quality: quality,
      maxChars: maxChars,
    );
