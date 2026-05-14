import 'package:image_picker/image_picker.dart';
import 'package:heic_to_png_jpg/heic_to_png_jpg.dart';
import 'package:flutter/foundation.dart';

class HeicConversionService {
  Future<XFile?> convertIfNeeded(XFile file) async {
    final name = file.name.toLowerCase();
    if (name.endsWith('.heic') || name.endsWith('.heif')) {
      try {
        final Uint8List heicBytes = await file.readAsBytes();
        
        final Uint8List pngBytes = await HeicConverter.convertToPNG(
          heicData: heicBytes,
        );

        return XFile.fromData(
          pngBytes,
          name: '${file.name}.png',
          mimeType: 'image/png',
        );
      } catch (e) {
        debugPrint('Error converting HEIC to PNG: $e');
        // Lanzamos el error para que el Cubit lo capture y lo muestre
        throw Exception('Error al procesar formato HEIC: $e');
      }
    }
    return file;
  }
}
