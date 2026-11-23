import 'dart:convert';
import 'dart:typed_data';

Future<String> compressDataUrlForFirestore(
  String dataUrl, {
  int maxDimension = 520,
  double quality = 0.72,
  int maxChars = 95000,
}) async {
  return dataUrl;
}

Future<String> compressBytesToDataUrl(
  Uint8List bytes,
  String mimeType, {
  int maxDimension = 520,
  double quality = 0.72,
  int maxChars = 95000,
}) async {
  final b64 = base64Encode(bytes);
  return 'data:$mimeType;base64,$b64';
}
