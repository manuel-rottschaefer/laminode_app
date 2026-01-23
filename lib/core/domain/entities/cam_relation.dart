// A CAM Relation represents a bound relationship of a CAM Parameter to one or many other parameters
import 'package:laminode_app/core/domain/entities/cam_param.dart';

abstract class CamRelation {
  final CamParameter targetParam;

  const CamRelation({required this.targetParam});
}

/// A relation that carries an expression used to compute a value
class ValueRelation extends CamRelation {
  final String expression;

  const ValueRelation({required super.targetParam, required this.expression});

  /// Evaluates the expression using a context
  dynamic eval([Map<String, dynamic>? context]) {
    if (expression.isEmpty) return null;
    // TODO: Connect to expression engine
    return null;
  }
}

/// A relation that represents hierarchy without an expression
class AncestorRelation extends CamRelation {
  final CamParameter ancestorParam;

  const AncestorRelation({required super.targetParam, required this.ancestorParam});
}
