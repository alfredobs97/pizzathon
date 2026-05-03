import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizzathon/data/services/auth_service.dart';
import 'package:pizzathon/data/services/firestore_service.dart';
import 'package:pizzathon/data/services/pizza_storage_service.dart';
import 'package:pizzathon/domain/entities/tracked_error.dart';
import 'package:pizzathon/domain/services/error_tracker_service.dart';
import 'dart:typed_data';

import '../../../data/services/image_processing_service.dart';
import '../../../data/services/remote_config_service.dart';
import '../../../data/services/image_metadata_service.dart';
import '../../../data/services/pizza_validation_service.dart';
import '../../../domain/models/compression_settings.dart';
import '../../../domain/entities/validation_result.dart';
import 'poc_images_state.dart';

class PocImagesCubit extends Cubit<PocImagesState> {
  final ImageProcessingService _imageProcessingService;
  final RemoteConfigService _remoteConfigService;
  final ImageMetadataService _metadataService;
  final PizzaValidationService _validationService;
  final ErrorTrackerService _errorTrackerService;
  final AuthService _authService;
  final PizzaStorageService _pizzaStorageService;
  final FirestoreService _firestoreService;

  PocImagesCubit(
    this._imageProcessingService,
    this._remoteConfigService,
    this._metadataService,
    this._validationService,
    this._errorTrackerService,
    this._authService,
    this._pizzaStorageService,
    this._firestoreService,
  ) : super(PocImagesState());

  Future<void> pickSingleImage() async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      final file = await _imageProcessingService.pickSingleImage();

      if (file == null) {
        emit(state.copyWith(isLoading: false));
        return;
      }

      final metadata = await _metadataService.extractMetadata(file);

      final validationResult = await _validationService.validate(metadata);

      if (validationResult is! ValidationSuccess) {
        String errorMsg = "Error al validar la imagen.";

        if (validationResult is ValidationRejected) {
          errorMsg = validationResult.reason;
        } else if (validationResult is ValidationDisqualified) {
          errorMsg = validationResult.reason;
        }

        emit(state.copyWith(isLoading: false, errorMessage: errorMsg));
        return;
      }

      final originalBytes = metadata.bytes!;
      final originalSize = originalBytes.length;
      final int fetchedQuality = _remoteConfigService.imageCompressionQuality;
      final settings = CompressionSettings(quality: fetchedQuality);
      debugPrint("valor ANTES de la compresion: ${settings.quality}");

      final compressedBytes = await _imageProcessingService.compressImage(
        originalBytes,
        settings: settings,
      );

      debugPrint("valor DESPUES  de la compresion: ${settings.quality}");

      if (compressedBytes != null) {
        final compressedSize = compressedBytes.length;
        
        final updatedOriginalSizes = Map<PizzaPhotoStep, int>.from(state.originalSizes);
        final updatedCompressedSizes = Map<PizzaPhotoStep, int>.from(state.compressedSizes);
        
        updatedOriginalSizes[state.currentStep] = originalSize;
        updatedCompressedSizes[state.currentStep] = compressedSize;

        emit(
          state.copyWith(
            isLoading: false,
            pendingImage: compressedBytes,
            originalSizes: updatedOriginalSizes,
            compressedSizes: updatedCompressedSizes,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: "No se pudo comprimir la imagen.",
          ),
        );
      }
    } catch (e, stackTrace) {
      _errorTrackerService.trackError(
        TrackedError(
          error: e,
          stackTrace: stackTrace,
          extra: {
            'component': 'PocImagesCubit',
            'action': 'pickAndCompressImages',
          },
        ),
      );
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: "Ups! Error inesperado: ${e.toString()}",
        ),
      );
    }
  }

  void confirmImage() {
    if (state.pendingImage == null) return;

    final updatedConfirmed = Map<PizzaPhotoStep, Uint8List>.from(
      state.confirmedImages,
    );
    updatedConfirmed[state.currentStep] = state.pendingImage!;

    if (state.currentStep == PizzaPhotoStep.bottom) {
      emit(
        state.copyWith(
          mainStep: WizardStep.formulario,
          confirmedImages: updatedConfirmed,
          clearPendingImage: true,
        ),
      );
    } else {
      final nextStep = PizzaPhotoStep.values[state.currentStep.index + 1];
      emit(
        state.copyWith(
          currentStep: nextStep,
          confirmedImages: updatedConfirmed,
          clearPendingImage: true,
        ),
      );
    }
  }

  void nextPhotoStep() {
    if (state.currentStep == PizzaPhotoStep.bottom) {
      emit(
        state.copyWith(
          mainStep: WizardStep.formulario,
          clearPendingImage: true,
        ),
      );
    } else {
      final nextStep = PizzaPhotoStep.values[state.currentStep.index + 1];
      emit(state.copyWith(currentStep: nextStep, clearPendingImage: true));
    }
  }

  void savePizzaDetails({
    required String pizzaStyle,
    required String flours,
    required String preferment,
    required String prefermentPercentage,
    required String hydration,
    required String doughBallWeight,
    required String oven,
    required String cookingTemperature,
  }) {
    emit(
      state.copyWith(
        pizzaStyle: pizzaStyle,
        flours: flours,
        preferment: preferment,
        prefermentPercentage: prefermentPercentage,
        hydration: hydration,
        doughBallWeight: doughBallWeight,
        oven: oven,
        cookingTemperature: cookingTemperature,
        mainStep: WizardStep.ingredientes,
      ),
    );
  }

  void saveIngredients({
    required String baseIngredient,
    required String otherIngredients,
  }) {
    emit(
      state.copyWith(
        baseIngredient: baseIngredient,
        otherIngredients: otherIngredients,
        mainStep: WizardStep.confirmacion,
      ),
    );
  }

  void redoChanges() {
    emit(
      state.copyWith(
        mainStep: WizardStep.fotos,
        currentStep: PizzaPhotoStep.front,
      ),
    );
  }

  void goBackMainStep() {
    if (state.mainStep == WizardStep.formulario) {
      emit(state.copyWith(mainStep: WizardStep.fotos));
    } else if (state.mainStep == WizardStep.ingredientes) {
      emit(state.copyWith(mainStep: WizardStep.formulario));
    } else if (state.mainStep == WizardStep.confirmacion) {
      emit(state.copyWith(mainStep: WizardStep.ingredientes));
    }
  }

  Future<void> submitPizza() async {
    if (state.isSubmitting) return;

    if (state.confirmedImages.length < 4) {
      emit(state.copyWith(errorMessage: "Faltan fotos por confirmar."));
      return;
    }
    if (state.pizzaStyle == null || state.flours == null) {
      emit(state.copyWith(errorMessage: "Faltan detalles de la pizza."));
      return;
    }
    if (state.baseIngredient == null || state.otherIngredients == null) {
      emit(
        state.copyWith(errorMessage: "Faltan los ingredientes de la pizza."),
      );
      return;
    }

    try {
      emit(state.copyWith(isSubmitting: true, errorMessage: null));

      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw Exception("Debes estar identificado para enviar tu pizza.");
      }

      final pizzaData = {
        'pizzaStyle': state.pizzaStyle,
        'flours': state.flours,
        'preferment': state.preferment,
        'prefermentPercentage': state.prefermentPercentage,
        'hydration': state.hydration,
        'doughBallWeight': state.doughBallWeight,
        'oven': state.oven,
        'cookingTemperature': state.cookingTemperature,
        'baseIngredient': state.baseIngredient,
        'otherIngredients': state.otherIngredients,
      };

      final pizzaId = _firestoreService.generatePizzaId();

      final imageUrls = await _pizzaStorageService.uploadPizzaParticipation(
        userId: userId,
        images: state.confirmedImages,
        pizzaId: pizzaId,
      );

      await _firestoreService.savePizzaParticipation(
        userId: userId,
        pizzaId: pizzaId,
        pizzaData: pizzaData,
        imageUrls: imageUrls,
      );

      emit(state.copyWith(
        isSubmitting: false,
        isFinished: true,
        imageUrls: Map<PizzaPhotoStep, String>.fromEntries(
          imageUrls.entries.map(
            (e) => MapEntry(
              PizzaPhotoStep.values.firstWhere((step) => step.name == e.key),
              e.value,
            ),
          ),
        ),
      ));
    } catch (e, stackTrace) {
      _errorTrackerService.trackError(
        TrackedError(
          error: e,
          stackTrace: stackTrace,
          extra: {
            'component': 'PocImagesCubit',
            'action': 'submitPizza',
          },
        ),
      );
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: "Error al enviar la participación al servidor.",
        ),
      );
    }
  }

  void resetWizard() {
    emit(PocImagesState());
  }
}
