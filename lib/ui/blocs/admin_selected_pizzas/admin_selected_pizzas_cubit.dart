import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/admin_selection_service.dart';
import '../../../domain/models/pizza_model.dart';
import 'admin_selected_pizzas_state.dart';

class AdminSelectedPizzasCubit extends Cubit<AdminSelectedPizzasState> {
  final AdminSelectionService _adminSelectionService;

  AdminSelectedPizzasCubit(this._adminSelectionService) : super(const AdminSelectedPizzasState());

  Future<void> init(String adminId) async {
    if (state.isLoading) return;
    emit(state.copyWith(isLoading: true));
    try {
      final pizzas = await _adminSelectionService.getSelectedPizzas(adminId);
      emit(state.copyWith(selectedPizzas: pizzas, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> togglePizza(String adminId, PizzaModel pizza) async {
    final List<PizzaModel> current = List.from(state.selectedPizzas);
    final int index = current.indexWhere((p) => p.id == pizza.id);
    final bool isAdding = index < 0;

    if (isAdding) {
      current.add(pizza);
    } else {
      current.removeAt(index);
    }

    // Optimistic update
    emit(state.copyWith(selectedPizzas: current));

    try {
      await _adminSelectionService.togglePizzaSelection(adminId, pizza, isAdding);
    } catch (e) {
      // Rollback on error
      final rollback = List<PizzaModel>.from(state.selectedPizzas);
      if (isAdding) {
        rollback.removeWhere((p) => p.id == pizza.id);
      } else {
        rollback.add(pizza);
      }
      emit(state.copyWith(selectedPizzas: rollback));
    }
  }

  bool isSelected(String pizzaId) {
    return state.selectedPizzas.any((p) => p.id == pizzaId);
  }

  Future<void> clearSelection(String adminId) async {
    final previous = state.selectedPizzas;
    emit(state.copyWith(selectedPizzas: const []));

    try {
      await _adminSelectionService.clearSelection(adminId);
    } catch (e) {
      emit(state.copyWith(selectedPizzas: previous));
    }
  }
}
