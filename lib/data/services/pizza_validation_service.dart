import 'package:pizzathon/domain/entities/pizza_image_metadata.dart';
import 'package:pizzathon/domain/entities/validation_result.dart';
import 'package:pizzathon/domain/entities/pizza_validation_rules.dart'; 

class PizzaValidationService {
  static final DateTime fechaInicio = DateTime(2026, 4, 20);
  static final DateTime fechaFin = DateTime(2026, 4, 30, 23, 59, 59); 

  final List<PizzaValidationRule> _rules = [
    const RequireExifDataRule(),
    const DisallowScreenshotsRule(),
    const RequireCameraMetadataRule(),
    const DisallowAIGeneratedRule(),
    ContestDateRangeRule(startDate: fechaInicio, endDate: fechaFin),
  ];

  Future<ValidationResult> validate(PizzaImageMetadata metadata) async {
    for (final rule in _rules) {
      final result = await rule.validate(metadata);
      
      if (result is! ValidationSuccess) {
        return result; 
      }
    }
    return const ValidationSuccess();
  }
}