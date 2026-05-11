import 'package:cloud_firestore/cloud_firestore.dart';

enum PizzaStyle {
  contemporanea,
  napoletana,
  newYork,
  tondaClasica,
  tondaRomana,
  tegliaRomana,
  padellino,
  palaRomana,
}

extension PizzaStyleExtension on PizzaStyle {
  String get displayName {
    switch (this) {
      case PizzaStyle.contemporanea: return 'Contemporánea';
      case PizzaStyle.napoletana: return 'Napoletana';
      case PizzaStyle.newYork: return 'New York';
      case PizzaStyle.tondaClasica: return 'Tonda clásica';
      case PizzaStyle.tondaRomana: return 'Tonda romana';
      case PizzaStyle.tegliaRomana: return 'Teglia romana';
      case PizzaStyle.padellino: return 'Padellino';
      case PizzaStyle.palaRomana: return 'Pala romana';
    }
  }
}

enum PizzaStatus {
  pending('Sin valorar'),
  approved('Aprobada'),
  rejected('Rechazada');

  final String displayName;
  const PizzaStatus(this.displayName);
}

class PizzaModel {
  final String id;
  final String userId;
  final Map<String, String> imageUrls;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final PizzaStatus status;
  
  // Technical details
  final PizzaStyle? pizzaStyle;
  final String? flours;
  final String? preferment;
  final int? prefermentPercentage;
  final num? hydration;
  final num? doughBallWeight;
  final String? oven;
  final num? cookingTemperature;
  final String? baseIngredient;
  final String? otherIngredients;
  final int? score;
  final String? adminComment;
  
  final Map<String, dynamic>? metadata;

  const PizzaModel({
    required this.id,
    required this.userId,
    required this.imageUrls,
    this.thumbnailUrl,
    required this.createdAt,
    this.status = PizzaStatus.pending,
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
    this.score,
    this.adminComment,
    this.metadata,
  });

  factory PizzaModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    final imageUrlsData = data['imageUrls'];
    final Map<String, String> urls = imageUrlsData is Map 
        ? Map<String, String>.from(imageUrlsData) 
        : {};

    PizzaStyle? style;
    if (data['pizzaStyle'] != null) {
      try {
        style = PizzaStyle.values.firstWhere(
          (e) => e.name == data['pizzaStyle'] || e.displayName == data['pizzaStyle'],
        );
      } catch (_) {}
    }

    PizzaStatus status = PizzaStatus.pending;
    if (data['status'] != null) {
      try {
        status = PizzaStatus.values.firstWhere(
          (e) => e.name == data['status'],
        );
      } catch (_) {}
    }

    return PizzaModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      imageUrls: urls,
      thumbnailUrl: data['thumbnailUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: status,
      pizzaStyle: style,
      flours: data['flours'],
      preferment: data['preferment'],
      prefermentPercentage: data['prefermentPercentage'],
      hydration: data['hydration'],
      doughBallWeight: data['doughBallWeight'],
      oven: data['oven'],
      cookingTemperature: data['cookingTemperature'],
      baseIngredient: data['baseIngredient'],
      otherIngredients: data['otherIngredients'],
      score: data['score'],
      adminComment: data['adminComment'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'pizzaId': id,
      'imageUrls': imageUrls,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'status': status.name,
      'pizzaStyle': pizzaStyle?.name,
      'flours': flours,
      'preferment': preferment,
      'prefermentPercentage': prefermentPercentage,
      'hydration': hydration,
      'doughBallWeight': doughBallWeight,
      'oven': oven,
      'cookingTemperature': cookingTemperature,
      'baseIngredient': baseIngredient,
      'otherIngredients': otherIngredients,
      'score': score,
      'adminComment': adminComment,
      'metadata': metadata,
    };
  }
}
