/// Represents a relationship between CAM Parameters.
abstract class CamRelation {
  /// The parameter that this relation targets/defines.
  final String targetParamName;

  const CamRelation({required this.targetParamName});
}

/// A relation that uses a JavaScript expression to compute a value or condition.
class CamExpressionRelation extends CamRelation {
  /// The JavaScript expression string.
  final String expression;

  /// List of parameter names that this expression depends on.
  final List<String> referencedParamNames;

  const CamExpressionRelation({
    required super.targetParamName,
    required this.expression,
    this.referencedParamNames = const [],
  });

  /// Returns true if the expression is empty or null-equivalent.
  bool get isEmpty => expression.trim().isEmpty;
}

/// A relation that represents a hierarchical link between parameters (Parent -> Child).
class CamHierarchyRelation extends CamRelation {
  /// The name of the child parameter.
  final String childParamName;

  const CamHierarchyRelation({
    required super.targetParamName,
    required this.childParamName,
  });
}
