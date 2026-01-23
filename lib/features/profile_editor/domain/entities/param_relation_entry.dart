import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/cam_relation.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';

// A relation entry is a representation of a CamRelation that stores pre-computed references
class ParamRelationEntry extends CamRelation {
  const ParamRelationEntry({
    required super.targetParam,
    required super.expression,
    List<CamParamEntry> referencedParamNames = const [],
  }) : super(referencedParams: referencedParamNames);

  // Convenience getter to access referencedParams as CamParamEntry list
  List<CamParamEntry> get referencedEntries => referencedParams.cast<CamParamEntry>();

  ParamRelationEntry copyWith({
    CamParameter? targetParam,
    String? expression,
    List<CamParamEntry>? referencedParamNames,
  }) {
    return ParamRelationEntry(
      targetParam: targetParam ?? this.targetParam,
      expression: expression ?? this.expression,
      referencedParamNames: referencedParamNames ?? this.referencedEntries,
    );
  }
}
