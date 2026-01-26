import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/features/evaluation/application/expression_parser.dart';
import 'package:laminode_app/features/evaluation/domain/evaluation_engine.dart';
import 'package:laminode_app/features/evaluation/domain/expression_validation_result.dart';

class ExpressionValidator {
  final ExpressionParser _parser;
  final EvaluationEngine _engine;

  ExpressionValidator(this._parser, this._engine);

  /// Validates an expression against a list of available parameters.
  /// [expectedType] can be used to further validate the result (e.g., bool for conditions).
  ExpressionValidationResult validate(
    String expression,
    List<CamParameter> availableParams, {
    QuantityType? expectedQuantityType,
    bool isCondition = false,
  }) {
    if (expression.trim().isEmpty) {
      return ExpressionValidationResult.valid(null);
    }

    // 1. Check if every word in the expression can be mapped to a parameter
    final variables = _parser.extractVariableNames(expression);
    final paramMap = {for (final p in availableParams) p.paramName: p};

    final unknownVariables = <String>[];
    for (final variable in variables) {
      if (!paramMap.containsKey(variable)) {
        unknownVariables.add(variable);
      }
    }

    if (unknownVariables.isNotEmpty) {
      return ExpressionValidationResult.invalid(
        'Unknown parameters: ${unknownVariables.join(', ')}',
      );
    }

    // 2. Run the expression once with default values
    final context = <String, dynamic>{};
    for (final variable in variables) {
      context[variable] = paramMap[variable]!.quantity.validationDefaultValue;
    }

    try {
      final result = _engine.evaluate(expression, context);

      // 3. Verify result type
      if (isCondition) {
        if (result is! bool) {
          return ExpressionValidationResult.invalid(
            'Expression must evaluate to a boolean (got ${result?.runtimeType ?? 'null'})',
          );
        }
      } else if (expectedQuantityType != null) {
        switch (expectedQuantityType) {
          case QuantityType.numeric:
            if (result is! num) {
              return ExpressionValidationResult.invalid(
                'Expression must evaluate to a number (got ${result?.runtimeType ?? 'null'})',
              );
            }
            break;
          case QuantityType.choice:
            if (result is! String) {
              return ExpressionValidationResult.invalid(
                'Expression must evaluate to a string (got ${result?.runtimeType ?? 'null'})',
              );
            }
            break;
          case QuantityType.boolean:
            if (result is! bool) {
              return ExpressionValidationResult.invalid(
                'Expression must evaluate to a boolean (got ${result?.runtimeType ?? 'null'})',
              );
            }
            break;
        }
      }

      return ExpressionValidationResult.valid(result);
    } catch (e) {
      return ExpressionValidationResult.invalid('Evaluation error: $e');
    }
  }
}
