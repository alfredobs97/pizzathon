sealed class ValidationResult {
  const ValidationResult();
}

class ValidationSuccess extends ValidationResult {
  const ValidationSuccess();
}

class ValidationRejected extends ValidationResult {
  final String reason;
  const ValidationRejected(this.reason);
}

class ValidationUnsure extends ValidationResult {
  final String reason;
  const ValidationUnsure(this.reason);
}
