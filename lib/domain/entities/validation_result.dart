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
  final String ruleName;
  final String reason;
  const ValidationUnsure(this.ruleName, this.reason);
}

class ValidationUnsureList extends ValidationResult {
  final List<ValidationUnsure> results;
  const ValidationUnsureList(this.results);
}
