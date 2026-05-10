import 'package:equatable/equatable.dart';
import '../../../domain/models/user_model.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserModel? user;
  final int pizzaCount;
  final String? errorMessage;
  final String? shareUrl;
  final int? rank;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.pizzaCount = 0,
    this.errorMessage,
    this.shareUrl,
    this.rank,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserModel? user,
    int? pizzaCount,
    String? errorMessage,
    String? shareUrl,
    int? rank,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      pizzaCount: pizzaCount ?? this.pizzaCount,
      errorMessage: errorMessage ?? this.errorMessage,
      shareUrl: shareUrl,
      rank: rank ?? this.rank,
    );
  }

  @override
  List<Object?> get props => [status, user, pizzaCount, errorMessage, shareUrl, rank];
}
