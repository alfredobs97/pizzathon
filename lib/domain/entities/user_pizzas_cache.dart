import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pizza_model.dart';

class UserPizzasCache {
  final List<PizzaModel> pizzas;
  final DocumentSnapshot? lastDocument;
  final DateTime lastUpdated;
  final bool hasReachedMax;

  static const int cacheDurationMinutes = 20;

  UserPizzasCache({
    required this.pizzas,
    this.lastDocument,
    required this.lastUpdated,
    required this.hasReachedMax,
  });

  bool get isExpired {
    final now = DateTime.now();
    return now.difference(lastUpdated).inMinutes >= cacheDurationMinutes;
  }
}
