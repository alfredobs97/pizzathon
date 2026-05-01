import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pizzathon/domain/entities/pizza_image_metadata.dart';
import 'package:png_chunks_extract/png_chunks_extract.dart' as png_extract;
import 'c2pa/c2pa_service.dart';

class ImageMetadataService {
  Future<PizzaImageMetadata> extractMetadata(XFile file) async {
    Map<String, dynamic>? c2paData;
    try {
      final fileBytes = await file.readAsBytes();

      c2paData = await analyzeC2pa(fileBytes, file.mimeType);

      final exifData = await readExifFromBytes(fileBytes);
      final pngTextData = _extractPngText(fileBytes);

      if (exifData.isEmpty && pngTextData == null) {
        return EmptyImageMetadata(c2paData: c2paData, bytes: fileBytes);
      }

      final creationDate = _parseCreationDate(exifData);
      final make = exifData['Image Make']?.printable;
      final model = exifData['Image Model']?.printable;

      final software = _combineSoftware(
        exifData['Image Software']?.printable,
        pngTextData,
      );

      return DetailedImageMetadata(
        creationDate: creationDate,
        make: make,
        model: model,
        software: software,
        hasExif: exifData.isNotEmpty,
        c2paData: c2paData,
        bytes: fileBytes,
      );
    } catch (e) {
      debugPrint('Error extracting metadata: $e');
      return EmptyImageMetadata(c2paData: c2paData);
    }
  }

  String? _extractPngText(Uint8List fileBytes) {
    if (fileBytes.length < 8 ||
        fileBytes[0] != 0x89 ||
        fileBytes[1] != 0x50 ||
        fileBytes[2] != 0x4E ||
        fileBytes[3] != 0x47) {
      return null;
    }

    try {
      final chunks = png_extract.extractChunks(fileBytes);
      final textChunks = chunks.where(
        (c) =>
            c['name'] == 'tEXt' || c['name'] == 'zTXt' || c['name'] == 'iTXt',
      );

      if (textChunks.isEmpty) return null;

      return textChunks
          .map((c) {
            final bytes = c['data'] as Uint8List;
            return String.fromCharCodes(bytes.where((b) => b >= 32 && b < 127));
          })
          .join(' ');
    } catch (e) {
      debugPrint('Error parsing PNG chunks: $e');
      return null;
    }
  }

  DateTime? _parseCreationDate(Map<String, dynamic> exifData) {
    final dateString = exifData['Image DateTime']?.printable;
    if (dateString == null) return null;

    try {
      final formattedString = dateString
          .replaceFirst(':', '-')
          .replaceFirst(':', '-');
      return DateTime.parse(formattedString);
    } catch (e) {
      debugPrint('Error parsing Date: $e');
      return null;
    }
  }

  String? _combineSoftware(String? exifSoftware, String? pngTextData) {
    if (exifSoftware == null) return pngTextData;
    if (pngTextData == null) return exifSoftware;
    return '$exifSoftware $pngTextData';
  }
}
