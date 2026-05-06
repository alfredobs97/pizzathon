import 'package:pizzathon/domain/entities/user_pizzas_cache.dart';
import 'package:pizzathon/domain/models/pizza_model.dart';

class CacheService {
  UserPizzasCache? _userPizzasCache;

  UserPizzasCache? getUserPizzas() {
    final cache = _userPizzasCache;
    if (cache == null) return null;
    if (cache.isExpired) {
      _userPizzasCache = null;
      return null;
    }
    return cache;
  }

  void saveUserPizzas(List<PizzaModel> pizzas, bool hasReachedMax) {
    _userPizzasCache = UserPizzasCache(
      pizzas: pizzas,
      lastUpdated: DateTime.now(),
      hasReachedMax: hasReachedMax,
    );
  }

  void invalidateUserPizzas() {
    _userPizzasCache = null;
  }

  void clearAll() {
    _userPizzasCache = null;
  }
}
