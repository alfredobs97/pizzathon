import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:typed_data';
import '../../../data/services/image_processing_service.dart';
import '../../../data/services/remote_config_service.dart'; 
import '../../../domain/models/compression_settings.dart'; 
import 'poc_images_state.dart';

class PocImagesCubit extends Cubit<PocImagesState> {
  final ImageProcessingService _imageProcessingService;
  final RemoteConfigService _remoteConfigService;

  //static const int limitePizzas = 5;

  PocImagesCubit(
    this._imageProcessingService,
    this._remoteConfigService,
  ) : super(PocImagesInitial());

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
        if (currentList.isNotEmpty) {
          emit(PocImagesSuccess(processedImages: currentList));
        } else {
          emit(PocImagesInitial());
        }
        return;
      }

      final int fetchedQuality = _remoteConfigService.imageCompressionQuality;

      final CompressionSettings settings = fetchedQuality > 0 
          ? CompressionSettings(quality: fetchedQuality) 
          : CompressionSettings.defaultConfig();

      List<({Uint8List original, Uint8List compressed})> finalList = List.of(currentList);

      for (var originalBytes in newOriginals) {
        final compressedBytes = await _imageProcessingService.compressImage(
          originalBytes,
          quality: settings.quality,
        );

        if (compressedBytes != null) {
          finalList.add((
            original: originalBytes,
            compressed: compressedBytes,
          ));
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
}