import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/data/services/cache_service.dart';
import 'package:pizzathon/domain/entities/tracked_error.dart';
import 'package:pizzathon/domain/services/error_tracker_service.dart';
import '../../data/services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final ErrorTrackerService _errorTrackerService;
  final CacheService _cacheService;
  StreamSubscription<User?>? _authSubscription;

  AuthCubit(this._authService, this._errorTrackerService, this._cacheService)
    : super(AuthInitial()) {
    _authSubscription = _authService.authStateChanges.listen((user) {
      emit(user != null ? AuthAuthenticated(user) : AuthUnauthenticated());
    });
  }

  Future<void> login() async {
    emit(AuthLoading());
    try {
      await _authService.signInWithGoogle();
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        emit(AuthAuthenticated(currentUser));
      }
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
      _cacheService.clearAll();
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

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
