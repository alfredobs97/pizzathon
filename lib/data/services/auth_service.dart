//import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthService() {
    _auth.setLanguageCode('es');
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithGoogle() async {
    print("[AuthService] 1. Iniciando signInWithGoogle()");
    try {
      final GoogleAuthProvider provider = GoogleAuthProvider();
      print("[AuthService] 2. GoogleAuthProvider instanciado");

      provider.setCustomParameters({
        'hl': 'es', 
      });
      print("[AuthService] 3. Ejecutando signInWithPopup...");

      final result = await _auth.signInWithPopup(provider);
      
      print("[AuthService] 4. signInWithPopup completado exitosamente. UID: ${result.user?.uid}");
      return result;
    } catch (e, stackTrace) {
      print("[AuthService] X. FALLO en signInWithPopup: $e\n$stackTrace");
      return null; 
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e, stackTrace) {
      print("[AuthService] Error al cerrar sesión: $e\n$stackTrace");
    }
  }
}