abstract class EvaluationEngine {
  /// Evaluates the [expression] using the provided [context].
  /// [context] maps variable names to their values.
  dynamic evaluate(String expression, Map<String, dynamic> context);
}
