import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/models/pizza_model.dart';

sealed class AdminPizzasListState {
  const AdminPizzasListState();
}

class AdminPizzasListLoading extends AdminPizzasListState {}

class AdminPizzasListLoaded extends AdminPizzasListState {
  final List<PizzaModel> pizzas;
  final DocumentSnapshot? lastDocument;
  final bool hasReachedMax;

  const AdminPizzasListLoaded({
    required this.pizzas,
    this.lastDocument,
    required this.hasReachedMax,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminPizzasListLoaded &&
        other.pizzas == pizzas &&
        other.lastDocument == lastDocument &&
        other.hasReachedMax == hasReachedMax;
  }

  @override
  int get hashCode => Object.hash(pizzas, lastDocument, hasReachedMax);
}

class AdminPizzasListError extends AdminPizzasListState {
  final String message;

  const AdminPizzasListError(this.message);
}
