import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/firestore_service.dart';
import '../../../domain/models/pizza_model.dart';
import 'admin_pizzas_state.dart';

class AdminPizzasCubit extends Cubit<AdminPizzasState> {
  final FirestoreService _firestoreService;
  static const int _maxItemPerPage = 10;

  AdminPizzasCubit(this._firestoreService) : super(const AdminPizzasState());

  void refreshAll() {
    for (final status in PizzaStatus.values) {
      fetchPizzas(status);
    }
  }

  Future<void> fetchPizzas(PizzaStatus status, {bool isLoadMore = false}) async {
    final currentList = state.getForStatus(status);
    if (isLoadMore && (currentList.isLoading || currentList.hasReachedMax)) return;

    _updateList(
      status,
      (l) => l.copyWith(isLoading: true, errorMessage: isLoadMore ? null : l.errorMessage),
    );

    try {
      final result = await _firestoreService.getPizzasByStatusPaginated(
        status: status,
        lastDocument: isLoadMore ? currentList.lastDocument : null,
        limit: _maxItemPerPage,
      );

      _updateList(
        status,
        (l) => l.copyWith(
          pizzas: isLoadMore ? [...l.pizzas, ...result.pizzas] : result.pizzas,
          lastDocument: result.lastDocument,
          hasReachedMax: result.pizzas.length < _maxItemPerPage,
          isLoading: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      debugPrint('Error fetching $status pizzas: $e');
      _updateList(
        status,
        (l) => l.copyWith(isLoading: false, errorMessage: isLoadMore ? null : e.toString()),
      );
    }
  }

  void _updateList(
    PizzaStatus status,
    PizzaListStatusState Function(PizzaListStatusState) updater,
  ) {
    emit(switch (status) {
      PizzaStatus.pending => state.copyWith(pending: updater(state.pending)),
      PizzaStatus.approved => state.copyWith(approved: updater(state.approved)),
      PizzaStatus.rejected => state.copyWith(rejected: updater(state.rejected)),
    });
  }
}
