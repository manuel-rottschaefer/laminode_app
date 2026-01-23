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
    // Inject context variables into the JS scope
    // We wrap values in a JSON object to safely pass them
    final jsonContext = jsonEncode(context);
    
    // We assign the context to a global variable '__ctx'
    // and then use a 'with' statement or explicit property access?
    // 'with' is often discouraged but convenient for simple formulas like "a + b" where a and b are keys.
    // However, strict mode forbids 'with'. 
    // A safer way is to replace variable names or just expose them globally if keys are safe.
    
    // For robust evaluation without parsing, we can declare variables.
    // Assuming context keys are valid JS identifiers.
    
    // Better approach: 
    // 1. Assign context to a variable
    final setupScript = 'var __ctx = $jsonContext;';
    _runtime.evaluate(setupScript);

    // 2. Create a function that destructures __ctx and returns the expression
    // "with(__ctx) { return ( expression ); }"
    // This allows writing "a + b" instead of "__ctx.a + __ctx.b"
    final evalScript = 'with(__ctx) { $expression }';

    final result = _runtime.evaluate(evalScript);

    if (result.isError) {
      throw Exception('JS Evaluation Error: ${result.stringResult}');
    }

    return result.rawResult;
  }

  void dispose() {
    _runtime.dispose();
  }
}
