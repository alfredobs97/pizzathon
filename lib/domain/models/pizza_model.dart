import 'package:cloud_firestore/cloud_firestore.dart';

class PizzaModel {
  final String id;
  final String userId;
  final String imageUrl;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const PizzaModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.thumbnailUrl,
    required this.createdAt,
    this.metadata,
  });

  factory PizzaModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PizzaModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: data['metadata'],
    );
  }
}
