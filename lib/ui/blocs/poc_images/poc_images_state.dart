import 'dart:typed_data';

sealed class PocImagesState {}

class PocImagesInitial extends PocImagesState {}

class PocImagesLoading extends PocImagesState {}

class PocImagesSuccess extends PocImagesState {
  final List<({Uint8List original, Uint8List compressed})> processedImages;
  
  PocImagesSuccess({required this.processedImages});
}

class PocImagesError extends PocImagesState {
  final String message;
  PocImagesError(this.message);
}