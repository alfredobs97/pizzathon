import 'dart:typed_data';

enum PizzaPhotoStep { bocaHorno, vistaArriba, corte, abajo;
  String get title {
    switch (this) {
      case PizzaPhotoStep.bocaHorno:
        return 'Pizza a boca de horno';
      case PizzaPhotoStep.vistaArriba:
        return 'Pizza desde arriba';
      case PizzaPhotoStep.corte:
        return 'Pizza corte porcion';
      case PizzaPhotoStep.abajo:
        return 'Pizza cocción debajo';
    }
  }

  String get description {
    switch (this) {
      case PizzaPhotoStep.bocaHorno:
        return 'Debe verse la pizza recien hecha sobre la pala en la entrada del horno';
      case PizzaPhotoStep.vistaArriba:
        return 'Debe verse la pizza completa en todo su diámetro desde arriba';
      case PizzaPhotoStep.corte:
        return 'Debe verse el corte lateral de una porción independientemente del estilo de pizza';
      case PizzaPhotoStep.abajo:
        return 'Debe verse al menos parcialmente la cocción de la masa debajo';
    }
  }

  String get exampleImageUrl {
    switch (this) {
      case PizzaPhotoStep.bocaHorno:
        return 'https://i.ibb.co/n2sYtLD/b8eab707322743000dc0cbeb211a500a33fc43af.jpg';
      case PizzaPhotoStep.vistaArriba:
        return 'https://i.ibb.co/CKs7jkvD/569589abb736fba9fcf5d2f014c13243a7854c8d.jpg';
      case PizzaPhotoStep.corte:
        return 'https://i.ibb.co/4RbS9mVH/733255011dc93e0156a96a05823a61893d1bac11.jpg';
      case PizzaPhotoStep.abajo:
        return 'https://i.ibb.co/nMNCmZwc/6cacf9ccfc8592c764c292ff1893325a3d2a4b93.jpg';
    }
  }
}

enum WizardStep { fotos, formulario, confirmacion }


class PocImagesState {
  final WizardStep mainStep;
  final PizzaPhotoStep currentStep;
  final Uint8List? pendingImage;
  final Map<PizzaPhotoStep, Uint8List> confirmedImages;
  final bool isLoading;
  final String? errorMessage;
  final bool isFinished;

  // --- NUEVOS CAMPOS PARA EL FORMULARIO ---
  final String? pizzaStyle;
  final String? flours;
  final String? preferment;
  final String? prefermentPercentage;
  final String? hydration;
  final String? doughBallWeight;
  final String? oven;
  final String? cookingTemperature;
  final bool isSubmitting;

  PocImagesState({
    this.mainStep = WizardStep.fotos,
    this.currentStep = PizzaPhotoStep.bocaHorno,
    this.pendingImage,
    this.confirmedImages = const {},
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
    this.isSubmitting = false,
  });

  PocImagesState copyWith({
    WizardStep? mainStep,
    PizzaPhotoStep? currentStep,
    Uint8List? pendingImage,
    Map<PizzaPhotoStep, Uint8List>? confirmedImages,
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
    bool? isSubmitting,
    bool clearPendingImage = false,
  }) {
    return PocImagesState(
      mainStep: mainStep ?? this.mainStep,
      currentStep: currentStep ?? this.currentStep,
      pendingImage: clearPendingImage ? null : (pendingImage ?? this.pendingImage),
      confirmedImages: confirmedImages ?? this.confirmedImages,
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
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
