import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/admin_selection_service.dart';
import '../../../domain/models/pizza_model.dart';
import 'admin_selected_pizzas_state.dart';

class AdminSelectedPizzasCubit extends Cubit<AdminSelectedPizzasState> {
  final AdminSelectionService _adminSelectionService;

  AdminSelectedPizzasCubit(this._adminSelectionService) : super(const AdminSelectedPizzasState());

  Future<void> init() async {
    if (state.isLoading) return;
    emit(state.copyWith(isLoading: true));
    try {
      final pizzas = await _adminSelectionService.getSelectedPizzas();
      emit(state.copyWith(selectedPizzas: _sortPizzas(pizzas), isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> togglePizza(PizzaModel pizza) async {
    final List<PizzaModel> current = List.from(state.selectedPizzas);
    final int index = current.indexWhere((p) => p.id == pizza.id);
    final bool isAdding = index < 0;

    if (isAdding) {
      current.add(pizza);
    } else {
      current.removeAt(index);
    }

    // Optimistic update
    emit(state.copyWith(selectedPizzas: _sortPizzas(current)));

    try {
      await _adminSelectionService.togglePizzaSelection(pizza, isAdding);
    } catch (e) {
      // Rollback on error
      final rollback = List<PizzaModel>.from(state.selectedPizzas);
      if (isAdding) {
        rollback.removeWhere((p) => p.id == pizza.id);
      } else {
        rollback.add(pizza);
      }
      emit(state.copyWith(selectedPizzas: _sortPizzas(rollback)));
    }
  }

  bool isSelected(String pizzaId) {
    return state.selectedPizzas.any((p) => p.id == pizzaId);
  }

  Future<void> clearSelection() async {
    final previous = state.selectedPizzas;
    emit(state.copyWith(selectedPizzas: const []));

    try {
      await _adminSelectionService.clearSelection();
    } catch (e) {
      emit(state.copyWith(selectedPizzas: previous));
    }
  }

  List<PizzaModel> _sortPizzas(List<PizzaModel> pizzas) {
    int rank(PizzaAward? award) {
      if (award == PizzaAward.general) return 0;
      if (award == PizzaAward.category) return 1;
      return 2;
    }

    return List.from(pizzas)..sort((a, b) {
      final comp = rank(a.award).compareTo(rank(b.award));
      return comp != 0 ? comp : b.createdAt.compareTo(a.createdAt);
    });
  }
}
