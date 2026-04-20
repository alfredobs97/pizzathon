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

  Future<Uint8List?> compressImage(Uint8List imageBytes, {required CompressionSettings settings}) async {
    try {
      return await FlutterImageCompress.compressWithList(
        imageBytes,
        minHeight: settings.maxWidth,
        minWidth: settings.maxWidth,
        quality: settings.quality,
        format: CompressFormat.jpeg,
      );
    } catch (e) {
      return null;
    }
  }
}