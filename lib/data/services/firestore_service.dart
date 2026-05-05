import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pizzathon/domain/models/user_extension.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/pizza_model.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

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

  Future<void> banUser(String uid) async {
    await _db.collection(_userCollectionName).doc(uid).update({'banned': true});
  }

  Future<int> countPizzasToday({
    required String uid,
    required DateTime startOfDay,
    required DateTime endOfDay,
  }) async {
    final query = _db
        .collection(_pizzaCollectionName)
        .where('userId', isEqualTo: uid)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));

    final snapshot = await query.get();
    return snapshot.docs.length;
  }

  Future<({List<UserModel> users, DocumentSnapshot? lastDocument})>
  getUsersPaginated({DocumentSnapshot? lastDocument, int limit = 10}) async {
    Query query = _db
        .collection(_userCollectionName)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();

    final users = snapshot.docs
        .map((doc) => UserModel.fromDocument(doc))
        .toList();

    return (
      users: users,
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
    );
  }

  Future<({List<PizzaModel> pizzas, DocumentSnapshot? lastDocument})>
  getPizzasFromUserPaginated({
    required String uid,
    DocumentSnapshot? lastDocument,
    int limit = 5,
  }) async {
    Query query = _db
        .collection(_pizzaCollectionName)
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();

    final pizzas = snapshot.docs
        .map((doc) => PizzaModel.fromDocument(doc))
        .toList();

    return (
      pizzas: pizzas,
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
    );
  }
}
