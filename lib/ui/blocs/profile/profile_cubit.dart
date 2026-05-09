import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/cache_service.dart';
import '../../../data/services/firestore_service.dart';
import '../../../domain/entities/user_profile_cache.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final FirestoreService _firestoreService;
  final CacheService _cacheService;

  ProfileCubit({required FirestoreService firestoreService, required CacheService cacheService})
    : _firestoreService = firestoreService,
      _cacheService = cacheService,
      super(ProfileInitial());

  Future<void> loadProfile(String uid) async {
    final cached = _cacheService.getUserProfile();
    if (cached != null) {
      emit(ProfileLoaded(user: cached.user, pizzaCount: cached.pizzaCount));
      return;
    }

    emit(ProfileLoading());
    try {
      final user = await _firestoreService.getUser(uid);
      if (user == null) {
        emit(const ProfileError('Usuario no encontrado'));
        return;
      }

      final pizzaCount = await _firestoreService.getUserPizzaCount(uid);

      final newCache = UserProfileCache(
        user: user,
        pizzaCount: pizzaCount,
        lastUpdated: DateTime.now(),
      );
      _cacheService.saveUserProfile(newCache);

      emit(ProfileLoaded(user: user, pizzaCount: pizzaCount));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
