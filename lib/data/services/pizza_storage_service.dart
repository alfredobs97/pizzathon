import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../ui/blocs/poc_images/poc_images_state.dart';

class PizzaStorageService {
  final FirebaseStorage _storage;
  final FirebaseFirestore _firestore;

  PizzaStorageService({
    FirebaseStorage? storage,
    FirebaseFirestore? firestore,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _pizzaCollectionName = 'pizzas_2026_05';

  /// Uploads 4 pizza images in parallel and saves the metadata to Firestore.
  Future<Map<PizzaPhotoStep, String>> uploadPizzaParticipation({
    required String userId,
    required Map<PizzaPhotoStep, Uint8List> images,
    required Map<String, dynamic> pizzaData,
  }) async {
    final Map<PizzaPhotoStep, String> imageUrls = {};

    // 1. Get the current count of pizzas for this user to determine the folder name
    final querySnapshot = await _firestore
        .collection(_pizzaCollectionName)
        .where('userId', isEqualTo: userId)
        .count()
        .get();
    
    final pizzaNumber = querySnapshot.count! + 1;

    // 2. Prepare upload tasks for parallel execution
    final uploadTasks = images.entries.map((entry) async {
      final step = entry.key;
      final bytes = entry.value;
      
      // New clean path: pizzas/userId/pizzaNumber/step.jpg
      final path = 'pizzas/$userId/$pizzaNumber/${step.name}.jpg';

      final ref = _storage.ref().child(path);

      // Upload with metadata
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
      return MapEntry(step, downloadUrl);
    });

    // 3. Execute all uploads in parallel
    final results = await Future.wait(uploadTasks);
    for (final entry in results) {
      imageUrls[entry.key] = entry.value;
    }

    // 4. Save to Firestore
    await _firestore.collection(_pizzaCollectionName).add({
      ...pizzaData,
      'userId': userId,
      'pizzaNumber': pizzaNumber,
      'imageUrls': imageUrls.values.toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return imageUrls;
  }
}
