import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/cache_service.dart';
import '../../../data/services/firestore_service.dart';
import '../../../domain/entities/user_profile_cache.dart';
import '../../../domain/models/user_model.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final FirestoreService _firestoreService;
  final CacheService _cacheService;

  ProfileCubit({required FirestoreService firestoreService, required CacheService cacheService})
    : _firestoreService = firestoreService,
      _cacheService = cacheService,
      super(const ProfileState());

  Future<void> loadProfile(String uid) async {
    final cached = _cacheService.getUserProfile();
    if (cached != null && cached.user.uid == uid) {
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          user: cached.user,
          pizzaCount: cached.pizzaCount,
        ),
      );
      return;
    }

    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final user = await _firestoreService.getUser(uid);
      if (user == null) {
        emit(state.copyWith(status: ProfileStatus.error, errorMessage: 'Usuario no encontrado'));
        return;
      }

      final pizzaCount = await _firestoreService.getUserPizzaCount(uid);

      final newCache = UserProfileCache(
        user: user,
        pizzaCount: pizzaCount,
        lastUpdated: DateTime.now(),
      );
      _cacheService.saveUserProfile(newCache);

      emit(state.copyWith(status: ProfileStatus.loaded, user: user, pizzaCount: pizzaCount));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> loadPublicProfile(String identifier) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      UserModel? user;
      if (identifier.length <= 10) {
        user = await _firestoreService.getUserByShortId(identifier);
      }

      user ??= await _firestoreService.getUser(identifier);

      if (user == null) {
        emit(state.copyWith(status: ProfileStatus.error, errorMessage: 'Perfil no encontrado'));
        return;
      }

      final pizzaCount = await _firestoreService.getUserPizzaCount(user.uid);
      emit(state.copyWith(status: ProfileStatus.loaded, user: user, pizzaCount: pizzaCount));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> generateShareLink(UserModel user) async {
    try {
      String? shortId = user.shortId;
      UserModel updatedUser = user;

      if (shortId == null || shortId.isEmpty) {
        shortId = await _firestoreService.generateAndSaveShortId(user.uid);

        updatedUser = UserModel(
          uid: user.uid,
          shortId: shortId,
          displayName: user.displayName,
          email: user.email,
          photoUrl: user.photoUrl,
          score: user.score,
          createdAt: user.createdAt,
          isBanned: user.isBanned,
        );

        _cacheService.saveUserProfile(
          UserProfileCache(
            user: updatedUser,
            pizzaCount: state.pizzaCount,
            lastUpdated: DateTime.now(),
          ),
        );
      }

      const domain = String.fromEnvironment('APP_DOMAIN', defaultValue: 'https://pizzathon.es/');
      final shareUrl = '$domain/p/$shortId-${updatedUser.slug}';

      emit(state.copyWith(user: updatedUser, shareUrl: shareUrl));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, errorMessage: 'Error al generar link: $e'));
    }
  }

  void clearShareUrl() {
    emit(state.copyWith(shareUrl: null));
  }
}
