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
            DisallowC2paAIGeneratedRule(),
            DisallowAIGeneratedRule(),
            MaxAgeRule(),
            DisallowScreenshotsRule(),
            RequireCameraMetadataRule(),
            RequireExifDataRule(),
          ];

  Future<ValidationResult> validate(PizzaImageMetadata metadata) async {
    for (final rule in rules) {
      final result = await rule.validate(metadata);

      if (result is ValidationRejected) {
        return result;
      }
    }

    return const ValidationSuccess();
  }
}
