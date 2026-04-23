import 'dart:typed_data';

import 'c2pa_service_stub.dart'
    if (dart.library.js_interop) 'c2pa_service_web.dart';

/// Analyzes an image for C2PA content credentials.
///
/// Returns a [Map] containing the JSON representation of the C2PA manifest,
/// or `null` if the image has no credentials, the operation fails, or
/// the current platform is not supported.
Future<Map<String, dynamic>?> analyzeC2pa(
  Uint8List bytes, [
  String? mimeType,
]) async {
  return analyzeC2paImpl(bytes, mimeType);
}
