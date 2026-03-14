import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class HuggingFaceSpoofService {
  static const String _baseUrl = 'https://cvdetectors-liveness-detector.hf.space';

  Future<bool> detectSpoofFromBytes(Uint8List bytes, {required double threshold}) async {
    try {
      // 1. Upload the image to HF space to get a temporary path
      final uploadRes = await _uploadToHuggingFace(bytes);

      print('Upload result: $uploadRes');
      if (uploadRes == null) return false;

      // 2. Start the prediction
      final eventId = await _startPrediction(uploadRes);
      print('Event ID: $eventId');
      if (eventId == null) return false;

      // 3. Fetch the results (streaming)
      final result = await _fetchResult(eventId);
      print('Result: $result');
      // The result looks like: "Liveness: live (Confidence: 0.9459)"
      if (result != null) {
        // Regex to extract status (live/spoof) and confidence
        final regExp = RegExp(r'Liveness:\s+(\w+)\s+\(Confidence:\s+([0-9.]+)\)');
        final match = regExp.firstMatch(result);

        if (match != null) {
          final status = match.group(1)?.toLowerCase();
          final confidence = double.tryParse(match.group(2) ?? '0') ?? 0.0;

          print('Interpreted Status: $status, Confidence: $confidence (Threshold: $threshold)');

          if (confidence < threshold) {
            print('Confidence below threshold, ignoring result.');
            return false;
          }

          // If it says "spoof" and confidence is high enough, it's moire/screen
          return status == 'spoof';
        }

        // Fallback to simple string check if regex fails
        final lowerResult = result.toLowerCase();
        return (lowerResult.contains('spoof') || lowerResult.contains('moire')) &&
            !lowerResult.contains('live');
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> _uploadToHuggingFace(Uint8List bytes) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/gradio_api/upload'));
      request.files.add(http.MultipartFile.fromBytes('files', bytes, filename: 'image.jpg'));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final List<dynamic> paths = jsonDecode(body);
        if (paths.isNotEmpty) {
          return paths.first.toString();
        }
      } else {
        print('Upload failed with status: ${response.statusCode}');
        print('Error body: $body');
      }
    } catch (e) {
      print('Exception during upload: $e');
    }
    return null;
  }

  Future<String?> _startPrediction(String filePath) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/gradio_api/call/predict'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "data": [
          {
            "path": filePath,
            "meta": {"_type": "gradio.FileData"},
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['event_id'];
    }
    return null;
  }

  Future<String?> _fetchResult(String eventId) async {
    // We'll use a standard GET for the stream, but we'll stop at the first 'complete' event
    final response = await http.get(Uri.parse('$_baseUrl/gradio_api/call/predict/$eventId'));

    if (response.statusCode == 200) {
      final lines = response.body.split('\n');
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].startsWith('event: complete') && i + 1 < lines.length) {
          final dataLine = lines[i + 1];
          if (dataLine.startsWith('data: ')) {
            final jsonStr = dataLine.substring(6);
            final List<dynamic> result = jsonDecode(jsonStr);
            if (result.isNotEmpty) {
              return result.first.toString();
            }
          }
        }
      }
    }
    return null;
  }
}
