import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '727941411451-45isi3s3c1gupgfp2p4o9talm60bhn7c.apps.googleusercontent.com',
  );

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Lanza el flujo nativo de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('El usuario canceló el login.');
        return null; 
      }

      // 2. Obtenemos los tokens
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Creamos la credencial
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Logueamos en Firebase
      return await _auth.signInWithCredential(credential);
      
    } catch (e) {
      print("Error en Google Sign-In: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print("Error al cerrar sesión: $e");
    }
  }
  // Método extra que te vendrá bien para saber si ya hay alguien logueado
  User? get currentUser => _auth.currentUser;
}