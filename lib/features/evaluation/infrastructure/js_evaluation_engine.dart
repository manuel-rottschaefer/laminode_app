import 'dart:convert';
import 'package:flutter_js/flutter_js.dart';
import 'package:laminode_app/features/evaluation/domain/evaluation_engine.dart';

class JsEvaluationEngine implements EvaluationEngine {
  late JavascriptRuntime _runtime;

  JsEvaluationEngine() {
    _runtime = getJavascriptRuntime();
  }

  @override
  dynamic evaluate(String expression, Map<String, dynamic> context) {
    if (expression.trim().isEmpty) return null;

    // Inject context variables into the JS scope
    final jsonContext = jsonEncode(context);

    // Instead of using 'with', we will declare each variable locally in an IIFE.
    // This is safer and avoids strict mode issues with 'with'.
    // We create a script that:
    // 1. Parses the context
    // 2. Extracts keys
    // 3. Evaluates the expression in that scope

    final buffer = StringBuffer();
    buffer.writeln('(function() {');
    buffer.writeln('  const ctx = $jsonContext;');
    for (final key in context.keys) {
      // Ensure key is a valid identifier (we assume they are for now)
      buffer.writeln('  const $key = ctx["$key"];');
    }
    buffer.writeln('  return ($expression);');
    buffer.writeln('})();');

    final result = _runtime.evaluate(buffer.toString());

    if (result.isError) {
      // For now we'll return null to prevent crashing the whole app.
      // In a real app we might want to log this to a crash reporting service.
      return null;
    }

    return _parseResult(result.rawResult);
  }

  /// Converts JS results to Dart-friendly types
  dynamic _parseResult(dynamic raw) {
    if (raw is num || raw is bool || raw is String || raw == null) {
      return raw;
    }
    // Handle other types if necessary
    return raw.toString();
  }

  void dispose() {
    _runtime.dispose();
  }
}
