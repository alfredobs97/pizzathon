import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/services/firestore_service.dart';
import '../../../../domain/models/pizza_model.dart';
import 'admin_pizza_review_state.dart';

class AdminPizzaReviewCubit extends Cubit<AdminPizzaReviewState> {
  final FirestoreService _firestoreService;

  AdminPizzaReviewCubit(this._firestoreService) : super(const AdminPizzaReviewState());

  Future<void> loadUserHistory(String userId) async {
    emit(state.copyWith(status: AdminPizzaReviewStatus.loadingHistory));
    try {
      final result = await _firestoreService.getPizzasFromUserPaginated(uid: userId);
      emit(
        state.copyWith(status: AdminPizzaReviewStatus.historyLoaded, previousPizzas: result.pizzas),
      );
    } catch (e) {
      emit(state.copyWith(status: AdminPizzaReviewStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> loadStyleCount(PizzaStyle style) async {
    try {
      final count = await _firestoreService.getPizzaCountByStyle(style);
      emit(state.copyWith(styleCount: count));
    } catch (e) {
      debugPrint('Error loading style count: $e');
    }
  }

  Future<void> submitReview({
    required String pizzaId,
    required String userId,
    required PizzaStatus status,
    int? score,
    String? comment,
  }) async {
    emit(state.copyWith(status: AdminPizzaReviewStatus.submitting));
    try {
      await _firestoreService.reviewPizza(
        pizzaId: pizzaId,
        userId: userId,
        status: status,
        score: score,
        comment: comment,
      );
      emit(state.copyWith(status: AdminPizzaReviewStatus.success));
    } catch (e) {
      debugPrint('Error reviewing pizza: $e');
      emit(state.copyWith(status: AdminPizzaReviewStatus.error, errorMessage: e.toString()));
    }
  }
}
