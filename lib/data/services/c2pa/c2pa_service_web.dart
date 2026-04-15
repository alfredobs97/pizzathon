import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';

@JS('readC2paFromBytes')
external JSPromise<JSString?> _readC2paFromBytes(JSUint8Array bytes, [JSString? mimeType]);

/// Web implementation of C2PA analysis using package:web and dart:js_interop.
Future<Map<String, dynamic>?> analyzeC2paImpl(Uint8List bytes, [String? mimeType]) async {
  try {
    // 1. Convert Dart Uint8List to JS Uint8Array
    final jsBytes = bytes.toJS;
    final jsMimeType = mimeType?.toJS;

    // 2. Call the external JS function and await the promise
    final jsString = await _readC2paFromBytes(jsBytes, jsMimeType).toDart;

    // 3. Return early if no C2PA data was found
    if (jsString == null) {
      return null;
    }

    // 4. Decode the JSON string back into a Dart Map
    final dartString = jsString.toDart;
    final decoded = jsonDecode(dartString) as Map<String, dynamic>;

    return decoded;
  } catch (e) {
    // Handle failures gracefully
    // e.g. WASM initialization failure or no metadata parseable
    debugPrint('Failed to analyze C2PA in Dart: \$e');
    return null;
  }
}
