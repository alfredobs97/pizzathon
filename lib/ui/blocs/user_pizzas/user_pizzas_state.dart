import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/models/pizza_model.dart';

sealed class UserPizzasState extends Equatable {
  const UserPizzasState();

  @override
  List<Object?> get props => [];
}

class UserPizzasInitial extends UserPizzasState {}

class UserPizzasLoading extends UserPizzasState {}

class UserPizzasLoaded extends UserPizzasState {
  final List<PizzaModel> pizzas;
  final DocumentSnapshot? lastDocument;
  final bool hasReachedMax;

  const UserPizzasLoaded({
    required this.pizzas,
    this.lastDocument,
    required this.hasReachedMax,
  });

  @override
  List<Object?> get props => [pizzas, lastDocument, hasReachedMax];

  UserPizzasLoaded copyWith({
    List<PizzaModel>? pizzas,
    DocumentSnapshot? lastDocument,
    bool? hasReachedMax,
  }) {
    return UserPizzasLoaded(
      pizzas: pizzas ?? this.pizzas,
      lastDocument: lastDocument ?? this.lastDocument,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class UserPizzasError extends UserPizzasState {
  final String message;

  const UserPizzasError(this.message);

  @override
  List<Object?> get props => [message];
}
