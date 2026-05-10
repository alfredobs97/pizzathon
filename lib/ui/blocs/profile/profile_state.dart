import 'package:equatable/equatable.dart';
import '../../../domain/models/user_model.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel user;
  final int pizzaCount;
  final int? rank;

  const ProfileLoaded({
    required this.user,
    required this.pizzaCount,
    this.rank,
  });

  @override
  List<Object?> get props => [user, pizzaCount, rank];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
