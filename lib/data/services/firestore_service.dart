import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUser(User user) async {
    final userRef = _db.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      await userRef.set({
        'displayName': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL,
        'score': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
