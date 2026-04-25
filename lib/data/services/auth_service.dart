import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthService() {
    _auth.setLanguageCode('es');
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleAuthProvider provider = GoogleAuthProvider();

    provider.setCustomParameters({'hl': 'es'});

    final result = await _auth.signInWithPopup(provider);
    return result;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
