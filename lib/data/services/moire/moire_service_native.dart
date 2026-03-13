import 'dart:typed_data';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'moire_service.dart';

class NativeMoireService implements MoireService {
  @override
  Future<bool> detectMoireFromBytes(Uint8List bytes, {double threshold = 100.0}) async {
    try {
      // 1. Decode image from bytes
      final mat = cv.imdecode(bytes, cv.IMREAD_GRAYSCALE);
      if (mat.isEmpty) return false;

      // 2. Laplacian
      final laplacian = cv.laplacian(mat, cv.MatType.CV_64F);

      // 3. Mean and StdDev
      final (mean, stdDev) = cv.meanStdDev(laplacian);

      // 4. Variance = stdDev^2
      // Scalar typically has v0, v1, v2, v3 or val[0]
      final variance = stdDev.val[0] * stdDev.val[0];

      // Cleanup
      mat.dispose();
      laplacian.dispose();
      mean.dispose();
      stdDev.dispose();

      return variance > threshold;
    } catch (e) {
      // Failed to detect Moire
      return false;
    }
  }
}

MoireService getMoireService() => NativeMoireService();
