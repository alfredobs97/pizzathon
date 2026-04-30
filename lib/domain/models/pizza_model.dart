import 'package:cloud_firestore/cloud_firestore.dart';

class PizzaModel {
  final String id;
  final String userId;
  final List<String> imageUrls;
  final String? thumbnailUrl;
  final DateTime createdAt;
  
  // Technical details
  final String? pizzaStyle;
  final String? flours;
  final String? preferment;
  final String? prefermentPercentage;
  final String? hydration;
  final String? doughBallWeight;
  final String? oven;
  final String? cookingTemperature;
  final String? baseIngredient;
  final String? otherIngredients;
  
  final Map<String, dynamic>? metadata;

  const PizzaModel({
    required this.id,
    required this.userId,
    required this.imageUrls,
    this.thumbnailUrl,
    required this.createdAt,
    this.pizzaStyle,
    this.flours,
    this.preferment,
    this.prefermentPercentage,
    this.hydration,
    this.doughBallWeight,
    this.oven,
    this.cookingTemperature,
    this.baseIngredient,
    this.otherIngredients,
    this.metadata,
  });

  factory PizzaModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Handle legacy imageUrl if it exists
    List<String> urls = [];
    if (data['imageUrls'] != null) {
      urls = List<String>.from(data['imageUrls']);
    } else if (data['imageUrl'] != null) {
      urls = [data['imageUrl'] as String];
    }

    return PizzaModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      imageUrls: urls,
      thumbnailUrl: data['thumbnailUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pizzaStyle: data['pizzaStyle'],
      flours: data['flours'],
      preferment: data['preferment'],
      prefermentPercentage: data['prefermentPercentage'],
      hydration: data['hydration'],
      doughBallWeight: data['doughBallWeight'],
      oven: data['oven'],
      cookingTemperature: data['cookingTemperature'],
      baseIngredient: data['baseIngredient'],
      otherIngredients: data['otherIngredients'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'imageUrls': imageUrls,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'pizzaStyle': pizzaStyle,
      'flours': flours,
      'preferment': preferment,
      'prefermentPercentage': prefermentPercentage,
      'hydration': hydration,
      'doughBallWeight': doughBallWeight,
      'oven': oven,
      'cookingTemperature': cookingTemperature,
      'baseIngredient': baseIngredient,
      'otherIngredients': otherIngredients,
      'metadata': metadata,
    };
  }
}
