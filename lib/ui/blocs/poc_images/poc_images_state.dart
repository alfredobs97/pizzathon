import 'package:image_picker/image_picker.dart';
import '../../../domain/models/pizza_photo_step.dart';
import '../../../domain/models/pizza_model.dart';

enum WizardStep { fotos, formulario, ingredientes, confirmacion }

class PocImagesState {
  final WizardStep mainStep;
  final PizzaPhotoStep currentStep;
  final XFile? pendingImage;
  final Map<PizzaPhotoStep, XFile> confirmedImages;
  final Map<PizzaPhotoStep, int> originalSizes;
  final Map<PizzaPhotoStep, int> compressedSizes;
  final Map<PizzaPhotoStep, String> imageUrls;
  final bool isLoading;
  final String? errorMessage;
  final bool isFinished;

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
    XFile? pendingImage,
    Map<PizzaPhotoStep, XFile>? confirmedImages,
    Map<PizzaPhotoStep, int>? originalSizes,
    Map<PizzaPhotoStep, int>? compressedSizes,
    Map<PizzaPhotoStep, String>? imageUrls,
    bool? isLoading,
    String? errorMessage,
    bool? isFinished,
    PizzaStyle? pizzaStyle,
    String? flours,
    String? preferment,
    int? prefermentPercentage,
    num? hydration,
    num? doughBallWeight,
    String? oven,
    num? cookingTemperature,
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
