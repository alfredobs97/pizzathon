import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:typed_data';
import '../../../data/services/image_processing_service.dart';
import '../../../data/services/remote_config_service.dart';
import '../../../domain/models/compression_settings.dart';
import 'poc_images_state.dart';

class PocImagesCubit extends Cubit<PocImagesState> {
  final ImageProcessingService _imageProcessingService;
  final RemoteConfigService _remoteConfigService;
  
  static const int limitePizzas = 4;

  PocImagesCubit(this._imageProcessingService, this._remoteConfigService)
    : super(PocImagesInitial());

  Future<void> pickAndCompressImages() async {
    try {
      final currentState = state;
      List<({Uint8List original, Uint8List compressed})> currentList = [];

      if (currentState is PocImagesSuccess) {
        currentList = List.of(currentState.processedImages);
      }

      emit(PocImagesLoading());
      final newOriginals = await _imageProcessingService.pickMultipleImages();

      if (newOriginals.isEmpty) {
        _restorePreviousState(currentList);
        return;
      }

      // VALIDACIÓN 1: El máximo permitido
      final int totalImages = currentList.length + newOriginals.length;
      
      if (totalImages > limitePizzas) {
        emit(PocImagesError("Solo puedes subir un máximo de $limitePizzas imágenes. Tienes ${currentList.length} y has intentado añadir ${newOriginals.length}."));
        // Restauramos el estado para no perder las fotos que ya se estaban mostrando en el Success
        _restorePreviousState(currentList);
        return;
      }

      final int fetchedQuality = _remoteConfigService.imageCompressionQuality;
      final settings = CompressionSettings(quality: fetchedQuality);

      List<({Uint8List original, Uint8List compressed})> finalList = List.of(currentList);

      for (var originalBytes in newOriginals) {
        final compressedBytes = await _imageProcessingService.compressImage(
          originalBytes,
          settings: settings,
        );

        if (compressedBytes != null) {
          finalList.add((original: originalBytes, compressed: compressedBytes));
        }
      }

      if (finalList.isNotEmpty) {
        emit(PocImagesSuccess(processedImages: finalList));
      } else {
        if (currentList.isNotEmpty) {
          emit(PocImagesSuccess(processedImages: currentList));
        } else {
          emit(PocImagesError("No se pudo comprimir ninguna imagen."));
        }
      }
    } catch (e) {
      emit(PocImagesError("Ups! Error: ${e.toString()}"));
    }
  }

  void removeImage(int index) {
    if (state is PocImagesSuccess) {
      final currentState = state as PocImagesSuccess;
      final updatedList = List.of(currentState.processedImages);

      updatedList.removeAt(index);

      if (updatedList.isEmpty) {
        emit(PocImagesInitial());
      } else {
        emit(PocImagesSuccess(processedImages: updatedList));
      }
    }
  }

  // Helper para restaurar el estado y no perder las fotos previas tras un error/cancelación
  void _restorePreviousState(List<({Uint8List original, Uint8List compressed})> currentList) {
    if (currentList.isNotEmpty) {
      emit(PocImagesSuccess(processedImages: currentList));
    } else {
      emit(PocImagesInitial());
    }
  }

  // VALIDACIÓN 2: El mínimo (exactamente 4). 
  // Usa esto en tu UI para habilitar/deshabilitar el botón de "Validar Imágenes" o "Siguiente Paso"
  bool get hasExactlyFourImages {
    if (state is PocImagesSuccess) {
      return (state as PocImagesSuccess).processedImages.length == limitePizzas;
    }
    return false;
  }
}