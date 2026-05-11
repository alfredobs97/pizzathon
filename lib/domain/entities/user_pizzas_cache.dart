import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pizza_model.dart';

class UserPizzasCache {
  final String userId;
  final List<PizzaModel> pizzas;
  final DocumentSnapshot? lastDocument;
  final DateTime lastUpdated;
  final bool hasReachedMax;

  UserPizzasCache({
    required this.userId,
    required this.pizzas,
    this.lastDocument,
    required this.lastUpdated,
    required this.hasReachedMax,
  });

  bool isExpired(Duration duration) {
    final now = DateTime.now();
    return now.difference(lastUpdated) >= duration;
  }
}
