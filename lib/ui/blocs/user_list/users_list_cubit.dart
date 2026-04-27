import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/domain/entities/tracked_error.dart';
import 'package:pizzathon/domain/services/error_tracker_service.dart';
import '../../../data/services/firestore_service.dart';
import 'users_list_state.dart';

class UsersListCubit extends Cubit<UsersListState> {
  final FirestoreService _firestoreService;
  final ErrorTrackerService? _errorTrackerService;
  static const int _maxItemPerPage = 15;

  UsersListCubit(this._firestoreService, [this._errorTrackerService]) : super(UsersListInitial());

  Future<void> loadInitialUsers() async {
    emit(UsersListLoading());
    try {
      final result = await _firestoreService.getUsersPaginated(limit: _maxItemPerPage);

      emit(
        UsersListLoaded(
          users: result.users,
          lastDocument: result.lastDocument,
          hasReachedMax: result.users.length < _maxItemPerPage,
        ),
      );
    } catch (e, stackTrace) {
      _errorTrackerService?.trackError(
        TrackedError(
          error: e,
          stackTrace: stackTrace,
          extra: {'component': 'UsersListCubit', 'action': 'loadInitialUsers'},
        ),
      );
      emit(UsersListError(e.toString()));
    }
  }

  Future<void> loadMoreUsers() async {
    final currentState = state;
    if (currentState is! UsersListLoaded || currentState.hasReachedMax) return;

    try {
      final result = await _firestoreService.getUsersPaginated(
        lastDocument: currentState.lastDocument,
        limit: _maxItemPerPage,
      );

      emit(
        UsersListLoaded(
          users: [...currentState.users, ...result.users],
          lastDocument: result.lastDocument,
          hasReachedMax: result.users.length < _maxItemPerPage,
        ),
      );
    } catch (e, stackTrace) {
      _errorTrackerService?.trackError(
        TrackedError(
          error: e,
          stackTrace: stackTrace,
          extra: {'component': 'UsersListCubit', 'action': 'loadMoreUsers'},
        ),
      );
      emit(UsersListError(e.toString()));
    }
  }
}
