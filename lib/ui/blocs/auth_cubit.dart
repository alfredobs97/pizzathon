import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/domain/entities/tracked_error.dart';
import 'package:pizzathon/domain/services/error_tracker_service.dart';
import '../../data/services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final ErrorTrackerService _errorTrackerService;

  AuthCubit(this._authService, this._errorTrackerService) : super(AuthInitial());

  void checkAuth() {
    final user = _authService.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login() async {
    emit(AuthLoading());
    try {
      final userCredential = await _authService.signInWithGoogle();
      final user = userCredential?.user;
      emit(user != null ? AuthAuthenticated(user) : AuthUnauthenticated());
    } catch (e, stackTrace) {
      _errorTrackerService.trackError(
        TrackedError(
          error: e,
          stackTrace: stackTrace,
          extra: {'component': 'AuthCubit', 'action': 'login'},
        ),
      );
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
      await _errorTrackerService.clearContext();
      emit(AuthUnauthenticated());
    } catch (e, stackTrace) {
      _errorTrackerService.trackError(
        TrackedError(
          error: e,
          stackTrace: stackTrace,
          extra: {'component': 'AuthCubit', 'action': 'logout'},
        ),
      );
      emit(AuthError(e.toString()));
    }
  }
}
