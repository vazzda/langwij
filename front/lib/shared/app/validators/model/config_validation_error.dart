class ConfigValidationError implements Exception {
  const ConfigValidationError(this.message);
  final String message;

  @override
  String toString() => 'ConfigValidationError: $message';
}
