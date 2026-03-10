import 'package:pizzathon/domain/entities/pizza_image_metadata.dart';

import 'entities/pizza_validation_rules.dart';
import 'entities/validation_result.dart';

/// Executes each [PizzaValidationRule] in order and returns the first failure,
/// or success if all rules pass.
class PizzaValidator {
  final List<PizzaValidationRule> rules;

  PizzaValidator({List<PizzaValidationRule>? rules})
    : rules =
          rules ??
          const [
            MaxAgeRule(),
            DisallowC2paAIGeneratedRule(),
            DisallowAIGeneratedRule(),
            DisallowScreenshotsRule(),
            RequireCameraMetadataRule(),
            RequireExifDataRule(),
          ];

  ValidationResult validate(PizzaImageMetadata metadata) {
    ValidationResult finalResult = const ValidationSuccess();
    for (final rule in rules) {
      final result = rule.validate(metadata);

      if (result is ValidationRejected) {
        return result;
      }

      if (result is ValidationUnsure && finalResult is ValidationSuccess) {
        // Keep the first unsure reason but continue checking for rejections
        finalResult = result;
      }
    }
    return finalResult;
  }
}
