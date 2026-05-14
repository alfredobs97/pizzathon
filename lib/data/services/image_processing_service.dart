import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:pizzathon/domain/models/compression_settings.dart';

class ImageProcessingService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickSingleImage() async {
    try {
      return await _picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      return null;
    }
  }

  Future<XFile?> compressImage(
    XFile originalFile,
    Uint8List originalBytes, {
    required CompressionSettings settings,
  }) async {
    try {
      final compressedBytes = await FlutterImageCompress.compressWithList(
        
        originalBytes,
        minHeight: settings.maxWidth,
        minWidth: settings.maxWidth,
        quality: settings.quality,
      );

      return XFile.fromData(
        compressedBytes,
        mimeType: originalFile.mimeType ?? 'image/jpeg',
        name: originalFile.name,
      );
    } catch (e) {
      return null;
    }
  }
}
