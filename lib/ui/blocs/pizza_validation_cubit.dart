import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pizzathon/domain/entities/validation_result.dart';
import 'package:pizzathon/domain/pizza_validator.dart';
import 'package:pizzathon/data/services/image_metadata_service.dart';
import 'pizza_validation_state.dart';

class PizzaValidationCubit extends Cubit<PizzaValidationState> {
  final ImagePicker _picker;
  final ImageMetadataService _metadataService;
  final PizzaValidator _validator;

  PizzaValidationCubit({
    ImagePicker? picker,
    ImageMetadataService? metadataService,
    PizzaValidator? validator,
  }) : _picker = picker ?? ImagePicker(),
       _metadataService = metadataService ?? ImageMetadataService(),
       _validator = validator ?? PizzaValidator(),
       super(const PizzaValidationState());

  Future<void> pickAndValidateImage() async {
    try {
      final XFile? imagePath = await _picker.pickImage(source: ImageSource.gallery);

      if (imagePath == null) {
        // User canceled picking an image
        return;
      }

      emit(
        state.copyWith(
          status: PizzaValidationStatus.loading,
          imageFile: imagePath,
          errorMessage: null,
        ),
      );

      // Simulate a bit of loading for UX
      await Future.delayed(const Duration(seconds: 1));

      final metadata = await _metadataService.extractMetadata(imagePath);
      final validationResult = await _validator.validate(metadata);

      switch (validationResult) {
        case ValidationSuccess():
          emit(state.copyWith(status: PizzaValidationStatus.success, metadata: metadata));
        case ValidationRejected(:final reason):
          emit(
            state.copyWith(
              status: PizzaValidationStatus.rejected,
              errorMessage: reason,
              metadata: metadata,
            ),
          );
        case ValidationDisqualified(:final reason):
          emit(
            state.copyWith(
              status: PizzaValidationStatus.disqualified,
              errorMessage: reason,
              metadata: metadata,
            ),
          );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: PizzaValidationStatus.rejected,
          errorMessage: 'Error inesperado al procesar la imagen: $e',
        ),
      );
    }
  }

  void reset() {
    emit(const PizzaValidationState());
  }
}
