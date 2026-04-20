import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:typed_data';
import '../../../data/services/image_processing_service.dart';
import '../../../data/services/remote_config_service.dart';
import '../../../domain/models/compression_settings.dart';
import 'poc_images_state.dart';

class PocImagesCubit extends Cubit<PocImagesState> {
  final ImageProcessingService _imageProcessingService;
  final RemoteConfigService _remoteConfigService;

  PocImagesCubit(this._imageProcessingService, this._remoteConfigService)
      : super(PocImagesState());

  Future<void> pickSingleImage() async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final newOriginals = await _imageProcessingService.pickMultipleImages();

      if (newOriginals.isEmpty) {
        emit(state.copyWith(isLoading: false));
        return;
      }

      final originalBytes = newOriginals.first;
      final int fetchedQuality = _remoteConfigService.imageCompressionQuality;
      final settings = CompressionSettings(quality: fetchedQuality);

      final compressedBytes = await _imageProcessingService.compressImage(
        originalBytes,
        settings: settings,
      );

      if (compressedBytes != null) {
        emit(state.copyWith(
          isLoading: false,
          pendingImage: compressedBytes,
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
        errorMessage: "Ups! Error: ${e.toString()}",
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