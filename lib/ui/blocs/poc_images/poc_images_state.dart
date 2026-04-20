import 'dart:typed_data';

enum PizzaPhotoStep { bocaHorno, vistaArriba, corte, abajo }

extension PizzaPhotoStepExtension on PizzaPhotoStep {
  String get title {
    switch (this) {
      case PizzaPhotoStep.bocaHorno: return 'Foto 1: A boca de horno';
      case PizzaPhotoStep.vistaArriba: return 'Foto 2: Desde arriba';
      case PizzaPhotoStep.corte: return 'Foto 3: De corte';
      case PizzaPhotoStep.abajo: return 'Foto 4: De abajo';
    }
  }

  String get exampleImageUrl {
    switch (this) {
      case PizzaPhotoStep.bocaHorno: 
        return 'https://i.ibb.co/n2sYtLD/b8eab707322743000dc0cbeb211a500a33fc43af.jpg';
      case PizzaPhotoStep.vistaArriba: 
        return 'URL_FOTO_2';
      case PizzaPhotoStep.corte: 
        return 'URL_FOTO_3';
      case PizzaPhotoStep.abajo: 
        return 'URL_FOTO_4';
    }
  }
}

class PocImagesState {
  final PizzaPhotoStep currentStep;
  final Uint8List? pendingImage; 
  final Map<PizzaPhotoStep, Uint8List> confirmedImages; 
  final bool isLoading;
  final String? errorMessage;
  final bool isFinished; 

  PocImagesState({
    this.currentStep = PizzaPhotoStep.bocaHorno,
    this.pendingImage,
    this.confirmedImages = const {},
    this.isLoading = false,
    this.errorMessage,
    this.isFinished = false,
  });

  PocImagesState copyWith({
    PizzaPhotoStep? currentStep,
    Uint8List? pendingImage,
    Map<PizzaPhotoStep, Uint8List>? confirmedImages,
    bool? isLoading,
    String? errorMessage,
    bool? isFinished,
    bool clearPendingImage = false,
  }) {
    return PocImagesState(
      currentStep: currentStep ?? this.currentStep,
      pendingImage: clearPendingImage ? null : (pendingImage ?? this.pendingImage),
      confirmedImages: confirmedImages ?? this.confirmedImages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Si es null, limpia el error
      isFinished: isFinished ?? this.isFinished,
    );
  }
}