import 'dart:typed_data'; 
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageProcessingService {
  final ImagePicker _picker = ImagePicker();

  Future<List<Uint8List>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();

      if (images.isNotEmpty) {
        List<Uint8List> bytesList = [];
        for (var image in images) {
          final bytes = await image.readAsBytes();
          bytesList.add(bytes);
        }
        return bytesList;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Uint8List?> compressImage(Uint8List imageBytes) async {
    try {
      final Uint8List result = await FlutterImageCompress.compressWithList(
        imageBytes,
        minHeight: 1440,
        minWidth: 1440,
        quality: 80, 
        format: CompressFormat.jpeg,
      );

      return result;
    } catch (e) {
      return null;
    }
  }
}
