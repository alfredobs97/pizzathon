import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/cache_service.dart';
import '../../../data/services/firestore_service.dart';
import 'user_pizzas_state.dart';

class UserPizzasCubit extends Cubit<UserPizzasState> {
  final FirestoreService _firestoreService;
  final CacheService _cacheService;
  final String userId;
  static const int _limit = 5;

  UserPizzasCubit({
    required FirestoreService firestoreService,
    required CacheService cacheService,
    required this.userId,
  }) : _firestoreService = firestoreService,
       _cacheService = cacheService,
       super(UserPizzasInitial());

  Future<void> fetchInitialPizzas() async {
    final cached = _cacheService.getUserPizzas();
    if (cached != null) {
      emit(
        UserPizzasLoaded(
          pizzas: cached.pizzas,
          lastDocument: cached.lastDocument,
          hasReachedMax: cached.hasReachedMax,
        ),
      );
      return;
    }

    emit(UserPizzasLoading());
    try {
      final result = await _firestoreService.getPizzasFromUserPaginated(uid: userId, limit: _limit);

      _cacheService.saveUserPizzas(result.pizzas, result.pizzas.length < _limit);

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

      final updatedPizzas = [...currentState.pizzas, ...result.pizzas];

      _cacheService.saveUserPizzas(updatedPizzas, result.pizzas.length < _limit);

      emit(
        UserPizzasLoaded(
          pizzas: updatedPizzas,
          lastDocument: result.lastDocument,
          hasReachedMax: result.pizzas.length < _limit,
        ),
      );
    } catch (e) {
      emit(UserPizzasError(e.toString()));
    }
  }
}
