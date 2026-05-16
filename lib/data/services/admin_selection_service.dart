import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/pizza_model.dart';
import 'cache_service.dart';

class AdminSelectionService {
  final FirebaseFirestore _firestore;
  final CacheService _cacheService;

  AdminSelectionService({
    FirebaseFirestore? firestore,
    required CacheService cacheService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _cacheService = cacheService;

  CollectionReference _getSelectionsCollection(String adminId) {
    return _firestore
        .collection('admin_selections')
        .doc(adminId)
        .collection('selected_pizzas');
  }

  Future<List<PizzaModel>> getSelectedPizzas(String adminId) async {
    final cached = _cacheService.getAdminSelectedPizzas();
    if (cached != null) return cached;

    final snapshot = await _getSelectionsCollection(adminId).get();
    final pizzas = snapshot.docs.map((doc) => PizzaModel.fromJson(doc.data() as Map<String, dynamic>)).toList();

    _cacheService.saveAdminSelectedPizzas(pizzas);
    return pizzas;
  }

  Future<void> togglePizzaSelection(String adminId, PizzaModel pizza, bool isSelected) async {
    final collection = _getSelectionsCollection(adminId);
    final docRef = collection.doc(pizza.id);

    if (isSelected) {
      await docRef.set(pizza.toJson());
    } else {
      await docRef.delete();
    }

    // Update local cache
    final current = _cacheService.getAdminSelectedPizzas();
    if (current != null) {
      final updated = List<PizzaModel>.from(current);
      if (isSelected) {
        if (!updated.any((p) => p.id == pizza.id)) {
          updated.add(pizza);
        }
      } else {
        updated.removeWhere((p) => p.id == pizza.id);
      }
      _cacheService.saveAdminSelectedPizzas(updated);
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

    _cacheService.invalidateAdminSelectedPizzas();
  }
}
