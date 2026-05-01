import 'dart:typed_data';

/// Stub implementation for non-web platforms.
Future<Map<String, dynamic>?> analyzeC2paImpl(
  Uint8List bytes, [
  String? mimeType,
]) => throw UnsupportedError('C2PA analysis is only supported on Web');
