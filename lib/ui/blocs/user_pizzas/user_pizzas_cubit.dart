import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/firestore_service.dart';
import 'user_pizzas_state.dart';

class UserPizzasCubit extends Cubit<UserPizzasState> {
  final FirestoreService _firestoreService;
  final String userId;
  static const int _limit = 5;

  UserPizzasCubit({
    required FirestoreService firestoreService,
    required this.userId,
  }) : _firestoreService = firestoreService,
       super(UserPizzasInitial());

  Future<void> fetchInitialPizzas() async {
    emit(UserPizzasLoading());
    try {
      final result = await _firestoreService.getPizzasFromUserPaginated(
        uid: userId,
        limit: _limit,
      );

      emit(
        UserPizzasLoaded(
          pizzas: result.pizzas,
          lastDocument: result.lastDocument,
          hasReachedMax: result.pizzas.length < _limit,
        ),
      );
    } catch (e) {
      emit(UserPizzasError(e.toString()));
    }
  }

  Future<void> fetchMorePizzas() async {
    final currentState = state;
    if (currentState is! UserPizzasLoaded || currentState.hasReachedMax) return;

    try {
      final result = await _firestoreService.getPizzasFromUserPaginated(
        uid: userId,
        lastDocument: currentState.lastDocument,
        limit: _limit,
      );

      emit(
        UserPizzasLoaded(
          pizzas: [...currentState.pizzas, ...result.pizzas],
          lastDocument: result.lastDocument,
          hasReachedMax: result.pizzas.length < _limit,
        ),
      );
    } catch (e) {
      // In case of error when loading more, we could just stay in the current state or show an error
      // For now, let's keep it simple
      emit(UserPizzasError(e.toString()));
    }
  }
}
