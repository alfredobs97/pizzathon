import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial());

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
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
