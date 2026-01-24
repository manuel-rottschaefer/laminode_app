import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/cam_relation.dart';
import 'package:laminode_app/features/evaluation/application/expression_parser.dart';
import 'package:laminode_app/features/evaluation/domain/evaluation_engine.dart';

/// Service responsible for managing and evaluating parameter relations.
class CamRelationService {
  final EvaluationEngine _engine;
  final ExpressionParser _parser;

  CamRelationService(this._engine, this._parser);

  /// Evaluates an expression relation within the context of other parameters.
  dynamic evaluateRelation(
    CamExpressionRelation relation,
    Map<String, dynamic> context,
  ) {
    if (relation.isEmpty) return null;
    return _engine.evaluate(relation.expression, context);
  }

  /// Analyzes a parameter's expressions to find which other parameters it references.
  /// Updates the [referencedParamNames] in the relations.
  CamParameter analyzeDependencies(CamParameter param) {
    final minRefs = _parser
        .extractVariableNames(param.minThreshold.expression)
        .toList();
    final maxRefs = _parser
        .extractVariableNames(param.maxThreshold.expression)
        .toList();
    final defRefs = _parser
        .extractVariableNames(param.defaultValue.expression)
        .toList();
    final sugRefs = _parser
        .extractVariableNames(param.suggestedValue.expression)
        .toList();
    final enRefs = _parser
        .extractVariableNames(param.enabledCondition.expression)
        .toList();

    return (param as dynamic).copyWith(
      minThreshold: CamExpressionRelation(
        targetParamName: param.paramName,
        expression: param.minThreshold.expression,
        referencedParamNames: minRefs,
      ),
      maxThreshold: CamExpressionRelation(
        targetParamName: param.paramName,
        expression: param.maxThreshold.expression,
        referencedParamNames: maxRefs,
      ),
      defaultValue: CamExpressionRelation(
        targetParamName: param.paramName,
        expression: param.defaultValue.expression,
        referencedParamNames: defRefs,
      ),
      suggestedValue: CamExpressionRelation(
        targetParamName: param.paramName,
        expression: param.suggestedValue.expression,
        referencedParamNames: sugRefs,
      ),
      enabledCondition: CamExpressionRelation(
        targetParamName: param.paramName,
        expression: param.enabledCondition.expression,
        referencedParamNames: enRefs,
      ),
    );
  }

  /// Rebuilds the dependentParamNames for all parameters in the map.
  Map<String, CamParameter> rebuildDependencyGraph(
    Map<String, CamParameter> allParams,
  ) {
    final Map<String, Set<String>> reverseDeps = {};

    for (final param in allParams.values) {
      final allRefs = {
        ...param.minThreshold.referencedParamNames,
        ...param.maxThreshold.referencedParamNames,
        ...param.defaultValue.referencedParamNames,
        ...param.suggestedValue.referencedParamNames,
        ...param.enabledCondition.referencedParamNames,
      };

      for (final ref in allRefs) {
        if (allParams.containsKey(ref)) {
          reverseDeps.putIfAbsent(ref, () => {}).add(param.paramName);
        }
      }
    }

    final result = <String, CamParameter>{};
    for (final entry in allParams.entries) {
      result[entry.key] = (entry.value as dynamic).copyWith(
        dependentParamNames:
            reverseDeps[entry.key]?.toList() ?? const <String>[],
      );
    }
    return result;
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
