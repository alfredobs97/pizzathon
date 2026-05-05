import 'package:equatable/equatable.dart';
import '../../../../domain/models/pizza_model.dart';

enum AdminPizzaReviewStatus { initial, loadingHistory, historyLoaded, submitting, success, error }

class AdminPizzaReviewState extends Equatable {
  final AdminPizzaReviewStatus status;
  final List<PizzaModel> previousPizzas;
  final int styleCount;
  final String? errorMessage;

  const AdminPizzaReviewState({
    this.status = AdminPizzaReviewStatus.initial,
    this.previousPizzas = const [],
    this.styleCount = 0,
    this.errorMessage,
  });

  bool get isLoadingHistory => status == AdminPizzaReviewStatus.loadingHistory;
  bool get isSubmitting => status == AdminPizzaReviewStatus.submitting;
  bool get isSuccess => status == AdminPizzaReviewStatus.success;
  bool get isError => status == AdminPizzaReviewStatus.error;

  AdminPizzaReviewState copyWith({
    AdminPizzaReviewStatus? status,
    List<PizzaModel>? previousPizzas,
    int? styleCount,
    String? errorMessage,
  }) {
    return AdminPizzaReviewState(
      status: status ?? this.status,
      previousPizzas: previousPizzas ?? this.previousPizzas,
      styleCount: styleCount ?? this.styleCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, previousPizzas, styleCount, errorMessage];
}

