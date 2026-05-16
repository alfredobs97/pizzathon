import 'package:equatable/equatable.dart';
import '../../../domain/models/pizza_model.dart';

class AdminSelectedPizzasState extends Equatable {
  final List<PizzaModel> selectedPizzas;
  final bool isLoading;

  const AdminSelectedPizzasState({
    this.selectedPizzas = const [],
    this.isLoading = false,
  });

  AdminSelectedPizzasState copyWith({
    List<PizzaModel>? selectedPizzas,
    bool? isLoading,
  }) {
    return AdminSelectedPizzasState(
      selectedPizzas: selectedPizzas ?? this.selectedPizzas,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [selectedPizzas, isLoading];
}
