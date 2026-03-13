import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pizzathon/domain/entities/pizza_image_metadata.dart';

enum PizzaValidationStatus { initial, loading, success, rejected, unsure }

class PizzaValidationState extends Equatable {
  final PizzaValidationStatus status;
  final XFile? imageFile;
  final PizzaImageMetadata? metadata;
  final String? errorMessage;

  const PizzaValidationState({
    this.status = PizzaValidationStatus.initial,
    this.imageFile,
    this.metadata,
    this.errorMessage,
  });

  PizzaValidationState copyWith({
    PizzaValidationStatus? status,
    XFile? imageFile,
    PizzaImageMetadata? metadata,
    String? errorMessage,
  }) {
    return PizzaValidationState(
      status: status ?? this.status,
      imageFile: imageFile ?? this.imageFile,
      metadata: metadata ?? this.metadata,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, imageFile, metadata, errorMessage];
}
