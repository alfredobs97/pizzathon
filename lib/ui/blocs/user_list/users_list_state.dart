import '../../../domain/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

sealed class UsersListState {
  const UsersListState();
}

class UsersListInitial extends UsersListState {}

class UsersListLoading extends UsersListState {}

class UsersListLoaded extends UsersListState {
  final List<UserModel> users;
  final DocumentSnapshot? lastDocument;
  final bool hasReachedMax;

  const UsersListLoaded({
    required this.users,
    this.lastDocument,
    required this.hasReachedMax,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UsersListLoaded &&
        other.users == users &&
        other.lastDocument == lastDocument &&
        other.hasReachedMax == hasReachedMax;
  }

  @override
  int get hashCode => Object.hash(users, lastDocument, hasReachedMax);
}

class UsersListError extends UsersListState {
  final String message;

  const UsersListError(this.message);
}
