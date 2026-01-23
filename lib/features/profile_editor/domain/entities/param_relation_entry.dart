import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/cam_relation.dart';

// A relation entry is a representation of a ValueRelation that stores pre-computed references
class ParamRelationEntry extends ValueRelation {
  const ParamRelationEntry({
    required super.targetParam,
    required super.expression,
    required super.referencedParams,
  });

  ParamRelationEntry copyWith({
    CamParameter? targetParam,
    String? expression,
    List<CamParameter>? referencedParams,
  }) {
    return ParamRelationEntry(
      targetParam: targetParam ?? this.targetParam,
      expression: expression ?? this.expression,
      referencedParams: referencedParams ?? this.referencedParams,
    );
  }

  @override
  dynamic eval([Map<String, dynamic>? context]) {
    if (expression?.isEmpty ?? true) {
      return null;
    }

    // TODO: Implement Eval engine lookup and execution.
    // Usually it has a .eval(expression, context) method.
    return null;
  }
}
