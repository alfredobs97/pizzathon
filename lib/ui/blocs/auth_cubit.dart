import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/data/services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;

  AuthCubit(this._authService) : super(AuthInitial()) {
    _authSubscription = _authService.authStateChanges.listen((user) {
      emit(user != null ? AuthAuthenticated(user) : AuthUnauthenticated());
    });
  }

  Future<void> login() async {
    print("[AuthCubit] A. Emitiendo AuthLoading");
    emit(AuthLoading());
    try {
      print("[AuthCubit] B. Llamando a authService.signInWithGoogle()");
      await _authService.signInWithGoogle();
      print("[AuthCubit] C. authService finalizó exitosamente");
    } catch (e, stackTrace) {
      print("[AuthCubit] X. Error en login(): $e\n$stackTrace");
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
