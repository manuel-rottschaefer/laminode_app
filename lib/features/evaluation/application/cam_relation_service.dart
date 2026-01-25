import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/cam_relation.dart';
import 'package:laminode_app/features/evaluation/domain/evaluation_engine.dart';

/// Service responsible for managing and evaluating parameter relations.
class CamRelationService {
  final EvaluationEngine _engine;

  CamRelationService(this._engine);

  /// Evaluates an expression relation within the context of other parameters.
  dynamic evaluateRelation(
    CamExpressionRelation relation,
    Map<String, dynamic> context,
  ) {
    if (relation.isEmpty) return null;
    return _engine.evaluate(relation.expression, context);
  }

  /// Re-evaluates all parameters that depend on [changedParamName].
  /// Returns a map of updated parameter values.
  Map<String, dynamic> propagateChanges(
    String changedParamName,
    Map<String, CamParameter> allParams,
    Map<String, dynamic> currentValues,
  ) {
    final updatedValues = Map<String, dynamic>.from(currentValues);
    final queue = <String>[changedParamName];
    final visited = <String>{};

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (visited.contains(current)) continue;
      visited.add(current);

      final param = allParams[current];
      if (param == null) continue;

      // Find parameters that reference this one
      for (final dependentName in param.dependentParamNames) {
        final dependentParam = allParams[dependentName];
        if (dependentParam == null) continue;

        // Re-evaluate its default value (or others if needed)
        // For now we focus on default value as it's the primary derived value
        final newValue = evaluateRelation(
          dependentParam.defaultValue,
          updatedValues,
        );

        if (newValue != updatedValues[dependentName]) {
          updatedValues[dependentName] = newValue;
          queue.add(dependentName);
        }
      }
    }

    return updatedValues;
  }
}
