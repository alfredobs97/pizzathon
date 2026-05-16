import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/pizza_model.dart';

class AdminSelectionService {
  final FirebaseFirestore _firestore;

  AdminSelectionService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _getSelectionsCollection(String adminId) {
    return _firestore
        .collection('admin_selections_2026_05')
        .doc(adminId)
        .collection('selected_pizzas');
  }

  Future<List<PizzaModel>> getSelectedPizzas(String adminId) async {
    final snapshot = await _getSelectionsCollection(adminId).get();
    return snapshot.docs
        .map((doc) => PizzaModel.fromDocument(doc))
        .toList();
  }

  Future<void> togglePizzaSelection(String adminId, PizzaModel pizza, bool isSelected) async {
    final collection = _getSelectionsCollection(adminId);
    final docRef = collection.doc(pizza.id);

    if (isSelected) {
      await docRef.set(pizza.toJson());
    } else {
      await docRef.delete();
    }
  }

  Future<void> clearSelection(String adminId) async {
    final collection = _getSelectionsCollection(adminId);
    final snapshot = await collection.get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
