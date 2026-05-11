import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/models/pizza_photo_step.dart';
import '../../domain/entities/pizza_image_link.dart';

class PizzaStorageService {
  final FirebaseStorage _storage;

  PizzaStorageService({
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance;

  static const String _storageRootPath = 'pizzas_2026_05';

  Future<List<PizzaImageLink>> uploadPizzaParticipation({
    required String userId,
    required Map<PizzaPhotoStep, XFile> images,
    required String pizzaId,
  }) async {
    final List<PizzaImageLink> imageUrls = [];

    final uploadTasks = images.entries.map((entry) async {
      final step = entry.key;
      final file = entry.value;
      final bytes = await file.readAsBytes();

      final path = '$_storageRootPath/$userId/$pizzaId/${step.name}.jpg';

      final ref = _storage.ref().child(path);

      final metadata = SettableMetadata(
        contentType: file.mimeType ?? 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'step': step.name,
          'pizzaId': pizzaId,
        },
      );

      final uploadTask = await ref.putData(bytes, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return PizzaImageLink(step: step, url: downloadUrl);
    });

    final results = await Future.wait(uploadTasks);
    imageUrls.addAll(results);

    return imageUrls;
  }
}
