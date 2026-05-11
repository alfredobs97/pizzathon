import '../../domain/models/user_model.dart';

class UserProfileCache {
  final UserModel user;
  final int pizzaCount;
  final DateTime lastUpdated;

  UserProfileCache({
    required this.user,
    required this.pizzaCount,
    required this.lastUpdated,
  });

  bool isExpired(Duration duration) {
    final now = DateTime.now();
    return now.difference(lastUpdated) >= duration;
  }
}
