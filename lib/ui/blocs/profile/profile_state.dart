import 'package:equatable/equatable.dart';
import '../../../domain/models/user_model.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserModel? user;
  final int pizzaCount;
  final String? errorMessage;
  final String? shareUrl;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.pizzaCount = 0,
    this.errorMessage,
    this.shareUrl,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserModel? user,
    int? pizzaCount,
    String? errorMessage,
    String? shareUrl,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      pizzaCount: pizzaCount ?? this.pizzaCount,
      errorMessage: errorMessage ?? this.errorMessage,
      shareUrl: shareUrl,
    );
  }

  @override
  List<Object?> get props => [status, user, pizzaCount, errorMessage, shareUrl];
}
