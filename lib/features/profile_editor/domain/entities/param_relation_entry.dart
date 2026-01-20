import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/cam_relation.dart';

// A relation entry is a representation of a CamRelation that stores pre-computed references
class ParamRelationEntry extends CamRelation {
  final List<String>? referencedParamNames;

  const ParamRelationEntry({
    required super.targetParam,
    required super.expression,
    this.referencedParamNames,
  });

  ParamRelationEntry copyWith({
    CamParameter? targetParam,
    String? expression,
    List<String>? referencedParamNames,
  }) {
    return ParamRelationEntry(
      targetParam: targetParam ?? this.targetParam,
      expression: expression ?? this.expression,
      referencedParamNames: referencedParamNames ?? this.referencedParamNames,
    );
  }
}
