import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/firestore_service.dart';
import '../../../domain/models/pizza_model.dart';
import 'admin_pizzas_state.dart';

class AdminPizzasListCubit extends Cubit<AdminPizzasListState> {
  final FirestoreService _firestoreService;
  final PizzaStatus _status;
  static const int _maxItemPerPage = 10;

  AdminPizzasListCubit(this._firestoreService, this._status) : super(AdminPizzasListLoading()) {
    loadInitialPizzas();
  }

  Future<void> loadInitialPizzas() async {
    emit(AdminPizzasListLoading());
    try {
      final result = await _firestoreService.getPizzasByStatusPaginated(
        status: _status,
        limit: _maxItemPerPage,
      );

      emit(
        AdminPizzasListLoaded(
          pizzas: result.pizzas,
          lastDocument: result.lastDocument,
          hasReachedMax: result.pizzas.length < _maxItemPerPage,
        ),
      );
    } catch (e) {
      emit(AdminPizzasListError(e.toString()));
    }
  }

  Future<void> loadMorePizzas() async {
    final currentState = state;
    if (currentState is! AdminPizzasListLoaded || currentState.hasReachedMax) return;

    try {
      final result = await _firestoreService.getPizzasByStatusPaginated(
        status: _status,
        lastDocument: currentState.lastDocument,
        limit: _maxItemPerPage,
      );

      emit(
        AdminPizzasListLoaded(
          pizzas: [...currentState.pizzas, ...result.pizzas],
          lastDocument: result.lastDocument,
          hasReachedMax: result.pizzas.length < _maxItemPerPage,
        ),
      );
    } catch (e) {
      debugPrint('Error loading more pizzas: $e');
      emit(AdminPizzasListError(e.toString()));
    }
  }
}
