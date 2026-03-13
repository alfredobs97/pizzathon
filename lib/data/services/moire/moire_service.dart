import 'dart:typed_data';
import 'moire_service_stub.dart'
    if (dart.library.js_interop) 'moire_service_web.dart'
    if (dart.library.io) 'moire_service_native.dart';

abstract class MoireService {
  factory MoireService() => getMoireService();

  Future<bool> detectMoireFromBytes(Uint8List bytes, {double threshold = 100.0});
}
