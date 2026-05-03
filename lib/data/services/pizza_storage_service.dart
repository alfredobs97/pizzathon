import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../../ui/blocs/poc_images/poc_images_state.dart';

class PizzaStorageService {
  final FirebaseStorage _storage;

  PizzaStorageService({
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance;

  static const String _storageRootPath = 'pizzas_2026_05';

  Future<Map<String, String>> uploadPizzaParticipation({
    required String userId,
    required Map<PizzaPhotoStep, Uint8List> images,
    required int pizzaNumber,
  }) async {
    final Map<String, String> imageUrls = {};

    final uploadTasks = images.entries.map((entry) async {
      final step = entry.key;
      final bytes = entry.value;

      final path = '$_storageRootPath/$userId/$pizzaNumber/${step.name}.jpg';

      final ref = _storage.ref().child(path);

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'step': step.name,
          'pizzaNumber': pizzaNumber.toString(),
        },
      );

      final uploadTask = await ref.putData(bytes, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return MapEntry(step.name, downloadUrl);
    });

    final results = await Future.wait(uploadTasks);
    for (final entry in results) {
      imageUrls[entry.key] = entry.value;
    }

    return imageUrls;
  }
}
