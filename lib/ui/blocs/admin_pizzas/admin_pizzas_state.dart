import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/models/pizza_model.dart';

class PizzaListStatusState extends Equatable {
  final List<PizzaModel> pizzas;
  final DocumentSnapshot? lastDocument;
  final bool hasReachedMax;
  final bool isLoading;
  final String? errorMessage;

  const PizzaListStatusState({
    this.pizzas = const [],
    this.lastDocument,
    this.hasReachedMax = false,
    this.isLoading = false,
    this.errorMessage,
  });

  PizzaListStatusState copyWith({
    List<PizzaModel>? pizzas,
    DocumentSnapshot? lastDocument,
    bool? hasReachedMax,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PizzaListStatusState(
      pizzas: pizzas ?? this.pizzas,
      lastDocument: lastDocument ?? this.lastDocument,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [pizzas, lastDocument, hasReachedMax, isLoading, errorMessage];
}

class AdminPizzasState extends Equatable {
  final PizzaListStatusState pending;
  final PizzaListStatusState approved;
  final PizzaListStatusState rejected;

  const AdminPizzasState({
    this.pending = const PizzaListStatusState(),
    this.approved = const PizzaListStatusState(),
    this.rejected = const PizzaListStatusState(),
  });

  AdminPizzasState copyWith({
    PizzaListStatusState? pending,
    PizzaListStatusState? approved,
    PizzaListStatusState? rejected,
  }) {
    return AdminPizzasState(
      pending: pending ?? this.pending,
      approved: approved ?? this.approved,
      rejected: rejected ?? this.rejected,
    );
  }

  PizzaListStatusState getForStatus(PizzaStatus status) {
    return switch (status) {
      PizzaStatus.pending => pending,
      PizzaStatus.approved => approved,
      PizzaStatus.rejected => rejected,
    };
  }

  @override
  List<Object?> get props => [pending, approved, rejected];
}
