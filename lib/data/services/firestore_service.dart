import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pizzathon/domain/models/user_extension.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/pizza_model.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  static const String _userCollectionName = 'users_2026_05';
  static const String _pizzaCollectionName = 'pizzas_2026_05';

  Future<void> saveUser(User user) async {
    final userRef = _db.collection(_userCollectionName).doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      await userRef.set({
        'displayName': user.nameToSave,
        'email': user.email,
        'photoUrl': user.photoURL,
        'score': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  String generatePizzaId() => _db.collection(_pizzaCollectionName).doc().id;

  Future<void> savePizzaParticipation({
    required String userId,
    required String pizzaId,
    required Map<String, dynamic> pizzaData,
    required Map<String, String> imageUrls,
  }) async {
    await _db.collection(_pizzaCollectionName).doc(pizzaId).set({
      ...pizzaData,
      'userId': userId,
      'pizzaId': pizzaId,
      'imageUrls': imageUrls,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> isUserEnrolled(String uid) async {
    final doc = await _db.collection(_userCollectionName).doc(uid).get();
    return doc.exists;
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection(_userCollectionName).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromDocument(doc);
  }

  Future<void> banUser(String uid) async {
    await _db.collection(_userCollectionName).doc(uid).update({'banned': true});
  }

  Future<({List<UserModel> users, DocumentSnapshot? lastDocument})> getUsersPaginated({
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    Query query = _db
        .collection(_userCollectionName)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();

    final users = snapshot.docs.map((doc) => UserModel.fromDocument(doc)).toList();

    return (users: users, lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null);
  }

  Future<({List<PizzaModel> pizzas, DocumentSnapshot? lastDocument})> getPizzasFromUserPaginated({
    required String uid,
    DocumentSnapshot? lastDocument,
    DateTime? beforeDate,
    PizzaStatus? status,
    int limit = 5,
  }) async {
    Query query = _db.collection(_pizzaCollectionName).where('userId', isEqualTo: uid);

    if (beforeDate != null) {
      query = query.where('createdAt', isLessThan: beforeDate);
    }

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    query = query.orderBy('createdAt', descending: true).limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();

    final pizzas = snapshot.docs.map((doc) => PizzaModel.fromDocument(doc)).toList();

    return (pizzas: pizzas, lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null);
  }

  Future<({List<PizzaModel> pizzas, DocumentSnapshot? lastDocument})> getPizzasByStatusPaginated({
    required PizzaStatus status,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    Query query = _db
        .collection(_pizzaCollectionName)
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: false)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();

    final pizzas = snapshot.docs.map((doc) => PizzaModel.fromDocument(doc)).toList();

    return (pizzas: pizzas, lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null);
  }

  Future<void> reviewPizza({
    required String pizzaId,
    required String userId,
    required PizzaStatus status,
    int? score,
    String? comment,
  }) async {
    final pizzaRef = _db.collection(_pizzaCollectionName).doc(pizzaId);
    final userRef = _db.collection(_userCollectionName).doc(userId);

    await _db.runTransaction((transaction) async {
      transaction.update(pizzaRef, {
        'status': status.name,
        'score': score,
        'adminComment': comment,
        'reviewedAt': FieldValue.serverTimestamp(),
      });

      if (status == PizzaStatus.approved && score != null && score > 0) {
        transaction.update(userRef, {'score': FieldValue.increment(score)});
      }
    });
  }

  Future<int> getPizzaCountByStyle(PizzaStyle style) async {
    final snapshot = await _db
        .collection(_pizzaCollectionName)
        .where('pizzaStyle', isEqualTo: style.name)
        .where('status', isEqualTo: PizzaStatus.approved.name)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<int> getUserPizzaCount(String uid) async {
    final snapshot = await _db
        .collection(_pizzaCollectionName)
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: PizzaStatus.approved.name)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<UserModel?> getUserByShortId(String shortId) async {
    final query = await _db
        .collection(_userCollectionName)
        .where('shortId', isEqualTo: shortId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return UserModel.fromDocument(query.docs.first);
  }

  Future<String> generateAndSaveShortId(String uid) async {
    final userRef = _db.collection(_userCollectionName).doc(uid);

    String shortId = '';
    bool exists = true;

    while (exists) {
      shortId = _generateRandomString(6);
      final query = await _db
          .collection(_userCollectionName)
          .where('shortId', isEqualTo: shortId)
          .limit(1)
          .get();
      exists = query.docs.isNotEmpty;
    }

    await userRef.update({'shortId': shortId});
    return shortId;
  }

  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
}
