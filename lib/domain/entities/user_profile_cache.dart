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

  bool get isExpired {
    final now = DateTime.now();
    return now.difference(lastUpdated).inMinutes >= 5;
  }
}
