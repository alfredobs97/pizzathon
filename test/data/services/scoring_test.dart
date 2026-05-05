import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizzathon/data/services/firestore_service.dart';
import 'package:pizzathon/domain/models/pizza_model.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreService firestoreService;

  const String userCollectionName = 'users_2026_05';
  const String pizzaCollectionName = 'pizzas_2026_05';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    firestoreService = FirestoreService(firestore: fakeFirestore);
  });

  group('Scoring Logic Verification', () {
    const userId = 'user123';
    const pizzaId = 'pizza456';

    setUp(() async {
      // Create user
      await fakeFirestore.collection(userCollectionName).doc(userId).set({
        'displayName': 'Test User',
        'score': 0,
      });

      // Create pizza
      await fakeFirestore.collection(pizzaCollectionName).doc(pizzaId).set({
        'userId': userId,
        'status': PizzaStatus.pending.name,
        'score': 0,
      });
    });

    test('Initial approval should add score', () async {
      await firestoreService.reviewPizza(
        pizzaId: pizzaId,
        userId: userId,
        status: PizzaStatus.approved,
        score: 30,
      );

      final userDoc = await fakeFirestore.collection(userCollectionName).doc(userId).get();
      expect(userDoc.data()?['score'], 30);

      final pizzaDoc = await fakeFirestore.collection(pizzaCollectionName).doc(pizzaId).get();
      expect(pizzaDoc.data()?['score'], 30);
      expect(pizzaDoc.data()?['status'], PizzaStatus.approved.name);
    });
  });
}
