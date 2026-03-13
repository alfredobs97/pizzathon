import 'dart:js_interop';
import 'dart:typed_data';
import 'moire_service.dart';

@JS('detectMoireFromBytes')
external JSPromise<JSBoolean> _detectMoireFromBytes(JSUint8Array bytes, [JSNumber? threshold]);

class WebMoireService implements MoireService {
  @override
  Future<bool> detectMoireFromBytes(Uint8List bytes, {double threshold = 20.0}) async {
    try {
      final jsBytes = bytes.toJS;
      final jsThreshold = threshold.toJS;
      final result = await _detectMoireFromBytes(jsBytes, jsThreshold).toDart;
      return result.toDart;
    } catch (e) {
      // Web Moire detection error
      return false;
    }
  }
}

MoireService getMoireService() => WebMoireService();
