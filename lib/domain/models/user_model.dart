import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? shortId;
  final String displayName;
  final String email;
  final String photoUrl;
  final int score;
  final DateTime createdAt;
  final bool isBanned;

  UserModel({
    required this.uid,
    this.shortId,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.score,
    required this.createdAt,
    this.isBanned = false,
  });

  String get slug => displayName.toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9]+'), '-');

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return UserModel(
      uid: doc.id,
      shortId: data?['shortId'] as String?,
      displayName: data?['displayName'] as String? ?? '',
      email: data?['email'] as String? ?? '',
      photoUrl: data?['photoUrl'] as String? ?? '',
      score: data?['score'] as int? ?? 0,
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isBanned: data?['banned'] as bool? ?? false,
    );
  }
}
