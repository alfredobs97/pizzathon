import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizzathon/data/services/firestore_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreService firestoreService;

  const String userCollectionName = 'users_2026_05';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    firestoreService = FirestoreService(firestore: fakeFirestore);
  });

  group('FirestoreService.banUser', () {
    test('should set banned field to true for the specified user', () async {
      const uid = 'user123';

      // Create a user first
      await fakeFirestore.collection(userCollectionName).doc(uid).set({
        'displayName': 'Test User',
        'email': 'test@example.com',
        'score': 0,
        // 'banned' field is missing initially
      });

      // Call banUser
      await firestoreService.banUser(uid);

      // Verify
      final doc = await fakeFirestore
          .collection(userCollectionName)
          .doc(uid)
          .get();
      expect(doc.data()?['banned'], true);
    });

    test('should update existing banned field from false to true', () async {
      const uid = 'user456';

      // Create a user with banned: false
      await fakeFirestore.collection(userCollectionName).doc(uid).set({
        'displayName': 'Test User 2',
        'banned': false,
      });

      // Call banUser
      await firestoreService.banUser(uid);

      // Verify
      final doc = await fakeFirestore
          .collection(userCollectionName)
          .doc(uid)
          .get();
      expect(doc.data()?['banned'], true);
    });
  });
}
