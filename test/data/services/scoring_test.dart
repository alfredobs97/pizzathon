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

    test('Re-approving with same score should NOT increment again', () async {
      // First approval
      await firestoreService.reviewPizza(
        pizzaId: pizzaId,
        userId: userId,
        status: PizzaStatus.approved,
        score: 30,
      );

      // Second approval
      await firestoreService.reviewPizza(
        pizzaId: pizzaId,
        userId: userId,
        status: PizzaStatus.approved,
        score: 30,
      );

      final userDoc = await fakeFirestore.collection(userCollectionName).doc(userId).get();
      // EXPECTED: 30, CURRENT: 60 (IF BUGGY)
      expect(userDoc.data()?['score'], 30, reason: 'Score should not be added twice');
    });

    test('Changing score should update user total score correctly', () async {
      // First approval with 30
      await firestoreService.reviewPizza(
        pizzaId: pizzaId,
        userId: userId,
        status: PizzaStatus.approved,
        score: 30,
      );

      // Change to 10
      await firestoreService.reviewPizza(
        pizzaId: pizzaId,
        userId: userId,
        status: PizzaStatus.approved,
        score: 10,
      );

      final userDoc = await fakeFirestore.collection(userCollectionName).doc(userId).get();
      // EXPECTED: 10, CURRENT: 40 (IF BUGGY)
      expect(userDoc.data()?['score'], 10, reason: 'Score should be updated, not just added');
    });

    test('Rejecting an approved pizza should subtract score', () async {
      // First approval with 30
      await firestoreService.reviewPizza(
        pizzaId: pizzaId,
        userId: userId,
        status: PizzaStatus.approved,
        score: 30,
      );

      // Change to rejected
      await firestoreService.reviewPizza(
        pizzaId: pizzaId,
        userId: userId,
        status: PizzaStatus.rejected,
        score: 0,
      );

      final userDoc = await fakeFirestore.collection(userCollectionName).doc(userId).get();
      // EXPECTED: 0, CURRENT: 30 (IF BUGGY)
      expect(userDoc.data()?['score'], 0, reason: 'Score should be removed if rejected');
    });
  });
}
