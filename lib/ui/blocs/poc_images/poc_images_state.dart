import 'dart:typed_data';

enum PizzaPhotoStep {
  front,
  top,
  slice,
  bottom;

  String get title {
    switch (this) {
      case PizzaPhotoStep.front:
        return 'Pizza a boca de horno';
      case PizzaPhotoStep.top:
        return 'Pizza desde arriba';
      case PizzaPhotoStep.slice:
        return 'Pizza corte porcion';
      case PizzaPhotoStep.bottom:
        return 'Pizza cocción debajo';
    }
  }

  String get description {
    switch (this) {
      case PizzaPhotoStep.front:
        return 'Debe verse la pizza recien hecha sobre la pala en la entrada del horno';
      case PizzaPhotoStep.top:
        return 'Debe verse la pizza completa en todo su diámetro desde arriba';
      case PizzaPhotoStep.slice:
        return 'Debe verse el corte lateral de una porción independientemente del estilo de pizza';
      case PizzaPhotoStep.bottom:
        return 'Debe verse al menos parcialmente la cocción de la masa debajo';
    }
  }

  String get exampleImageUrl {
    switch (this) {
      case PizzaPhotoStep.front:
        return 'https://i.ibb.co/n2sYtLD/b8eab707322743000dc0cbeb211a500a33fc43af.jpg';
      case PizzaPhotoStep.top:
        return 'https://i.ibb.co/CKs7jkvD/569589abb736fba9fcf5d2f014c13243a7854c8d.jpg';
      case PizzaPhotoStep.slice:
        return 'https://i.ibb.co/4RbS9mVH/733255011dc93e0156a96a05823a61893d1bac11.jpg';
      case PizzaPhotoStep.bottom:
        return 'https://i.ibb.co/nMNCmZwc/6cacf9ccfc8592c764c292ff1893325a3d2a4b93.jpg';
    }
  }
}

enum WizardStep { fotos, formulario, ingredientes, confirmacion }

class PocImagesState {
  final WizardStep mainStep;
  final PizzaPhotoStep currentStep;
  final Uint8List? pendingImage;
  final Map<PizzaPhotoStep, Uint8List> confirmedImages;
  final Map<PizzaPhotoStep, int> originalSizes;
  final Map<PizzaPhotoStep, int> compressedSizes;
  final Map<PizzaPhotoStep, String> imageUrls;
  final bool isLoading;
  final String? errorMessage;
  final bool isFinished;

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
  final bool isSubmitting;

  PocImagesState({
    this.mainStep = WizardStep.fotos,
    this.currentStep = PizzaPhotoStep.front,
    this.pendingImage,
    this.confirmedImages = const {},
    this.originalSizes = const {},
    this.compressedSizes = const {},
    this.imageUrls = const {},
    this.isLoading = false,
    this.errorMessage,
    this.isFinished = false,
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
    this.isSubmitting = false,
  });

  PocImagesState copyWith({
    WizardStep? mainStep,
    PizzaPhotoStep? currentStep,
    Uint8List? pendingImage,
    Map<PizzaPhotoStep, Uint8List>? confirmedImages,
    Map<PizzaPhotoStep, int>? originalSizes,
    Map<PizzaPhotoStep, int>? compressedSizes,
    Map<PizzaPhotoStep, String>? imageUrls,
    bool? isLoading,
    String? errorMessage,
    bool? isFinished,
    String? pizzaStyle,
    String? flours,
    String? preferment,
    String? prefermentPercentage,
    String? hydration,
    String? doughBallWeight,
    String? oven,
    String? cookingTemperature,
    String? baseIngredient,
    String? otherIngredients,
    bool? isSubmitting,
    bool clearPendingImage = false,
  }) {
    return PocImagesState(
      mainStep: mainStep ?? this.mainStep,
      currentStep: currentStep ?? this.currentStep,
      pendingImage: clearPendingImage ? null : (pendingImage ?? this.pendingImage),
      confirmedImages: confirmedImages ?? this.confirmedImages,
      originalSizes: originalSizes ?? this.originalSizes,
      compressedSizes: compressedSizes ?? this.compressedSizes,
      imageUrls: imageUrls ?? this.imageUrls,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isFinished: isFinished ?? this.isFinished,
      pizzaStyle: pizzaStyle ?? this.pizzaStyle,
      flours: flours ?? this.flours,
      preferment: preferment ?? this.preferment,
      prefermentPercentage: prefermentPercentage ?? this.prefermentPercentage,
      hydration: hydration ?? this.hydration,
      doughBallWeight: doughBallWeight ?? this.doughBallWeight,
      oven: oven ?? this.oven,
      cookingTemperature: cookingTemperature ?? this.cookingTemperature,
      baseIngredient: baseIngredient ?? this.baseIngredient,
      otherIngredients: otherIngredients ?? this.otherIngredients,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
