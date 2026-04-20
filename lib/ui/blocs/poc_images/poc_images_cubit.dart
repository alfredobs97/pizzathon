import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:typed_data';

// Ajusta los imports según tu estructura de carpetas
import '../../../data/services/image_processing_service.dart';
import '../../../data/services/remote_config_service.dart';
import '../../../data/services/image_metadata_service.dart';
import '../../../data/services/pizza_validation_service.dart'; 
import '../../../domain/models/compression_settings.dart';
import '../../../domain/entities/validation_result.dart'; // Añadimos este import
import 'poc_images_state.dart';

class PocImagesCubit extends Cubit<PocImagesState> {
  final ImageProcessingService _imageProcessingService;
  final RemoteConfigService _remoteConfigService;
  final ImageMetadataService _metadataService;
  final PizzaValidationService _validationService;

  PocImagesCubit(
    this._imageProcessingService,
    this._remoteConfigService,
    this._metadataService,
    this._validationService,
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

        emit(state.copyWith(
          isLoading: false,
          errorMessage: errorMsg,
        ));
        return;
      }
      
      final originalBytes = metadata.bytes!; 
      final int fetchedQuality = _remoteConfigService.imageCompressionQuality;
      final settings = CompressionSettings(quality: fetchedQuality);
      debugPrint("valor ANTES de la compresion: ${settings.quality}");
      final compressedBytes = await _imageProcessingService.compressImage(
        originalBytes,
        settings: settings,
      );

      debugPrint("valor DESPUES  de la compresion: ${settings.quality}");
      if (compressedBytes != null) {
        emit(state.copyWith(
          isLoading: false,
          pendingImage: await file.readAsBytes(),

        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: "No se pudo comprimir la imagen.",
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: "Ups! Error inesperado: ${e.toString()}",
      ));
    }
  }

  void confirmImage() {
    if (state.pendingImage == null) return;

    final updatedConfirmed = Map<PizzaPhotoStep, Uint8List>.from(state.confirmedImages);
    updatedConfirmed[state.currentStep] = state.pendingImage!;

    if (state.currentStep == PizzaPhotoStep.abajo) {
      emit(state.copyWith(
        confirmedImages: updatedConfirmed,
        isFinished: true,
        clearPendingImage: true,
      ));
    } else {
      final nextStep = PizzaPhotoStep.values[state.currentStep.index + 1];
      emit(state.copyWith(
        currentStep: nextStep,
        confirmedImages: updatedConfirmed,
        clearPendingImage: true,
      ));
    }
  }
  
  void resetWizard() {
    emit(PocImagesState());
  }
}