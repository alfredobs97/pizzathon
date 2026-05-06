import '../../domain/entities/user_pizzas_cache.dart';
import '../../domain/entities/user_profile_cache.dart';

class CacheService {
  UserPizzasCache? _userPizzasCache;
  UserProfileCache? _userProfileCache;

  UserPizzasCache? getUserPizzas() {
    final cache = _userPizzasCache;
    if (cache == null) return null;
    if (cache.isExpired) {
      _userPizzasCache = null;
      return null;
    }
    return cache;
  }

  void saveUserPizzas(UserPizzasCache cache) {
    _userPizzasCache = cache;
  }

  void invalidateUserPizzas() {
    _userPizzasCache = null;
  }

  UserProfileCache? getUserProfile() {
    final cache = _userProfileCache;
    if (cache == null) return null;
    if (cache.isExpired) {
      _userProfileCache = null;
      return null;
    }
    return cache;
  }

  void saveUserProfile(UserProfileCache cache) {
    _userProfileCache = cache;
  }

  void invalidateUserProfile() {
    _userProfileCache = null;
  }

  void clearAll() {
    _userPizzasCache = null;
    _userProfileCache = null;
  }
}
