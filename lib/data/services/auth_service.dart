import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthService() {
    _auth.setLanguageCode('es');
  }

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleAuthProvider provider = GoogleAuthProvider();

      provider.setCustomParameters({
        'hl': 'es', 
      });

      return await _auth.signInWithPopup(provider);
      
    } catch (e, stackTrace) {
      log("Error en Google Sign-In (Web)", error: e, stackTrace: stackTrace, name: 'AuthService');
      return null; 
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e, stackTrace) {
      log("Error al cerrar sesión", error: e, stackTrace: stackTrace, name: 'AuthService');
    }
  }
}