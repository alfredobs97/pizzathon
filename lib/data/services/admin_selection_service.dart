import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/pizza_model.dart';

class AdminSelectionService {
  final FirebaseFirestore _firestore;

  AdminSelectionService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _getSelectionsCollection() {
    return _firestore.collection('admin_selections_2026_05');
  }

  Future<List<PizzaModel>> getSelectedPizzas() async {
    final snapshot = await _getSelectionsCollection().get();
    return snapshot.docs
        .map((doc) => PizzaModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> togglePizzaSelection(PizzaModel pizza, bool isSelected) async {
    final collection = _getSelectionsCollection();
    final docRef = collection.doc(pizza.id);

    if (isSelected) {
      await docRef.set(pizza.toJson());
    } else {
      await docRef.delete();
    }
  }

  Future<void> clearSelection() async {
    final collection = _getSelectionsCollection();
    final snapshot = await collection.get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
