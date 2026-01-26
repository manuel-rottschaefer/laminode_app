class ExpressionValidationResult {
  final bool isValid;
  final String? errorMessage;
  final dynamic resultValue;
  final Type? resultType;

  const ExpressionValidationResult({
    required this.isValid,
    this.errorMessage,
    this.resultValue,
    this.resultType,
  });

  factory ExpressionValidationResult.valid(dynamic resultValue) {
    return ExpressionValidationResult(
      isValid: true,
      resultValue: resultValue,
      resultType: resultValue?.runtimeType,
    );
  }

  factory ExpressionValidationResult.invalid(String errorMessage) {
    return ExpressionValidationResult(
      isValid: false,
      errorMessage: errorMessage,
    );
  }
}
