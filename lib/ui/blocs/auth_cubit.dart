import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/firestore_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final FirestoreService _firestoreService = FirestoreService();

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
      if (userCredential?.user != null) {
        await _firestoreService.saveUser(userCredential!.user!);
        emit(AuthAuthenticated(userCredential.user!));
      } else {
        emit(AuthUnauthenticated());
      }
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